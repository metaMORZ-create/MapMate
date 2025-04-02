import 'package:flutter/material.dart';
import 'package:map_mates/pages/intro_page.dart';
import 'package:map_mates/services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Wichtig für async-Aufrufe in main()

  // Standortberechtigung abfragen
  bool permissionGranted = await LocationService.checkAndRequestLocationPermission();

  runApp(MyApp(permissionGranted: permissionGranted));
}

class MyApp extends StatelessWidget {
  final bool permissionGranted;

  const MyApp({super.key, required this.permissionGranted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IntroPage(permissionGranted: permissionGranted),
    );
  }
}