import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator_2/background_locator.dart';
import 'package:flutter/material.dart';
import 'package:map_mates/background/background_location_repository.dart';
import 'package:map_mates/pages/home_page.dart';
import 'package:map_mates/pages/intro_page.dart';
import 'package:map_mates/services/location_service.dart';
import 'package:map_mates/services/location_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:map_mates/background/location_callback_handler.dart';

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
    await LocationTracker().startAllLocationTracking();
    await LocationTracker().updatePolygonOnce(userId);
    LocationTracker().startAutoPolygonUpdate(userId); // alle 5min automatisch
  }

  runApp(MyApp(permissionGranted: permissionGranted, loggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  static const String _isolateName = "LocatorIsolate";
  final bool permissionGranted;
  final bool loggedIn;

  const MyApp({
    super.key,
    required this.permissionGranted,
    required this.loggedIn,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final backgroundRepo = BackgroundLocationRepository();

  @override
  void initState() {
    super.initState();
    backgroundRepo.initialize();
  }

  Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          widget.loggedIn
              ? HomePage()
              : IntroPage(permissionGranted: widget.permissionGranted),
    );
  }
}
