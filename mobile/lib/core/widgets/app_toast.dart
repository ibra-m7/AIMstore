import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum AppToastType { error, success, warning, info }

/// بانر Toast موحّد — خلفية فاتحة ملونة + نص داكن + زر اختياري بلون العلامة.
class AppToast {
  AppToast._();

  static Duration _defaultDuration(AppToastType type) {
    switch (type) {
      case AppToastType.error:
        return const Duration(milliseconds: 3500);
      case AppToastType.warning:
        return const Duration(milliseconds: 2500);
      case AppToastType.success:
      case AppToastType.info:
        return const Duration(seconds: 2);
    }
  }

  static (Color bg, Color text) colorsFor(AppToastType type) {
    switch (type) {
      case AppToastType.error:
        return (AppTheme.toastErrorBg, AppTheme.toastErrorText);
      case AppToastType.success:
        return (AppTheme.toastSuccessBg, AppTheme.toastSuccessText);
      case AppToastType.warning:
        return (AppTheme.toastWarningBg, AppTheme.toastWarningText);
      case AppToastType.info:
        return (AppTheme.toastInfoBg, AppTheme.toastInfoText);
    }
  }

  /// يعرض رسالة عائمة بنفس شكل بانر المساعد.
  static void show(
    BuildContext context,
    String message, {
    AppToastType type = AppToastType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
    bool aboveBottomNav = false,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;
    final marginBottom = aboveBottomNav ? bottomPad + 56 : 16.0;

    messenger.showSnackBar(
      SnackBar(
        content: AppToastBanner(
          message: message,
          type: type,
          actionLabel: actionLabel,
          onAction: onAction == null
              ? null
              : () {
                  messenger.hideCurrentSnackBar();
                  onAction();
                },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.fromLTRB(16, 0, 16, marginBottom),
        duration: duration ?? _defaultDuration(type),
      ),
    );
  }

  static void error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
    bool aboveBottomNav = false,
  }) =>
      show(
        context,
        message,
        type: AppToastType.error,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
        aboveBottomNav: aboveBottomNav,
      );

  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
    bool aboveBottomNav = false,
  }) =>
      show(
        context,
        message,
        type: AppToastType.success,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
        aboveBottomNav: aboveBottomNav,
      );

  static void warning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
    bool aboveBottomNav = false,
  }) =>
      show(
        context,
        message,
        type: AppToastType.warning,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
        aboveBottomNav: aboveBottomNav,
      );

  static void info(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
    bool aboveBottomNav = false,
  }) =>
      show(
        context,
        message,
        type: AppToastType.info,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
        aboveBottomNav: aboveBottomNav,
      );
}

/// المحتوى المرئي للبانر — يُستخدم أيضاً داخل ورقة المساعد.
class AppToastBanner extends StatelessWidget {
  const AppToastBanner({
    super.key,
    required this.message,
    this.type = AppToastType.error,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final String message;
  final AppToastType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (bg, textColor) = AppToast.colorsFor(type);
    final hasAction = actionLabel != null && onAction != null;
    final radius = BorderRadius.circular(compact ? 10 : 12);

    return Material(
      color: bg,
      borderRadius: radius,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 0 : 10,
        ),
        child: SizedBox(
          height: compact ? 36 : null,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  maxLines: compact ? 1 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 12 : 13,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
              if (hasAction)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    actionLabel!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: compact ? 12.5 : 13,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
