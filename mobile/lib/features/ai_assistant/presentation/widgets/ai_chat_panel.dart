import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_count_badge.dart';
import '../../../auth/data/services/auth_session.dart';
import '../../../auth/presentation/widgets/delivery_addresses_sheet.dart';
import '../../../auth/presentation/widgets/edit_name_sheet.dart';
import '../../../shop/presentation/widgets/cart_sheet.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/chat_message.dart';
import '../cubit/ai_controller_cubit.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/suggested_products_grid.dart';
import '../widgets/typing_indicator.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/ai_gemini_dock_bar.dart';
import '../widgets/ai_wave_header.dart';
import '../widgets/voice_mic_button.dart';
import '../../../shop/data/models/product_model.dart';
import '../../../shop/domain/entities/cart_item.dart';
import '../../../shop/presentation/manager/cart_cubit.dart';
import '../../../shop/presentation/pages/product_details_screen.dart';
import '../../../shop/presentation/widgets/categories_nav.dart';
import '../../../shop/presentation/widgets/main_shell_scope.dart';

enum AiChatPresentation { embedded, fullscreen }

const kAiSheetCompactThreshold = 0.22;

const kMintBrand = Color(0xFF003399);
const kMintDark = Color(0xFF2D6A4F);
const kMintPaleBg = Color(0xFFE8F8ED);
const kMintGradientA = Color(0xFFB8E8C8);
const kMintGradientB = Color(0xFF003399);
const kMintGradientC = Color(0xFF6BC489);
const kChatSurface = Color(0xFFFAFDFB);

TextStyle aiChatCairo(
  double fontSize, {
  FontWeight fontWeight = FontWeight.w500,
  Color? color,
  double? height,
  FontStyle? fontStyle,
}) =>
    TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      fontStyle: fontStyle,
    );

Future<void> openCheckoutFromChat(BuildContext context) async {
  final shell = context.findAncestorWidgetOfExactType<MainShellScope>();
  if (shell != null) {
    await shell.openCheckout();
  } else {
    await showCartSheet(context);
  }
}

void showChatOptionsMenu(BuildContext hostContext) {
  showModalBottomSheet<void>(
    context: hostContext,
    showDragHandle: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFFF4757)),
            title:
                const Text('مسح المحادثة', textDirection: TextDirection.rtl),
            onTap: () {
              Navigator.pop(sheetContext);
              hostContext.read<AiControllerCubit>().clearConversation();
            },
          ),
        ],
      ),
    ),
  );
}

/// محتوى المحادثة — fullscreen أو داخل اللوحة العائمة.
class AiChatPanel extends StatefulWidget {
  final ScrollController scrollController;
  final AiChatPresentation presentation;
  final VoidCallback onClose;
  final bool useHeroMic;
  final double sheetExtent;
  final VoidCallback? onExpandSheet;

  const AiChatPanel({
    super.key,
    required this.scrollController,
    required this.presentation,
    required this.onClose,
    this.useHeroMic = false,
    this.sheetExtent = 0.52,
    this.onExpandSheet,
  });

  @override
  State<AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends State<AiChatPanel> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _fullscreenShowTextField = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _isCompactLayout(widget.sheetExtent)) {
      widget.onExpandSheet?.call();
    }
  }

  bool get _isEmbedded => widget.presentation == AiChatPresentation.embedded;

  bool _isCompactLayout(double extent) =>
      _isEmbedded && extent < kAiSheetCompactThreshold;

  void _maybeExpandForChat() {
    if (_isCompactLayout(widget.sheetExtent)) {
      widget.onExpandSheet?.call();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.scrollController.hasClients) return;
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _toggleVoice(BuildContext context, AiControllerState state) {
    _maybeExpandForChat();
    final cubit = context.read<AiControllerCubit>();
    if (state.isListening) {
      cubit.stopVoiceInput();
    } else {
      cubit.startVoiceInput();
    }
  }

  void _sendText(BuildContext context) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _maybeExpandForChat();
    context.read<AiControllerCubit>().sendTextMessage(text);
    _textController.clear();
  }

  Widget _embeddedDock(
    AiControllerState state, {
    bool compact = false,
    double? barHeight,
  }) {
    return AiGeminiDockBar(
      compact: compact,
      heightOverride: barHeight,
      status: state.status,
      textController: _textController,
      onMicTap: () => _toggleVoice(context, state),
      onSend: () => _sendText(context),
      onFocus: _maybeExpandForChat,
    );
  }

  Widget _embeddedCompactBody(
    BuildContext context,
    AiControllerState state,
    BoxConstraints constraints,
  ) {
    const dockPad = 4.0;
    const preferredDock = AiGeminiDockBar.compactBarHeight;
    final available = constraints.maxHeight;
    final dockHeight = available <= preferredDock + dockPad
        ? (available - dockPad).clamp(44.0, preferredDock)
        : preferredDock;
    final waveHeight =
        (available - dockHeight - dockPad).clamp(0.0, 12.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (waveHeight >= 6)
          AiWaveHeader(height: waveHeight, prominent: false),
        _embeddedDock(
          state,
          compact: true,
          barHeight: dockHeight,
        ),
      ],
    );
  }

  Widget _embeddedExpandedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 4, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'مساعد AIMstore',
              textAlign: TextAlign.center,
              style: aiChatCairo(
                15,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryDark,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            color: AppTheme.mutedText,
          ),
          IconButton(
            onPressed: () => showChatOptionsMenu(context),
            icon: const Icon(Icons.more_vert_rounded),
            color: AppTheme.mutedText,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final embedded = _isEmbedded;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final compact =
        _isCompactLayout(widget.sheetExtent) && !keyboardOpen;
    final baseTheme = Theme.of(context);

    final panelBody = BlocBuilder<AiControllerCubit, AiControllerState>(
      builder: (context, state) {
        if (embedded) {
          return ColoredBox(
            color: AppTheme.background,
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (compact) {
                  return _embeddedCompactBody(context, state, constraints);
                }

                return Column(
                  children: [
                    const AiWaveHeader(height: 30, prominent: true),
                    _embeddedExpandedHeader(),
                    Expanded(
                      child: ChatMessagesList(
                        messages: state.messages,
                        isThinking: state.isThinking,
                        partialSpeechText: state.partialSpeechText,
                        scrollController: widget.scrollController,
                        errorMessage: state.errorMessage,
                        onAddToCart: (product) => context
                            .read<AiControllerCubit>()
                            .addToCart(product),
                        onOpenProduct: (product) {
                          Navigator.of(context).pushNamed(
                            AppRouter.productDetails,
                            arguments: ProductDetailsArgs(product: product),
                          );
                        },
                      ),
                    ),
                    _embeddedDock(state),
                  ],
                );
              },
            ),
          );
        }

        if (!embedded) {
          return Column(
            children: [
              Expanded(
                child: ChatMessagesList(
                  messages: state.messages,
                  isThinking: state.isThinking,
                  partialSpeechText: state.partialSpeechText,
                  scrollController: widget.scrollController,
                  errorMessage: state.errorMessage,
                  onAddToCart: (product) =>
                      context.read<AiControllerCubit>().addToCart(product),
                  onOpenProduct: (product) {
                    Navigator.of(context).pushNamed(
                      AppRouter.productDetails,
                      arguments: ProductDetailsArgs(product: product),
                    );
                  },
                ),
              ),
              ChatBottomBar(
                useHeroMic: widget.useHeroMic,
                status: state.status,
                showTextField: _fullscreenShowTextField,
                textController: _textController,
                onMicTap: () => _toggleVoice(context, state),
                onTextSend: () => _sendText(context),
                onToggleInput: () => setState(
                  () => _fullscreenShowTextField = !_fullscreenShowTextField,
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );

    return Theme(
      data: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(
          fontFamily: AppTextStyles.fontFamily,
        ),
      ),
      child: _wrapListeners(
        embedded ? panelBody : ChatBackdrop(child: panelBody),
      ),
    );
  }

  Widget _wrapListeners(Widget child) {
    return MultiBlocListener(
          listeners: [
            BlocListener<CartCubit, CartState>(
              listenWhen: (prev, curr) =>
                  curr.lastAddedProductName != null &&
                  prev.lastAddedProductName != curr.lastAddedProductName,
              listener: (context, state) {
                final name = state.lastAddedProductName!;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.shopping_cart_checkout_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'أُضيف "$name" للسلة ✓',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF4CAF50),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.all(16),
                      action: SnackBarAction(
                        label: 'عرض السلة',
                        textColor: Colors.white,
                        onPressed: () => ChatCartSheet.show(context),
                      ),
                    ),
                  );
                context.read<CartCubit>().dismissNotification();
              },
            ),
            BlocListener<AiControllerCubit, AiControllerState>(
              listenWhen: (prev, curr) =>
                  !prev.checkoutRequested && curr.checkoutRequested,
              listener: (context, state) {
                context.read<AiControllerCubit>().clearCheckoutRequest();
                openCheckoutFromChat(context);
              },
            ),
            BlocListener<AiControllerCubit, AiControllerState>(
              listenWhen: (p, n) =>
                  p.pendingTabIndex != n.pendingTabIndex &&
                  n.pendingTabIndex != null,
              listener: (context, state) {
                final tab = state.pendingTabIndex;
                if (tab == null) return;
                final sectionId = state.pendingRouteArgs;
                widget.onClose();
                MainShellNavigation.goToTab(context, tab);
                if (tab == MainShellTabs.categories &&
                    sectionId is String &&
                    sectionId.isNotEmpty) {
                  CategoriesNav.focusSection(sectionId);
                }
                context.read<AiControllerCubit>().clearPendingNavigation();
              },
            ),
            BlocListener<AiControllerCubit, AiControllerState>(
              listenWhen: (p, n) =>
                  p.pendingRoute != n.pendingRoute && n.pendingRoute != null,
              listener: (context, state) {
                final route = state.pendingRoute;
                if (route == null || route.isEmpty) return;
                final args = state.pendingRouteArgs;
                widget.onClose();
                Navigator.of(context).pushNamed(route, arguments: args);
                context.read<AiControllerCubit>().clearPendingNavigation();
              },
            ),
            BlocListener<AiControllerCubit, AiControllerState>(
              listenWhen: (p, n) =>
                  p.pendingSheet != n.pendingSheet && n.pendingSheet != null,
              listener: (context, state) async {
                final sheet = state.pendingSheet;
                if (sheet == null) return;
                context.read<AiControllerCubit>().clearPendingNavigation();
                widget.onClose();
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
              listenWhen: (prev, curr) =>
                  prev.messages.length != curr.messages.length ||
                  (!prev.isThinking && curr.isThinking),
              listener: (context, state) {
                if (state.messages.isNotEmpty) _scrollToBottom();
                if (_isEmbedded &&
                    (state.isThinking || state.messages.isNotEmpty)) {
                  _maybeExpandForChat();
                }
              },
            ),
            BlocListener<AiControllerCubit, AiControllerState>(
              listenWhen: (prev, curr) =>
                  curr.errorMessage != null &&
                  prev.errorMessage != curr.errorMessage,
              listener: (context, state) {
                if (state.messages.isEmpty) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        state.errorMessage!.split('\n').first,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFFFF4757),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.all(16),
                      action: SnackBarAction(
                        label: 'حسناً',
                        textColor: Colors.white,
                        onPressed: () =>
                            context.read<AiControllerCubit>().dismissError(),
                      ),
                    ),
                  );
              },
            ),
          ],
          child: child,
        );
  }
}

class ChatBackdrop extends StatelessWidget {
  final Widget child;

  const ChatBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: kChatSurface),
        LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: FaintStorePatternPainter(),
            );
          },
        ),
        child,
      ],
    );
  }
}

class FaintStorePatternPainter extends CustomPainter {
  static const _glyphs = ['🍊', '🍋', '🧼', '🧴', '🍇', '🫧', '🍎', '🧽'];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    for (var i = 0; i < 28; i++) {
      final x = ((i * 47.0 + 11) % (size.width - 28)) + 8;
      final y = ((i * 61.0 + 19) % (size.height - 28)) + 8;
      final tp = TextPainter(
        text: TextSpan(
          text: _glyphs[i % _glyphs.length],
          style: TextStyle(
            fontSize: 16 + (i % 4) * 3.0,
            color: kMintBrand.withValues(alpha: 0.045),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AiChatEmbeddedHeader extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onOpenOptions;

  const AiChatEmbeddedHeader({
    super.key,
    required this.onClose,
    required this.onOpenOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kMintGradientA, kMintGradientB, kMintGradientC],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0x66003399), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white, size: 28),
                  ),
                  Expanded(
                    child: Text(
                      'مساعد AIMstore',
                      textAlign: TextAlign.center,
                      style: aiChatCairo(16,
                          fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                  const ChatAppBarCartButton(),
                  IconButton(
                    onPressed: onOpenOptions,
                    icon: const Icon(Icons.more_vert_rounded,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatFullscreenAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onOpenOptions;

  const ChatFullscreenAppBar({super.key, required this.onOpenOptions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        'مساعد AIMstore',
        style: aiChatCairo(18, fontWeight: FontWeight.w800, color: Colors.white),
      ),
      actions: [
        const ChatAppBarCartButton(),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded,
              color: Colors.white, size: 26),
          onPressed: onOpenOptions,
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kMintGradientA, kMintGradientB, kMintGradientC],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }
}

class ChatAppBarCartButton extends StatelessWidget {
  const ChatAppBarCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartCubit>().state.count;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined,
              color: Colors.white, size: 26),
          onPressed: () => ChatCartSheet.show(context),
        ),
        if (cartCount > 0)
          AppCountBadge.positioned(
            count: cartCount,
            top: 8,
            end: 8,
            fontSize: 9,
          ),
      ],
    );
  }
}

class ChatMessagesList extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool isThinking;
  final String partialSpeechText;
  final ScrollController scrollController;
  final void Function(ProductModel) onAddToCart;
  final void Function(ProductModel) onOpenProduct;
  final String? errorMessage;

  const ChatMessagesList({
    super.key,
    required this.messages,
    required this.isThinking,
    required this.partialSpeechText,
    required this.scrollController,
    required this.onAddToCart,
    required this.onOpenProduct,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty && !isThinking) {
      return ListView(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          ChatEmptyState(loadError: errorMessage),
        ],
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _itemCount,
      itemBuilder: (context, index) => _buildItem(context, index),
    );
  }

  int get _itemCount {
    var count = messages.length;
    if (isThinking) count++;
    if (partialSpeechText.isNotEmpty) count++;
    return count;
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index < messages.length) {
      final msg = messages[index];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChatBubble(message: msg),
          if (!msg.isUser && msg.suggestedProducts.isNotEmpty)
            SuggestedProductsGrid(
              products: msg.suggestedProducts,
              onAddToCart: onAddToCart,
              onOpen: onOpenProduct,
            ),
        ],
      );
    }

    var offset = messages.length;

    if (partialSpeechText.isNotEmpty && index == offset) {
      return PartialSpeechBubble(text: partialSpeechText);
    }
    if (partialSpeechText.isNotEmpty) offset++;

    if (isThinking && index == offset) {
      return const AssistantTypingBubble();
    }

    return const SizedBox.shrink();
  }
}

class ChatEmptyState extends StatelessWidget {
  final String? loadError;

  const ChatEmptyState({super.key, this.loadError});

  @override
  Widget build(BuildContext context) {
    final hasError = loadError != null && loadError!.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: hasError
                  ? [const Color(0xFFFFEBEB), const Color(0xFFFFD4D4)]
                  : [const Color(0xFFE8F8ED), const Color(0xFFC8ECD4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              hasError ? '⚠️' : '🛍️',
              style: const TextStyle(fontSize: 42),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          hasError ? 'تعذّر الاتصال بالمساعد' : 'مرحباً بك في AIMstore!',
          textAlign: TextAlign.center,
          style: aiChatCairo(18, fontWeight: FontWeight.bold, color: kMintDark),
        ),
        const SizedBox(height: 8),
        Text(
          hasError
              ? 'تأكد من اتصالك بالإنترنت ثم أعد المحاولة'
              : 'اضغط على الميكروفون وتحدث،\nأو اكتب سؤالك في الأسفل',
          textAlign: TextAlign.center,
          style: aiChatCairo(
            13,
            color: hasError ? Colors.red[400] : Colors.grey[600],
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        if (hasError)
          FilledButton.icon(
            onPressed: () =>
                context.read<AiControllerCubit>().initConversation(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('إعادة المحاولة'),
            style: FilledButton.styleFrom(
              backgroundColor: kMintBrand,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          )
        else
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              SuggestionChip('ماذا عندكم؟'),
              SuggestionChip('أريد منظفاً قوياً'),
              SuggestionChip('اقترح لي هدية'),
              SuggestionChip('ما هو أفضل منتج؟'),
            ],
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class SuggestionChip extends StatelessWidget {
  final String label;

  const SuggestionChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<AiControllerCubit>().sendTextMessage(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: kMintPaleBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kMintBrand.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: aiChatCairo(13, fontWeight: FontWeight.w600, color: kMintDark),
        ),
      ),
    );
  }
}

class PartialSpeechBubble extends StatelessWidget {
  final String text;

  const PartialSpeechBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 12,
        end: 52,
        top: 4,
        bottom: 4,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: kMintBrand.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: kMintBrand.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mic_rounded, color: kMintBrand, size: 14),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  style: aiChatCairo(14,
                      color: kMintDark, fontStyle: FontStyle.italic),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GeminiEmbeddedBar extends StatelessWidget {
  static const _barBg = Color(0xFF252A27);
  static const _barBorder = Color(0xFF3A4540);

  final bool useHeroMic;
  final bool expanded;
  final bool dense;
  final AiProcessingStatus status;
  final bool showTextField;
  final TextEditingController textController;
  final VoidCallback onMicTap;
  final VoidCallback onTextSend;
  final VoidCallback onTapPlaceholder;
  final VoidCallback onToggleInput;
  final VoidCallback onSuggestTap;

  const GeminiEmbeddedBar({
    super.key,
    required this.useHeroMic,
    required this.status,
    required this.showTextField,
    required this.textController,
    required this.onMicTap,
    required this.onTextSend,
    required this.onTapPlaceholder,
    required this.onToggleInput,
    required this.onSuggestTap,
    this.expanded = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    // فوق شريط التنقل — لا نحتاج safe-area سفلي إضافي في الوضع المدمج.
    final bottomPad = dense ? 2.0 : MediaQuery.paddingOf(context).bottom + 6;
    final handleGap = dense ? 6.0 : 8.0;
    final rowPadV = dense ? 6.0 : 8.0;
    final rowPadBottom = dense ? 8.0 : 10.0;
    final micSize = dense ? 40.0 : 44.0;
    final fieldHeight = dense ? 40.0 : 44.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, bottomPad),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _barBg,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: _barBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!expanded) ...[
              SizedBox(height: handleGap),
              Container(
                width: 36,
                height: dense ? 3 : 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
            Padding(
              padding: EdgeInsets.fromLTRB(10, expanded ? 10 : rowPadV, 10, rowPadBottom),
              child: Row(
                children: [
                  _GeminiMicChip(
                    useHero: useHeroMic,
                    listening: status == AiProcessingStatus.listening,
                    onTap: onMicTap,
                    size: micSize,
                  ),
                  SizedBox(width: dense ? 8 : 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: onTapPlaceholder,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: fieldHeight,
                        alignment: AlignmentDirectional.centerStart,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          'اسأل مساعد AIMstore',
                          style: aiChatCairo(
                            14,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _GeminiBarIcon(
                    icon: Icons.add_rounded,
                    onTap: onSuggestTap,
                  ),
                  const SizedBox(width: 4),
                  _GeminiBarIcon(
                    icon: showTextField
                        ? Icons.keyboard_hide_rounded
                        : Icons.keyboard_alt_outlined,
                    onTap: onToggleInput,
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              clipBehavior: Clip.hardEdge,
              child: !dense && showTextField
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: _GeminiTextField(
                        controller: textController,
                        onSend: onTextSend,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeminiMicChip extends StatelessWidget {
  final bool useHero;
  final bool listening;
  final VoidCallback onTap;
  final double size;

  const _GeminiMicChip({
    required this.useHero,
    required this.listening,
    required this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: listening
              ? [const Color(0xFF6BC489), kMintBrand]
              : [kMintDark, kMintGradientC],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: listening
            ? [
                BoxShadow(
                  color: kMintBrand.withValues(alpha: 0.55),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Icon(
        listening ? Icons.mic_rounded : Icons.mic_none_rounded,
        color: Colors.white,
        size: 22,
      ),
    );

    chip = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: chip,
      ),
    );

    if (useHero) {
      chip = Hero(
        tag: 'ai_button',
        child: Material(type: MaterialType.transparency, child: chip),
      );
    }
    return chip;
  }
}

class _GeminiBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GeminiBarIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.82), size: 22),
        ),
      ),
    );
  }
}

class _GeminiTextField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _GeminiTextField({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            style: aiChatCairo(14, color: Colors.white),
            textDirection: TextDirection.rtl,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              hintText: 'اكتب رسالتك...',
              hintTextDirection: TextDirection.rtl,
              hintStyle: aiChatCairo(14, color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: onSend,
          style: IconButton.styleFrom(
            backgroundColor: kMintBrand,
            foregroundColor: kMintDark,
          ),
          icon: const Icon(Icons.send_rounded, size: 20),
        ),
      ],
    );
  }
}

class ChatBottomBar extends StatelessWidget {
  final bool useHeroMic;
  final AiProcessingStatus status;
  final bool showTextField;
  final TextEditingController textController;
  final VoidCallback onMicTap;
  final VoidCallback onTextSend;
  final VoidCallback onToggleInput;

  const ChatBottomBar({
    super.key,
    this.useHeroMic = false,
    required this.status,
    required this.showTextField,
    required this.textController,
    required this.onMicTap,
    required this.onTextSend,
    required this.onToggleInput,
  });

  @override
  Widget build(BuildContext context) {
    Widget mic = VoiceMicButton(status: status, onTap: onMicTap);
    if (useHeroMic) {
      mic = Hero(
        tag: 'ai_button',
        child: Material(type: MaterialType.transparency, child: mic),
      );
    }
    mic = Transform.translate(offset: const Offset(0, -12), child: mic);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + 12,
        top: 12,
        right: 16,
        left: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InputToggleButton(
                showTextField: showTextField,
                onTap: onToggleInput,
              ),
              SizedBox(width: 96, height: 96, child: Center(child: mic)),
              ActionIconButton(
                icon: Icons.emoji_objects_outlined,
                onTap: () => context
                    .read<AiControllerCubit>()
                    .sendTextMessage('اقترح لي منتجات مميزة اليوم'),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: showTextField
                ? ChatTextField(controller: textController, onSend: onTextSend)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class InputToggleButton extends StatelessWidget {
  final bool showTextField;
  final VoidCallback onTap;

  const InputToggleButton({
    super.key,
    required this.showTextField,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              showTextField ? kMintBrand.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: kMintBrand.withValues(alpha: 0.55),
            width: 1.2,
          ),
        ),
        child: Icon(
          showTextField
              ? Icons.keyboard_hide_rounded
              : Icons.keyboard_alt_outlined,
          color: kMintDark,
          size: 20,
        ),
      ),
    );
  }
}

class ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const ActionIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: kMintBrand.withValues(alpha: 0.55),
            width: 1.2,
          ),
        ),
        child: Icon(icon, color: kMintDark, size: 20),
      ),
    );
  }
}

class ChatTextField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatTextField({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kMintPaleBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kMintBrand.withValues(alpha: 0.2)),
              ),
              child: TextField(
                controller: controller,
                style: aiChatCairo(14, color: kMintDark),
                textDirection: TextDirection.rtl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: aiChatCairo(14, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: kMintBrand, size: 20),
                    onPressed: onSend,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatCartSheet extends StatelessWidget {
  final BuildContext parentContext;

  const ChatCartSheet({super.key, required this.parentContext});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<CartCubit>(),
        child: ChatCartSheet(parentContext: context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollCtrl) => BlocBuilder<CartCubit, CartState>(
          builder: (context, cart) {
            return Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'السلة (${cart.distinctCount})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kMintDark,
                        ),
                      ),
                      if (cart.isNotEmpty)
                        TextButton.icon(
                          onPressed: () =>
                              context.read<CartCubit>().clearCart(),
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 18, color: Color(0xFFFF4757)),
                          label: const Text('مسح الكل',
                              style: TextStyle(color: Color(0xFFFF4757))),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: cart.isEmpty
                      ? const ChatEmptyCart()
                      : ListView.separated(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: cart.items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) =>
                              ChatCartItemTile(item: cart.items[i]),
                        ),
                ),
                if (cart.isNotEmpty)
                  ChatCartFooter(
                    total: cart.total,
                    parentContext: parentContext,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ChatCartItemTile extends StatelessWidget {
  final CartItem item;

  const ChatCartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppNetworkImage(
              product.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              error: Container(
                width: 64,
                height: 64,
                color: kMintPaleBg,
                child: const Icon(Icons.image_not_supported_outlined,
                    color: kMintBrand, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kMintDark,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.effectivePrice.toStringAsFixed(0)} \u{20C1}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: kMintBrand,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ChatQuantityControls(item: item),
        ],
      ),
    );
  }
}

class ChatQuantityControls extends StatelessWidget {
  final CartItem item;

  const ChatQuantityControls({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        QtyButton(
          icon: Icons.remove,
          onTap: () =>
              cubit.updateQuantity(item.product.id, item.quantity - 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '${item.quantity}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kMintDark,
            ),
          ),
        ),
        QtyButton(
          icon: Icons.add,
          onTap: () =>
              cubit.updateQuantity(item.product.id, item.quantity + 1),
        ),
      ],
    );
  }
}

class QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const QtyButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: kMintPaleBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: kMintBrand),
      ),
    );
  }
}

class ChatCartFooter extends StatelessWidget {
  final double total;
  final BuildContext parentContext;

  const ChatCartFooter({
    super.key,
    required this.total,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('الإجمالي',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                '${total.toStringAsFixed(0)} \u{20C1}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kMintBrand,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await openCheckoutFromChat(parentContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kMintBrand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'إتمام الشراء',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatEmptyCart extends StatelessWidget {
  const ChatEmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          const Text(
            'السلة فارغة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kMintDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'تحدث مع المساعد ليقترح عليك منتجات',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
