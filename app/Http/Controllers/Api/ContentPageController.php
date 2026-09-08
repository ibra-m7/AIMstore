<?php

namespace App\Http\Controllers\Api;

use App\Enums\PagePlacement;
use App\Http\Controllers\Controller;
use App\Models\Page;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ContentPageController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'placement' => ['nullable', 'string', Rule::enum(PagePlacement::class)],
        ]);

        $pages = Page::query()
            ->active()
            ->when($validated['placement'] ?? null, fn ($query, $placement) => $query->where('placement', $placement))
            ->ordered()
            ->get()
            ->map(fn (Page $page) => $this->summary($page))
            ->values()
            ->all();

        return ApiResponse::success('صفحات المحتوى', $pages);
    }

    public function show(string $slug): JsonResponse
    {
        $page = Page::query()
            ->active()
            ->where('slug', $slug)
            ->first();

        if ($page === null) {
            return ApiResponse::error('الصفحة غير موجودة.', 404);
        }

        return ApiResponse::success('تفاصيل الصفحة', [
            ...$this->summary($page),
            'content' => (string) ($page->content ?? ''),
        ]);
    }

    /**
     * @return array{id: int, slug: string, title: string, button_label: string, placement: string, sort_order: int}
     */
    private function summary(Page $page): array
    {
        return [
            'id' => $page->id,
            'slug' => $page->slug,
            'title' => $page->title,
            'button_label' => $page->resolvedButtonLabel(),
            'placement' => $page->placement instanceof PagePlacement
                ? $page->placement->value
                : (string) $page->placement,
            'sort_order' => (int) $page->sort_order,
        ];
    }
}
