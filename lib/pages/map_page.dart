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
  late final MapController _mapController;
  LatLng? _currentLocation;

  // Bei Initierung der Seite
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadLocation();
  }

  // Funktion zum abrufen der Location
  Future<void> _loadLocation() async {
    LatLng? location = await LocationService.getCurrentLocation();
    if (location != null) {
      setState(() {
        _currentLocation = location;
      });
      _mapController.move(location, 12);
    }
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
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.map_page',
            tileSize: 512,
            retinaMode: true,
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLocation?? LatLng(52.5200, 13.4050), 
                width: 50,
                height: 50,
                child: Icon(Icons.my_location, color: Colors.blue,)
              )
            ]
          ),
        ],
      ),
    );
  }
}
