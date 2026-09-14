@php
    $tab = old('active_tab', $tab ?? 'app');
    $scope = old('marketing_sold_scope', $settings['marketing_sold_scope']);
@endphp

<x-layouts.admin :title="$title">
    <x-admin.page-head :title="$title" />

    <div class="page-card p-0 overflow-hidden" style="max-width: 920px">
        <form method="POST" action="{{ route('admin.settings.update') }}" data-settings-form enctype="multipart/form-data">
            @csrf
            @method('PUT')
            <input type="hidden" name="active_tab" value="{{ $tab }}" data-settings-active-tab>

            <div class="p-4 p-md-5">
                @if ($tab === 'app')
                    <h2 class="settings-pane-title">إعدادات التطبيق</h2>
                    <p class="settings-pane-lead">الاسم والعملة كما يظهران للعميل داخل التطبيق.</p>

                    <div class="mb-3">
                        <label class="form-label">اسم المتجر في التطبيق</label>
                        <input type="text" name="store_name" value="{{ old('store_name', $settings['store_name']) }}" class="form-control @error('store_name') is-invalid @enderror" required>
                        @error('store_name') <div class="invalid-feedback">{{ $message }}</div> @enderror
                    </div>
                    <div class="mb-4">
                        <label class="form-label">العملة</label>
                        <div class="form-control-plaintext fs-4">{{ $strings::CURRENCY }} {{ $strings::CURRENCY_NAME }}</div>
                        <input type="hidden" name="currency" value="YER">
                    </div>

                    @php
                        $fallbackRaw = $settings['fallback_product_image'] ?? '';
                        $fallbackSrc = \App\Support\StoreSettings::fallbackProductImageUrl();
                    @endphp
                    <div class="mb-3">
                        <label class="form-label">صورة المنتج الافتراضية</label>
                        <input type="file" name="fallback_product_image" accept="image/*" class="form-control @error('fallback_product_image') is-invalid @enderror" data-image-preview="#fallback-product-preview">
                        @error('fallback_product_image') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        <img id="fallback-product-preview" src="{{ $fallbackSrc }}" alt="" class="upload-preview mt-2" style="width: 120px; height: 120px; object-fit: cover" @if(! $fallbackSrc) hidden @endif>
                    </div>
                    <div class="mb-4">
                        <label class="form-label">أو رابط الصورة الافتراضية</label>
                        <input type="url" name="fallback_product_image_url" value="{{ old('fallback_product_image_url', str_starts_with((string) $fallbackRaw, 'http') ? $fallbackRaw : '') }}" class="form-control @error('fallback_product_image_url') is-invalid @enderror" placeholder="https://...">
                        @error('fallback_product_image_url') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        <div class="form-hint">تُعرض لأي منتج بلا صورة.</div>
                    </div>

                    @php
                        $homeLogoRaw = $settings['home_logo'] ?? '';
                        $homeLogoSrc = \App\Support\StoreSettings::homeLogoUrl();
                    @endphp
                    <div class="mb-3">
                        <label class="form-label">شعار الصفحة الرئيسية (App Bar)</label>
                        <input type="file" name="home_logo" accept="image/*" class="form-control @error('home_logo') is-invalid @enderror" data-image-preview="#home-logo-preview">
                        @error('home_logo') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        <img id="home-logo-preview" src="{{ $homeLogoSrc }}" alt="" class="upload-preview mt-2" style="width: auto; max-width: 240px; height: 64px; object-fit: contain; background: #f3f5f8; border-radius: 12px; padding: 8px;" @if(! $homeLogoSrc) hidden @endif>
                    </div>
                    <div class="mb-4">
                        <label class="form-label">أو رابط شعار الرئيسية</label>
                        <input type="url" name="home_logo_url" value="{{ old('home_logo_url', str_starts_with((string) $homeLogoRaw, 'http') ? $homeLogoRaw : '') }}" class="form-control @error('home_logo_url') is-invalid @enderror" placeholder="https://...">
                        @error('home_logo_url') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        <div class="form-hint">يظهر في شريط الصفحة الرئيسية داخل التطبيق. إن تُرك فارغاً يُستخدم الشعار الافتراضي.</div>
                    </div>

                    <div class="settings-links">
                        <a href="{{ route('admin.ai.index') }}" class="settings-link">
                            <i class="bi bi-stars"></i>
                            <span>المساعد الذكي</span>
                        </a>
                        <a href="{{ route('admin.onboarding.index') }}" class="settings-link">
                            <i class="bi bi-collection"></i>
                            <span>شرائح التعريف</span>
                        </a>
                    </div>

                    <hr class="my-4">

                    <h3 class="h6 fw-bold mb-1">راسلنا (واتساب)</h3>
                    <p class="settings-pane-lead mb-3">الرقم الذي يُفتح عند الضغط على «راسلنا» في التطبيق.</p>
                    <div class="mb-4">
                        <label class="form-label">رقم واتساب راسلنا</label>
                        <x-admin.gcc-phone-input
                            country-name="message_us_phone_country"
                            national-name="message_us_phone"
                            :e164="old('message_us_phone_full', $settings['message_us_phone'])"
                        />
                        <div class="form-hint mt-2">اختر الدولة ثم أدخل الرقم بدون رمز الدولة.</div>
                    </div>

                    <h3 class="h6 fw-bold mb-1">أرقام خدمة العملاء</h3>
                    <p class="settings-pane-lead mb-3">تظهر في نافذة صغيرة عند الضغط على «خدمة العملاء» داخل التطبيق.</p>
                    <x-admin.contact-numbers-picker
                        :rows="old('customer_service_numbers', $settings['customer_service_numbers'])"
                    />
                @elseif ($tab === 'store')
                    <h2 class="settings-pane-title">إعدادات المتجر</h2>
                    <p class="settings-pane-lead">الشحن والتحويل البنكي داخل اليمن.</p>

                    <div class="mb-3">
                        <label class="form-label">{{ $strings::SETTINGS_SHIPPING_FEE }}</label>
                        <input type="number" step="0.01" name="shipping_fee" value="{{ old('shipping_fee', $settings['shipping_fee']) }}" class="form-control @error('shipping_fee') is-invalid @enderror" required>
                        @error('shipping_fee') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        <div class="form-hint">رسوم احتياطية. سياسة المسافة من صفحة التوصيل.</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">{{ $strings::SETTINGS_FREE_SHIPPING }}</label>
                        <input type="number" step="0.01" name="free_shipping_threshold" value="{{ old('free_shipping_threshold', $settings['free_shipping_threshold']) }}" class="form-control @error('free_shipping_threshold') is-invalid @enderror" required>
                        @error('free_shipping_threshold') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        <div class="form-hint">0 لتعطيله.</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">اسم البنك (للتحويل داخل اليمن)</label>
                        <input type="text" name="bank_name" value="{{ old('bank_name', $settings['bank_name']) }}" class="form-control @error('bank_name') is-invalid @enderror">
                        @error('bank_name') <div class="invalid-feedback">{{ $message }}</div> @enderror
                    </div>
                    <div class="mb-4">
                        <label class="form-label">آيبان المتجر</label>
                        <input type="text" name="bank_iban" value="{{ old('bank_iban', $settings['bank_iban']) }}" class="form-control @error('bank_iban') is-invalid @enderror" placeholder="YExx xxxx xxxx xxxx xxxx xxxx" dir="ltr">
                        @error('bank_iban') <div class="invalid-feedback">{{ $message }}</div> @enderror
                    </div>

                    <div class="settings-links">
                        <a href="{{ route('admin.splash-screens.index') }}" class="settings-link">
                            <i class="bi bi-phone"></i>
                            <span>شاشة البداية</span>
                        </a>
                        <a href="{{ route('admin.onboarding.index') }}" class="settings-link">
                            <i class="bi bi-collection"></i>
                            <span>شرائح الترحيب</span>
                        </a>
                        <a href="{{ route('admin.delivery.index') }}" class="settings-link">
                            <i class="bi bi-truck"></i>
                            <span>مناطق ورسوم التوصيل</span>
                        </a>
                        <a href="{{ route('admin.payment-methods.index') }}" class="settings-link">
                            <i class="bi bi-credit-card"></i>
                            <span>طرق الدفع</span>
                        </a>
                    </div>

                    <hr class="my-4">
                    <h3 class="h6 fw-bold mb-1 text-danger">منطقة خطرة</h3>
                    <p class="settings-pane-lead mb-3">إجراءات لا يمكن التراجع عنها تخص كتالوج المنتجات.</p>
                    <div class="settings-danger mb-0">
                        <h2 class="settings-danger-title">حذف كل المنتجات</h2>
                        <p class="settings-danger-lead">يحذف كل المنتجات من الكتالوج والتطبيق نهائياً. تبقى الطلبات السابقة في السجل بدون ربط بالمنتج.</p>
                        <p class="settings-danger-count">المنتجات الحالية: <strong>{{ $productCount }}</strong></p>
                        <label class="form-label" for="wipe-products-confirmation">اكتب «{{ $strings::WIPE_PRODUCTS_CONFIRMATION_PHRASE }}» للتأكيد</label>
                        <input type="text" id="wipe-products-confirmation" name="confirmation" form="wipe-products-form" value="{{ old('confirmation') }}" class="form-control @error('confirmation') is-invalid @enderror" autocomplete="off" {{ $productCount === 0 ? 'disabled' : '' }} placeholder="{{ $strings::WIPE_PRODUCTS_CONFIRMATION_PHRASE }}" data-wipe-products-input>
                        @error('confirmation') <div class="invalid-feedback d-block">{{ $message }}</div> @enderror
                        <button type="submit" form="wipe-products-form" class="btn btn-outline-danger rounded-pill mt-3" {{ $productCount === 0 ? 'disabled' : '' }}>
                            حذف كل المنتجات
                        </button>
                    </div>
                @elseif ($tab === 'marketing')
                    <h2 class="settings-pane-title">العروض والتسويق</h2>
                    <p class="settings-pane-lead">عدد تسويقي يظهر على المنتجات، وتوصيات «يُشترى معه» في التطبيق.</p>

                    <div class="border rounded-4 p-3 mb-4 bg-light">
                        <input type="hidden" name="auto_product_recommendations" value="0">
                        <div class="form-check form-switch mb-0">
                            <input
                                class="form-check-input"
                                type="checkbox"
                                role="switch"
                                id="auto_product_recommendations"
                                name="auto_product_recommendations"
                                value="1"
                                @checked(filter_var(old('auto_product_recommendations', ($settings['auto_product_recommendations'] ?? false) ? '1' : '0'), FILTER_VALIDATE_BOOLEAN))
                            >
                            <label class="form-check-label" for="auto_product_recommendations">
                                <strong>تفعيل «يُشترى معه» التلقائي لكل المنتجات</strong>
                                <span class="d-block small text-muted">
                                    عند التفعيل يملأ النظام صف «يُشترى معه» تلقائيًا لجميع المنتجات.
                                    عند الإيقاف يظهر فقط ما تختاره يدويًا في كل منتج.
                                </span>
                            </label>
                        </div>
                        @error('auto_product_recommendations')
                            <div class="invalid-feedback d-block">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="mb-3">
                        <label class="form-label">عدد العملاء التسويقي</label>
                        <input type="number" min="0" name="marketing_sold_count" value="{{ old('marketing_sold_count', $settings['marketing_sold_count']) }}" class="form-control @error('marketing_sold_count') is-invalid @enderror">
                        @error('marketing_sold_count') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        <div class="form-hint">0 لإخفاء العدد.</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label d-block">يظهر على</label>
                        <div class="settings-scope">
                            <label class="settings-scope-option">
                                <input type="radio" name="marketing_sold_scope" value="all" @checked($scope !== 'selected') data-sold-scope>
                                <span>كل المنتجات</span>
                            </label>
                            <label class="settings-scope-option">
                                <input type="radio" name="marketing_sold_scope" value="selected" @checked($scope === 'selected') data-sold-scope>
                                <span>منتجات محددة</span>
                            </label>
                        </div>
                        @error('marketing_sold_scope') <div class="invalid-feedback d-block">{{ $message }}</div> @enderror
                    </div>

                    <div class="product-picker" data-product-picker data-scope="{{ $scope === 'selected' ? 'selected' : 'all' }}">
                        <x-admin.product-picker
                            name="marketing_sold_product_ids[]"
                            :selected="$products"
                            hint="ابحث وأضف المنتجات التي يظهر عليها عداد المبيعات التسويقي."
                        />
                    </div>

                    <div class="settings-links mt-4">
                        <a href="{{ route('admin.offers.index') }}" class="settings-link">
                            <i class="bi bi-percent"></i>
                            <span>عروض الأسعار</span>
                        </a>
                        <a href="{{ route('admin.coupons.index') }}" class="settings-link">
                            <i class="bi bi-ticket-perforated"></i>
                            <span>الكوبونات</span>
                        </a>
                        <a href="{{ route('admin.banners.index') }}" class="settings-link">
                            <i class="bi bi-image"></i>
                            <span>البنرات</span>
                        </a>
                    </div>
                @else
                    <h2 class="settings-pane-title">الخصوصية</h2>
                    <p class="settings-pane-lead mb-4">إدارة أرقام الدخول المباشر ودول رمز الهاتف في التطبيق.</p>

                    <div class="mb-4">
                        <label class="form-label fw-bold">دول رمز الهاتف في تسجيل الدخول</label>
                        <p class="text-muted small mb-2">اختر الدول التي تظهر للمستخدم عند اختيار رمز الدولة. يجب اختيار دولة واحدة على الأقل.</p>
                        @php
                            $selectedPhoneCountries = old('phone_allowed_countries', $settings['phone_allowed_countries'] ?? []);
                            if (! is_array($selectedPhoneCountries)) {
                                $selectedPhoneCountries = [];
                            }
                        @endphp
                        <div class="row g-2">
                            @foreach ($phoneCountryCatalog as $code => $meta)
                                <div class="col-md-6 col-lg-4">
                                    <label class="form-check border rounded-3 px-3 py-2 h-100">
                                        <input
                                            class="form-check-input @error('phone_allowed_countries') is-invalid @enderror @error('phone_allowed_countries.*') is-invalid @enderror"
                                            type="checkbox"
                                            name="phone_allowed_countries[]"
                                            value="{{ $code }}"
                                            @checked(in_array($code, $selectedPhoneCountries, true))
                                        >
                                        <span class="form-check-label">
                                            {{ $meta['flag'] }} {{ $meta['name'] }}
                                            <span class="text-muted" dir="ltr">{{ $meta['dial'] }}</span>
                                        </span>
                                    </label>
                                </div>
                            @endforeach
                        </div>
                        @error('phone_allowed_countries')
                            <div class="text-danger small mt-2">{{ $message }}</div>
                        @enderror
                        @error('phone_allowed_countries.*')
                            <div class="text-danger small mt-2">{{ $message }}</div>
                        @enderror
                    </div>

                    <x-admin.otp-bypass-phones-picker
                        :phones="old('otp_bypass_phones', $settings['otp_bypass_phones'])"
                    />
                @endif

                <div class="pt-4">
                    <button class="btn btn-brand">{{ $strings::SAVE }}</button>
                </div>
            </div>
        </form>

        @if ($tab === 'store')
            <form
                id="wipe-products-form"
                method="POST"
                action="{{ route('admin.settings.products.destroy-all') }}"
                data-wipe-products-form
                data-wipe-phrase="{{ $strings::WIPE_PRODUCTS_CONFIRMATION_PHRASE }}"
                data-wipe-confirm="{{ $strings::CONFIRM_WIPE_PRODUCTS }}"
                class="d-none"
                aria-hidden="true"
            >
                @csrf
                @method('DELETE')
            </form>
        @endif
    </div>
</x-layouts.admin>
