import 'dart:convert';
import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:map_mates/services/location_service.dart';

class BackgroundTrackingService {
  static Future<void> start() async {
    await BackgroundLocationTrackerManager.startTracking();
  }

  static Future<void> stop() async {
    await BackgroundLocationTrackerManager.stopTracking();
  }

  static Future<void> uploadStoredLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList("bg_locations") ?? [];

    if (stored.isEmpty) return;

    final List<Map<String, dynamic>> batch =
        stored.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();

    try {
      await LocationService.uploadBatchVisitedZones(batch);
      await LocationService.uploadBatchLocations(batch);
      await prefs.remove("bg_locations");
    } catch (e) {
      debugPrint("❌ Fehler beim Upload der BG-Daten: $e");
    }
  }
}
