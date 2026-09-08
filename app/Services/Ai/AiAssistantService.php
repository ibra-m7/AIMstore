<?php

namespace App\Services\Ai;

use App\Enums\AiMessageRole;
use App\Exceptions\AiAssistantException;
use App\Http\Resources\ProductResource;
use App\Models\AiConversation;
use App\Models\Product;
use App\Models\User;
use App\Support\AiSettings;
use App\Support\AppStrings;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use RuntimeException;
use Throwable;

class AiAssistantService
{
    public function __construct(
        private readonly GeminiClient $gemini,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function config(): array
    {
        return AiSettings::mobileConfig();
    }

    /**
     * @return array{conversation_id: int, guest_token: string|null, reply: string, products: array<int, mixed>, name: string}
     */
    public function chat(
        string $message,
        ?User $user,
        ?string $guestToken,
        ?int $conversationId,
        string $intent = 'chat',
        ?string $productId = null,
    ): array {
        if (! AiSettings::enabled()) {
            throw new AiAssistantException('المساعد الذكي متوقف مؤقتاً من لوحة التحكم.', 503);
        }

        if ($user === null && ! AiSettings::guestsAllowed()) {
            throw new AiAssistantException('سجّل دخولك لاستخدام المساعد الذكي.', 401);
        }

        if (! AiSettings::hasApiKey()) {
            throw new AiAssistantException('المساعد غير جاهز. أضف مفتاح Gemini في إعدادات الخادم.', 503);
        }

        $guestToken = $this->normalizeGuestToken($guestToken, $user);
        $conversation = $this->resolveConversation($user, $guestToken, $conversationId);
        $candidates = $this->candidateProducts($message, $productId);
        $history = $this->historyPayload($conversation);

        $system = implode("\n\n", [
            AiSettings::systemPrompt(),
            $this->outputContract(),
            $this->catalogBlock($candidates),
        ]);

        $userPrompt = $intent === 'complement'
            ? $this->complementPrompt($message, $productId)
            : $message;

        try {
            $raw = AiSettings::fastMode()
                ? $this->gemini->generateJsonFast($system, $userPrompt, $history)
                : $this->gemini->generateJson($system, $userPrompt, $history);
        } catch (RuntimeException $e) {
            Log::warning('ai.chat.gemini', ['reason' => $e->getMessage()]);
            throw new AiAssistantException('تعذّر الرد الآن. حاول بعد لحظات.', 502);
        } catch (Throwable $e) {
            Log::error('ai.chat.failed', ['message' => $e->getMessage()]);
            throw new AiAssistantException('تعذّر الرد الآن. حاول بعد لحظات.', 502);
        }

        $parsed = $this->parseReply($raw);
        $products = $this->resolveProducts($parsed['product_ids'], $candidates, $message);

        $conversation->messages()->create([
            'role' => AiMessageRole::User,
            'content' => $message,
        ]);

        $conversation->messages()->create([
            'role' => AiMessageRole::Assistant,
            'content' => $parsed['reply'],
            'suggested_product_ids' => $products->pluck('id')->values()->all(),
        ]);

        $payload = [
            'conversation_id' => $conversation->id,
            'guest_token' => $guestToken,
            'reply' => $parsed['reply'],
            'products' => ProductResource::collection($products)->resolve(),
            'name' => AiSettings::name(),
        ];

        if ($parsed['action'] !== null) {
            $payload['action'] = $parsed['action'];
        }

        return $payload;
    }

    private function normalizeGuestToken(?string $guestToken, ?User $user): ?string
    {
        $token = trim((string) $guestToken);
        if ($token !== '') {
            return Str::limit($token, 64, '');
        }

        return $user === null ? (string) Str::uuid() : null;
    }

    private function resolveConversation(?User $user, ?string $guestToken, ?int $conversationId): AiConversation
    {
        if ($conversationId) {
            $existing = AiConversation::query()
                ->where('id', $conversationId)
                ->where(function ($query) use ($user, $guestToken) {
                    if ($user) {
                        $query->orWhere('user_id', $user->id);
                    }
                    if ($guestToken) {
                        $query->orWhere('guest_token', $guestToken);
                    }
                })
                ->first();

            if ($existing) {
                if ($user && $existing->user_id === null) {
                    $existing->update(['user_id' => $user->id]);
                }

                return $existing;
            }
        }

        return AiConversation::query()->create([
            'user_id' => $user?->id,
            'guest_token' => $guestToken,
        ]);
    }

    /**
     * @return list<array{role: string, content: string}>
     */
    private function historyPayload(AiConversation $conversation): array
    {
        return $conversation->messages()
            ->latest('id')
            ->take(AiSettings::historyLimit())
            ->get()
            ->reverse()
            ->values()
            ->map(fn ($message) => [
                'role' => $message->role?->value ?? 'user',
                'content' => (string) $message->content,
            ])
            ->all();
    }

    /**
     * @return Collection<int, Product>
     */
    private function candidateProducts(string $message, ?string $productId): Collection
    {
        $limit = AiSettings::catalogLimit();
        $searchLimit = (int) max(8, min(24, (int) round($limit * 0.5)));
        $featuredLimit = (int) max(4, min(12, (int) round($limit * 0.25)));
        $recentLimit = (int) max(4, min(16, (int) round($limit * 0.35)));

        // خفيف للبرومبت — الصور تُجلب بعد اختيار المعرّفات.
        $light = ['category:id,name'];

        $matched = Product::query()
            ->active()
            ->with($light)
            ->search($message)
            ->orderByDesc('is_featured')
            ->limit($searchLimit)
            ->get(['id', 'name', 'price', 'discount_price', 'category_id', 'is_featured', 'keywords', 'is_active']);

        $featured = Product::query()
            ->active()
            ->with($light)
            ->featured()
            ->limit($featuredLimit)
            ->get(['id', 'name', 'price', 'discount_price', 'category_id', 'is_featured', 'keywords', 'is_active']);

        $recent = Product::query()
            ->active()
            ->with($light)
            ->latest('id')
            ->limit($recentLimit)
            ->get(['id', 'name', 'price', 'discount_price', 'category_id', 'is_featured', 'keywords', 'is_active']);

        $priority = collect();
        if ($productId) {
            $source = Product::query()->active()->with($light)->find($productId, ['id', 'name', 'price', 'discount_price', 'category_id', 'is_featured', 'keywords', 'is_active']);
            if ($source) {
                $priority = $priority->push($source);
                $priority = $priority->concat(
                    Product::query()
                        ->active()
                        ->with($light)
                        ->where('category_id', $source->category_id)
                        ->where('id', '!=', $source->id)
                        ->limit(8)
                        ->get(['id', 'name', 'price', 'discount_price', 'category_id', 'is_featured', 'keywords', 'is_active'])
                );
            }
        }

        return $priority
            ->concat($matched)
            ->concat($featured)
            ->concat($recent)
            ->unique('id')
            ->take($limit)
            ->values();
    }

    /**
     * @param  Collection<int, Product>  $candidates
     */
    private function catalogBlock(Collection $candidates): string
    {
        if ($candidates->isEmpty()) {
            return 'كتالوج المنتجات المتاح الآن: لا توجد منتجات نشطة.';
        }

        $lines = $candidates->map(function (Product $product) {
            $category = $product->category?->name ?? 'عام';

            return sprintf(
                '[%d] %s | %.2f '.AppStrings::CURRENCY.' | %s',
                $product->id,
                $product->name,
                (float) $product->effective_price,
                $category
            );
        })->implode("\n");

        return "كتالوج المنتجات المتاح للاقتراح (اختر المعرّفات فقط من هنا):\n".$lines;
    }

    private function outputContract(): string
    {
        $max = AiSettings::maxProducts();

        return <<<TXT
صيغة الرد إلزامية: أرجعي JSON فقط بهذا الشكل:
{"reply":"نص عربي قصير وواضح","product_ids":[1,2,3],"action":null}
- reply للعميل فقط، بدون ذكر المعرّفات أو JSON.
- product_ids أرقام من الكتالوج المرفق فقط، بحد أقصى {$max} منتجات. اتركها [] إن لم يطلب العميل منتجات.
- action اختياري فقط عند طلب صريح:
  {"type":"clear_cart"} أو {"type":"navigate","target":"home|categories|cart|profile|orders|search|notifications"} أو {"type":"show_order","order_number":"123"}
- لا تختلقي معرّفات غير موجودة في القائمة.
- لا تملئي product_ids لمجرد التحية أو الأسئلة العامة.
TXT;
    }

    private function complementPrompt(string $message, ?string $productId): string
    {
        $hint = $productId ? ' المنتج المضاف معرّفه '.$productId.'.' : '';

        return 'أكّدي إضافة المنتج للسلة بجملة قصيرة، ثم اقترحي منتجات مكملة حقيقية من الكتالوج.'.$hint."\n".$message;
    }

    /**
     * @return array{reply: string, product_ids: list<int>, action: array<string, mixed>|null}
     */
    private function parseReply(string $raw): array
    {
        $text = trim($raw);
        if (preg_match('/\{.*\}/s', $text, $matches) === 1) {
            $text = $matches[0];
        }

        $data = json_decode($text, true);
        $reply = is_array($data) && is_string($data['reply'] ?? null)
            ? trim((string) $data['reply'])
            : '';

        $ids = [];
        if (is_array($data) && isset($data['product_ids']) && is_array($data['product_ids'])) {
            foreach ($data['product_ids'] as $id) {
                if (is_numeric($id)) {
                    $ids[] = (int) $id;
                }
            }
        }

        $action = null;
        if (is_array($data) && isset($data['action']) && is_array($data['action'])) {
            $type = trim((string) ($data['action']['type'] ?? ''));
            if (in_array($type, ['clear_cart', 'navigate', 'show_order'], true)) {
                $action = [
                    'type' => $type,
                    'target' => isset($data['action']['target'])
                        ? trim((string) $data['action']['target'])
                        : null,
                    'order_number' => isset($data['action']['order_number'])
                        ? trim((string) $data['action']['order_number'])
                        : null,
                ];
            }
        }

        if ($reply === '') {
            $reply = 'تفضل هذه اختيارات من متجرنا، ويمكنك فتح أي منتج للتفاصيل.';
        }

        return [
            'reply' => $reply,
            'product_ids' => array_values(array_unique($ids)),
            'action' => $action,
        ];
    }

    /**
     * @param  list<int>  $ids
     * @param  Collection<int, Product>  $candidates
     * @return Collection<int, Product>
     */
    private function resolveProducts(array $ids, Collection $candidates, string $message): Collection
    {
        $max = AiSettings::maxProducts();
        $wanted = collect($ids)->unique()->filter()->values();

        // لا تملأ منتجات تلقائياً إلا إذا أعاد النموذج معرّفات صريحة.
        if ($wanted->isEmpty()) {
            return collect();
        }

        $products = Product::query()
            ->active()
            ->with(['images', 'primaryImage', 'category'])
            ->whereIn('id', $wanted->all())
            ->get()
            ->keyBy('id');

        return $wanted
            ->map(fn ($id) => $products->get((int) $id))
            ->filter()
            ->take($max)
            ->values();
    }
}
