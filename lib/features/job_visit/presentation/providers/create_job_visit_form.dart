import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/job_visit.dart';
import 'job_visit_providers.dart';

@immutable
class CreateVisitDraft {
  const CreateVisitDraft({
    this.status = JobVisitStatus.enRoute,
    this.gps,
    this.capturing = false,
    this.saving = false,
  });

  final JobVisitStatus status;
  final ({double lat, double lng})? gps;
  final bool capturing;
  final bool saving;

  CreateVisitDraft copyWith({
    JobVisitStatus? status,
    ({double lat, double lng})? gps,
    bool clearGps = false,
    bool? capturing,
    bool? saving,
  }) {
    return CreateVisitDraft(
      status: status ?? this.status,
      gps: clearGps ? null : gps ?? this.gps,
      capturing: capturing ?? this.capturing,
      saving: saving ?? this.saving,
    );
  }
}

class CreateJobVisitForm extends AutoDisposeNotifier<CreateVisitDraft> {
  bool _alive = true;

  @override
  CreateVisitDraft build() {
    ref.onDispose(() => _alive = false);
    return const CreateVisitDraft();
  }

  void setStatus(JobVisitStatus status) {
    state = state.copyWith(status: status);
  }

  Future<void> captureGps() async {
    if (state.capturing) return;
    state = state.copyWith(capturing: true);
    final position = await ref.read(currentLocationProvider).fetch();
    if (!_alive) return; // user backed out while the permission dialog was up
    // Deliberate: a failed fetch keeps the last good coordinate (there is no
    // older good value on first entry, but a retry must not blank one out).
    state = state.copyWith(
      capturing: false,
      gps: position != null ? (lat: position.lat, lng: position.lng) : null,
    );
  }

  Future<String?> save() async {
    if (state.saving) return null;
    state = state.copyWith(saving: true);
    try {
      final visit = await ref
          .read(createJobVisitProvider)
          .call(
            status: state.status,
            gpsLat: state.gps?.lat,
            gpsLng: state.gps?.lng,
          );
      if (!_alive) return null;
      return visit.id;
    } finally {
      if (_alive) state = state.copyWith(saving: false);
    }
  }
}

final createJobVisitFormProvider =
    NotifierProvider.autoDispose<CreateJobVisitForm, CreateVisitDraft>(
      CreateJobVisitForm.new,
    );
