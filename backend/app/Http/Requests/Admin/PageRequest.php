<?php

namespace App\Http\Requests\Admin;

use App\Enums\PagePlacement;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class PageRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:160'],
            'slug' => ['nullable', 'string', 'max:160'],
            'button_label' => ['nullable', 'string', 'max:120'],
            'placement' => ['required', Rule::enum(PagePlacement::class)],
            'content' => ['nullable', 'string'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ];
    }

    public function attributes(): array
    {
        return [
            'title' => 'العنوان',
            'slug' => 'المعرّف',
            'button_label' => 'نص الزر',
            'placement' => 'مكان الظهور',
            'content' => 'المحتوى',
            'sort_order' => 'الترتيب',
            'is_active' => 'التفعيل',
        ];
    }

    protected function prepareForValidation(): void
    {
        $this->merge([
            'is_active' => $this->boolean('is_active'),
        ]);
    }
}
