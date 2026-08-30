import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/secure_storage/secure_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bootstrap the fake auth token into Keystore/Keychain on first run. The
  // mock backend reads it back out and attaches it to every fake request.
  try {
    await SecureStorageService().ensureToken();
  } catch (_) {
    // Non-fatal: an unwritable secure store (e.g. a locked-down emulator)
    // must not block the app from launching.
  }
  runApp(const ProviderScope(child: FieldOpsApp()));
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
