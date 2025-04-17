import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/location_dto.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_mates/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_callback_handler.dart';

class BackgroundLocationRepository {
  static const String isolateName = LocationCallbackHandler.isolateName;

  final ReceivePort _port = ReceivePort();
  final List<LocationDto> _buffer = [];

  Timer? _uploadTimer;

  void initialize() {
    IsolateNameServer.removePortNameMapping(isolateName);
    IsolateNameServer.registerPortWithName(_port.sendPort, isolateName);

    _port.listen((dynamic data) {
      if (data is LocationDto) {
        _buffer.add(data);
      }
    });

    _uploadTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _uploadBufferedLocations();
    });
  }

  Future<void> _uploadBufferedLocations() async {
    if (_buffer.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    if (userId == null) return;

    final now = DateTime.now().toIso8601String();

    final batch = _buffer.map((dto) {
      return {
        "user_id": userId,
        "latitude": dto.latitude,
        "longitude": dto.longitude,
        "timestamp": now,
      };
    }).toList();

    try {
      await LocationService.uploadBatchVisitedZones(batch);
      await LocationService.uploadBatchLocations(batch);
      _buffer.clear();
      debugPrint("✅ Hochgeladen: ${batch.length} Standortdaten");
    } catch (e) {
      debugPrint("❌ Fehler beim Hochladen der Standortdaten: $e");
    }
  }

  void dispose() {
    IsolateNameServer.removePortNameMapping(isolateName);
    _uploadTimer?.cancel();
    _port.close();
  }
}
