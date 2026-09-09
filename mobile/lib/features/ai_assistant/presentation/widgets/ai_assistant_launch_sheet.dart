import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/services/auth_session.dart';
import '../../../auth/presentation/widgets/delivery_addresses_sheet.dart';
import '../../../auth/presentation/widgets/edit_name_sheet.dart';
import '../../../shop/data/models/product_model.dart';
import '../../../shop/domain/entities/order_entity.dart';
import '../../../shop/presentation/widgets/cart_sheet.dart';
import '../../../shop/presentation/widgets/categories_nav.dart';
import '../../../shop/presentation/widgets/main_shell_scope.dart';
import '../../../shop/presentation/widgets/product_card.dart';
import '../../domain/entities/chat_message.dart';
import '../cubit/ai_controller_cubit.dart';
import 'ai_chat_panel.dart';

/// لوحة المساعد العائمة — تتمدّد من زر الـ FAB وتنكمش إليه (بدون زر إغلاق).
class AiMorphFloatingPanel extends StatefulWidget {
  final bool isOpen;
  final double bottomOffset;
  final AiControllerCubit cubit;
  final VoidCallback? onDismiss;

  const AiMorphFloatingPanel({
    super.key,
    required this.isOpen,
    required this.cubit,
    this.bottomOffset = 108,
    this.onDismiss,
  });

  @override
  State<AiMorphFloatingPanel> createState() => _AiMorphFloatingPanelState();
}

class _AiMorphFloatingPanelState extends State<AiMorphFloatingPanel>
    with SingleTickerProviderStateMixin {
  static const _basePanelHeight = 460.0;
  static const _productsExtraHeight = 180.0;
  static const _dismissThreshold = 80.0;

  late final AnimationController _ctrl;
  late final Animation<double> _t;
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();
  double _dragOffset = 0;

  /// فتح بطيء بهوية بصرية — تباطؤ طويل وناعم.
  static const _openCurve = Cubic(0.05, 0.75, 0.12, 1.0);
  static const _closeCurve = Cubic(0.4, 0.0, 0.2, 1.0);
  static const _revealCurve = Cubic(0.22, 1.0, 0.36, 1.0);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
      reverseDuration: const Duration(milliseconds: 420),
    );
    _t = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.linear,
      reverseCurve: _closeCurve,
    );
    if (widget.isOpen) _ctrl.value = 1;
  }

  @override
  void didUpdateWidget(covariant AiMorphFloatingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen == oldWidget.isOpen) return;
    if (widget.isOpen) {
      _dragOffset = 0;
      _ctrl.forward();
    } else {
      _focusNode.unfocus();
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return;
    _searchCtrl.clear();
    widget.cubit.sendTextMessage(text);
  }

  void _toggleMic() {
    final state = widget.cubit.state;
    if (state.isListening) {
      widget.cubit.stopVoiceInput();
    } else {
      widget.cubit.startVoiceInput();
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.isOpen || _t.value < 0.9) return;
    final dy = details.delta.dy;
    if (dy <= 0 && _dragOffset <= 0) return;
    setState(() {
      _dragOffset = (_dragOffset + dy).clamp(0.0, 220.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.isOpen) return;
    final velocity = details.primaryVelocity ?? 0;
    if (_dragOffset >= _dismissThreshold || velocity > 700) {
      _dragOffset = 0;
      widget.onDismiss?.call();
      return;
    }
    setState(() => _dragOffset = 0);
  }

  List<ProductModel> _latestProducts(AiControllerState state) {
    // فقط منتجات آخر رد من المساعد — لا تُثبَّت من رسائل قديمة.
    for (final msg in state.messages.reversed) {
      if (msg.isUser) continue;
      return msg.suggestedProducts;
    }
    return const [];
  }

  bool _hasConversation(AiControllerState state) =>
      state.messages.any((m) => m.isUser);

  Color _hexColor(String hex, Color fallback) {
    final value = hex.trim();
    if (value.length == 7 && value.startsWith('#')) {
      final parsed = int.tryParse(value.substring(1), radix: 16);
      if (parsed != null) return Color(0xFF000000 | parsed);
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return BlocProvider<AiControllerCubit>.value(
      value: widget.cubit,
      child: MultiBlocListener(
        listeners: [
          BlocListener<AiControllerCubit, AiControllerState>(
            listenWhen: (p, n) =>
                p.pendingTabIndex != n.pendingTabIndex &&
                n.pendingTabIndex != null,
            listener: (context, state) {
              final tab = state.pendingTabIndex;
              if (tab == null) return;
              final sectionId = state.pendingRouteArgs;
              widget.onDismiss?.call();
              MainShellNavigation.goToTab(context, tab);
              if (tab == MainShellTabs.categories &&
                  sectionId is String &&
                  sectionId.isNotEmpty) {
                CategoriesNav.focusSection(sectionId);
              }
              widget.cubit.clearPendingNavigation();
            },
          ),
          BlocListener<AiControllerCubit, AiControllerState>(
            listenWhen: (p, n) =>
                p.pendingRoute != n.pendingRoute && n.pendingRoute != null,
            listener: (context, state) {
              final route = state.pendingRoute;
              if (route == null || route.isEmpty) return;
              final args = state.pendingRouteArgs;
              widget.onDismiss?.call();
              Navigator.of(context).pushNamed(route, arguments: args);
              widget.cubit.clearPendingNavigation();
            },
          ),
          BlocListener<AiControllerCubit, AiControllerState>(
            listenWhen: (p, n) =>
                p.pendingSheet != n.pendingSheet && n.pendingSheet != null,
            listener: (context, state) async {
              final sheet = state.pendingSheet;
              if (sheet == null) return;
              widget.cubit.clearPendingNavigation();
              widget.onDismiss?.call();
              if (!context.mounted) return;
              switch (sheet) {
                case 'addresses':
                  await DeliveryAddressesSheet.show(context);
                case 'edit_name':
                  final user = AuthSession.instance.user;
                  if (user == null) {
                    await Navigator.of(context)
                        .pushNamed(AppRouter.phoneLogin);
                    break;
                  }
                  await EditNameSheet.show(
                    context,
                    currentName: user.name,
                    phone: user.phone ?? '',
                  );
                case 'cart':
                  await showCartSheet(context);
                default:
                  break;
              }
            },
          ),
          BlocListener<AiControllerCubit, AiControllerState>(
            listenWhen: (p, n) =>
                !p.checkoutRequested && n.checkoutRequested,
            listener: (context, state) async {
              widget.cubit.clearCheckoutRequest();
              widget.onDismiss?.call();
              await openCheckoutFromChat(context);
            },
          ),
        ],
        child: BlocBuilder<AiControllerCubit, AiControllerState>(
          buildWhen: (p, n) =>
              p.messages != n.messages ||
              p.status != n.status ||
              p.voiceOn != n.voiceOn ||
              p.suggestionChips != n.suggestionChips ||
              p.config != n.config ||
              p.statusToast != n.statusToast ||
              p.errorMessage != n.errorMessage ||
              p.trackedOrder != n.trackedOrder,
          builder: (context, aiState) {
            final products = _latestProducts(aiState);
            final hasChat = _hasConversation(aiState);
            // نفس عرض الشريط السفلي العائم (هوامش 16).
            const navHMargin = 16.0;
            final panelWidth = size.width - navHMargin * 2;
            final floatingHeight = hasChat ||
                    products.isNotEmpty ||
                    aiState.trackedOrder != null
                ? _basePanelHeight + _productsExtraHeight
                : _basePanelHeight;
            final primaryColor = _hexColor(
              aiState.config?.primaryColor ?? '',
              AppTheme.primary,
            );
            final surfaceColor = _hexColor(
              aiState.config?.surfaceColor ?? '',
              AppTheme.surface,
            );

            if (aiState.statusToast != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                final msg = aiState.statusToast;
                if (msg == null) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg, textAlign: TextAlign.center),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
                widget.cubit.clearToast();
              });
            }

            return AnimatedBuilder(
              animation: _t,
              builder: (context, _) {
                final v = _t.value;
                if (v <= 0.001) return const SizedBox.shrink();

                // طبقات بطيئة: تمدّد من الزر → صقل → كشف المحتوى (هوية بصرية).
                final sizeT = _openCurve.transform(v);
                final widthT = const Interval(
                  0.0,
                  0.78,
                  curve: _openCurve,
                ).transform(v);
                final heightT = const Interval(
                  0.06,
                  0.92,
                  curve: _openCurve,
                ).transform(v);
                final revealT = const Interval(
                  0.38,
                  0.96,
                  curve: _revealCurve,
                ).transform(v);
                final bulgeT = const Interval(
                  0.28,
                  1.0,
                  curve: Curves.easeOutCubic,
                ).transform(v);
                // توهّج الهوية في منتصف الفتح ثم يخفت.
                final bloom = math.sin(v * math.pi).clamp(0.0, 1.0);

                // بدون resizeToAvoidBottomInset: ارفع اللوحة فوق الكيبورد مباشرة.
                final lift =
                    keyboard > 0 ? keyboard : widget.bottomOffset;
                final targetHeight = math.max(
                  320.0,
                  math.min(
                    floatingHeight,
                    size.height - lift - 8,
                  ),
                );
                // بروز يحتضن الزر بقوس منفرج للأسفل.
                final bulgeExtent = lerpDouble(0, 46, bulgeT)!;
                const fabSize = 68.0;
                const openLeft = navHMargin;
                final fabLeft = (size.width - fabSize) / 2;
                final left = lerpDouble(fabLeft, openLeft, widthT)!;
                final width = lerpDouble(fabSize, panelWidth, widthT)!;
                final height =
                    lerpDouble(fabSize, targetHeight + bulgeExtent, heightT)!;
                final bottom = lerpDouble(
                      widget.bottomOffset,
                      lift,
                      sizeT,
                    )! -
                    _dragOffset;
                final topRadius = lerpDouble(fabSize / 2, 18, sizeT)!;
                final contentOpacity = revealT;
                final dismissProgress =
                    (_dragOffset / _dismissThreshold).clamp(0.0, 1.0);
                final artScale = lerpDouble(0.86, 1.0, sizeT)!;
                final shellOpacity = lerpDouble(0.55, 1.0, sizeT)!;

                return Stack(
                  children: [
                    Positioned(
                      left: left,
                      bottom: bottom,
                      width: width,
                      height: height,
                      child: Transform.scale(
                        scale: artScale,
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onVerticalDragUpdate: _onDragUpdate,
                          onVerticalDragEnd: _onDragEnd,
                          child: Opacity(
                            opacity: (shellOpacity *
                                    (1 - dismissProgress * 0.35))
                                .clamp(0.35, 1),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(
                                      alpha: 0.12 * revealT + 0.28 * bloom,
                                    ),
                                    blurRadius: 28 * revealT + 36 * bloom,
                                    spreadRadius: 2 * bloom,
                                    offset: Offset(0, 6 + 6 * bloom),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.05 * revealT,
                                    ),
                                    blurRadius: 18,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipPath(
                                clipper: _AiPanelBottomNotchClipper(
                                  topRadius: topRadius,
                                  bottomCornerRadius:
                                      lerpDouble(fabSize / 2, 18, sizeT)!,
                                  notchDiameter: bulgeExtent * 2,
                                  notchMargin: 0,
                                  flare: lerpDouble(0.35, 1.0, bulgeT)!,
                                ),
                                child: ColoredBox(
                                  color: surfaceColor,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: primaryColor.withValues(
                                          alpha: 0.14 * revealT +
                                              0.2 * bloom,
                                        ),
                                      ),
                                    ),
                                    child: Opacity(
                                      opacity: contentOpacity,
                                      child: (contentOpacity < 0.04 ||
                                              height < 200)
                                          ? const SizedBox.shrink()
                                          : _PanelBody(
                                            searchCtrl: _searchCtrl,
                                            focusNode: _focusNode,
                                            suggestions:
                                                aiState.suggestionChips,
                                            products: products,
                                            messages: aiState.messages,
                                            trackedOrder:
                                                aiState.trackedOrder,
                                            hasConversation: hasChat,
                                            isThinking: aiState.isThinking,
                                            assistantName:
                                                aiState.assistantName,
                                            voiceOn: aiState.voiceOn,
                                            ttsAllowed:
                                                aiState.ttsAllowedByAdmin,
                                            sttAllowed:
                                                aiState.sttAllowedByAdmin,
                                            showClose:
                                                aiState.showCloseButton,
                                            productLayout:
                                                aiState.productLayout,
                                            bubbleStyle:
                                                aiState.bubbleStyle,
                                            accentColor: primaryColor,
                                            errorMessage:
                                                aiState.errorMessage,
                                            bottomBulgeReserve: bulgeExtent,
                                            onSubmit: _submit,
                                            onMicTap: _toggleMic,
                                            onToggleVoice: () =>
                                                widget.cubit.toggleVoice(),
                                            onClose: widget.onDismiss,
                                            onDismissError: () =>
                                                widget.cubit
                                                    .dismissError(),
                                            onClearChat: () async {
                                              widget.cubit
                                                  .clearConversation();
                                              await widget.cubit
                                                  .initConversation();
                                            },
                                            onClearTrackedOrder: () =>
                                                widget.cubit
                                                    .clearTrackedOrder(),
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PanelBody extends StatelessWidget {
  final TextEditingController searchCtrl;
  final FocusNode focusNode;
  final List<String> suggestions;
  final List<ProductModel> products;
  final List<ChatMessage> messages;
  final OrderEntity? trackedOrder;
  final bool hasConversation;
  final bool isThinking;
  final String assistantName;
  final bool voiceOn;
  final bool ttsAllowed;
  final bool sttAllowed;
  final bool showClose;
  final String productLayout;
  final String bubbleStyle;
  final Color accentColor;
  final String? errorMessage;
  final double bottomBulgeReserve;
  final ValueChanged<String> onSubmit;
  final VoidCallback onMicTap;
  final VoidCallback onToggleVoice;
  final VoidCallback? onClose;
  final VoidCallback onDismissError;
  final VoidCallback onClearChat;
  final VoidCallback onClearTrackedOrder;

  const _PanelBody({
    required this.searchCtrl,
    required this.focusNode,
    required this.suggestions,
    required this.products,
    required this.messages,
    required this.trackedOrder,
    required this.hasConversation,
    required this.isThinking,
    required this.assistantName,
    required this.voiceOn,
    required this.ttsAllowed,
    required this.sttAllowed,
    required this.showClose,
    required this.productLayout,
    required this.bubbleStyle,
    required this.accentColor,
    required this.errorMessage,
    this.bottomBulgeReserve = 0,
    required this.onSubmit,
    required this.onMicTap,
    required this.onToggleVoice,
    required this.onClose,
    required this.onDismissError,
    required this.onClearChat,
    required this.onClearTrackedOrder,
  });

  String get _welcome {
    if (messages.isEmpty) {
      return 'أهلاً بك! كيف يمكنني مساعدتك في التسوق اليوم؟';
    }
    return messages.first.content;
  }

  @override
  Widget build(BuildContext context) {
    // أثناء الـ morph يكون ارتفاع اللوحة ضيقاً؛ نخفي الثانوي ونضغط الحشو.
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final tight = h < 280;
        final showHandle = h >= 260;
        final showWelcome = !hasConversation && h >= 320;
        final showError =
            errorMessage != null && errorMessage!.isNotEmpty && h >= 230;
        final bottomPad = tight ? 8.0 : 12.0;
        final topPad = tight ? 6.0 : 10.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, topPad, 16, bottomPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showHandle)
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.mutedText.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    SizedBox(
                      height: tight ? 36 : 44,
                      child: Row(
                        children: [
                          if (ttsAllowed)
                            IconButton(
                              tooltip: voiceOn ? 'كتم الصوت' : 'تفعيل الصوت',
                              onPressed: onToggleVoice,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              icon: Icon(
                                voiceOn
                                    ? Icons.volume_up_rounded
                                    : Icons.volume_off_rounded,
                                size: 22,
                                color:
                                    voiceOn ? accentColor : AppTheme.mutedText,
                              ),
                            )
                          else
                            const SizedBox(width: 30),
                          Expanded(
                            child: Text(
                              'مساعد $assistantName',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: tight ? 14 : 16,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.darkText,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'مسح الدردشة',
                            onPressed: onClearChat,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 22,
                              color: AppTheme.mutedText.withValues(alpha: 0.85),
                            ),
                          ),
                          if (showClose && onClose != null)
                            _AiRoundCloseButton(onTap: onClose!)
                          else
                            const SizedBox(width: 30),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showWelcome) ...[
                            const SizedBox(height: 4),
                            Text(
                              _welcome,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.mutedText.withValues(
                                  alpha: 0.95,
                                ),
                              ),
                            ),
                            if (suggestions.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 36,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: suggestions.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    final tip = suggestions[index];
                                    return ActionChip(
                                      label: Text(tip),
                                      labelStyle: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w400,
                                        color: AppTheme.darkText,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      backgroundColor:
                                          accentColor.withValues(alpha: 0.12),
                                      side: BorderSide(
                                        color: accentColor.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      onPressed: () => onSubmit(tip),
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    );
                                  },
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                          ],
                          Expanded(
                            child: hasConversation
                                ? _ConversationArea(
                                    messages: messages,
                                    products: products,
                                    trackedOrder: trackedOrder,
                                    isThinking: isThinking,
                                    productLayout: productLayout,
                                    bubbleStyle: bubbleStyle,
                                    accentColor: accentColor,
                                    onClearTrackedOrder: onClearTrackedOrder,
                                  )
                                : const SizedBox.shrink(),
                          ),
                          if (!hasConversation && products.isNotEmpty)
                            Flexible(
                              child: LayoutBuilder(
                                builder: (context, productConstraints) {
                                  final scale = AppScale.of(context);
                                  final preferred = productLayout == 'grid'
                                      ? scale.productCardHeight * 0.75 * 2 + 12
                                      : scale.productCardHeight * 0.75;
                                  final height = math.min(
                                    preferred,
                                    productConstraints.maxHeight,
                                  );
                                  if (height < 88) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: SizedBox(
                                      height: height,
                                      child: productLayout == 'grid'
                                          ? _ProductsGrid(products: products)
                                          : _ProductsStrip(products: products),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (showError) ...[
                      const SizedBox(height: 6),
                      Material(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 36,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFC62828),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: onDismissError,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: const Text(
                                    'إلغاء',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    _SearchBar(
                      controller: searchCtrl,
                      focusNode: focusNode,
                      onSubmit: onSubmit,
                      onMicTap: sttAllowed ? onMicTap : () {},
                      sttAllowed: sttAllowed,
                    ),
                  ],
                ),
              ),
            ),
            // امتداد الصقل تحت حقل الإدخال — لا يخصم من ارتفاع المحادثة.
            if (bottomBulgeReserve > 0) SizedBox(height: bottomBulgeReserve),
          ],
        );
      },
    );
  }
}

class _AiRoundCloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AiRoundCloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // نفس حجم/شكل زر الإلغاء في مراجعة الطلب (checkout).
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x14000000), width: 0.5),
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 18,
            color: AppTheme.darkText,
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}

class _ConversationArea extends StatefulWidget {
  final List<ChatMessage> messages;
  final List<ProductModel> products;
  final OrderEntity? trackedOrder;
  final bool isThinking;
  final String productLayout;
  final String bubbleStyle;
  final Color accentColor;
  final VoidCallback onClearTrackedOrder;

  const _ConversationArea({
    required this.messages,
    required this.products,
    required this.trackedOrder,
    required this.isThinking,
    required this.productLayout,
    required this.bubbleStyle,
    required this.accentColor,
    required this.onClearTrackedOrder,
  });

  @override
  State<_ConversationArea> createState() => _ConversationAreaState();
}

class _ConversationAreaState extends State<_ConversationArea> {
  final _scrollCtrl = ScrollController();

  @override
  void didUpdateWidget(covariant _ConversationArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages.length != widget.messages.length ||
        oldWidget.isThinking != widget.isThinking ||
        oldWidget.trackedOrder != widget.trackedOrder) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollCtrl.hasClients) return;
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasProducts = widget.products.isNotEmpty;
        final hasOrder = widget.trackedOrder != null;
        final preferred = widget.productLayout == 'grid'
            ? AppScale.of(context).productCardHeight * 0.75 * 2 + 12
            : AppScale.of(context).productCardHeight * 0.75;
        const gap = 8.0;
        const minMessages = 96.0;
        final orderReserve = hasOrder ? 132.0 : 0.0;
        final maxProducts = hasProducts
            ? math.max(
                0.0,
                constraints.maxHeight - minMessages - gap - orderReserve,
              )
            : 0.0;
        final productsHeight = hasProducts
            ? math.min(preferred, maxProducts).clamp(0.0, preferred)
            : 0.0;
        final showProducts = hasProducts && productsHeight >= 96;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.only(bottom: 4),
                itemCount:
                    widget.messages.length + (widget.isThinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (widget.isThinking &&
                      index == widget.messages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _TypingBubble(
                          accentColor: widget.accentColor,
                        ),
                      ),
                    );
                  }
                  final msg = widget.messages[index];
                  return _ChatBubble(
                    message: msg,
                    bubbleStyle: widget.bubbleStyle,
                    accentColor: widget.accentColor,
                  );
                },
              ),
            ),
            if (hasOrder) ...[
              const SizedBox(height: gap),
              _OrderTrackCard(
                order: widget.trackedOrder!,
                accentColor: widget.accentColor,
                onDismiss: widget.onClearTrackedOrder,
              ),
            ],
            if (showProducts) ...[
              const SizedBox(height: gap),
              SizedBox(
                height: productsHeight,
                child: widget.productLayout == 'grid'
                    ? _ProductsGrid(products: widget.products)
                    : _ProductsStrip(products: widget.products),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final String bubbleStyle;
  final Color accentColor;

  const _ChatBubble({
    required this.message,
    required this.bubbleStyle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final soft = bubbleStyle == 'soft';
    final radius = soft ? 16.0 : 12.0;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isUser
                ? accentColor
                : accentColor.withValues(alpha: soft ? 0.10 : 0.12),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
              bottomLeft: Radius.circular(isUser ? radius : (soft ? 10 : 4)),
              bottomRight: Radius.circular(isUser ? (soft ? 10 : 4) : radius),
            ),
          ),
          child: message.isLoading
              ? SizedBox(
                  width: 28,
                  height: 14,
                  child:
                      _TypingBubble(compact: true, accentColor: accentColor),
                )
              : Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                    color: isUser ? Colors.white : AppTheme.darkText,
                  ),
                ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  final bool compact;
  final Color accentColor;

  const _TypingBubble({
    this.compact = false,
    this.accentColor = AppTheme.primaryDark,
  });

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) => Text(
          '…',
          style: TextStyle(
            color: AppTheme.mutedText.withValues(alpha: 0.5 + 0.5 * _ctrl.value),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: widget.accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final t = ((_ctrl.value + i * 0.2) % 1.0);
              final scale = 0.55 + 0.45 * (1 - (t - 0.5).abs() * 2);
              return Padding(
                padding: EdgeInsetsDirectional.only(end: i == 2 ? 0 : 4),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: widget.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  final List<ProductModel> products;

  const _ProductsGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AiControllerCubit>();
    return GridView.builder(
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          heroTag: 'ai_preview_grid_${product.id}',
          compactFooter: true,
          compactGiftOverlay: true,
          onAfterAddedToCart: () => cubit.suggestComplementFor(product),
        );
      },
    );
  }
}

class _ProductsStrip extends StatelessWidget {
  final List<ProductModel> products;

  const _ProductsStrip({required this.products});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AiControllerCubit>();
    final scale = AppScale.of(context);
    final cardW = scale.productCardWidth * 0.76;
    final cardH = scale.productCardHeight * 0.76;
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final product = products[index];
        return SizedBox(
          width: cardW,
          height: cardH,
          child: ProductCard(
            product: product,
            heroTag: 'ai_preview_${product.id}',
            compactFooter: true,
            compactGiftOverlay: true,
            onAfterAddedToCart: () => cubit.suggestComplementFor(product),
          ),
        );
      },
    );
  }
}

/// حافة سفلية محدّبة للخارج بقوس منفرج (أكتاف ناعمة) نحو زر المساعد.
/// البروز تحت حقل الإدخال ولا يقتطع من محتوى المحادثة.
class _AiPanelBottomNotchClipper extends CustomClipper<Path> {
  const _AiPanelBottomNotchClipper({
    required this.topRadius,
    required this.bottomCornerRadius,
    required this.notchDiameter,
    required this.notchMargin,
    this.flare = 1,
  });

  final double topRadius;
  final double bottomCornerRadius;
  final double notchDiameter;
  final double notchMargin;
  /// 1 = أكتاف منفرجة بالكامل؛ أقل = أقرب لشكل الزر أثناء الـ morph.
  final double flare;

  @override
  Path getClip(Size size) {
    final topR = topRadius.clamp(0.0, size.width / 2);
    final br = bottomCornerRadius.clamp(0.0, size.width / 2);
    final depth =
        ((notchDiameter / 2) + notchMargin).clamp(0.0, size.height * 0.42);
    final f = flare.clamp(0.0, 1.0);

    if (depth <= 1) {
      return Path()
        ..addRRect(
          RRect.fromRectAndCorners(
            Offset.zero & size,
            topLeft: Radius.circular(topR),
            topRight: Radius.circular(topR),
            bottomLeft: Radius.circular(br),
            bottomRight: Radius.circular(br),
          ),
        );
    }

    final cx = size.width / 2;
    final tipY = size.height;
    final sideY = size.height - depth;
    // كتف أعرض من نصف القطر → زاوية منفرجة عند التقاء القوس بالحافة.
    final shoulder = (depth * (1.15 + 0.95 * f))
        .clamp(depth, size.width * 0.42);

    final path = Path()
      ..moveTo(0, topR)
      ..quadraticBezierTo(0, 0, topR, 0)
      ..lineTo(size.width - topR, 0)
      ..quadraticBezierTo(size.width, 0, size.width, topR)
      ..lineTo(size.width, sideY - br)
      ..quadraticBezierTo(size.width, sideY, size.width - br, sideY)
      ..lineTo(cx + shoulder, sideY)
      // قوس منفرج للأسفل: أكتاف واسعة ثم طرف ناعم عند الزر.
      ..cubicTo(
        cx + shoulder * 0.52,
        sideY + depth * 0.08,
        cx + shoulder * 0.22,
        tipY,
        cx,
        tipY,
      )
      ..cubicTo(
        cx - shoulder * 0.22,
        tipY,
        cx - shoulder * 0.52,
        sideY + depth * 0.08,
        cx - shoulder,
        sideY,
      )
      ..lineTo(br, sideY)
      ..quadraticBezierTo(0, sideY, 0, sideY - br)
      ..lineTo(0, topR)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant _AiPanelBottomNotchClipper oldClipper) =>
      oldClipper.topRadius != topRadius ||
      oldClipper.bottomCornerRadius != bottomCornerRadius ||
      oldClipper.notchDiameter != notchDiameter ||
      oldClipper.notchMargin != notchMargin ||
      oldClipper.flare != flare;
}

class _OrderTrackCard extends StatelessWidget {
  final OrderEntity order;
  final Color accentColor;
  final VoidCallback onDismiss;

  const _OrderTrackCard({
    required this.order,
    required this.accentColor,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final itemsPreview =
        order.items.take(3).map((i) => i.product.name).join(' · ');
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'طلب #${order.id}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.darkText,
                    ),
                  ),
                ),
                Text(
                  order.status.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: accentColor,
                  ),
                ),
                IconButton(
                  onPressed: onDismiss,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              itemsPreview.isEmpty ? 'لا توجد عناصر ظاهرة' : itemsPreview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppTheme.mutedText.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '${order.total.toStringAsFixed(2)} ',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.darkText,
                  ),
                ),
                const Text(
                  'ر.س',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.mutedText,
                  ),
                ),
                const Spacer(),
                if (order.paymentMethodLabel.isNotEmpty)
                  Text(
                    order.paymentMethodLabel,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.mutedText,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmit;
  final VoidCallback onMicTap;
  final bool sttAllowed;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.onMicTap,
    this.sttAllowed = true,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant _SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
      _hasText = widget.controller.text.trim().isNotEmpty;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final next = widget.controller.text.trim().isNotEmpty;
    if (next == _hasText) return;
    setState(() => _hasText = next);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiControllerCubit, AiControllerState>(
      buildWhen: (p, n) => p.status != n.status,
      builder: (context, state) {
        final listening = state.isListening;
        final showSend = _hasText && !listening;

        return Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: listening
                  ? AppTheme.primaryDark
                  : AppTheme.primary.withValues(alpha: 0.3),
              width: listening ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  textInputAction: TextInputAction.search,
                  onSubmitted: widget.onSubmit,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkText,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: listening
                        ? 'جاري الاستماع…'
                        : 'ابحث أو اسأل المساعد…',
                    hintStyle: TextStyle(
                      color: AppTheme.mutedText.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
              Material(
                color: showSend || listening
                    ? AppTheme.primaryDark
                    : AppTheme.primary.withValues(alpha: 0.2),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: showSend
                      ? () => widget.onSubmit(widget.controller.text)
                      : (widget.sttAllowed ? widget.onMicTap : null),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: anim,
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: Icon(
                        showSend
                            ? Icons.send_rounded
                            : (listening
                                ? Icons.mic_rounded
                                : (widget.sttAllowed
                                    ? Icons.mic_none_rounded
                                    : Icons.keyboard_rounded)),
                        key: ValueKey<String>(
                          showSend
                              ? 'send'
                              : (listening ? 'mic_on' : 'mic_off'),
                        ),
                        color: showSend || listening
                            ? Colors.white
                            : AppTheme.primaryDark,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        );
      },
    );
  }
}
