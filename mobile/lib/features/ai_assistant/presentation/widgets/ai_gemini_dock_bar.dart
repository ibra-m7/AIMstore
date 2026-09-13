import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/ai_controller_cubit.dart';

/// شريط إدخال Gemini — ميكروفون + حقل نص inline فقط.
class AiGeminiDockBar extends StatelessWidget {
  final AiProcessingStatus status;
  final TextEditingController textController;
  final VoidCallback onMicTap;
  final VoidCallback onSend;
  final VoidCallback? onFocus;
  final bool compact;
  final double? heightOverride;

  const AiGeminiDockBar({
    super.key,
    required this.status,
    required this.textController,
    required this.onMicTap,
    required this.onSend,
    this.onFocus,
    this.compact = false,
    this.heightOverride,
  });

  static const standardBarHeight = 58.0;
  static const compactBarHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    final listening = status == AiProcessingStatus.listening;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final resolvedHeight = heightOverride ??
        (compact ? compactBarHeight : standardBarHeight);
    final horizontalPad = compact ? 10.0 : 12.0;
    final bottomPadding = compact
        ? 4.0
        : (bottomPad > 0 ? 4.0 : 8.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPad,
        0,
        horizontalPad,
        bottomPadding,
      ),
      child: Material(
        color: AppTheme.surface,
        elevation: compact ? 4 : 6,
        shadowColor: AppTheme.primaryDark.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        child: Container(
          height: resolvedHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.28),
              width: 1.2,
            ),
            gradient: LinearGradient(
              colors: [
                AppTheme.background,
                AppTheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8),
          child: Row(
            children: [
              _DockMicButton(
                listening: listening,
                onTap: onMicTap,
                compact: compact,
              ),
              SizedBox(width: compact ? 6 : 8),
              Expanded(
                child: TextField(
                  controller: textController,
                  onTap: onFocus,
                  onChanged: (_) => onFocus?.call(),
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: compact ? 13 : 14,
                    color: AppTheme.darkText,
                  ),
                  textDirection: TextDirection.rtl,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: 'اسأل مساعد AIMstore',
                    hintTextDirection: TextDirection.rtl,
                    hintStyle: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: compact ? 13 : 14,
                      color: AppTheme.mutedText.withValues(alpha: 0.85),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: compact ? 10 : 14,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onSend,
                icon: Icon(
                  Icons.arrow_upward_rounded,
                  color: AppTheme.primaryDark,
                  size: compact ? 20 : 22,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primarySurface,
                  minimumSize: Size(compact ? 36 : 40, compact ? 36 : 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockMicButton extends StatefulWidget {
  final bool listening;
  final VoidCallback onTap;
  final bool compact;

  const _DockMicButton({
    required this.listening,
    required this.onTap,
    this.compact = false,
  });

  @override
  State<_DockMicButton> createState() => _DockMicButtonState();
}

class _DockMicButtonState extends State<_DockMicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant _DockMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listening != widget.listening) _syncPulse();
  }

  void _syncPulse() {
    if (widget.listening) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.compact ? 40.0 : 44.0;
    final iconSize = widget.compact ? 20.0 : 22.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final scale = widget.listening ? 1.0 + _pulse.value * 0.08 : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: widget.listening
                      ? [AppTheme.primary, AppTheme.primaryDark]
                      : [AppTheme.primaryDark, AppTheme.primary],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: widget.listening
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.45),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          );
        },
      ),
    );
  }
}
