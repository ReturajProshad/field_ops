import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/job_visit/data/models/job_visit_merger.dart';
import '../../features/job_visit/domain/entities/job_visit.dart';

class StatusChangeNotice {
  const StatusChangeNotice({
    required this.visitId,
    required this.title,
    required this.body,
  });

  final String visitId;
  final String title;
  final String body;
}

/// The three notification gates, as a pure function so they're unit-testable.
/// Returns null when no notification is warranted; the provider wiring shows
/// the returned [StatusChangeNotice].
///
/// 1. `previousLocal != null` — a remote-created visit isn't "your visit
///    changed", so it never notifies.
/// 2. `remoteChangedFields` contains `status` — only a *backend* status change
///    triggers a push-style notification (that's the brief's exact wording).
/// 3. merged status differs from the pre-sync local status — suppresses the
///    false positive when the *local* edit wins a conflict, since nothing
///    actually changed from the user's point of view.
StatusChangeNotice? statusChangeNotice({
  required JobVisit merged,
  required JobVisit? previousLocal,
  required Set<MergeField> remoteChangedFields,
}) {
  if (previousLocal == null) return null;
  if (!remoteChangedFields.contains(MergeField.status)) return null;
  if (merged.status == previousLocal.status) return null;
  return StatusChangeNotice(
    visitId: merged.id,
    title: 'Job Visit status changed',
    body:
        '${StatusChipLabel.forStatus(previousLocal.status)} → '
        '${StatusChipLabel.forStatus(merged.status)}. Tap to open.',
  );
}

/// Status labels kept dependency-free so [statusChangeNotice] (and its tests)
/// don't need widget code. Duplicates `StatusChip.labelFor` by design — the
/// services layer must not import the presentation layer.
abstract final class StatusChipLabel {
  static String forStatus(JobVisitStatus status) => switch (status) {
    JobVisitStatus.enRoute => 'En Route',
    JobVisitStatus.onSite => 'On Site',
    JobVisitStatus.completed => 'Completed',
    JobVisitStatus.blocked => 'Blocked',
  };
}

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _channelId = 'fieldops_status';
  static const _channelName = 'Job Visit status';

  static const _notificationId = 1000;

  final FlutterLocalNotificationsPlugin _plugin;

  FlutterLocalNotificationsPlugin get plugin => _plugin;

  Future<void> initialize({
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    // iOS: request*Permission false keeps the OS prompt OUT of startup init —
    // it happens later via [requestPermissions], after the first frame. A
    // permission dialog blocking the launch screen (pre-runApp) is a black
    // first-frame on camera (Phase 8 review).
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description:
              'Notifications when a job visit status changes on the backend.',
          importance: Importance.max,
        ),
      );
    }
  }

  /// Requests notification permission — called AFTER `runApp` (post-first-frame),
  /// so a first-launch OS prompt never blocks the app from rendering (Android
  /// 13+ `POST_NOTIFICATIONS` is ignored silently without this grant).
  Future<void> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      await ios.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> showStatusChanged({
    required String visitId,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription:
            'Notifications when a job visit status changes on the backend.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      id: _notificationId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: visitId,
    );
  }
}
