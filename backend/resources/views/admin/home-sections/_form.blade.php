@php
    use App\Support\Media;

    $section = $section ?? new \App\Models\HomeSection(['is_active' => true, 'sort_order' => 0]);
    $contentType = old('content_type', $section->content_type ?? \App\Models\HomeSection::CONTENT_PRODUCTS);
    $showsBundles = $contentType === \App\Models\HomeSection::CONTENT_BUNDLES;

    $useDefaultTitleColor = old('use_default_title_color', empty($section->title_color));
    $titleColor = old('title_color', $section->title_color ?: '#0A1F4D');
    $titleColor = preg_match('/^#?[0-9A-Fa-f]{6}$/', (string) $titleColor)
        ? '#'.strtoupper(ltrim((string) $titleColor, '#'))
        : '#0A1F4D';

    $useDefaultSubtitleColor = old('use_default_subtitle_color', empty($section->subtitle_color));
    $subtitleColor = old('subtitle_color', $section->subtitle_color ?: '#6B7C74');
    $subtitleColor = preg_match('/^#?[0-9A-Fa-f]{6}$/', (string) $subtitleColor)
        ? '#'.strtoupper(ltrim((string) $subtitleColor, '#'))
        : '#6B7C74';

    $backgroundMode = old('background_mode', ! empty($section->background_image_url) ? 'image' : 'color');
    $useDefaultBg = old('use_default_background', empty($section->background_color) && empty($section->background_image_url));
    $bgColor = old('background_color', $section->background_color ?: '#E8EEF8');
    $bgColor = preg_match('/^#?[0-9A-Fa-f]{6}$/', (string) $bgColor)
        ? '#'.strtoupper(ltrim((string) $bgColor, '#'))
        : '#E8EEF8';
    $bgImageSrc = Media::url($section->background_image_url);

    $titleFontSize = old('title_font_size', $section->title_font_size ?? \App\Models\HomeSection::DEFAULT_TITLE_FONT_SIZE);
    $subtitleFontSize = old('subtitle_font_size', $section->subtitle_font_size ?? \App\Models\HomeSection::DEFAULT_SUBTITLE_FONT_SIZE);
    $cardWidth = old('card_width', $section->card_width ?? \App\Models\HomeSection::DEFAULT_CARD_WIDTH);
    $rowHeight = old('row_height', $section->row_height);
    $itemSpacing = old('item_spacing', $section->item_spacing ?? \App\Models\HomeSection::DEFAULT_ITEM_SPACING);
    $paddingTop = old('padding_top', $section->padding_top ?? \App\Models\HomeSection::DEFAULT_PADDING_TOP);
    $paddingBottom = old('padding_bottom', $section->padding_bottom ?? \App\Models\HomeSection::DEFAULT_PADDING_BOTTOM);
@endphp

<div class="alert alert-light border mb-4">
    <strong>أين يظهر هذا في التطبيق؟</strong>
    <p class="mb-0 small text-muted">
        يظهر كشريط أفقي في الصفحة الرئيسية. اختر نوع المحتوى ثم خصّص المظهر والمنتجات أو السلات.
    </p>
</div>

<div class="row g-3 align-items-end mb-3">
    <div class="col-lg-4 col-md-5">
        <label class="form-label">اسم القسم</label>
        <input type="text" name="title" value="{{ old('title', $section->title) }}" class="form-control form-control-sm @error('title') is-invalid @enderror" required>
        @error('title') <div class="invalid-feedback">{{ $message }}</div> @enderror
    </div>
    <div class="col-auto">
        <label class="form-label d-block">لون الاسم</label>
        <div class="d-flex align-items-center gap-2 flex-wrap">
            <div class="color-picker-field">
                <input
                    type="color"
                    id="home_section_title_color"
                    name="title_color"
                    value="{{ $titleColor }}"
                    class="color-picker-input @error('title_color') is-invalid @enderror"
                    data-color-sync="#home-section-title-hex"
                    @disabled($useDefaultTitleColor)
                >
                <span id="home-section-title-hex" class="color-picker-hex">{{ $titleColor }}</span>
            </div>
            <div class="form-check mb-0">
                <input
                    class="form-check-input"
                    type="checkbox"
                    name="use_default_title_color"
                    value="1"
                    id="use_default_title_color"
                    data-home-section-color-toggle="#home_section_title_color"
                    @checked($useDefaultTitleColor)
                >
                <label class="form-check-label small" for="use_default_title_color">افتراضي</label>
            </div>
        </div>
        @error('title_color') <div class="text-danger small mt-1">{{ $message }}</div> @enderror
    </div>
    <div class="col-auto">
        <div class="form-check mb-2">
            <input class="form-check-input" type="checkbox" name="show_title_icon" value="1" id="show_title_icon" @checked(old('show_title_icon', $section->show_title_icon ?? false))>
            <label class="form-check-label" for="show_title_icon">أيقونة النار بجانب العنوان</label>
        </div>
    </div>
</div>

<div class="row g-3 align-items-end mb-3">
    <div class="col-lg-4 col-md-5">
        <label class="form-label">العنوان الفرعي</label>
        <input type="text" name="subtitle" value="{{ old('subtitle', $section->subtitle) }}" class="form-control form-control-sm">
        <div class="form-hint">يظهر تحت الاسم في التطبيق.</div>
    </div>
    <div class="col-auto">
        <label class="form-label d-block">لون العنوان الفرعي</label>
        <div class="d-flex align-items-center gap-2 flex-wrap">
            <div class="color-picker-field">
                <input
                    type="color"
                    id="home_section_subtitle_color"
                    name="subtitle_color"
                    value="{{ $subtitleColor }}"
                    class="color-picker-input @error('subtitle_color') is-invalid @enderror"
                    data-color-sync="#home-section-subtitle-hex"
                    @disabled($useDefaultSubtitleColor)
                >
                <span id="home-section-subtitle-hex" class="color-picker-hex">{{ $subtitleColor }}</span>
            </div>
            <div class="form-check mb-0">
                <input
                    class="form-check-input"
                    type="checkbox"
                    name="use_default_subtitle_color"
                    value="1"
                    id="use_default_subtitle_color"
                    data-home-section-color-toggle="#home_section_subtitle_color"
                    @checked($useDefaultSubtitleColor)
                >
                <label class="form-check-label small" for="use_default_subtitle_color">افتراضي</label>
            </div>
        </div>
        @error('subtitle_color') <div class="text-danger small mt-1">{{ $message }}</div> @enderror
    </div>
    <div class="col-auto">
        <div class="form-check mb-2">
            <input class="form-check-input" type="checkbox" name="emphasize_subtitle" value="1" id="emphasize_subtitle" @checked(old('emphasize_subtitle', $section->emphasize_subtitle ?? false))>
            <label class="form-check-label" for="emphasize_subtitle">تمييز العنوان الفرعي</label>
            <div class="form-hint">خط أصغر وأكثر بروزاً.</div>
        </div>
    </div>
</div>

<div class="mb-3">
    <label class="form-label d-block">نوع المحتوى</label>
    <div class="d-flex flex-wrap gap-3">
        <div class="form-check">
            <input class="form-check-input" type="radio" name="content_type" id="content_type_products" value="products" data-home-section-content-type="products" @checked($contentType === 'products')>
            <label class="form-check-label" for="content_type_products">منتجات</label>
        </div>
        <div class="form-check">
            <input class="form-check-input" type="radio" name="content_type" id="content_type_bundles" value="bundles" data-home-section-content-type="bundles" @checked($contentType === 'bundles')>
            <label class="form-check-label" for="content_type_bundles">سلات التوفير</label>
        </div>
    </div>
    @error('content_type') <div class="text-danger small mt-1">{{ $message }}</div> @enderror
</div>

<div class="mb-3">
    <label class="form-label d-block">خلفية القسم في التطبيق</label>
    <div class="d-flex flex-wrap gap-3 mb-3">
        <div class="form-check">
            <input class="form-check-input" type="radio" name="background_mode" id="background_mode_color" value="color" data-home-section-bg-mode="color" @checked($backgroundMode === 'color')>
            <label class="form-check-label" for="background_mode_color">لون</label>
        </div>
        <div class="form-check">
            <input class="form-check-input" type="radio" name="background_mode" id="background_mode_image" value="image" data-home-section-bg-mode="image" @checked($backgroundMode === 'image')>
            <label class="form-check-label" for="background_mode_image">صورة</label>
        </div>
    </div>

    <div id="home-section-bg-color-wrap" @if($backgroundMode !== 'color') hidden @endif>
        <div class="d-flex align-items-center gap-3 flex-wrap mb-2">
            <div class="color-picker-field">
                <input
                    type="color"
                    id="home_section_background_color"
                    name="background_color"
                    value="{{ $bgColor }}"
                    class="color-picker-input @error('background_color') is-invalid @enderror"
                    data-color-sync="#home-section-bg-hex"
                    @disabled($useDefaultBg)
                >
                <span id="home-section-bg-hex" class="color-picker-hex">{{ $bgColor }}</span>
            </div>
            <div class="form-check mb-0">
                <input
                    class="form-check-input"
                    type="checkbox"
                    name="use_default_background"
                    value="1"
                    id="use_default_background"
                    data-home-section-bg-toggle="#home_section_background_color"
                    @checked($useDefaultBg)
                >
                <label class="form-check-label" for="use_default_background">اللون الافتراضي للتطبيق</label>
            </div>
        </div>
        @error('background_color') <div class="text-danger small mt-1">{{ $message }}</div> @enderror
        <div class="form-hint">يُعرض كتدرج من الزاوية اليمنى العليا إلى اليسار السفلي.</div>
    </div>

    <div id="home-section-bg-image-wrap" @if($backgroundMode !== 'image') hidden @endif>
        <input type="file" name="background_image" accept="image/*" class="form-control form-control-sm @error('background_image') is-invalid @enderror" data-image-preview="#home-section-bg-preview">
        @error('background_image') <div class="invalid-feedback">{{ $message }}</div> @enderror
        <img id="home-section-bg-preview" src="{{ $bgImageSrc }}" alt="" class="upload-preview mt-2" style="width: 100%; max-width: 360px; height: 120px" @if(! $bgImageSrc) hidden @endif>
        <input type="url" name="background_image_url" value="{{ old('background_image_url', str_starts_with((string) $section->background_image_url, 'http') ? $section->background_image_url : '') }}" class="form-control form-control-sm mt-2 @error('background_image_url') is-invalid @enderror" placeholder="أو رابط صورة خارجي">
        @error('background_image_url') <div class="invalid-feedback">{{ $message }}</div> @enderror
        @if ($bgImageSrc)
            <div class="form-check mt-2">
                <input class="form-check-input" type="checkbox" name="remove_background_image" value="1" id="remove_background_image">
                <label class="form-check-label" for="remove_background_image">إزالة صورة الخلفية الحالية</label>
            </div>
        @endif
        <div class="form-hint">تُستخدم بدلاً من لون الخلفية عند اختيار «صورة».</div>
    </div>
</div>

<div class="card border mb-4">
    <div class="card-body">
        <div class="d-flex flex-wrap align-items-start justify-content-between gap-2 mb-3 mb-md-4">
            <div>
                <h6 class="mb-1">مظهر العرض في الرئيسية</h6>
                <p class="small text-muted mb-0">تحكّم بحجم الخط والعناصر والمسافات. القيم الافتراضية أصغر قليلاً لتناسب الشاشة.</p>
            </div>
            <button
                type="button"
                class="btn btn-outline-secondary btn-sm rounded-pill"
                data-home-section-layout-reset
                data-default-title-font-size="{{ \App\Models\HomeSection::DEFAULT_TITLE_FONT_SIZE }}"
                data-default-subtitle-font-size="{{ \App\Models\HomeSection::DEFAULT_SUBTITLE_FONT_SIZE }}"
                data-default-card-width="{{ \App\Models\HomeSection::DEFAULT_CARD_WIDTH }}"
                data-default-item-spacing="{{ \App\Models\HomeSection::DEFAULT_ITEM_SPACING }}"
                data-default-padding-top="{{ \App\Models\HomeSection::DEFAULT_PADDING_TOP }}"
                data-default-padding-bottom="{{ \App\Models\HomeSection::DEFAULT_PADDING_BOTTOM }}"
            >
                إعادة الإعدادات الافتراضية
            </button>
        </div>
        <div class="row g-3" data-home-section-layout-fields>
            <div class="col-6 col-md-3">
                <label class="form-label">حجم خط العنوان</label>
                <input type="number" min="12" max="36" name="title_font_size" value="{{ $titleFontSize }}" class="form-control form-control-sm @error('title_font_size') is-invalid @enderror" data-layout-field="title_font_size">
                @error('title_font_size') <div class="invalid-feedback">{{ $message }}</div> @enderror
            </div>
            <div class="col-6 col-md-3">
                <label class="form-label">حجم خط العنوان الفرعي</label>
                <input type="number" min="8" max="24" name="subtitle_font_size" value="{{ $subtitleFontSize }}" class="form-control form-control-sm @error('subtitle_font_size') is-invalid @enderror" data-layout-field="subtitle_font_size">
                @error('subtitle_font_size') <div class="invalid-feedback">{{ $message }}</div> @enderror
            </div>
            <div class="col-6 col-md-3">
                <label class="form-label">عرض البطاقة</label>
                <input type="number" min="80" max="220" name="card_width" value="{{ $cardWidth }}" class="form-control form-control-sm @error('card_width') is-invalid @enderror" data-layout-field="card_width">
                @error('card_width') <div class="invalid-feedback">{{ $message }}</div> @enderror
            </div>
            <div class="col-6 col-md-3">
                <label class="form-label">ارتفاع الصف</label>
                <input type="number" min="100" max="400" name="row_height" value="{{ $rowHeight }}" class="form-control form-control-sm @error('row_height') is-invalid @enderror" placeholder="تلقائي" data-layout-field="row_height">
                @error('row_height') <div class="invalid-feedback">{{ $message }}</div> @enderror
                <div class="form-hint">اتركه فارغاً ليُحسب من عرض البطاقة.</div>
            </div>
            <div class="col-6 col-md-3">
                <label class="form-label">المسافة بين البطاقات</label>
                <input type="number" min="0" max="40" name="item_spacing" value="{{ $itemSpacing }}" class="form-control form-control-sm @error('item_spacing') is-invalid @enderror" data-layout-field="item_spacing">
                @error('item_spacing') <div class="invalid-feedback">{{ $message }}</div> @enderror
            </div>
            <div class="col-6 col-md-3">
                <label class="form-label">المسافة العلوية</label>
                <input type="number" min="0" max="48" name="padding_top" value="{{ $paddingTop }}" class="form-control form-control-sm @error('padding_top') is-invalid @enderror" data-layout-field="padding_top">
                @error('padding_top') <div class="invalid-feedback">{{ $message }}</div> @enderror
            </div>
            <div class="col-6 col-md-3">
                <label class="form-label">المسافة السفلية</label>
                <input type="number" min="0" max="48" name="padding_bottom" value="{{ $paddingBottom }}" class="form-control form-control-sm @error('padding_bottom') is-invalid @enderror" data-layout-field="padding_bottom">
                @error('padding_bottom') <div class="invalid-feedback">{{ $message }}</div> @enderror
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-3 mb-3">
        <label class="form-label">{{ $strings::SORT_ORDER }}</label>
        <input type="number" min="0" name="sort_order" value="{{ old('sort_order', $section->sort_order ?? 0) }}" class="form-control form-control-sm">
    </div>
    <div class="col-md-3 mb-3 d-flex align-items-end">
        <div class="form-check mb-2">
            <input class="form-check-input" type="checkbox" name="is_active" value="1" id="is_active" @checked(old('is_active', $section->is_active ?? true))>
            <label class="form-check-label" for="is_active">{{ $strings::ACTIVE }}</label>
        </div>
    </div>
    <div class="col-md-6 mb-3 d-flex align-items-end">
        <div class="form-check mb-2">
            <input class="form-check-input" type="checkbox" name="auto_scroll_cards" value="1" id="auto_scroll_cards" @checked(old('auto_scroll_cards', $section->auto_scroll_cards ?? false))>
            <label class="form-check-label" for="auto_scroll_cards">تحريك الكروت تلقائياً</label>
            <div class="form-hint">عند التفعيل، تتحرك بطاقات المنتجات/السلات بشكل مستمر في الشريط.</div>
        </div>
    </div>
</div>

<div class="mb-3" id="home-section-products-wrap" @if($showsBundles) hidden @endif>
    <label class="form-label">المنتجات</label>
    <x-admin.product-picker
        name="product_ids[]"
        :selected="$selectedProducts ?? []"
        hint="ابحث وأضف منتجات هذا القسم دون تحميل الكتالوج كاملاً."
    />
    @error('product_ids') <div class="text-danger small mt-1">{{ $message }}</div> @enderror
</div>

<div class="mb-0" id="home-section-bundles-hint" @if(! $showsBundles) hidden @endif>
    <div class="alert alert-info mb-0">
        <p class="mb-0 small">
            بعد حفظ إعدادات القسم، أدر السلات من قسم «سلات التوفير» في أسفل هذه الصفحة.
        </p>
    </div>
</div>

<script>
(() => {
    const button = document.querySelector('[data-home-section-layout-reset]');
    if (!button || button.dataset.inlineResetBound === '1') return;
    button.dataset.inlineResetBound = '1';
    button.addEventListener('click', () => {
        const defaults = {
            title_font_size: button.getAttribute('data-default-title-font-size') || '',
            subtitle_font_size: button.getAttribute('data-default-subtitle-font-size') || '',
            card_width: button.getAttribute('data-default-card-width') || '',
            row_height: '',
            item_spacing: button.getAttribute('data-default-item-spacing') || '',
            padding_top: button.getAttribute('data-default-padding-top') || '',
            padding_bottom: button.getAttribute('data-default-padding-bottom') || '',
        };
        Object.entries(defaults).forEach(([name, value]) => {
            const input = document.querySelector(`[data-layout-field="${name}"]`);
            if (!input) return;
            input.value = value;
            input.dispatchEvent(new Event('input', { bubbles: true }));
            input.dispatchEvent(new Event('change', { bubbles: true }));
        });
    });
})();
</script>
