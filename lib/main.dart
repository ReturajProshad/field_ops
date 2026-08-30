import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/router/deep_link_service.dart';
import 'core/theme/app_theme.dart';
import 'services/notifications/notification_service.dart';
import 'services/secure_storage/secure_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bootstrap the fake auth token into Keystore/Keychain on first run. The
  // mock backend reads it back out and attaches it to every fake request.
  try {
    await SecureStorageService().ensureToken();
  } catch (_) {}

  final notifications = NotificationService();
  final deepLinks = DeepLinkService(
    router: appRouter,
    notifications: notifications,
    appLinks: AppLinks(),
  );
  try {
    await notifications.initialize(
      onDidReceiveNotificationResponse: deepLinks.onNotificationResponse,
    );
  } catch (_) {}

  runApp(const ProviderScope(child: FieldOpsApp()));
  unawaited(notifications.requestPermissions());

  await deepLinks.start();
}

class FieldOpsApp extends StatelessWidget {
  const FieldOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FieldOps',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
