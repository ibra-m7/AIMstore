<?php

namespace App\Http\Controllers;

use App\Models\Setting;
use App\Support\Constants;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\StreamedResponse;

class HomeLogoController extends Controller
{
    public function __invoke(): Response|RedirectResponse|StreamedResponse
    {
        $value = trim((string) Setting::getValue(Constants::SETTING_HOME_LOGO, ''));

        if ($value === '') {
            $fallback = public_path('images/home_logo.png');
            if (is_file($fallback)) {
                return response()->file($fallback, [
                    'Content-Type' => 'image/png',
                    'Cache-Control' => 'public, max-age=86400',
                ]);
            }
            abort(404);
        }

        if (str_starts_with($value, 'http://') || str_starts_with($value, 'https://')) {
            return redirect()->away($value);
        }

        if (str_starts_with($value, 'data:')
            && preg_match('/^data:(image\/[a-zA-Z0-9.+-]+);base64,(.+)$/s', $value, $matches) === 1
        ) {
            $binary = base64_decode($matches[2], true);
            if ($binary === false || $binary === '') {
                abort(404);
            }

            return response($binary, 200, [
                'Content-Type' => $matches[1],
                'Cache-Control' => 'public, max-age=86400',
            ]);
        }

        foreach ([$value, ltrim(str_replace('\\', '/', $value), '/')] as $path) {
            if ($path !== '' && Storage::disk('public')->exists($path)) {
                return Storage::disk('public')->response($path);
            }
        }

        abort(404);
    }
}
