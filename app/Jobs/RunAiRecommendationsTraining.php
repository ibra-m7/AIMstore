<?php

namespace App\Jobs;

use App\Services\Ai\AiTrainingService;
use Illuminate\Foundation\Bus\Dispatchable;

/**
 * يعمل بعد استجابة HTTP (afterResponse) حتى لا ينتهي طلب الأدمن بـ timeout.
 * لا يعتمد على queue worker.
 */
class RunAiRecommendationsTraining
{
    use Dispatchable;

    public function __construct(
        public readonly ?int $limit = null,
        public readonly bool $notify = false,
        public readonly ?int $actorUserId = null,
    ) {}

    public function handle(AiTrainingService $training): void
    {
        $training->runQueued($this->limit, $this->notify, $this->actorUserId);
    }
}
