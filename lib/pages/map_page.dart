import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_mates/services/location_tracker.dart';

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

  // FUNKTIONEN

  // Startet das Location-Tracking & aktualisiert die Karte
  void _startTracking() {
    // Einmalig beim starten letzte ausgesendete Position bekommen
    final lastPos = LocationTracker().lastKnownLocation;
    if (lastPos != null && mounted) {
      setState(() => _currentLocation = lastPos);
      _mapController.move(lastPos, _mapController.camera.zoom);
    }

    // Abhören auf neue Positionen
    _trackerSub = LocationTracker().stream.listen((pos) {
      if (!mounted) return;
      setState(() => _currentLocation = pos);
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
          initialZoom: 14,
          onMapReady: () {
            if (!_mapReady) {
              _mapReady = true;
              _startTracking(); // Erst starten, wenn Karte bereit ist
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
