import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_count_badge.dart';
import '../manager/cart_cubit.dart';
import 'celebrate_anchors.dart';

const _kSurface = Color(0xFFFFFFFF);
const _kSubtext = Color(0xFF6B8A76);

/// قصّة علوية مركزية + زوايا دائرية لشريط الملصق العائم.
class _AiNavBarNotchClipper extends CustomClipper<Path> {
  const _AiNavBarNotchClipper({
    this.cornerRadius = 20,
    this.fabDiameter = 64,
    this.fabCenterDy = 0,
    this.notchMargin = 6,
  });

  final double cornerRadius;
  final double fabDiameter;
  final double fabCenterDy;
  final double notchMargin;

  @override
  Path getClip(Size size) {
    final hostRect = Offset.zero & size;
    final guestRect = Rect.fromCenter(
      center: Offset(size.width / 2, fabCenterDy),
      width: fabDiameter + notchMargin * 2,
      height: fabDiameter + notchMargin * 2,
    );
    final notched =
        const CircularNotchedRectangle().getOuterPath(hostRect, guestRect);
    final rounded = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          hostRect,
          Radius.circular(cornerRadius),
        ),
      );
    return Path.combine(PathOperation.intersect, notched, rounded);
  }

  @override
  bool shouldReclip(covariant _AiNavBarNotchClipper oldClipper) =>
      oldClipper.cornerRadius != cornerRadius ||
      oldClipper.fabDiameter != fabDiameter ||
      oldClipper.fabCenterDy != fabCenterDy ||
      oldClipper.notchMargin != notchMargin;
}

/// شريط التنقل السفلي المشترك بين [MainScreen] ومسار [CheckoutScreen].
///
/// فهارس التبويب: 0 رئيسية، 1 أقسام، 2 سلة، 3 حسابي. زر المساعد (وسط) يفتح الشات عبر [onAiAssistantTap].
/// البصر (RTL): من اليمين للشمال — رئيسية، أقسام، زر المساعد (وسط)، سلة، حسابي.
///
/// عند [cartScreenActive] (مسار السلة المنبثق): تُبرز أيقونة السلة وتُعطّل إعادة فتحها.
class MainBottomNavBar extends StatelessWidget {
  final int currentTabIndex;

  /// true عند عرض الشريط فوق [CheckoutScreen] المفتوح كمسار (وليس كتبويب).
  final bool cartScreenActive;

  final ValueChanged<int> onTabTap;

  /// فتح شاشة المحادثة فوق الـ shell (يُستخدَم مع `Navigator` الجذر لإخفاء الشريط السفلي).
  final VoidCallback? onAiAssistantTap;

  /// عند `true`: يلفّ زر المساعد الوسطي بـ [Hero] tag `ai_button`.
  final bool wrapAiCenterHero;

  /// تمييز زر المساعد عند فتح اللوحة العائمة.
  final bool isAiActive;

  const MainBottomNavBar({
    super.key,
    required this.currentTabIndex,
    this.cartScreenActive = false,
    required this.onTabTap,
    this.onAiAssistantTap,
    this.wrapAiCenterHero = true,
    this.isAiActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    final barHeight = scale.s(70).clamp(66.0, 76.0);
    const aiButtonSize = 80.0;
    const fabOuter = 72.0;
    // رفع أوضح فوق الشريط ليجلس داخل صقل اللوحة.
    const aiLift = 28.0;
    const hMargin = 16.0;
    const floatBottom = 10.0;
    const cornerRadius = 20.0;
    const fabCenterDy = (aiButtonSize / 2) - aiLift;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: aiLift + barHeight + floatBottom + bottomPad,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: hMargin,
            right: hMargin,
            bottom: floatBottom + bottomPad,
            height: barHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cornerRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 22,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppTheme.primaryDark.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: PhysicalShape(
                clipper: const _AiNavBarNotchClipper(
                  cornerRadius: cornerRadius,
                  fabDiameter: fabOuter,
                  fabCenterDy: fabCenterDy,
                  notchMargin: 6,
                ),
                elevation: 0,
                color: _kSurface,
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: barHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _SimpleNavItem(
                          icon: (!cartScreenActive && currentTabIndex == 0)
                              ? Icons.storefront_rounded
                              : Icons.storefront_outlined,
                          label: AppStrings.navHome,
                          isActive:
                              !cartScreenActive && currentTabIndex == 0,
                          onTap: () => onTabTap(0),
                        ),
                      ),
                      Expanded(
                        child: _SimpleNavItem(
                          icon: (!cartScreenActive && currentTabIndex == 1)
                              ? Icons.category_rounded
                              : Icons.category_outlined,
                          label: AppStrings.navCategories,
                          isActive:
                              !cartScreenActive && currentTabIndex == 1,
                          onTap: () => onTabTap(1),
                        ),
                      ),
                      const SizedBox(width: 76),
                      Expanded(
                        child: _CartNavItem(
                          isActive: cartScreenActive || currentTabIndex == 2,
                          onTap: (cartScreenActive || currentTabIndex == 2)
                              ? null
                              : () => onTabTap(2),
                        ),
                      ),
                      Expanded(
                        child: _SimpleNavItem(
                          icon: (!cartScreenActive && currentTabIndex == 3)
                              ? Icons.person_rounded
                              : Icons.person_outline_rounded,
                          label: AppStrings.navProfile,
                          isActive:
                              !cartScreenActive && currentTabIndex == 3,
                          onTap: () => onTabTap(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _buildAiCenterButton(context),
            ),
          ),
        ],
      ),
    );
  }

  /// زر المساعد — نفس الزر يفتح/يغلق اللوحة (بدون Hero مسار منفصل).
  Widget _buildAiCenterButton(BuildContext context) {
    return _AiCenterButton(
      isActive: isAiActive,
      onTap: () => onAiAssistantTap?.call(),
    );
  }
}

class _SimpleNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SimpleNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  static const _iconSize = 26.0;

  @override
  Widget build(BuildContext context) {
    final labelSize = AppScale.of(context).s(11.5).clamp(11.0, 12.5);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              icon,
              key: ValueKey(isActive),
              size: _iconSize,
              color: isActive ? AppTheme.primaryDark : _kSubtext,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: (isActive
                    ? AppTextStyles.navLabelActive
                    : AppTextStyles.navLabel)
                .copyWith(
              fontSize: labelSize,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppTheme.primaryDark : _kSubtext,
              height: 1.1,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartNavItem extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onTap;

  const _CartNavItem({
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final labelSize = AppScale.of(context).s(11.5).clamp(11.0, 12.5);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CartNavIcon(isActive: isActive),
          const SizedBox(height: 4),
          Text(
            AppStrings.navCart,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (isActive
                    ? AppTextStyles.navLabelActive
                    : AppTextStyles.navLabel)
                .copyWith(
              fontSize: labelSize,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppTheme.primaryDark : _kSubtext,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartNavIcon extends StatefulWidget {
  final bool isActive;

  const _CartNavIcon({required this.isActive});

  @override
  State<_CartNavIcon> createState() => _CartNavIconState();
}

class _CartNavIconState extends State<_CartNavIcon>
    with SingleTickerProviderStateMixin {
  final GlobalKey _measureKey = GlobalKey();
  final GlobalKey _iconKey = GlobalKey();
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounceScale;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _bounceScale = Tween<double>(begin: 1, end: 1.26).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
    );
    CartNavAnchor.bounce.addListener(_onBouncePing);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindCartPosition());
  }

  @override
  void didUpdateWidget(covariant _CartNavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindCartPosition());
  }

  void _onBouncePing() {
    if (!mounted) return;
    _bounceCtrl.forward(from: 0);
  }

  void _bindCartPosition() {
    if (!mounted) return;
    CelebratePositions.bind(CelebratePositions.cartAnchor, _center);
    CelebratePositions.bind(CelebratePositions.cartIconAnchor, _iconCenter);
  }

  Offset? _iconCenter() => celebrateGlobalCenter(_iconKey);

  Offset? _center() {
    final box = _measureKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  @override
  void dispose() {
    CartNavAnchor.bounce.removeListener(_onBouncePing);
    CelebratePositions.unbind(CelebratePositions.cartAnchor);
    CelebratePositions.unbind(CelebratePositions.cartIconAnchor);
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _bounceScale,
      child: SizedBox(
        key: _measureKey,
        height: 26,
        width: 26,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(
              key: _iconKey,
              widget.isActive
                  ? Icons.shopping_bag_rounded
                  : Icons.shopping_bag_outlined,
              size: 26,
              color: widget.isActive ? AppTheme.primaryDark : _kSubtext,
            ),
            BlocBuilder<CartCubit, CartState>(
              buildWhen: (prev, curr) => prev.count != curr.count,
              builder: (context, state) {
                if (state.count <= 0) return const SizedBox.shrink();
                return AppCountBadge.positioned(
                  count: state.count,
                  top: -2,
                  end: -4,
                  fontSize: 9,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AiCenterButton extends StatefulWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _AiCenterButton({required this.isActive, required this.onTap});

  @override
  State<_AiCenterButton> createState() => _AiCenterButtonState();
}

class _AiCenterButtonState extends State<_AiCenterButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        height: 80,
        child: Center(
          child: ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: widget.isActive
                      ? [AppTheme.primary, AppTheme.primaryDark]
                      : [AppTheme.primaryDark, AppTheme.primary],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                border: Border.all(
                  color: Colors.white,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryDark.withValues(alpha: 0.28),
                    blurRadius: 14,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
