import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ha_ecommerce/core/router/app_router.dart';
import 'package:ha_ecommerce/core/theme/app_theme.dart' show HATheme;
import 'package:ha_ecommerce/features/auth/presentation/providers/auth_provider.dart';
import 'package:ha_ecommerce/features/notifications/presentation/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Crashlytics — catch Flutter errors in release
  if (!kDebugMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await NotificationService.init();

  runApp(
    const ProviderScope(
      child: HAECommerceApp(),
    ),
  );
}

class HAECommerceApp extends ConsumerWidget {
  const HAECommerceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'HA E-Commerce',
      debugShowCheckedModeBanner: false,
      theme: HATheme.light,
      darkTheme: HATheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
