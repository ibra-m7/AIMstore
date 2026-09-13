<x-layouts.admin :title="$title">
    <x-admin.page-head
        :title="$title"
        subtitle="إنشاء حساب موظف بصلاحيات محددة بدون صلاحيات المدير الكاملة"
    />

    <div class="page-card p-4 p-md-5" style="max-width: 920px">
        <form method="POST" action="{{ route('admin.staff.store') }}">
            @csrf
            @include('admin.staff._form', [
                'member' => null,
                'evaluateUrl' => route('admin.profile.evaluate-password'),
            ])
            <div class="d-flex gap-2 mt-4">
                <button class="btn btn-brand">{{ $strings::SAVE }}</button>
                <a href="{{ route('admin.staff.index') }}" class="btn btn-outline-secondary rounded-pill">{{ $strings::CANCEL }}</a>
            </div>
        </form>
    </div>
</x-layouts.admin>
