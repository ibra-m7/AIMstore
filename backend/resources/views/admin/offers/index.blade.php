<x-layouts.admin :title="$title">
    <x-admin.page-head
        :title="$title"
        :create="route('admin.offers.create', ['type' => $type->value])"
        :create-label="$type->addLabel()"
    />

    <div class="alert alert-light border mb-3">
        <strong>الفرق بين الخصومات والعروض</strong>
        <p class="mb-0 small text-muted">
            <strong>الخصومات:</strong> تخفيضات دائمة أو روتينية — تظهر في شريط «خصومات اليوم» بالتطبيق بشارة حمراء.
            <strong>العروض:</strong> حملات ترويجية خاصة — تظهر في شريط «عروض خاصة» بشارة برتقالية وفي سلايدر الترويج.
            لا يمكن للمنتج أن يكون عليه النوعان معاً.
        </p>
    </div>

    <div class="page-card p-3 mb-3">
        @php
            $bannerEnabled = $type === \App\Enums\PromoType::Offer
                ? ($showOffersAsBanner ?? true)
                : ($showDiscountsAsBanner ?? true);
            $bannerTitle = $type === \App\Enums\PromoType::Offer
                ? 'إظهار العروض كبنر في الرئيسية'
                : 'إظهار الخصومات كبنر في الرئيسية';
            $bannerHint = $type === \App\Enums\PromoType::Offer
                ? 'عند التفعيل تظهر منتجات العروض في بنر الرئيسية وشريط «عروض خاصة». عند الإيقاف تُخفى من البنر فقط وتبقى أسعارها المخفّضة على المنتج.'
                : 'عند التفعيل تظهر منتجات الخصم في بنر الرئيسية وشريط «خصومات اليوم». عند الإيقاف تُخفى من البنر فقط وتبقى أسعارها المخفّضة على المنتج.';
            $bannerInputId = $type === \App\Enums\PromoType::Offer
                ? 'show_offers_as_banner'
                : 'show_discounts_as_banner';
        @endphp
        <form method="POST" action="{{ route('admin.offers.banner-visibility') }}" class="promo-banner-toggle">
            @csrf
            @method('PUT')
            <input type="hidden" name="type" value="{{ $type->value }}">
            <input type="hidden" name="enabled" value="0">
            <div class="form-check form-switch mb-0">
                <input
                    class="form-check-input"
                    type="checkbox"
                    role="switch"
                    id="{{ $bannerInputId }}"
                    name="enabled"
                    value="1"
                    @checked($bannerEnabled)
                    onchange="this.form.requestSubmit()"
                >
                <label class="form-check-label" for="{{ $bannerInputId }}">
                    <strong>{{ $bannerTitle }}</strong>
                    <span class="d-block small text-muted">{{ $bannerHint }}</span>
                </label>
            </div>
        </form>
    </div>

    <div class="promo-tabs">
        @foreach (\App\Enums\PromoType::cases() as $tab)
            <a href="{{ route('admin.offers.index', ['type' => $tab->value]) }}" class="promo-tab {{ $type === $tab ? 'is-active' : '' }}">
                <i class="bi {{ $tab === \App\Enums\PromoType::Discount ? 'bi-percent' : 'bi-tag' }}"></i>
                {{ $tab->plural() }}
                <span class="promo-tab-count">{{ $counts[$tab->value] ?? 0 }}</span>
            </a>
        @endforeach
    </div>

    <form method="GET" class="d-flex flex-wrap gap-2 mb-3">
        <input type="hidden" name="type" value="{{ $type->value }}">
        <input type="text" name="q" value="{{ $filters['q'] ?? '' }}" class="form-control" style="max-width: 260px" placeholder="ابحث في {{ $type->plural() }}...">
        <button class="btn btn-outline-success rounded-pill">{{ $strings::FILTER }}</button>
    </form>

    <div class="page-card p-4" data-promo-bulk>
        @if ($offers->isEmpty())
            <x-admin.empty-state icon="bi-percent" :action="route('admin.offers.create', ['type' => $type->value])" :action-label="$type->addLabel()" />
        @else
            <div class="promo-bulk-bar mb-3">
                <div class="promo-bulk-bar__hint text-muted small">
                    حدّد منتجات ثم ألغِ {{ $type->label() }}، أو ألغِ الكل دفعة واحدة.
                </div>
                <div class="d-flex flex-wrap gap-2">
                    <form method="POST" action="{{ route('admin.offers.bulk-clear') }}" id="promo-selected-form" class="d-inline">
                        @csrf
                        <input type="hidden" name="type" value="{{ $type->value }}">
                        <input type="hidden" name="scope" value="selected">
                        <button
                            type="submit"
                            class="btn btn-sm btn-outline-danger rounded-pill"
                            data-promo-bulk-selected
                            disabled
                            onclick="return confirm('سيتم إلغاء {{ $type->label() }} عن المنتجات المحددة فقط. هل أنت متأكد؟')"
                        >
                            إلغاء المحدد
                        </button>
                    </form>
                    <form method="POST" action="{{ route('admin.offers.bulk-clear') }}" class="d-inline" onsubmit="return confirm('سيتم إلغاء {{ $type->label() }} عن كل {{ $type->plural() }} ({{ $counts[$type->value] ?? 0 }}). هل أنت متأكد؟')">
                        @csrf
                        <input type="hidden" name="type" value="{{ $type->value }}">
                        <input type="hidden" name="scope" value="all">
                        <button type="submit" class="btn btn-sm btn-danger rounded-pill">
                            إلغاء كل {{ $type->plural() }}
                        </button>
                    </form>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th style="width: 2.5rem">
                                <input
                                    type="checkbox"
                                    class="form-check-input"
                                    data-promo-select-all
                                    aria-label="تحديد الكل في هذه الصفحة"
                                >
                            </th>
                            <th></th>
                            <th>النوع</th>
                            <th>المنتج</th>
                            <th>السعر الأصلي</th>
                            <th>بعد التخفيض</th>
                            <th>النسبة</th>
                            <th>{{ $strings::ACTIONS }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($offers as $product)
                            <tr>
                                <td>
                                    <input
                                        type="checkbox"
                                        class="form-check-input"
                                        name="product_ids[]"
                                        value="{{ $product->id }}"
                                        form="promo-selected-form"
                                        data-promo-select
                                        aria-label="تحديد {{ $product->name }}"
                                    >
                                </td>
                                <td>
                                    @if ($product->primaryImage?->url)
                                        <img src="{{ \App\Support\Media::url($product->primaryImage->url) }}" alt="" class="table-thumb">
                                    @endif
                                </td>
                                <td>
                                    <span class="badge {{ $type === \App\Enums\PromoType::Offer ? 'bg-warning-subtle text-warning-emphasis' : 'bg-danger-subtle text-danger-emphasis' }}">
                                        {{ $type->label() }}
                                    </span>
                                </td>
                                <td>
                                    <div class="fw-bold">{{ $product->name }}</div>
                                    <div class="text-muted small">{{ $product->category?->name }}</div>
                                </td>
                                <td>{{ number_format((float) $product->price, 2) }} {{ $strings::CURRENCY }}</td>
                                <td class="fw-bold">{{ number_format((float) $product->discount_price, 2) }} {{ $strings::CURRENCY }}</td>
                                <td><span class="badge badge-sale">{{ $product->discount_percent }}%</span></td>
                                <td>
                                    <div class="d-flex gap-2">
                                        <a href="{{ route('admin.offers.edit', $product) }}" class="btn btn-sm btn-outline-success rounded-pill">{{ $strings::EDIT }}</a>
                                        <form method="POST" action="{{ route('admin.offers.destroy', $product) }}" onsubmit="return confirm('سيتم إلغاء {{ $type->label() }} عن هذا المنتج فقط.')">
                                            @csrf
                                            @method('DELETE')
                                            <button class="btn btn-sm btn-outline-danger rounded-pill">إلغاء {{ $type->label() }}</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            {{ $offers->links() }}
        @endif
    </div>
</x-layouts.admin>
