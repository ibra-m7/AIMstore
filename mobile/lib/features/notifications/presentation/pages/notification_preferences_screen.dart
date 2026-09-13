import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../../auth/data/services/auth_session.dart';
import '../../data/services/notifications_api.dart';
import '../../data/services/push_service.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  static const routeName = '/notification-preferences';

  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  bool _saving = false;

  Future<void> _patch({
    bool? enabled,
    bool? orders,
    bool? offers,
    bool? general,
  }) async {
    final user = AuthSession.instance.user;
    if (user == null || _saving) return;

    final previous = user;
    final optimistic = user.copyWith(
      notificationsEnabled: enabled,
      notificationsOrdersEnabled: orders,
      notificationsOffersEnabled: offers,
      notificationsGeneralEnabled: general,
    );
    await AuthSession.instance.updateUser(optimistic);
    setState(() => _saving = true);

    try {
      final updated = await NotificationsApi.instance.updatePreferences(
        enabled: enabled,
        orders: orders,
        offers: offers,
        general: general,
      );
      if (enabled != null) {
        unawaited(
          PushService.instance.applyPreference(
            updated?.notificationsEnabled ?? enabled,
          ),
        );
      }
    } catch (_) {
      await AuthSession.instance.updateUser(previous);
      if (mounted) {
        AppToast.error(context, AppStrings.profileNotificationsSaveFailed);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leadingWidth: 56,
            leading: CircleBackButton.appBarLeading(),
            title: const Text(
              AppStrings.notificationPrefsTitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkText,
              ),
            ),
          ),
          body: ListenableBuilder(
            listenable: AuthSession.instance,
            builder: (context, _) {
              final user = AuthSession.instance.user;
              if (user == null) {
                return const Center(child: Text('سجّل الدخول أولاً'));
              }

              final masterOn = user.notificationsEnabled;

              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                children: [
                  _PrefsCard(
                    child: _PrefRow(
                      icon: Icons.notifications_active_outlined,
                      title: AppStrings.notificationPrefsMaster,
                      subtitle: AppStrings.notificationPrefsMasterDesc,
                      value: masterOn,
                      enabled: !_saving,
                      onChanged: (v) => _patch(enabled: v),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _SectionLabel('أنواع الإشعارات'),
                  const SizedBox(height: 8),
                  _PrefsCard(
                    child: Column(
                      children: [
                        _PrefRow(
                          icon: Icons.local_shipping_outlined,
                          title: AppStrings.notificationPrefsOrders,
                          subtitle: AppStrings.notificationPrefsOrdersDesc,
                          value: user.notificationsOrdersEnabled,
                          enabled: !_saving && masterOn,
                          onChanged: (v) => _patch(orders: v),
                        ),
                        Divider(
                          height: 14,
                          color: AppTheme.primaryLight.withValues(alpha: 0.7),
                        ),
                        _PrefRow(
                          icon: Icons.local_offer_outlined,
                          title: AppStrings.notificationPrefsOffers,
                          subtitle: AppStrings.notificationPrefsOffersDesc,
                          value: user.notificationsOffersEnabled,
                          enabled: !_saving && masterOn,
                          onChanged: (v) => _patch(offers: v),
                        ),
                        Divider(
                          height: 14,
                          color: AppTheme.primaryLight.withValues(alpha: 0.7),
                        ),
                        _PrefRow(
                          icon: Icons.campaign_outlined,
                          title: AppStrings.notificationPrefsGeneral,
                          subtitle: AppStrings.notificationPrefsGeneralDesc,
                          value: user.notificationsGeneralEnabled,
                          enabled: !_saving && masterOn,
                          onChanged: (v) => _patch(general: v),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: AppTheme.mutedText.withValues(alpha: 0.95),
        ),
      ),
    );
  }
}

class _PrefsCard extends StatelessWidget {
  final Widget child;

  const _PrefsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: child,
    );
  }
}

class _PrefRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _PrefRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dim = !enabled;

    return Opacity(
      opacity: dim ? 0.45 : 1,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.primaryDark.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.mutedText.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.82,
            child: Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              thumbColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? Colors.white
                    : const Color(0xFFF5F5F5),
              ),
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.primary;
                }
                return const Color(0xFFD0D8D3);
              }),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}
