<?php

namespace App\Services\Admin;

use App\Enums\OrderStatus;
use App\Enums\UserRole;
use App\Models\Coupon;
use App\Models\CouponRedemption;
use App\Models\Courier;
use App\Models\Favorite;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\Review;
use App\Models\StorePaymentMethod;
use App\Models\User;
use App\Support\AppStrings;
use Carbon\Carbon;
use Carbon\CarbonPeriod;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Cache;

class ReportService
{
    public const PRESETS = [
        'today' => 'اليوم',
        'yesterday' => 'أمس',
        '7d' => 'آخر 7 أيام',
        '30d' => 'آخر 30 يوماً',
        '90d' => 'آخر 90 يوماً',
        'month' => 'هذا الشهر',
        'last_month' => 'الشهر الماضي',
        'year' => 'هذه السنة',
        'custom' => 'مخصص',
    ];

    public const TABS = [
        'daily' => 'التقرير اليومي',
        'overview' => 'نظرة عامة',
        'sales' => 'المبيعات',
        'orders' => 'الطلبات',
        'products' => 'الأكثر مبيعاً',
        'customers' => 'العملاء المفضلون',
        'couriers' => 'الموصلون',
        'inventory' => 'المخزون',
        'coupons' => 'الكوبونات',
        'reviews' => 'التقييمات',
    ];

    /**
     * @return array{from: Carbon, to: Carbon, preset: string, previous_from: Carbon, previous_to: Carbon, label: string, is_single_day: bool}
     */
    public function resolvePeriod(?string $preset, ?string $from, ?string $to): array
    {
        $preset = $preset && isset(self::PRESETS[$preset]) ? $preset : 'today';
        $now = now()->endOfDay();

        [$start, $end] = match ($preset) {
            'today' => [now()->startOfDay(), $now],
            'yesterday' => [now()->subDay()->startOfDay(), now()->subDay()->endOfDay()],
            '7d' => [now()->subDays(6)->startOfDay(), $now],
            '30d' => [now()->subDays(29)->startOfDay(), $now],
            '90d' => [now()->subDays(89)->startOfDay(), $now],
            'month' => [now()->startOfMonth(), $now],
            'last_month' => [now()->subMonthNoOverflow()->startOfMonth(), now()->subMonthNoOverflow()->endOfMonth()],
            'year' => [now()->startOfYear(), $now],
            'custom' => [
                $this->parseDate($from)?->startOfDay() ?? now()->startOfDay(),
                $this->parseDate($to)?->endOfDay() ?? $now,
            ],
            default => [now()->startOfDay(), $now],
        };

        if ($start->greaterThan($end)) {
            [$start, $end] = [$end->copy()->startOfDay(), $start->copy()->endOfDay()];
        }

        $days = max(1, (int) $start->diffInDays($end) + 1);
        $previousTo = $start->copy()->subSecond();
        $previousFrom = $previousTo->copy()->subDays($days - 1)->startOfDay();
        $isSingleDay = $start->isSameDay($end);

        return [
            'from' => $start,
            'to' => $end,
            'preset' => $preset,
            'previous_from' => $previousFrom,
            'previous_to' => $previousTo,
            'label' => $isSingleDay
                ? $start->copy()->locale('ar')->translatedFormat('l d F Y')
                : $start->format('Y-m-d').' → '.$end->format('Y-m-d'),
            'is_single_day' => $isSingleDay,
        ];
    }

    /**
     * @param  array{from: Carbon, to: Carbon, previous_from: Carbon, previous_to: Carbon, is_single_day?: bool}  $period
     * @return array<string, mixed>
     */
    public function overview(array $period): array
    {
        $cacheKey = 'admin.reports.overview.v2.'.$period['from']->timestamp.'.'.$period['to']->timestamp;

        return Cache::remember($cacheKey, 20, function () use ($period) {
            $current = $this->kpis($period['from'], $period['to']);
            $previous = $this->kpis($period['previous_from'], $period['previous_to']);

            return [
                'kpis' => [
                    $this->kpi('إيرادات مسلّمة', $current['revenue'], $previous['revenue'], 'bi-wallet2', 'money', 'success'),
                    $this->kpi('إجمالي الطلبات', $current['orders'], $previous['orders'], 'bi-bag-check', 'number', 'info'),
                    $this->kpi('متوسط الطلب', $current['aov'], $previous['aov'], 'bi-graph-up', 'money', 'primary'),
                    $this->kpi('عملاء جدد', $current['new_customers'], $previous['new_customers'], 'bi-people', 'number', 'warning'),
                    $this->kpi('ملغاة', $current['cancelled'], $previous['cancelled'], 'bi-x-circle', 'number', 'danger'),
                    $this->kpi('نسبة الإلغاء', $current['cancel_rate'], $previous['cancel_rate'], 'bi-percent', 'percent', 'muted'),
                    $this->kpi('الخصومات', $current['discounts'], $previous['discounts'], 'bi-ticket-perforated', 'money', 'promo'),
                    $this->kpi('قطع مباعة', $current['units_sold'], $previous['units_sold'], 'bi-box-seam', 'number', 'info'),
                ],
                'series' => $this->salesSeries($period['from'], $period['to']),
                'status' => $this->statusBreakdown($period['from'], $period['to']),
                'payments' => $this->paymentBreakdown($period['from'], $period['to']),
                'methods' => $this->methodBreakdown($period['from'], $period['to']),
                'top_products' => $this->topProducts($period['from'], $period['to'], 8),
                'top_customers' => $this->topCustomers($period['from'], $period['to'], 8),
                'low_stock' => $this->lowStock(8),
                'alerts' => $this->alerts($period['from'], $period['to']),
                'is_hourly' => $period['from']->isSameDay($period['to']),
            ];
        });
    }

    /**
     * تقرير اليوم — ساعة بساعة من قاعدة البيانات.
     *
     * @param  array{from: Carbon, to: Carbon, previous_from: Carbon, previous_to: Carbon}  $period
     * @return array<string, mixed>
     */
    public function dailyReport(array $period): array
    {
        $from = $period['from']->copy()->startOfDay();
        $to = $period['to']->copy()->endOfDay();
        if (! $from->isSameDay($to)) {
            $from = now()->startOfDay();
            $to = now()->endOfDay();
        }

        $previousFrom = $from->copy()->subDay()->startOfDay();
        $previousTo = $from->copy()->subDay()->endOfDay();

        $current = $this->kpis($from, $to);
        $previous = $this->kpis($previousFrom, $previousTo);

        return [
            'date' => $from->toDateString(),
            'date_label' => $from->copy()->locale('ar')->translatedFormat('l d F Y'),
            'kpis' => [
                $this->kpi('إيرادات اليوم', $current['revenue'], $previous['revenue'], 'bi-wallet2', 'money', 'success'),
                $this->kpi('طلبات اليوم', $current['orders'], $previous['orders'], 'bi-bag-check', 'number', 'info'),
                $this->kpi('مُسلَّم اليوم', $current['delivered'], $previous['delivered'], 'bi-check2-circle', 'number', 'success'),
                $this->kpi('قطع مباعة', $current['units_sold'], $previous['units_sold'], 'bi-box-seam', 'number', 'primary'),
                $this->kpi('عملاء جدد', $current['new_customers'], $previous['new_customers'], 'bi-person-plus', 'number', 'warning'),
                $this->kpi('ملغاة', $current['cancelled'], $previous['cancelled'], 'bi-x-circle', 'number', 'danger'),
            ],
            'hourly' => $this->hourlySeries($from, $to),
            'status' => $this->statusBreakdown($from, $to),
            'payments' => $this->paymentBreakdown($from, $to),
            'methods' => $this->methodBreakdown($from, $to),
            'top_products' => $this->topProducts($from, $to, 10),
            'top_customers' => $this->topCustomers($from, $to, 10),
            'recent_orders' => $this->recentOrders($from, $to, 12),
            'compared_to' => 'مقارنة بأمس',
        ];
    }

    /**
     * @return array{revenue: float, orders: int, aov: float, new_customers: int, cancelled: int, cancel_rate: float, discounts: float, shipping: float, delivered: int, units_sold: int, gross: float}
     */
    public function kpis(Carbon $from, Carbon $to): array
    {
        $totals = Order::query()
            ->whereBetween('created_at', [$from, $to])
            ->selectRaw('COUNT(*) as orders_count')
            ->selectRaw('SUM(CASE WHEN status = ? THEN total ELSE 0 END) as revenue', [OrderStatus::Delivered->value])
            ->selectRaw('SUM(CASE WHEN status != ? THEN total ELSE 0 END) as gross', [OrderStatus::Cancelled->value])
            ->selectRaw('SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) as delivered_count', [OrderStatus::Delivered->value])
            ->selectRaw('SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) as cancelled_count', [OrderStatus::Cancelled->value])
            ->selectRaw('SUM(COALESCE(discount_amount, 0)) as discounts')
            ->selectRaw('SUM(COALESCE(shipping_fee, 0)) as shipping')
            ->first();

        $orders = (int) ($totals->orders_count ?? 0);
        $delivered = (int) ($totals->delivered_count ?? 0);
        $cancelled = (int) ($totals->cancelled_count ?? 0);
        $revenue = (float) ($totals->revenue ?? 0);
        $aov = $delivered > 0 ? round($revenue / $delivered, 2) : 0.0;

        $unitsSold = (int) OrderItem::query()
            ->join('orders', 'orders.id', '=', 'order_items.order_id')
            ->whereBetween('orders.created_at', [$from, $to])
            ->where('orders.status', '!=', OrderStatus::Cancelled->value)
            ->where(function ($q) {
                $q->where('order_items.is_gift', false)->orWhereNull('order_items.is_gift');
            })
            ->sum('order_items.quantity');

        $newCustomers = User::query()
            ->where('role', UserRole::Customer)
            ->whereBetween('created_at', [$from, $to])
            ->count();

        return [
            'revenue' => round($revenue, 2),
            'gross' => round((float) ($totals->gross ?? 0), 2),
            'orders' => $orders,
            'aov' => $aov,
            'new_customers' => $newCustomers,
            'cancelled' => $cancelled,
            'cancel_rate' => $orders > 0 ? round(($cancelled / $orders) * 100, 1) : 0.0,
            'discounts' => round((float) ($totals->discounts ?? 0), 2),
            'shipping' => round((float) ($totals->shipping ?? 0), 2),
            'delivered' => $delivered,
            'units_sold' => $unitsSold,
        ];
    }

    /**
     * @return list<array{date: string, label: string, revenue: float, orders: int, hour?: int}>
     */
    public function salesSeries(Carbon $from, Carbon $to): array
    {
        if ($from->isSameDay($to)) {
            return $this->hourlySeries($from, $to);
        }

        $rows = Order::query()
            ->whereBetween('created_at', [$from, $to])
            ->where('status', OrderStatus::Delivered)
            ->selectRaw('DATE(created_at) as day')
            ->selectRaw('SUM(total) as revenue')
            ->selectRaw('COUNT(*) as orders_count')
            ->groupBy('day')
            ->orderBy('day')
            ->get()
            ->keyBy('day');

        $series = [];
        foreach (CarbonPeriod::create($from->copy()->startOfDay(), $to->copy()->startOfDay()) as $day) {
            $key = $day->format('Y-m-d');
            $row = $rows->get($key);
            $series[] = [
                'date' => $key,
                'label' => $day->format('m/d'),
                'revenue' => round((float) ($row->revenue ?? 0), 2),
                'orders' => (int) ($row->orders_count ?? 0),
            ];
        }

        return $series;
    }

    /**
     * @return list<array{date: string, label: string, revenue: float, orders: int, hour: int}>
     */
    public function hourlySeries(Carbon $from, Carbon $to): array
    {
        $rows = Order::query()
            ->whereBetween('created_at', [$from, $to])
            ->where('status', '!=', OrderStatus::Cancelled->value)
            ->selectRaw('HOUR(created_at) as hour_slot')
            ->selectRaw('SUM(CASE WHEN status = ? THEN total ELSE 0 END) as revenue', [OrderStatus::Delivered->value])
            ->selectRaw('COUNT(*) as orders_count')
            ->groupBy('hour_slot')
            ->orderBy('hour_slot')
            ->get()
            ->keyBy(fn ($row) => (int) $row->hour_slot);

        $lastHour = ($from->isToday() && $to->isToday()) ? (int) now()->format('G') : 23;
        $series = [];
        for ($hour = 0; $hour <= $lastHour; $hour++) {
            $row = $rows->get($hour);
            $series[] = [
                'date' => $from->format('Y-m-d').' '.sprintf('%02d:00', $hour),
                'label' => sprintf('%02d:00', $hour),
                'hour' => $hour,
                'revenue' => round((float) ($row->revenue ?? 0), 2),
                'orders' => (int) ($row->orders_count ?? 0),
            ];
        }

        return $series;
    }

    /**
     * @return list<array{key: string, label: string, count: int, total: float}>
     */
    public function statusBreakdown(Carbon $from, Carbon $to): array
    {
        $rows = Order::query()
            ->whereBetween('created_at', [$from, $to])
            ->selectRaw('status, COUNT(*) as c, SUM(total) as t')
            ->groupBy('status')
            ->get()
            ->keyBy('status');

        $out = [];
        foreach (OrderStatus::cases() as $status) {
            $row = $rows->get($status->value);
            $out[] = [
                'key' => $status->value,
                'label' => $status->label(),
                'count' => (int) ($row->c ?? 0),
                'total' => round((float) ($row->t ?? 0), 2),
            ];
        }

        return $out;
    }

    /**
     * @return list<array{key: string, label: string, count: int, total: float}>
     */
    public function paymentBreakdown(Carbon $from, Carbon $to): array
    {
        $labels = StorePaymentMethod::query()->pluck('label', 'slug');

        return Order::query()
            ->whereBetween('created_at', [$from, $to])
            ->selectRaw('payment_method as bucket, COUNT(*) as orders_count, SUM(total) as revenue_total')
            ->groupBy('payment_method')
            ->orderByDesc('orders_count')
            ->get()
            ->map(function ($row) use ($labels) {
                $slug = (string) ($row->bucket ?: 'cash');

                return [
                    'key' => $slug,
                    'label' => (string) ($labels[$slug] ?? $slug),
                    'count' => (int) $row->orders_count,
                    'total' => round((float) $row->revenue_total, 2),
                ];
            })
            ->all();
    }

    /**
     * @return list<array{key: string, label: string, count: int, total: float}>
     */
    public function methodBreakdown(Carbon $from, Carbon $to): array
    {
        return Order::query()
            ->whereBetween('created_at', [$from, $to])
            ->selectRaw("COALESCE(order_method, 'delivery') as bucket, COUNT(*) as orders_count, SUM(total) as revenue_total")
            ->groupByRaw("COALESCE(order_method, 'delivery')")
            ->orderByDesc('orders_count')
            ->get()
            ->map(function ($row) {
                $key = (string) $row->bucket;

                return [
                    'key' => $key,
                    'label' => $key === 'pickup' ? 'استلام من المتجر' : 'توصيل',
                    'count' => (int) $row->orders_count,
                    'total' => round((float) $row->revenue_total, 2),
                ];
            })
            ->all();
    }

    /**
     * الأكثر مبيعاً حسب الكمية المباعة فعلياً (طلبات غير ملغاة، بدون هدايا).
     *
     * @return list<array<string, mixed>>
     */
    public function topProducts(Carbon $from, Carbon $to, int $limit = 20): array
    {
        $rows = OrderItem::query()
            ->join('orders', 'orders.id', '=', 'order_items.order_id')
            ->leftJoin('products', 'products.id', '=', 'order_items.product_id')
            ->whereBetween('orders.created_at', [$from, $to])
            ->where('orders.status', '!=', OrderStatus::Cancelled->value)
            ->where(function ($q) {
                $q->where('order_items.is_gift', false)->orWhereNull('order_items.is_gift');
            })
            ->selectRaw('order_items.product_id')
            ->selectRaw('COALESCE(MAX(products.name), MAX(order_items.product_name)) as name')
            ->selectRaw('SUM(order_items.quantity) as qty')
            ->selectRaw('SUM(order_items.line_total) as revenue')
            ->selectRaw('COUNT(DISTINCT order_items.order_id) as orders_count')
            ->groupBy('order_items.product_id')
            ->orderByDesc('qty')
            ->orderByDesc('revenue')
            ->limit($limit)
            ->get();

        return $rows->map(fn ($row, $index) => [
            'rank' => $index + 1,
            'product_id' => $row->product_id ? (int) $row->product_id : null,
            'name' => (string) $row->name,
            'qty' => (int) $row->qty,
            'revenue' => round((float) $row->revenue, 2),
            'orders' => (int) $row->orders_count,
        ])->values()->all();
    }

    /**
     * العملاء المفضلون: أعلى ولاء (عدد الطلبات ثم الإنفاق) من بيانات الطلبات الحقيقية.
     *
     * @return list<array<string, mixed>>
     */
    public function topCustomers(Carbon $from, Carbon $to, int $limit = 20): array
    {
        $rows = Order::query()
            ->whereBetween('created_at', [$from, $to])
            ->where('status', '!=', OrderStatus::Cancelled->value)
            ->whereNotNull('user_id')
            ->selectRaw('user_id')
            ->selectRaw('COUNT(*) as orders_count')
            ->selectRaw('SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) as delivered_count', [OrderStatus::Delivered->value])
            ->selectRaw('SUM(total) as spent')
            ->selectRaw('SUM(CASE WHEN status = ? THEN total ELSE 0 END) as delivered_spent', [OrderStatus::Delivered->value])
            ->selectRaw('MAX(created_at) as last_order_at')
            ->selectRaw('MIN(created_at) as first_order_at')
            ->groupBy('user_id')
            ->orderByDesc('orders_count')
            ->orderByDesc('spent')
            ->limit($limit)
            ->get();

        $userIds = $rows->pluck('user_id')->filter()->all();
        $users = User::query()
            ->whereIn('id', $userIds)
            ->get(['id', 'name', 'phone', 'created_at'])
            ->keyBy('id');

        $favorites = Favorite::query()
            ->whereIn('user_id', $userIds)
            ->selectRaw('user_id, COUNT(*) as fav_count')
            ->groupBy('user_id')
            ->pluck('fav_count', 'user_id');

        return $rows->values()->map(function ($row, $index) use ($users, $favorites) {
            $user = $users->get($row->user_id);
            $orders = (int) $row->orders_count;
            $spent = round((float) $row->spent, 2);
            $delivered = (int) $row->delivered_count;
            $favCount = (int) ($favorites[$row->user_id] ?? 0);
            // نقاط ولاء حقيقية: تكرار الشراء + الإنفاق + المفضلة
            $loyalty = ($orders * 100) + (int) round($spent / 10) + ($delivered * 25) + ($favCount * 5);

            return [
                'rank' => $index + 1,
                'user_id' => (int) $row->user_id,
                'name' => $user?->name ?? 'عميل محذوف',
                'phone' => $user?->phone,
                'orders' => $orders,
                'delivered' => $delivered,
                'spent' => $spent,
                'delivered_spent' => round((float) $row->delivered_spent, 2),
                'favorites' => $favCount,
                'loyalty' => $loyalty,
                'tier' => $this->loyaltyTier($orders, $spent),
                'last_order_at' => $row->last_order_at
                    ? Carbon::parse($row->last_order_at)->format('Y-m-d H:i')
                    : null,
                'first_order_at' => $row->first_order_at
                    ? Carbon::parse($row->first_order_at)->format('Y-m-d')
                    : null,
            ];
        })->all();
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function recentOrders(Carbon $from, Carbon $to, int $limit = 12): array
    {
        return Order::query()
            ->with(['user:id,name', 'courier:id,name'])
            ->whereBetween('created_at', [$from, $to])
            ->latest('id')
            ->limit($limit)
            ->get()
            ->map(fn (Order $order) => [
                'id' => $order->id,
                'order_number' => $order->order_number,
                'customer' => $order->shipping_name ?: $order->user?->name,
                'status' => $order->status?->value,
                'status_label' => $order->status?->label(),
                'total' => round((float) $order->total, 2),
                'payment' => $order->paymentMethodLabel(),
                'created_at' => $order->created_at?->format('H:i'),
                'edit_url' => route('admin.orders.edit', $order),
            ])
            ->all();
    }

    private function loyaltyTier(int $orders, float $spent): string
    {
        if ($orders >= 10 || $spent >= 50000) {
            return 'ذهبي';
        }
        if ($orders >= 5 || $spent >= 15000) {
            return 'فضي';
        }
        if ($orders >= 2 || $spent >= 3000) {
            return 'برونزي';
        }

        return 'جديد';
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function courierPerformance(Carbon $from, Carbon $to): array
    {
        $stats = Order::query()
            ->whereBetween('created_at', [$from, $to])
            ->whereNotNull('courier_id')
            ->selectRaw('courier_id')
            ->selectRaw('COUNT(*) as orders_count')
            ->selectRaw('SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) as delivered', [OrderStatus::Delivered->value])
            ->selectRaw('SUM(CASE WHEN status = ? THEN 1 ELSE 0 END) as cancelled', [OrderStatus::Cancelled->value])
            ->selectRaw('SUM(CASE WHEN status = ? THEN total ELSE 0 END) as revenue', [OrderStatus::Delivered->value])
            ->groupBy('courier_id')
            ->orderByDesc('delivered')
            ->get()
            ->keyBy('courier_id');

        return Courier::query()
            ->orderBy('name')
            ->get(['id', 'name', 'phone', 'is_active', 'is_online'])
            ->map(function (Courier $courier) use ($stats) {
                $row = $stats->get($courier->id);

                return [
                    'id' => $courier->id,
                    'name' => $courier->name,
                    'phone' => $courier->phoneDisplay(),
                    'is_active' => (bool) $courier->is_active,
                    'is_online' => (bool) $courier->is_online,
                    'orders' => (int) ($row->orders_count ?? 0),
                    'delivered' => (int) ($row->delivered ?? 0),
                    'cancelled' => (int) ($row->cancelled ?? 0),
                    'revenue' => round((float) ($row->revenue ?? 0), 2),
                ];
            })
            ->sortByDesc('delivered')
            ->values()
            ->all();
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function lowStock(int $limit = 20, int $threshold = 10): array
    {
        return Product::query()
            ->sellable()
            ->with('category:id,name')
            ->where('stock', '<=', $threshold)
            ->orderBy('stock')
            ->orderBy('name')
            ->limit($limit)
            ->get(['id', 'name', 'sku', 'barcode', 'stock', 'price', 'category_id', 'is_active'])
            ->map(fn (Product $p) => [
                'id' => $p->id,
                'name' => $p->name,
                'sku' => $p->sku,
                'barcode' => $p->barcode,
                'stock' => (int) $p->stock,
                'price' => round((float) $p->price, 2),
                'category' => $p->category?->name,
                'is_active' => (bool) $p->is_active,
            ])
            ->all();
    }

    /**
     * @return array{total: int, active: int, inactive: int, out_of_stock: int, low_stock: int, inventory_value: float}
     */
    public function inventorySummary(): array
    {
        $row = Product::query()
            ->sellable()
            ->selectRaw('COUNT(*) as total')
            ->selectRaw('SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) as active')
            ->selectRaw('SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END) as inactive')
            ->selectRaw('SUM(CASE WHEN stock <= 0 THEN 1 ELSE 0 END) as out_of_stock')
            ->selectRaw('SUM(CASE WHEN stock > 0 AND stock <= 10 THEN 1 ELSE 0 END) as low_stock')
            ->selectRaw('SUM(stock * price) as inventory_value')
            ->first();

        return [
            'total' => (int) ($row->total ?? 0),
            'active' => (int) ($row->active ?? 0),
            'inactive' => (int) ($row->inactive ?? 0),
            'out_of_stock' => (int) ($row->out_of_stock ?? 0),
            'low_stock' => (int) ($row->low_stock ?? 0),
            'inventory_value' => round((float) ($row->inventory_value ?? 0), 2),
        ];
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function couponPerformance(Carbon $from, Carbon $to): array
    {
        $redemptions = CouponRedemption::query()
            ->whereBetween('created_at', [$from, $to])
            ->selectRaw('coupon_id, COUNT(*) as uses, SUM(discount_amount) as discount_total')
            ->groupBy('coupon_id')
            ->get()
            ->keyBy('coupon_id');

        $orderCoupons = Order::query()
            ->whereBetween('created_at', [$from, $to])
            ->whereNotNull('coupon_id')
            ->selectRaw('coupon_id, COUNT(*) as orders_count, SUM(total) as order_total')
            ->groupBy('coupon_id')
            ->get()
            ->keyBy('coupon_id');

        return Coupon::query()
            ->orderByDesc('is_active')
            ->orderBy('code')
            ->get(['id', 'code', 'title', 'type', 'value', 'is_active', 'usage_limit'])
            ->map(function (Coupon $coupon) use ($redemptions, $orderCoupons) {
                $red = $redemptions->get($coupon->id);
                $ord = $orderCoupons->get($coupon->id);

                return [
                    'id' => $coupon->id,
                    'code' => $coupon->code,
                    'title' => $coupon->title,
                    'type' => $coupon->type?->value,
                    'value' => round((float) $coupon->value, 2),
                    'is_active' => (bool) $coupon->is_active,
                    'uses' => (int) ($red->uses ?? $ord->orders_count ?? 0),
                    'discount_total' => round((float) ($red->discount_total ?? 0), 2),
                    'order_total' => round((float) ($ord->order_total ?? 0), 2),
                ];
            })
            ->sortByDesc('uses')
            ->values()
            ->all();
    }

    /**
     * @return array{count: int, avg_rating: float, distribution: list<array{rating: int, count: int}>}
     */
    public function reviewsSummary(Carbon $from, Carbon $to): array
    {
        $base = Review::query()->whereBetween('created_at', [$from, $to]);
        $count = (clone $base)->count();
        $avg = round((float) ((clone $base)->avg('rating') ?? 0), 2);

        $dist = (clone $base)
            ->selectRaw('rating, COUNT(*) as c')
            ->groupBy('rating')
            ->pluck('c', 'rating');

        $distribution = [];
        for ($i = 5; $i >= 1; $i--) {
            $distribution[] = [
                'rating' => $i,
                'count' => (int) ($dist[$i] ?? 0),
            ];
        }

        return [
            'count' => $count,
            'avg_rating' => $avg,
            'distribution' => $distribution,
        ];
    }

    /**
     * @return list<array{type: string, icon: string, title: string, body: string}>
     */
    public function alerts(Carbon $from, Carbon $to): array
    {
        $alerts = [];

        $pending = Order::query()
            ->where('status', OrderStatus::Pending)
            ->where('created_at', '<=', now()->subHours(2))
            ->count();
        if ($pending > 0) {
            $alerts[] = [
                'type' => 'warning',
                'icon' => 'bi-hourglass-split',
                'title' => 'طلبات معلّقة',
                'body' => $pending.' طلب بانتظار التأكيد لأكثر من ساعتين.',
            ];
        }

        $out = Product::query()->sellable()->where('stock', '<=', 0)->count();
        if ($out > 0) {
            $alerts[] = [
                'type' => 'danger',
                'icon' => 'bi-box',
                'title' => 'نفاد مخزون',
                'body' => $out.' منتج بدون كمية متاحة.',
            ];
        }

        $cancelled = Order::query()
            ->whereBetween('created_at', [$from, $to])
            ->where('status', OrderStatus::Cancelled)
            ->count();
        $total = Order::query()->whereBetween('created_at', [$from, $to])->count();
        if ($total > 0 && ($cancelled / $total) >= 0.15) {
            $alerts[] = [
                'type' => 'danger',
                'icon' => 'bi-exclamation-triangle',
                'title' => 'إلغاء مرتفع',
                'body' => 'نسبة الإلغاء '.round(($cancelled / $total) * 100, 1).'% خلال الفترة.',
            ];
        }

        return $alerts;
    }

    /**
     * @param  array{q?: string, status?: string, sort?: string, dir?: string, page?: int, per_page?: int}  $filters
     */
    public function ordersTable(Carbon $from, Carbon $to, array $filters = []): LengthAwarePaginator
    {
        $sort = in_array($filters['sort'] ?? '', ['created_at', 'total', 'order_number', 'status'], true)
            ? $filters['sort']
            : 'created_at';
        $dir = ($filters['dir'] ?? 'desc') === 'asc' ? 'asc' : 'desc';
        $perPage = min(100, max(10, (int) ($filters['per_page'] ?? 25)));

        return Order::query()
            ->with(['user:id,name,phone', 'courier:id,name'])
            ->whereBetween('created_at', [$from, $to])
            ->when($filters['status'] ?? null, fn (Builder $q, $status) => $q->where('status', $status))
            ->when($filters['q'] ?? null, function (Builder $q, string $search) {
                $q->where(function (Builder $nested) use ($search) {
                    $nested->where('order_number', 'like', '%'.$search.'%')
                        ->orWhere('shipping_name', 'like', '%'.$search.'%')
                        ->orWhere('shipping_phone', 'like', '%'.$search.'%')
                        ->orWhereHas('user', fn (Builder $u) => $u->where('name', 'like', '%'.$search.'%'));
                });
            })
            ->orderBy($sort, $dir)
            ->paginate($perPage)
            ->through(fn (Order $order) => [
                'id' => $order->id,
                'order_number' => $order->order_number,
                'customer' => $order->shipping_name ?: $order->user?->name,
                'phone' => $order->shipping_phone,
                'courier' => $order->courier?->name,
                'status' => $order->status?->value,
                'status_label' => $order->status?->label(),
                'payment' => $order->paymentMethodLabel(),
                'method' => $order->orderMethodLabel(),
                'total' => round((float) $order->total, 2),
                'discount' => round((float) ($order->discount_amount ?? 0), 2),
                'created_at' => $order->created_at?->format('Y-m-d H:i'),
                'edit_url' => route('admin.orders.edit', $order),
            ]);
    }

    /**
     * @return list<array{key: string, label: string, description: string, icon: string}>
     */
    public function exportTypes(): array
    {
        return [
            ['key' => 'daily', 'label' => 'التقرير اليومي', 'description' => 'مؤشرات اليوم وساعة بساعة', 'icon' => 'bi-calendar-day'],
            ['key' => 'overview', 'label' => 'ملخص الفترة', 'description' => 'المؤشرات والرسوم البيانية كجدول', 'icon' => 'bi-speedometer2'],
            ['key' => 'orders', 'label' => 'الطلبات', 'description' => 'كل طلبات الفترة المحددة', 'icon' => 'bi-bag-check'],
            ['key' => 'sales', 'label' => 'المبيعات', 'description' => 'إيرادات وعدد الطلبات (يومي/ساعي)', 'icon' => 'bi-graph-up'],
            ['key' => 'products', 'label' => 'الأكثر مبيعاً', 'description' => 'المنتجات حسب الكمية المباعة', 'icon' => 'bi-box-seam'],
            ['key' => 'customers', 'label' => 'العملاء المفضلون', 'description' => 'الولاء والتكرار والإنفاق', 'icon' => 'bi-heart'],
            ['key' => 'couriers', 'label' => 'أداء الموصلين', 'description' => 'التسليم والإيرادات لكل موصل', 'icon' => 'bi-bicycle'],
            ['key' => 'inventory', 'label' => 'المخزون المنخفض', 'description' => 'منتجات قاربت على النفاد', 'icon' => 'bi-clipboard-data'],
            ['key' => 'coupons', 'label' => 'الكوبونات', 'description' => 'الاستخدام وقيمة الخصم', 'icon' => 'bi-ticket-perforated'],
        ];
    }

    public function currency(): string
    {
        return AppStrings::CURRENCY;
    }

    private function parseDate(?string $value): ?Carbon
    {
        if ($value === null || trim($value) === '') {
            return null;
        }

        try {
            return Carbon::parse($value);
        } catch (\Throwable) {
            return null;
        }
    }

    /**
     * @return array{label: string, value: float|int, previous: float|int, delta: float|null, delta_label: string, icon: string, format: string, tone: string}
     */
    private function kpi(string $label, float|int $value, float|int $previous, string $icon, string $format, string $tone): array
    {
        $delta = null;
        $deltaLabel = '—';
        if ((float) $previous != 0.0) {
            $delta = round((((float) $value - (float) $previous) / abs((float) $previous)) * 100, 1);
            $deltaLabel = ($delta > 0 ? '+' : '').$delta.'%';
        } elseif ((float) $value > 0) {
            $delta = 100.0;
            $deltaLabel = '+100%';
        }

        return [
            'label' => $label,
            'value' => $value,
            'previous' => $previous,
            'delta' => $delta,
            'delta_label' => $deltaLabel,
            'icon' => $icon,
            'format' => $format,
            'tone' => $tone,
        ];
    }
}
