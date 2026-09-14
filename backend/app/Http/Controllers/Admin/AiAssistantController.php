<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AiConversation;
use App\Models\Product;
use App\Models\Setting;
use App\Services\Ai\AiTrainingService;
use App\Support\AiSettings;
use App\Support\AppStrings;
use App\Support\Constants;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AiAssistantController extends Controller
{
    public function index(Request $request): View
    {
        $tab = (string) $request->query('tab', 'general');
        if (! in_array($tab, ['general', 'prompt', 'display', 'voice', 'performance', 'training'], true)) {
            $tab = 'general';
        }

        return view('admin.ai.index', [
            'title' => AppStrings::NAV_AI,
            'tab' => $tab,
            'settings' => AiSettings::adminBag(),
            'models' => AiSettings::models(),
            'presentations' => AiSettings::presentations(),
            'productLayouts' => AiSettings::productLayouts(),
            'bubbleStyles' => AiSettings::bubbleStyles(),
            'hasApiKey' => AiSettings::hasApiKey(),
            'conversationsCount' => AiConversation::query()->count(),
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:40'],
            'welcome' => ['required', 'string', 'max:500'],
            'system_prompt' => ['required', 'string', 'max:4000'],
            'max_products' => ['required', 'integer', 'min:2', 'max:8'],
            'model' => ['required', 'string', 'in:'.implode(',', AiSettings::models())],
            'presentation' => ['required', 'string', 'in:'.implode(',', AiSettings::presentations())],
            'primary_color' => ['nullable', 'string', 'max:7', 'regex:/^#?[0-9A-Fa-f]{0,6}$/'],
            'surface_color' => ['nullable', 'string', 'max:7', 'regex:/^#?[0-9A-Fa-f]{0,6}$/'],
            'suggestion_chips' => ['nullable', 'string', 'max:2000'],
            'product_layout' => ['required', 'string', 'in:'.implode(',', AiSettings::productLayouts())],
            'bubble_style' => ['required', 'string', 'in:'.implode(',', AiSettings::bubbleStyles())],
            'tts_rate' => ['required', 'numeric', 'min:0.3', 'max:0.9'],
            'notify_title' => ['nullable', 'string', 'max:80'],
            'notify_body' => ['nullable', 'string', 'max:240'],
            'catalog_limit' => ['required', 'integer', 'min:12', 'max:60'],
            'history_limit' => ['required', 'integer', 'min:4', 'max:16'],
            'timeout_seconds' => ['required', 'integer', 'min:15', 'max:45'],
            'rate_limit_per_minute' => ['required', 'integer', 'min:5', 'max:60'],
            'train_limit' => ['required', 'integer', 'min:1', 'max:200'],
            'train_prompt' => ['nullable', 'string', 'max:6000'],
            'active_tab' => ['nullable', 'string', 'max:40'],
        ]);

        $chips = collect(preg_split('/\r\n|\r|\n/', (string) ($data['suggestion_chips'] ?? '')))
            ->map(fn ($line) => trim((string) $line))
            ->filter()
            ->take(12)
            ->values()
            ->all();

        $primary = $this->normalizeHex($data['primary_color'] ?? '');
        $surface = $this->normalizeHex($data['surface_color'] ?? '');

        Setting::setValue(Constants::SETTING_AI_ENABLED, $request->boolean('enabled') ? '1' : '0');
        Setting::setValue(Constants::SETTING_AI_GUESTS_ALLOWED, $request->boolean('guests_allowed') ? '1' : '0');
        Setting::setValue(Constants::SETTING_AI_NAME, $data['name']);
        Setting::setValue(Constants::SETTING_AI_WELCOME, $data['welcome']);
        Setting::setValue(Constants::SETTING_AI_SYSTEM_PROMPT, $data['system_prompt']);
        Setting::setValue(Constants::SETTING_AI_MAX_PRODUCTS, (string) $data['max_products']);
        Setting::setValue(Constants::SETTING_AI_MODEL, $data['model']);
        Setting::setValue(Constants::SETTING_AI_PRESENTATION, $data['presentation']);
        Setting::setValue(Constants::SETTING_AI_PRIMARY_COLOR, $primary);
        Setting::setValue(Constants::SETTING_AI_SURFACE_COLOR, $surface);
        Setting::setValue(Constants::SETTING_AI_SUGGESTION_CHIPS, json_encode($chips, JSON_UNESCAPED_UNICODE));
        Setting::setValue(Constants::SETTING_AI_PRODUCT_LAYOUT, $data['product_layout']);
        Setting::setValue(Constants::SETTING_AI_SHOW_CLOSE_BUTTON, $request->boolean('show_close_button') ? '1' : '0');
        Setting::setValue(Constants::SETTING_AI_BUBBLE_STYLE, $data['bubble_style']);
        Setting::setValue(Constants::SETTING_AI_TTS_ENABLED, $request->boolean('tts_enabled') ? '1' : '0');
        Setting::setValue(Constants::SETTING_AI_TTS_DEFAULT_ON, $request->boolean('tts_default_on') ? '1' : '0');
        Setting::setValue(Constants::SETTING_AI_TTS_WELCOME, $request->boolean('tts_welcome') ? '1' : '0');
        Setting::setValue(Constants::SETTING_AI_TTS_REPLIES, $request->boolean('tts_replies') ? '1' : '0');
        Setting::setValue(Constants::SETTING_AI_STT_ENABLED, $request->boolean('stt_enabled') ? '1' : '0');
        Setting::setValue(Constants::SETTING_AI_TTS_RATE, (string) $data['tts_rate']);
        Setting::setValue(Constants::SETTING_AI_NOTIFY_ON_OPS, $request->boolean('notify_on_ops') ? '1' : '0');
        Setting::setValue(Constants::SETTING_AI_NOTIFY_TITLE, trim((string) ($data['notify_title'] ?? '')));
        Setting::setValue(Constants::SETTING_AI_NOTIFY_BODY, trim((string) ($data['notify_body'] ?? '')));
        Setting::setValue(Constants::SETTING_AI_FAST_MODE, $request->boolean('fast_mode') ? '1' : '0');
        Setting::setValue(Constants::SETTING_AI_CATALOG_LIMIT, (string) $data['catalog_limit']);
        Setting::setValue(Constants::SETTING_AI_HISTORY_LIMIT, (string) $data['history_limit']);
        Setting::setValue(Constants::SETTING_AI_TIMEOUT_SECONDS, (string) $data['timeout_seconds']);
        Setting::setValue(Constants::SETTING_AI_RATE_LIMIT, (string) $data['rate_limit_per_minute']);
        Setting::setValue(Constants::SETTING_AI_TRAIN_LIMIT, (string) $data['train_limit']);
        Setting::setValue(
            Constants::SETTING_AI_TRAIN_PROMPT,
            trim((string) ($data['train_prompt'] ?? '')) !== ''
                ? trim((string) $data['train_prompt'])
                : AiSettings::defaultTrainPrompt()
        );

        $tab = (string) ($data['active_tab'] ?? 'general');

        return redirect()
            ->route('admin.ai.index', ['tab' => $tab])
            ->with('success', AppStrings::AI_SAVED);
    }

    public function restoreCityMartPrompts(Request $request): RedirectResponse
    {
        $defaults = AiSettings::cityMartPromptDefaults();

        Setting::setValue(Constants::SETTING_AI_NAME, $defaults['name']);
        Setting::setValue(Constants::SETTING_AI_WELCOME, $defaults['welcome']);
        Setting::setValue(Constants::SETTING_AI_SYSTEM_PROMPT, $defaults['system_prompt']);
        Setting::setValue(Constants::SETTING_AI_TRAIN_PROMPT, $defaults['train_prompt']);
        Setting::setValue(
            Constants::SETTING_AI_SUGGESTION_CHIPS,
            json_encode($defaults['suggestion_chips'], JSON_UNESCAPED_UNICODE)
        );

        $tab = (string) $request->input('active_tab', 'prompt');
        if (! in_array($tab, ['general', 'prompt', 'display', 'voice', 'performance', 'training'], true)) {
            $tab = 'prompt';
        }

        return redirect()
            ->route('admin.ai.index', ['tab' => $tab])
            ->with('success', AppStrings::AI_PROMPTS_RESTORED);
    }

    public function train(Request $request, AiTrainingService $training): RedirectResponse
    {
        $data = $request->validate([
            'train_limit' => ['nullable', 'integer', 'min:1', 'max:200'],
        ]);

        if (isset($data['train_limit'])) {
            Setting::setValue(Constants::SETTING_AI_TRAIN_LIMIT, (string) $data['train_limit']);
        }

        $result = $training->enqueue(
            isset($data['train_limit']) ? (int) $data['train_limit'] : null,
            $request->boolean('notify_customers'),
        );

        $flash = match ($result['status']) {
            'success', 'queued', 'busy' => 'success',
            default => 'error',
        };

        return redirect()
            ->route('admin.ai.index', ['tab' => 'training'])
            ->with($flash, $result['message']);
    }

    public function conversations(Request $request): View
    {
        $q = trim((string) $request->query('q', ''));
        $audience = (string) $request->query('audience', 'all');

        $conversations = AiConversation::query()
            ->with(['user', 'messages' => fn ($query) => $query->latest('id')->limit(1)])
            ->withCount('messages')
            ->when($audience === 'customers', fn ($query) => $query->whereNotNull('user_id'))
            ->when($audience === 'guests', fn ($query) => $query->whereNull('user_id'))
            ->when($q !== '', function ($query) use ($q) {
                $query->where(function ($inner) use ($q) {
                    $inner->where('id', $q)
                        ->orWhere('guest_token', 'like', '%'.$q.'%')
                        ->orWhereHas('user', function ($userQuery) use ($q) {
                            $userQuery->where('name', 'like', '%'.$q.'%')
                                ->orWhere('phone', 'like', '%'.$q.'%');
                        });
                });
            })
            ->latest('id')
            ->paginate(Constants::DEFAULT_PAGE_SIZE)
            ->withQueryString();

        return view('admin.ai.conversations', [
            'title' => AppStrings::AI_CONVERSATIONS,
            'conversations' => $conversations,
            'q' => $q,
            'audience' => $audience,
        ]);
    }

    public function show(AiConversation $conversation): View
    {
        $conversation->load(['user', 'messages']);

        $productIds = $conversation->messages
            ->pluck('suggested_product_ids')
            ->filter()
            ->flatten()
            ->unique()
            ->values();

        $products = $productIds->isEmpty()
            ? collect()
            : Product::query()->whereIn('id', $productIds)->get()->keyBy('id');

        return view('admin.ai.show', [
            'title' => 'محادثة #'.$conversation->id,
            'conversation' => $conversation,
            'products' => $products,
        ]);
    }

    public function destroyConversation(AiConversation $conversation): RedirectResponse
    {
        $conversation->delete();

        return redirect()
            ->route('admin.ai.conversations')
            ->with('success', 'تم حذف المحادثة.');
    }

    public function destroyAllConversations(): RedirectResponse
    {
        $count = AiConversation::query()->count();
        AiConversation::query()->delete();

        return redirect()
            ->route('admin.ai.conversations')
            ->with('success', $count > 0
                ? "تم حذف {$count} محادثة نهائياً مع رسائلها."
                : 'لا توجد محادثات للحذف.');
    }

    private function normalizeHex(?string $value): string
    {
        $value = trim((string) $value);
        if ($value === '') {
            return '';
        }
        if (preg_match('/^#?[0-9A-Fa-f]{6}$/', $value) !== 1) {
            return '';
        }

        return str_starts_with($value, '#') ? $value : '#'.$value;
    }
}
