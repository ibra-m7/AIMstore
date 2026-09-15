<x-layouts.admin :title="$title">
    <x-admin.page-head
        :title="$title"
        :create="$createUrl"
        :create-label="$createLabel"
    />

    <form method="GET" action="{{ route('admin.categories.index') }}" class="d-flex flex-wrap gap-2 mb-3">
        <input type="text" name="q" value="{{ $filters['q'] ?? '' }}" class="form-control" style="max-width: 240px" placeholder="{{ $strings::SEARCH }}">
        <select name="type" class="form-select" style="max-width: 180px" aria-label="نوع المحتوى">
            <option value="">كل الأنواع</option>
            <option value="mains" @selected(($filters['type'] ?? '') === 'mains')">تبويبات</option>
            <option value="branches" @selected(($filters['type'] ?? '') === 'branches')">أقسام</option>
            <option value="classes" @selected(($filters['type'] ?? '') === 'classes')">تصنيفات</option>
        </select>
        <select name="status" class="form-select" style="max-width: 140px">
            <option value="">{{ $strings::STATUS }}</option>
            <option value="active" @selected(($filters['status'] ?? '') === 'active')">{{ $strings::ACTIVE }}</option>
            <option value="inactive" @selected(($filters['status'] ?? '') === 'inactive')">{{ $strings::INACTIVE }}</option>
        </select>
        <button class="btn btn-outline-success rounded-pill">{{ $strings::FILTER }}</button>
        @if (! empty($filters['q']) || ! empty($filters['type']) || ! empty($filters['status']))
            <a href="{{ route('admin.categories.index') }}" class="btn btn-outline-secondary rounded-pill">مسح</a>
        @endif
    </form>

    <div class="page-card p-0 overflow-hidden">
        <div class="p-4">
            @if (empty($filtered))
            <nav class="catalog-crumb" aria-label="مسار الأقسام">
                <a href="{{ route('admin.categories.index') }}" @class(['is-current' => ! $parent])>التبويبات</a>
                @foreach ($ancestors as $crumb)
                    <span class="catalog-crumb-sep"><i class="bi bi-chevron-left"></i></span>
                    <a href="{{ route('admin.categories.index', ['parent' => $crumb->id]) }}" @class(['is-current' => $loop->last])>{{ $crumb->name }}</a>
                @endforeach
            </nav>
            @endif

            @if ($items->isEmpty())
                <x-admin.empty-state icon="bi-grid" :action="$createUrl" :action-label="$createLabel" />
            @else
                <div class="table-responsive">
                    <table class="table mb-0 catalog-table">
                        <thead>
                            <tr>
                                <th>الاسم</th>
                                <th>{{ ($filtered ?? false) ? 'المحتوى' : ($depth >= 2 ? 'المنتجات' : 'المحتوى') }}</th>
                                <th>{{ $strings::STATUS }}</th>
                                <th>{{ $strings::ACTIONS }}</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach ($items as $category)
                                @php
                                    $itemDepth = ($filtered ?? false)
                                        ? app(\App\Services\Admin\CategoryService::class)->depthOf($category)
                                        : $depth;
                                    $thumb = $category->image_src ?: $category->icon_src;
                                    $openLabel = match ($itemDepth) {
                                        0 => 'الأقسام',
                                        1 => 'التصنيفات',
                                        default => null,
                                    };
                                    $countOne = match ($itemDepth) {
                                        0 => 'قسم',
                                        1 => 'تصنيف',
                                        default => 'منتج',
                                    };
                                    $countMany = match ($itemDepth) {
                                        0 => 'أقسام',
                                        1 => 'تصنيفات',
                                        default => 'منتجات',
                                    };
                                    $openUrl = $openLabel
                                        ? route('admin.categories.index', ['parent' => $category->id])
                                        : null;
                                    $childCount = $itemDepth >= 2
                                        ? (int) $category->products_count
                                        : (int) $category->children_count;
                                    $contentLabel = $childCount.' '.($childCount === 1 ? $countOne : $countMany);
                                @endphp
                                <tr>
                                    <td>
                                        <span class="d-inline-flex align-items-center gap-2">
                                            <span class="table-thumb-wrap">
                                                @if ($thumb)
                                                    <img src="{{ $thumb }}" alt="" class="table-thumb">
                                                @else
                                                    <i class="bi {{ $itemDepth === 0 ? 'bi-folder' : ($itemDepth === 1 ? 'bi-grid' : 'bi-tag') }}"></i>
                                                @endif
                                            </span>
                                            @if ($openUrl)
                                                <a href="{{ $openUrl }}" class="catalog-name-link">
                                                    <span class="color-dot" style="background: {{ $category->color ?: '#003399' }}"></span>
                                                    {{ $category->name }}
                                                    <i class="bi bi-chevron-left catalog-name-chevron"></i>
                                                </a>
                                            @else
                                                <strong>
                                                    <span class="color-dot" style="background: {{ $category->color ?: '#003399' }}"></span>
                                                    {{ $category->name }}
                                                </strong>
                                            @endif
                                        </span>
                                    </td>
                                    <td>{{ $contentLabel }}</td>
                                    <td>
                                        <span class="badge badge-soft">{{ $category->is_active ? $strings::ACTIVE : $strings::INACTIVE }}</span>
                                    </td>
                                    <td>
                                        <div class="d-flex flex-wrap gap-1">
                                            @if ($openUrl)
                                                <a href="{{ $openUrl }}" class="btn btn-sm btn-outline-success rounded-pill">{{ $openLabel }}</a>
                                            @endif
                                            <a href="{{ route('admin.categories.edit', $category) }}" class="btn btn-sm btn-outline-success rounded-pill">{{ $strings::EDIT }}</a>
                                            <form method="POST" action="{{ route('admin.categories.destroy', $category) }}" onsubmit="return confirm(@js($strings::CONFIRM_DELETE))">
                                                @csrf
                                                @method('DELETE')
                                                <button class="btn btn-sm btn-outline-danger rounded-pill">{{ $strings::DELETE }}</button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
                @if ($filtered ?? false)
                    <div class="mt-3">{{ $items->links() }}</div>
                @endif
            @endif
        </div>
    </div>
</x-layouts.admin>
