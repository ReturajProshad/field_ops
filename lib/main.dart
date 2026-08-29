import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const FieldOpsApp());
}

class FieldOpsApp extends StatelessWidget {
  const FieldOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FieldOps',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const PlaceholderScreen(),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FieldOps')),
      body: const Center(child: Text('Phase 0 bootstrap')),
    );
  }
}