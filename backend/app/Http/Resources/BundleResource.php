<?php

namespace App\Http\Resources;

use App\Support\Media;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\ProductBundle */
class BundleResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (string) $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'summary' => $this->summary ?? '',
            'description' => $this->description ?? '',
            'image_url' => Media::publicUrl($this->image_url) ?? '',
            'preview_image_urls' => $this->coverPreviewUrls(),
            'discount_percent' => (float) $this->discount_percent,
            'bundle_price' => (float) $this->bundle_price,
            'original_price' => (float) $this->original_price,
            'item_count' => (int) $this->item_count,
            'is_available' => (bool) $this->is_available,
            'items' => $this->itemsPayload(),
        ];
    }

    /**
     * @return list<array{product: array<string, mixed>, quantity: int}>
     */
    private function itemsPayload(): array
    {
        if (! $this->relationLoaded('items')) {
            return [];
        }

        return $this->items
            ->filter(fn ($item) => $item->product !== null)
            ->map(function ($item) {
                return [
                    'product' => (new ProductResource($item->product))->resolve(),
                    'quantity' => max(1, (int) $item->quantity),
                ];
            })
            ->values()
            ->all();
    }

    /**
     * @return list<string>
     */
    private function coverPreviewUrls(): array
    {
        $cover = Media::publicUrl($this->image_url);
        if (is_string($cover) && $cover !== '') {
            return [$cover];
        }

        $urls = [];
        foreach ($this->itemsPayload() as $item) {
            $url = trim((string) ($item['product']['image_url'] ?? ''));
            if ($url === '' || in_array($url, $urls, true)) {
                continue;
            }
            $urls[] = $url;
            if (count($urls) >= 3) {
                break;
            }
        }

        return $urls;
    }
}
