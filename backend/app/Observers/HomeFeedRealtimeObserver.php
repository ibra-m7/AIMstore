<?php

namespace App\Observers;

use App\Support\HomeFeedRealtime;

class HomeFeedRealtimeObserver
{
    public function saved(mixed $model): void
    {
        HomeFeedRealtime::ping(class_basename($model).'.saved');
    }

    public function deleted(mixed $model): void
    {
        HomeFeedRealtime::ping(class_basename($model).'.deleted');
    }
}
