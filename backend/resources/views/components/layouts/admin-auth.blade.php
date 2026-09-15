@props(['title' => null])

<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>{{ $title ?? $strings::LOGIN_TITLE }} — {{ $strings::APP_NAME }}</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;800&display=swap" rel="stylesheet">
    @if (file_exists(public_path('build/manifest.json')) || file_exists(public_path('hot')))
        @vite(['resources/js/admin.js'])
    @endif
</head>
<body class="auth-wrap d-flex align-items-center justify-content-center p-3">
    @if (! file_exists(public_path('build/manifest.json')) && ! file_exists(public_path('hot')))
        <div class="card auth-card w-100 p-4" style="max-width: 28rem">
            <strong>تعذّر تحميل أصول لوحة التحكم.</strong>
            <p class="mb-0 mt-2 text-muted">شغّل <code>npm run build</code> أو <code>npm run dev</code> داخل مجلد <code>backend</code> ثم أعد تحميل الصفحة.</p>
        </div>
    @else
        {{ $slot }}
        <script>
            window.addEventListener("pageshow", (event) => {
                if (event.persisted) {
                    window.location.reload();
                }
            });
        </script>
    @endif
</body>
</html>
