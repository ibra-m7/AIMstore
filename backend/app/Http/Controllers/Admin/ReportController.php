<?php

namespace App\Http\Controllers\Admin;

use App\Enums\OrderStatus;
use App\Http\Controllers\Controller;
use App\Services\Admin\ReportExportService;
use App\Services\Admin\ReportService;
use App\Support\AppStrings;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;
use Symfony\Component\HttpFoundation\Response;

class ReportController extends Controller
{
    public function __construct(
        private readonly ReportService $reports,
        private readonly ReportExportService $exporter,
    ) {}

    public function index(Request $request): View
    {
        $period = $this->reports->resolvePeriod(
            $request->query('preset'),
            $request->query('from'),
            $request->query('to'),
        );

        $defaultTab = ($period['preset'] === 'today' || ($period['is_single_day'] ?? false))
            ? 'daily'
            : 'overview';
        $tab = $request->query('tab', $defaultTab);
        if (! isset(ReportService::TABS[$tab])) {
            $tab = $defaultTab;
        }

        $daily = $tab === 'daily' || $period['preset'] === 'today'
            ? $this->reports->dailyReport($period)
            : null;

        return view('admin.reports.index', [
            'title' => AppStrings::NAV_REPORTS,
            'period' => $period,
            'presets' => ReportService::PRESETS,
            'tabs' => ReportService::TABS,
            'tab' => $tab,
            'overview' => $this->reports->overview($period),
            'daily' => $daily,
            'exportTypes' => $this->reports->exportTypes(),
            'statuses' => OrderStatus::cases(),
            'currency' => $this->reports->currency(),
            'dataUrl' => route('admin.reports.data'),
            'exportUrl' => route('admin.reports.export'),
        ]);
    }

    public function data(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'preset' => ['nullable', 'string', Rule::in(array_keys(ReportService::PRESETS))],
            'from' => ['nullable', 'date'],
            'to' => ['nullable', 'date'],
            'section' => ['required', 'string', Rule::in([
                'daily', 'overview', 'sales', 'orders', 'products', 'customers',
                'couriers', 'inventory', 'coupons', 'reviews',
            ])],
            'q' => ['nullable', 'string', 'max:120'],
            'status' => ['nullable', 'string', Rule::enum(OrderStatus::class)],
            'sort' => ['nullable', 'string', 'max:40'],
            'dir' => ['nullable', 'string', Rule::in(['asc', 'desc'])],
            'page' => ['nullable', 'integer', 'min:1'],
            'per_page' => ['nullable', 'integer', 'min:10', 'max:100'],
        ]);

        $period = $this->reports->resolvePeriod(
            $validated['preset'] ?? null,
            $validated['from'] ?? null,
            $validated['to'] ?? null,
        );

        $section = $validated['section'];
        $payload = match ($section) {
            'daily' => $this->reports->dailyReport($period),
            'overview' => $this->reports->overview($period),
            'sales' => [
                'series' => $this->reports->salesSeries($period['from'], $period['to']),
                'status' => $this->reports->statusBreakdown($period['from'], $period['to']),
                'payments' => $this->reports->paymentBreakdown($period['from'], $period['to']),
                'methods' => $this->reports->methodBreakdown($period['from'], $period['to']),
                'kpis' => $this->reports->kpis($period['from'], $period['to']),
                'is_hourly' => $period['from']->isSameDay($period['to']),
            ],
            'orders' => [
                'table' => $this->reports->ordersTable($period['from'], $period['to'], $validated),
            ],
            'products' => [
                'items' => $this->reports->topProducts($period['from'], $period['to'], 100),
            ],
            'customers' => [
                'items' => $this->reports->topCustomers($period['from'], $period['to'], 100),
            ],
            'couriers' => [
                'items' => $this->reports->courierPerformance($period['from'], $period['to']),
            ],
            'inventory' => [
                'summary' => $this->reports->inventorySummary(),
                'items' => $this->reports->lowStock(100, 20),
            ],
            'coupons' => [
                'items' => $this->reports->couponPerformance($period['from'], $period['to']),
            ],
            'reviews' => $this->reports->reviewsSummary($period['from'], $period['to']),
        };

        return response()->json([
            'ok' => true,
            'section' => $section,
            'period' => [
                'from' => $period['from']->toDateString(),
                'to' => $period['to']->toDateString(),
                'preset' => $period['preset'],
                'label' => $period['label'],
                'is_single_day' => $period['is_single_day'],
            ],
            'currency' => $this->reports->currency(),
            'data' => $payload,
        ]);
    }

    public function export(Request $request): Response
    {
        $validated = $request->validate([
            'preset' => ['nullable', 'string', Rule::in(array_keys(ReportService::PRESETS))],
            'from' => ['nullable', 'date'],
            'to' => ['nullable', 'date'],
            'type' => ['required', 'string', Rule::in([
                'daily', 'overview', 'orders', 'sales', 'products', 'customers', 'couriers', 'inventory', 'coupons',
            ])],
            'format' => ['required', 'string', Rule::in(['xls', 'csv', 'json'])],
        ]);

        $period = $this->reports->resolvePeriod(
            $validated['preset'] ?? null,
            $validated['from'] ?? null,
            $validated['to'] ?? null,
        );

        return $this->exporter->download($validated['type'], $validated['format'], $period);
    }

    public function importPreset(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'preset' => ['nullable', 'array'],
            'preset.preset' => ['nullable', 'string', Rule::in(array_keys(ReportService::PRESETS))],
            'preset.from' => ['nullable', 'date'],
            'preset.to' => ['nullable', 'date'],
            'preset.tab' => ['nullable', 'string', Rule::in(array_keys(ReportService::TABS))],
            'preset.type' => ['nullable', 'string'],
            'file' => ['nullable', 'file', 'mimes:json,txt', 'max:512'],
        ]);

        $data = $validated['preset'] ?? null;

        if ($request->hasFile('file')) {
            $raw = json_decode((string) file_get_contents($request->file('file')->getRealPath()), true);
            if (! is_array($raw)) {
                return response()->json(['ok' => false, 'message' => 'ملف غير صالح.'], 422);
            }
            $data = $raw;
        }

        if (! is_array($data)) {
            return response()->json(['ok' => false, 'message' => 'لم يتم العثور على إعدادات.'], 422);
        }

        $period = $this->reports->resolvePeriod(
            $data['preset'] ?? null,
            $data['from'] ?? null,
            $data['to'] ?? null,
        );

        $tab = $data['tab'] ?? 'overview';
        if (! isset(ReportService::TABS[$tab])) {
            $tab = 'overview';
        }

        return response()->json([
            'ok' => true,
            'message' => 'تم استيراد إعدادات التقرير.',
            'redirect' => route('admin.reports.index', [
                'preset' => $period['preset'],
                'from' => $period['from']->toDateString(),
                'to' => $period['to']->toDateString(),
                'tab' => $tab,
            ]),
            'period' => [
                'preset' => $period['preset'],
                'from' => $period['from']->toDateString(),
                'to' => $period['to']->toDateString(),
                'label' => $period['label'],
            ],
            'tab' => $tab,
        ]);
    }
}
