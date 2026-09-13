<x-layouts.admin :title="$title">
    <x-admin.page-head
        :title="$title"
        subtitle="إدارة حسابات الموظفين مع صلاحيات مخصصة"
        :create="route('admin.staff.create')"
        :create-label="$strings::ADD_STAFF"
    />

    @if (session('success'))
        <div class="alert alert-success border-0 shadow-sm rounded-4 mb-4">{{ session('success') }}</div>
    @endif

    <div class="d-flex justify-content-between align-items-center mb-3">
        <form method="GET" class="d-flex flex-wrap gap-2">
            <input type="text" name="q" value="{{ $filters['q'] ?? '' }}" class="form-control" style="max-width: 280px" placeholder="ابحث بالاسم أو البريد أو الهاتف">
            <button class="btn btn-outline-secondary rounded-pill">{{ $strings::FILTER }}</button>
        </form>
    </div>

    <div class="page-card p-4">
        @if ($staff->isEmpty())
            <x-admin.empty-state icon="bi-person-gear" message="لا توجد حسابات فريق بعد." />
        @else
            <div class="table-responsive">
                <table class="table align-middle mb-0">
                    <thead>
                        <tr>
                            <th>الحساب</th>
                            <th>الدور</th>
                            <th>الصلاحيات</th>
                            <th>البريد</th>
                            <th>{{ $strings::ACTIONS }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($staff as $member)
                            @php
                                $perms = $member->isAdmin()
                                    ? ['مدير كامل']
                                    : collect($member->permissionList())
                                        ->map(fn ($key) => $permissionCatalog[$key]['label'] ?? $key)
                                        ->values()
                                        ->all();
                            @endphp
                            <tr>
                                <td>
                                    <div class="fw-bold">{{ $member->name }}</div>
                                    <div class="text-muted small">{{ $member->job_title ?: '—' }}</div>
                                </td>
                                <td>
                                    @if ($member->isAdmin())
                                        <span class="badge text-bg-primary">مدير</span>
                                    @else
                                        <span class="badge text-bg-secondary">موظف</span>
                                    @endif
                                </td>
                                <td>
                                    <div class="staff-perm-chips">
                                        @forelse ($perms as $label)
                                            <span class="staff-perm-chip">{{ $label }}</span>
                                        @empty
                                            <span class="text-muted">بدون صلاحيات</span>
                                        @endforelse
                                    </div>
                                </td>
                                <td dir="ltr">{{ $member->email }}</td>
                                <td>
                                    @if ($member->isStaff())
                                        <div class="d-flex gap-2">
                                            <a href="{{ route('admin.staff.edit', $member) }}" class="btn btn-sm btn-outline-primary rounded-pill">{{ $strings::EDIT }}</a>
                                            <form method="POST" action="{{ route('admin.staff.destroy', $member) }}" onsubmit="return confirm('حذف هذا الحساب؟')">
                                                @csrf
                                                @method('DELETE')
                                                <button class="btn btn-sm btn-outline-danger rounded-pill">{{ $strings::DELETE }}</button>
                                            </form>
                                        </div>
                                    @else
                                        <span class="text-muted small">محمي</span>
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            <div class="mt-3">{{ $staff->links() }}</div>
        @endif
    </div>
</x-layouts.admin>
