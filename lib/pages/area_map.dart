import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_mates/services/location_service.dart';
import 'package:map_mates/services/location_tracker.dart';

class VisitedAreaPage extends StatefulWidget {
  final int userId;
  final String userName;

  const VisitedAreaPage({super.key, required this.userId, required this.userName});

  @override
  State<VisitedAreaPage> createState() => _VisitedAreaPageState();
}

class _VisitedAreaPageState extends State<VisitedAreaPage> {
  final MapController _mapController = MapController();

  LatLng? _currentLocation;
  List<List<LatLng>> _visitedPolygon = [];
  LatLng? pos;

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

  Future<void> _initializeMap() async {
    final lastLocationData = await LocationService.getLastLocation(
      widget.userId,
    );
    if (lastLocationData != null) {
      pos = lastLocationData["position"];
    }

    if (pos != null && mounted) {
      final polygon = await LocationService.getStoredVisitedPolygon(
        widget.userId,
      );

      setState(() {
        _currentLocation = pos;
        _visitedPolygon = polygon;
      });
      _mapController.move(pos!, 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Center(child: Text("${widget.userName} Visited Areas", style: TextStyle(color: Colors.white, fontSize: 14),)),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white,),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              LocationTracker().updatePolygonOnce(widget.userId);
              _initializeMap();
            }, 
            icon: Icon(Icons.refresh, color: Colors.white,)
            )
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialZoom: 14,
          onMapReady: () {
            _initializeMap();
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}.png",
            userAgentPackageName: 'com.example.map_page',
          ),
          if (_visitedPolygon.isNotEmpty)
            PolygonLayer(
              key: ValueKey(_visitedPolygon.length),
              polygons: [
                Polygon(
                  points: outerPolygon,
                  holePointsList: _visitedPolygon,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ],
            ),
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
