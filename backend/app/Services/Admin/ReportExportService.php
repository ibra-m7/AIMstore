<?php

namespace App\Services\Admin;

use App\Enums\OrderStatus;
use App\Models\Order;
use App\Models\Product;
use App\Support\AppStrings;
use App\Support\Excel\SpreadsheetXml;
use Carbon\Carbon;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportExportService
{
    public function __construct(private readonly ReportService $reports) {}

    /**
     * @param  array{from: Carbon, to: Carbon}  $period
     */
    public function download(string $type, string $format, array $period): Response|StreamedResponse
    {
        $payload = $this->payload($type, $period);
        $stamp = $period['from']->format('Ymd').'-'.$period['to']->format('Ymd');
        $base = 'تقرير-'.$type.'-'.$stamp;

        return match ($format) {
            'json' => response()->streamDownload(
                function () use ($payload) {
                    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
                },
                $base.'.json',
                ['Content-Type' => 'application/json; charset=UTF-8'],
            ),
            'csv' => $this->csvDownload($payload['sheets'][0] ?? ['name' => 'تقرير', 'headers' => [], 'rows' => []], $base.'.csv'),
            default => response(
                SpreadsheetXml::document(
                    $this->toXmlSheets($payload['sheets']),
                    [
                        'Header' => '<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:ReadingOrder="RightToLeft" ss:WrapText="1"/><Font ss:Bold="1" ss:Color="#002266" ss:Size="11"/><Interior ss:Color="#E8EEF8" ss:Pattern="Solid"/>',
                    ],
                ),
                200,
                [
                    'Content-Type' => 'application/vnd.ms-excel; charset=UTF-8',
                    'Content-Disposition' => 'attachment; filename="report.xls"; filename*=UTF-8\'\''.rawurlencode($base.'.xls'),
                ],
            ),
        };
    }

    /**
     * @param  array{from: Carbon, to: Carbon}  $period
     * @return array{meta: array<string, mixed>, sheets: list<array{name: string, headers: list<string>, rows: list<list<string|int|float|null>>}>}
     */
    public function payload(string $type, array $period): array
    {
        $meta = [
            'type' => $type,
            'generated_at' => now()->toIso8601String(),
            'from' => $period['from']->toDateString(),
            'to' => $period['to']->toDateString(),
            'currency' => AppStrings::CURRENCY_NAME,
            'app' => AppStrings::APP_NAME,
        ];

        $sheets = match ($type) {
            'daily' => $this->dailySheets($period['from'], $period['to']),
            'orders' => [$this->ordersSheet($period['from'], $period['to'])],
            'sales' => [$this->salesSheet($period['from'], $period['to'])],
            'products' => [$this->productsSheet($period['from'], $period['to'])],
            'customers' => [$this->customersSheet($period['from'], $period['to'])],
            'couriers' => [$this->couriersSheet($period['from'], $period['to'])],
            'inventory' => [$this->inventorySheet()],
            'coupons' => [$this->couponsSheet($period['from'], $period['to'])],
            default => $this->overviewSheets($period['from'], $period['to']),
        };

        return ['meta' => $meta, 'sheets' => $sheets];
    }

    /**
     * @return list<array{name: string, headers: list<string>, rows: list<list<string|int|float|null>>}>
     */
    private function dailySheets(Carbon $from, Carbon $to): array
    {
        $dayFrom = $from->copy()->startOfDay();
        $dayTo = $from->copy()->endOfDay();
        $kpis = $this->reports->kpis($dayFrom, $dayTo);

        return [
            [
                'name' => 'ملخص اليوم',
                'headers' => ['المؤشر', 'القيمة'],
                'rows' => [
                    ['التاريخ', $dayFrom->toDateString()],
                    ['إيرادات مسلّمة', $kpis['revenue']],
                    ['إجمالي الطلبات', $kpis['orders']],
                    ['مُسلَّم', $kpis['delivered']],
                    ['قطع مباعة', $kpis['units_sold']],
                    ['عملاء جدد', $kpis['new_customers']],
                    ['ملغاة', $kpis['cancelled']],
                ],
            ],
            [
                'name' => 'ساعات اليوم',
                'headers' => ['الساعة', 'الإيرادات', 'الطلبات'],
                'rows' => array_map(
                    fn ($row) => [$row['label'], $row['revenue'], $row['orders']],
                    $this->reports->hourlySeries($dayFrom, $dayTo),
                ),
            ],
            $this->productsSheet($dayFrom, $dayTo),
            $this->customersSheet($dayFrom, $dayTo),
        ];
    }

    /**
     * @return list<array{name: string, headers: list<string>, rows: list<list<string|int|float|null>>}>
     */
    private function overviewSheets(Carbon $from, Carbon $to): array
    {
        $kpis = $this->reports->kpis($from, $to);
        $status = $this->reports->statusBreakdown($from, $to);

        return [
            [
                'name' => 'الملخص',
                'headers' => ['المؤشر', 'القيمة'],
                'rows' => [
                    ['الإيرادات (مسلّم)', $kpis['revenue']],
                    ['عدد الطلبات', $kpis['orders']],
                    ['الطلبات المسلّمة', $kpis['delivered']],
                    ['قطع مباعة', $kpis['units_sold']],
                    ['متوسط قيمة الطلب', $kpis['aov']],
                    ['عملاء جدد', $kpis['new_customers']],
                    ['طلبات ملغاة', $kpis['cancelled']],
                    ['نسبة الإلغاء %', $kpis['cancel_rate']],
                    ['إجمالي الخصومات', $kpis['discounts']],
                ],
            ],
            [
                'name' => 'الحالات',
                'headers' => ['الحالة', 'العدد', 'الإجمالي'],
                'rows' => array_map(fn ($r) => [$r['label'], $r['count'], $r['total']], $status),
            ],
            $this->salesSheet($from, $to),
            $this->productsSheet($from, $to),
        ];
    }

    /**
     * @return array{name: string, headers: list<string>, rows: list<list<string|int|float|null>>}
     */
    private function ordersSheet(Carbon $from, Carbon $to): array
    {
        $rows = [];
        Order::query()
            ->with(['user:id,name', 'courier:id,name'])
            ->whereBetween('created_at', [$from, $to])
            ->orderByDesc('id')
            ->lazy(200)
            ->each(function (Order $order) use (&$rows) {
                $rows[] = [
                    $order->order_number,
                    $order->shipping_name ?: $order->user?->name,
                    $order->shipping_phone,
                    $order->courier?->name,
                    $order->status?->label(),
                    $order->paymentMethodLabel(),
                    $order->orderMethodLabel(),
                    round((float) $order->subtotal, 2),
                    round((float) ($order->discount_amount ?? 0), 2),
                    round((float) $order->shipping_fee, 2),
                    round((float) $order->total, 2),
                    $order->coupon_code,
                    $order->created_at?->format('Y-m-d H:i'),
                ];
            });

        return [
            'name' => 'الطلبات',
            'headers' => [
                'رقم الطلب', 'العميل', 'الجوال', 'الموصل', 'الحالة', 'الدفع',
                'الاستلام', 'المنتجات', 'الخصم', 'التوصيل', 'الإجمالي', 'كوبون', 'التاريخ',
            ],
            'rows' => $rows,
        ];
    }

    /**
     * @return array{name: string, headers: list<string>, rows: list<list<string|int|float|null>>}
     */
    private function salesSheet(Carbon $from, Carbon $to): array
    {
        return [
            'name' => 'المبيعات اليومية',
            'headers' => ['التاريخ', 'الإيرادات', 'الطلبات'],
            'rows' => array_map(
                fn ($row) => [$row['date'], $row['revenue'], $row['orders']],
                $this->reports->salesSeries($from, $to),
            ),
        ];
    }

    /**
     * @return array{name: string, headers: list<string>, rows: list<list<string|int|float|null>>}
     */
    private function productsSheet(Carbon $from, Carbon $to): array
    {
        return [
            'name' => 'الأكثر مبيعاً',
            'headers' => ['الترتيب', 'المنتج', 'الكمية المباعة', 'الإيرادات', 'الطلبات'],
            'rows' => array_map(
                fn ($row) => [$row['rank'] ?? '', $row['name'], $row['qty'], $row['revenue'], $row['orders']],
                $this->reports->topProducts($from, $to, 500),
            ),
        ];
    }

    /**
     * @return array{name: string, headers: list<string>, rows: list<list<string|int|float|null>>}
     */
    private function customersSheet(Carbon $from, Carbon $to): array
    {
        return [
            'name' => 'العملاء المفضلون',
            'headers' => ['الترتيب', 'العميل', 'الجوال', 'الطلبات', 'مُسلَّم', 'الإنفاق', 'المفضلة', 'الولاء', 'المستوى', 'آخر طلب'],
            'rows' => array_map(
                fn ($row) => [
                    $row['rank'] ?? '',
                    $row['name'],
                    $row['phone'],
                    $row['orders'],
                    $row['delivered'] ?? 0,
                    $row['spent'],
                    $row['favorites'] ?? 0,
                    $row['loyalty'] ?? 0,
                    $row['tier'] ?? '',
                    $row['last_order_at'],
                ],
                $this->reports->topCustomers($from, $to, 500),
            ),
        ];
    }

    /**
     * @return array{name: string, headers: list<string>, rows: list<list<string|int|float|null>>}
     */
    private function couriersSheet(Carbon $from, Carbon $to): array
    {
        return [
            'name' => 'الموصلون',
            'headers' => ['الموصل', 'الجوال', 'الطلبات', 'مُسلَّم', 'ملغي', 'الإيرادات', 'نشط', 'متصل'],
            'rows' => array_map(
                fn ($row) => [
                    $row['name'], $row['phone'], $row['orders'], $row['delivered'], $row['cancelled'],
                    $row['revenue'], $row['is_active'] ? 'نعم' : 'لا', $row['is_online'] ? 'نعم' : 'لا',
                ],
                $this->reports->courierPerformance($from, $to),
            ),
        ];
    }

    /**
     * @return array{name: string, headers: list<string>, rows: list<list<string|int|float|null>>}
     */
    private function inventorySheet(): array
    {
        $summary = $this->reports->inventorySummary();
        $low = $this->reports->lowStock(500, 20);

        return [
            'name' => 'المخزون',
            'headers' => ['المنتج', 'القسم', 'SKU', 'الباركود', 'المخزون', 'السعر', 'نشط'],
            'rows' => array_merge(
                [
                    ['— ملخص —', '', '', '', '', '', ''],
                    ['إجمالي المنتجات', $summary['total'], '', '', '', '', ''],
                    ['نشط', $summary['active'], '', '', '', '', ''],
                    ['نفد', $summary['out_of_stock'], '', '', '', '', ''],
                    ['منخفض', $summary['low_stock'], '', '', '', '', ''],
                    ['قيمة المخزون', $summary['inventory_value'], '', '', '', '', ''],
                    ['', '', '', '', '', '', ''],
                ],
                array_map(
                    fn ($row) => [
                        $row['name'], $row['category'], $row['sku'], $row['barcode'],
                        $row['stock'], $row['price'], $row['is_active'] ? 'نعم' : 'لا',
                    ],
                    $low,
                ),
            ),
        ];
    }

    /**
     * @return array{name: string, headers: list<string>, rows: list<list<string|int|float|null>>}
     */
    private function couponsSheet(Carbon $from, Carbon $to): array
    {
        return [
            'name' => 'الكوبونات',
            'headers' => ['الكود', 'العنوان', 'النوع', 'القيمة', 'الاستخدام', 'خصم إجمالي', 'مبيعات مرتبطة', 'نشط'],
            'rows' => array_map(
                fn ($row) => [
                    $row['code'], $row['title'], $row['type'], $row['value'],
                    $row['uses'], $row['discount_total'], $row['order_total'],
                    $row['is_active'] ? 'نعم' : 'لا',
                ],
                $this->reports->couponPerformance($from, $to),
            ),
        ];
    }

    /**
     * @param  list<array{name: string, headers: list<string>, rows: list<list<string|int|float|null>>}>  $sheets
     * @return list<array{name: string, freeze: bool, widths: list<int>, rows: list<list<array{value: string, style?: string, type?: string}>>}>
     */
    private function toXmlSheets(array $sheets): array
    {
        $out = [];
        foreach ($sheets as $sheet) {
            $header = array_map(
                fn ($h) => ['value' => (string) $h, 'style' => 'Header'],
                $sheet['headers'],
            );
            $rows = [$header];
            foreach ($sheet['rows'] as $row) {
                $rows[] = array_map(function ($cell) {
                    $value = $cell === null ? '' : (string) $cell;
                    $isNum = is_int($cell) || is_float($cell) || (is_string($cell) && is_numeric($cell) && $cell !== '');

                    return [
                        'value' => $value,
                        'type' => $isNum ? 'Number' : 'String',
                    ];
                }, $row);
            }
            $out[] = [
                'name' => mb_substr($sheet['name'], 0, 31),
                'freeze' => true,
                'widths' => array_fill(0, max(1, count($sheet['headers'])), 120),
                'rows' => $rows,
            ];
        }

        return $out;
    }

    /**
     * @param  array{name: string, headers: list<string>, rows: list<list<string|int|float|null>>}  $sheet
     */
    private function csvDownload(array $sheet, string $filename): StreamedResponse
    {
        return response()->streamDownload(function () use ($sheet) {
            $out = fopen('php://output', 'w');
            fwrite($out, "\xEF\xBB\xBF");
            fputcsv($out, $sheet['headers']);
            foreach ($sheet['rows'] as $row) {
                fputcsv($out, array_map(fn ($v) => $v === null ? '' : (string) $v, $row));
            }
            fclose($out);
        }, $filename, [
            'Content-Type' => 'text/csv; charset=UTF-8',
        ]);
    }
}
