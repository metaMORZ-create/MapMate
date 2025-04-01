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

  // Funktion zum abrufen der Location
  void _startTracking() async {
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
          _mapController.move(
            pos,
            _mapController.camera.zoom,
          );
          _lastMovedLocation = pos;
          debugPrint("Initial location: $_currentLocation");
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
          initialCenter: _currentLocation ?? LatLng(52.5200, 13.4050),
          initialZoom: 12,
          onMapReady: _startTracking,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.map_page',
            tileDimension: 512,
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
