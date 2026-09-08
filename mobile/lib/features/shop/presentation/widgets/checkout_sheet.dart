import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import 'coupon_badge_icon.dart';

Future<T?> showCheckoutSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: builder(ctx),
    ),
  );
}

class CheckoutSheetCloseButton extends StatelessWidget {
  static const double size = 28;

  const CheckoutSheetCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.85),
            blurRadius: 0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          customBorder: const CircleBorder(),
          child: const Center(
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: AppTheme.darkText,
            ),
          ),
        ),
      ),
    );
  }
}

class CheckoutSheetFrame extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;
  final bool compact;
  final bool showCloseButton;
  final double? maxHeightFactor;

  const CheckoutSheetFrame({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.footer,
    this.compact = true,
    this.showCloseButton = true,
    this.maxHeightFactor,
  });

  @override
  Widget build(BuildContext context) {
    final factor = maxHeightFactor ?? (compact ? 0.72 : 0.86);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * factor,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      22,
                      showCloseButton ? 18 : 20,
                      22,
                      8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 21.5,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.darkText,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.mutedText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showCloseButton)
                    const Positioned(
                      top: 14,
                      left: 16,
                      child: CheckoutSheetCloseButton(),
                    ),
                ],
              ),
              Flexible(child: child),
              if (footer != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: footer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckoutSheetButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color? background;

  const CheckoutSheetButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background ?? AppTheme.primaryDark,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFB7C9BC),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17.5,
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// حقل إدخال الكوبون داخل سكشن الخصومات في صفحة الطلب.
class CouponSectionInput extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final VoidCallback onApply;

  const CouponSectionInput({
    super.key,
    required this.controller,
    required this.loading,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ApplyCouponChipButton(
          loading: loading,
          onTap: loading ? null : onApply,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            enabled: !loading,
            textAlign: TextAlign.right,
            textCapitalization: TextCapitalization.characters,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-_]')),
              LengthLimitingTextInputFormatter(32),
            ],
            onSubmitted: (_) {
              if (!loading) onApply();
            },
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'أدخل كود قسيمة شرائية أو خصم',
              hintStyle: TextStyle(
                color: AppTheme.mutedText.withValues(alpha: 0.75),
                fontWeight: FontWeight.w500,
                fontSize: 13.5,
              ),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: Color(0xFFDCE5DF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: Color(0xFFDCE5DF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(
                  color: AppTheme.primaryDark,
                  width: 1.2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: Color(0xFFE8EFEA)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// زر «تطبيق الخصم» الصغير — للسكشن ولوحة الإدخال.
class ApplyCouponChipButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool loading;
  final bool filled;
  final double fontSize;

  const ApplyCouponChipButton({
    super.key,
    this.onTap,
    this.loading = false,
    this.filled = false,
    this.fontSize = 11.5,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);

    if (filled) {
      return Material(
        color: AppTheme.primaryDark,
        borderRadius: radius,
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'تطبيق الخصم',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
      );
    }

    return Material(
      color: AppTheme.background,
      borderRadius: radius,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: radius,
            border: Border.all(color: const Color(0xFFD4DDD6)),
          ),
          child: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  textDirection: TextDirection.ltr,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CouponBadgeIcon(size: 18),
                    const SizedBox(width: 5),
                    Text(
                      'تطبيق الخصم',
                      style: TextStyle(
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
