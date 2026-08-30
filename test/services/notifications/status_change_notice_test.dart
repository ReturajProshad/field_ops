import 'package:flutter_test/flutter_test.dart';

import 'package:field_ops/features/job_visit/data/models/job_visit_merger.dart';
import 'package:field_ops/features/job_visit/domain/entities/job_visit.dart';
import 'package:field_ops/services/notifications/notification_service.dart';

void main() {
  JobVisit visit({
    JobVisitStatus status = JobVisitStatus.enRoute,
    String id = 'visit-1',
  }) {
    return JobVisit(
      id: id,
      createdAt: 1000,
      status: status,
      statusUpdatedAt: 1000,
      syncState: JobVisitSyncState.synced,
      deviceId: 'device-a',
    );
  }

  test('remote status change on a known visit → notification', () {
    final previous = visit();
    final merged = visit(status: JobVisitStatus.completed);

    final notice = statusChangeNotice(
      merged: merged,
      previousLocal: previous,
      remoteChangedFields: {MergeField.status},
    );

    expect(notice, isNotNull);
    expect(notice!.visitId, 'visit-1');
    expect(notice.body, 'En Route → Completed. Tap to open.');
  });

  test('gate 1: remote-created visit (no previousLocal) never notifies', () {
    final notice = statusChangeNotice(
      merged: visit(status: JobVisitStatus.completed),
      previousLocal: null,
      remoteChangedFields: {MergeField.status},
    );
    expect(notice, isNull);
  });

  test('gate 2: remote changed only a non-status field → no notification', () {
    final notice = statusChangeNotice(
      merged: visit(status: JobVisitStatus.completed),
      previousLocal: visit(),
      remoteChangedFields: {MergeField.photo},
    );
    expect(notice, isNull);
  });

  test(
      'gate 3: local won the conflict (merged == previous status) → no '
      'notification, even though remote changed status', () {
    // Local edit wins: merged status equals what we already had locally.
    final previous = visit(status: JobVisitStatus.onSite);
    final merged = visit(status: JobVisitStatus.onSite);

    final notice = statusChangeNotice(
      merged: merged,
      previousLocal: previous,
      remoteChangedFields: {MergeField.status},
    );
    expect(notice, isNull,
        reason: "the user's own status didn't change from their point of view");
  });

  test('local changed status but remote did not → no notification', () {
    final notice = statusChangeNotice(
      merged: visit(status: JobVisitStatus.onSite),
      previousLocal: visit(),
      remoteChangedFields: const {},
    );
    expect(notice, isNull);
  });
}