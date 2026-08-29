import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/database_provider.dart';
import '../../../../services/location/current_location.dart';
import '../../../../services/media/photo_store.dart';
import '../../data/repositories/job_visit_repository_impl.dart';
import '../../domain/entities/job_visit.dart';
import '../../domain/repositories/job_visit_repository.dart';
import '../../domain/usecases/create_job_visit.dart';
import '../../domain/usecases/edit_job_visit.dart';

/// Which device this install is. Stored per edit so the merge engine's
/// tie-break (lexically smaller deviceId wins) has a deterministic local value.
final localDeviceIdProvider = Provider<String>((ref) => 'device-a');

final jobVisitRepositoryProvider = Provider<JobVisitRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return JobVisitRepositoryImpl(db);
});

final createJobVisitProvider = Provider<CreateJobVisit>((ref) {
  return CreateJobVisit(
    ref.watch(jobVisitRepositoryProvider),
    ref.watch(localDeviceIdProvider),
  );
});

final editJobVisitProvider = Provider<EditJobVisit>((ref) {
  return EditJobVisit(
    ref.watch(jobVisitRepositoryProvider),
    ref.watch(localDeviceIdProvider),
  );
});

final currentLocationProvider = Provider<CurrentLocation>((ref) {
  return CurrentLocation();
});

final photoStoreProvider = Provider<PhotoStore>((ref) => PhotoStore());

/// All visits, newest first, as streamed by the repository.
final jobVisitsStreamProvider = StreamProvider<List<JobVisit>>((ref) {
  return ref.watch(jobVisitRepositoryProvider).watchAll();
});

final jobVisitByIdProvider = StreamProvider.family<JobVisit?, String>((
  ref,
  id,
) {
  return ref.watch(jobVisitRepositoryProvider).watchById(id);
});

/// Sort modes per ui-plan §3.1. Status order is enum order
/// (enRoute → onSite → completed → blocked); sync-state order is explicit
/// (pending → conflict_resolved → synced). Tiebreak: newest createdAt first.
enum VisitSortMode { byStatus, bySyncState }

int _sortRank(JobVisitSyncState state) => switch (state) {
  JobVisitSyncState.pending => 0,
  JobVisitSyncState.conflictResolved => 1,
  JobVisitSyncState.synced => 2,
};

final visitSortModeProvider = StateProvider<VisitSortMode>((ref) {
  return VisitSortMode.byStatus;
});

/// Sorted view of all visits. Carries the underlying [jobVisitsStreamProvider]
/// state through (loading/error/data) so the list screen watches one provider
/// and can render every branch, including sync failures.
final sortedJobVisitsProvider = Provider<AsyncValue<List<JobVisit>>>((ref) {
  final async = ref.watch(jobVisitsStreamProvider);
  final mode = ref.watch(visitSortModeProvider);
  return async.whenData((visits) => _sortVisits(visits, mode));
});

List<JobVisit> _sortVisits(List<JobVisit> visits, VisitSortMode mode) {
  final sorted = [...visits]
    ..sort((a, b) {
      final byGroup = switch (mode) {
        VisitSortMode.byStatus => a.status.index.compareTo(b.status.index),
        VisitSortMode.bySyncState => _sortRank(
          a.syncState,
        ).compareTo(_sortRank(b.syncState)),
      };
      if (byGroup != 0) return byGroup;
      return b.createdAt.compareTo(a.createdAt);
    });
  return sorted;
}
