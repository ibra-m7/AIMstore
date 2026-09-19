<?php

namespace App\Http\Resources;

use App\Models\HomeSection;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin \App\Models\HomeSection */
class HomeSectionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (string) $this->id,
            'key' => $this->key,
            'content_type' => $this->content_type,
            'title' => $this->title,
            'subtitle' => $this->subtitle,
            'title_color' => $this->title_color,
            'subtitle_color' => $this->subtitle_color,
            'background_color' => $this->background_color,
            'background_image_url' => \App\Support\Media::publicUrl($this->background_image_url),
            'auto_scroll_cards' => (bool) $this->auto_scroll_cards,
            'show_title_icon' => (bool) $this->show_title_icon,
            'emphasize_subtitle' => (bool) $this->emphasize_subtitle,
            'title_font_size' => (int) ($this->title_font_size ?? HomeSection::DEFAULT_TITLE_FONT_SIZE),
            'subtitle_font_size' => (int) ($this->subtitle_font_size ?? HomeSection::DEFAULT_SUBTITLE_FONT_SIZE),
            'card_width' => (int) ($this->card_width ?? HomeSection::DEFAULT_CARD_WIDTH),
            'row_height' => $this->row_height !== null ? (int) $this->row_height : null,
            'item_spacing' => (int) ($this->item_spacing ?? HomeSection::DEFAULT_ITEM_SPACING),
            'padding_top' => (int) ($this->padding_top ?? HomeSection::DEFAULT_PADDING_TOP),
            'padding_bottom' => (int) ($this->padding_bottom ?? HomeSection::DEFAULT_PADDING_BOTTOM),
            'products' => ProductResource::collection($this->whenLoaded('products')),
            'bundles' => BundleResource::collection($this->whenLoaded('bundles')),
        ];
    }
}
