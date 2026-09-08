import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ai_chat_panel.dart';

/// لوحة مساعد عائمة — Gemini Dock: صغيرة، بدون scrim، تتوسّع عند التفاعل.
class AiChatDraggableSheet extends StatefulWidget {
  final VoidCallback onDismiss;
  final ValueChanged<double>? onExtentChanged;
  final double initialSize;

  const AiChatDraggableSheet({
    super.key,
    required this.onDismiss,
    this.onExtentChanged,
    this.initialSize = kAiSheetCompactSize,
  });

  static const kAiSheetCompactSize = 0.14;
  static const kAiSheetChatSize = 0.55;
  static const kAiSheetFullSize = 0.92;

  static const snapSizes = [
    kAiSheetCompactSize,
    kAiSheetChatSize,
    kAiSheetFullSize,
  ];

  static const compactThreshold = kAiSheetCompactThreshold;

  @override
  State<AiChatDraggableSheet> createState() => _AiChatDraggableSheetState();
}

class _AiChatDraggableSheetState extends State<AiChatDraggableSheet>
    with WidgetsBindingObserver {
  final DraggableScrollableController _sheetCtrl =
      DraggableScrollableController();
  double _extent = AiChatDraggableSheet.kAiSheetCompactSize;
  double _lastKeyboardInset = 0;
  bool _hasReachedOpenSize = false;
  bool _dismissArmed = false;

  @override
  void initState() {
    super.initState();
    _extent = widget.initialSize;
    _sheetCtrl.addListener(_onExtentChanged);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _dismissArmed = true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sheetCtrl.removeListener(_onExtentChanged);
    _sheetCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleKeyboardInset());
  }

  void _handleKeyboardInset() {
    if (!mounted) return;
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    if (inset > 0 && inset != _lastKeyboardInset && _extent < 0.85) {
      _expandTo(AiChatDraggableSheet.kAiSheetFullSize);
    }
    _lastKeyboardInset = inset;
  }

  Future<void> _expandTo(double size) async {
    if (!_sheetCtrl.isAttached) return;
    await _sheetCtrl.animateTo(
      size,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onExtentChanged() {
    if (!_sheetCtrl.isAttached) return;
    _reportExtent(_sheetCtrl.size);
  }

  void _reportExtent(double next) {
    if ((next - _extent).abs() < 0.005) return;
    final prev = _extent;
    if (next >= widget.initialSize * 0.82) {
      _hasReachedOpenSize = true;
    }
    setState(() => _extent = next);
    widget.onExtentChanged?.call(next);
    _maybeHapticSnap(prev, next);
  }

  void _maybeHapticSnap(double prev, double next) {
    for (final snap in AiChatDraggableSheet.snapSizes) {
      final wasNear = (prev - snap).abs() < 0.04;
      final isNear = (next - snap).abs() < 0.015;
      if (!wasNear && isNear) {
        hapticSheetSnap();
        break;
      }
    }
  }

  void _onNotification(DraggableScrollableNotification notification) {
    final extent = notification.extent;
    _reportExtent(extent);
    if (!_dismissArmed || !_hasReachedOpenSize) return;
    if (extent <= 0.09) {
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (n) {
        _onNotification(n);
        return false;
      },
      child: DraggableScrollableSheet(
        controller: _sheetCtrl,
        expand: false,
        snap: true,
        snapSizes: AiChatDraggableSheet.snapSizes,
        initialChildSize: widget.initialSize,
        minChildSize: 0.08,
        maxChildSize: AiChatDraggableSheet.kAiSheetFullSize,
        builder: (context, scrollController) {
          return Material(
            color: Colors.transparent,
            elevation: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: AiChatPanel(
                scrollController: scrollController,
                presentation: AiChatPresentation.embedded,
                onClose: widget.onDismiss,
                sheetExtent: _extent,
                onExpandSheet: () => _expandTo(
                  keyboardOpen
                      ? AiChatDraggableSheet.kAiSheetFullSize
                      : AiChatDraggableSheet.kAiSheetChatSize,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

void hapticSheetSnap() => HapticFeedback.mediumImpact();
