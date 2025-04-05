import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:map_mates/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationTracker {
  // Variablen
  static final LocationTracker _instance = LocationTracker._internal();
  factory LocationTracker() => _instance;
  LocationTracker._internal();

  final StreamController<LatLng> _locationStreamController =
      StreamController.broadcast();
  StreamSubscription<LatLng>? _subscription;
  Stream<LatLng> get stream => _locationStreamController.stream;
  LatLng? _lastEmittedLocation;
  LatLng? _lastSavedLocation;

  // Start Location Tracking
  Future<void> start({double minDistanceMeters = 10}) async {
    final stream = await LocationService.getLocationStream();
    final prefs = await SharedPreferences.getInstance();

    if (stream != null) {
      _subscription = stream.listen((pos) async {
        final userId = await prefs.getInt("user_id");

        // Stream an UI immer weiterleiten für flüssige Map-Bewegung
        _locationStreamController.add(pos);
        _lastEmittedLocation = pos;

        if (userId == null) return;

        // Nur speichern, wenn 10m weiter entfernt als letzte gespeicherte
        if (_lastSavedLocation == null ||
            const Distance().as(LengthUnit.Meter, _lastSavedLocation!, pos) >=
                minDistanceMeters) {
          await LocationService.addLocation(userId, pos);
          await LocationService.markVisitedZone(userId, pos);
          _lastSavedLocation = pos;
        }
      });
    }
  }

  // Stoppt das Tracking und beendet den Broadcat
  void stop() {
    _subscription?.cancel();
    _locationStreamController.close();
  }

  LatLng? get lastKnownLocation => _lastEmittedLocation;
}
