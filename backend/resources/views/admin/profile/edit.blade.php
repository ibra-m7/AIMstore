@php
    $initial = mb_substr($user->name ?: 'م', 0, 1);
@endphp

<x-layouts.admin :title="$title">
    <x-admin.page-head :title="$title" :subtitle="$strings::PROFILE_SUBTITLE" />

    @if (session('success'))
        <div class="alert alert-success border-0 shadow-sm rounded-4 mb-4">{{ session('success') }}</div>
    @endif

    <form method="POST" action="{{ route('admin.profile.update') }}" enctype="multipart/form-data" class="profile-page">
        @csrf
        @method('PUT')

        <div class="profile-hero page-card mb-4">
            <div class="profile-hero__main">
                <div class="profile-avatar-wrap">
                    <img
                        id="profile-avatar-preview"
                        src="{{ $avatarUrl }}"
                        alt="{{ $user->name }}"
                        class="profile-avatar"
                        @if(! $avatarUrl) hidden @endif
                    >
                    <div class="profile-avatar-fallback" @if($avatarUrl) hidden @endif data-profile-avatar-fallback>
                        {{ $initial }}
                    </div>
                </div>
                <div class="profile-hero__meta">
                    <h2 class="profile-hero__name">{{ $user->name }}</h2>
                    <p class="profile-hero__title mb-1">{{ $user->job_title ?: 'مدير النظام' }}</p>
                    <p class="profile-hero__email mb-0" dir="ltr">{{ $user->email }}</p>
                </div>
            </div>
            <div class="profile-hero__aside">
                <span class="profile-badge">حساب مدير</span>
                <span class="profile-meta-muted">آخر تحديث: {{ $user->updated_at?->format('Y-m-d H:i') ?? '—' }}</span>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-lg-8">
                <div class="page-card p-4 p-md-5 mb-4">
                    <h3 class="profile-section-title">
                        <i class="bi bi-person-vcard"></i>
                        المعلومات الأساسية
                    </h3>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">الاسم الكامل</label>
                            <input type="text" name="name" value="{{ old('name', $user->name) }}" class="form-control @error('name') is-invalid @enderror" required>
                            @error('name') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">المسمى الوظيفي</label>
                            <input type="text" name="job_title" value="{{ old('job_title', $user->job_title) }}" class="form-control @error('job_title') is-invalid @enderror" placeholder="مثال: مدير المتجر">
                            @error('job_title') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>
                        <div class="col-12">
                            <label class="form-label">نبذة مختصرة</label>
                            <textarea name="bio" rows="3" class="form-control @error('bio') is-invalid @enderror" placeholder="تعريف قصير يظهر في ملفك داخل لوحة التحكم">{{ old('bio', $user->bio) }}</textarea>
                            @error('bio') <div class="invalid-feedback">{{ $message }}</div> @enderror
                            <div class="form-hint">حتى 500 حرف.</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">البريد الإلكتروني</label>
                            <input type="email" name="email" value="{{ old('email', $user->email) }}" class="form-control @error('email') is-invalid @enderror" dir="ltr" required>
                            @error('email') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">لغة الواجهة</label>
                            <select name="locale" class="form-select @error('locale') is-invalid @enderror">
                                <option value="ar" @selected(old('locale', $user->locale ?? 'ar') === 'ar')>العربية</option>
                                <option value="en" @selected(old('locale', $user->locale ?? 'ar') === 'en')>English</option>
                            </select>
                            @error('locale') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>
                        <div class="col-12">
                            <label class="form-label">رقم الهاتف</label>
                            <x-admin.gcc-phone-input
                                country-name="phone_country"
                                national-name="phone"
                                :e164="old('phone_full', $user->phone)"
                            />
                            @error('phone') <div class="invalid-feedback d-block">{{ $message }}</div> @enderror
                            <div class="form-hint mt-2">اختياري — للتواصل الداخلي والإشعارات.</div>
                        </div>
                    </div>
                </div>

                <div class="page-card p-4 p-md-5 mb-4" data-password-panel
                     data-verify-url="{{ route('admin.profile.verify-password') }}"
                     data-evaluate-url="{{ route('admin.profile.evaluate-password') }}">
                    <h3 class="profile-section-title">
                        <i class="bi bi-shield-lock"></i>
                        كلمة المرور
                    </h3>
                    <p class="settings-pane-lead mb-3">اترك الحقول فارغة إن لم ترغب بتغيير كلمة المرور. يجب أن تحتوي الجديدة على أحرف وأرقام ورمزاً (8 أحرف على الأقل).</p>
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label">كلمة المرور الحالية</label>
                            <input type="password" name="current_password" class="form-control @error('current_password') is-invalid @enderror" autocomplete="current-password" data-current-password>
                            <div class="password-live-status" data-current-status hidden></div>
                            @error('current_password') <div class="invalid-feedback d-block">{{ $message }}</div> @enderror
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">كلمة المرور الجديدة</label>
                            <input type="password" name="password" class="form-control @error('password') is-invalid @enderror" autocomplete="new-password" data-new-password>
                            @error('password') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">تأكيد كلمة المرور</label>
                            <input type="password" name="password_confirmation" class="form-control" autocomplete="new-password" data-password-confirm>
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
            </div>

            <div class="col-lg-4">
                <div class="page-card p-4 p-md-4 mb-4 profile-side-card">
                    <h3 class="profile-section-title">
                        <i class="bi bi-image"></i>
                        صورة الملف
                    </h3>
                    <div class="profile-upload">
                        <input
                            type="file"
                            name="avatar"
                            accept="image/*"
                            class="form-control @error('avatar') is-invalid @enderror"
                            data-image-preview="#profile-avatar-preview"
                            data-profile-avatar-input
                        >
                        @error('avatar') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        <div class="form-hint mt-2">JPG أو PNG أو WebP — حتى 4MB.</div>
                        @if ($avatarUrl)
                            <label class="form-check mt-3 mb-0">
                                <input type="checkbox" name="remove_avatar" value="1" class="form-check-input" @checked(old('remove_avatar'))>
                                <span class="form-check-label">إزالة الصورة الحالية</span>
                            </label>
                        @endif
                    </div>
                </div>

                <div class="page-card p-4 mb-4 profile-side-card">
                    <h3 class="profile-section-title">
                        <i class="bi bi-info-circle"></i>
                        ملخص الحساب
                    </h3>
                    <ul class="profile-summary list-unstyled mb-0">
                        <li>
                            <span>الدور</span>
                            <strong>مدير</strong>
                        </li>
                        <li>
                            <span>تاريخ الإنشاء</span>
                            <strong>{{ $user->created_at?->format('Y-m-d') ?? '—' }}</strong>
                        </li>
                        <li>
                            <span>الهاتف</span>
                            <strong dir="ltr">{{ $user->phone ? '+'.$user->phone : '—' }}</strong>
                        </li>
                    </ul>
                </div>
            </div>
        </div>

        <div class="profile-actions">
            <button type="submit" class="btn btn-brand">
                <i class="bi bi-check2-circle ms-1"></i>
                {{ $strings::SAVE }}
            </button>
            <a href="{{ route('admin.dashboard') }}" class="btn btn-outline-secondary rounded-pill">{{ $strings::CANCEL }}</a>
        </div>
    </form>
</x-layouts.admin>
