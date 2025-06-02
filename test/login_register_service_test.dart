import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:map_mates/services/login_register_service.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MockHTTPClient extends Mock implements Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockHTTPClient mockHTTPClient;
  late LoginRegisterService loginRegisterService;

  setUp(() {
    mockHTTPClient = MockHTTPClient();
    loginRegisterService = LoginRegisterService(mockHTTPClient);

    // SharedPreferences mock vorbereiten
    SharedPreferences.setMockInitialValues({});
  });

  // LOGIN TESTS
  group("Login", () {
    test("Login Succeed", () async {
      const username = 'testuser';
      const password = '123456';

      // Simulierter Server-Response
      final fakeResponse = {'user': username, 'user_id': 42};

      when(
        () => mockHTTPClient.post(
          Uri.parse(
            "https://map-mates-profile-api-production.up.railway.app/users/login",
          ),
          headers: any(named: "headers"),
          body: any(named: "body"),
        ),
      ).thenAnswer((_) async => Response(jsonEncode(fakeResponse), 200));

      final result = await loginRegisterService.login(
        username,
        password,
        skipTracking: true,
      );

      expect(result, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('loggedIn'), true);
      expect(prefs.getString('username'), username);
      expect(prefs.getInt('user_id'), 42);
    });
    // Falsches Passwort oder Nutzer
    test("Login Failed", () async {
      const username = 'testuser';
      const password = 'falschesPasswort';

      // Simuliere HTTP 400 mit Fehlermeldung
      when(
        () => mockHTTPClient.post(
          Uri.parse(
            "https://map-mates-profile-api-production.up.railway.app/users/login",
          ),
          headers: any(named: "headers"),
          body: any(named: "body"),
        ),
      ).thenAnswer(
        (_) async => Response('{"detail": "Invalid credentials"}', 400),
      );

      final result = await loginRegisterService.login(
        username,
        password,
        skipTracking: true,
      );

      expect(result, false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('loggedIn'), isNot(true));
      expect(prefs.getString('username'), isNull);
      expect(prefs.getInt('user_id'), isNull);
    });
  });

  // REGISTER TESTS
  group("Register", () {
    test("Register Succeed", () async {
      const email = 'test@example.com';
      const username = 'testuser';
      const password = 'securepassword';
      const userId = 99;

      final fakeResponse = {
        "message": "User created successfully",
        "user": username,
        "user_id": userId,
      };

      when(
        () => mockHTTPClient.post(
          Uri.parse(
            "https://map-mates-profile-api-production.up.railway.app/users/register",
          ),
          headers: any(named: "headers"),
          body: any(named: "body"),
        ),
      ).thenAnswer((_) async => Response(jsonEncode(fakeResponse), 200));

      final result = await loginRegisterService.register(
        email,
        username,
        password,
        skipTracking: true,
      );

      expect(result, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('loggedIn'), true);
      expect(prefs.getString('username'), username);
      expect(prefs.getInt('user_id'), userId);
    });

    test("Register fails – Username already taken", () async {
      const email = 'test@example.com';
      const username = 'existinguser';
      const password = 'any';

      when(
        () => mockHTTPClient.post(
          Uri.parse(
            "https://map-mates-profile-api-production.up.railway.app/users/register",
          ),
          headers: any(named: "headers"),
          body: any(named: "body"),
        ),
      ).thenAnswer(
        (_) async => Response('{"detail": "Username already registered"}', 400),
      );

      final result = await loginRegisterService.register(
        email,
        username,
        password,
        skipTracking: true,
      );

      expect(result, false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('loggedIn'), isNot(true));
    });

    test("Register fails – Email already registered", () async {
      const email = 'used@example.com';
      const username = 'newuser';
      const password = 'secure';

      when(
        () => mockHTTPClient.post(
          Uri.parse(
            "https://map-mates-profile-api-production.up.railway.app/users/register",
          ),
          headers: any(named: "headers"),
          body: any(named: "body"),
        ),
      ).thenAnswer(
        (_) async => Response('{"detail": "Email already registered"}', 400),
      );

      final result = await loginRegisterService.register(
        email,
        username,
        password,
        skipTracking: true,
      );

      expect(result, false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('loggedIn'), isNot(true));
    });
  });

  group("logout", () {
    test("Logout", () async {

      // Set-Up
      SharedPreferences.setMockInitialValues({
      'loggedIn': true,
      'username': 'testuser',
      'user_id': 1,
      });

      // Ausführung
      await loginRegisterService.logout(skipTracking: true);

      // Überprüfung
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isEmpty);
    });
  });
}
