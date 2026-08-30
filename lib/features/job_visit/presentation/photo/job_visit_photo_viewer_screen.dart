import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/locked_photo_placeholder.dart';
import '../../../../services/biometrics/biometrics_service.dart';
import '../providers/job_visit_providers.dart';

/// Full-screen photo viewer (`/visit/:id/photo`).
///
/// The biometric gate lives HERE, not in the caller (ui-plan §3.4): this route
/// is registered and deep-linkable, so every entry path — tap, deep link, cold
/// start from a link — hits the gate. Gated content exists nowhere else:
/// nothing outside this screen ever decodes the image file.
class JobVisitPhotoViewerScreen extends ConsumerStatefulWidget {
  const JobVisitPhotoViewerScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<JobVisitPhotoViewerScreen> createState() =>
      _JobVisitPhotoViewerScreenState();
}

/// Terminal gate result. `checking` before the first attempt resolves.
enum _GateOutcome {
  checking,
  success,
  failed,
  notSetUp,
  lockedOut,
  permanentlyLockedOut,
}

class _JobVisitPhotoViewerScreenState
    extends ConsumerState<JobVisitPhotoViewerScreen> {
  bool _started = false;
  String? _photoPath;
  _GateOutcome _outcome = _GateOutcome.checking;
  bool _photoExists = false;

  @override
  Widget build(BuildContext context) {
    final visitAsync = ref.watch(jobVisitByIdProvider(widget.id));
    return visitAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Photo')),
        body: EmptyState(
          icon: Icons.error_outline,
          message: 'Something went wrong: $e',
        ),
      ),
      data: (visit) {
        if (visit == null) return _notFound();
        if (visit.photoPath == null) return _noPhoto();
        if (!_started) {
          _started = true;
          _photoPath = visit.photoPath;
          WidgetsBinding.instance.addPostFrameCallback((_) => _attemptUnlock());
        }
        return _gateBody();
      },
    );
  }

  Future<void> _attemptUnlock() async {
    if (!mounted) return;
    setState(() => _outcome = _GateOutcome.checking);
    final result = await ref.read(biometricsServiceProvider).authenticate();
    if (!mounted) return;
    setState(() {
      _outcome = switch (result) {
        BiometricAuthResult.success => _GateOutcome.success,
        BiometricAuthResult.notSetUp ||
        BiometricAuthResult.unsupported => _GateOutcome.notSetUp,
        BiometricAuthResult.lockedOut => _GateOutcome.lockedOut,
        BiometricAuthResult.permanentlyLockedOut =>
          _GateOutcome.permanentlyLockedOut,
        _ => _GateOutcome.failed,
      };

      final path = _photoPath;
      _photoExists =
          _outcome == _GateOutcome.success &&
          path != null &&
          File(path).existsSync();
    });
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.list);
    }
  }

  Widget _gateBody() {
    final appBar = AppBar(title: const Text('Photo'));
    switch (_outcome) {
      case _GateOutcome.checking:
        return Scaffold(
          appBar: appBar,
          body: const Center(child: CircularProgressIndicator()),
        );
      case _GateOutcome.success:
        if (!_photoExists) {
          return Scaffold(
            appBar: appBar,
            body: EmptyState(
              icon: Icons.broken_image_outlined,
              message: 'Photo file not available on this device.',
              actionLabel: 'Back',
              onAction: _back,
            ),
          );
        }
        return Scaffold(
          appBar: appBar,
          body: Center(
            child: Image.file(
              File(_photoPath!),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const EmptyState(
                icon: Icons.broken_image_outlined,
                message: 'Photo file not available on this device.',
              ),
            ),
          ),
        );
      case _GateOutcome.notSetUp:
        return Scaffold(
          appBar: appBar,
          body: EmptyState(
            icon: Icons.lock_outline,
            message:
                'Set up a screen lock or biometrics in your device settings '
                'to view photos.',
          ),
        );
      case _GateOutcome.failed:
      case _GateOutcome.lockedOut:
      case _GateOutcome.permanentlyLockedOut:
        return _lockedView(appBar, _messageFor(_outcome));
    }
  }

  Widget _lockedView(AppBar appBar, String message) {
    return Scaffold(
      appBar: appBar,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LockedPhotoPlaceholder(dimensions: 120),
              const SizedBox(height: 20),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _attemptUnlock,
                icon: const Icon(Icons.lock_open),
                label: const Text('Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _messageFor(_GateOutcome outcome) => switch (outcome) {
    _GateOutcome.failed => 'Verify your identity to unlock this photo.',
    _GateOutcome.lockedOut =>
      'Too many failed attempts. Try again in a moment.',
    _GateOutcome.permanentlyLockedOut =>
      'Biometrics are locked. Enable them again in your device settings.',
    _ => 'Verify your identity to unlock this photo.',
  };

  Widget _notFound() {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo')),
      body: EmptyState(
        icon: Icons.search_off,
        message: 'Visit not found.',
        actionLabel: 'Back to list',
        onAction: () => context.go(AppRoutes.list),
      ),
    );
  }

  Widget _noPhoto() {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo')),
      body: EmptyState(
        icon: Icons.photo_outlined,
        message: 'This visit has no photo attached.',
        actionLabel: 'Back',
        onAction: _back,
      ),
    );
  }
}
