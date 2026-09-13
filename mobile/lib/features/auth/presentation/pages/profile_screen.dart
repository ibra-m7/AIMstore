import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../content_pages/data/services/content_pages_api.dart';
import '../../../content_pages/presentation/content_page_nav.dart';
import '../../../notifications/data/services/push_service.dart';
import '../../../notifications/presentation/manager/notifications_cubit.dart';
import '../../../shop/presentation/manager/favorite_cubit.dart';
import '../../../shop/presentation/manager/orders_cubit.dart';
import '../../../shop/presentation/pages/orders_screen.dart';
import '../../../shop/presentation/widgets/main_shell_scope.dart';
import '../../data/models/auth_user.dart';
import '../../data/services/auth_session.dart';
import '../../data/services/phone_auth_api.dart';
import '../auth_flow.dart';
import '../manager/address_cubit.dart';
import '../widgets/delivery_addresses_sheet.dart';
import '../widgets/edit_name_sheet.dart';
import '../widgets/profile_contact.dart';
import '../widgets/profile_luxe.dart';
import '../widgets/profile_luxe_header.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _openMyOrders() async {
    final tab = await Navigator.of(context, rootNavigator: true).push<int>(
      CupertinoPageRoute<int>(
        settings: const RouteSettings(name: OrdersScreen.routeName),
        builder: (_) => const OrdersScreen(),
      ),
    );
    if (!mounted || tab == null) return;
    MainShellNavigation.goToTab(context, tab);
  }

  void _confirmSignOut() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          buttonPadding: EdgeInsets.zero,
          title: const Text(
            AppStrings.profileSignOutConfirmTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          content: const Text(
            AppStrings.profileSignOutConfirmBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.45,
              color: Color(0xFF5A5A5A),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: Row(
                textDirection: TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      await PushService.instance.unregisterForLogout();
                      await PhoneAuthApi.instance.logout();
                      if (!mounted) return;
                      try {
                        context.read<OrdersCubit>().load();
                      } catch (_) {}
                      try {
                        context.read<NotificationsCubit>().load();
                      } catch (_) {}
                      try {
                        context.read<AddressCubit>().load();
                      } catch (_) {}
                    },
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: const Text(
                      AppStrings.profileSignOut,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: const Text(
                      AppStrings.cancel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthSession.instance,
      builder: (context, _) {
        if (!AuthSession.instance.isLoggedIn) {
          return _GuestProfileView(
            onLogin: () => AuthFlow.openLogin(context),
          );
        }
        return _LoggedInProfileView(
          user: AuthSession.instance.user!,
          onOrdersTap: _openMyOrders,
          onSignOut: _confirmSignOut,
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// العرض بعد تسجيل الدخول
// ══════════════════════════════════════════════════════════════════════════════
class _LoggedInProfileView extends StatefulWidget {
  final AuthUser user;
  final VoidCallback onOrdersTap;
  final VoidCallback onSignOut;

  const _LoggedInProfileView({
    required this.user,
    required this.onOrdersTap,
    required this.onSignOut,
  });

  @override
  State<_LoggedInProfileView> createState() => _LoggedInProfileViewState();
}

class _LoggedInProfileViewState extends State<_LoggedInProfileView>
    with SingleTickerProviderStateMixin {
  static const _appVersion = '1.0.0';

  late final AnimationController _entrance;
  List<ContentPage> _menuPages = const [];
  List<ContentPage> _footerPages = const [];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    // نضمن جاهزية عدّاد الطلبات عند فتح الصفحة مباشرة.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final orders = context.read<OrdersCubit>();
        if (orders.state.orders.isEmpty && !orders.state.loading) {
          orders.load();
        }
      } catch (_) {}
    });

    _loadContentPages();
  }

  Future<void> _loadContentPages() async {
    final menu = await ContentPagesApi.instance.list(
      placement: ContentPagePlacement.profileMenu,
    );
    final footer = await ContentPagesApi.instance.list(
      placement: ContentPagePlacement.profileFooter,
    );
    if (!mounted) return;
    setState(() {
      _menuPages = menu;
      _footerPages = footer;
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  AuthUser get user => widget.user;

  Future<void> _openEditProfile() async {
    final saved = await EditNameSheet.show(
      context,
      currentName: user.name,
      phone: user.phone ?? '',
    );
    if (saved && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: kLuxeBodyBg,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── الهيدر: أفاتار + الاسم + الموجتان المتقاطعتان ─────────────
              ProfileLuxeHeader(
                name: user.name,
                phone: user.phone,
                avatarUrl: user.avatar,
                onEditTap: _openEditProfile,
                entrance: _entrance,
              ),

              // ── قائمة الحساب ─────────────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 14, bottom: 6),
                  children: [
                    BlocBuilder<FavoriteCubit, FavoriteState>(
                      builder: (context, state) => _LuxeMenuRow(
                        icon: Icons.favorite_border_rounded,
                        label: AppStrings.favoritesTitle,
                        count: state.length,
                        entrance: _entrance,
                        order: 0,
                        onTap: () => Navigator.of(context, rootNavigator: true)
                            .pushNamed(AppRouter.favorites),
                      ),
                    ),
                    BlocBuilder<OrdersCubit, OrdersState>(
                      builder: (context, state) => _LuxeMenuRow(
                        icon: Icons.receipt_long_outlined,
                        label: AppStrings.profileOrders,
                        count: state.orders.length,
                        entrance: _entrance,
                        order: 1,
                        onTap: widget.onOrdersTap,
                      ),
                    ),
                    _LuxeMenuRow(
                      icon: Icons.location_on_outlined,
                      label: AppStrings.profileAddresses,
                      entrance: _entrance,
                      order: 2,
                      onTap: () => DeliveryAddressesSheet.show(context),
                    ),
                    _LuxeMenuRow(
                      leading: const WhatsAppIcon(size: 20),
                      label: AppStrings.profileContactUs,
                      entrance: _entrance,
                      order: 3,
                      onTap: () => openCompanyWhatsapp(context),
                    ),
                    _LuxeMenuRow(
                      icon: Icons.headset_mic_outlined,
                      label: AppStrings.profileCustomerService,
                      entrance: _entrance,
                      order: 4,
                      onTap: () => openCustomerService(context),
                    ),
                    _LuxeMenuRow(
                      icon: Icons.settings_outlined,
                      label: AppStrings.profileSettings,
                      entrance: _entrance,
                      order: 5,
                      onTap: () => Navigator.of(context, rootNavigator: true)
                          .pushNamed(AppRouter.accountSettings),
                    ),
                    for (var i = 0; i < _menuPages.length; i++)
                      _LuxeMenuRow(
                        icon: Icons.description_outlined,
                        label: _menuPages[i].buttonLabel,
                        entrance: _entrance,
                        order: 6 + i,
                        onTap: () => openContentPage(context, _menuPages[i]),
                      ),
                  ],
                ),
              ),

              // ── التذييل: خروج + النسخة + الخصوصية ───────────────────────
              _ProfileFooter(
                version: _appVersion,
                onSignOut: widget.onSignOut,
                contentPages: _footerPages,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// صف القائمة — أيقونة + عنوان + عدّاد دائري (نفس المرجع، بلا فواصل)
// ══════════════════════════════════════════════════════════════════════════════
class _LuxeMenuRow extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String label;
  final int count;
  final VoidCallback? onTap;
  final Animation<double> entrance;
  final int order;

  const _LuxeMenuRow({
    this.icon,
    this.leading,
    required this.label,
    required this.entrance,
    required this.order,
    this.count = 0,
    this.onTap,
  }) : assert(icon != null || leading != null);

  @override
  Widget build(BuildContext context) {
    final start = (0.22 + order * 0.09).clamp(0.0, 0.82);
    final animation = CurvedAnimation(
      parent: entrance,
      curve: Interval(
        start,
        (start + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - animation.value)),
          child: child,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: kLuxeRowTint,
          highlightColor: kLuxeRowTint.withValues(alpha: 0.7),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Center(
                          child: leading ??
                              Icon(icon, size: 20, color: kLuxeRowLabel),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: kLuxeRowLabel,
                          ),
                        ),
                      ),
                      if (count > 0) ...[
                        _LuxeCountBadge(count: count),
                        const SizedBox(width: 6),
                      ],
                      Icon(
                        Icons.chevron_left_rounded,
                        size: 20,
                        color: kLuxeFooterText.withValues(alpha: 0.7),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  color: kLuxeHairline.withValues(alpha: 0.55),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// عدّاد دائري متدرّج — يعرض العدد بجانب العنصر كما في المرجع.
class _LuxeCountBadge extends StatelessWidget {
  final int count;

  const _LuxeCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : '$count';

    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      height: 22,
      padding: EdgeInsets.symmetric(horizontal: count > 9 ? 6 : 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kLuxeVividA.withValues(alpha: 0.14),
        border: Border.all(
          color: kLuxeVividA.withValues(alpha: 0.28),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: kLuxeVividA.withValues(alpha: 0.35),
            blurRadius: 8,
            spreadRadius: 0.5,
            offset: const Offset(3, 0),
          ),
          BoxShadow(
            color: kLuxeVividB.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(1, 0),
          ),
        ],
      ),
      child: Text(
        text,
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: kLuxeDeepA.withValues(alpha: 0.85),
          height: 1,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// التذييل
// ══════════════════════════════════════════════════════════════════════════════
class _ProfileFooter extends StatelessWidget {
  final String version;
  final VoidCallback onSignOut;
  final List<ContentPage> contentPages;

  const _ProfileFooter({
    required this.version,
    required this.onSignOut,
    this.contentPages = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Row(
              children: [
                const Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x00A8B0C0),
                          Color(0x88A8B0C0),
                          Color(0xE0A8B0C0),
                        ],
                      ),
                    ),
                    child: SizedBox(height: 1.4),
                  ),
                ),
                InkWell(
                  onTap: onSignOut,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: AppTheme.accent,
                          textDirection: TextDirection.ltr,
                        ),
                        Text(
                          AppStrings.profileSignOut,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xE0A8B0C0),
                          Color(0x88A8B0C0),
                          Color(0x00A8B0C0),
                        ],
                      ),
                    ),
                    child: SizedBox(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          Text(
            AppStrings.profileVersionLabel(version),
            style: TextStyle(
              fontSize: 11,
              color: kLuxeFooterText.withValues(alpha: 0.7),
            ),
          ),
          if (contentPages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 4),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (var i = 0; i < contentPages.length; i++) ...[
                    if (i > 0)
                      Text(
                        '·',
                        style: TextStyle(
                          fontSize: 11,
                          color: kLuxeFooterText.withValues(alpha: 0.45),
                        ),
                      ),
                    InkWell(
                      onTap: () => openContentPage(context, contentPages[i]),
                      child: Text(
                        contentPages[i].buttonLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: kLuxeFooterText.withValues(alpha: 0.7),
                          decoration: TextDecoration.underline,
                          decorationColor:
                              kLuxeFooterText.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// عرض الزائر
// ══════════════════════════════════════════════════════════════════════════════
class _GuestProfileView extends StatelessWidget {
  final VoidCallback onLogin;

  const _GuestProfileView({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: kLuxeBodyBg,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: topInset +
                    kLuxeHeaderTopPad +
                    ProfileLuxeHeader.avatarBoxHeight +
                    kLuxeProfileWaveHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Positioned.fill(
                      child: ColoredBox(color: Colors.white),
                    ),
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: kLuxeProfileWaveHeight,
                      child: CustomPaint(painter: LuxeWavePainter()),
                    ),
                    Positioned.fill(
                      child: Column(
                        children: [
                          SizedBox(height: topInset + kLuxeHeaderTopPad),
                          Center(
                            child: Container(
                              width: ProfileLuxeHeader.avatarSize,
                              height: ProfileLuxeHeader.avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: kLuxeDeepA.withValues(alpha: 0.14),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(2.5),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primarySurface,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 38,
                                  color: kLuxeDeepA,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 26),
                      const Text(
                        AppStrings.guestProfileTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const LuxeGoldRule(width: 44),
                      const SizedBox(height: 14),
                      Text(
                        AppStrings.guestProfileBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.65,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.mutedText.withValues(alpha: 0.95),
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        height: 46,
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onLogin,
                          style: FilledButton.styleFrom(
                            backgroundColor: kLuxeDeepA,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            AppStrings.guestLoginCta,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
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
