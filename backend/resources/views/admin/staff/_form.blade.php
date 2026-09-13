@php
    $selected = collect(old('permissions', $member->permissions ?? []))->map(fn ($v) => (string) $v)->all();
@endphp

<div class="row g-3">
    <div class="col-md-6">
        <label class="form-label">الاسم الكامل</label>
        <input type="text" name="name" value="{{ old('name', $member->name ?? '') }}" class="form-control @error('name') is-invalid @enderror" required>
        @error('name') <div class="invalid-feedback">{{ $message }}</div> @enderror
    </div>
    <div class="col-md-6">
        <label class="form-label">المسمى الوظيفي</label>
        <input type="text" name="job_title" value="{{ old('job_title', $member->job_title ?? '') }}" class="form-control @error('job_title') is-invalid @enderror" placeholder="مثال: مشرف الطلبات">
        @error('job_title') <div class="invalid-feedback">{{ $message }}</div> @enderror
    </div>
    <div class="col-md-6">
        <label class="form-label">البريد الإلكتروني</label>
        <input type="email" name="email" value="{{ old('email', $member->email ?? '') }}" class="form-control @error('email') is-invalid @enderror" dir="ltr" required>
        @error('email') <div class="invalid-feedback">{{ $message }}</div> @enderror
    </div>
    <div class="col-md-6">
        <label class="form-label">رقم الهاتف</label>
        <x-admin.gcc-phone-input
            country-name="phone_country"
            national-name="phone"
            :e164="old('phone_full', $member->phone ?? '')"
        />
        @error('phone') <div class="invalid-feedback d-block">{{ $message }}</div> @enderror
    </div>
</div>

<hr class="my-4">

<div class="mb-3" data-password-panel
     @if(!empty($evaluateUrl)) data-evaluate-url="{{ $evaluateUrl }}" @endif>
    <h3 class="h6 fw-bold mb-1">كلمة المرور</h3>
    <p class="text-muted small mb-3">
        @if (! empty($member?->id))
            اتركها فارغة للإبقاء على كلمة المرور الحالية.
        @else
            مطلوبة عند إنشاء الحساب.
        @endif
        يجب أن تحتوي على أحرف وأرقام ورمزاً (8 أحرف على الأقل).
    </p>
    <div class="row g-3">
        <div class="col-md-6">
            <label class="form-label">{{ !empty($member?->id) ? 'كلمة مرور جديدة' : 'كلمة المرور' }}</label>
            <input type="password" name="password" class="form-control @error('password') is-invalid @enderror" autocomplete="new-password" data-new-password @if(empty($member?->id)) required @endif>
            @error('password') <div class="invalid-feedback">{{ $message }}</div> @enderror
        </div>
        <div class="col-md-6">
            <label class="form-label">تأكيد كلمة المرور</label>
            <input type="password" name="password_confirmation" class="form-control" autocomplete="new-password" data-password-confirm @if(empty($member?->id)) required @endif>
            <div class="password-live-status" data-confirm-status hidden></div>
        </div>
    </div>
    <ul class="password-checklist mt-3 mb-0" data-password-checklist hidden>
        <li data-check="length">8 أحرف على الأقل</li>
        <li data-check="letter">حرف واحد على الأقل (كبير أو صغير)</li>
        <li data-check="number">رقم واحد على الأقل</li>
        <li data-check="symbol">رمز واحد على الأقل مثل @ # $ !</li>
    </ul>
</div>

<hr class="my-4">

<div>
    <h3 class="h6 fw-bold mb-1">الصلاحيات</h3>
    <p class="text-muted small mb-3">اختر الأقسام التي يمكن لهذا الحساب الوصول إليها. لن يحصل على صلاحيات المدير الكاملة.</p>
    @error('permissions') <div class="text-danger small mb-2">{{ $message }}</div> @enderror
    <div class="permission-grid">
        @foreach ($assignableKeys as $key)
            @php $meta = $permissionCatalog[$key] ?? null; @endphp
            @if ($meta)
                <label class="permission-card">
                    <input type="checkbox" name="permissions[]" value="{{ $key }}" @checked(in_array($key, $selected, true))>
                    <span class="permission-card__body">
                        <span class="permission-card__title">
                            <i class="bi {{ $meta['icon'] }}"></i>
                            {{ $meta['label'] }}
                        </span>
                        <span class="permission-card__desc">{{ $meta['description'] }}</span>
                    </span>
                </label>
            @endif
        @endforeach
    </div>
</div>
