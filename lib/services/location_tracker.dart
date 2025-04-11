import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_mates/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationTracker {
  static final LocationTracker _instance = LocationTracker._internal();
  factory LocationTracker() => _instance;
  LocationTracker._internal();

  final StreamController<LatLng> _locationStreamController =
      StreamController.broadcast();
  StreamSubscription<LatLng>? _subscription;
  Stream<LatLng> get stream => _locationStreamController.stream;
  LatLng? _lastEmittedLocation;
  LatLng? _lastSavedLocation;

  final List<Map<String, dynamic>> _pendingVisited = [];
  Timer? _uploadTimer;

  Future<void> startBatchTracking({
    double minDistanceMeters = 10,
    Duration uploadInterval = const Duration(seconds: 10),
  }) async {
    final stream = await LocationService.getLocationStream();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    if (userId == null) return;

    _uploadTimer = Timer.periodic(uploadInterval, (_) {
      _uploadBatch(userId);
    });

    if (stream != null) {
      _subscription = stream.listen((pos) {
        _locationStreamController.add(pos);
        _lastEmittedLocation = pos;

        if (_lastSavedLocation == null ||
            const Distance().as(LengthUnit.Meter, _lastSavedLocation!, pos) >=
                minDistanceMeters) {
          final now = DateTime.now().toIso8601String();
          _pendingVisited.add({
            "user_id": userId,
            "latitude": pos.latitude,
            "longitude": pos.longitude,
            "timestamp": now,
          });
          _lastSavedLocation = pos;
        }
      });
    }
  }

  Future<void> _uploadBatch(int userId) async {
    if (_pendingVisited.isEmpty) return;

    try {
      await LocationService.uploadBatchVisitedZones(_pendingVisited);
      await LocationService.uploadBatchLocations(_pendingVisited);
      _pendingVisited.clear();
    } catch (e) {
      debugPrint("Fehler beim Batch-Upload: $e");
    }
  }

  void stop() {
    _subscription?.cancel();
    _uploadTimer?.cancel();
    _locationStreamController.close();
  }

  LatLng? get lastKnownLocation => _lastEmittedLocation;
}
