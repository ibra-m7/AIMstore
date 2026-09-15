<x-layouts.admin :title="$title">
    @php
        $from = $period['from']->format('Y-m-d');
        $to = $period['to']->format('Y-m-d');
        $overviewJson = [
            'kpis' => $overview['kpis'],
            'series' => $overview['series'],
            'status' => $overview['status'],
            'payments' => $overview['payments'],
            'methods' => $overview['methods'],
            'top_products' => $overview['top_products'],
            'top_customers' => $overview['top_customers'],
            'low_stock' => $overview['low_stock'],
            'alerts' => $overview['alerts'],
            'is_hourly' => $overview['is_hourly'] ?? false,
        ];
        $dailyJson = $daily ?? null;
    @endphp

    <div
        class="reports-hub"
        id="reportsHub"
        data-tab="{{ $tab }}"
        data-preset="{{ $period['preset'] }}"
        data-from="{{ $from }}"
        data-to="{{ $to }}"
        data-currency="{{ $currency }}"
        data-data-url="{{ $dataUrl }}"
        data-export-url="{{ $exportUrl }}"
        data-import-url="{{ route('admin.reports.import-preset') }}"
        data-overview='@json($overviewJson)'
        @if ($dailyJson) data-daily='@json($dailyJson)' @endif
    >
        <div class="reports-toolbar page-card p-3 p-md-4 mb-3">
            <div class="d-flex flex-wrap align-items-start justify-content-between gap-3">
                <div>
                    <h1 class="page-head-title mb-1">{{ $title }}</h1>
                    <p class="page-head-sub mb-0">بيانات حية من المتجر · تقرير يومي · الأكثر مبيعاً · العملاء المفضلون</p>
                </div>
                <div class="d-flex flex-wrap gap-2">
                    <a href="{{ route('admin.reports.index', ['preset' => 'today', 'tab' => 'daily']) }}" class="btn {{ $period['preset'] === 'today' ? 'btn-brand' : 'btn-outline-success' }} rounded-pill">
                        <i class="bi bi-calendar-day ms-1"></i> تقرير اليوم
                    </a>
                    <button type="button" class="btn btn-outline-success rounded-pill" data-bs-toggle="modal" data-bs-target="#reportExportModal">
                        <i class="bi bi-download ms-1"></i> تصدير
                    </button>
                    <button type="button" class="btn btn-outline-success rounded-pill" data-bs-toggle="modal" data-bs-target="#reportImportModal">
                        <i class="bi bi-upload ms-1"></i> استيراد إعدادات
                    </button>
                    <button type="button" class="btn btn-outline-secondary rounded-pill" data-report-print>
                        <i class="bi bi-printer ms-1"></i> طباعة
                    </button>
                    <button type="button" class="btn btn-outline-secondary rounded-pill" data-report-refresh>
                        <i class="bi bi-arrow-clockwise ms-1"></i> تحديث
                    </button>
                </div>
            </div>

            <form method="GET" action="{{ route('admin.reports.index') }}" class="reports-filters mt-3" data-report-filters>
                {{-- Intentionally omit tab so period presets pick the server default (daily vs overview). --}}
                <div class="reports-presets" role="tablist" aria-label="الفترة">
                    @foreach ($presets as $key => $label)
                        @if ($key !== 'custom')
                            <button
                                type="submit"
                                name="preset"
                                value="{{ $key }}"
                                class="reports-preset {{ $period['preset'] === $key ? 'is-active' : '' }}"
                            >{{ $label }}</button>
                        @endif
                    @endforeach
                </div>
                <div class="d-flex flex-wrap gap-2 align-items-end mt-3">
                    <div>
                        <label class="form-label small mb-1">من</label>
                        <input type="date" name="from" value="{{ $from }}" class="form-control" style="min-width: 150px">
                    </div>
                    <div>
                        <label class="form-label small mb-1">إلى</label>
                        <input type="date" name="to" value="{{ $to }}" class="form-control" style="min-width: 150px">
                    </div>
                    <button type="submit" name="preset" value="custom" class="btn btn-outline-success rounded-pill">
                        تطبيق الفترة
                    </button>
                    <span class="text-muted small ms-auto" data-report-period-label>{{ $period['label'] }}</span>
                </div>
            </form>
        </div>

        @if (! empty($overview['alerts']))
            <div class="reports-alerts mb-3">
                @foreach ($overview['alerts'] as $alert)
                    <div class="reports-alert reports-alert--{{ $alert['type'] }}">
                        <i class="bi {{ $alert['icon'] }}"></i>
                        <div>
                            <strong>{{ $alert['title'] }}</strong>
                            <span>{{ $alert['body'] }}</span>
                        </div>
                    </div>
                @endforeach
            </div>
        @endif

        <div class="reports-tabs page-card p-2 mb-3" role="tablist">
            @foreach ($tabs as $key => $label)
                <button
                    type="button"
                    class="reports-tab {{ $tab === $key ? 'is-active' : '' }}"
                    data-report-tab="{{ $key }}"
                    role="tab"
                    aria-selected="{{ $tab === $key ? 'true' : 'false' }}"
                >{{ $label }}</button>
            @endforeach
        </div>

        <div class="reports-loading" data-report-loading hidden>
            <div class="reports-loading-bar"></div>
            <span>جاري تحديث التقرير…</span>
        </div>

        <div class="reports-panels" data-report-panels>
            {{-- Daily --}}
            <section class="reports-panel {{ $tab === 'daily' ? 'is-active' : '' }}" data-report-panel="daily" @if ($tab !== 'daily') hidden @endif>
                <div class="reports-daily-banner page-card p-3 px-4 mb-3">
                    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2">
                        <div>
                            <div class="small text-muted fw-bold">التقرير اليومي · بيانات حقيقية</div>
                            <div class="h5 fw-bold mb-0" data-report-daily-date>{{ $daily['date_label'] ?? $period['label'] }}</div>
                        </div>
                        <span class="badge text-bg-light" data-report-daily-compare>{{ $daily['compared_to'] ?? 'مقارنة بأمس' }}</span>
                    </div>
                </div>
                <div class="row g-3 mb-3" data-report-daily-kpis>
                    @foreach (($daily['kpis'] ?? []) as $kpi)
                        @include('admin.reports._kpi', ['kpi' => $kpi, 'currency' => $currency])
                    @endforeach
                </div>
                <div class="row g-3 mb-3">
                    <div class="col-xl-8">
                        <div class="page-card p-4 h-100">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h2 class="h6 fw-bold mb-0">أداء الساعات</h2>
                                <span class="small text-muted">طلبات وإيرادات لكل ساعة</span>
                            </div>
                            <div class="reports-chart reports-chart--lg" data-report-hourly-chart></div>
                        </div>
                    </div>
                    <div class="col-xl-4">
                        <div class="page-card p-4 h-100">
                            <h2 class="h6 fw-bold mb-3">حالات طلبات اليوم</h2>
                            <div data-report-daily-status></div>
                        </div>
                    </div>
                </div>
                <div class="row g-3 mb-3">
                    <div class="col-lg-6">
                        <div class="page-card p-4 h-100">
                            <h2 class="h6 fw-bold mb-3">الأكثر مبيعاً اليوم</h2>
                            <div class="table-responsive">
                                <table class="table table-sm align-middle mb-0">
                                    <thead><tr><th>#</th><th>المنتج</th><th>الكمية</th><th>الإيراد</th></tr></thead>
                                    <tbody data-report-daily-products>
                                        @forelse (($daily['top_products'] ?? []) as $row)
                                            <tr>
                                                <td class="text-muted">{{ $row['rank'] ?? $loop->iteration }}</td>
                                                <td class="fw-semibold">{{ $row['name'] }}</td>
                                                <td>{{ number_format($row['qty']) }}</td>
                                                <td>{{ number_format($row['revenue'], 2) }} {{ $currency }}</td>
                                            </tr>
                                        @empty
                                            <tr><td colspan="4" class="text-muted">لا مبيعات مسجّلة اليوم بعد.</td></tr>
                                        @endforelse
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="page-card p-4 h-100">
                            <h2 class="h6 fw-bold mb-3">عملاء اليوم المفضلون</h2>
                            <div class="table-responsive">
                                <table class="table table-sm align-middle mb-0">
                                    <thead><tr><th>#</th><th>العميل</th><th>الطلبات</th><th>الإنفاق</th></tr></thead>
                                    <tbody data-report-daily-customers>
                                        @forelse (($daily['top_customers'] ?? []) as $row)
                                            <tr>
                                                <td class="text-muted">{{ $row['rank'] ?? $loop->iteration }}</td>
                                                <td>
                                                    <div class="fw-semibold">{{ $row['name'] }}</div>
                                                    <small class="text-muted">{{ $row['tier'] ?? '' }} · {{ $row['phone'] }}</small>
                                                </td>
                                                <td>{{ number_format($row['orders']) }}</td>
                                                <td>{{ number_format($row['spent'], 2) }} {{ $currency }}</td>
                                            </tr>
                                        @empty
                                            <tr><td colspan="4" class="text-muted">لا طلبات عملاء اليوم بعد.</td></tr>
                                        @endforelse
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="page-card p-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h2 class="h6 fw-bold mb-0">آخر طلبات اليوم</h2>
                        <button type="button" class="btn btn-sm btn-link" data-report-tab="orders">كل الطلبات</button>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-sm align-middle mb-0">
                            <thead><tr><th>الطلب</th><th>العميل</th><th>الحالة</th><th>الإجمالي</th><th>الوقت</th><th></th></tr></thead>
                            <tbody data-report-daily-orders>
                                @forelse (($daily['recent_orders'] ?? []) as $row)
                                    <tr>
                                        <td class="fw-semibold">{{ $row['order_number'] }}</td>
                                        <td>{{ $row['customer'] }}</td>
                                        <td><span class="badge text-bg-light">{{ $row['status_label'] }}</span></td>
                                        <td>{{ number_format($row['total'], 2) }} {{ $currency }}</td>
                                        <td>{{ $row['created_at'] }}</td>
                                        <td><a class="btn btn-sm btn-outline-success rounded-pill" href="{{ $row['edit_url'] }}">فتح</a></td>
                                    </tr>
                                @empty
                                    <tr><td colspan="6" class="text-muted text-center py-3">لا طلبات لهذا اليوم.</td></tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>

            {{-- Overview --}}
            <section class="reports-panel {{ $tab === 'overview' ? 'is-active' : '' }}" data-report-panel="overview" @if ($tab !== 'overview') hidden @endif>
                <div class="row g-3 mb-3" data-report-kpis>
                    @foreach ($overview['kpis'] as $kpi)
                        @include('admin.reports._kpi', ['kpi' => $kpi, 'currency' => $currency])
                    @endforeach
                </div>

                <div class="row g-3 mb-3">
                    <div class="col-xl-8">
                        <div class="page-card p-4 h-100">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h2 class="h6 fw-bold mb-0">منحنى الإيرادات</h2>
                                <span class="small text-muted" data-report-series-label>{{ ($overview['is_hourly'] ?? false) ? 'ساعي' : 'يومي' }}</span>
                            </div>
                            <div class="reports-chart" data-report-sales-chart></div>
                        </div>
                    </div>
                    <div class="col-xl-4">
                        <div class="page-card p-4 h-100">
                            <h2 class="h6 fw-bold mb-3">توزيع الحالات</h2>
                            <div data-report-status-bars></div>
                        </div>
                    </div>
                </div>

                <div class="row g-3">
                    <div class="col-lg-6">
                        <div class="page-card p-4 h-100">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h2 class="h6 fw-bold mb-0">الأكثر مبيعاً</h2>
                                <button type="button" class="btn btn-sm btn-link" data-report-tab="products">عرض الكل</button>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-sm align-middle mb-0">
                                    <thead><tr><th>#</th><th>المنتج</th><th>الكمية</th><th>الإيراد</th></tr></thead>
                                    <tbody data-report-top-products>
                                        @forelse ($overview['top_products'] as $row)
                                            <tr>
                                                <td class="text-muted">{{ $row['rank'] ?? $loop->iteration }}</td>
                                                <td class="fw-semibold">{{ $row['name'] }}</td>
                                                <td>{{ number_format($row['qty']) }}</td>
                                                <td>{{ number_format($row['revenue'], 2) }} {{ $currency }}</td>
                                            </tr>
                                        @empty
                                            <tr><td colspan="4" class="text-muted">لا بيانات في هذه الفترة.</td></tr>
                                        @endforelse
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="page-card p-4 h-100">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h2 class="h6 fw-bold mb-0">العملاء المفضلون</h2>
                                <button type="button" class="btn btn-sm btn-link" data-report-tab="customers">عرض الكل</button>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-sm align-middle mb-0">
                                    <thead><tr><th>#</th><th>العميل</th><th>الطلبات</th><th>الإنفاق</th></tr></thead>
                                    <tbody data-report-top-customers>
                                        @forelse ($overview['top_customers'] as $row)
                                            <tr>
                                                <td class="text-muted">{{ $row['rank'] ?? $loop->iteration }}</td>
                                                <td>
                                                    <div class="fw-semibold">{{ $row['name'] }}</div>
                                                    <small class="text-muted">{{ $row['tier'] ?? '' }} · {{ $row['phone'] }}</small>
                                                </td>
                                                <td>{{ number_format($row['orders']) }}</td>
                                                <td>{{ number_format($row['spent'], 2) }} {{ $currency }}</td>
                                            </tr>
                                        @empty
                                            <tr><td colspan="4" class="text-muted">لا بيانات في هذه الفترة.</td></tr>
                                        @endforelse
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {{-- Sales --}}
            <section class="reports-panel {{ $tab === 'sales' ? 'is-active' : '' }}" data-report-panel="sales" hidden>
                <div class="row g-3">
                    <div class="col-xl-8">
                        <div class="page-card p-4">
                            <h2 class="h6 fw-bold mb-3">المبيعات اليومية</h2>
                            <div class="reports-chart reports-chart--lg" data-report-sales-chart-full></div>
                            <div class="table-responsive mt-3">
                                <table class="table table-sm align-middle" data-report-sortable>
                                    <thead>
                                        <tr>
                                            <th data-sort="date">التاريخ</th>
                                            <th data-sort="revenue">الإيرادات</th>
                                            <th data-sort="orders">الطلبات</th>
                                        </tr>
                                    </thead>
                                    <tbody data-report-sales-rows></tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-4">
                        <div class="page-card p-4 mb-3">
                            <h2 class="h6 fw-bold mb-3">طرق الدفع</h2>
                            <div data-report-payment-bars></div>
                        </div>
                        <div class="page-card p-4">
                            <h2 class="h6 fw-bold mb-3">طريقة الاستلام</h2>
                            <div data-report-method-bars></div>
                        </div>
                    </div>
                </div>
            </section>

            {{-- Orders --}}
            <section class="reports-panel {{ $tab === 'orders' ? 'is-active' : '' }}" data-report-panel="orders" hidden>
                <div class="page-card p-4">
                    <div class="d-flex flex-wrap gap-2 mb-3">
                        <input type="search" class="form-control" style="max-width: 260px" placeholder="بحث برقم الطلب أو العميل" data-report-orders-q>
                        <select class="form-select" style="max-width: 200px" data-report-orders-status>
                            <option value="">كل الحالات</option>
                            @foreach ($statuses as $status)
                                <option value="{{ $status->value }}">{{ $status->label() }}</option>
                            @endforeach
                        </select>
                        <select class="form-select" style="max-width: 140px" data-report-orders-per-page>
                            <option value="25">25 / صفحة</option>
                            <option value="50">50 / صفحة</option>
                            <option value="100">100 / صفحة</option>
                        </select>
                    </div>
                    <div class="table-responsive">
                        <table class="table align-middle" data-report-orders-table>
                            <thead>
                                <tr>
                                    <th><button type="button" class="reports-sort" data-orders-sort="order_number">الطلب</button></th>
                                    <th>العميل</th>
                                    <th>الموصل</th>
                                    <th><button type="button" class="reports-sort" data-orders-sort="status">الحالة</button></th>
                                    <th>الدفع</th>
                                    <th><button type="button" class="reports-sort is-active" data-orders-sort="total" data-dir="desc">الإجمالي</button></th>
                                    <th><button type="button" class="reports-sort" data-orders-sort="created_at">التاريخ</button></th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody data-report-orders-rows>
                                <tr><td colspan="8" class="text-muted text-center py-4">اختر تبويب الطلبات لتحميل البيانات.</td></tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mt-3" data-report-orders-pager></div>
                </div>
            </section>

            {{-- Products --}}
            <section class="reports-panel {{ $tab === 'products' ? 'is-active' : '' }}" data-report-panel="products" hidden>
                <div class="page-card p-4">
                    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
                        <div>
                            <h2 class="h6 fw-bold mb-0">الأكثر مبيعاً</h2>
                            <p class="small text-muted mb-0">مرتّب حسب الكمية المباعة من الطلبات غير الملغاة</p>
                        </div>
                        <input type="search" class="form-control" style="max-width: 280px" placeholder="تصفية المنتجات…" data-client-filter="products">
                    </div>
                    <div class="table-responsive">
                        <table class="table align-middle" data-report-sortable data-client-table="products">
                            <thead>
                                <tr>
                                    <th data-sort="rank">#</th>
                                    <th data-sort="name">المنتج</th>
                                    <th data-sort="qty">الكمية المباعة</th>
                                    <th data-sort="revenue">الإيرادات</th>
                                    <th data-sort="orders">الطلبات</th>
                                </tr>
                            </thead>
                            <tbody data-report-products-rows></tbody>
                        </table>
                    </div>
                </div>
            </section>

            {{-- Customers --}}
            <section class="reports-panel {{ $tab === 'customers' ? 'is-active' : '' }}" data-report-panel="customers" hidden>
                <div class="page-card p-4">
                    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
                        <div>
                            <h2 class="h6 fw-bold mb-0">العملاء المفضلون</h2>
                            <p class="small text-muted mb-0">حسب تكرار الطلبات ثم الإنفاق · مستويات ولاء من البيانات الحقيقية</p>
                        </div>
                        <input type="search" class="form-control" style="max-width: 280px" placeholder="تصفية العملاء…" data-client-filter="customers">
                    </div>
                    <div class="table-responsive">
                        <table class="table align-middle" data-report-sortable data-client-table="customers">
                            <thead>
                                <tr>
                                    <th data-sort="rank">#</th>
                                    <th data-sort="name">العميل</th>
                                    <th data-sort="phone">الجوال</th>
                                    <th data-sort="orders">الطلبات</th>
                                    <th data-sort="delivered">مُسلَّم</th>
                                    <th data-sort="spent">الإنفاق</th>
                                    <th data-sort="loyalty">الولاء</th>
                                    <th data-sort="tier">المستوى</th>
                                    <th data-sort="last_order_at">آخر طلب</th>
                                </tr>
                            </thead>
                            <tbody data-report-customers-rows></tbody>
                        </table>
                    </div>
                </div>
            </section>

            {{-- Couriers --}}
            <section class="reports-panel {{ $tab === 'couriers' ? 'is-active' : '' }}" data-report-panel="couriers" hidden>
                <div class="page-card p-4">
                    <div class="table-responsive">
                        <table class="table align-middle" data-report-sortable data-client-table="couriers">
                            <thead>
                                <tr>
                                    <th data-sort="name">الموصل</th>
                                    <th data-sort="orders">الطلبات</th>
                                    <th data-sort="delivered">مُسلَّم</th>
                                    <th data-sort="cancelled">ملغي</th>
                                    <th data-sort="revenue">الإيرادات</th>
                                    <th>الحالة</th>
                                </tr>
                            </thead>
                            <tbody data-report-couriers-rows></tbody>
                        </table>
                    </div>
                </div>
            </section>

            {{-- Inventory --}}
            <section class="reports-panel {{ $tab === 'inventory' ? 'is-active' : '' }}" data-report-panel="inventory" hidden>
                <div class="row g-3 mb-3" data-report-inventory-kpis></div>
                <div class="page-card p-4">
                    <div class="d-flex flex-wrap gap-2 mb-3">
                        <input type="search" class="form-control" style="max-width: 280px" placeholder="تصفية المخزون…" data-client-filter="inventory">
                    </div>
                    <div class="table-responsive">
                        <table class="table align-middle" data-report-sortable data-client-table="inventory">
                            <thead>
                                <tr>
                                    <th data-sort="name">المنتج</th>
                                    <th data-sort="category">القسم</th>
                                    <th data-sort="stock">المخزون</th>
                                    <th data-sort="price">السعر</th>
                                    <th>الحالة</th>
                                </tr>
                            </thead>
                            <tbody data-report-inventory-rows></tbody>
                        </table>
                    </div>
                </div>
            </section>

            {{-- Coupons --}}
            <section class="reports-panel {{ $tab === 'coupons' ? 'is-active' : '' }}" data-report-panel="coupons" hidden>
                <div class="page-card p-4">
                    <div class="table-responsive">
                        <table class="table align-middle" data-report-sortable data-client-table="coupons">
                            <thead>
                                <tr>
                                    <th data-sort="code">الكود</th>
                                    <th data-sort="title">العنوان</th>
                                    <th data-sort="uses">الاستخدام</th>
                                    <th data-sort="discount_total">خصم إجمالي</th>
                                    <th data-sort="order_total">مبيعات مرتبطة</th>
                                    <th>نشط</th>
                                </tr>
                            </thead>
                            <tbody data-report-coupons-rows></tbody>
                        </table>
                    </div>
                </div>
            </section>

            {{-- Reviews --}}
            <section class="reports-panel {{ $tab === 'reviews' ? 'is-active' : '' }}" data-report-panel="reviews" hidden>
                <div class="row g-3">
                    <div class="col-md-4">
                        <div class="page-card p-4 h-100 text-center">
                            <div class="text-muted small">متوسط التقييم</div>
                            <div class="display-5 fw-bold" style="color: var(--color-dark-text)" data-report-reviews-avg>—</div>
                            <div class="text-muted" data-report-reviews-count></div>
                        </div>
                    </div>
                    <div class="col-md-8">
                        <div class="page-card p-4 h-100">
                            <h2 class="h6 fw-bold mb-3">توزيع النجوم</h2>
                            <div data-report-reviews-bars></div>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </div>

    {{-- Export modal --}}
    <div class="modal fade" id="reportExportModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content border-0 rounded-4">
                <div class="modal-header border-0 pb-0">
                    <h2 class="modal-title h5 fw-bold">تصدير التقرير</h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="إغلاق"></button>
                </div>
                <div class="modal-body">
                    <p class="text-muted small">اختر نوع التقرير والصيغة. التصدير يستخدم نفس الفترة المحددة حالياً.</p>
                    <div class="row g-3">
                        @foreach ($exportTypes as $type)
                            <div class="col-md-6">
                                <label class="reports-export-card">
                                    <input type="radio" name="export_type" value="{{ $type['key'] }}" {{ $loop->first ? 'checked' : '' }}>
                                    <span>
                                        <i class="bi {{ $type['icon'] }}"></i>
                                        <strong>{{ $type['label'] }}</strong>
                                        <small>{{ $type['description'] }}</small>
                                    </span>
                                </label>
                            </div>
                        @endforeach
                    </div>
                    <div class="d-flex flex-wrap gap-2 mt-4">
                        <button type="button" class="btn btn-brand rounded-pill" data-report-export="xls">
                            <i class="bi bi-file-earmark-excel ms-1"></i> Excel
                        </button>
                        <button type="button" class="btn btn-outline-success rounded-pill" data-report-export="csv">
                            <i class="bi bi-filetype-csv ms-1"></i> CSV
                        </button>
                        <button type="button" class="btn btn-outline-secondary rounded-pill" data-report-export="json">
                            <i class="bi bi-filetype-json ms-1"></i> JSON
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- Import preset modal --}}
    <div class="modal fade" id="reportImportModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 rounded-4">
                <div class="modal-header border-0 pb-0">
                    <h2 class="modal-title h5 fw-bold">استيراد إعدادات التقرير</h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="إغلاق"></button>
                </div>
                <form class="modal-body" data-report-import-form enctype="multipart/form-data">
                    <p class="text-muted small">ارفع ملف JSON محفوظ مسبقاً (فترة + تبويب) لتطبيق الإعدادات فوراً.</p>
                    <div class="mb-3">
                        <label class="form-label">ملف الإعدادات (.json)</label>
                        <input type="file" name="file" accept=".json,application/json,text/plain" class="form-control" required>
                    </div>
                    <div class="d-flex flex-wrap gap-2">
                        <button type="submit" class="btn btn-brand rounded-pill">
                            <i class="bi bi-upload ms-1"></i> استيراد وتطبيق
                        </button>
                        <button type="button" class="btn btn-outline-secondary rounded-pill" data-report-save-preset>
                            <i class="bi bi-download ms-1"></i> حفظ الإعدادات الحالية
                        </button>
                    </div>
                    <div class="small text-danger mt-2" data-report-import-error hidden></div>
                </form>
            </div>
        </div>
    </div>
</x-layouts.admin>
