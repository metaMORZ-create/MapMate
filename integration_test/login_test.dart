import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:map_mates/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

// Starten mit: flutter test integration_test/login_test.dart --dart-define=TEST_MODE=true
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({"loggedIn": false});
  });

  testWidgets("Login and check if all Pages are loaded correctly", (
    tester,
  ) async {
    await app.startApp();
    await tester.pumpAndSettle();

    // Login-Button finden und klicken
    final loginButton = find.byKey(const Key("login_button"));
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Login-Form ausfüllen und absenden
    await tester.enterText(find.byType(TextFormField).at(0), "test");
    await tester.enterText(find.byType(TextFormField).at(1), "test");
    await tester.tap(find.text("Einloggen"));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Startseite (HomePage) prüfen
    expect(find.byKey(const Key("home_page")), findsOneWidget);

    // FriendsTab sollte aktiv sein
    expect(find.byKey(const Key("profiles_tabview")), findsOneWidget);

    // Zur Map-Seite wechseln
    await tester.tap(find.byKey(const Key("nav_map")));
    await tester.pumpAndSettle();
    expect(find.byType(FlutterMap), findsOneWidget);

    // Zur Settings-Seite wechseln
    await tester.tap(find.byKey(const Key("nav_settings")));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key("logout_button")), findsOneWidget);
  });
}
