import "dart:async";

import "package:map_mates/services/location_service.dart";
import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Variablen
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  LatLng? _lastMovedLocation;
  StreamSubscription<LatLng>? _locationSub;
  bool _mapReady = false;

  // Funktion zum Abrufen der Location
  void _startTracking() async {
    // Zuerst einmal den aktuellen Standort abfragen
    final initialLocation = await LocationService.getCurrentLocation();
    if (initialLocation != null) {
      setState(() {
        _currentLocation = initialLocation;
      });
      _mapController.move(initialLocation, _mapController.camera.zoom);
      _lastMovedLocation = initialLocation;
      debugPrint("Initial location set to: $_currentLocation");
    }

    // Dann den Stream abonnieren, um weitere Updates zu erhalten
    final stream = await LocationService.getLocationStream();
    if (stream != null) {
      _locationSub = stream.listen((LatLng pos) {
        debugPrint("Got position: $pos");

        setState(() {
          _currentLocation = pos;
        });

        if (_lastMovedLocation == null ||
            const Distance().as(LengthUnit.Meter, _lastMovedLocation!, pos) >
                30) {
          debugPrint("Moved to: $pos");
          _mapController.move(pos, _mapController.camera.zoom);
          _lastMovedLocation = pos;
          debugPrint("Updated location: $_currentLocation");
          debugPrint("Last moved location: $_lastMovedLocation");
        }
      });
    }
  }

  @override
  void dispose() {
    _locationSub?.cancel();
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
              _startTracking();
              _mapReady = true;
            }
            debugPrint("Map is ready");
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.map_page',
       //     tileDimension: 512,
            retinaMode: true,
          ),
          if (_currentLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLocation!,
                  width: 50,
                  height: 50,
                  child: Icon(Icons.my_location, color: Colors.blue),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
