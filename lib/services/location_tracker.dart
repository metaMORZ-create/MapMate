import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:map_mates/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationTracker {
  // Variablen
  static final LocationTracker _instance = LocationTracker._internal();
  factory LocationTracker() => _instance;
  LocationTracker._internal();

  final StreamController<LatLng> _locationStreamController = StreamController.broadcast();
  StreamSubscription<LatLng>? _subscription;
  Stream<LatLng> get stream => _locationStreamController.stream;
  LatLng? _lastEmittedLocation;

  // Startet Tracking und öffnet Broadcast, dem die anderen Seiten zuhören können
  Future<void> start({double minDistanceMeters = 10}) async {
    final stream = await LocationService.getLocationStream();
    final prefs = await SharedPreferences.getInstance();
    

    if (stream != null) {
      _subscription = stream.listen((pos) async {
        // Falls noch keine Location, einmal aussenden
        final user_id = await prefs.getInt("user_id");
        if (_lastEmittedLocation == null) {
          _locationStreamController.add(pos);
          _lastEmittedLocation = pos;
          if (user_id != null) {
            await LocationService.addLocation(user_id, pos);
          }
          return;
        }
        // Entfernung berechnen
        final distance = const Distance().as(
          LengthUnit.Meter,
          _lastEmittedLocation!,
          pos,
        );

        if (distance >= minDistanceMeters) {
          _locationStreamController.add(pos);
          _lastEmittedLocation = pos;
          if (user_id != null) {     
            await LocationService.addLocation(user_id, pos);
          }
        }
        _locationStreamController.add(pos);
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
