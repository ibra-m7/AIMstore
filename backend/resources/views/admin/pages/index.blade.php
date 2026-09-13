<x-layouts.admin :title="$title">
    <x-admin.page-head
        :title="$title"
        :create="route('admin.pages.create')"
        :create-label="$strings::ADD_PAGE"
        subtitle="صفحات المحتوى مثل سياسة الخصوصية وشروط الاستخدام. اختر مكان الظهور ونص الزر في التطبيق."
    />

    <form method="GET" class="d-flex flex-wrap gap-2 mb-3">
        <input type="text" name="q" value="{{ $filters['q'] ?? '' }}" class="form-control" style="max-width: 240px" placeholder="{{ $strings::SEARCH }}">
        <select name="status" class="form-select" style="max-width: 140px">
            <option value="">{{ $strings::STATUS }}</option>
            <option value="active" @selected(($filters['status'] ?? '') === 'active')">{{ $strings::ACTIVE }}</option>
            <option value="inactive" @selected(($filters['status'] ?? '') === 'inactive')">{{ $strings::INACTIVE }}</option>
        </select>
        <select name="placement" class="form-select" style="max-width: 220px">
            <option value="">كل الأماكن</option>
            @foreach ($placements as $placement)
                <option value="{{ $placement->value }}" @selected(($filters['placement'] ?? '') === $placement->value)>
                    {{ $placement->label() }}
                </option>
            @endforeach
        </select>
        <button class="btn btn-outline-success rounded-pill">{{ $strings::FILTER }}</button>
    </form>

    <div class="page-card p-4">
        @if ($pages->isEmpty())
            <x-admin.empty-state icon="bi-file-text" :action="route('admin.pages.create')" :action-label="$strings::ADD_PAGE" />
        @else
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>العنوان</th>
                            <th>نص الزر</th>
                            <th>المكان</th>
                            <th>الترتيب</th>
                            <th>{{ $strings::STATUS }}</th>
                            <th>{{ $strings::ACTIONS }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($pages as $page)
                            <tr>
                                <td>
                                    <div class="fw-bold">{{ $page->title }}</div>
                                    <div class="text-muted small" dir="ltr">{{ $page->slug }}</div>
                                </td>
                                <td>{{ $page->resolvedButtonLabel() }}</td>
                                <td>{{ $page->placement?->label() ?? $page->placement }}</td>
                                <td>{{ $page->sort_order }}</td>
                                <td>
                                    @if ($page->is_active)
                                        <span class="badge badge-soft">{{ $strings::LIVE_IN_APP }}</span>
                                    @else
                                        <span class="badge badge-soft">{{ $strings::INACTIVE }}</span>
                                    @endif
                                </td>
                                <td>
                                    <div class="d-flex gap-2">
                                        <a href="{{ route('admin.pages.edit', $page) }}" class="btn btn-sm btn-outline-success rounded-pill">{{ $strings::EDIT }}</a>
                                        <form method="POST" action="{{ route('admin.pages.destroy', $page) }}" onsubmit="return confirm('{{ $strings::CONFIRM_DELETE }}')">
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
            {{ $pages->links() }}
        @endif
    </div>
</x-layouts.admin>
