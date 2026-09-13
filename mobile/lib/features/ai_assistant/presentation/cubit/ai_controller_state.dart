part of 'ai_controller_cubit.dart';

enum InputMode { text, voice }

enum AiProcessingStatus {
  idle,
  listening,
  thinking,
  speaking,
  error,
}

class AiControllerState extends Equatable {
  final List<ChatMessage> messages;
  final AiProcessingStatus status;
  final InputMode inputMode;
  final int? conversationId;
  final String assistantName;
  final String partialSpeechText;
  final ProductModel? lastMentionedProduct;
  final bool checkoutRequested;
  final String? errorMessage;
  final String? statusToast;
  final AiConfig? config;
  final bool voiceOn;
  final List<String> suggestionChips;
  final OrderEntity? trackedOrder;
  final int? pendingTabIndex;
  final String? pendingRoute;
  final Object? pendingRouteArgs;
  /// addresses | edit_name | cart
  final String? pendingSheet;

  const AiControllerState({
    this.messages = const [],
    this.status = AiProcessingStatus.idle,
    this.inputMode = InputMode.voice,
    this.conversationId,
    this.assistantName = 'AIM',
    this.partialSpeechText = '',
    this.lastMentionedProduct,
    this.checkoutRequested = false,
    this.errorMessage,
    this.statusToast,
    this.config,
    this.voiceOn = false,
    this.suggestionChips = const [],
    this.trackedOrder,
    this.pendingTabIndex,
    this.pendingRoute,
    this.pendingRouteArgs,
    this.pendingSheet,
  });

  bool get isListening => status == AiProcessingStatus.listening;
  bool get isThinking => status == AiProcessingStatus.thinking;
  bool get isSpeaking => status == AiProcessingStatus.speaking;
  bool get isIdle => status == AiProcessingStatus.idle;
  bool get ttsAllowedByAdmin => config?.ttsEnabled ?? true;
  bool get sttAllowedByAdmin => config?.sttEnabled ?? true;
  bool get showCloseButton => config?.showCloseButton ?? true;
  String get presentation => config?.presentation ?? 'floating';
  String get productLayout => config?.productLayout ?? 'strip';
  String get bubbleStyle => config?.bubbleStyle ?? 'modern';

  AiControllerState copyWith({
    List<ChatMessage>? messages,
    AiProcessingStatus? status,
    InputMode? inputMode,
    int? conversationId,
    bool clearConversationId = false,
    String? assistantName,
    String? partialSpeechText,
    ProductModel? lastMentionedProduct,
    bool clearLastProduct = false,
    bool? checkoutRequested,
    String? errorMessage,
    bool clearError = false,
    String? statusToast,
    bool clearToast = false,
    AiConfig? config,
    bool? voiceOn,
    List<String>? suggestionChips,
    OrderEntity? trackedOrder,
    bool clearTrackedOrder = false,
    int? pendingTabIndex,
    bool clearPendingTab = false,
    String? pendingRoute,
    bool clearPendingRoute = false,
    Object? pendingRouteArgs,
    bool clearPendingRouteArgs = false,
    String? pendingSheet,
    bool clearPendingSheet = false,
  }) {
    return AiControllerState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      inputMode: inputMode ?? this.inputMode,
      conversationId:
          clearConversationId ? null : (conversationId ?? this.conversationId),
      assistantName: assistantName ?? this.assistantName,
      partialSpeechText: partialSpeechText ?? this.partialSpeechText,
      lastMentionedProduct: clearLastProduct
          ? null
          : (lastMentionedProduct ?? this.lastMentionedProduct),
      checkoutRequested: checkoutRequested ?? this.checkoutRequested,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      statusToast: clearToast ? null : (statusToast ?? this.statusToast),
      config: config ?? this.config,
      voiceOn: voiceOn ?? this.voiceOn,
      suggestionChips: suggestionChips ?? this.suggestionChips,
      trackedOrder:
          clearTrackedOrder ? null : (trackedOrder ?? this.trackedOrder),
      pendingTabIndex:
          clearPendingTab ? null : (pendingTabIndex ?? this.pendingTabIndex),
      pendingRoute:
          clearPendingRoute ? null : (pendingRoute ?? this.pendingRoute),
      pendingRouteArgs: clearPendingRouteArgs
          ? null
          : (pendingRouteArgs ?? this.pendingRouteArgs),
      pendingSheet:
          clearPendingSheet ? null : (pendingSheet ?? this.pendingSheet),
    );
  }

  @override
  List<Object?> get props => [
        messages,
        status,
        inputMode,
        conversationId,
        assistantName,
        partialSpeechText,
        lastMentionedProduct,
        checkoutRequested,
        errorMessage,
        statusToast,
        config,
        voiceOn,
        suggestionChips,
        trackedOrder,
        pendingTabIndex,
        pendingRoute,
        pendingRouteArgs,
        pendingSheet,
      ];
}
