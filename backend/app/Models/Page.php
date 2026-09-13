<?php

namespace App\Models;

use App\Enums\PagePlacement;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class Page extends Model
{
    protected $fillable = [
        'slug',
        'title',
        'content',
        'placement',
        'button_label',
        'sort_order',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'placement' => PagePlacement::class,
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }

    public function scopeOrdered(Builder $query): Builder
    {
        return $query->orderBy('sort_order')->orderBy('id');
    }

    public function resolvedButtonLabel(): string
    {
        $label = trim((string) $this->button_label);

        return $label !== '' ? $label : (string) $this->title;
    }
}
