import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_mates/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:map_mates/background/location_callback_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:map_mates/background/callback_dispatcher.dart';
import 'package:background_locator_2/location_dto.dart';

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
  Timer? _polygonTimer;
  Timer? _bgUploadTimer;
  bool _trackingStarted = false;
  bool _polygonUpdaterStarted = false;

  Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
  }

  Future<void> startAllLocationTracking() async {
    await startBatchTracking();
    await startBackgroundLocator(); // ← das neue
    startBackgroundUploader();
  }

  Future<void> startBatchTracking({
    double minDistanceMeters = 10,
    Duration uploadInterval = const Duration(seconds: 10),
  }) async {
    if (_trackingStarted) return; // Bereits gestartet
    _trackingStarted = true; // Jetzt als aktiv markieren

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

  // Automatische Polygon-Aktualisierung alle X Minuten
  void startAutoPolygonUpdate(
    int userId, {
    Duration interval = const Duration(minutes: 2),
  }) {
    if (_polygonUpdaterStarted) return;
    _polygonUpdaterStarted = true;

    _polygonTimer?.cancel();
    _polygonTimer = Timer.periodic(interval, (_) async {
      try {
        final zones = await LocationService.getVisitedZones(userId);
        await LocationService.extendVisitedPolygon(userId, zones);
        debugPrint("Polygon aktualisiert (automatisch)");
      } catch (e) {
        debugPrint("Fehler beim automatischen Polygon-Update: $e");
      }
    });
  }

  Future<void> updatePolygonOnce(int userId) async {
    try {
      final zones = await LocationService.getVisitedZones(userId);
      await LocationService.extendVisitedPolygon(userId, zones);
      debugPrint("Polygon einmalig aktualisiert beim App-Start");
    } catch (e) {
      debugPrint("Fehler beim einmaligen Polygon-Update: $e");
    }
  }

  Future<void> startBackgroundLocatorAlt() async {
    await BackgroundLocator.initialize(); // ← kein Parameter hier!
    await BackgroundLocator.registerLocationUpdate(
      LocationCallbackHandler.callback,
      initCallback: LocationCallbackHandler.initCallback,
      disposeCallback: LocationCallbackHandler.disposeCallback,
      iosSettings: IOSSettings(
        accuracy: LocationAccuracy.NAVIGATION,
        distanceFilter: 10,
        stopWithTerminate: false,
        showsBackgroundLocationIndicator: true,
      ),
      autoStop: false,
      androidSettings: AndroidSettings(
        accuracy: LocationAccuracy.NAVIGATION,
        interval: 10,
        distanceFilter: 10,
        client: LocationClient.google,
        androidNotificationSettings: AndroidNotificationSettings(
          notificationChannelName: 'Location tracking',
          notificationTitle: 'MapMates läuft im Hintergrund',
          notificationMsg: 'Standort wird aktualisiert',
          notificationBigMsg: 'MapMates zeichnet deinen Standort auf...',
          notificationIcon: '',
        ),
      ),
    );
  }

  Future<void> startBackgroundLocator() async {
    await BackgroundLocator.initialize();
    callbackDispatcher();
  }

  Future<void> stopBackgroundLocator() async {
    await BackgroundLocator.unRegisterLocationUpdate();
  }

  void startBackgroundUploader({
    Duration interval = const Duration(minutes: 1),
  }) {
    _bgUploadTimer?.cancel(); // falls mehrfach gestartet
    _bgUploadTimer = Timer.periodic(interval, (_) async {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id");
      if (userId == null) return;

      final List<String> stored = prefs.getStringList("bg_locations") ?? [];

      if (stored.isEmpty) return;

      final List<Map<String, dynamic>> batch =
          stored.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();

      try {
        await LocationService.uploadBatchVisitedZones(batch);
        await LocationService.uploadBatchLocations(batch);

        await prefs.remove("bg_locations");
        debugPrint("🔁 Hintergrund-Standorte hochgeladen.");
      } catch (e) {
        debugPrint("❌ Fehler beim Senden der BG-Daten: $e");
      }
    });
  }

  void stop() async {
    _subscription?.cancel();
    _uploadTimer?.cancel();
    _polygonTimer?.cancel(); // Stoppe auch den Polygon-Timer
    _bgUploadTimer?.cancel();
    await BackgroundLocator.unRegisterLocationUpdate();
    _locationStreamController.close();
  }

  LatLng? get lastKnownLocation => _lastEmittedLocation;
}
