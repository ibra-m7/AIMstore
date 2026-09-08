import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_strings.dart';
import 'core/di/service_locator.dart';
import 'core/network/app_http_overrides.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/services/auth_session.dart';
import 'features/auth/presentation/manager/address_cubit.dart';
import 'features/notifications/data/services/push_service.dart';
import 'features/notifications/presentation/manager/notifications_cubit.dart';
import 'features/shop/presentation/manager/cart_cubit.dart';
import 'features/shop/presentation/manager/catalog_cubit.dart';
import 'features/shop/presentation/manager/favorite_cubit.dart';
import 'features/shop/presentation/manager/orders_cubit.dart';
import 'features/shop/presentation/manager/search_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installAppHttpOverrides();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  await Future.wait([
    dotenv.load(fileName: '.env'),
    AuthSession.instance.load(),
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
  ]);

  ApiClient.instance.resetConnection();

  // Sync DI only — needed before CartCubit create. Firebase/voice/push wait.
  ServiceLocator.init();

  runApp(const RaoahAlkhamsa());
}

Future<void> _warmServices(NotificationsCubit notificationsCubit) async {
  try {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await ensureFirebaseApp();
    await PushService.instance.initialize(cubit: notificationsCubit);
  } catch (_) {
    // Push/Firebase must not block the app if unavailable.
  }
  unawaited(ServiceLocator.instance.voiceService.initialize());
}

class RaoahAlkhamsa extends StatefulWidget {
  const RaoahAlkhamsa({super.key});

  @override
  State<RaoahAlkhamsa> createState() => _RaoahAlkhamsaState();
}

class _RaoahAlkhamsaState extends State<RaoahAlkhamsa> {
  late final NotificationsCubit _notificationsCubit = NotificationsCubit();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_warmServices(_notificationsCubit));
    });
  }

  @override
  void dispose() {
    _notificationsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartCubit>(
          create: (_) {
            final cubit = ServiceLocator.instance.createCartCubit();
            cubit.restorePersisted();
            return cubit;
          },
        ),
        BlocProvider<CatalogCubit>(
          create: (_) => CatalogCubit()..load(),
        ),
        BlocProvider<FavoriteCubit>(
          create: (_) {
            final cubit = FavoriteCubit();
            cubit.restorePersisted();
            return cubit;
          },
        ),
        // Deferred network loads — started from MainScreen first frame.
        BlocProvider<OrdersCubit>(
          create: (_) => OrdersCubit(),
        ),
        BlocProvider<AddressCubit>(
          create: (_) => AddressCubit(),
        ),
        BlocProvider<NotificationsCubit>.value(
          value: _notificationsCubit,
        ),
        BlocProvider<SearchCubit>(
          create: (_) => SearchCubit()..hydrate(),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        navigatorKey: AppRouter.navigatorKey,
        locale: const Locale('ar', 'SA'),
        supportedLocales: const [
          Locale('ar', 'SA'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.buildTheme(),
        initialRoute: AppRouter.initial,
        onGenerateRoute: AppRouter.onGenerateRoute,
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaler.scale(1.0).clamp(0.90, 1.08),
              ),
            ),
            child: child!,
          ),
        ),
      ),
    );
  }
}
