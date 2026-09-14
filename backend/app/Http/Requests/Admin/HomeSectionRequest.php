<?php

namespace App\Http\Requests\Admin;

use App\Models\HomeSection;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class HomeSectionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $section = $this->route('home_section');

        return [
            'title' => ['required', 'string', 'max:255'],
            'subtitle' => ['nullable', 'string', 'max:255'],
            'title_color' => ['nullable', 'string', 'max:7', 'regex:/^#?[0-9A-Fa-f]{6}$/'],
            'subtitle_color' => ['nullable', 'string', 'max:7', 'regex:/^#?[0-9A-Fa-f]{6}$/'],
            'background_color' => ['nullable', 'string', 'max:7', 'regex:/^#?[0-9A-Fa-f]{6}$/'],
            'background_image' => ['nullable', 'file', 'mimes:jpg,jpeg,png,webp,gif', 'max:4096'],
            'background_image_url' => ['nullable', 'url', 'max:2048'],
            'remove_background_image' => ['nullable', 'boolean'],
            'background_mode' => ['nullable', 'in:color,image'],
            'content_type' => ['required', Rule::in([HomeSection::CONTENT_PRODUCTS, HomeSection::CONTENT_BUNDLES])],
            'key' => [
                'nullable',
                'string',
                'max:64',
                Rule::unique('home_sections', 'key')->ignore($section),
            ],
            'product_ids' => ['nullable', 'array'],
            'product_ids.*' => ['integer', 'exists:products,id'],
            'sort_order' => ['nullable', 'integer', 'min:0', 'max:9999'],
            'is_active' => ['nullable', 'boolean'],
            'auto_scroll_cards' => ['nullable', 'boolean'],
            'show_title_icon' => ['nullable', 'boolean'],
            'emphasize_subtitle' => ['nullable', 'boolean'],
            'title_font_size' => ['nullable', 'integer', 'min:12', 'max:36'],
            'subtitle_font_size' => ['nullable', 'integer', 'min:8', 'max:24'],
            'card_width' => ['nullable', 'integer', 'min:80', 'max:220'],
            'row_height' => ['nullable', 'integer', 'min:100', 'max:400'],
            'item_spacing' => ['nullable', 'integer', 'min:0', 'max:40'],
            'padding_top' => ['nullable', 'integer', 'min:0', 'max:48'],
            'padding_bottom' => ['nullable', 'integer', 'min:0', 'max:48'],
            'use_default_background' => ['nullable', 'boolean'],
            'use_default_title_color' => ['nullable', 'boolean'],
            'use_default_subtitle_color' => ['nullable', 'boolean'],
        ];
    }

    public function attributes(): array
    {
        return [
            'title' => 'الاسم التجاري',
            'subtitle' => 'العنوان الفرعي',
            'title_color' => 'لون اسم القسم',
            'subtitle_color' => 'لون العنوان الفرعي',
            'background_color' => 'لون خلفية القسم',
            'background_image' => 'صورة خلفية القسم',
            'background_image_url' => 'رابط صورة الخلفية',
            'content_type' => 'نوع المحتوى',
            'key' => 'المعرّف',
            'product_ids' => 'المنتجات',
            'auto_scroll_cards' => 'تحريك الكروت',
            'show_title_icon' => 'أيقونة العنوان',
            'emphasize_subtitle' => 'تمييز العنوان الفرعي',
            'title_font_size' => 'حجم خط العنوان',
            'subtitle_font_size' => 'حجم خط العنوان الفرعي',
            'card_width' => 'عرض البطاقة',
            'row_height' => 'ارتفاع الصف',
            'item_spacing' => 'المسافة بين البطاقات',
            'padding_top' => 'المسافة العلوية',
            'padding_bottom' => 'المسافة السفلية',
        ];
    }

    protected function prepareForValidation(): void
    {
        $backgroundMode = $this->input('background_mode', 'color');

        $this->merge([
            'is_active' => $this->boolean('is_active'),
            'auto_scroll_cards' => $this->boolean('auto_scroll_cards'),
            'show_title_icon' => $this->boolean('show_title_icon'),
            'emphasize_subtitle' => $this->boolean('emphasize_subtitle'),
            'remove_background_image' => $this->boolean('remove_background_image'),
            'content_type' => $this->input('content_type') ?: HomeSection::CONTENT_PRODUCTS,
            'key' => null,
            'subtitle' => $this->input('subtitle') ?: null,
            'title_color' => $this->boolean('use_default_title_color')
                ? null
                : ($this->input('title_color') ?: null),
            'subtitle_color' => $this->boolean('use_default_subtitle_color')
                ? null
                : ($this->input('subtitle_color') ?: null),
            'background_color' => $backgroundMode === 'image' || $this->boolean('use_default_background')
                ? null
                : ($this->input('background_color') ?: null),
            'background_image_url' => $backgroundMode === 'color'
                ? null
                : ($this->input('background_image_url') ?: null),
            'title_font_size' => $this->filled('title_font_size') ? $this->input('title_font_size') : null,
            'subtitle_font_size' => $this->filled('subtitle_font_size') ? $this->input('subtitle_font_size') : null,
            'card_width' => $this->filled('card_width') ? $this->input('card_width') : null,
            'row_height' => $this->filled('row_height') ? $this->input('row_height') : null,
            'item_spacing' => $this->filled('item_spacing') ? $this->input('item_spacing') : null,
            'padding_top' => $this->filled('padding_top') ? $this->input('padding_top') : null,
            'padding_bottom' => $this->filled('padding_bottom') ? $this->input('padding_bottom') : null,
            'product_ids' => array_values(array_filter((array) $this->input('product_ids', []))),
        ]);
    }
}
