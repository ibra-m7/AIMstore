import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_client.dart';
import '../../../shop/data/models/category_model.dart';
import '../../../shop/data/models/product_model.dart';

class AiConfig {
  final bool enabled;
  final bool guestsAllowed;
  final String name;
  final String welcome;
  final int maxProducts;
  final String presentation;
  final String primaryColor;
  final String surfaceColor;
  final List<String> suggestionChips;
  final String productLayout;
  final bool showCloseButton;
  final String bubbleStyle;
  final bool ttsEnabled;
  final bool ttsDefaultOn;
  final bool ttsWelcome;
  final bool ttsReplies;
  final bool sttEnabled;
  final double ttsRate;

  const AiConfig({
    required this.enabled,
    required this.guestsAllowed,
    required this.name,
    required this.welcome,
    required this.maxProducts,
    this.presentation = 'floating',
    this.primaryColor = '',
    this.surfaceColor = '',
    this.suggestionChips = const [],
    this.productLayout = 'strip',
    this.showCloseButton = true,
    this.bubbleStyle = 'modern',
    this.ttsEnabled = true,
    this.ttsDefaultOn = false,
    this.ttsWelcome = false,
    this.ttsReplies = true,
    this.sttEnabled = true,
    this.ttsRate = 0.5,
  });

  factory AiConfig.fromJson(Map<String, dynamic> json) {
    final chipsRaw = json['suggestion_chips'];
    final chips = <String>[];
    if (chipsRaw is List) {
      for (final item in chipsRaw) {
        final text = '$item'.trim();
        if (text.isNotEmpty) chips.add(text);
      }
    }

    return AiConfig(
      enabled: json['enabled'] == true,
      guestsAllowed: json['guests_allowed'] != false,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : 'روعة',
      welcome: (json['welcome'] as String?)?.trim().isNotEmpty == true
          ? json['welcome'] as String
          : 'أهلاً بك في روعة الخمسة! كيف يمكنني مساعدتك؟',
      maxProducts: (json['max_products'] as num?)?.toInt() ?? 6,
      presentation: (json['presentation'] as String?) ?? 'floating',
      primaryColor: (json['primary_color'] as String?)?.trim() ?? '',
      surfaceColor: (json['surface_color'] as String?)?.trim() ?? '',
      suggestionChips: chips,
      productLayout: (json['product_layout'] as String?) ?? 'strip',
      showCloseButton: json['show_close_button'] != false,
      bubbleStyle: (json['bubble_style'] as String?) ?? 'modern',
      ttsEnabled: json['tts_enabled'] != false,
      ttsDefaultOn: json['tts_default_on'] == true,
      ttsWelcome: json['tts_welcome'] == true,
      ttsReplies: json['tts_replies'] != false,
      sttEnabled: json['stt_enabled'] != false,
      ttsRate: ((json['tts_rate'] as num?)?.toDouble() ?? 0.5).clamp(0.3, 0.9),
    );
  }
}

class AiChatAction {
  final String type;
  final String? target;
  final String? orderNumber;
  final String? categoryName;
  final String? query;
  final String? productId;

  const AiChatAction({
    required this.type,
    this.target,
    this.orderNumber,
    this.categoryName,
    this.query,
    this.productId,
  });

  factory AiChatAction.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AiChatAction(type: '');
    }
    return AiChatAction(
      type: (json['type'] as String?)?.trim() ?? '',
      target: (json['target'] as String?)?.trim(),
      orderNumber: (json['order_number'] as String?)?.trim() ??
          (json['orderNumber'] as String?)?.trim(),
      categoryName: (json['category_name'] as String?)?.trim() ??
          (json['categoryName'] as String?)?.trim(),
      query: (json['query'] as String?)?.trim(),
      productId: (json['product_id'] as String?)?.trim() ??
          (json['productId'] as String?)?.trim(),
    );
  }

  bool get isEmpty => type.isEmpty;
}

class AiChatResult {
  final int conversationId;
  final String reply;
  final List<ProductModel> products;
  final String name;
  final AiChatAction? action;

  const AiChatResult({
    required this.conversationId,
    required this.reply,
    required this.products,
    required this.name,
    this.action,
  });
}

class AiChatApi {
  AiChatApi._();
  static final AiChatApi instance = AiChatApi._();

  static const _guestKey = 'ai_guest_token';
  static const voicePrefKey = 'ai_voice_enabled_pref';
  final _client = ApiClient.instance;

  Future<String> guestToken() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(_guestKey);
    if (token == null || token.length < 8) {
      token = _newToken();
      await prefs.setString(_guestKey, token);
    }
    return token;
  }

  Future<AiConfig> config() async {
    final json = await _client.get('/ai/config', auth: false);
    return AiConfig.fromJson(_dataMap(json));
  }

  Future<AiChatResult> chat({
    required String message,
    int? conversationId,
    String intent = 'chat',
    String? productId,
  }) async {
    final conversation = conversationId != null && conversationId > 0
        ? conversationId
        : null;
    final json = await _client.post(
      '/ai/chat',
      {
        'message': message,
        'conversation_id': ?conversation,
        'guest_token': await guestToken(),
        'intent': intent,
        'product_id': ?productId,
      },
      auth: true,
      timeout: const Duration(seconds: 45),
    );

    final data = _dataMap(json);
    final actionRaw = data['action'];
    AiChatAction? action;
    if (actionRaw is Map<String, dynamic>) {
      action = AiChatAction.fromJson(actionRaw);
    } else if (actionRaw is Map) {
      action = AiChatAction.fromJson(Map<String, dynamic>.from(actionRaw));
    }
    if (action != null && action.isEmpty) action = null;

    return AiChatResult(
      conversationId: (data['conversation_id'] as num?)?.toInt() ?? 0,
      reply: (data['reply'] as String?)?.trim().isNotEmpty == true
          ? data['reply'] as String
          : 'تفضل هذه اختيارات من متجرنا.',
      products: jsonMapList(data['products'], ProductModel.fromJson),
      name: (data['name'] as String?) ?? 'روعة',
      action: action,
    );
  }

  Map<String, dynamic> _dataMap(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  String _newToken() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}
