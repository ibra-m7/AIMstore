<?php

namespace App\Services\Admin;

use App\Models\HomeSection;
use App\Support\Constants;
use App\Support\Media;
use App\Support\Slug;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class HomeSectionService
{
    public function paginate(array $filters = []): LengthAwarePaginator
    {
        return HomeSection::query()
            ->withCount(['products', 'bundles'])
            ->when($filters['q'] ?? null, function ($query, $search) {
                $query->where(function ($nested) use ($search) {
                    $nested->where('title', 'like', '%'.$search.'%')
                        ->orWhere('key', 'like', '%'.$search.'%');
                });
            })
            ->orderBy('sort_order')
            ->paginate(Constants::DEFAULT_PAGE_SIZE)
            ->withQueryString();
    }

    public function create(array $data): HomeSection
    {
        $section = HomeSection::query()->create($this->payload($data));
        $this->syncRelations($section, $data);

        return $section;
    }

    public function update(HomeSection $section, array $data): HomeSection
    {
        $section->update($this->payload($data, $section));
        $this->syncRelations($section, $data);

        return $section;
    }

    public function delete(HomeSection $section): void
    {
        Media::delete($section->background_image_url);
        $section->products()->detach();
        $section->bundles()->detach();
        $section->delete();
    }

    private function payload(array $data, ?HomeSection $section = null): array
    {
        $contentType = (string) ($data['content_type'] ?? HomeSection::CONTENT_PRODUCTS);

        return [
            'key' => $this->resolveKey($data, $section),
            'content_type' => $contentType,
            'title' => $data['title'],
            'subtitle' => $data['subtitle'] ?? null,
            'title_color' => $this->normalizeColor($data['title_color'] ?? null),
            'subtitle_color' => $this->normalizeColor($data['subtitle_color'] ?? null),
            'background_color' => $this->normalizeBackgroundColor($data['background_color'] ?? null),
            'background_image_url' => $this->storeBackgroundImage(
                $data['background_image'] ?? null,
                $data['background_image_url'] ?? '',
                $section?->background_image_url,
                (bool) ($data['remove_background_image'] ?? false),
            ),
            'auto_scroll_cards' => (bool) ($data['auto_scroll_cards'] ?? false),
            'show_title_icon' => (bool) ($data['show_title_icon'] ?? false),
            'emphasize_subtitle' => (bool) ($data['emphasize_subtitle'] ?? false),
            'title_font_size' => $this->normalizeSize(
                $data['title_font_size'] ?? null,
                HomeSection::DEFAULT_TITLE_FONT_SIZE,
                12,
                36,
            ),
            'subtitle_font_size' => $this->normalizeSize(
                $data['subtitle_font_size'] ?? null,
                HomeSection::DEFAULT_SUBTITLE_FONT_SIZE,
                8,
                24,
            ),
            'card_width' => $this->normalizeSize(
                $data['card_width'] ?? null,
                HomeSection::DEFAULT_CARD_WIDTH,
                80,
                220,
            ),
            'row_height' => $this->nullableSize($data['row_height'] ?? null, 100, 400),
            'item_spacing' => $this->normalizeSize(
                $data['item_spacing'] ?? null,
                HomeSection::DEFAULT_ITEM_SPACING,
                0,
                40,
            ),
            'padding_top' => $this->normalizeSize(
                $data['padding_top'] ?? null,
                HomeSection::DEFAULT_PADDING_TOP,
                0,
                48,
            ),
            'padding_bottom' => $this->normalizeSize(
                $data['padding_bottom'] ?? null,
                HomeSection::DEFAULT_PADDING_BOTTOM,
                0,
                48,
            ),
            'sort_order' => (int) ($data['sort_order'] ?? 0),
            'is_active' => (bool) ($data['is_active'] ?? false),
        ];
    }

    private function normalizeSize(mixed $value, int $default, int $min, int $max): int
    {
        if ($value === null || $value === '') {
            return $default;
        }

        return max($min, min($max, (int) $value));
    }

    private function nullableSize(mixed $value, int $min, int $max): ?int
    {
        if ($value === null || $value === '') {
            return null;
        }

        return max($min, min($max, (int) $value));
    }

    private function resolveKey(array $data, ?HomeSection $section = null): string
    {
        if ($section?->key) {
            return (string) $section->key;
        }

        return Slug::unique($data['title'], 'home_sections', 'key');
    }

    private function syncProducts(HomeSection $section, array $ids): void
    {
        $sync = [];
        foreach (array_values(array_filter($ids)) as $i => $id) {
            $sync[(int) $id] = ['sort_order' => $i];
        }
        $section->products()->sync($sync);
    }

    private function syncRelations(HomeSection $section, array $data): void
    {
        $contentType = (string) ($data['content_type'] ?? $section->content_type ?? HomeSection::CONTENT_PRODUCTS);

        if ($contentType === HomeSection::CONTENT_BUNDLES) {
            $section->products()->detach();

            return;
        }

        $section->bundles()->detach();
        $this->syncProducts($section, $data['product_ids'] ?? []);
    }

    private function storeBackgroundImage(
        mixed $file,
        string $url,
        ?string $current,
        bool $remove,
    ): ?string {
        if ($remove) {
            Media::delete($current);

            return null;
        }

        $url = trim($url);
        if ($file) {
            return Media::store($file, 'home-sections', $current);
        }

        if ($url !== '') {
            if ($current && $url !== $current) {
                Media::delete($current);
            }

            return $url;
        }

        return $current;
    }

    private function normalizeColor(?string $value): ?string
    {
        $value = trim((string) $value);
        if ($value === '') {
            return null;
        }

        $hex = ltrim($value, '#');
        if (! preg_match('/^[0-9A-Fa-f]{6}$/', $hex)) {
            return null;
        }

        return '#'.strtoupper($hex);
    }

    private function normalizeBackgroundColor(?string $value): ?string
    {
        return $this->normalizeColor($value);
    }
}
