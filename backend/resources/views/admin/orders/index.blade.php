<x-layouts.admin :title="$title">
    <x-admin.page-head
        :title="$title"
        subtitle="حدّث الحالة، أو عدّل منتجات أي طلب قبل التسليم"
    />
    <form method="GET" class="d-flex flex-wrap gap-2 mb-3">
        <input type="text" name="q" value="{{ $filters['q'] ?? '' }}" class="form-control" style="max-width: 240px" placeholder="رقم الطلب أو العميل">
        <select name="status" class="form-select" style="max-width: 180px">
            <option value="">{{ $strings::STATUS }}</option>
            @foreach ($statuses as $status)
                <option value="{{ $status->value }}" @selected(($filters['status'] ?? '') === $status->value)>{{ $status->label() }}</option>
            @endforeach
        </select>
        <button class="btn btn-outline-success rounded-pill">{{ $strings::FILTER }}</button>
    </form>
    <div class="page-card p-4">
        @if ($orders->isEmpty())
            <x-admin.empty-state icon="bi-bag-check" />
        @else
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>الطلب</th>
                            <th>العميل</th>
                            <th>{{ $strings::COURIER }}</th>
                            <th>الموقع</th>
                            <th>الدفع</th>
                            <th>الإجمالي</th>
                            <th>{{ $strings::STATUS }}</th>
                            <th>تحديث</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($orders as $order)
                            @php
                                $orderDetail = [
                                    'title' => $order->order_number,
                                    'badges' => array_values(array_filter([
                                        $order->status?->label(),
                                        $order->paymentMethodLabel(),
                                        $order->payment_status?->label(),
                                    ])),
                                    'fields' => array_values(array_filter([
                                        ['label' => 'العميل', 'value' => $order->user?->name],
                                        ['label' => 'الجوال', 'value' => $order->shipping_phone],
                                        ['label' => $strings::COURIER, 'value' => $order->courier
                                            ? $order->courier->name.($order->courier->phoneDisplay() ? ' — '.$order->courier->phoneDisplay() : '')
                                            : ($order->status === \App\Enums\OrderStatus::Preparing || $order->status === \App\Enums\OrderStatus::Pending ? $strings::WAITING_COURIER : null)],
                                        ['label' => 'المدينة', 'value' => $order->shipping_city],
                                        array_filter([
                                            'label' => 'العنوان',
                                            'value' => $order->shipping_details ?: $order->address?->displayLine(),
                                            'map_url' => $order->mapsUrl(),
                                        ]),
                                        ['label' => 'المنتجات', 'value' => number_format((float) $order->subtotal, 2).' '.$strings::CURRENCY],
                                        ['label' => 'التوصيل', 'value' => $order->has_free_shipping ? 'مجاني' : number_format((float) $order->shipping_fee, 2).' '.$strings::CURRENCY],
                                        ['label' => 'الإجمالي', 'value' => number_format((float) $order->total, 2).' '.$strings::CURRENCY],
                                        ['label' => 'الملاحظات', 'value' => $order->notes],
                                        ['label' => 'الكوبون', 'value' => $order->coupon_code],
                                        ['label' => 'طريقة الاستلام', 'value' => $order->orderMethodLabel()],
                                        ['label' => $order->isPickup() ? 'فترة التجهيز' : 'وقت التنفيذ', 'value' => $order->fulfillment_type === 'scheduled'
                                            ? 'مجدول'.($order->scheduled_at ? ' — '.$order->scheduled_at->format('Y-m-d H:i') : '')
                                            : 'الآن'],
                                        ['label' => 'سبب الإلغاء', 'value' => $order->status === \App\Enums\OrderStatus::Cancelled ? $order->cancel_reason : null],
                                        ['label' => 'التاريخ', 'value' => $order->created_at?->format('Y-m-d H:i')],
                                    ], fn ($row) => filled($row['value'] ?? null))),
                                    'blocks' => [[
                                        'label' => 'المنتجات',
                                        'list' => $order->items->map(fn ($item) => $item->product_name.' × '.$item->quantity)->all(),
                                    ]],
                                ];
                            @endphp
                            <tr>
                                <td>
                                    <button type="button" class="entity-open" data-detail='@json($orderDetail)'>
                                        <span class="entity-open-text">
                                            <strong>{{ $order->order_number }}</strong>
                                            <small>{{ $order->created_at?->format('Y-m-d H:i') }}</small>
                                            <span class="badge {{ $order->isPickup() ? 'text-bg-info' : 'text-bg-secondary' }} mt-1">{{ $order->orderMethodLabel() }}</span>
                                        </span>
                                    </button>
                                </td>
                                <td>{{ $order->shipping_name ?: $order->user?->name }}</td>
                                <td>
                                    @php
                                        $otherCouriers = $availableCouriers
                                            ->filter(fn ($courier) => (int) $courier->id !== (int) $order->courier_id)
                                            ->values();
                                        $canChangeCourier = $order->status !== \App\Enums\OrderStatus::Delivered
                                            && $order->status !== \App\Enums\OrderStatus::Cancelled;
                                    @endphp
                                    @if ($order->courier)
                                        <div class="fw-bold">{{ $order->courier->name }}</div>
                                        <small class="text-muted d-block">{{ $order->courier->phoneDisplay() }}</small>
                                    @elseif ($canChangeCourier)
                                        <div class="text-muted mb-1">{{ $strings::WAITING_COURIER }}</div>
                                    @else
                                        <span class="text-muted">—</span>
                                    @endif
                                    @if ($canChangeCourier)
                                        <form method="POST" action="{{ route('admin.orders.courier', $order) }}" class="mt-1">
                                            @csrf
                                            @method('PATCH')
                                            <select name="courier_id" class="form-select form-select-sm" style="min-width: 150px" @if ($otherCouriers->isNotEmpty()) onchange="this.form.requestSubmit()" @endif>
                                                <option value="" selected disabled>{{ $strings::CHANGE_COURIER }}</option>
                                                @forelse ($otherCouriers as $courier)
                                                    <option value="{{ $courier->id }}">
                                                        {{ $courier->name }}@if ($courier->is_online) · {{ $strings::COURIER_AVAILABLE }}@endif
                                                    </option>
                                                @empty
                                                    <option value="" disabled>{{ $strings::NO_AVAILABLE_COURIERS }}</option>
                                                @endforelse
                                            </select>
                                        </form>
                                    @endif
                                </td>
                                <td>
                                    @if ($order->mapsUrl())
                                        <a class="map-link" href="{{ $order->mapsUrl() }}" target="_blank" rel="noopener noreferrer">
                                            <i class="bi bi-geo-alt-fill"></i>
                                            <span>موقع العميل</span>
                                        </a>
                                    @else
                                        <span class="text-muted">بدون موقع</span>
                                    @endif
                                </td>
                                <td>
                                    <div class="fw-bold">{{ $order->paymentMethodLabel() }}</div>
                                    <small class="text-muted">{{ $order->payment_status?->label() }}</small>
                                </td>
                                <td class="fw-bold">{{ number_format((float) $order->total, 2) }} {{ $strings::CURRENCY }}</td>
                                <td><span class="badge badge-soft">{{ $order->status?->label() }}</span></td>
                                <td>
                                    <form method="POST" action="{{ route('admin.orders.update', $order) }}" class="d-flex flex-column gap-1 order-status-form">
                                        @csrf
                                        @method('PATCH')
                                        <div class="d-flex flex-wrap gap-1 align-items-center">
                                            <select
                                                name="status"
                                                class="form-select form-select-sm js-order-status"
                                                style="min-width: 140px"
                                                data-was-cancelled="{{ $order->status === \App\Enums\OrderStatus::Cancelled ? '1' : '0' }}"
                                            >
                                                @foreach ($statuses as $status)
                                                    <option value="{{ $status->value }}" @selected($order->status === $status)>{{ $status->label() }}</option>
                                                @endforeach
                                            </select>
                                            <select name="payment_status" class="form-select form-select-sm" style="min-width: 120px">
                                                @foreach ($paymentStatuses as $pay)
                                                    <option value="{{ $pay->value }}" @selected($order->payment_status === $pay)>{{ $pay->label() }}</option>
                                                @endforeach
                                            </select>
                                            <button class="btn btn-sm btn-brand">حفظ</button>
                                            @if ($order->status?->value !== 'cancelled')
                                                <a href="{{ route('admin.orders.edit', $order) }}" class="btn btn-sm btn-outline-success rounded-pill">{{ $strings::EDIT }}</a>
                                            @endif
                                        </div>
                                        <input
                                            type="text"
                                            name="cancel_reason"
                                            class="form-control form-control-sm js-cancel-reason"
                                            style="max-width: 280px; {{ $order->status === \App\Enums\OrderStatus::Cancelled ? '' : 'display:none;' }}"
                                            placeholder="سبب الإلغاء"
                                            maxlength="250"
                                            value="{{ old('cancel_reason', $order->cancel_reason) }}"
                                            @if ($order->status !== \App\Enums\OrderStatus::Cancelled) disabled @endif
                                            @if ($order->status !== \App\Enums\OrderStatus::Cancelled) aria-hidden="true" @endif
                                        >
                                    </form>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            {{ $orders->links() }}
        @endif
    </div>

    <script>
        (function () {
            function syncCancelReason(select) {
                const form = select.closest('.order-status-form');
                if (!form) return;
                const input = form.querySelector('.js-cancel-reason');
                if (!input) return;
                const isCancelled = select.value === 'cancelled';
                input.style.display = isCancelled ? '' : 'none';
                input.disabled = !isCancelled;
                input.setAttribute('aria-hidden', isCancelled ? 'false' : 'true');
                if (isCancelled && select.dataset.wasCancelled !== '1') {
                    input.required = true;
                } else {
                    input.required = false;
                }
            }

            document.querySelectorAll('.js-order-status').forEach((select) => {
                syncCancelReason(select);
                select.addEventListener('change', () => syncCancelReason(select));
            });
        })();
    </script>
</x-layouts.admin>
