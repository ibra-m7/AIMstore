<?php

namespace App\Services\Catalog;

use App\Enums\ProductRelationType;
use App\Http\Resources\ProductResource;
use App\Models\Product;
use App\Models\ProductRelation;
use App\Models\User;
use App\Services\Ai\RecommendationTrainer;
use App\Support\StoreSettings;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Cache;

class ProductRecommendationService
{
    public function __construct(
        private readonly ProductRecommendationEngine $engine,
        private readonly RecommendationTrainer $trainer,
    ) {}

    /**
     * Shared pipeline:
     * manual complements (always) → optional auto bought-together → AI reorder → dedupe → resources.
     *
     * @return array{bought_together: array<int, mixed>, similar: array<int, mixed>, suggested: array<int, mixed>}
     */
    public function forProduct(Product $product, ?User $user = null): array
    {
        $product->loadMissing(['category', 'productRelations']);

        $manual = $this->manualBoughtTogether($product);

        if (StoreSettings::autoProductRecommendations()) {
            $autoBought = $this->engine->withoutIds(
                $this->engine->boughtTogether($product, 12),
                $manual->pluck('id')->all()
            );
            $autoBought = $this->applyCachedRank(
                'bought_together',
                [
                    'product_id' => $product->id,
                    'name' => $product->name,
                    'category' => $product->category?->name,
                ],
                $autoBought
            );
            $bought = $manual->concat($autoBought)->unique('id')->take(8)->values();
        } else {
            $bought = $manual->take(8)->values();
        }

        $similar = $this->applyCachedRank(
            'similar',
            [
                'product_id' => $product->id,
                'name' => $product->name,
                'category' => $product->category?->name,
            ],
            $this->engine->withoutIds(
                $this->engine->similar($product, 12),
                $bought->pluck('id')->all()
            )
        )->take(8)->values();

        $exclude = array_merge(
            [(int) $product->id],
            $bought->pluck('id')->map(fn ($id) => (int) $id)->all(),
            $similar->pluck('id')->map(fn ($id) => (int) $id)->all(),
        );
        $suggested = $this->engine->contextualSuggested($product, $user, $exclude, 8);

        return [
            'bought_together' => $this->resources($bought),
            'similar' => $this->resources($similar),
            'suggested' => $this->resources($suggested),
        ];
    }

    /**
     * @param  list<int>  $productIds
     * @return array{complete_cart: array<int, mixed>, suggested: array<int, mixed>}
     */
    public function forCart(array $productIds, ?User $user = null): array
    {
        $complete = $this->applyCachedRank(
            'complete_cart',
            ['product_ids' => $productIds],
            $this->engine->completeCart($productIds, 12)
        )->take(8)->values();

        $exclude = array_merge(
            $productIds,
            $complete->pluck('id')->map(fn ($id) => (int) $id)->all(),
        );

        $suggested = $this->engine->withoutIds(
            $this->forYou($user, $exclude, 8),
            $exclude
        )->take(8)->values();

        return [
            'complete_cart' => $this->resources($complete),
            'suggested' => $this->resources($suggested),
        ];
    }

    /**
     * @param  list<int>  $excludeIds
     * @return Collection<int, Product>
     */
    public function forYou(?User $user, array $excludeIds = [], int $limit = 10): Collection
    {
        $cacheKey = 'reco:foryou:v3:'.($user?->id ?? 'guest').':'.md5(implode(',', $excludeIds)).':'.$limit;

        $ids = Cache::remember($cacheKey, now()->addMinutes(20), function () use ($user, $excludeIds, $limit) {
            return $this->engine->forYou($user, $excludeIds, $limit)->pluck('id')->all();
        });

        $products = Product::query()
            ->active()
            ->sellable()
            ->with($this->engine->relations())
            ->whereIn('id', $ids)
            ->get();

        return $this->engine->applyOrder($products, array_map('intval', $ids))->take($limit)->values();
    }

    /**
     * Admin-selected complementary products — always preferred for «يُشترى معه».
     *
     * @return Collection<int, Product>
     */
    private function manualBoughtTogether(Product $product): Collection
    {
        $ids = ProductRelation::query()
            ->where('product_id', $product->id)
            ->where('type', ProductRelationType::Complementary)
            ->where(function ($query) {
                $query->where('source', 'manual')
                    ->orWhereNull('source')
                    ->orWhere('source', '');
            })
            ->orderBy('sort_order')
            ->pluck('related_product_id')
            ->map(fn ($id) => (int) $id)
            ->filter(fn (int $id) => $id > 0)
            ->unique()
            ->values()
            ->all();

        if ($ids === []) {
            return collect();
        }

        $products = Product::query()
            ->active()
            ->sellable()
            ->with($this->engine->relations())
            ->whereIn('id', $ids)
            ->get();

        return $this->engine->applyOrder($products, $ids);
    }

    /**
     * @param  Collection<int, Product>  $products
     * @return Collection<int, Product>
     */
    private function applyCachedRank(string $mechanism, array $anchor, Collection $products): Collection
    {
        if ($products->isEmpty()) {
            return $products;
        }

        $ranked = $this->trainer->cachedRank(
            $mechanism,
            $this->trainer->contextKey($anchor, $products),
            $products
        );

        if ($ranked === null || $ranked === []) {
            $ranked = $this->trainer->cachedRank(
                $mechanism,
                $this->trainer->contextKey($anchor, collect()),
                $products
            );
        }

        return $ranked ? $this->engine->applyOrder($products, $ranked) : $products;
    }

    /**
     * @param  Collection<int, Product>  $products
     * @return array<int, mixed>
     */
    private function resources(Collection $products): array
    {
        return ProductResource::collection($products->values())->resolve();
    }
}
