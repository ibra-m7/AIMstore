@php
    $value = $kpi['value'];
    $formatted = match ($kpi['format']) {
        'money' => number_format((float) $value, 2).' '.$currency,
        'percent' => number_format((float) $value, 1).'%',
        default => number_format((float) $value),
    };
    $delta = $kpi['delta'];
    $deltaClass = $delta === null ? 'is-flat' : ($delta >= 0 ? 'is-up' : 'is-down');
@endphp
<div class="col-6 col-md-4 col-xl-3">
    <div class="reports-kpi reports-kpi--{{ $kpi['tone'] }}">
        <div class="reports-kpi__icon"><i class="bi {{ $kpi['icon'] }}"></i></div>
        <div class="reports-kpi__body">
            <div class="reports-kpi__label">{{ $kpi['label'] }}</div>
            <div class="reports-kpi__value">{{ $formatted }}</div>
            <div class="reports-kpi__delta {{ $deltaClass }}">
                <i class="bi {{ $delta === null ? 'bi-dash' : ($delta >= 0 ? 'bi-arrow-up-short' : 'bi-arrow-down-short') }}"></i>
                {{ $kpi['delta_label'] }}
                <span>مقابل الفترة السابقة</span>
            </div>
        </div>
    </div>
</div>
