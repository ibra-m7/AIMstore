import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/services/ai_chat_api.dart';
import '../../data/services/voice_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../../shop/data/models/product_model.dart';
import '../../../shop/data/services/orders_api.dart';
import '../../../shop/domain/entities/order_entity.dart';
import '../../../shop/presentation/manager/cart_cubit.dart';
import '../../../shop/presentation/widgets/main_shell_scope.dart';

part 'ai_controller_state.dart';

class AiControllerCubit extends Cubit<AiControllerState> {
  final AiChatApi _aiChatApi;
  final VoiceService _voiceService;
  final CartCubit _cartCubit;

  AiControllerCubit({
    required AiChatApi aiChatApi,
    required VoiceService voiceService,
    required CartCubit cartCubit,
  })  : _aiChatApi = aiChatApi,
        _voiceService = voiceService,
        _cartCubit = cartCubit,
        super(const AiControllerState()) {
    _setupCallbacks();
  }

  void _setupCallbacks() {
    _voiceService.onPartialResult = (text) {
      if (isClosed) return;
      emit(state.copyWith(partialSpeechText: text));
    };

    _voiceService.onFinalResult = (text) {
      if (isClosed) return;
      emit(state.copyWith(partialSpeechText: ''));
      _handleUserInput(text);
    };

    _voiceService.onStateChanged = (voiceState) {
      if (isClosed) return;
      switch (voiceState) {
        case VoiceState.listening:
          emit(state.copyWith(status: AiProcessingStatus.listening));
        case VoiceState.speaking:
          emit(state.copyWith(status: AiProcessingStatus.speaking));
        case VoiceState.idle:
        case VoiceState.processing:
          if (state.status != AiProcessingStatus.thinking) {
            emit(state.copyWith(status: AiProcessingStatus.idle));
          }
        case VoiceState.error:
          break;
      }
    };

    _voiceService.onError = (message) {
      if (isClosed) return;
      emit(state.copyWith(
        status: AiProcessingStatus.idle,
        errorMessage: message,
      ));
    };

    _voiceService.onSpeakComplete = () {
      if (isClosed) return;
      emit(state.copyWith(status: AiProcessingStatus.idle));
    };
  }

  Future<void> initConversation() async {
    if (state.messages.isNotEmpty) return;
    if (state.isThinking) return;
    emit(state.copyWith(status: AiProcessingStatus.thinking, clearError: true));
    try {
      final config = await _aiChatApi.config();
      await _voiceService.setSpeechRate(config.ttsRate);
      final voiceOn = await _resolveVoicePreference(config);
      final chips = config.suggestionChips.isNotEmpty
          ? config.suggestionChips
          : const [
              'أبحث عن إكسسوارات للمنزل',
              'ما أفضل خيارات الهدايا؟',
              'قارن لي بين منتجات مشابهة',
              'منتجات العناية بالمنزل',
            ];
      final welcomeText = config.enabled
          ? config.welcome
          : 'المساعد الذكي متوقف مؤقتاً. يمكنك تصفح المتجر كالمعتاد.';
      final welcome = ChatMessageModel.fromGeminiResponse(welcomeText);
      emit(state.copyWith(
        messages: [welcome],
        assistantName: config.name,
        config: config,
        voiceOn: voiceOn,
        suggestionChips: chips,
        status: AiProcessingStatus.idle,
      ));
      if (config.enabled &&
          voiceOn &&
          config.ttsEnabled &&
          config.ttsWelcome) {
        await _voiceService.speak(welcome.content);
      }
    } catch (e) {
      debugPrint('[AiController] initConversation error: $e');
      final offlineWelcome = ChatMessageModel.fromGeminiResponse(
        'أهلاً بك في روعة الخمسة! كيف يمكنني مساعدتك اليوم؟',
      );
      emit(state.copyWith(
        messages: [offlineWelcome],
        status: AiProcessingStatus.idle,
        statusToast: 'تعذّر تحميل إعدادات المساعد، تم استخدام الوضع الافتراضي',
      ));
    }
  }

  Future<bool> _resolveVoicePreference(AiConfig config) async {
    if (!config.ttsEnabled) return false;
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(AiChatApi.voicePrefKey)) {
      return config.ttsDefaultOn;
    }
    return prefs.getBool(AiChatApi.voicePrefKey) ?? config.ttsDefaultOn;
  }

  Future<void> toggleVoice() async {
    if (!(state.config?.ttsEnabled ?? true)) {
      emit(state.copyWith(
        statusToast: 'الصوت متوقف من إعدادات المتجر',
      ));
      return;
    }
    final next = !state.voiceOn;
    if (!next) {
      await _voiceService.stop();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AiChatApi.voicePrefKey, next);
    emit(state.copyWith(
      voiceOn: next,
      statusToast: next ? 'تم تفعيل صوت المساعد' : 'تم كتم صوت المساعد',
      status: next ? state.status : AiProcessingStatus.idle,
    ));
  }

  Future<void> _maybeSpeak(String text, {required bool isWelcome}) async {
    final config = state.config;
    if (config == null || !config.ttsEnabled || !state.voiceOn) return;
    if (isWelcome && !config.ttsWelcome) return;
    if (!isWelcome && !config.ttsReplies) return;
    await _voiceService.speak(text);
  }

  Future<void> startVoiceInput() async {
    if (!(state.config?.sttEnabled ?? true)) {
      emit(state.copyWith(errorMessage: 'الميكروفون متوقف من إعدادات المتجر'));
      return;
    }
    if (state.isListening) return;
    if (state.isSpeaking) await _voiceService.stop();

    emit(state.copyWith(partialSpeechText: '', clearError: true));

    final started = await _voiceService.startListening();
    if (!started) {
      emit(state.copyWith(
        errorMessage: 'تعذّر الوصول للميكروفون. تحقق من الصلاحيات.',
      ));
    }
  }

  Future<void> stopVoiceInput() async {
    if (!state.isListening) return;
    final text = await _voiceService.stopListening();
    if (text.trim().isNotEmpty) {
      _handleUserInput(text);
    } else {
      emit(state.copyWith(status: AiProcessingStatus.idle));
    }
  }

  Future<void> sendTextMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    await _handleUserInput(trimmed);
  }

  Future<void> retryLast() async {
    final lastUser = state.messages.reversed.cast<ChatMessage?>().firstWhere(
          (m) => m?.isUser == true,
          orElse: () => null,
        );
    if (lastUser == null) return;
    await _handleUserInput(lastUser.content);
  }

  Future<void> _handleUserInput(String userText) async {
    if (state.isThinking) return;

    if (_isCheckoutIntent(userText)) {
      await _handleCheckoutIntent();
      return;
    }

    if (_isClearCartIntent(userText)) {
      await _handleClearCartIntent(userText);
      return;
    }

    final nav = _matchNavigateIntent(userText);
    if (nav != null) {
      await _handleNavigateIntent(userText, nav);
      return;
    }

    final orderNo = _extractOrderNumber(userText);
    if (orderNo != null && _isTrackOrderIntent(userText)) {
      await _handleTrackOrderIntent(userText, orderNo);
      return;
    }

    if (_isCartIntent(userText) && state.lastMentionedProduct != null) {
      await _handleCartIntent();
      return;
    }

    final userMsg = ChatMessageModel.userMessage(userText);
    final updatedMessages = [...state.messages, userMsg];

    emit(state.copyWith(
      messages: updatedMessages,
      status: AiProcessingStatus.thinking,
      partialSpeechText: '',
      clearError: true,
      clearToast: true,
      clearTrackedOrder: true,
    ));

    try {
      final result = await _aiChatApi.chat(
        message: userText,
        conversationId: state.conversationId,
      );
      final response = ChatMessageModel.fromGeminiResponse(
        result.reply,
        products: result.products,
      );

      emit(state.copyWith(
        messages: [...updatedMessages, response],
        conversationId: result.conversationId > 0
            ? result.conversationId
            : state.conversationId,
        lastMentionedProduct: result.products.isNotEmpty
            ? result.products.last
            : null,
        clearLastProduct: result.products.isEmpty,
        status: AiProcessingStatus.idle,
      ));

      await _applyServerAction(result.action);
      await _maybeSpeak(response.content, isWelcome: false);
    } catch (e) {
      debugPrint('[AiController] processUserQuery error: $e');
      emit(state.copyWith(
        messages: updatedMessages,
        status: AiProcessingStatus.error,
        errorMessage: _mapError(e),
        statusToast: _mapError(e),
      ));
    }
  }

  Future<void> _applyServerAction(AiChatAction? action) async {
    if (action == null) return;
    switch (action.type) {
      case 'clear_cart':
        _cartCubit.clearCart();
        emit(state.copyWith(statusToast: 'تم تفريغ السلة'));
      case 'navigate':
        final target = (action.target ?? '').toLowerCase();
        final tab = _tabForTarget(target);
        if (tab != null) {
          emit(state.copyWith(pendingTabIndex: tab));
        } else {
          final route = _routeForTarget(target);
          if (route != null) {
            emit(state.copyWith(pendingRoute: route));
          }
        }
      case 'show_order':
        final number = action.orderNumber;
        if (number != null && number.isNotEmpty) {
          await _loadTrackedOrder(number);
        }
      default:
        break;
    }
  }

  Future<void> _loadTrackedOrder(String orderNo) async {
    try {
      final orders = await OrdersApi.instance.list();
      final match = orders.cast<OrderEntity?>().firstWhere(
            (o) =>
                o!.id == orderNo ||
                o.id.endsWith(orderNo) ||
                o.id.contains(orderNo),
            orElse: () => null,
          );
      if (match != null) {
        emit(state.copyWith(trackedOrder: match));
      }
    } catch (_) {
      // تجاهل — الرد النصي كافٍ إن فشل التحميل.
    }
  }

  Future<void> _handleClearCartIntent(String userText) async {
    final userMsg = ChatMessageModel.userMessage(userText);
    _cartCubit.clearCart();
    const replyText = 'تم تفريغ السلة بنجاح. يمكنك متابعة التسوق متى شئت.';
    final reply = ChatMessageModel.fromGeminiResponse(replyText);
    emit(state.copyWith(
      messages: [...state.messages, userMsg, reply],
      status: AiProcessingStatus.idle,
      statusToast: 'تم تفريغ السلة',
      clearTrackedOrder: true,
      clearLastProduct: true,
    ));
    await _maybeSpeak(replyText, isWelcome: false);
  }

  Future<void> _handleNavigateIntent(
    String userText,
    ({int? tab, String? route, String label}) nav,
  ) async {
    final userMsg = ChatMessageModel.userMessage(userText);
    final replyText = 'حسناً، سأنقلك إلى ${nav.label} الآن.';
    final reply = ChatMessageModel.fromGeminiResponse(replyText);
    emit(state.copyWith(
      messages: [...state.messages, userMsg, reply],
      status: AiProcessingStatus.idle,
      clearTrackedOrder: true,
      pendingTabIndex: nav.tab,
      pendingRoute: nav.route,
      clearPendingTab: nav.tab == null,
      clearPendingRoute: nav.route == null,
    ));
    await _maybeSpeak(replyText, isWelcome: false);
  }

  Future<void> _handleTrackOrderIntent(String userText, String orderNo) async {
    final userMsg = ChatMessageModel.userMessage(userText);
    emit(state.copyWith(
      messages: [...state.messages, userMsg],
      status: AiProcessingStatus.thinking,
      clearError: true,
      clearTrackedOrder: true,
    ));

    try {
      final orders = await OrdersApi.instance.list();
      final match = orders.cast<OrderEntity?>().firstWhere(
            (o) =>
                o!.id == orderNo ||
                o.id.endsWith(orderNo) ||
                o.id.contains(orderNo),
            orElse: () => null,
          );

      if (match == null) {
        const replyText =
            'لم أجد طلباً بهذا الرقم ضمن طلباتك. تأكد من الرقم أو سجّل دخولك أولاً.';
        final reply = ChatMessageModel.fromGeminiResponse(replyText);
        emit(state.copyWith(
          messages: [...state.messages, reply],
          status: AiProcessingStatus.idle,
        ));
        await _maybeSpeak(replyText, isWelcome: false);
        return;
      }

      final replyText =
          'إليك تفاصيل طلبك رقم ${match.id}: الحالة «${match.status.label}» والإجمالي ${match.total.toStringAsFixed(2)} ر.س.';
      final reply = ChatMessageModel.fromGeminiResponse(replyText);
      emit(state.copyWith(
        messages: [...state.messages, reply],
        trackedOrder: match,
        status: AiProcessingStatus.idle,
      ));
      await _maybeSpeak(replyText, isWelcome: false);
    } on ApiException catch (e) {
      final msg = e.statusCode == 401
          ? 'سجّل دخولك أولاً لعرض تفاصيل طلباتك.'
          : e.message;
      final reply = ChatMessageModel.fromGeminiResponse(msg);
      emit(state.copyWith(
        messages: [...state.messages, reply],
        status: AiProcessingStatus.idle,
        errorMessage: msg,
      ));
    } catch (e) {
      final msg = _mapError(e);
      final reply = ChatMessageModel.fromGeminiResponse(msg);
      emit(state.copyWith(
        messages: [...state.messages, reply],
        status: AiProcessingStatus.idle,
        errorMessage: msg,
      ));
    }
  }

  void clearTrackedOrder() =>
      emit(state.copyWith(clearTrackedOrder: true));

  void clearPendingNavigation() => emit(state.copyWith(
        clearPendingTab: true,
        clearPendingRoute: true,
      ));

  bool _isClearCartIntent(String text) {
    final t = text.toLowerCase();
    const keys = [
      'فرغ السلة',
      'فرّغ السلة',
      'افرغ السلة',
      'أفرغ السلة',
      'امسح السلة',
      'احذف السلة',
      'تفريغ السلة',
      'clear cart',
      'empty cart',
    ];
    return keys.any(t.contains);
  }

  bool _isTrackOrderIntent(String text) {
    final t = text.toLowerCase();
    const keys = [
      'تتبع',
      'تتبع لي',
      'وين طلبي',
      'أين طلبي',
      'حالة الطلب',
      'تفاصيل الطلب',
      'طلب رقم',
      'الطلب رقم',
      'track order',
    ];
    return keys.any(t.contains);
  }

  String? _extractOrderNumber(String text) {
    final match = RegExp(r'(\d{1,12})').firstMatch(text);
    return match?.group(1);
  }

  ({int? tab, String? route, String label})? _matchNavigateIntent(String text) {
    final t = text.toLowerCase();
    final wantsNav = [
      'انتقل',
      'انقلني',
      'وديني',
      'روح',
      'خذني',
      'افتح',
      'اذهب',
      'ودّني',
      'navigate',
      'open',
      'go to',
    ].any(t.contains);
    if (!wantsNav) return null;

    if (t.contains('رئيسي') || t.contains('الهوم') || t.contains('home')) {
      return (tab: MainShellTabs.home, route: null, label: 'الرئيسية');
    }
    if (t.contains('أقسام') ||
        t.contains('اقسام') ||
        t.contains('التصنيف') ||
        t.contains('categories')) {
      return (tab: MainShellTabs.categories, route: null, label: 'الأقسام');
    }
    if (t.contains('سلة') || t.contains('cart')) {
      return (tab: MainShellTabs.cart, route: null, label: 'السلة');
    }
    if (t.contains('حساب') || t.contains('profile') || t.contains('بروفايل')) {
      return (tab: MainShellTabs.profile, route: null, label: 'حسابي');
    }
    if (t.contains('طلباتي') || t.contains('الطلبات') || t.contains('orders')) {
      return (tab: null, route: AppRouter.orders, label: 'طلباتي');
    }
    if (t.contains('بحث') || t.contains('search')) {
      return (tab: null, route: AppRouter.search, label: 'البحث');
    }
    if (t.contains('إشعار') ||
        t.contains('اشعار') ||
        t.contains('notifications')) {
      return (tab: null, route: AppRouter.notifications, label: 'الإشعارات');
    }
    return null;
  }

  int? _tabForTarget(String target) {
    return switch (target) {
      'home' || 'الرئيسية' => MainShellTabs.home,
      'categories' || 'الأقسام' || 'اقسام' => MainShellTabs.categories,
      'cart' || 'السلة' => MainShellTabs.cart,
      'profile' || 'حسابي' || 'الحساب' => MainShellTabs.profile,
      _ => null,
    };
  }

  String? _routeForTarget(String target) {
    return switch (target) {
      'orders' || 'الطلبات' || 'طلباتي' => AppRouter.orders,
      'search' || 'البحث' => AppRouter.search,
      'notifications' || 'الإشعارات' => AppRouter.notifications,
      _ => null,
    };
  }

  Future<void> addToCart(ProductModel product) async {
    _cartCubit.addToCart(product);
    emit(state.copyWith(statusToast: 'تمت إضافة «${product.name}» للسلة'));
    await _suggestComplement(product);
  }

  void removeFromCart(String productId) {
    _cartCubit.removeFromCart(productId);
  }

  void clearCart() {
    _cartCubit.clearCart();
  }

  Future<void> _handleCartIntent() async {
    final product = state.lastMentionedProduct;
    if (product == null) return;
    _cartCubit.addToCart(product);
    emit(state.copyWith(statusToast: 'تمت إضافة «${product.name}» للسلة'));
    await _suggestComplement(product);
  }

  Future<void> _suggestComplement(ProductModel addedProduct) async {
    if (isClosed || state.isThinking) return;

    emit(state.copyWith(status: AiProcessingStatus.thinking));

    try {
      final result = await _aiChatApi.chat(
        message:
            'أضفت «${addedProduct.name}» للسلة. أكّد الإضافة واقترح منتجات مكملة.',
        conversationId: state.conversationId,
        intent: 'complement',
        productId: addedProduct.id,
      );
      if (isClosed) return;

      final suggestion = ChatMessageModel.fromGeminiResponse(
        result.reply,
        products: result.products,
      );

      emit(state.copyWith(
        messages: [...state.messages, suggestion],
        conversationId: result.conversationId > 0
            ? result.conversationId
            : state.conversationId,
        lastMentionedProduct: result.products.isNotEmpty
            ? result.products.first
            : addedProduct,
        status: AiProcessingStatus.idle,
      ));

      await _maybeSpeak(suggestion.content, isWelcome: false);
    } catch (_) {
      if (!isClosed) emit(state.copyWith(status: AiProcessingStatus.idle));
    }
  }

  Future<void> _handleCheckoutIntent() async {
    if (_cartCubit.state.isEmpty) {
      const msg = 'السلة فارغة! أضف منتجات أولاً وسأساعدك في إتمام الطلب.';
      final reply = ChatMessageModel.fromGeminiResponse(msg);
      emit(state.copyWith(messages: [...state.messages, reply]));
      await _maybeSpeak(msg, isWelcome: false);
      return;
    }

    final count = _cartCubit.state.totalQuantity;
    final total = _cartCubit.state.total;
    final ttsText =
        'لديك $count قطعة بإجمالي ${total.toStringAsFixed(0)} \u{20C1}. سأنقلك لصفحة إتمام الطلب الآن.';
    final reply = ChatMessageModel.fromGeminiResponse(ttsText);

    emit(state.copyWith(
      messages: [...state.messages, reply],
      checkoutRequested: true,
      statusToast: 'الانتقال لإتمام الطلب…',
    ));
    await _maybeSpeak(ttsText, isWelcome: false);
  }

  void clearCheckoutRequest() =>
      emit(state.copyWith(checkoutRequested: false));

  void clearConversation() {
    emit(const AiControllerState());
  }

  void dismissError() => emit(state.copyWith(clearError: true));

  void clearToast() => emit(state.copyWith(clearToast: true));

  void switchInputMode(InputMode mode) =>
      emit(state.copyWith(inputMode: mode));

  static const _checkoutKeywords = [
    'أريد إنهاء الطلب',
    'إنهاء الطلب',
    'خلاص اشتريت',
    'أريد الدفع',
    'ادفع',
    'تأكيد الطلب',
    'إتمام الطلب',
    'أتمام الشراء',
    'أنهِ الطلب',
    'روعة للدفع',
    'checkout',
    'pay now',
  ];

  static bool _isCheckoutIntent(String text) {
    final lower = text.toLowerCase();
    return _checkoutKeywords.any((kw) => lower.contains(kw));
  }

  static const _addToCartKeywords = [
    'أضف للسلة',
    'أضيفه للسلة',
    'ضعه في السلة',
    'أضف هذا للسلة',
    'أريد شراء هذا',
    'أريد أشتريه',
    'سأشتريه',
    'أشتريه',
    'اشتره',
    'أريده',
    'خذه',
    'احجزه',
    'ضيفه',
    'أضفه',
    'للسلة',
    'add to cart',
  ];

  static bool _isCartIntent(String text) {
    final lower = text.toLowerCase();
    return _addToCartKeywords.any((kw) => lower.contains(kw));
  }

  String _mapError(Object e) {
    if (e is ApiException) return e.message;
    if (e is NetworkException) return e.message;
    if (e is ServerException) return e.message;

    final raw = e.toString();
    debugPrint('[AiController] _mapError raw: $raw');

    if (raw.contains('network') ||
        raw.contains('socket') ||
        raw.contains('SocketException') ||
        raw.contains('Failed host lookup')) {
      return 'لا يوجد اتصال بالإنترنت';
    }
    if (raw.contains('timeout') || raw.contains('TimeoutException')) {
      return 'انتهت مهلة الاتصال، حاول مجدداً';
    }
    return 'تعذّر الرد الآن. حاول مجدداً';
  }

  @override
  Future<void> close() async {
    await _voiceService.stop();
    return super.close();
  }
}
