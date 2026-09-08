<x-layouts.admin :title="$title">
    <x-admin.page-head
        :title="$title"
        subtitle="آخر محادثات العملاء والزوار مع المساعد"
    />

    <div class="d-flex flex-wrap gap-2 mb-3">
        <a href="{{ route('admin.ai.index') }}" class="btn btn-outline-secondary rounded-pill">
            <i class="bi bi-sliders ms-1"></i>
            إعدادات المساعد
        </a>
    </div>

    <form method="GET" class="page-card p-3 mb-3">
        <div class="row g-2 align-items-end">
            <div class="col-md-5">
                <label class="form-label">بحث</label>
                <input type="text" name="q" value="{{ $q }}" class="form-control" placeholder="رقم المحادثة / اسم / جوال / ضيف">
            </div>
            <div class="col-md-3">
                <label class="form-label">النوع</label>
                <select name="audience" class="form-select">
                    <option value="all" @selected($audience === 'all')>الكل</option>
                    <option value="customers" @selected($audience === 'customers')>عملاء</option>
                    <option value="guests" @selected($audience === 'guests')>زوار</option>
                </select>
            </div>
            <div class="col-md-4 d-flex gap-2">
                <button class="btn btn-brand">تصفية</button>
                <a href="{{ route('admin.ai.conversations') }}" class="btn btn-outline-secondary">إعادة</a>
            </div>
        </div>
    </form>

    <div class="page-card p-4">
        @if ($conversations->isEmpty())
            <x-admin.empty-state icon="bi-stars" />
        @else
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>العميل</th>
                            <th>آخر رسالة</th>
                            <th>الرسائل</th>
                            <th>التاريخ</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($conversations as $conversation)
                            @php
                                $last = $conversation->messages->first();
                            @endphp
                            <tr>
                                <td>
                                    <a href="{{ route('admin.ai.conversations.show', $conversation) }}">{{ $conversation->id }}</a>
                                </td>
                                <td>
                                    @if ($conversation->user)
                                        {{ $conversation->user->name }}
                                    @else
                                        <span class="text-muted">زائر</span>
                                        @if ($conversation->guest_token)
                                            <div class="small text-muted">{{ \Illuminate\Support\Str::limit($conversation->guest_token, 10) }}</div>
                                        @endif
                                    @endif
                                </td>
                                <td>{{ \Illuminate\Support\Str::limit($last?->content, 70) ?: '—' }}</td>
                                <td><span class="badge badge-soft">{{ $conversation->messages_count }}</span></td>
                                <td>{{ $conversation->updated_at?->format('Y-m-d H:i') }}</td>
                                <td class="text-end">
                                    <form method="POST" action="{{ route('admin.ai.conversations.destroy', $conversation) }}" onsubmit="return confirm('حذف هذه المحادثة؟');">
                                        @csrf
                                        @method('DELETE')
                                        <button class="btn btn-sm btn-outline-danger rounded-pill">حذف</button>
                                    </form>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            {{ $conversations->links() }}
        @endif
    </div>
</x-layouts.admin>
