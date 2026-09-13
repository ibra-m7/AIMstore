import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../../content_pages/data/services/content_pages_api.dart';
import '../../../content_pages/presentation/content_page_nav.dart';
import '../../../notifications/data/services/push_service.dart';
import '../../../notifications/presentation/manager/notifications_cubit.dart';
import '../../data/services/phone_auth_api.dart';
import '../../../shop/presentation/manager/orders_cubit.dart';
import '../manager/address_cubit.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<ContentPage> _legalPages = const [];

  @override
  void initState() {
    super.initState();
    _loadLegalPages();
  }

  Future<void> _loadLegalPages() async {
    final pages = await ContentPagesApi.instance.list(
      placement: ContentPagePlacement.settings,
    );
    if (!mounted) return;
    setState(() => _legalPages = pages);
  }

  void _openNotificationPreferences() {
    Navigator.of(context).pushNamed(AppRouter.notificationPreferences);
  }

  void _confirmDeleteAccount() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            AppStrings.profileDeleteAccountConfirmTitle,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            AppStrings.profileDeleteAccountConfirmBody,
            style: TextStyle(fontSize: 12.5, height: 1.55),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                AppStrings.cancel,
                style: TextStyle(fontSize: 12.5),
              ),
            ),
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
              child: const Text(
                AppStrings.profileSignOut,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              AppStrings.profileSettings,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkText,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
            children: [
              _SettingsSectionLabel(AppStrings.settingsSectionGeneral),
              const SizedBox(height: 8),
              _SettingsCard(
                dense: true,
                child: InkWell(
                  onTap: _openNotificationPreferences,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          size: 20,
                          color: AppTheme.primaryDark.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                AppStrings.profileNotifications,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.darkText,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                AppStrings.profileNotificationsDesc,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  height: 1.3,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.mutedText.withValues(
                                    alpha: 0.95,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppTheme.mutedText.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (_legalPages.isNotEmpty) ...[
                const _SettingsSectionLabel('المعلومات القانونية'),
                const SizedBox(height: 8),
                _SettingsCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < _legalPages.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 18,
                            color: AppTheme.primaryLight
                                .withValues(alpha: 0.7),
                          ),
                        InkWell(
                          onTap: () =>
                              openContentPage(context, _legalPages[i]),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primarySurface,
                                    borderRadius:
                                        BorderRadius.circular(11),
                                  ),
                                  child: Icon(
                                    Icons.description_outlined,
                                    size: 18,
                                    color: AppTheme.primaryDark
                                        .withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _legalPages[i].buttonLabel,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w400,
                                      color: AppTheme.darkText,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: AppTheme.mutedText
                                      .withValues(alpha: 0.6),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],
              _SettingsSectionLabel(AppStrings.settingsSectionAccount),
              const SizedBox(height: 8),
              _SettingsCard(
                dense: true,
                child: InkWell(
                  onTap: _confirmDeleteAccount,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: SizedBox(
                      height: 28,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            size: 20,
                            color: Color(0xFFE57373),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              AppStrings.profileDeleteAccount,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE57373),
                                height: 1.2,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: AppTheme.mutedText.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ),
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

class _SettingsSectionLabel extends StatelessWidget {
  final String text;

  const _SettingsSectionLabel(this.text);

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

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final bool dense;

  const _SettingsCard({required this.child, this.dense = false});

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
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: dense ? 6 : 8,
      ),
      child: child,
    );
  }
}
