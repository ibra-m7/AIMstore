<?php

namespace App\Services\Notifications;

use App\Enums\DevicePlatform;
use App\Enums\NotificationType;
use App\Enums\OrderStatus;
use App\Enums\UserRole;
use App\Models\AppNotification;
use App\Models\DeviceToken;
use App\Models\NotificationCampaign;
use App\Models\Order;
use App\Models\User;
use App\Support\AppStrings;

class NotificationService
{
    public function __construct(private readonly FcmClient $fcm) {}

    public function fcmReady(): bool
    {
        return $this->fcm->isConfigured();
    }

    public function eligibleCustomerCount(): int
    {
        return User::query()
            ->where('role', UserRole::Customer)
            ->where('notifications_enabled', true)
            ->count();
    }

    public function registerToken(User $user, string $token, DevicePlatform $platform): DeviceToken
    {
        return DeviceToken::query()->updateOrCreate(
            ['token' => $token],
            [
                'user_id' => $user->id,
                'platform' => $platform,
                'last_used_at' => now(),
            ]
        );
    }

    public function unregisterToken(User $user, ?string $token): void
    {
        $query = DeviceToken::query()->where('user_id', $user->id);
        if (filled($token)) {
            $query->where('token', $token);
        }
        $query->delete();
    }

    public function setPreference(User $user, bool $enabled): User
    {
        $user->update(['notifications_enabled' => $enabled]);

        if (! $enabled) {
            DeviceToken::query()->where('user_id', $user->id)->delete();
        }

        return $user->fresh();
    }

    /**
     * @param  array{enabled?: bool, orders?: bool, offers?: bool, general?: bool}  $prefs
     */
    public function updatePreferences(User $user, array $prefs): User
    {
        $payload = [];

        if (array_key_exists('enabled', $prefs)) {
            $payload['notifications_enabled'] = (bool) $prefs['enabled'];
        }
        if (array_key_exists('orders', $prefs)) {
            $payload['notifications_orders_enabled'] = (bool) $prefs['orders'];
        }
        if (array_key_exists('offers', $prefs)) {
            $payload['notifications_offers_enabled'] = (bool) $prefs['offers'];
        }
        if (array_key_exists('general', $prefs)) {
            $payload['notifications_general_enabled'] = (bool) $prefs['general'];
        }

        if ($payload !== []) {
            $user->update($payload);
        }

        $fresh = $user->fresh();
        if ($fresh !== null && ! $fresh->notifications_enabled) {
            DeviceToken::query()->where('user_id', $fresh->id)->delete();
        }

        return $fresh ?? $user;
    }

    public function wantsPush(User $user, NotificationType $type): bool
    {
        if (! (bool) $user->notifications_enabled) {
            return false;
        }

        return match ($type) {
            NotificationType::Order => (bool) ($user->notifications_orders_enabled ?? true),
            NotificationType::Promo => (bool) ($user->notifications_offers_enabled ?? true),
            NotificationType::General => (bool) ($user->notifications_general_enabled ?? true),
        };
    }

    public function notifyOrder(Order $order): void
    {
        $order->loadMissing('user');
        $user = $order->user;
        if ($user === null) {
            return;
        }

        [$title, $body] = $this->orderCopy($order);

        $this->deliver(
            $user,
            $title,
            $body,
            NotificationType::Order,
            [
                'type' => NotificationType::Order->value,
                'order_id' => (string) $order->id,
                'order_number' => (string) $order->order_number,
                'status' => $order->status?->value,
            ],
            push: $this->wantsPush($user, NotificationType::Order),
        );
    }

    public function notifyOrderEdited(Order $order): void
    {
        $order->loadMissing('user');
        $user = $order->user;
        if ($user === null) {
            return;
        }

        $this->deliver(
            $user,
            'تم تعديل طلبك',
            'حدّثنا منتجات طلبك '.$order->order_number.' ليصبح الإجمالي '.number_format((float) $order->total, 2).' '.AppStrings::CURRENCY.'.',
            NotificationType::Order,
            [
                'type' => NotificationType::Order->value,
                'order_id' => (string) $order->id,
                'order_number' => (string) $order->order_number,
                'status' => $order->status?->value,
            ],
            push: $this->wantsPush($user, NotificationType::Order),
        );
    }

    public function notifyUser(
        User $user,
        string $title,
        string $body,
        NotificationType $type = NotificationType::General,
        array $data = [],
        ?bool $push = null,
    ): void {
        $payload = array_merge([
            'type' => $type->value,
        ], $data);

        $this->deliver(
            $user,
            $title,
            $body,
            $type,
            $payload,
            push: $push ?? $this->wantsPush($user, $type),
        );
    }

    public function notifyCustomersGeneral(
        string $title,
        string $body,
        ?User $author = null,
    ): NotificationCampaign {
        return $this->broadcast($title, $body, NotificationType::General, $author);
    }

    public function broadcast(
        string $title,
        string $body,
        NotificationType $type,
        ?User $author = null,
    ): NotificationCampaign {
        $campaign = NotificationCampaign::query()->create([
            'title' => $title,
            'body' => $body,
            'type' => $type,
            'audience' => 'all_customers',
            'created_by' => $author?->id,
            'sent_at' => now(),
        ]);

        $users = $this->customersForType($type);

        $tokens = [];
        foreach ($users as $user) {
            AppNotification::query()->create([
                'user_id' => $user->id,
                'campaign_id' => $campaign->id,
                'title' => $title,
                'body' => $body,
                'type' => $type,
                'data' => [
                    'type' => $type->value,
                    'campaign_id' => (string) $campaign->id,
                ],
            ]);

            if (! $this->wantsPush($user, $type)) {
                continue;
            }

            foreach ($user->deviceTokens as $device) {
                $tokens[] = $device->token;
            }
        }

        $pushCount = 0;
        if ($this->fcm->isConfigured() && $tokens !== []) {
            $invalid = $this->fcm->send($tokens, $title, $body, [
                'type' => $type->value,
                'campaign_id' => (string) $campaign->id,
            ]);
            $this->forgetTokens($invalid);
            $pushCount = max(0, count($tokens) - count($invalid));
        }

        $campaign->update([
            'recipients_count' => $users->count(),
            'push_count' => $pushCount,
        ]);

        return $campaign->fresh();
    }

    public function resend(NotificationCampaign $campaign, ?User $author = null): NotificationCampaign
    {
        return $this->broadcast(
            $campaign->title,
            $campaign->body,
            $campaign->type ?? NotificationType::Promo,
            $author,
        );
    }

    /**
     * @return \Illuminate\Support\Collection<int, User>
     */
    private function customersForType(NotificationType $type)
    {
        $query = User::query()
            ->where('role', UserRole::Customer)
            ->where('notifications_enabled', true)
            ->with('deviceTokens');

        return match ($type) {
            NotificationType::Order => $query->where('notifications_orders_enabled', true)->get(),
            NotificationType::Promo => $query->where('notifications_offers_enabled', true)->get(),
            NotificationType::General => $query->where('notifications_general_enabled', true)->get(),
        };
    }

    /**
     * @return array{0: string, 1: string}
     */
    private function orderCopy(Order $order): array
    {
        $number = $order->order_number;

        return match ($order->status) {
            OrderStatus::Pending => ['تم استلام طلبك', 'استلمنا طلبك '.$number.' وجاري تأكيده.'],
            OrderStatus::Preparing => ['جاري تحضير طلبك', 'طلبك '.$number.' قيد التحضير الآن.'],
            OrderStatus::OnTheWay => ['طلبك في الطريق', 'مندوب التوصيل في الطريق بطلبك '.$number.'.'],
            OrderStatus::Delivered => ['تم توصيل طلبك', 'تم تسليم طلبك '.$number.' بنجاح. نتمنى أن ينال إعجابك.'],
            OrderStatus::Cancelled => ['تم إلغاء الطلب', 'تم إلغاء طلبك '.$number.'.'],
            default => ['تحديث على طلبك', 'تم تحديث حالة طلبك '.$number.'.'],
        };
    }

    /**
     * @param  array<string, mixed>  $data
     */
    private function deliver(
        User $user,
        string $title,
        string $body,
        NotificationType $type,
        array $data,
        bool $push,
    ): void {
        // إذا أوقف المستخدم هذا النوع بالكامل لا نُنشئ إشعاراً داخلياً للعروض/العام.
        if (! $this->allowsInbox($user, $type)) {
            return;
        }

        $row = AppNotification::query()->create([
            'user_id' => $user->id,
            'title' => $title,
            'body' => $body,
            'type' => $type,
            'data' => $data,
        ]);

        $data['notification_id'] = (string) $row->id;

        if (! $push || ! $this->wantsPush($user, $type)) {
            return;
        }

        $tokens = DeviceToken::query()
            ->where('user_id', $user->id)
            ->pluck('token')
            ->all();

        $invalid = $this->fcm->send($tokens, $title, $body, $data);
        $this->forgetTokens($invalid);
    }

    private function allowsInbox(User $user, NotificationType $type): bool
    {
        // الطلبات تبقى في الصندوق حتى لو أوقف الدفع، طالما التفضيل مفعّل للنوع.
        return match ($type) {
            NotificationType::Order => (bool) ($user->notifications_orders_enabled ?? true),
            NotificationType::Promo => (bool) ($user->notifications_offers_enabled ?? true),
            NotificationType::General => (bool) ($user->notifications_general_enabled ?? true),
        };
    }

    /**
     * @param  list<string>  $tokens
     */
    private function forgetTokens(array $tokens): void
    {
        if ($tokens === []) {
            return;
        }

        DeviceToken::query()->whereIn('token', $tokens)->delete();
    }
}
