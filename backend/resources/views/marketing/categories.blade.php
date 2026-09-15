<x-layouts.marketing :title="$title">
    <header class="mkt-nav">
        <a class="mkt-brand" href="{{ url('/') }}">
            <img src="{{ asset('images/logo.png') }}" alt="سيتي مارت">
        </a>
        <nav class="mkt-nav-links" aria-label="روابط الصفحة">
            <a href="{{ url('/') }}#home">الرئيسية</a>
            <a href="{{ route('marketing.categories') }}">الأقسام</a>
            <a href="{{ url('/') }}#faq">الأسئلة الشائعة</a>
        </nav>
        <a class="mkt-nav-cta" href="{{ route('admin.login') }}">{{ $strings::LANDING_CTA }}</a>
    </header>

    <main class="mkt-section" style="padding-top: 6rem">
        <div class="mkt-section-head">
            <h1>{{ $title }}</h1>
            <p>تصفّح أقسام سيتي مارت واختر ما تحتاجه — التجربة الكاملة داخل التطبيق.</p>
        </div>

        @if ($categories->isEmpty())
            <p class="text-center text-muted">لا توجد أقسام متاحة حالياً.</p>
        @else
            <div class="mkt-features-grid" style="margin-bottom: 2rem">
                @foreach ($categories as $category)
                    <a
                        class="mkt-feature"
                        href="{{ route('marketing.categories', ['c' => $category->slug]) }}"
                        style="text-decoration: none; color: inherit; {{ $selected && $selected->id === $category->id ? 'outline: 2px solid var(--color-primary, #003399);' : '' }}"
                    >
                        <h3>{{ $category->name }}</h3>
                        @if ($category->description)
                            <p>{{ $category->description }}</p>
                        @else
                            <p>تصفّح منتجات {{ $category->name }} في تطبيق سيتي مارت.</p>
                        @endif
                    </a>
                @endforeach
            </div>

            @if ($selected)
                <div class="mkt-section-head">
                    <h2>{{ $selected->name }}</h2>
                    @if ($selected->description)
                        <p>{{ $selected->description }}</p>
                    @endif
                </div>
                @if ($selected->children->isNotEmpty())
                    <div class="mkt-features-grid">
                        @foreach ($selected->children as $child)
                            <article class="mkt-feature">
                                <h3>{{ $child->name }}</h3>
                                @if ($child->description)
                                    <p>{{ $child->description }}</p>
                                @else
                                    <p>متوفر في التطبيق ضمن قسم {{ $selected->name }}.</p>
                                @endif
                            </article>
                        @endforeach
                    </div>
                @else
                    <p class="text-center text-muted">لا توجد تصنيفات فرعية لهذا القسم بعد — تابع من التطبيق.</p>
                @endif
            @endif
        @endif

        <div class="text-center" style="margin-top: 2.5rem">
            <a class="mkt-btn large" href="{{ route('admin.login') }}">{{ $strings::LANDING_CTA }}</a>
            <a class="mkt-btn ghost large" href="{{ url('/') }}" style="margin-inline-start: .75rem">العودة للرئيسية</a>
        </div>
    </main>

    <footer class="mkt-footer">
        <div class="mkt-footer-bottom">
            <span>© {{ date('Y') }} سيتي مارت — جميع الحقوق محفوظة.</span>
            <span>{{ $strings::APP_TAGLINE }}</span>
        </div>
    </footer>
</x-layouts.marketing>
