import 'package:flutter/material.dart';
import 'package:map_mates/pages/home_page.dart';
import 'package:map_mates/pages/intro_page.dart';
import 'package:map_mates/services/location_service.dart';
import 'package:map_mates/services/location_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool("loggedIn") ?? false;  
  final userId = prefs.getInt("user_id");

  // Standortberechtigung abfragen
  bool permissionGranted =
      await LocationService.checkAndRequestLocationPermission();

  // Automatische Polygon aktualisierung alle 5 Min
  // Nur wenn eingeloggt: Tracking starten + Polygon-Update
  if (isLoggedIn && userId != null) {
    await LocationTracker().startBatchTracking();
    await LocationTracker().updatePolygonOnce(userId);
    LocationTracker().startAutoPolygonUpdate(userId); // alle 5min automatisch
  }

  runApp(MyApp(permissionGranted: permissionGranted, loggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool permissionGranted;
  final bool loggedIn;

  const MyApp({
    super.key,
    required this.permissionGranted,
    required this.loggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          loggedIn
              ? HomePage()
              : IntroPage(permissionGranted: permissionGranted),
    );
  }
}
