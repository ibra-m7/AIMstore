<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class MarketingController extends Controller
{
    public function index(): View|RedirectResponse
    {
        if (auth()->user()?->canAccessAdminPanel()) {
            return redirect()->route('admin.dashboard');
        }

        return view('marketing.home', [
            'title' => 'سيتي مارت',
            'exploreCategories' => $this->exploreCategories(),
        ]);
    }

    public function categories(Request $request): View|RedirectResponse
    {
        if (auth()->user()?->canAccessAdminPanel()) {
            return redirect()->route('admin.dashboard');
        }

        $slug = trim((string) $request->query('c', ''));
        $categories = Category::query()
            ->active()
            ->roots()
            ->with(['children' => fn ($q) => $q->active()->orderBy('sort_order')->orderBy('name')])
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();

        $selected = $slug !== ''
            ? $categories->first(fn (Category $category) => $category->slug === $slug)
            : null;

        return view('marketing.categories', [
            'title' => $selected?->name ?? 'تصفّح الأقسام',
            'categories' => $categories,
            'selected' => $selected,
        ]);
    }

    /**
     * @return list<array{label: string, icon: string, href: string}>
     */
    private function exploreCategories(): array
    {
        $roots = Category::query()
            ->active()
            ->roots()
            ->orderBy('sort_order')
            ->orderBy('name')
            ->limit(4)
            ->get(['id', 'name', 'slug']);

        $fallback = [
            ['label' => 'مشروبات', 'icon' => 'bi-cup-hot', 'slug' => null],
            ['label' => 'ألبان', 'icon' => 'bi-egg-fried', 'slug' => null],
            ['label' => 'خضار', 'icon' => 'bi-flower1', 'slug' => null],
            ['label' => 'عروض', 'icon' => 'bi-box2-heart', 'slug' => null],
        ];

        $icons = ['bi-cup-hot', 'bi-egg-fried', 'bi-flower1', 'bi-box2-heart'];
        $tiles = [];
        foreach ($fallback as $index => $item) {
            $root = $roots->get($index);
            $label = $root?->name ?? $item['label'];
            if ($root && str_contains($root->name, 'مشروب')) {
                $label = 'مشروبات';
            }
            $tiles[] = [
                'label' => $label,
                'icon' => $icons[$index] ?? 'bi-grid',
                'href' => $root
                    ? route('marketing.categories', ['c' => $root->slug])
                    : route('marketing.categories'),
            ];
        }

        // Prefer an exact "مشروبات" tile when a matching root exists.
        $beverage = $roots->first(fn (Category $c) => str_contains($c->name, 'مشروب'));
        if ($beverage !== null) {
            $tiles[0] = [
                'label' => 'مشروبات',
                'icon' => 'bi-cup-hot',
                'href' => route('marketing.categories', ['c' => $beverage->slug]),
            ];
        }

        return $tiles;
    }
}
