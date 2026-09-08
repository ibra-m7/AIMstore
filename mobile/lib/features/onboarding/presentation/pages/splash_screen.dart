import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../auth/data/services/auth_session.dart';
import '../../../auth/data/services/phone_auth_api.dart';
import '../../data/startup_api.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  SplashConfig? _remote;

  static const _maxSplashMs = 450;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _startSequence();
  }

  Future<void> _startSequence() async {
    final routeFuture = _resolveRoute();
    unawaited(_intro.forward());
    unawaited(_tryLoadRemoteImage());

    await Future.wait<void>([
      routeFuture.then((_) {}),
      Future<void>.delayed(const Duration(milliseconds: _maxSplashMs)),
    ]);
    if (!mounted) return;

    final route = await routeFuture;
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(route);
  }

  Future<void> _tryLoadRemoteImage() async {
    try {
      final startup = await StartupApi.instance
          .fetch()
          .timeout(const Duration(milliseconds: 700));
      final splash = startup.splash;
      if (!mounted || splash == null || !splash.hasMedia) return;
      if (!splash.isVideo) {
        setState(() => _remote = splash);
      }
    } catch (_) {}
  }

  Future<String> _resolveRoute() async {
    final session = AuthSession.instance;
    var route = AppRouter.onboarding;

    if (session.isLoggedIn) {
      try {
        await PhoneAuthApi.instance.me().timeout(const Duration(seconds: 2));
        route = AppRouter.main;
      } on ApiException catch (e) {
        if (e.statusCode == 401) {
          await session.clear();
          route = session.onboardingSeen ? AppRouter.main : AppRouter.onboarding;
        } else {
          route = AppRouter.main;
        }
      } catch (_) {
        route = AppRouter.main;
      }
    } else if (session.onboardingSeen) {
      route = AppRouter.main;
    }

    return route;
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remote = _remote;
    final hasRemote = remote != null && remote.hasMedia && !remote.isVideo;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Center(
          child: hasRemote
              ? AppNetworkImage(
                  remote.mediaUrl,
                  fit: BoxFit.contain,
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  error: BrandLogoIntro(animation: _intro),
                )
              : BrandLogoIntro(animation: _intro),
        ),
      ),
    );
  }
}
