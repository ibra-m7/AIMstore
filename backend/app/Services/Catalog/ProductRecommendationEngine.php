<?php

namespace App\Services\Catalog;

use App\Enums\OrderStatus;
use App\Enums\ProductRelationType;
use App\Models\Favorite;
use App\Models\Product;
use App\Models\ProductRelation;
use App\Models\User;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class ProductRecommendationEngine
{
    private const MAX_PER_CATEGORY_COMPLEMENT = 2;

    /**
     * Complementary products: frequently bought together / complete the item.
     *
     * @return Collection<int, Product>
     */
    public function boughtTogether(Product $product, int $limit = 8): Collection
    {
        $scores = $this->coOccurrenceScores([$product->id]);

        foreach ($this->relationsOf($product->id) as $relation) {
            $relatedId = (int) $relation->related_product_id;
            $scores[$relatedId] = ($scores[$relatedId] ?? 0) + $this->relationBonus($relation);
        }

        $picked = $this->hydrateRanked(
            $scores,
            [$product->id],
            $limit * 2,
            $product->category_id,
            preferOtherCategory: true,
        );
        $picked = $this->diversifyByCategory($picked, $limit, self::MAX_PER_CATEGORY_COMPLEMENT);

        if ($picked->count() >= $limit) {
            return $picked;
        }

        return $this->fillFromPool(
            $picked,
            $this->popularPool([$product->id], $product->category_id, otherCategory: true),
            $limit
        );
    }

    /**
     * Substitutes: same need, similar category/price/keywords.
     *
     * @return Collection<int, Product>
     */
    public function similar(Product $product, int $limit = 8): Collection
    {
        $complementIds = $this->relationsOf($product->id)
            ->where('type', ProductRelationType::Complementary)
            ->pluck('related_product_id')
            ->map(fn ($id) => (int) $id)
            ->all();

        $candidates = Product::query()
            ->active()
            ->sellable()
            ->with($this->relations())
            ->forCategory($product->category_id)
            ->where('id', '!=', $product->id)
            ->when($complementIds !== [], fn ($q) => $q->whereNotIn('id', $complementIds))
            ->orderByDesc('is_featured')
            ->orderByDesc('review_count')
            ->limit(40)
            ->get();

        if ($candidates->count() < 8 && $product->category?->parent_id) {
            $extra = Product::query()
                ->active()
                ->sellable()
                ->with($this->relations())
                ->forCategory($product->category->parent_id)
                ->where('id', '!=', $product->id)
                ->whereNotIn('id', $candidates->modelKeys())
                ->when($complementIds !== [], fn ($q) => $q->whereNotIn('id', $complementIds))
                ->limit(24)
                ->get();
            $candidates = $candidates->concat($extra);
        }

        $anchorPrice = (float) $product->effective_price;
        $anchorTokens = $this->tokens($product->name.' '.implode(' ', $product->keywords ?? []));
        $anchorKeywords = $this->normalizedSet($product->keywords ?? []);

        $ranked = $candidates
            ->map(function (Product $candidate) use ($product, $anchorPrice, $anchorTokens, $anchorKeywords) {
                $score = 0.0;
                if ((int) $candidate->category_id === (int) $product->category_id) {
                    $score += 22;
                } else {
                    $score += 10;
                }

                $price = (float) $candidate->effective_price;
                if ($anchorPrice > 0 && $price > 0) {
                    $ratio = $price / $anchorPrice;
                    if ($ratio >= 0.6 && $ratio <= 1.5) {
                        $score += 12;
                    } elseif ($ratio >= 0.4 && $ratio <= 2.0) {
                        $score += 6;
                    }
                }

                $score += count(array_intersect($anchorKeywords, $this->normalizedSet($candidate->keywords ?? []))) * 5;
                $score += count(array_intersect($anchorTokens, $this->tokens($candidate->name))) * 3;
                $score += $this->popularity($candidate);

                return ['product' => $candidate, 'score' => $score];
            })
            ->sortByDesc('score')
            ->values();

        return $ranked
            ->pluck('product')
            ->unique('id')
            ->take($limit)
            ->values();
    }

    /**
     * Complete the cart: missing complementary categories, not substitutes.
     *
     * @param  list<int>  $productIds
     * @return Collection<int, Product>
     */
    public function completeCart(array $productIds, int $limit = 8): Collection
    {
        $productIds = $this->uniqueIds($productIds);
        if ($productIds === []) {
            return collect();
        }

        $cart = Product::query()
            ->with(['productRelations', 'category'])
            ->whereIn('id', $productIds)
            ->get();
        $cartCategoryIds = $cart->pluck('category_id')->map(fn ($id) => (int) $id)->unique()->all();
        $scores = $this->coOccurrenceScores($productIds);

        foreach ($cart as $item) {
            foreach ($this->relationsOf($item->id, $item) as $relation) {
                $relatedId = (int) $relation->related_product_id;
                if (in_array($relatedId, $productIds, true)) {
                    continue;
                }
                $scores[$relatedId] = ($scores[$relatedId] ?? 0) + $this->relationBonus($relation, cartMode: true);
            }
        }

        $picked = $this->hydrateRanked(
            $scores,
            $productIds,
            $limit * 2,
            $cartCategoryIds,
            preferOtherCategory: true,
        );
        $picked = $this->diversifyByCategory($picked, $limit, self::MAX_PER_CATEGORY_COMPLEMENT);

        if ($picked->count() >= $limit) {
            return $picked;
        }

        return $this->fillFromPool(
            $picked,
            $this->popularPool($productIds, $cartCategoryIds, otherCategory: true),
            $limit
        );
    }

    /**
     * Personal / home feed suggestions.
     *
     * @param  list<int>  $excludeIds
     * @return Collection<int, Product>
     */
    public function forYou(?User $user, array $excludeIds = [], int $limit = 10): Collection
    {
        $excludeIds = $this->uniqueIds($excludeIds);
        $scores = [];
        $affinityCategories = [];

        if ($user) {
            $history = DB::table('order_items')
                ->join('orders', 'orders.id', '=', 'order_items.order_id')
                ->join('products', 'products.id', '=', 'order_items.product_id')
                ->where('orders.user_id', $user->id)
                ->where('orders.status', '!=', OrderStatus::Cancelled->value)
                ->selectRaw('order_items.product_id, products.category_id, COUNT(*) as freq')
                ->groupBy('order_items.product_id', 'products.category_id')
                ->get();

            foreach ($history as $row) {
                $productId = (int) $row->product_id;
                $affinityCategories[] = (int) $row->category_id;
                // Grocery repurchase is intentional.
                $scores[$productId] = ($scores[$productId] ?? 0) + 16 + min(8, (int) $row->freq);
            }

            foreach ($this->relationsForProducts($history->pluck('product_id')->all()) as $relation) {
                $relatedId = (int) $relation->related_product_id;
                $scores[$relatedId] = ($scores[$relatedId] ?? 0) + 22;
            }

            $favoriteRows = Favorite::query()
                ->where('user_id', $user->id)
                ->with('product:id,category_id')
                ->limit(40)
                ->get();

            foreach ($favoriteRows as $favorite) {
                $productId = (int) $favorite->product_id;
                $scores[$productId] = ($scores[$productId] ?? 0) + 18;
                if ($favorite->product) {
                    $affinityCategories[] = (int) $favorite->product->category_id;
                }
            }
        }

        $affinityCategories = array_values(array_unique(array_filter($affinityCategories)));

        $pool = Product::query()
            ->active()
            ->sellable()
            ->with($this->relations())
            ->when($excludeIds !== [], fn ($query) => $query->whereNotIn('id', $excludeIds))
            ->orderByDesc('is_featured')
            ->orderByDesc('review_count')
            ->limit(48)
            ->get();

        foreach ($pool as $product) {
            $score = $scores[$product->id] ?? 0;
            $score += $this->popularity($product);
            if (in_array((int) $product->category_id, $affinityCategories, true)) {
                $score += 10;
            }
            $scores[$product->id] = $score;
        }

        $picked = $this->hydrateRanked($scores, $excludeIds, $limit * 2);
        $picked = $this->diversifyByCategory($picked, $limit, 3);

        if ($picked->count() >= $limit) {
            return $picked;
        }

        return $this->fillFromPool($picked, $pool, $limit);
    }

    /**
     * Product-detail "suggested" row: contextual discovery, not generic popularity.
     *
     * @param  list<int>  $excludeIds
     * @return Collection<int, Product>
     */
    public function contextualSuggested(
        Product $product,
        ?User $user,
        array $excludeIds = [],
        int $limit = 8,
    ): Collection {
        $excludeIds = $this->uniqueIds(array_merge($excludeIds, [$product->id]));
        $scores = [];

        foreach ($this->relationsOf($product->id) as $relation) {
            $relatedId = (int) $relation->related_product_id;
            if (in_array($relatedId, $excludeIds, true)) {
                continue;
            }
            // Softer than bought-together so the row stays distinct.
            $bonus = $relation->type === ProductRelationType::Complementary ? 28.0 : 10.0;
            if ((string) ($relation->source ?? '') === 'manual') {
                $bonus += 20.0;
            }
            $scores[$relatedId] = ($scores[$relatedId] ?? 0) + $bonus;
        }

        foreach ($this->coOccurrenceScores([$product->id]) as $id => $score) {
            if (in_array((int) $id, $excludeIds, true)) {
                continue;
            }
            $scores[(int) $id] = ($scores[(int) $id] ?? 0) + ($score * 0.55);
        }

        if ($user) {
            foreach ($this->forYou($user, $excludeIds, 16) as $index => $candidate) {
                $scores[(int) $candidate->id] = ($scores[(int) $candidate->id] ?? 0) + max(4, 14 - $index);
            }
        }

        $pool = Product::query()
            ->active()
            ->sellable()
            ->with($this->relations())
            ->whereNotIn('id', $excludeIds)
            ->when(
                $product->category_id,
                fn ($q) => $q->where(function ($inner) use ($product) {
                    $inner->where('category_id', '!=', $product->category_id)
                        ->orWhere('is_featured', true)
                        ->orWhereNotNull('discount_price');
                })
            )
            ->orderByDesc('is_featured')
            ->orderByDesc('review_count')
            ->limit(36)
            ->get();

        foreach ($pool as $candidate) {
            $score = $scores[$candidate->id] ?? 0;
            $score += $this->popularity($candidate);
            if ((int) $candidate->category_id !== (int) $product->category_id) {
                $score += 8;
            }
            if ($candidate->has_discount) {
                $score += 5;
            }
            $scores[$candidate->id] = $score;
        }

        $picked = $this->hydrateRanked(
            $scores,
            $excludeIds,
            $limit * 2,
            $product->category_id,
            preferOtherCategory: true,
        );
        $picked = $this->diversifyByCategory($picked, $limit, 2);

        if ($picked->count() >= $limit) {
            return $picked;
        }

        return $this->fillFromPool($picked, $pool, $limit);
    }

    /**
     * @param  list<int>  $orderedIds
     * @param  Collection<int, Product>  $products
     * @return Collection<int, Product>
     */
    public function applyOrder(Collection $products, array $orderedIds): Collection
    {
        if ($products->isEmpty() || $orderedIds === []) {
            return $products;
        }

        $byId = $products->keyBy(fn (Product $product) => (int) $product->id);
        $ordered = collect();
        foreach ($orderedIds as $id) {
            $product = $byId->get((int) $id);
            if ($product) {
                $ordered->push($product);
                $byId->forget((int) $id);
            }
        }

        return $ordered->concat($byId->values())->values();
    }

    /**
     * Drop products already shown in earlier recommendation rows.
     *
     * @param  Collection<int, Product>  $products
     * @param  list<int>  $excludeIds
     * @return Collection<int, Product>
     */
    public function withoutIds(Collection $products, array $excludeIds): Collection
    {
        $excludeIds = $this->uniqueIds($excludeIds);
        if ($excludeIds === []) {
            return $products->values();
        }

        return $products
            ->reject(fn (Product $product) => in_array((int) $product->id, $excludeIds, true))
            ->values();
    }

    /**
     * @return list<string>
     */
    public function relations(): array
    {
        return ['images', 'primaryImage', 'category'];
    }

    /**
     * @param  list<int>  $productIds
     * @return array<int, float>
     */
    private function coOccurrenceScores(array $productIds): array
    {
        $productIds = $this->uniqueIds($productIds);
        if ($productIds === []) {
            return [];
        }

        $rows = DB::table('order_items as a')
            ->join('order_items as b', 'a.order_id', '=', 'b.order_id')
            ->join('orders', 'orders.id', '=', 'a.order_id')
            ->whereIn('a.product_id', $productIds)
            ->whereNotIn('b.product_id', $productIds)
            ->where('orders.status', '!=', OrderStatus::Cancelled->value)
            ->selectRaw('b.product_id, COUNT(*) as freq')
            ->groupBy('b.product_id')
            ->orderByDesc('freq')
            ->limit(48)
            ->get();

        $scores = [];
        foreach ($rows as $row) {
            $scores[(int) $row->product_id] = 8 + min(24, (int) $row->freq * 4);
        }

        return $scores;
    }

    private function relationBonus(ProductRelation $relation, bool $cartMode = false): float
    {
        $type = $relation->type instanceof ProductRelationType
            ? $relation->type
            : ProductRelationType::tryFrom((string) $relation->type);

        $bonus = match ($type) {
            ProductRelationType::Complementary => $cartMode ? 46.0 : 40.0,
            ProductRelationType::Upsell => $cartMode ? 18.0 : 14.0,
            default => 8.0,
        };

        $source = (string) ($relation->source ?? 'manual');
        if ($source === 'manual') {
            $bonus += $cartMode ? 100.0 : 120.0;
        } elseif ($source === 'ai') {
            $bonus += 8.0;
        }

        return $bonus;
    }

    /**
     * @return Collection<int, ProductRelation>
     */
    private function relationsOf(int $productId, ?Product $product = null): Collection
    {
        if ($product && $product->relationLoaded('productRelations')) {
            return $product->productRelations
                ->reject(fn (ProductRelation $relation) => $relation->type === ProductRelationType::Gift
                    || (string) $relation->type === ProductRelationType::Gift->value);
        }

        return ProductRelation::query()
            ->where('product_id', $productId)
            ->where('type', '!=', ProductRelationType::Gift->value)
            ->orderBy('sort_order')
            ->get();
    }

    /**
     * @param  list<int|string>  $productIds
     * @return Collection<int, ProductRelation>
     */
    private function relationsForProducts(array $productIds): Collection
    {
        $productIds = $this->uniqueIds($productIds);
        if ($productIds === []) {
            return collect();
        }

        return ProductRelation::query()
            ->whereIn('product_id', $productIds)
            ->where('type', '!=', ProductRelationType::Gift->value)
            ->orderBy('sort_order')
            ->get();
    }

    /**
     * @param  array<int, float>  $scores
     * @param  list<int>  $excludeIds
     * @param  int|list<int>|null  $avoidCategories
     * @return Collection<int, Product>
     */
    private function hydrateRanked(
        array $scores,
        array $excludeIds,
        int $limit,
        int|array|null $avoidCategories = null,
        bool $preferOtherCategory = false,
    ): Collection {
        foreach ($excludeIds as $id) {
            unset($scores[(int) $id]);
        }
        if ($scores === []) {
            return collect();
        }

        arsort($scores);
        $ids = array_keys(array_slice($scores, 0, 48, true));
        $products = Product::query()
            ->active()
            ->sellable()
            ->with($this->relations())
            ->whereIn('id', $ids)
            ->get()
            ->keyBy('id');

        $avoid = is_array($avoidCategories)
            ? array_map('intval', $avoidCategories)
            : ((int) $avoidCategories > 0 ? [(int) $avoidCategories] : []);

        return collect($ids)
            ->map(function (int $id) use ($products, $scores, $avoid, $preferOtherCategory) {
                $product = $products->get($id);
                if (! $product) {
                    return null;
                }
                $score = $scores[$id] ?? 0;
                if ($preferOtherCategory && $avoid !== [] && ! in_array((int) $product->category_id, $avoid, true)) {
                    $score += 10;
                } elseif ($preferOtherCategory && in_array((int) $product->category_id, $avoid, true)) {
                    $score -= 6;
                }
                $score += $this->popularity($product);

                return ['product' => $product, 'score' => $score];
            })
            ->filter()
            ->sortByDesc('score')
            ->pluck('product')
            ->unique('id')
            ->take($limit)
            ->values();
    }

    /**
     * Cap how many products share the same category in a complement-style row.
     *
     * @param  Collection<int, Product>  $products
     * @return Collection<int, Product>
     */
    private function diversifyByCategory(Collection $products, int $limit, int $maxPerCategory): Collection
    {
        $counts = [];
        $picked = collect();
        $deferred = collect();

        foreach ($products as $product) {
            $categoryId = (int) $product->category_id;
            $used = $counts[$categoryId] ?? 0;
            if ($used < $maxPerCategory) {
                $picked->push($product);
                $counts[$categoryId] = $used + 1;
            } else {
                $deferred->push($product);
            }

            if ($picked->count() >= $limit) {
                break;
            }
        }

        if ($picked->count() < $limit) {
            foreach ($deferred as $product) {
                $picked->push($product);
                if ($picked->count() >= $limit) {
                    break;
                }
            }
        }

        return $picked->values();
    }

    /**
     * @param  list<int>  $excludeIds
     * @param  int|list<int>|null  $avoidCategories
     * @return Collection<int, Product>
     */
    private function popularPool(array $excludeIds, int|array|null $avoidCategories = null, bool $otherCategory = false): Collection
    {
        $avoid = is_array($avoidCategories)
            ? array_map('intval', $avoidCategories)
            : ((int) $avoidCategories > 0 ? [(int) $avoidCategories] : []);

        return Product::query()
            ->active()
            ->sellable()
            ->with($this->relations())
            ->when($excludeIds !== [], fn ($query) => $query->whereNotIn('id', $excludeIds))
            ->when($otherCategory && $avoid !== [], fn ($query) => $query->whereNotIn('category_id', $avoid))
            ->orderByDesc('is_featured')
            ->orderByDesc('review_count')
            ->limit(16)
            ->get();
    }

    /**
     * @param  Collection<int, Product>  $picked
     * @param  Collection<int, Product>  $pool
     * @return Collection<int, Product>
     */
    private function fillFromPool(Collection $picked, Collection $pool, int $limit): Collection
    {
        $ids = $picked->pluck('id')->all();

        return $picked
            ->concat($pool->reject(fn (Product $product) => in_array($product->id, $ids, true)))
            ->unique('id')
            ->take($limit)
            ->values();
    }

    private function popularity(Product $product): float
    {
        return log(1 + (int) $product->review_count) * 2
            + ($product->is_featured ? 6.0 : 0.0)
            + ($product->has_discount ? 3.0 : 0.0);
    }

    /**
     * @param  list<mixed>  $values
     * @return list<string>
     */
    private function normalizedSet(array $values): array
    {
        return array_values(array_unique(array_filter(array_map(
            fn ($value) => mb_strtolower(trim((string) $value)),
            $values
        ))));
    }

    /**
     * @return list<string>
     */
    private function tokens(string $text): array
    {
        $parts = preg_split('/[\s\-_,،.\/]+/u', mb_strtolower(trim($text))) ?: [];

        return array_values(array_filter($parts, fn (string $token) => mb_strlen($token) >= 2));
    }

    /**
     * @param  list<int|string>  $ids
     * @return list<int>
     */
    private function uniqueIds(array $ids): array
    {
        return array_values(array_unique(array_filter(array_map(
            fn ($id) => (int) $id,
            $ids
        ), fn (int $id) => $id > 0)));
    }
}
