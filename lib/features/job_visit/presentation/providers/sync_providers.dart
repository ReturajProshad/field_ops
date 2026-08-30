import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../services/secure_storage/secure_storage_service.dart';
import '../../data/models/job_visit_merger.dart';
import '../../data/remote/mock_sync_service.dart';
import '../../data/remote/sync_engine.dart';
import 'job_visit_providers.dart';

/// One entry in the developer log: what happened and when, as emitted by the
/// sync engine's per-step instrumentation.
class SyncLogLine {
  const SyncLogLine({required this.message, required this.at});

  final String message;
  final DateTime at;

  @override
  String toString() {
    final t = at;
    String two(int n) => n.toString().padLeft(2, '0');
    final stamp =
        '${two(t.hour)}:${two(t.minute)}:${two(t.second)}.${t.millisecond.toString().padLeft(3, '0')}';
    return '$stamp  $message';
  }
}

/// Secure-storage wrapper for the mock auth token.
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// JSON-file-backed mock backend. The file lives in the app-support dir so it
/// survives both app restarts and device reboots. The token provider reads real
/// secure storage (Keystore/Keychain) — but it is *injected* so engine tests
/// can supply a fake instead of hitting a platform channel.
final mockSyncServiceProvider = FutureProvider<MockSyncService>((ref) async {
  final dir = await getApplicationSupportDirectory();
  final file = File('${dir.path}/mock_backend.json');
  final storage = ref.read(secureStorageServiceProvider);
  return MockSyncService(
    file: file,
    tokenProvider: () => storage.readToken(),
  );
});

/// The sync engine wired to the real local DB and the mock backend. Its
/// per-step [SyncEngine] `onEvent` instrumentation feeds the developer log so
/// the demo can narrate, step by step, exactly what each sync just did.
final syncEngineProvider = FutureProvider<SyncEngine>((ref) async {
  final backend = await ref.watch(mockSyncServiceProvider.future);
  return SyncEngine(
    repository: ref.watch(jobVisitRepositoryProvider),
    backend: backend,
    merger: const JobVisitMerger(),
    onEvent: (line) {
      final next = [
        ...ref.read(syncLogProvider),
        SyncLogLine(message: line, at: DateTime.now()),
      ];
      // Cap the in-memory log so a long demo doesn't grow without bound.
      ref.read(syncLogProvider.notifier).state =
          next.length > 400 ? next.sublist(next.length - 400) : next;
    },
  );
});

/// Debug-menu state: simulated connectivity. Flipping to online triggers a
/// sync run — the toggle *is* the "connectivity restored" event.
final isOnlineProvider = StateProvider<bool>((ref) => true);

/// Debug-menu state: fail the Nth record of the next sync run.
final failAfterRecordsProvider = StateProvider<int?>((ref) => null);

/// Debug-menu state: the developer log. Newest entries last.
final syncLogProvider = StateProvider<List<SyncLogLine>>((ref) => []);

/// Best-effort background sync after a local create/edit when online, so a
/// freshly saved visit doesn't sit at Pending forever in an "online" app. The
/// single-flight guard + participated-skip make it cheap; failures are
/// swallowed here (the debug toggle's explicit sync is where outcomes surface).
final autoSyncProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    try {
      if (!ref.read(isOnlineProvider)) return;
      final engine = await ref.read(syncEngineProvider.future);
      await engine.sync();
    } catch (_) {
      // Best-effort only.
    }
  };
});