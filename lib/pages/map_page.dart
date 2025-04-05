import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_mates/services/location_service.dart';
import 'package:map_mates/services/location_tracker.dart';
import 'package:map_mates/services/math_service.dart';
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
  List<Map<String, dynamic>> _visitedZones = [];

  // FUNKTIONEN

  
  // Load Last Visited Zones
  Future<void> _loadVisitedZones() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    if (userId != null) {
      final zones = await LocationService.getVisitedZones(userId);
      setState(() {
        _visitedZones= zones;
      });
    }
  }

  // Startet das Location-Tracking & aktualisiert die Karte
  void _startTracking() {
    // Hole letzten bekannten Standort (z. B. falls Map später gebaut wird)
    final lastPos = LocationTracker().lastKnownLocation;
    if (lastPos != null) {
      setState(() {
        _currentLocation = lastPos;
      });
      _mapController.move(lastPos, _mapController.camera.zoom);
    }

    // Höre auf neue Positionen vom globalen Stream
    _trackerSub = LocationTracker().stream.listen((pos) {
      setState(() {
        _currentLocation = pos;
      });

      if (_mapReady) {
        _mapController.move(pos, _mapController.camera.zoom);
      }
    });
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
          initialZoom: 12,
          onMapReady: () {
            if (!_mapReady) {
              _mapReady = true;
              _startTracking();
              _loadVisitedZones(); // Erst starten, wenn Karte bereit ist
            }
            debugPrint("Map is ready");
          },
        ),
        children: [
          // Satellitenkarte via ArcGIS
          TileLayer(
            urlTemplate:
                "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
            userAgentPackageName: 'com.example.map_page',
            tileBuilder: (context, widget, tile) {
              return ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.saturation,
                ),
                child: widget,
              );
            },
          ),
          // Zonen wieder farbig sichtbar
          PolygonLayer(
            polygons: _visitedZones.map((zone) {
              final points = MathService.createCircle(
                zone["latitude"],
                zone["longitude"],
                zone["radius"] ?? 5.0,
              );
              return Polygon(
                points: points,
                color: Colors.transparent,
                borderColor: Colors.transparent,
              );
            }).toList(),
          ),
          // Marker für aktuellen Standort
          if (_currentLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLocation!,
                  width: 50,
                  height: 50,
                  child: const Icon(Icons.my_location_outlined, color: Colors.blue),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
