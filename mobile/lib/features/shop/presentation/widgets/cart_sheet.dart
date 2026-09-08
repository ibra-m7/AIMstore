import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../pages/checkout_screen.dart';

Future<void> showCartSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    useSafeArea: false,
    builder: (ctx) => const CartSheet(),
  );
}

class CartSheet extends StatefulWidget {
  const CartSheet({super.key});

  @override
  State<CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends State<CartSheet> {
  late final ScrollController _scrollCtrl;
  double _dismissDy = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  bool _tracksDismiss(Offset delta) {
    // الإغلاق فقط بسحب للأسفل (موجب)، وليس أثناء التمرير للأعلى داخل القائمة.
    if (delta.dy <= 0 && _dismissDy == 0) {
      return false;
    }
    if (delta.dx.abs() > delta.dy.abs() && _dismissDy == 0) {
      return false;
    }
    final atTop = !_scrollCtrl.hasClients || _scrollCtrl.offset <= 0.5;
    // لا تبدأ الإغلاق إلا عند أعلى الصفحة؛ بعد البدء أكمل الإيماءة.
    if (!atTop && _dismissDy == 0) {
      return false;
    }
    return atTop || _dismissDy > 0;
  }

  void _onDismissPointerMove(PointerMoveEvent event) {
    if (!_tracksDismiss(event.delta)) {
      return;
    }
    final height = MediaQuery.sizeOf(context).height;
    final next = (_dismissDy + event.delta.dy).clamp(0.0, height);
    if (next == _dismissDy) {
      return;
    }
    setState(() => _dismissDy = next);
  }

  void _onDismissPointerEnd(PointerEvent event) {
    if (_dismissDy >= 90) {
      Navigator.of(context).pop();
      return;
    }
    if (_dismissDy != 0) {
      setState(() => _dismissDy = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Listener(
        onPointerMove: _onDismissPointerMove,
        onPointerUp: _onDismissPointerEnd,
        onPointerCancel: _onDismissPointerEnd,
        child: AnimatedSlide(
          offset: Offset(0, _dismissDy / height),
          duration: _dismissDy == 0
              ? const Duration(milliseconds: 180)
              : Duration.zero,
          curve: Curves.easeOutCubic,
          child: Container(
            height: height * 0.90,
            decoration: const BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            clipBehavior: Clip.antiAlias,
            child: CartBody(
              scrollController: _scrollCtrl,
              scrollPhysics: _dismissDy > 0
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
            ),
          ),
        ),
      ),
    );
  }
}
