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
import '../../../auth/data/services/auth_session.dart';
import '../../../shop/data/models/category_model.dart';
import '../../../shop/data/models/category_model.dart';
import '../../../shop/data/models/home_feed.dart';
import '../../../shop/data/models/product_model.dart';
import '../../../shop/data/services/orders_api.dart';
import '../../../shop/domain/entities/order_entity.dart';
import '../../../shop/presentation/manager/cart_cubit.dart';
import '../../../shop/presentation/manager/catalog_cubit.dart';
import '../../../shop/presentation/widgets/main_shell_scope.dart';

part 'ai_controller_state.dart';

typedef _NavIntent = ({
  int? tab,
  String? route,
  Object? args,
  String? sheet,
  bool checkout,
  String label,
});

class AiControllerCubit extends Cubit<AiControllerState> {
  final AiChatApi _aiChatApi;
  final VoiceService _voiceService;
  final CartCubit _cartCubit;
  final CatalogCubit? _catalogCubit;

  AiControllerCubit({
    required AiChatApi aiChatApi,
    required VoiceService voiceService,
    required CartCubit cartCubit,
    CatalogCubit? catalogCubit,
  })  : _aiChatApi = aiChatApi,
        _voiceService = voiceService,
        _cartCubit = cartCubit,
        _catalogCubit = catalogCubit,
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
        'أهلاً بك في AIMstore! كيف يمكنني مساعدتك اليوم؟',
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
    final config = state.config;
    if (config != null && !config.enabled) {
      emit(state.copyWith(errorMessage: 'المساعد الذكي متوقف مؤقتاً من لوحة التحكم.'));
      return;
    }
    if (config != null &&
        !config.guestsAllowed &&
        !AuthSession.instance.isLoggedIn) {
      emit(state.copyWith(errorMessage: 'سجّل دخولك لاستخدام المساعد الذكي.'));
      return;
    }
    if (!(config?.sttEnabled ?? true)) {
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

    // لا نُعيد إدراج رسالة المستخدم — هي موجودة مسبقاً بعد فشل الرد.
    if (state.isThinking) return;
    emit(state.copyWith(
      status: AiProcessingStatus.thinking,
      clearError: true,
      clearToast: true,
    ));

    try {
      final result = await _aiChatApi.chat(
        message: lastUser.content,
        conversationId: state.conversationId,
      );
      final response = ChatMessageModel.fromGeminiResponse(
        result.reply,
        products: result.products,
      );

      emit(state.copyWith(
        messages: [...state.messages, response],
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
      debugPrint('[AiController] retryLast error: $e');
      emit(state.copyWith(
        status: AiProcessingStatus.error,
        errorMessage: _mapError(e),
      ));
    }
  }

  Future<void> _handleUserInput(String userText) async {
    if (state.isThinking) return;

    final config = state.config;
    if (config != null && !config.enabled) {
      emit(state.copyWith(
        status: AiProcessingStatus.error,
        errorMessage: 'المساعد الذكي متوقف مؤقتاً من لوحة التحكم.',
      ));
      return;
    }

    if (config != null &&
        !config.guestsAllowed &&
        !AuthSession.instance.isLoggedIn) {
      emit(state.copyWith(
        status: AiProcessingStatus.error,
        errorMessage: 'سجّل دخولك لاستخدام المساعد الذكي.',
      ));
      return;
    }

    if (_isCheckoutIntent(userText)) {
      await _handleCheckoutIntent();
      return;
    }

    if (_isClearCartIntent(userText)) {
      await _handleClearCartIntent(userText);
      return;
    }

    if (_isCartTotalIntent(userText)) {
      await _handleCartTotalIntent(userText);
      return;
    }

    final nav = _matchAppGuideIntent(userText);
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
      ));
    }
  }

  Future<void> _applyServerAction(AiChatAction? action) async {
    if (action == null || action.isEmpty) return;
    switch (action.type) {
      case 'clear_cart':
        _cartCubit.clearCart();
        emit(state.copyWith(statusToast: 'تم تفريغ السلة'));
      case 'navigate':
        final resolved = _resolveNavTarget(
          action.target ?? '',
          categoryName: action.categoryName,
          productId: action.productId,
          query: action.query,
        );
        if (resolved != null) {
          _emitNavigation(resolved);
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

  void _emitNavigation(_NavIntent nav) {
    emit(state.copyWith(
      checkoutRequested: nav.checkout,
      pendingTabIndex: nav.tab,
      pendingRoute: nav.route,
      pendingRouteArgs: nav.args,
      pendingSheet: nav.sheet,
      clearPendingTab: nav.tab == null,
      clearPendingRoute: nav.route == null,
      clearPendingRouteArgs: nav.args == null,
      clearPendingSheet: nav.sheet == null,
      statusToast: 'الانتقال إلى ${nav.label}…',
    ));
  }

  Future<void> _handleNavigateIntent(String userText, _NavIntent nav) async {
    final userMsg = ChatMessageModel.userMessage(userText);
    final replyText = 'حسناً، سأنقلك إلى ${nav.label} الآن.';
    final reply = ChatMessageModel.fromGeminiResponse(replyText);
    emit(state.copyWith(
      messages: [...state.messages, userMsg, reply],
      status: AiProcessingStatus.idle,
      clearTrackedOrder: true,
      checkoutRequested: nav.checkout,
      pendingTabIndex: nav.tab,
      pendingRoute: nav.route,
      pendingRouteArgs: nav.args,
      pendingSheet: nav.sheet,
      clearPendingTab: nav.tab == null,
      clearPendingRoute: nav.route == null,
      clearPendingRouteArgs: nav.args == null,
      clearPendingSheet: nav.sheet == null,
    ));
    await _maybeSpeak(replyText, isWelcome: false);
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
        clearPendingRouteArgs: true,
        clearPendingSheet: true,
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

  bool _isCartTotalIntent(String text) {
    final t = text.toLowerCase();
    if (!_containsAny(t, ['سلة', 'سلتي', 'cart'])) return false;
    if (_isClearCartIntent(t) || _isCheckoutIntent(t)) return false;
    return _containsAny(t, [
      'اجمالي',
      'إجمالي',
      'مجموع',
      'قيمة',
      'تكلف',
      'كام',
      'كم',
      'فلوس',
      'سعر',
      'total',
      'how much',
      'amount',
    ]);
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

  _NavIntent? _matchAppGuideIntent(String text) {
    final t = text.trim();
    if (t.isEmpty) return null;
    final lower = t.toLowerCase();

    // بيانات الحساب / تعديل الاسم
    if (_containsAny(lower, [
      'أغير بياناتي',
      'اغير بياناتي',
      'تعديل بياناتي',
      'غيّر بياناتي',
      'غير بياناتي',
      'أشتي أغيّر بياناتي',
      'اشتي اغير بياناتي',
      'أبي أعدل بياناتي',
      'ابي اعدل بياناتي',
      'تعديل الاسم',
      'غيّر اسمي',
      'غير اسمي',
      'تغيير الاسم',
      'عدل اسمي',
      'عدّل اسمي',
      'edit profile',
      'change name',
      'my profile data',
    ])) {
      if (!AuthSession.instance.isLoggedIn) {
        return (
          tab: null,
          route: AppRouter.phoneLogin,
          args: null,
          sheet: null,
          checkout: false,
          label: 'تسجيل الدخول',
        );
      }
      return (
        tab: null,
        route: null,
        args: null,
        sheet: 'edit_name',
        checkout: false,
        label: 'تعديل بيانات الحساب',
      );
    }

    // العناوين
    if (_containsAny(lower, [
      'عناوين',
      'عنوان التوصيل',
      'عنواني',
      'مواقع التوصيل',
      'عناوين التوصيل',
      'addresses',
      'delivery address',
    ])) {
      if (_containsAny(lower, ['أضف', 'اضف', 'جديد', 'add'])) {
        return (
          tab: null,
          route: AppRouter.addAddress,
          args: null,
          sheet: null,
          checkout: false,
          label: 'إضافة عنوان',
        );
      }
      return (
        tab: null,
        route: null,
        args: null,
        sheet: 'addresses',
        checkout: false,
        label: 'عناوين التوصيل',
      );
    }

    if (_containsAny(lower, ['إعدادات', 'اعدادات', 'settings'])) {
      return (
        tab: null,
        route: AppRouter.accountSettings,
        args: null,
        sheet: null,
        checkout: false,
        label: 'الإعدادات',
      );
    }

    if (_containsAny(lower, ['مفضل', 'المفضلة', 'favorites', 'wishlist'])) {
      return (
        tab: null,
        route: AppRouter.favorites,
        args: null,
        sheet: null,
        checkout: false,
        label: 'المفضلة',
      );
    }

    if (_containsAny(lower, [
      'تسجيل الدخول',
      'سجل دخول',
      'سجّل دخول',
      'login',
      'sign in',
    ])) {
      return (
        tab: null,
        route: AppRouter.phoneLogin,
        args: null,
        sheet: null,
        checkout: false,
        label: 'تسجيل الدخول',
      );
    }

    if (_containsAny(lower, ['المقاضي', 'مقاضي', 'groceries'])) {
      return (
        tab: null,
        route: AppRouter.groceriesSection,
        args: null,
        sheet: null,
        checkout: false,
        label: 'قسم المقاضي',
      );
    }

    // قسم عرض في تبويب الأقسام: «الخضروات والفواكه» — بدون صفحة جديدة
    final sectionFromPhrase = _extractCategoryPhrase(t);
    final sectionHit =
        _findDisplaySectionByName(sectionFromPhrase ?? t);
    if (sectionHit != null &&
        (sectionFromPhrase != null ||
            _containsAny(lower, [
              'قسم',
              'تصنيف',
              'category',
              'افتح',
              'وديني',
              'خذني',
              'روح',
              'انقلني',
              'انتقل',
            ]))) {
      return (
        tab: MainShellTabs.categories,
        route: null,
        args: sectionHit.id,
        sheet: null,
        checkout: false,
        label: 'قسم ${sectionHit.name}',
      );
    }

    // قسم فرعي بالاسم → نفتح قسم العرض الأب داخل تبويب الأقسام
    final categoryFromPhrase = sectionFromPhrase;
    final categoryHit = _findCategoryByName(categoryFromPhrase ?? t);
    if (categoryHit != null &&
        (categoryFromPhrase != null ||
            _containsAny(lower, [
              'قسم',
              'تصنيف',
              'category',
              'افتح',
              'وديني',
              'خذني',
              'روح',
              'انقلني',
              'انتقل',
            ]))) {
      final parent = _displaySectionContaining(categoryHit.id);
      if (parent != null) {
        return (
          tab: MainShellTabs.categories,
          route: null,
          args: parent.id,
          sheet: null,
          checkout: false,
          label: 'قسم ${parent.name}',
        );
      }
      return (
        tab: MainShellTabs.categories,
        route: null,
        args: null,
        sheet: null,
        checkout: false,
        label: 'الأقسام',
      );
    }

    // منتج بالاسم إن وُجد في الكتالوج مع نية فتح
    if (_containsAny(lower, ['افتح منتج', 'تفاصيل', 'عرض المنتج', 'product'])) {
      final product = _findProductByName(t);
      if (product != null) {
        return (
          tab: null,
          route: AppRouter.productDetails,
          args: product,
          sheet: null,
          checkout: false,
          label: product.name,
        );
      }
    }

    final wantsNav = _containsAny(lower, [
      'انتقل',
      'انقلني',
      'وديني',
      'ودّني',
      'روح',
      'خذني',
      'افتح',
      'اذهب',
      'navigate',
      'open',
      'go to',
      'أبي أروح',
      'ابي اروح',
      'أشتي أروح',
      'اشتي اروح',
    ]);

    if (!wantsNav && categoryFromPhrase == null) {
      // بدون فعل تنقل: وجهات مباشرة شائعة
      if (_containsAny(lower, ['طلباتي', 'الطلبات'])) {
        return (
          tab: null,
          route: AppRouter.orders,
          args: null,
          sheet: null,
          checkout: false,
          label: 'طلباتي',
        );
      }
      if (_containsAny(lower, ['إشعارات', 'اشعارات', 'الإشعارات'])) {
        return (
          tab: null,
          route: AppRouter.notifications,
          args: null,
          sheet: null,
          checkout: false,
          label: 'الإشعارات',
        );
      }
      if (_containsAny(lower, ['حسابي', 'صفحتي الشخصية'])) {
        return (
          tab: MainShellTabs.profile,
          route: null,
          args: null,
          sheet: null,
          checkout: false,
          label: 'حسابي',
        );
      }
      if (_containsAny(lower, ['الأقسام', 'اقسام', 'صفحة الأقسام'])) {
        return (
          tab: MainShellTabs.categories,
          route: null,
          args: null,
          sheet: null,
          checkout: false,
          label: 'الأقسام',
        );
      }
      if (_containsAny(lower, ['السلة', 'سلتي'])) {
        return (
          tab: MainShellTabs.cart,
          route: null,
          args: null,
          sheet: 'cart',
          checkout: false,
          label: 'السلة',
        );
      }
      if (_containsAny(lower, ['الرئيسية', 'الهوم'])) {
        return (
          tab: MainShellTabs.home,
          route: null,
          args: null,
          sheet: null,
          checkout: false,
          label: 'الرئيسية',
        );
      }
      return null;
    }

    return _resolveNavTarget(lower);
  }

  _NavIntent? _resolveNavTarget(
    String target, {
    String? categoryName,
    String? productId,
    String? query,
  }) {
    final t = target.trim().toLowerCase();

    if (categoryName != null && categoryName.trim().isNotEmpty) {
      final section = _findDisplaySectionByName(categoryName);
      if (section != null) {
        return (
          tab: MainShellTabs.categories,
          route: null,
          args: section.id,
          sheet: null,
          checkout: false,
          label: 'قسم ${section.name}',
        );
      }
      final cat = _findCategoryByName(categoryName);
      if (cat != null) {
        final parent = _displaySectionContaining(cat.id);
        return (
          tab: MainShellTabs.categories,
          route: null,
          args: parent?.id,
          sheet: null,
          checkout: false,
          label: parent != null ? 'قسم ${parent.name}' : 'الأقسام',
        );
      }
    }

    if (productId != null && productId.trim().isNotEmpty) {
      final product = _catalogCubit?.state.productsById[productId.trim()];
      if (product != null) {
        return (
          tab: null,
          route: AppRouter.productDetails,
          args: product,
          sheet: null,
          checkout: false,
          label: product.name,
        );
      }
    }

    if (t.isEmpty) return null;

    if (_containsAny(t, [
          'edit_profile',
          'profile_edit',
          'complete_name',
          'تعديل_الحساب',
          'تعديل_الاسم',
        ]) ||
        t == 'name' ||
        t == 'بيانات' ||
        t == 'edit-name') {
      if (!AuthSession.instance.isLoggedIn) {
        return (
          tab: null,
          route: AppRouter.phoneLogin,
          args: null,
          sheet: null,
          checkout: false,
          label: 'تسجيل الدخول',
        );
      }
      return (
        tab: null,
        route: null,
        args: null,
        sheet: 'edit_name',
        checkout: false,
        label: 'تعديل بيانات الحساب',
      );
    }

    if (_containsAny(t, ['addresses', 'عناوين', 'address'])) {
      return (
        tab: null,
        route: null,
        args: null,
        sheet: 'addresses',
        checkout: false,
        label: 'عناوين التوصيل',
      );
    }

    if (_containsAny(t, ['add_address', 'إضافة_عنوان', 'اضف_عنوان'])) {
      return (
        tab: null,
        route: AppRouter.addAddress,
        args: null,
        sheet: null,
        checkout: false,
        label: 'إضافة عنوان',
      );
    }

    if (_containsAny(t, ['settings', 'إعدادات', 'اعدادات'])) {
      return (
        tab: null,
        route: AppRouter.accountSettings,
        args: null,
        sheet: null,
        checkout: false,
        label: 'الإعدادات',
      );
    }

    if (_containsAny(t, ['favorites', 'مفضلة', 'المفضلة'])) {
      return (
        tab: null,
        route: AppRouter.favorites,
        args: null,
        sheet: null,
        checkout: false,
        label: 'المفضلة',
      );
    }

    if (_containsAny(t, ['login', 'phone_login', 'تسجيل_الدخول'])) {
      return (
        tab: null,
        route: AppRouter.phoneLogin,
        args: null,
        sheet: null,
        checkout: false,
        label: 'تسجيل الدخول',
      );
    }

    if (_containsAny(t, ['groceries', 'المقاضي', 'مقاضي'])) {
      return (
        tab: null,
        route: AppRouter.groceriesSection,
        args: null,
        sheet: null,
        checkout: false,
        label: 'قسم المقاضي',
      );
    }

    if (_containsAny(t, ['checkout', 'إتمام_الطلب', 'اتمام_الطلب']) ||
        t == 'دفع') {
      return (
        tab: null,
        route: null,
        args: null,
        sheet: null,
        checkout: true,
        label: 'إتمام الطلب',
      );
    }

    if (_containsAny(t, ['cart_sheet', 'سلة_منبثقة'])) {
      return (
        tab: null,
        route: null,
        args: null,
        sheet: 'cart',
        checkout: false,
        label: 'السلة',
      );
    }

    if (_containsAny(t, ['home', 'رئيسي', 'الرئيسية', 'الهوم'])) {
      return (
        tab: MainShellTabs.home,
        route: null,
        args: null,
        sheet: null,
        checkout: false,
        label: 'الرئيسية',
      );
    }

    if (_containsAny(t, ['categories', 'أقسام', 'اقسام', 'التصنيف'])) {
      return (
        tab: MainShellTabs.categories,
        route: null,
        args: null,
        sheet: null,
        checkout: false,
        label: 'الأقسام',
      );
    }

    if (_containsAny(t, ['cart', 'السلة', 'سلتي']) || t == 'سلة') {
      return (
        tab: MainShellTabs.cart,
        route: null,
        args: null,
        sheet: 'cart',
        checkout: false,
        label: 'السلة',
      );
    }

    if (_containsAny(t, ['profile', 'حسابي', 'الحساب', 'بروفايل'])) {
      return (
        tab: MainShellTabs.profile,
        route: null,
        args: null,
        sheet: null,
        checkout: false,
        label: 'حسابي',
      );
    }

    if (_containsAny(t, ['orders', 'طلباتي', 'الطلبات'])) {
      return (
        tab: null,
        route: AppRouter.orders,
        args: null,
        sheet: null,
        checkout: false,
        label: 'طلباتي',
      );
    }

    if (_containsAny(t, ['search', 'البحث']) || t == 'بحث') {
      return (
        tab: null,
        route: AppRouter.search,
        args: null,
        sheet: null,
        checkout: false,
        label: query != null && query.isNotEmpty ? 'البحث عن $query' : 'البحث',
      );
    }

    if (_containsAny(t, ['notifications', 'إشعار', 'اشعار', 'الإشعارات'])) {
      return (
        tab: null,
        route: AppRouter.notifications,
        args: null,
        sheet: null,
        checkout: false,
        label: 'الإشعارات',
      );
    }

    if (t == 'category' || t.startsWith('category:')) {
      final name = categoryName ?? t.replaceFirst('category:', '').trim();
      final section = _findDisplaySectionByName(name);
      if (section != null) {
        return (
          tab: MainShellTabs.categories,
          route: null,
          args: section.id,
          sheet: null,
          checkout: false,
          label: 'قسم ${section.name}',
        );
      }
      final cat = _findCategoryByName(name);
      if (cat != null) {
        final parent = _displaySectionContaining(cat.id);
        return (
          tab: MainShellTabs.categories,
          route: null,
          args: parent?.id,
          sheet: null,
          checkout: false,
          label: parent != null ? 'قسم ${parent.name}' : 'الأقسام',
        );
      }
    }

    return null;
  }

  String? _extractCategoryPhrase(String text) {
    final patterns = [
      RegExp(r'قسم\s+(.+)$'),
      RegExp(r'تصنيف\s+(.+)$'),
      RegExp(r'category\s+(.+)$', caseSensitive: false),
    ];
    for (final re in patterns) {
      final m = re.firstMatch(text.trim());
      if (m != null) {
        final name = m.group(1)?.trim() ?? '';
        if (name.isNotEmpty) return name;
      }
    }
    return null;
  }

  CategoryModel? _findCategoryByName(String raw) {
    final needle = _normalizeNavText(raw);
    if (needle.isEmpty) return null;
    final cats = _catalogCubit?.state.allCategories ?? const <CategoryModel>[];
    if (cats.isEmpty) return null;

    CategoryModel? best;
    var bestLen = 0;
    for (final cat in cats) {
      final name = _normalizeNavText(cat.name);
      if (name.isEmpty) continue;
      if (needle == name || needle.contains(name) || name.contains(needle)) {
        if (name.length >= bestLen) {
          best = cat;
          bestLen = name.length;
        }
      }
    }
    return best;
  }

  DisplaySectionModel? _findDisplaySectionByName(String raw) {
    final needle = _normalizeNavText(raw);
    if (needle.isEmpty) return null;
    final sections =
        _catalogCubit?.state.displaySections ?? const <DisplaySectionModel>[];
    if (sections.isEmpty) return null;

    DisplaySectionModel? best;
    var bestLen = 0;
    for (final section in sections) {
      final name = _normalizeNavText(section.name);
      if (name.isEmpty) continue;
      if (needle == name || needle.contains(name) || name.contains(needle)) {
        if (name.length >= bestLen) {
          best = section;
          bestLen = name.length;
        }
      }
    }
    return best;
  }

  DisplaySectionModel? _displaySectionContaining(String categoryId) {
    final sections =
        _catalogCubit?.state.displaySections ?? const <DisplaySectionModel>[];
    for (final section in sections) {
      for (final cat in section.categories) {
        if (cat.id == categoryId) return section;
      }
    }
    return null;
  }

  static String _normalizeNavText(String raw) {
    return raw
        .trim()
        .toLowerCase()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  ProductModel? _findProductByName(String raw) {
    final needle = raw.trim();
    if (needle.isEmpty) return null;
    final products = _catalogCubit?.state.productsById.values ?? const [];
    ProductModel? best;
    var bestLen = 0;
    for (final p in products) {
      final name = p.name.trim();
      if (name.isEmpty) continue;
      if (needle.contains(name) || name.contains(needle)) {
        if (name.length >= bestLen) {
          best = p;
          bestLen = name.length;
        }
      }
    }
    return best;
  }

  static bool _containsAny(String haystack, List<String> needles) {
    for (final n in needles) {
      if (haystack.contains(n.toLowerCase())) return true;
    }
    return false;
  }

  int? _tabForTarget(String target) {
    return _resolveNavTarget(target)?.tab;
  }

  String? _routeForTarget(String target) {
    return _resolveNavTarget(target)?.route;
  }

  Future<void> addToCart(ProductModel product) async {
    _cartCubit.addToCart(product);
    emit(state.copyWith(statusToast: 'تمت إضافة «${product.name}» للسلة'));
    await _suggestComplement(product);
  }

  /// بعد إضافة المنتج من كارد الواجهة مباشرة (بدون تكرار addToCart).
  Future<void> suggestComplementFor(ProductModel product) async {
    emit(state.copyWith(statusToast: 'تمت إضافة «${product.name}» للسلة'));
    await _suggestComplement(product);
  }

  void removeFromCart(String productId) {
    _cartCubit.removeFromCart(productId);
  }

  void clearCart() {
    _cartCubit.clearCart();
  }

  Future<void> _handleCartTotalIntent(String userText) async {
    final userMsg = ChatMessageModel.userMessage(userText);
    final cart = _cartCubit.state;
    final String replyText;
    if (cart.isEmpty) {
      replyText = 'سلتك فارغة حالياً. أضف منتجات وسأحسب الإجمالي فوراً.';
    } else {
      final count = cart.totalQuantity;
      final total = cart.total.toStringAsFixed(2);
      replyText =
          'إجمالي سلتك الآن $total ر.س، وفيها $count قطعة.';
    }
    final reply = ChatMessageModel.fromGeminiResponse(replyText);
    emit(state.copyWith(
      messages: [...state.messages, userMsg, reply],
      status: AiProcessingStatus.idle,
      clearTrackedOrder: true,
      clearError: true,
    ));
    await _maybeSpeak(replyText, isWelcome: false);
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
    'AIM للدفع',
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
