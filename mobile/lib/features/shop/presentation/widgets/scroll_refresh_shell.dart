import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// فيزياء بدون ارتداد — لا يظهر فراغ عند السحب.
const ScrollPhysics noGapScrollPhysics = AlwaysScrollableScrollPhysics(
  parent: ClampingScrollPhysics(),
);

/// يكتشف السحب لأسفل عند أعلى الصفحة ويشغّل التحديث دون تحريك المحتوى.
class TopPullRefreshDetector extends StatefulWidget {
  const TopPullRefreshDetector({
    super.key,
    required this.scrollController,
    required this.onRefresh,
    required this.child,
    this.pullTriggerExtent = 110,
  });

  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final Widget child;
  final double pullTriggerExtent;

  @override
  State<TopPullRefreshDetector> createState() => _TopPullRefreshDetectorState();
}

class _TopPullRefreshDetectorState extends State<TopPullRefreshDetector> {
  double _pullExtent = 0;
  bool _refreshing = false;

  Future<void> _triggerRefresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      await widget.onRefresh();
    } finally {
      _refreshing = false;
      _pullExtent = 0;
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    final controller = widget.scrollController;
    if (!controller.hasClients) return;
    if (controller.position.pixels > 0.5) {
      _pullExtent = 0;
      return;
    }
    if (event.delta.dy <= 0) return;

    _pullExtent += event.delta.dy;
    if (_pullExtent >= widget.pullTriggerExtent) {
      _pullExtent = 0;
      _triggerRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _onPointerMove,
      onPointerUp: (_) => _pullExtent = 0,
      onPointerCancel: (_) => _pullExtent = 0,
      child: widget.child,
    );
  }
}

/// دائرة تحميل ثابتة في أعلى الشاشة (فوق الـ AppBar / شريط الحالة).
class TopScreenRefreshIndicator extends StatelessWidget {
  const TopScreenRefreshIndicator({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: topInset > 0 ? topInset - 2 : 8,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppTheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
