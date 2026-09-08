<?php

namespace App\Services\Admin;

use App\Enums\PagePlacement;
use App\Models\Page;
use App\Support\Constants;
use App\Support\Slug;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Validation\ValidationException;

class PageService
{
    public function paginate(array $filters = []): LengthAwarePaginator
    {
        return Page::query()
            ->when($filters['q'] ?? null, function ($query, $search) {
                $query->where(function ($nested) use ($search) {
                    $nested->where('title', 'like', '%'.$search.'%')
                        ->orWhere('slug', 'like', '%'.$search.'%')
                        ->orWhere('button_label', 'like', '%'.$search.'%');
                });
            })
            ->when(($filters['status'] ?? '') === 'active', fn ($query) => $query->where('is_active', true))
            ->when(($filters['status'] ?? '') === 'inactive', fn ($query) => $query->where('is_active', false))
            ->when($filters['placement'] ?? null, fn ($query, $placement) => $query->where('placement', $placement))
            ->orderBy('sort_order')
            ->latest('id')
            ->paginate(Constants::DEFAULT_PAGE_SIZE)
            ->withQueryString();
    }

    public function create(array $data): Page
    {
        return Page::query()->create($this->payload($data));
    }

    public function update(Page $page, array $data): Page
    {
        $page->update($this->payload($data, $page));

        return $page->fresh();
    }

    public function delete(Page $page): void
    {
        $page->delete();
    }

    /**
     * @return array{slug: string, title: string, content: ?string, placement: string, button_label: string, sort_order: int, is_active: bool}
     */
    private function payload(array $data, ?Page $page = null): array
    {
        $title = trim((string) ($data['title'] ?? ''));
        if ($title === '') {
            throw ValidationException::withMessages([
                'title' => 'عنوان الصفحة مطلوب.',
            ]);
        }

        $slugInput = trim((string) ($data['slug'] ?? ''));
        $slug = Slug::unique(
            $slugInput !== '' ? $slugInput : $title,
            'pages',
            'slug',
            $page?->id,
        );

        $buttonLabel = trim((string) ($data['button_label'] ?? ''));
        if ($buttonLabel === '') {
            $buttonLabel = $title;
        }

        $placement = $data['placement'] ?? PagePlacement::ProfileFooter->value;
        if ($placement instanceof PagePlacement) {
            $placement = $placement->value;
        }

        return [
            'slug' => $slug,
            'title' => $title,
            'content' => trim((string) ($data['content'] ?? '')) ?: null,
            'placement' => (string) $placement,
            'button_label' => $buttonLabel,
            'sort_order' => (int) ($data['sort_order'] ?? 0),
            'is_active' => (bool) ($data['is_active'] ?? false),
        ];
    }
}
