import 'package:geolocator/geolocator.dart';

/// A single current position, nullable — GPS is optional and never blocks flow.
class CurrentPosition {
  const CurrentPosition({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

/// One-shot "get current position" used at visit creation / location update.
///
/// Per master plan §4 this is the *allowed* thin-plugin case for a one-off
/// read; the continuous background trail (Phases 9–10) is real native code.
/// Degrades to null on denied permission or failure — creation never blocks.
class CurrentLocation {
  Future<CurrentPosition?> fetch() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final position = await Geolocator.getCurrentPosition();
      return CurrentPosition(lat: position.latitude, lng: position.longitude);
    } catch (_) {
      return null;
    }
  }
}
