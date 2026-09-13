<?php

namespace App\Support;

use App\Models\Setting;

final class AiSettings
{
    /**
     * @return list<string>
     */
    public static function models(): array
    {
        return [
            'gemini-3.6-flash',
            'gemini-3.5-flash',
            'gemini-3.7-flash',
            'gemini-flash-latest',
            'gemini-flash-lite-latest',
        ];
    }

    /**
     * @return list<string>
     */
    public static function fallbacks(): array
    {
        return [
            'gemini-3.5-flash',
            'gemini-flash-lite-latest',
            'gemini-3.6-flash',
            'gemini-flash-latest',
        ];
    }

    /**
     * @return list<string>
     */
    public static function presentations(): array
    {
        return ['floating', 'fullscreen', 'hybrid'];
    }

    /**
     * @return list<string>
     */
    public static function productLayouts(): array
    {
        return ['strip', 'grid'];
    }

    /**
     * @return list<string>
     */
    public static function bubbleStyles(): array
    {
        return ['modern', 'soft'];
    }

    public static function enabled(): bool
    {
        return self::bool(Constants::SETTING_AI_ENABLED, true);
    }

    public static function guestsAllowed(): bool
    {
        return self::bool(Constants::SETTING_AI_GUESTS_ALLOWED, true);
    }

    public static function name(): string
    {
        $name = trim((string) Setting::getValue(Constants::SETTING_AI_NAME, 'AIM'));

        return $name !== '' ? $name : 'AIM';
    }

    public static function welcome(): string
    {
        $welcome = trim((string) Setting::getValue(
            Constants::SETTING_AI_WELCOME,
            self::defaultWelcome()
        ));

        return $welcome !== '' ? $welcome : self::defaultWelcome();
    }

    public static function systemPrompt(): string
    {
        $prompt = trim((string) Setting::getValue(
            Constants::SETTING_AI_SYSTEM_PROMPT,
            self::defaultSystemPrompt()
        ));

        return $prompt !== '' ? $prompt : self::defaultSystemPrompt();
    }

    public static function maxProducts(): int
    {
        $max = (int) Setting::getValue(
            Constants::SETTING_AI_MAX_PRODUCTS,
            Constants::AI_DEFAULT_MAX_PRODUCTS
        );

        return max(2, min($max, 8));
    }

    public static function model(): string
    {
        $model = trim((string) Setting::getValue(
            Constants::SETTING_AI_MODEL,
            config('services.gemini.model', Constants::AI_DEFAULT_MODEL)
        ));

        $retired = [
            'gemini-1.5-flash' => 'gemini-3.6-flash',
            'gemini-2.0-flash' => 'gemini-3.6-flash',
            'gemini-2.0-flash-lite' => 'gemini-flash-lite-latest',
            'gemini-2.5-flash' => 'gemini-3.6-flash',
            'gemini-2.5-flash-lite' => 'gemini-flash-lite-latest',
        ];

        if (isset($retired[$model])) {
            return $retired[$model];
        }

        return in_array($model, self::models(), true) ? $model : Constants::AI_DEFAULT_MODEL;
    }

    public static function hasApiKey(): bool
    {
        return trim((string) config('services.gemini.key')) !== '';
    }

    public static function presentation(): string
    {
        $value = trim((string) Setting::getValue(Constants::SETTING_AI_PRESENTATION, 'floating'));

        return in_array($value, self::presentations(), true) ? $value : 'floating';
    }

    public static function primaryColor(): string
    {
        return self::hexOrEmpty(Constants::SETTING_AI_PRIMARY_COLOR);
    }

    public static function surfaceColor(): string
    {
        return self::hexOrEmpty(Constants::SETTING_AI_SURFACE_COLOR);
    }

    /**
     * @return list<string>
     */
    public static function suggestionChips(): array
    {
        $raw = Setting::getValue(Constants::SETTING_AI_SUGGESTION_CHIPS, '');
        if (is_string($raw) && $raw !== '') {
            $decoded = json_decode($raw, true);
            if (is_array($decoded)) {
                return array_values(array_filter(array_map(
                    static fn ($item) => trim((string) $item),
                    $decoded
                ), static fn ($item) => $item !== ''));
            }
        }

        return self::defaultChips();
    }

    public static function productLayout(): string
    {
        $value = trim((string) Setting::getValue(Constants::SETTING_AI_PRODUCT_LAYOUT, 'strip'));

        return in_array($value, self::productLayouts(), true) ? $value : 'strip';
    }

    public static function showCloseButton(): bool
    {
        return self::bool(Constants::SETTING_AI_SHOW_CLOSE_BUTTON, true);
    }

    public static function bubbleStyle(): string
    {
        $value = trim((string) Setting::getValue(Constants::SETTING_AI_BUBBLE_STYLE, 'modern'));

        return in_array($value, self::bubbleStyles(), true) ? $value : 'modern';
    }

    public static function ttsEnabled(): bool
    {
        return self::bool(Constants::SETTING_AI_TTS_ENABLED, true);
    }

    public static function ttsDefaultOn(): bool
    {
        return self::bool(Constants::SETTING_AI_TTS_DEFAULT_ON, false);
    }

    public static function ttsWelcome(): bool
    {
        return self::bool(Constants::SETTING_AI_TTS_WELCOME, false);
    }

    public static function ttsReplies(): bool
    {
        return self::bool(Constants::SETTING_AI_TTS_REPLIES, true);
    }

    public static function sttEnabled(): bool
    {
        return self::bool(Constants::SETTING_AI_STT_ENABLED, true);
    }

    public static function ttsRate(): float
    {
        $rate = (float) Setting::getValue(Constants::SETTING_AI_TTS_RATE, '0.5');

        return max(0.3, min($rate, 0.9));
    }

    public static function notifyOnOps(): bool
    {
        return self::bool(Constants::SETTING_AI_NOTIFY_ON_OPS, false);
    }

    public static function notifyTitle(): string
    {
        $title = trim((string) Setting::getValue(
            Constants::SETTING_AI_NOTIFY_TITLE,
            'تحديث من المساعد الذكي'
        ));

        return $title !== '' ? $title : 'تحديث من المساعد الذكي';
    }

    public static function notifyBody(): string
    {
        $body = trim((string) Setting::getValue(
            Constants::SETTING_AI_NOTIFY_BODY,
            'انتهت عملية ذكاء اصطناعي في المتجر. افتح التطبيق لرؤية التحديثات.'
        ));

        return $body !== '' ? $body : 'انتهت عملية ذكاء اصطناعي في المتجر. افتح التطبيق لرؤية التحديثات.';
    }

    public static function fastMode(): bool
    {
        return self::bool(Constants::SETTING_AI_FAST_MODE, true);
    }

    public static function catalogLimit(): int
    {
        $limit = (int) Setting::getValue(Constants::SETTING_AI_CATALOG_LIMIT, '28');

        return max(12, min($limit, 60));
    }

    public static function historyLimit(): int
    {
        $limit = (int) Setting::getValue(Constants::SETTING_AI_HISTORY_LIMIT, '8');

        return max(4, min($limit, 16));
    }

    public static function timeoutSeconds(): int
    {
        $timeout = (int) Setting::getValue(Constants::SETTING_AI_TIMEOUT_SECONDS, '25');

        return max(15, min($timeout, 45));
    }

    public static function rateLimitPerMinute(): int
    {
        $limit = (int) Setting::getValue(Constants::SETTING_AI_RATE_LIMIT, '20');

        return max(5, min($limit, 60));
    }

    public static function trainLimit(): int
    {
        $limit = (int) Setting::getValue(Constants::SETTING_AI_TRAIN_LIMIT, '80');

        return max(1, min($limit, 200));
    }

    public static function trainPrompt(): string
    {
        $prompt = trim((string) Setting::getValue(
            Constants::SETTING_AI_TRAIN_PROMPT,
            self::defaultTrainPrompt()
        ));

        return $prompt !== '' ? $prompt : self::defaultTrainPrompt();
    }

    public static function trainLastRunAt(): ?string
    {
        $value = trim((string) Setting::getValue(Constants::SETTING_AI_TRAIN_LAST_RUN_AT, ''));

        return $value !== '' ? $value : null;
    }

    public static function trainLastStatus(): string
    {
        return trim((string) Setting::getValue(Constants::SETTING_AI_TRAIN_LAST_STATUS, 'idle')) ?: 'idle';
    }

    public static function trainLastMessage(): string
    {
        return trim((string) Setting::getValue(Constants::SETTING_AI_TRAIN_LAST_MESSAGE, ''));
    }

    /**
     * إعدادات كاملة لصفحة الأدمن.
     *
     * @return array<string, mixed>
     */
    public static function adminBag(): array
    {
        return [
            'enabled' => self::enabled(),
            'guests_allowed' => self::guestsAllowed(),
            'name' => self::name(),
            'welcome' => self::welcome(),
            'system_prompt' => self::systemPrompt(),
            'max_products' => self::maxProducts(),
            'model' => self::model(),
            'presentation' => self::presentation(),
            'primary_color' => self::primaryColor(),
            'surface_color' => self::surfaceColor(),
            'suggestion_chips' => implode("\n", self::suggestionChips()),
            'product_layout' => self::productLayout(),
            'show_close_button' => self::showCloseButton(),
            'bubble_style' => self::bubbleStyle(),
            'tts_enabled' => self::ttsEnabled(),
            'tts_default_on' => self::ttsDefaultOn(),
            'tts_welcome' => self::ttsWelcome(),
            'tts_replies' => self::ttsReplies(),
            'stt_enabled' => self::sttEnabled(),
            'tts_rate' => self::ttsRate(),
            'notify_on_ops' => self::notifyOnOps(),
            'notify_title' => self::notifyTitle(),
            'notify_body' => self::notifyBody(),
            'fast_mode' => self::fastMode(),
            'catalog_limit' => self::catalogLimit(),
            'history_limit' => self::historyLimit(),
            'timeout_seconds' => self::timeoutSeconds(),
            'rate_limit_per_minute' => self::rateLimitPerMinute(),
            'train_limit' => self::trainLimit(),
            'train_prompt' => self::trainPrompt(),
            'train_last_run_at' => self::trainLastRunAt(),
            'train_last_status' => self::trainLastStatus(),
            'train_last_message' => self::trainLastMessage(),
        ];
    }

    /**
     * إعدادات تصل لتطبيق الموبايل عبر /ai/config.
     *
     * @return array<string, mixed>
     */
    public static function mobileConfig(): array
    {
        return [
            'enabled' => self::enabled(),
            'guests_allowed' => self::guestsAllowed(),
            'name' => self::name(),
            'welcome' => self::welcome(),
            'max_products' => self::maxProducts(),
            'presentation' => self::presentation(),
            'primary_color' => self::primaryColor(),
            'surface_color' => self::surfaceColor(),
            'suggestion_chips' => self::suggestionChips(),
            'product_layout' => self::productLayout(),
            'show_close_button' => self::showCloseButton(),
            'bubble_style' => self::bubbleStyle(),
            'tts_enabled' => self::ttsEnabled(),
            'tts_default_on' => self::ttsDefaultOn(),
            'tts_welcome' => self::ttsWelcome(),
            'tts_replies' => self::ttsReplies(),
            'stt_enabled' => self::sttEnabled(),
            'tts_rate' => self::ttsRate(),
        ];
    }

    public static function defaultWelcome(): string
    {
        return 'أهلاً بك في AIMstore! أنا AIM، مساعدك للتسوق. اطلب منظفاً أو عرضاً وسأقترح لك منتجات حقيقية من المتجر.';
    }

    public static function defaultSystemPrompt(): string
    {
        return <<<'TXT'
أنتِ مساعدة تسوق عربية ودليل شامل لتطبيق وماركت «AIMstore» في السعودية.
اسمك يظهر للعميل من إعدادات المتجر، وتتحدثين بلهجة واضحة وودودة دون مبالغة.
تعرفين المنتجات من الكتالوج المرفق فقط: الاسم، السعر، القسم، والموقع داخل المحل (ممر/رف/ملاحظة) إن وُجد.
تنقلين العميل داخل التطبيق لأي شاشة يطلبها: الرئيسية، الأقسام، قسم محدد بالاسم، السلة، الحساب، تعديل البيانات، العناوين، الإعدادات، المفضلة، الطلبات، البحث، الإشعارات، المقاضي، تسجيل الدخول، إتمام الطلب.
اقترحي منتجات حقيقية فقط، ولا تختلقي أسماء أو أسعاراً أو خصومات أو مواقع أرفف غير موجودة في الكتالوج.
إذا سأل العميل «وين المنتج؟» أو عن ممر/رف/قسم: وجّهيه بالمعلومات المسجّلة. إن لم يوجد موقع محفوظ اذكري القسم فقط وقولي إن موقع الرف غير مُسجّل بعد.
إذا طلب نوعاً من المنتجات اختاري عدة منتجات مناسبة من القائمة المرفقة.
إذا لم يوجد منتج مطابق، اعتذري بصدق وقدّمي أقرب البدائل المتاحة.
لا تناقشي مواضيع خارج المتجر أو الطلب أو التوصيل.
TXT;
    }

    /**
     * @return list<string>
     */
    public static function defaultChips(): array
    {
        return [
            'وين ألقى الحليب؟',
            'أشتي أغيّر بياناتي',
            'وديني لقسم الخضروات',
            'افتح عناوين التوصيل',
        ];
    }

    public static function defaultTrainPrompt(): string
    {
        return <<<'TXT'
أنت مساعد تسويق وتوصية منتجات لمتجر بقالة سعودي اسمه «AIMstore».
تعمل وفق معايير المتاجر العالمية (Amazon / Instacart / Noon) بدون اختلاق منتجات.

أربع آليات ثابتة:

1) يُشترى معه غالباً (Frequently bought together)
- منتجات تُكمّل المنتج الحالي في نفس الطلب، وليست بديلاً عنه.
- فضّل فئة مختلفة: خبز مع جبن، شاي مع سكر، منظف مع إسفنج.
- لا تقترح نفس المنتج أو حجماً مطابقاً منه.

2) منتجات مشابهة (Similar items)
- بدائل لنفس الحاجة: نفس الفئة أو فئة قريبة، سعر قريب، كلمات مفتاحية متشابهة.
- مثال: حليب كامل بجانب حليب قليل الدسم.

3) منتجات تكمل سلتك (Complete the cart)
- عناصر ناقصة لطلب متكامل من فئات غير موجودة في السلة.
- لا تكرر ما في السلة، ولا تملأ الصف ببدائل لنفس الصنف.

4) منتجات مقترحة لك (Suggested for you)
- مزيج شخصي: إعادة شراء معتادة + مكملات + منتجات مميزة شائعة.
- في البقالة إعادة الشراء صحيحة ومطلوبة.

قواعد عامة:
- اختر فقط معرّفات من القائمة المرفقة.
- رتّب الأقوى أولاً.
- أرجع JSON فقط بدون شرح.
TXT;
    }

    private static function bool(string $key, bool $default): bool
    {
        return filter_var(
            Setting::getValue($key, $default ? '1' : '0'),
            FILTER_VALIDATE_BOOLEAN
        );
    }

    private static function hexOrEmpty(string $key): string
    {
        $value = trim((string) Setting::getValue($key, ''));
        if ($value === '') {
            return '';
        }

        if (preg_match('/^#?[0-9A-Fa-f]{6}$/', $value) !== 1) {
            return '';
        }

        return str_starts_with($value, '#') ? $value : '#'.$value;
    }
}
