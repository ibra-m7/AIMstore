<x-layouts.marketing :title="$title">
    <header class="mkt-nav">
        <a class="mkt-brand" href="{{ url('/') }}">
            <img src="{{ asset('images/logo.png') }}" alt="سيتي مارت">
        </a>
        <nav class="mkt-nav-links" aria-label="روابط الصفحة">
            <a href="#home">الرئيسية</a>
            <a href="#features">المزايا</a>
            <a href="#faq">الأسئلة الشائعة</a>
        </nav>
        <a class="mkt-nav-cta" href="{{ route('admin.login') }}">{{ $strings::LANDING_CTA }}</a>
    </header>

    <main>
        <section class="mkt-hero" id="home">
            <div class="mkt-hero-badge reveal">🛒 تسوق يومي أوفر وأسهل</div>
            <h1 class="reveal delay-1">{{ $strings::LANDING_HERO_TITLE }}</h1>
            <p class="mkt-lead reveal delay-2">{{ $strings::LANDING_HERO_BODY }}</p>
            <div class="mkt-actions reveal delay-3">
                <a class="mkt-btn large" href="{{ route('admin.login') }}">{{ $strings::LANDING_CTA }}</a>
                <a class="mkt-btn ghost large" href="#features">{{ $strings::LANDING_CTA_SECONDARY }}</a>
            </div>

            <div class="mkt-hero-stage reveal delay-4">
                <div class="mkt-wave" aria-hidden="true"></div>

                <div class="mkt-float float-a">
                    <div class="mkt-float-icon"><i class="bi bi-basket2-fill"></i></div>
                    <span>كل المستلزمات اليومية!</span>
                </div>
                <div class="mkt-float float-b">
                    <div class="mkt-float-icon red"><i class="bi bi-percent"></i></div>
                    <span>عروض تناسب ميزانيتك!</span>
                </div>
                <div class="mkt-float float-c">
                    <div class="mkt-float-icon"><i class="bi bi-flower2"></i></div>
                    <span>طازج كل يوم!</span>
                </div>
                <div class="mkt-float float-d">
                    <div class="mkt-float-icon red"><i class="bi bi-lightning-charge-fill"></i></div>
                    <span>توصيل سريع لبابك!</span>
                </div>

                <div class="mkt-phone" aria-label="معاينة أقسام التطبيق">
                    <div class="mkt-phone-screen">
                        <div class="mkt-phone-bar">
                            <img src="{{ asset('images/logo.png') }}" alt="">
                            <i class="bi bi-bell" style="color:#003399"></i>
                        </div>
                        <div class="mkt-phone-search">ابحث في سيتي مارت...</div>
                        <div class="mkt-phone-grid">
                            @foreach (($exploreCategories ?? []) as $tile)
                                <a class="mkt-phone-tile" href="{{ $tile['href'] }}">
                                    <i class="bi {{ $tile['icon'] }}" aria-hidden="true"></i>{{ $tile['label'] }}
                                </a>
                            @endforeach
                        </div>
                        <div class="mkt-phone-banner">أسعار ولا في الأحلام — إلا في سيتي مارت</div>
                    </div>
                </div>
            </div>
        </section>

        <section class="mkt-section" id="features">
            <div class="mkt-section-head reveal">
                <h2>ليش سيتي مارت؟</h2>
                <p>تجربة تسوق واضحة تجمع العروض، أقل الأسعار، والأقسام الجاهزة — بدون تعقيد.</p>
            </div>
            <div class="mkt-features-grid">
                <article class="mkt-feature reveal">
                    <h3>عروض يومية واضحة 🎉</h3>
                    <p>اكتشف خصومات حقيقية على المنتجات اليومية، من عروض ١+١ إلى تخفيضات مباشرة — كلها في مكان واحد.</p>
                </article>
                <article class="mkt-feature reveal delay-1">
                    <h3>بحث وتصفّح بسيط 🔍</h3>
                    <p>ابحث عن أي منتج بسرعة، أو تصفّح الأقسام بسهولة بفضل واجهة واضحة توصّلك للي تبيه بدون لف.</p>
                </article>
                <article class="mkt-feature reveal delay-2">
                    <h3>اقتراحات تناسبك ✨</h3>
                    <p>نقترح لك منتجات تناسب احتياجك وميزانيتك، عشان تختار أسرع وبكل ثقة.</p>
                </article>
                <article class="mkt-feature reveal delay-3">
                    <h3>أسعار أوفر 💸</h3>
                    <p>شوف السعر والحجم بوضوح، وقارن بسرعة — وفر وقتك وفلوسك في كل طلب.</p>
                </article>
            </div>
        </section>

        <section class="mkt-ai reveal" id="ai">
            <h2>✨ المساعد الذكي يفهمك ✨</h2>
            <p>
                مساعد سيتي مارت الذكي يفهم طلبك فوراً، يقترح المنتجات المناسبة،
                ويبسّط تجربة التسوّق بالكامل — بشكل سريع وشخصي.
            </p>
            <a class="mkt-btn" href="{{ route('admin.login') }}">{{ $strings::LANDING_CTA }}</a>
            <div class="mkt-phones-row" aria-hidden="true">
                <div class="mkt-mini-phone"><i class="bi bi-search"></i><span>بحث ذكي</span></div>
                <div class="mkt-mini-phone"><i class="bi bi-tags"></i><span>عروض</span></div>
                <div class="mkt-mini-phone"><i class="bi bi-cart3"></i><span>سلّة</span></div>
                <div class="mkt-mini-phone"><i class="bi bi-chat-heart"></i><span>مساعد</span></div>
                <div class="mkt-mini-phone"><i class="bi bi-truck"></i><span>توصيل</span></div>
            </div>
        </section>

        <section class="mkt-section" id="faq">
            <div class="mkt-section-head reveal">
                <h2>الأسئلة الشائعة</h2>
                <p>سيتي مارت يجمع العروض وأقل الأسعار في تجربة بسيطة وواضحة.</p>
            </div>
            <div class="mkt-faq">
                <details class="mkt-faq-item reveal" open>
                    <summary>كيف تساعدني الأقسام الجاهزة أثناء التسوق؟</summary>
                    <p>نجمع لك المنتجات حسب احتياجك اليومي في أقسام واضحة، عشان تكمّل قائمتك بسرعة بدون بحث طويل.</p>
                </details>
                <details class="mkt-faq-item reveal delay-1">
                    <summary>كيف ألقى أفضل العروض في سيتي مارت؟</summary>
                    <p>العروض تظهر في الصفحة الرئيسية وأقسام التخفيضات، مع تمييز واضح للسعر قبل وبعد الخصم.</p>
                </details>
                <details class="mkt-faq-item reveal delay-2">
                    <summary>كيف يساعدني سيتي مارت أوفّر كل يوم؟</summary>
                    <p>بمقارنة أسعار واضحة، سلات توفير، وكوبونات خصم — تختار الأنسب لميزانيتك بسهولة.</p>
                </details>
                <details class="mkt-faq-item reveal delay-3">
                    <summary>ليش التسوق مع سيتي مارت أسرع وأسهل؟</summary>
                    <p>واجهة بسيطة، بحث سريع، مساعد ذكي، وتوصيل لباب البيت — كل شيء في مكان واحد.</p>
                </details>
            </div>
        </section>

        <section class="mkt-why reveal">
            <h2>أسعارنا هي أصلاً عروض 🔥</h2>
            <p>
                لأن سيتي مارت يجمع لك أفضل العروض، أقل الأسعار، والتشكيلات الجاهزة
                في تجربة واحدة بسيطة وواضحة — تسوق أسرع، وأسهل، وأوفر.
            </p>
            <a class="mkt-btn large" href="{{ route('admin.login') }}">{{ $strings::LANDING_CTA }}</a>
        </section>
    </main>

    <footer class="mkt-footer">
        <div class="mkt-footer-grid">
            <div class="mkt-footer-brand">
                <img src="{{ asset('images/logo.png') }}" alt="سيتي مارت">
                <p>
                    تطبيق مقاضي يجمع لك أقل الأسعار والعروض في تجربة بسيطة وواضحة —
                    عشان تسوّقك يكون أسرع وأوفر.
                </p>
            </div>
            <div>
                <h3>تواصل معنا</h3>
                <p><a href="mailto:support@citymart.ye">support@citymart.ye</a></p>
                <p>اليمن</p>
            </div>
            <div>
                <h3>روابط سريعة</h3>
                <p><a href="#features">المزايا</a></p>
                <p><a href="#faq">الأسئلة الشائعة</a></p>
                <p><a href="{{ route('admin.login') }}">{{ $strings::LANDING_CTA }}</a></p>
            </div>
        </div>
        <div class="mkt-footer-bottom">
            <span>© {{ date('Y') }} سيتي مارت — جميع الحقوق محفوظة.</span>
            <span>{{ $strings::APP_TAGLINE }}</span>
        </div>
    </footer>
</x-layouts.marketing>
