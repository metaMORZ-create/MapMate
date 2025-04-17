import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:map_mates/background/location_callback_handler.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  BackgroundLocator.registerLocationUpdate(
    LocationCallbackHandler.callback,
    initCallback: LocationCallbackHandler.initCallback,
    disposeCallback: LocationCallbackHandler.disposeCallback,
    iosSettings: IOSSettings(
      accuracy: LocationAccuracy.NAVIGATION,
      distanceFilter: 10,
      stopWithTerminate: false,
      showsBackgroundLocationIndicator: true,
    ),
    autoStop: false,
    androidSettings: AndroidSettings(
      accuracy: LocationAccuracy.NAVIGATION,
      interval: 10,
      distanceFilter: 10,
      client: LocationClient.google,
      androidNotificationSettings: AndroidNotificationSettings(
        notificationChannelName: 'Location tracking',
        notificationTitle: 'MapMates läuft im Hintergrund',
        notificationMsg: 'Standort wird aktualisiert',
        notificationBigMsg: 'MapMates zeichnet deinen Standort auf...',
        notificationIcon: '',
      ),
    ),
  );
}
