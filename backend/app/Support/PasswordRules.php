<?php

namespace App\Support;

use Illuminate\Validation\Rules\Password;

final class PasswordRules
{
    /**
     * أحرف (كبيرة أو صغيرة) + أرقام + رموز — بدون إلزام الحالتين معاً.
     */
    public static function admin(): Password
    {
        return Password::min(8)
            ->letters()
            ->numbers()
            ->symbols();
    }

    public static function messages(): array
    {
        return [
            'password.min' => 'كلمة المرور يجب أن تكون 8 أحرف على الأقل.',
            'password.letters' => 'كلمة المرور يجب أن تحتوي على حرف واحد على الأقل.',
            'password.numbers' => 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل.',
            'password.symbols' => 'كلمة المرور يجب أن تحتوي على رمز واحد على الأقل (مثل @ # $ !).',
            'password.confirmed' => 'تأكيد كلمة المرور غير متطابق.',
        ];
    }

    /**
     * @return array{ok: bool, checks: array<string, bool>, message: string}
     */
    public static function evaluate(string $password): array
    {
        $checks = [
            'length' => mb_strlen($password) >= 8,
            'letter' => (bool) preg_match('/\p{L}/u', $password),
            'number' => (bool) preg_match('/\d/u', $password),
            'symbol' => (bool) preg_match('/[^\p{L}\d\s]/u', $password),
        ];

        $ok = ! in_array(false, $checks, true);

        return [
            'ok' => $ok,
            'checks' => $checks,
            'message' => $ok
                ? 'كلمة المرور قوية ومقبولة.'
                : 'أضف أحرفاً وأرقاماً ورمزاً، بطول 8 على الأقل.',
        ];
    }
}
