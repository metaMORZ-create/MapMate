import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_mates/services/location_service.dart';
import 'package:map_mates/services/location_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  // VARIABLEN
  LatLng? _currentLocation;
  bool _mapReady = false;
  late final StreamSubscription<LatLng> _trackerSub;
  LatLng? _lastRecordedLocation;
  List<List<LatLng>> _visitedPolygon = [];
  List<LatLng> _pendingVisited = [];
  Timer? _batchTimer;
  DateTime _lastPolygonLoad = DateTime.fromMillisecondsSinceEpoch(0);
  bool _isLoadingPolygon = false;

  final List<LatLng> outerPolygon = [
    LatLng(85, 90),
    LatLng(85, 0.1),
    LatLng(85, -90),
    LatLng(85, -179.9),
    LatLng(0, -179.9),
    LatLng(-85, -179.9),
    LatLng(-85, -90),
    LatLng(-85, 0.1),
    LatLng(-85, 90),
    LatLng(-85, 179.9),
    LatLng(0, 179.9),
    LatLng(85, 179.9),
  ];

  // FUNKTIONEN

  // Load Visited Polygon
 Future<void> _loadVisitedPolygons() async {
  // Nicht öfter als alle 30 Sekunden neu laden
  final now = DateTime.now();
  if (_isLoadingPolygon || now.difference(_lastPolygonLoad) < const Duration(seconds: 20)) return;

  _isLoadingPolygon = true;
  _lastPolygonLoad = now;

  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    if (userId != null) {
      final polygon = await LocationService.getVisitedPolygons(userId);
      if (!mounted) return;
      setState(() {
        _visitedPolygon = polygon;
      });
    }
  } catch (e) {
    debugPrint("Fehler beim Laden der Polygone: $e");
  } finally {
    _isLoadingPolygon = false;
  }
}


  // Startet das Location-Tracking & aktualisiert die Karte
  void _startTracking() {
    // Hole letzten bekannten Standort (z. B. falls Map später gebaut wird)
    final lastPos = LocationTracker().lastKnownLocation;
    if (lastPos != null) {
      if (!mounted) return;
      setState(() {
        _currentLocation = lastPos;
      });
      _mapController.move(lastPos, _mapController.camera.zoom);
    }
    // Timer für alle 10 sekunden upload
    _batchTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _uploadVisitedZones();
      _loadVisitedPolygons();
    });
    // Höre auf neue Positionen vom globalen Stream
    _trackerSub = LocationTracker().stream.listen((pos) async {
      setState(() {
        _currentLocation = pos;
      });

      if (_mapReady) {
        _mapController.move(pos, _mapController.camera.zoom);
      }
      if (_pendingVisited.isEmpty ||
          const Distance().as(LengthUnit.Meter, _pendingVisited.last, pos) >
              3) {
        _pendingVisited.add(pos);
      }
    });
  }

  Future<void> _uploadVisitedZones() async {
    if (_pendingVisited.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    if (userId == null) return;

    final List<Map<String, dynamic>> payload =
        _pendingVisited
            .map(
              (pos) => {
                "user_id": userId,
                "latitude": pos.latitude,
                "longitude": pos.longitude,
              },
            )
            .toList();

    try {
      await LocationService.uploadBatchVisitedZones(payload);
      _pendingVisited.clear(); // Nur bei Erfolg leeren
    } catch (e) {
      debugPrint("Fehler beim Hochladen der Visited Zones: $e");
    }
  }

  @override
  void dispose() {
    _trackerSub.cancel(); // Stream beenden
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialZoom: 14,
          onMapReady: () {
            if (!_mapReady) {
              _mapReady = true;
              _startTracking();
              _loadVisitedPolygons(); // Erst starten, wenn Karte bereit ist
            }
            debugPrint("Map is ready");
          },
        ),
        children: [
          // Satellitenkarte via ArcGIS
          TileLayer(
            urlTemplate:
                "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}.png",
            userAgentPackageName: 'com.example.map_page',
          ),
          // Zonen wieder farbig sichtbar
          PolygonLayer(
            key: ValueKey(_visitedPolygon.length),
            polygons: [
              Polygon(
                points: outerPolygon,
                holePointsList: _visitedPolygon,
                color: Colors.black.withValues(alpha: 0.6),
                // Füllfarbe für das äußere Polygon
                //borderColor: Colors.transparent,
              ),
            ],
          ),
          // Marker für aktuellen Standort
          if (_currentLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLocation!,
                  width: 50,
                  height: 50,
                  child: const Icon(
                    Icons.my_location_outlined,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
