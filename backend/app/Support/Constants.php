<?php

namespace App\Support;

/**
 * ثوابت المشروع — مطابقة لـ mobile/lib/core/utils/constants.dart
 */
final class Constants
{
    public const DEFAULT_PAGE_SIZE = 20;

    public const FREE_SHIPPING_THRESHOLD = 150.0;

    public const SHIPPING_FEE = 15.0;

    public const CURRENCY_CODE = 'YER';

    public const SETTING_SHIPPING_FEE = 'shipping_fee';

    public const SETTING_FREE_SHIPPING_THRESHOLD = 'free_shipping_threshold';

    public const SETTING_DELIVERY_ENABLED = 'delivery_enabled';

    public const SETTING_DELIVERY_FIRST_ORDER_FREE = 'delivery_first_order_free';

    public const SETTING_DELIVERY_HIDE_SUBTITLE = 'delivery_hide_subtitle';

    public const SETTING_DELIVERY_NOTES_ENABLED = 'delivery_notes_enabled';

    public const SETTING_DELIVERY_GENERAL_NOTE = 'delivery_general_note';

    public const SETTING_DELIVERY_STORE_LAT = 'delivery_store_lat';

    public const SETTING_DELIVERY_STORE_LNG = 'delivery_store_lng';

    public const SETTING_DELIVERY_STORE_ADDRESS = 'delivery_store_address';

    public const SETTING_DELIVERY_MAX_KM = 'delivery_max_km';

    public const SETTING_DELIVERY_FALLBACK_FEE = 'delivery_fallback_fee';

    public const SETTING_PICKUP_ENABLED = 'pickup_enabled';

    public const SETTING_STORE_NAME = 'store_name';

    public const SETTING_CURRENCY = 'currency';

    public const SETTING_BANK_IBAN = 'bank_iban';

    public const SETTING_BANK_NAME = 'bank_name';

    public const SETTING_AI_ENABLED = 'ai_enabled';

    public const SETTING_AI_GUESTS_ALLOWED = 'ai_guests_allowed';

    public const SETTING_AI_NAME = 'ai_assistant_name';

    public const SETTING_AI_WELCOME = 'ai_welcome_message';

    public const SETTING_AI_SYSTEM_PROMPT = 'ai_system_prompt';

    public const SETTING_AI_MAX_PRODUCTS = 'ai_max_products';

    public const SETTING_AI_MODEL = 'ai_gemini_model';

    public const SETTING_AI_PRESENTATION = 'ai_presentation';

    public const SETTING_AI_PRIMARY_COLOR = 'ai_primary_color';

    public const SETTING_AI_SURFACE_COLOR = 'ai_surface_color';

    public const SETTING_AI_SUGGESTION_CHIPS = 'ai_suggestion_chips';

    public const SETTING_AI_PRODUCT_LAYOUT = 'ai_product_layout';

    public const SETTING_AI_SHOW_CLOSE_BUTTON = 'ai_show_close_button';

    public const SETTING_AI_BUBBLE_STYLE = 'ai_bubble_style';

    public const SETTING_AI_TTS_ENABLED = 'ai_tts_enabled';

    public const SETTING_AI_TTS_DEFAULT_ON = 'ai_tts_default_on';

    public const SETTING_AI_TTS_WELCOME = 'ai_tts_welcome';

    public const SETTING_AI_TTS_REPLIES = 'ai_tts_replies';

    public const SETTING_AI_STT_ENABLED = 'ai_stt_enabled';

    public const SETTING_AI_TTS_RATE = 'ai_tts_rate';

    public const SETTING_AI_NOTIFY_ON_OPS = 'ai_notify_on_ops';

    public const SETTING_AI_FAST_MODE = 'ai_fast_mode';

    public const SETTING_AI_CATALOG_LIMIT = 'ai_catalog_limit';

    public const SETTING_AI_HISTORY_LIMIT = 'ai_history_limit';

    public const SETTING_AI_TIMEOUT_SECONDS = 'ai_timeout_seconds';

    public const SETTING_AI_RATE_LIMIT = 'ai_rate_limit_per_minute';

    public const SETTING_AI_TRAIN_LIMIT = 'ai_train_limit';

    public const SETTING_AI_TRAIN_PROMPT = 'ai_train_prompt';

    public const SETTING_AI_TRAIN_LAST_RUN_AT = 'ai_train_last_run_at';

    public const SETTING_AI_TRAIN_LAST_STATUS = 'ai_train_last_status';

    public const SETTING_AI_TRAIN_LAST_MESSAGE = 'ai_train_last_message';

    public const SETTING_AI_NOTIFY_TITLE = 'ai_notify_title';

    public const SETTING_AI_NOTIFY_BODY = 'ai_notify_body';

    public const SETTING_MARKETING_SOLD_COUNT = 'marketing_sold_count';

    public const SETTING_MARKETING_SOLD_SCOPE = 'marketing_sold_scope';

    public const SETTING_MARKETING_SOLD_PRODUCT_IDS = 'marketing_sold_product_ids';

    public const SETTING_FALLBACK_PRODUCT_IMAGE = 'fallback_product_image';

    public const SETTING_HOME_LOGO = 'home_logo';

    public const SETTING_CUSTOMER_SERVICE_NUMBERS = 'customer_service_numbers';

    public const SETTING_MESSAGE_US_PHONE = 'message_us_phone';

    public const SETTING_OTP_BYPASS_PHONES = 'otp_bypass_phones';

    public const SETTING_PHONE_ALLOWED_COUNTRIES = 'phone_allowed_countries';

    public const AI_DEFAULT_MAX_PRODUCTS = 6;

    public const AI_DEFAULT_MODEL = 'gemini-3.6-flash';
}
