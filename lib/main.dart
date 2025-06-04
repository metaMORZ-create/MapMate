import 'package:flutter/material.dart';
import 'package:map_mates/pages/home_page.dart';
import 'package:map_mates/pages/intro_page.dart';
import 'package:map_mates/services/location_service.dart';
import 'package:map_mates/services/location_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wird durch `--dart-define=TEST_MODE=true` aktiviert
const bool isTestMode = bool.fromEnvironment('TEST_MODE');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await startApp();
}

Future<void> startApp() async {
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool("loggedIn") ?? false;
  final userId = prefs.getInt("user_id");

  // Standortberechtigung: im Testmodus automatisch gewähren
  final permissionGranted =
      isTestMode
          ? true
          : await LocationService.checkAndRequestLocationPermission();

  // Nur im echten Login-Fall Tracking starten
  if (!isTestMode && isLoggedIn && userId != null) {
    await LocationTracker().startBatchTracking();
    await LocationTracker().updatePolygonOnce(userId);
    LocationTracker().startAutoPolygonUpdate(userId);
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
              ? const HomePage()
              : IntroPage(permissionGranted: permissionGranted),
    );
  }
}
