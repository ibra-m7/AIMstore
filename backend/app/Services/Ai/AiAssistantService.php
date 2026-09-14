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
        $searchLimit = (int) max(12, min(36, (int) round($limit * 0.6)));
        $featuredLimit = (int) max(4, min(12, (int) round($limit * 0.2)));
        $recentLimit = (int) max(4, min(16, (int) round($limit * 0.25)));
        $guideLimit = (int) max(8, min(40, (int) round($limit * 0.7)));

        $columns = [
            'id',
            'name',
            'price',
            'discount_price',
            'category_id',
            'is_featured',
            'keywords',
            'benefits',
            'is_active',
            'store_aisle',
            'store_shelf',
            'store_location_note',
        ];
        $light = ['category:id,name'];

        $matched = Product::query()
            ->active()
            ->with($light)
            ->search($message)
            ->orderByDesc('is_featured')
            ->limit($searchLimit)
            ->get($columns);

        $byAisle = $this->productsByAisleHint($message, $guideLimit, $columns, $light);
        $byCategory = $this->productsByCategoryHint($message, $guideLimit, $columns, $light);

        $featured = Product::query()
            ->active()
            ->with($light)
            ->featured()
            ->limit($featuredLimit)
            ->get($columns);

        $recent = Product::query()
            ->active()
            ->with($light)
            ->latest('id')
            ->limit($recentLimit)
            ->get($columns);

        $priority = collect();
        if ($productId) {
            $source = Product::query()->active()->with($light)->find($productId, $columns);
            if ($source) {
                $priority = $priority->push($source);
                $priority = $priority->concat(
                    Product::query()
                        ->active()
                        ->with($light)
                        ->where('category_id', $source->category_id)
                        ->where('id', '!=', $source->id)
                        ->limit(10)
                        ->get($columns)
                );
            }
        }

        return $priority
            ->concat($byAisle)
            ->concat($byCategory)
            ->concat($matched)
            ->concat($featured)
            ->concat($recent)
            ->unique('id')
            ->take($limit)
            ->values();
    }

    /**
     * @param  list<string>  $columns
     * @param  list<string>  $light
     * @return Collection<int, Product>
     */
    private function productsByAisleHint(string $message, int $limit, array $columns, array $light): Collection
    {
        $aisle = $this->extractAisleHint($message);
        if ($aisle === null) {
            return collect();
        }

        return Product::query()
            ->active()
            ->with($light)
            ->where(function ($query) use ($aisle) {
                $query->where('store_aisle', 'like', '%'.$aisle.'%')
                    ->orWhere('store_shelf', 'like', '%'.$aisle.'%')
                    ->orWhere('store_location_note', 'like', '%'.$aisle.'%');
            })
            ->orderByDesc('is_featured')
            ->limit($limit)
            ->get($columns);
    }

    /**
     * @param  list<string>  $columns
     * @param  list<string>  $light
     * @return Collection<int, Product>
     */
    private function productsByCategoryHint(string $message, int $limit, array $columns, array $light): Collection
    {
        $needle = trim($message);
        if (mb_strlen($needle) < 2) {
            return collect();
        }

        $categoryIds = \App\Models\Category::query()
            ->where('name', 'like', '%'.$needle.'%')
            ->limit(8)
            ->pluck('id');

        if ($categoryIds->isEmpty() && preg_match('/قسم\s+(.+)$/u', $needle, $m) === 1) {
            $name = trim($m[1]);
            if ($name !== '') {
                $categoryIds = \App\Models\Category::query()
                    ->where('name', 'like', '%'.$name.'%')
                    ->limit(8)
                    ->pluck('id');
            }
        }

        if ($categoryIds->isEmpty()) {
            return collect();
        }

        return Product::query()
            ->active()
            ->with($light)
            ->whereIn('category_id', $categoryIds->all())
            ->orderByDesc('is_featured')
            ->limit($limit)
            ->get($columns);
    }

    private function extractAisleHint(string $message): ?string
    {
        $message = trim($message);
        if ($message === '') {
            return null;
        }

        if (preg_match('/ممر\s*([0-9\x{0660}-\x{0669}A-Za-z\p{Arabic}]{1,20})/u', $message, $m) === 1) {
            return trim($m[0]);
        }

        if (preg_match('/رف\s*([0-9\x{0660}-\x{0669}A-Za-z\p{Arabic}]{1,20})/u', $message, $m) === 1) {
            return trim($m[0]);
        }

        if (preg_match('/(ممر|رف|موقع)\s*.{0,20}/u', $message, $m) === 1) {
            return trim($m[0]);
        }

        return null;
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
            $aisle = trim((string) ($product->store_aisle ?? ''));
            $shelf = trim((string) ($product->store_shelf ?? ''));
            $note = trim((string) ($product->store_location_note ?? ''));
            $location = collect([
                $aisle !== '' ? 'ممر: '.$aisle : null,
                $shelf !== '' ? 'رف: '.$shelf : null,
                $note !== '' ? $note : null,
            ])->filter()->implode(' | ');

            if ($location === '') {
                $location = 'موقع داخل المحل: غير مُسجّل (اذكر القسم فقط ولا تختلق رف/ممر)';
            }

            $keywords = collect($product->keywords ?? [])->take(5)->filter()->implode('، ');
            $benefits = collect($product->benefits ?? [])->take(3)->filter()->implode('، ');
            $extra = collect([
                $keywords !== '' ? 'كلمات: '.$keywords : null,
                $benefits !== '' ? 'فوائد: '.$benefits : null,
            ])->filter()->implode(' | ');

            return sprintf(
                '[%d] %s | %.2f '.AppStrings::CURRENCY.' | قسم: %s | %s%s',
                $product->id,
                $product->name,
                (float) $product->effective_price,
                $category,
                $location,
                $extra !== '' ? ' | '.$extra : ''
            );
        })->implode("\n");

        return "كتالوج سيتي مارت المتاح للاقتراح والتوجيه داخل المحل (اختر المعرّفات فقط من هنا):\n".$lines;
    }

    private function outputContract(): string
    {
        $max = AiSettings::maxProducts();

        return <<<TXT
أنت أيضاً دليل شامل داخل تطبيق سيتي مارت والماركت:
- وجّه العميل لأي شاشة يطلبها (حساب، تعديل البيانات، عناوين، إعدادات، مفضلة، طلبات، بحث، إشعارات، سلة، أقسام، قسم بالاسم، مقاضي، تسجيل دخول، إتمام طلب).
- ساعد العميل يعرف أين يجد المنتج (القسم، الممر، الرف) من بيانات الكتالوج فقط.
صيغة الرد إلزامية: أرجع JSON فقط بهذا الشكل:
{"reply":"نص عربي قصير وواضح بلهجة تسوق يمنية مهنية","product_ids":[1,2,3],"action":null}
- reply للعميل فقط، بدون ذكر المعرّفات أو JSON.
- إذا سأل عن موقع منتج: اذكر القسم، وإن وُجد الممر/الرف/الملاحظة في الكتالوج اذكرها حرفياً. إن لم يُسجَّل موقع فلا تختلقه؛ قل القسم فقط أو أن الموقع غير مُسجّل بعد.
- إذا سأل عن محتويات ممر/رف/قسم: اعرض المنتجات المطابقة من الكتالوج في reply مع product_ids.
- product_ids أرقام من الكتالوج المرفق فقط، بحد أقصى {$max} منتجات. اتركها [] إن لم يطلب العميل منتجات ولم يكن السؤال عن موقع/قسم يتطلب عرض منتجات.
- action عند طلب تنقل أو فتح شاشة:
  {"type":"navigate","target":"TARGET","category_name":null,"product_id":null,"query":null}
  TARGET المسموح: home, categories, cart, profile, orders, search, notifications, settings, favorites, login, edit_profile, addresses, add_address, groceries, checkout, category
  إذا كان الهدف قسماً محدداً بالاسم: target="category" مع category_name="اسم القسم كما في الكتالوج أو كما طلب العميل"
  إذا طلب منتج محدد معروف بالمعرّف: target يمكن أن يبقى فارغاً مع product_id من الكتالوج
- أو {"type":"clear_cart"} أو {"type":"show_order","order_number":"123"}
- لا تختلق معرّفات غير موجودة في القائمة.
- لا تملأ product_ids لمجرد التحية أو الأسئلة العامة.
TXT;
    }

    private function complementPrompt(string $message, ?string $productId): string
    {
        $hint = $productId ? ' المنتج المضاف معرّفه '.$productId.'.' : '';

        return 'أكّد إضافة المنتج للسلة بجملة قصيرة بلهجة يمنية مهنية، ثم اقترح منتجات مكملة حقيقية من الكتالوج.'.$hint."\n".$message;
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
                    'category_name' => isset($data['action']['category_name'])
                        ? trim((string) $data['action']['category_name'])
                        : null,
                    'product_id' => isset($data['action']['product_id'])
                        ? trim((string) $data['action']['product_id'])
                        : null,
                    'query' => isset($data['action']['query'])
                        ? trim((string) $data['action']['query'])
                        : null,
                ];
            }
        }

        if ($reply === '') {
            $reply = 'تفضل هذه اختيارات من سيتي مارت، ويمكنك فتح أي منتج للتفاصيل.';
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
