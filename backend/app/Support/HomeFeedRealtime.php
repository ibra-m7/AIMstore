<?php

namespace App\Support;

use App\Events\HomeFeedUpdated;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;
use Throwable;

final class HomeFeedRealtime
{
    public const CHANNEL = 'store.home';

    public const EVENT = 'home.updated';

    private const PENDING_KEY = 'home_feed_realtime_pending';

    private const QUEUED_KEY = 'home_feed_realtime_queued';

    public static function enabled(): bool
    {
        if (config('broadcasting.default') !== 'pusher') {
            return false;
        }

        $key = (string) config('broadcasting.connections.pusher.key', '');

        return $key !== '';
    }

    /**
     * Lightweight public config for the mobile app (never includes the secret).
     *
     * @return array{
     *     enabled: bool,
     *     driver: string,
     *     key: string,
     *     cluster: string,
     *     channel: string,
     *     event: string
     * }
     */
    public static function clientConfig(): array
    {
        $enabled = self::enabled();

        return [
            'enabled' => $enabled,
            'driver' => 'pusher',
            'key' => $enabled ? (string) config('broadcasting.connections.pusher.key', '') : '',
            'cluster' => $enabled
                ? (string) config('broadcasting.connections.pusher.options.cluster', 'mt1')
                : '',
            'channel' => self::CHANNEL,
            'event' => self::EVENT,
        ];
    }

    /**
     * Coalesce many model writes (one admin save) into a single lightweight signal.
     */
    public static function ping(string $reason = 'updated'): void
    {
        if (! self::enabled()) {
            return;
        }

        Cache::put(self::PENDING_KEY, $reason, 10);

        if (! Cache::add(self::QUEUED_KEY, true, 10)) {
            return;
        }

        dispatch(function (): void {
            $reason = (string) Cache::pull(self::PENDING_KEY, 'updated');
            Cache::forget(self::QUEUED_KEY);

            try {
                broadcast(new HomeFeedUpdated($reason));
            } catch (Throwable $e) {
                Log::warning('Home feed realtime broadcast failed', [
                    'reason' => $reason,
                    'error' => $e->getMessage(),
                ]);
            }
        })->afterResponse();
    }
}
