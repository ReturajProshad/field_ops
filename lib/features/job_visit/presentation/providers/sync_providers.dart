import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../services/notifications/notification_service.dart';
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

/// Local notification service (init + show only; the *when* is decided by the
/// sync engine's `onVisitSynced` gates in [syncEngineProvider]).
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final mockSyncServiceProvider = FutureProvider<MockSyncService>((ref) async {
  final dir = await getApplicationSupportDirectory();
  final file = File('${dir.path}/mock_backend.json');
  final storage = ref.read(secureStorageServiceProvider);
  return MockSyncService(file: file, tokenProvider: () => storage.readToken());
});

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
      ref.read(syncLogProvider.notifier).state = next.length > 400
          ? next.sublist(next.length - 400)
          : next;
    },

    onVisitSynced:
        ({
          required merged,
          required previousLocal,
          required remoteChangedFields,
        }) {
          final notice = statusChangeNotice(
            merged: merged,
            previousLocal: previousLocal,
            remoteChangedFields: remoteChangedFields,
          );
          if (notice != null) {
            ref
                .read(notificationServiceProvider)
                .showStatusChanged(
                  visitId: notice.visitId,
                  title: notice.title,
                  body: notice.body,
                );
          }
        },
  );
});

final isOnlineProvider = StateProvider<bool>((ref) => true);

/// Debug-menu state: fail the Nth record of the next sync run.
final failAfterRecordsProvider = StateProvider<int?>((ref) => null);

/// Debug-menu state: the developer log. Newest entries last.
final syncLogProvider = StateProvider<List<SyncLogLine>>((ref) => []);

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
