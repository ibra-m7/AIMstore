import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../shop/presentation/manager/cart_cubit.dart';
import '../../../shop/presentation/manager/catalog_cubit.dart';
import '../cubit/ai_controller_cubit.dart';
import '../widgets/ai_chat_panel.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';

  final bool useHeroMic;

  const ChatScreen({
    super.key,
    this.useHeroMic = true,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AiControllerCubit>(
      create: (ctx) => ServiceLocator.instance.createAiController(
        cartCubit: ctx.read<CartCubit>(),
        catalogCubit: ctx.read<CatalogCubit>(),
      )..initConversation(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: ChatFullscreenAppBar(
            onOpenOptions: () {
              final host = context;
              showChatOptionsMenu(host);
            },
          ),
          body: AiChatPanel(
            scrollController: _scrollController,
            presentation: AiChatPresentation.fullscreen,
            onClose: () => Navigator.of(context).maybePop(),
            useHeroMic: widget.useHeroMic,
          ),
        ),
      ),
    );
  }
}
