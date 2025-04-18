import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

@pragma('vm:entry-point')
void backgroundCallback() {
  BackgroundLocationTrackerManager.handleBackgroundUpdated((location) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList("bg_locations") ?? [];

    final newEntry = jsonEncode({
      "latitude": location.lat,
      "longitude": location.lon,
      "timestamp": DateTime.now().toIso8601String(),
    });

    stored.add(newEntry);
    await prefs.setStringList("bg_locations", stored);
  });
}
