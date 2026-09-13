@php
    $page = $page ?? new \App\Models\Page([
        'is_active' => true,
        'sort_order' => 0,
        'placement' => \App\Enums\PagePlacement::ProfileFooter,
    ]);
    $currentPlacement = old('placement', $page->placement?->value ?? $page->placement ?? \App\Enums\PagePlacement::ProfileFooter->value);
@endphp

<div class="mb-3">
    <label class="form-label">العنوان</label>
    <input type="text" name="title" value="{{ old('title', $page->title) }}" class="form-control @error('title') is-invalid @enderror" required>
    @error('title') <div class="invalid-feedback">{{ $message }}</div> @enderror
</div>

<div class="mb-3">
    <label class="form-label">المعرّف (slug)</label>
    <input type="text" name="slug" value="{{ old('slug', $page->slug) }}" class="form-control @error('slug') is-invalid @enderror" dir="ltr" placeholder="يُولَّد تلقائياً من العنوان إن تُرك فارغاً">
    @error('slug') <div class="invalid-feedback">{{ $message }}</div> @enderror
    <div class="form-text">مثال: privacy-policy</div>
</div>

<div class="mb-3">
    <label class="form-label">نص الزر في التطبيق</label>
    <input type="text" name="button_label" value="{{ old('button_label', $page->button_label) }}" class="form-control @error('button_label') is-invalid @enderror" placeholder="مثال: سياسة الخصوصية">
    @error('button_label') <div class="invalid-feedback">{{ $message }}</div> @enderror
    <div class="form-text">النص الذي يظهر على الزر/الرابط داخل التطبيق. إن تُرك فارغاً يُستخدم العنوان.</div>
</div>

<div class="mb-3">
    <label class="form-label">مكان الظهور في التطبيق</label>
    <select name="placement" class="form-select @error('placement') is-invalid @enderror" required>
        @foreach ($placements as $placement)
            <option value="{{ $placement->value }}" @selected($currentPlacement === $placement->value)>
                {{ $placement->label() }}
            </option>
        @endforeach
    </select>
    @error('placement') <div class="invalid-feedback">{{ $message }}</div> @enderror
</div>

<div class="mb-3">
    <label class="form-label">المحتوى</label>
    <textarea name="content" rows="14" class="form-control @error('content') is-invalid @enderror" dir="rtl">{{ old('content', $page->content) }}</textarea>
    @error('content') <div class="invalid-feedback">{{ $message }}</div> @enderror
    <div class="form-text">يمكن استخدام نص عادي أو HTML بسيط.</div>
</div>

<div class="row">
    <div class="col-md-4 mb-3">
        <label class="form-label">{{ $strings::SORT_ORDER }}</label>
        <input type="number" min="0" name="sort_order" value="{{ old('sort_order', $page->sort_order ?? 0) }}" class="form-control">
    </div>
    <div class="col-md-4 mb-3 d-flex align-items-end">
        <div class="form-check mb-2">
            <input class="form-check-input" type="checkbox" name="is_active" value="1" id="is_active" @checked(old('is_active', $page->is_active ?? true))>
            <label class="form-check-label" for="is_active">ظاهرة في التطبيق</label>
        </div>
    </div>
</div>
