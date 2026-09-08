<?php

namespace App\Http\Controllers\Admin;

use App\Enums\PagePlacement;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\PageRequest;
use App\Models\Page;
use App\Services\Admin\PageService;
use App\Support\AppStrings;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class PageController extends Controller
{
    public function __construct(private readonly PageService $pages) {}

    public function index(Request $request): View
    {
        $filters = $request->only(['q', 'status', 'placement']);

        return view('admin.pages.index', [
            'title' => AppStrings::NAV_PAGES,
            'pages' => $this->pages->paginate($filters),
            'filters' => $filters,
            'placements' => PagePlacement::cases(),
        ]);
    }

    public function create(): View
    {
        return view('admin.pages.create', [
            'title' => AppStrings::ADD_PAGE,
            'page' => new Page([
                'is_active' => true,
                'sort_order' => 0,
                'placement' => PagePlacement::ProfileFooter,
            ]),
            'placements' => PagePlacement::cases(),
        ]);
    }

    public function store(PageRequest $request): RedirectResponse
    {
        $this->pages->create($request->validated());

        return redirect()
            ->route('admin.pages.index')
            ->with('success', AppStrings::PAGE_CREATED);
    }

    public function edit(Page $page): View
    {
        return view('admin.pages.edit', [
            'title' => AppStrings::EDIT_PAGE,
            'page' => $page,
            'placements' => PagePlacement::cases(),
        ]);
    }

    public function update(PageRequest $request, Page $page): RedirectResponse
    {
        $this->pages->update($page, $request->validated());

        return redirect()
            ->route('admin.pages.index')
            ->with('success', AppStrings::PAGE_UPDATED);
    }

    public function destroy(Page $page): RedirectResponse
    {
        $this->pages->delete($page);

        return redirect()
            ->route('admin.pages.index')
            ->with('success', AppStrings::PAGE_DELETED);
    }
}
