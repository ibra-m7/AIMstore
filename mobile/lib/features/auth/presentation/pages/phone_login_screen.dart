import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/gcc_phone.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/gcc_phone_field.dart';
import '../../../content_pages/data/services/content_pages_api.dart';
import '../../../content_pages/presentation/content_page_nav.dart';
import '../../../onboarding/data/startup_api.dart';
import '../../data/services/phone_auth_api.dart';
import '../auth_flow.dart';
import '../widgets/auth_widgets.dart';
import 'otp_verify_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  static const routeName = '/phone-login';

  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  String _countryCode = GccPhone.defaultCode;
  bool _isLoading = false;
  List<ContentPage> _authTermPages = const [];

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _countryCode = GccPhone.defaultCode;
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
    _loadAuthTerms();
    _ensureStartupPhoneConfig();
  }

  Future<void> _ensureStartupPhoneConfig() async {
    try {
      await StartupApi.instance.fetch();
    } catch (_) {}
    if (!mounted) return;
    final next = GccPhone.defaultCode;
    if (next != _countryCode &&
        GccPhone.countries.any((country) => country.code == next)) {
      setState(() => _countryCode = next);
    } else if (!GccPhone.countries.any((c) => c.code == _countryCode)) {
      setState(() => _countryCode = GccPhone.defaultCode);
    }
  }

  Future<void> _loadAuthTerms() async {
    final pages = await ContentPagesApi.instance.list(
      placement: ContentPagePlacement.authTerms,
    );
    if (!mounted) return;
    setState(() => _authTermPages = pages);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final phone = GccPhone.combine(_countryCode, _phoneCtrl.text.trim());
      if (phone == null) {
        if (mounted) _showError(AppStrings.fieldPhoneInvalid);
        return;
      }
      final result = await PhoneAuthApi.instance.requestOtp(phone);
      if (!mounted) return;
      if (!result.otpRequired && result.user != null) {
        await AuthFlow.afterLogin(context, result.user!);
        return;
      }
      Navigator.of(context).pushNamed(
        AppRouter.otpVerify,
        arguments: OtpVerifyArgs(
          phone: result.phone,
          fromPhone: result.fromPhone ?? AppStrings.companyWhatsapp,
          resendIn: result.resendIn,
          debugCode: result.debugCode,
        ),
      );
    } on ApiException catch (e) {
      if (mounted) _showError(e.message);
    } on NetworkException catch (e) {
      if (mounted) _showError(e.message);
    } on ServerException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError(AppStrings.errorUnknown);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isValidNationalPhone(String raw) {
    return GccPhone.countryByCode(_countryCode).isValid(raw);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        AuthFlow.leaveAuth(context);
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const AuthGradientBackground(),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 32,
                          ),
                          child: Column(
                            children: [
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: AuthCloseButton(
                                  onPressed: () => AuthFlow.leaveAuth(context),
                                  tooltip: AppStrings.guestBrowse,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Hero(
                                tag: 'app_logo',
                                child: BrandLogoMark(size: 132),
                              ),
                              const SizedBox(height: 18),
                              AuthScreenHeader(
                                title: AppStrings.phoneLoginTitle,
                                subtitle: AppStrings.appTaglineShort,
                              ),
                              const SizedBox(height: 22),
                              AuthGlassCard(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      AuthFieldLabel(text: AppStrings.fieldPhone),
                                      const SizedBox(height: 8),
                                      GccPhoneField(
                                        countryCode: _countryCode,
                                        onCountryChanged: (code) {
                                          setState(() => _countryCode = code);
                                        },
                                        nationalController: _phoneCtrl,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: () {
                                          if (_isLoading) return;
                                          _submit();
                                        },
                                        validator: (v) {
                                          final value = v?.trim() ?? '';
                                          if (value.isEmpty) {
                                            return AppStrings.fieldRequired;
                                          }
                                          if (!_isValidNationalPhone(value)) {
                                            return AppStrings.fieldPhoneInvalid;
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'سنرسل لك رمز تحقق عبر واتساب',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          height: 1.35,
                                          fontWeight: FontWeight.w400,
                                          color: AppTheme.mutedText
                                              .withValues(alpha: 0.95),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      AuthPrimaryButton(
                                        label: AppStrings.phoneLoginButton,
                                        isLoading: false,
                                        onPressed: () {
                                          if (_isLoading) return;
                                          _submit();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const AuthTrustRow(),
                              if (_authTermPages.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    for (var i = 0;
                                        i < _authTermPages.length;
                                        i++) ...[
                                      if (i > 0)
                                        Text(
                                          '·',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.mutedText
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      GestureDetector(
                                        onTap: () => openContentPage(
                                          context,
                                          _authTermPages[i],
                                        ),
                                        child: Text(
                                          _authTermPages[i].buttonLabel,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primaryDark
                                                .withValues(alpha: 0.95),
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: AppTheme
                                                .primaryDark
                                                .withValues(alpha: 0.45),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                              const SizedBox(height: 18),
                              AuthTextLink(
                                label: AppStrings.guestBrowse,
                                onTap: () => AuthFlow.leaveAuth(context),
                                underline: true,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const AuthLoadingOverlay(message: 'جاري التحقق...'),
          ],
        ),
      ),
    );
  }
}
