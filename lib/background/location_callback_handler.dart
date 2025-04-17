import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/location_dto.dart';

class LocationCallbackHandler {
  static const String isolateName = 'LocatorIsolate';

  @pragma('vm:entry-point')
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    // Initialisierungscode, z. B. Logger einrichten
  }

  @pragma('vm:entry-point')
  static Future<void> disposeCallback() async {
    // Aufräumarbeiten durchführen
  }

  @pragma('vm:entry-point')
  static Future<void> callback(LocationDto locationDto) async {
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(locationDto);
  }

  @pragma('vm:entry-point')
  static void notificationCallback() {
    // Wird aufgerufen, wenn der Benutzer auf die Benachrichtigung klickt
  }
}
