<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class HomeFeedUpdated implements ShouldBroadcastNow
{
    use Dispatchable;
    use InteractsWithSockets;
    use SerializesModels;

    public function __construct(
        public readonly string $reason = 'updated',
    ) {}

    public function broadcastOn(): Channel
    {
        return new Channel('store.home');
    }

    public function broadcastAs(): string
    {
        return 'home.updated';
    }

    /**
     * @return array{reason: string, at: string}
     */
    public function broadcastWith(): array
    {
        return [
            'reason' => $this->reason,
            'at' => now()->toIso8601String(),
        ];
    }
}
