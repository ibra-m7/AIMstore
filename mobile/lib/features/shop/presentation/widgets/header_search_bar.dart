import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/typing_placeholder.dart';
import '../manager/catalog_cubit.dart';
import 'header_location_button.dart';

/// وضع الزجاج: الرئيسية (أيقونة منفصلة عند الانكماش) أو الأقسام (حقل غامق + نص فاتح).
enum HeaderSearchGlassMode { home, categories }

/// شريط بحث بيضاوي (ضغط يفتح شاشة البحث) — مشترك بين الرئيسية والأقسام.
class HeaderSearchBar extends StatelessWidget {
  final double height;
  final VoidCallback onTap;
  final double borderRadius;
  final List<String>? phrases;

  /// 0 = أبيض صلب، 1 = زجاجي شفاف / وضع الأب بار بدون حقل.
  final double glassAmount;
  final HeaderSearchGlassMode glassMode;

  /// فراغ إضافي من اليسار الفيزيائي (مثلاً لزر الموقع داخل الحقل).
  final double leadingEdgeInset;

  const HeaderSearchBar({
    super.key,
    required this.height,
    required this.onTap,
    this.borderRadius = 14,
    this.glassAmount = 0,
    this.phrases,
    this.glassMode = HeaderSearchGlassMode.home,
    this.leadingEdgeInset = 0,
  });

  @override
  Widget build(BuildContext context) {
    final g = glassAmount.clamp(0.0, 1.0);
    final fieldless =
        glassMode == HeaderSearchGlassMode.home && g > 0.45;
    final hintPhrases = (phrases != null && phrases!.isNotEmpty)
        ? phrases!
        : AppStrings.homeSearchHints;

    if (fieldless) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              const HeaderSearchIcon(glassAmount: 1, size: 36, iconSize: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _GlassHintText(
                    phrases: hintPhrases,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final categoriesScroll =
        glassMode == HeaderSearchGlassMode.categories && g > 0.12;
    final scrollT = categoriesScroll
        ? Curves.easeOut.transform(((g - 0.12) / 0.88).clamp(0.0, 1.0))
        : 0.0;

    final hintStyle = categoriesScroll
        ? AppTextStyles.searchHint.copyWith(
              color: Color.lerp(
                AppTheme.mutedText.withValues(alpha: 0.72),
                AppTheme.primaryDark.withValues(alpha: 0.88),
                scrollT,
              ),
            )
        : glassMode == HeaderSearchGlassMode.home
            ? _GlassHintText.homeBarHintStyle(context, g)
            : AppTextStyles.searchHint.copyWith(
                  color: AppTheme.mutedText.withValues(alpha: 0.75),
                );
    final fill = categoriesScroll
        ? Color.lerp(
            AppTheme.surface,
            AppTheme.surface.withValues(alpha: 0.96),
            scrollT,
          )!
        : Color.lerp(
            AppTheme.surface,
            Colors.white.withValues(alpha: 0.22),
            g,
          )!;
    final borderColor = categoriesScroll
        ? Color.lerp(
            const Color(0x1A6B8A76),
            AppTheme.primary.withValues(alpha: 0.38),
            scrollT,
          )!
        : Color.lerp(
            Colors.transparent,
            Colors.white.withValues(alpha: 0.55),
            g,
          )!;
    final iconGlass = categoriesScroll ? 0.0 : g;
    final shadowAlpha = categoriesScroll ? 0.06 + 0.04 * scrollT : 0.07 * (1 - g);

    final content = Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 10),
            child: HeaderSearchIcon(glassAmount: iconGlass),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 44, end: 16),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TypingPlaceholder(
                phrases: hintPhrases,
                style: hintStyle,
              ),
            ),
          ),
        ),
      ],
    );

    Widget bar = Container(
      height: height,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(borderRadius),
        border: (g > 0.02 || categoriesScroll)
            ? Border.all(color: borderColor, width: 1)
            : null,
        boxShadow: shadowAlpha < 0.01
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: shadowAlpha),
                  blurRadius: categoriesScroll ? 10 : 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: leadingEdgeInset > 0
          ? Padding(
              padding: EdgeInsets.only(left: leadingEdgeInset),
              child: content,
            )
          : content,
    );

    if ((g > 0.05 && !categoriesScroll) || (categoriesScroll && scrollT > 0.2)) {
      // بدون BackdropFilter — يسبب SIGTRAP على بعض أجهزة Samsung عند فتح الشيتات.
      bar = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: categoriesScroll
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primarySurface.withValues(alpha: 0.55 * scrollT),
                      AppTheme.surface.withValues(alpha: 0.35 * scrollT),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.42 * g),
                      Colors.white.withValues(alpha: 0.18 * g),
                    ],
                  ),
          ),
          child: bar,
        ),
      );
    }

    return GestureDetector(onTap: onTap, child: bar);
  }
}

/// أيقونة بحث — مشتركة بين الرئيسية وصفحة البحث.
class HeaderSearchIcon extends StatefulWidget {
  final double glassAmount;
  final double size;
  final double iconSize;

  const HeaderSearchIcon({
    super.key,
    required this.glassAmount,
    this.size = 28,
    this.iconSize = 18,
  });

  @override
  State<HeaderSearchIcon> createState() => _HeaderSearchIconState();
}

class _HeaderSearchIconState extends State<HeaderSearchIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    if (widget.glassAmount > 0.25) {
      _ctrl.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant HeaderSearchIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasGlass = oldWidget.glassAmount > 0.25;
    final isGlass = widget.glassAmount > 0.25;
    if (isGlass && !wasGlass) {
      _ctrl.repeat();
    } else if (!isGlass && wasGlass) {
      _ctrl
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.glassAmount.clamp(0.0, 1.0);
    final fieldless = g > 0.45;
    final iconColor = Color.lerp(
      AppTheme.primary,
      Colors.white,
      g,
    )!;

    if (fieldless) {
      return AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final t = _ctrl.value;
          final pulse = 1.0 + 0.05 * math.sin(t * math.pi * 2);
          final tilt = 0.1 * math.sin(t * math.pi * 2);
          return Transform.rotate(
            angle: tilt,
            child: Transform.scale(scale: pulse, child: child),
          );
        },
        child: ClipOval(
          child: Container(
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.48),
                  Colors.white.withValues(alpha: 0.14),
                  Colors.white.withValues(alpha: 0.28),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.72),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(-1, -1),
                ),
              ],
            ),
            child: Icon(
              Icons.search_rounded,
              size: widget.iconSize,
              color: Colors.white.withValues(alpha: 0.98),
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = _ctrl.value;
        final pulse = 1.0 + 0.08 * math.sin(t * math.pi * 2) * g;
        final tilt = 0.12 * math.sin(t * math.pi * 2) * g;
        final glow =
            (0.35 + 0.25 * (0.5 + 0.5 * math.sin(t * math.pi * 2))) * g;

        return Transform.rotate(
          angle: tilt,
          child: Transform.scale(
            scale: pulse,
            child: Container(
              width: widget.size,
              height: widget.size,
              alignment: Alignment.center,
              decoration: g > 0.15
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.18 * g),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.45 * g),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: glow * 0.55),
                          blurRadius: 10,
                          spreadRadius: 0.5,
                        ),
                      ],
                    )
                  : null,
              child: child,
            ),
          ),
        );
      },
      child: Icon(
        Icons.search_rounded,
        color: iconColor,
        size: widget.iconSize,
      ),
    );
  }
}

class _GlassHintText extends StatelessWidget {
  final List<String> phrases;
  final double fontSize;

  const _GlassHintText({
    required this.phrases,
    this.fontSize = 13,
  });

  static TextStyle glassTextStyle(
    BuildContext context, {
    double fontSize = 13,
  }) =>
      AppTextStyles.searchHint.copyWith(
            color: Colors.white.withValues(alpha: 0.96),
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            height: 1.2,
            letterSpacing: 0,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.32),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
              Shadow(
                color: Colors.white.withValues(alpha: 0.45),
                blurRadius: 4,
                offset: const Offset(0, -0.5),
              ),
            ],
          );

  /// نص تلميح الرئيسية داخل الحقل — صغير وبدون بولد، ثم يتدرج مع التمرير فوق البانر.
  static TextStyle homeBarHintStyle(BuildContext context, double g) {
    final t = Curves.easeOut.transform(g.clamp(0.0, 1.0));
    final glass = glassTextStyle(
      context,
      fontSize: lerpDouble(12, 13, t)!,
    );
    return glass.copyWith(
      fontWeight: FontWeight.w400,
      color: Color.lerp(
        AppTheme.mutedText.withValues(alpha: 0.62),
        Colors.white.withValues(alpha: 0.95),
        t,
      ),
      shadows: t > 0.1
          ? glass.shadows
          : [
              Shadow(
                color: Colors.white.withValues(alpha: 0.85),
                blurRadius: 5,
              ),
              Shadow(
                color: AppTheme.primary.withValues(alpha: 0.1),
                blurRadius: 3,
              ),
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _GlassHintShell(
      child: TypingPlaceholder(
        phrases: phrases,
        style: glassTextStyle(context, fontSize: fontSize),
      ),
    );
  }
}

/// حقل بحث قابل للكتابة — نفس تصميم الرئيسية (أيقونة زجاجية + نص زجاجي).
class HeaderSearchInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final List<String> phrases;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  const HeaderSearchInput({
    super.key,
    required this.controller,
    required this.phrases,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hintPhrases =
        phrases.where((p) => p.trim().isNotEmpty).toList().isEmpty
            ? AppStrings.homeSearchHints
            : phrases;
    final textStyle = _GlassHintText.glassTextStyle(context);

    return _GlassHintShell(
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final empty = value.text.trim().isEmpty;
          return Stack(
            alignment: Alignment.center,
            children: [
              TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: false,
                textInputAction: TextInputAction.search,
                textDirection: TextDirection.rtl,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                style: textStyle.copyWith(fontSize: 15),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          onPressed: onClear,
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.white.withValues(alpha: 0.88),
                            size: 18,
                          ),
                        )
                      : null,
                ),
              ),
              if (empty)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TypingPlaceholder(
                        phrases: hintPhrases,
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// صف البحث في صفحة البحث — نفس ترتيب الرئيسية (أيقونة + حقل زجاجي).
class HeaderSearchEntry extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final List<String> phrases;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  const HeaderSearchEntry({
    super.key,
    required this.controller,
    required this.phrases,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final height = AppScale.of(context).searchH;
    return SizedBox(
      height: height,
      child: Row(
        children: [
          const HeaderSearchIcon(glassAmount: 1, size: 36, iconSize: 22),
          const SizedBox(width: 10),
          Expanded(
            child: HeaderSearchInput(
              controller: controller,
              focusNode: focusNode,
              phrases: phrases,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              onClear: onClear,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassHintShell extends StatelessWidget {
  final Widget child;

  const _GlassHintShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.42),
              Colors.white.withValues(alpha: 0.18),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.55),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: child,
        ),
      ),
    );
  }
}

/// صف البحث + زر الموقع (مثل الرئيسية).
class HeaderSearchRow extends StatelessWidget {
  final VoidCallback onSearchTap;
  final bool onImage;
  final double chromeVisibility;
  final double searchBorderRadius;
  final double glassAmount;
  final HeaderSearchGlassMode glassMode;

  /// زر الموقع داخل حقل البحث من اليسار الفيزيائي، والحقل بعرض الصف كاملاً.
  final bool locationInsideLeading;

  const HeaderSearchRow({
    super.key,
    required this.onSearchTap,
    this.onImage = false,
    this.chromeVisibility = 1,
    this.searchBorderRadius = 14,
    this.glassAmount = 0,
    this.glassMode = HeaderSearchGlassMode.home,
    this.locationInsideLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    final showLocation = chromeVisibility > 0.02;
    return LayoutBuilder(
      builder: (context, constraints) {
        final locMax = constraints.maxWidth * 0.28;
        if (locationInsideLeading) {
          final inset = showLocation ? math.min(locMax, 118.0) : 0.0;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: HeaderSearchBar(
                  height: AppScale.of(context).searchH,
                  onTap: onSearchTap,
                  borderRadius: searchBorderRadius,
                  glassAmount: glassAmount,
                  glassMode: glassMode,
                  leadingEdgeInset: inset > 0 ? inset + 4 : 0,
                  phrases: context
                      .watch<CatalogCubit>()
                      .state
                      .store
                      .searchHintPhrases,
                ),
              ),
              if (showLocation)
                Positioned(
                  left: 6,
                  top: 0,
                  bottom: 0,
                  width: inset,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: chromeVisibility,
                      child: IgnorePointer(
                        ignoring: chromeVisibility < 0.2,
                        child: Opacity(
                          opacity: chromeVisibility,
                          child: HeaderLocationButton(onImage: onImage),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: HeaderSearchBar(
                height: AppScale.of(context).searchH,
                onTap: onSearchTap,
                borderRadius: searchBorderRadius,
                glassAmount: glassAmount,
                glassMode: glassMode,
                phrases: context
                    .watch<CatalogCubit>()
                    .state
                    .store
                    .searchHintPhrases,
              ),
            ),
            if (showLocation) ...[
              SizedBox(width: 4 * chromeVisibility),
              ClipRect(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  widthFactor: chromeVisibility,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: locMax),
                    child: IgnorePointer(
                      ignoring: chromeVisibility < 0.2,
                      child: Opacity(
                        opacity: chromeVisibility,
                        child: HeaderLocationButton(onImage: onImage),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
