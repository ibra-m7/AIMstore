<?php

namespace App\Services\Ai;

use App\Models\Product;
use App\Models\Setting;
use App\Services\Notifications\NotificationService;
use App\Support\AiSettings;
use App\Support\Constants;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;
use Throwable;

class AiTrainingService
{
    public function __construct(
        private readonly NotificationService $notifications,
    ) {}

    /**
     * @return array{status: string, message: string, trained: int}
     */
    public function run(?int $limit = null, bool $notify = false): array
    {
        $lock = Cache::lock('ai:train:recommendations', 1200);
        if (! $lock->get()) {
            return [
                'status' => 'busy',
                'message' => 'التدريب قيد التنفيذ حالياً. حاول بعد انتهاء العملية.',
                'trained' => 0,
            ];
        }

        $limit = max(1, min($limit ?? AiSettings::trainLimit(), 200));
        Setting::setValue(Constants::SETTING_AI_TRAIN_LAST_STATUS, 'running');
        Setting::setValue(Constants::SETTING_AI_TRAIN_LAST_MESSAGE, 'جاري تدريب التوصيات…');
        Setting::setValue(Constants::SETTING_AI_TRAIN_LAST_RUN_AT, now()->toDateTimeString());

        $trained = 0;

        try {
            if (! AiSettings::hasApiKey()) {
                throw new \RuntimeException('مفتاح Gemini غير متوفر على الخادم.');
            }

            $ids = Product::query()
                ->active()
                ->orderByDesc('is_featured')
                ->orderByDesc('id')
                ->limit($limit)
                ->pluck('id');

            foreach ($ids as $id) {
                \App\Jobs\RefreshProductRecommendations::dispatchSync((int) $id);
                $trained++;
            }

            $message = $trained > 0
                ? 'تم تدريب توصيات '.$trained.' منتجاً بنجاح.'
                : 'لا توجد منتجات نشطة للتدريب.';

            Setting::setValue(Constants::SETTING_AI_TRAIN_LAST_STATUS, 'success');
            Setting::setValue(Constants::SETTING_AI_TRAIN_LAST_MESSAGE, $message);
            Setting::setValue(Constants::SETTING_AI_TRAIN_LAST_RUN_AT, now()->toDateTimeString());

            if ($notify || AiSettings::notifyOnOps()) {
                $this->notifications->notifyCustomersGeneral(
                    AiSettings::notifyTitle(),
                    AiSettings::notifyBody() !== ''
                        ? AiSettings::notifyBody()
                        : $message,
                    Auth::user(),
                );
            }

            return [
                'status' => 'success',
                'message' => $message,
                'trained' => $trained,
            ];
        } catch (Throwable $e) {
            Log::error('ai.train.failed', ['message' => $e->getMessage()]);
            $message = 'فشل التدريب: '.mb_substr($e->getMessage(), 0, 180);
            Setting::setValue(Constants::SETTING_AI_TRAIN_LAST_STATUS, 'failed');
            Setting::setValue(Constants::SETTING_AI_TRAIN_LAST_MESSAGE, $message);
            Setting::setValue(Constants::SETTING_AI_TRAIN_LAST_RUN_AT, now()->toDateTimeString());

            return [
                'status' => 'failed',
                'message' => $message,
                'trained' => $trained,
            ];
        } finally {
            optional($lock)->release();
        }
    }
}
