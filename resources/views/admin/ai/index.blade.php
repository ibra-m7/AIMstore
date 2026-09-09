<x-layouts.admin :title="$title">
    <x-admin.page-head
        :title="$title"
        subtitle="إدارة العرض والصوت والأداء والتدريب من مكان واحد"
    />

    <div class="d-flex flex-wrap gap-2 mb-3">
        <a href="{{ route('admin.ai.conversations') }}" class="btn btn-outline-success rounded-pill">
            <i class="bi bi-chat-dots ms-1"></i>
            المحادثات
            @if ($conversationsCount)
                <span class="badge text-bg-success">{{ $conversationsCount }}</span>
            @endif
        </a>
        @if ($hasApiKey)
            <span class="badge badge-soft align-self-center">مفتاح Gemini جاهز على الخادم</span>
        @else
            <span class="badge text-bg-warning align-self-center">أضف GEMINI_API_KEY في ملف .env للخادم</span>
        @endif
    </div>

    @php
        $checked = fn (string $key) => session()->hasOldInput() ? (bool) old($key) : (bool) ($settings[$key] ?? false);
        $val = fn (string $key, $default = '') => old($key, $settings[$key] ?? $default);
    @endphp

    <div class="page-card p-3 p-md-4">
        <ul class="nav nav-tabs flex-nowrap overflow-auto mb-3" role="tablist">
            @foreach ([
                'general' => 'عام',
                'prompt' => 'البرومبت',
                'display' => 'العرض',
                'voice' => 'الصوت',
                'performance' => 'الأداء',
                'training' => 'التدريب',
            ] as $key => $label)
                <li class="nav-item" role="presentation">
                    <button
                        type="button"
                        class="nav-link {{ $tab === $key ? 'active' : '' }}"
                        id="tab-{{ $key }}"
                        data-bs-toggle="tab"
                        data-bs-target="#pane-{{ $key }}"
                        role="tab"
                    >{{ $label }}</button>
                </li>
            @endforeach
        </ul>

        <form method="POST" action="{{ route('admin.ai.update') }}" id="ai-settings-form">
            @csrf
            @method('PUT')
            <input type="hidden" name="active_tab" id="active_tab" value="{{ $tab }}">

            <div class="tab-content">
                <div class="tab-pane fade {{ $tab === 'general' ? 'show active' : '' }}" id="pane-general" role="tabpanel">
                    <div class="form-check mb-3">
                        <input class="form-check-input" type="checkbox" name="enabled" value="1" id="ai_enabled" @checked($checked('enabled'))>
                        <label class="form-check-label" for="ai_enabled">تشغيل المساعد في التطبيق</label>
                    </div>
                    <div class="form-check mb-4">
                        <input class="form-check-input" type="checkbox" name="guests_allowed" value="1" id="ai_guests" @checked($checked('guests_allowed'))>
                        <label class="form-check-label" for="ai_guests">السماح للزوار بدون تسجيل</label>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">اسم المساعد</label>
                        <input type="text" name="name" value="{{ $val('name') }}" class="form-control @error('name') is-invalid @enderror" required maxlength="40">
                        @error('name') <div class="invalid-feedback">{{ $message }}</div> @enderror
                    </div>
                    <div class="mb-3">
                        <label class="form-label">رسالة الترحيب</label>
                        <textarea name="welcome" rows="3" class="form-control @error('welcome') is-invalid @enderror" required maxlength="500">{{ $val('welcome') }}</textarea>
                        @error('welcome') <div class="invalid-feedback">{{ $message }}</div> @enderror
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">أقصى عدد منتجات في الرد</label>
                            <input type="number" name="max_products" min="2" max="8" value="{{ $val('max_products', 6) }}" class="form-control" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">نموذج Gemini</label>
                            <select name="model" class="form-select" required>
                                @foreach ($models as $model)
                                    <option value="{{ $model }}" @selected($val('model') === $model)>{{ $model }}</option>
                                @endforeach
                            </select>
                        </div>
                    </div>
                </div>

                <div class="tab-pane fade {{ $tab === 'prompt' ? 'show active' : '' }}" id="pane-prompt" role="tabpanel">
                    <div class="mb-3">
                        <label class="form-label">تعليمات الأسلوب (System Prompt)</label>
                        <textarea name="system_prompt" rows="12" class="form-control @error('system_prompt') is-invalid @enderror" required maxlength="4000">{{ $val('system_prompt') }}</textarea>
                        @error('system_prompt') <div class="invalid-feedback">{{ $message }}</div> @enderror
                        <div class="form-hint">للذكاء الاصطناعي فقط. لا يظهر للعميل.</div>
                    </div>
                </div>

                <div class="tab-pane fade {{ $tab === 'display' ? 'show active' : '' }}" id="pane-display" role="tabpanel">
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label class="form-label">نمط العرض</label>
                            <select name="presentation" class="form-select" required>
                                <option value="floating" @selected($val('presentation') === 'floating')>لوحة عائمة</option>
                                <option value="fullscreen" @selected($val('presentation') === 'fullscreen')>شاشة كاملة</option>
                                <option value="hybrid" @selected($val('presentation') === 'hybrid')>مزيج (عائم + توسيع)</option>
                            </select>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label">شكل المنتجات</label>
                            <select name="product_layout" class="form-select" required>
                                <option value="strip" @selected($val('product_layout') === 'strip')>شريط أفقي</option>
                                <option value="grid" @selected($val('product_layout') === 'grid')>شبكة</option>
                            </select>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label">شكل الفقاعات</label>
                            <select name="bubble_style" class="form-select" required>
                                <option value="modern" @selected($val('bubble_style') === 'modern')>عصري</option>
                                <option value="soft" @selected($val('bubble_style') === 'soft')>ناعم</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        @php
                            $primaryColor = (string) $val('primary_color');
                            $surfaceColor = (string) $val('surface_color');
                            $primaryPicker = preg_match('/^#[0-9A-Fa-f]{6}$/', $primaryColor) ? $primaryColor : '#88D498';
                            $surfacePicker = preg_match('/^#[0-9A-Fa-f]{6}$/', $surfaceColor) ? $surfaceColor : '#FFFFFF';
                        @endphp
                        <div class="col-md-6 mb-3">
                            <label class="form-label">لون أساسي (اختياري)</label>
                            <div class="color-picker-field" data-ai-color-field>
                                <input
                                    type="color"
                                    value="{{ $primaryPicker }}"
                                    class="color-picker-input"
                                    title="اختر لوناً"
                                    data-ai-color-picker
                                    data-color-sync="#ai-primary-hex-label"
                                    data-color-preview="#ai-primary-swatch"
                                    aria-label="منتقي اللون الأساسي"
                                >
                                <div class="color-picker-display">
                                    <span id="ai-primary-swatch" class="color-picker-swatch" style="background: {{ $primaryPicker }};"></span>
                                    <input
                                        type="text"
                                        name="primary_color"
                                        id="ai-primary-color"
                                        value="{{ $primaryColor }}"
                                        class="form-control border-0 shadow-none px-0"
                                        placeholder="#88D498"
                                        maxlength="7"
                                        data-ai-color-hex
                                        autocomplete="off"
                                    >
                                    <span id="ai-primary-hex-label" class="visually-hidden">{{ $primaryPicker }}</span>
                                </div>
                                <button type="button" class="btn btn-sm btn-outline-secondary rounded-pill" data-ai-color-clear title="مسح اللون">
                                    مسح
                                </button>
                            </div>
                            <div class="form-hint">اضغط مربع اللون لاختياره من اللوحة. اتركه فارغاً لاستخدام هوية التطبيق.</div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">لون السطح (اختياري)</label>
                            <div class="color-picker-field" data-ai-color-field>
                                <input
                                    type="color"
                                    value="{{ $surfacePicker }}"
                                    class="color-picker-input"
                                    title="اختر لوناً"
                                    data-ai-color-picker
                                    data-color-sync="#ai-surface-hex-label"
                                    data-color-preview="#ai-surface-swatch"
                                    aria-label="منتقي لون السطح"
                                >
                                <div class="color-picker-display">
                                    <span id="ai-surface-swatch" class="color-picker-swatch" style="background: {{ $surfacePicker }};"></span>
                                    <input
                                        type="text"
                                        name="surface_color"
                                        id="ai-surface-color"
                                        value="{{ $surfaceColor }}"
                                        class="form-control border-0 shadow-none px-0"
                                        placeholder="#FFFFFF"
                                        maxlength="7"
                                        data-ai-color-hex
                                        autocomplete="off"
                                    >
                                    <span id="ai-surface-hex-label" class="visually-hidden">{{ $surfacePicker }}</span>
                                </div>
                                <button type="button" class="btn btn-sm btn-outline-secondary rounded-pill" data-ai-color-clear title="مسح اللون">
                                    مسح
                                </button>
                            </div>
                            <div class="form-hint">اضغط مربع اللون لاختياره من اللوحة. اتركه فارغاً لاستخدام هوية التطبيق.</div>
                        </div>
                    </div>
                    <div class="form-check mb-3">
                        <input class="form-check-input" type="checkbox" name="show_close_button" value="1" id="ai_close" @checked($checked('show_close_button'))>
                        <label class="form-check-label" for="ai_close">إظهار زر الإغلاق في اللوحة</label>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">اقتراحات سريعة (سطر لكل اقتراح)</label>
                        <textarea name="suggestion_chips" rows="5" class="form-control" maxlength="2000">{{ $val('suggestion_chips') }}</textarea>
                    </div>
                </div>

                <div class="tab-pane fade {{ $tab === 'voice' ? 'show active' : '' }}" id="pane-voice" role="tabpanel">
                    <div class="form-check mb-2">
                        <input class="form-check-input" type="checkbox" name="tts_enabled" value="1" id="tts_enabled" @checked($checked('tts_enabled'))>
                        <label class="form-check-label" for="tts_enabled">السماح بالصوت في التطبيق</label>
                    </div>
                    <div class="form-check mb-2">
                        <input class="form-check-input" type="checkbox" name="tts_default_on" value="1" id="tts_default_on" @checked($checked('tts_default_on'))>
                        <label class="form-check-label" for="tts_default_on">الصوت مفعّل افتراضياً عند أول فتح</label>
                    </div>
                    <div class="form-check mb-2">
                        <input class="form-check-input" type="checkbox" name="tts_welcome" value="1" id="tts_welcome" @checked($checked('tts_welcome'))>
                        <label class="form-check-label" for="tts_welcome">نطق رسالة الترحيب</label>
                    </div>
                    <div class="form-check mb-2">
                        <input class="form-check-input" type="checkbox" name="tts_replies" value="1" id="tts_replies" @checked($checked('tts_replies'))>
                        <label class="form-check-label" for="tts_replies">نطق ردود المساعد</label>
                    </div>
                    <div class="form-check mb-3">
                        <input class="form-check-input" type="checkbox" name="stt_enabled" value="1" id="stt_enabled" @checked($checked('stt_enabled'))>
                        <label class="form-check-label" for="stt_enabled">تفعيل الميكروفون (Speech to Text)</label>
                    </div>
                    <div class="mb-3" style="max-width: 220px">
                        <label class="form-label">سرعة الكلام</label>
                        <input type="number" step="0.05" min="0.3" max="0.9" name="tts_rate" value="{{ $val('tts_rate', 0.5) }}" class="form-control" required>
                    </div>
                    <hr>
                    <div class="form-check mb-2">
                        <input class="form-check-input" type="checkbox" name="notify_on_ops" value="1" id="notify_on_ops" @checked($checked('notify_on_ops'))>
                        <label class="form-check-label" for="notify_on_ops">إرسال إشعار للعملاء عند عمليات AI من الأدمن</label>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">عنوان إشعار العمليات</label>
                        <input type="text" name="notify_title" value="{{ $val('notify_title') }}" class="form-control" maxlength="80">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">نص إشعار العمليات</label>
                        <textarea name="notify_body" rows="2" class="form-control" maxlength="240">{{ $val('notify_body') }}</textarea>
                    </div>
                </div>

                <div class="tab-pane fade {{ $tab === 'performance' ? 'show active' : '' }}" id="pane-performance" role="tabpanel">
                    <div class="form-check mb-3">
                        <input class="form-check-input" type="checkbox" name="fast_mode" value="1" id="fast_mode" @checked($checked('fast_mode'))>
                        <label class="form-check-label" for="fast_mode">الوضع السريع (generateJsonFast)</label>
                    </div>
                    <div class="row">
                        <div class="col-md-3 mb-3">
                            <label class="form-label">حد الكتالوج</label>
                            <input type="number" name="catalog_limit" min="12" max="60" value="{{ $val('catalog_limit', 28) }}" class="form-control" required>
                        </div>
                        <div class="col-md-3 mb-3">
                            <label class="form-label">نافذة التاريخ</label>
                            <input type="number" name="history_limit" min="4" max="16" value="{{ $val('history_limit', 8) }}" class="form-control" required>
                        </div>
                        <div class="col-md-3 mb-3">
                            <label class="form-label">المهلة (ثانية)</label>
                            <input type="number" name="timeout_seconds" min="15" max="45" value="{{ $val('timeout_seconds', 25) }}" class="form-control" required>
                        </div>
                        <div class="col-md-3 mb-3">
                            <label class="form-label">حد الطلبات / دقيقة</label>
                            <input type="number" name="rate_limit_per_minute" min="5" max="60" value="{{ $val('rate_limit_per_minute', 20) }}" class="form-control" required>
                        </div>
                    </div>
                </div>

                <div class="tab-pane fade {{ $tab === 'training' ? 'show active' : '' }}" id="pane-training" role="tabpanel">
                    <div class="alert alert-light border mb-3">
                        <div><strong>آخر تشغيل:</strong> {{ $settings['train_last_run_at'] ?: '—' }}</div>
                        <div><strong>الحالة:</strong> {{ $settings['train_last_status'] ?: 'idle' }}</div>
                        <div class="text-muted">{{ $settings['train_last_message'] ?: 'لا توجد نتائج بعد.' }}</div>
                    </div>
                    <div class="mb-3" style="max-width: 220px">
                        <label class="form-label">حد المنتجات للتدريب</label>
                        <input type="number" name="train_limit" min="1" max="200" value="{{ $val('train_limit', 80) }}" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">برومبت تدريب التوصيات</label>
                        <textarea name="train_prompt" rows="10" class="form-control" maxlength="6000">{{ $val('train_prompt') }}</textarea>
                    </div>
                </div>
            </div>

            <div class="d-flex flex-wrap gap-2 mt-3">
                <button class="btn btn-brand">{{ $strings::SAVE }}</button>
            </div>
        </form>

        <form method="POST" action="{{ route('admin.ai.train') }}" class="mt-3 p-3 border rounded-4 bg-light" onsubmit="return confirm('تشغيل تدريب التوصيات الآن؟ قد يستغرق وقتاً.');">
            @csrf
            <div class="d-flex flex-wrap align-items-end gap-3">
                <div>
                    <label class="form-label">تشغيل التدريب الآن</label>
                    <input type="number" name="train_limit" min="1" max="200" value="{{ $settings['train_limit'] }}" class="form-control" style="width: 140px">
                </div>
                <div class="form-check mb-2">
                    <input class="form-check-input" type="checkbox" name="notify_customers" value="1" id="notify_customers">
                    <label class="form-check-label" for="notify_customers">أرسل إشعاراً للعملاء عند الانتهاء</label>
                </div>
                <button class="btn btn-success rounded-pill mb-1">
                    <i class="bi bi-lightning-charge ms-1"></i>
                    تدريب الآن
                </button>
            </div>
        </form>
    </div>

    <script>
        document.querySelectorAll('[data-bs-toggle="tab"]').forEach((btn) => {
            btn.addEventListener('shown.bs.tab', (e) => {
                const id = (e.target.getAttribute('data-bs-target') || '').replace('#pane-', '');
                const input = document.getElementById('active_tab');
                if (input && id) input.value = id;
                const url = new URL(window.location.href);
                url.searchParams.set('tab', id);
                window.history.replaceState({}, '', url);
            });
        });

        const normalizeHex = (value) => {
            const raw = String(value || '').trim();
            if (/^#[0-9A-Fa-f]{6}$/.test(raw)) return raw.toUpperCase();
            if (/^[0-9A-Fa-f]{6}$/.test(raw)) return `#${raw.toUpperCase()}`;
            return '';
        };

        document.querySelectorAll('[data-ai-color-field]').forEach((field) => {
            const picker = field.querySelector('[data-ai-color-picker]');
            const hex = field.querySelector('[data-ai-color-hex]');
            const clearBtn = field.querySelector('[data-ai-color-clear]');
            const swatch = field.querySelector('.color-picker-swatch');
            if (!picker || !hex) return;

            const apply = (value, fromPicker = false) => {
                const normalized = normalizeHex(value);
                if (normalized) {
                    picker.value = normalized;
                    if (!fromPicker) hex.value = normalized;
                    if (swatch) swatch.style.background = normalized;
                    return;
                }
                if (!fromPicker) {
                    hex.value = String(value || '').trim();
                }
            };

            picker.addEventListener('input', () => {
                hex.value = picker.value.toUpperCase();
                if (swatch) swatch.style.background = picker.value;
            });

            hex.addEventListener('input', () => apply(hex.value));
            hex.addEventListener('blur', () => {
                const normalized = normalizeHex(hex.value);
                hex.value = normalized;
                if (normalized) apply(normalized);
            });

            clearBtn?.addEventListener('click', () => {
                hex.value = '';
                if (swatch) swatch.style.background = picker.value;
                hex.focus();
            });
        });
    </script>
</x-layouts.admin>
