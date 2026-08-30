import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../../services/notifications/notification_service.dart';
import 'app_routes.dart';

class DeepLinkService {
  DeepLinkService({
    required this._router,
    required this._notifications,
    required this._appLinks,
  });

  final GoRouter _router;
  final NotificationService _notifications;
  final AppLinks _appLinks;

  StreamSubscription<Uri>? _uriSub;

  /// Called from `main()` after `runApp` so the router is live.
  Future<void> start() async {
    // Priority 1 — the notification that might have launched the app.
    NotificationAppLaunchDetails? launch;
    try {
      launch = await _notifications.plugin.getNotificationAppLaunchDetails();
    } catch (_) {
      launch = null;
    }
    final payload = launch?.notificationResponse?.payload;
    if (launch?.didNotificationLaunchApp == true &&
        payload != null &&
        payload.isNotEmpty) {
      _router.go(AppRoutes.detail(payload));
    } else {
      // Priority 2 — an initial app link (custom scheme) at cold start.
      Uri? initial;
      try {
        initial = await _appLinks.getInitialLink();
      } catch (_) {
        initial = null;
      }
      if (initial != null) {
        _routeUri(initial);
      }
    }

    // Warm path for future link opens. Guarded so re-start (e.g. hot reload)
    // doesn't stack listeners.
    await _uriSub?.cancel();
    _uriSub = _appLinks.uriLinkStream.listen(_routeUri, onError: (_) {});
  }

  /// Warm-path notification tap. Registered as the plugin's
  /// `onDidReceiveNotificationResponse` at initialize — before the first frame,
  /// so a fast tap can't race initialization.
  void onNotificationResponse(NotificationResponse? response) {
    final payload = response?.payload;
    if (payload == null || payload.isEmpty) return;
    _router.go(AppRoutes.detail(payload));
  }

  /// Parses a `fieldops://visit/<id>` (or `fieldops://visit/<id>/photo`) link.
  /// Garbage is a silent no-op — deep links are untrusted input, and the
  /// detail screen's not-found state covers any id that resolves but exists.
  void _routeUri(Uri uri) {
    if (uri.scheme != 'fieldops') return;
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return;
    final id = segments.first;
    if (segments.length == 1) {
      _router.go(AppRoutes.detail(id));
    } else if (segments.length == 2 && segments[1] == 'photo') {
      _router.go(AppRoutes.photo(id));
    }
  }
}
