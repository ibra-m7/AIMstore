@props(['title' => null])

<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <meta name="theme-color" content="#001133">
    <title>{{ $title ?? $strings::ADMIN_PANEL }} — {{ $strings::APP_NAME }}</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;800&display=swap" rel="stylesheet">
    @vite(['resources/js/admin.js'])
</head>
<body>
    <div class="admin-progress" id="adminProgress" hidden aria-hidden="true">
        <div class="admin-progress-bar" data-admin-progress-bar></div>
    </div>
    <div class="admin-shell d-flex" id="adminShell">
        <aside class="admin-sidebar d-flex flex-column" id="adminSidebar">
            <div class="sidebar-brand">
                <img src="{{ asset('images/logo.png') }}" alt="{{ $strings::APP_NAME }}" class="sidebar-logo">
                <div class="brand-text">
                    <strong>{{ $strings::APP_NAME }}</strong>
                    <span>{{ $strings::APP_TAGLINE }}</span>
                </div>
                <button type="button" class="sidebar-close" data-sidebar-close aria-label="إغلاق القائمة">
                    <i class="bi bi-x-lg"></i>
                </button>
            </div>

            <nav class="sidebar-nav flex-grow-1">
                @foreach ($adminMenu as $group)
                    @if (! empty($group['title']))
                        <div class="nav-section">{{ $group['title'] }}</div>
                    @endif
                    @foreach ($group['items'] as $item)
                        @if (! empty($item['children']))
                            @php
                                $currentTab = request()->query('tab', 'app');
                                $groupActive = false;
                                foreach ($item['children'] as $child) {
                                    $childTab = $child['params']['tab'] ?? null;
                                    if (request()->routeIs($child['route']) && ($childTab === null || $currentTab === $childTab)) {
                                        $groupActive = true;
                                        break;
                                    }
                                }
                                if (! $groupActive && request()->routeIs($item['route'])) {
                                    $groupActive = true;
                                }
                            @endphp
                            <div class="nav-group {{ $groupActive ? 'is-open is-active' : '' }}" data-nav-group>
                                <button type="button"
                                        class="nav-link nav-group-toggle {{ $groupActive ? 'is-parent-active' : '' }}"
                                        data-nav-group-toggle
                                        title="{{ $item['label'] }}"
                                        aria-expanded="{{ $groupActive ? 'true' : 'false' }}">
                                    <i class="bi {{ $item['icon'] }}"></i>
                                    <span>{{ $item['label'] }}</span>
                                    <i class="bi bi-chevron-down nav-group-caret" aria-hidden="true"></i>
                                </button>
                                <div class="nav-submenu" data-nav-submenu>
                                    <div class="nav-submenu-inner">
                                        @foreach ($item['children'] as $child)
                                            @php
                                                $childTab = $child['params']['tab'] ?? null;
                                                $childActive = request()->routeIs($child['route'])
                                                    && ($childTab === null || $currentTab === $childTab);
                                            @endphp
                                            <a href="{{ route($child['route'], $child['params'] ?? []) }}"
                                               class="nav-link nav-sublink {{ $childActive ? 'active' : '' }}"
                                               title="{{ $child['label'] }}">
                                                <i class="bi {{ $child['icon'] }}"></i>
                                                <span>{{ $child['label'] }}</span>
                                            </a>
                                        @endforeach
                                    </div>
                                </div>
                            </div>
                        @else
                            @php
                                $isActive = str_ends_with($item['route'], '.index')
                                    ? request()->routeIs(\Illuminate\Support\Str::beforeLast($item['route'], '.index').'.*')
                                    : request()->routeIs($item['route']);
                            @endphp
                            <a href="{{ route($item['route']) }}"
                               class="nav-link {{ $isActive ? 'active' : '' }}"
                               title="{{ $item['label'] }}">
                                <i class="bi {{ $item['icon'] }}"></i>
                                <span>{{ $item['label'] }}</span>
                            </a>
                        @endif
                    @endforeach
                @endforeach
            </nav>

            <div class="sidebar-user">
                <a href="{{ route('admin.profile.edit') }}" class="sidebar-user-link" title="{{ $strings::NAV_PROFILE }}">
                    @php
                        $sidebarAvatar = \App\Support\Media::url(auth()->user()?->avatar);
                        $sidebarInitial = mb_substr(auth()->user()?->name ?? 'م', 0, 1);
                    @endphp
                    @if ($sidebarAvatar)
                        <img src="{{ $sidebarAvatar }}" alt="" class="sidebar-avatar sidebar-avatar--img">
                    @else
                        <div class="sidebar-avatar">{{ $sidebarInitial }}</div>
                    @endif
                    <div class="sidebar-user-meta">
                        <strong>{{ auth()->user()?->name }}</strong>
                        <span>{{ auth()->user()?->job_title ?: $strings::NAV_PROFILE }}</span>
                    </div>
                </a>
                <form method="POST" action="{{ route('admin.logout') }}" class="sidebar-logout">
                    @csrf
                    <button type="submit" title="{{ $strings::LOGOUT }}" aria-label="{{ $strings::LOGOUT }}">
                        <i class="bi bi-box-arrow-left"></i>
                    </button>
                </form>
            </div>
        </aside>

        <div class="admin-main flex-grow-1 d-flex flex-column">
            <header class="admin-topbar">
                <div class="topbar-start">
                    <button type="button" class="sidebar-toggle" data-sidebar-toggle aria-label="فتح وإغلاق القائمة">
                        <i class="bi bi-list"></i>
                    </button>
                    <div class="topbar-title">
                        <div>{{ $title ?? $strings::DASHBOARD }}</div>
                        <small>{{ $strings::APP_TAGLINE }}</small>
                    </div>
                </div>
                <form method="GET" action="{{ route('admin.search') }}" class="admin-search">
                    <i class="bi bi-search"></i>
                    <input type="search" name="q" value="{{ request('q') }}" placeholder="{{ $strings::SEARCH_PLACEHOLDER }}" aria-label="{{ $strings::SEARCH }}">
                </form>
                <div class="topbar-end">
                    <div class="live-bell" data-live-bell>
                        <button type="button" class="live-bell-btn" data-live-toggle aria-label="إشعارات الإدارة">
                            <i class="bi bi-bell"></i>
                            <span class="live-bell-count" data-live-count hidden>0</span>
                        </button>
                        <div class="live-bell-menu" data-live-menu hidden>
                            <div class="live-bell-head">
                                <strong>التحديثات</strong>
                                <button type="button" class="btn btn-sm btn-link p-0" data-live-read>تعليم كمقروء</button>
                            </div>
                            <div class="live-bell-list" data-live-list>
                                <p class="text-muted small mb-0 p-2">لا توجد تحديثات بعد.</p>
                            </div>
                        </div>
                    </div>
                    <a href="{{ route('admin.profile.edit') }}" class="topbar-user" title="{{ $strings::NAV_PROFILE }}">{{ auth()->user()?->name }}</a>
                    <form method="POST" action="{{ route('admin.logout') }}">
                        @csrf
                        <button class="btn btn-sm btn-outline-secondary rounded-pill">{{ $strings::LOGOUT }}</button>
                    </form>
                </div>
            </header>

            <main class="admin-content">
                {{ $slot }}
            </main>
        </div>
    </div>
    <div class="sidebar-backdrop" data-sidebar-backdrop></div>
    <x-admin.detail-modal />
    <div class="live-toast-stack" data-live-toasts></div>
</body>
</html>
