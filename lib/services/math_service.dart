import 'dart:math';
import 'package:latlong2/latlong.dart';

class MathService {
  static List<LatLng> createCircle(double lat, double lng, double radius) {
    const int points = 64;
    const double earthRadius = 6378137.0;
    double latRad = lat * (pi / 180.0);
    double lngRad = lng * (pi / 180.0);
    double d = radius / earthRadius;

    List<LatLng> circlePoints = [];
    for (int i = 0; i < points; i++) {
      double angle = (i * 360 / points) * (pi / 180.0);
      double latPoint =
          asin(sin(latRad) * cos(d) + cos(latRad) * sin(d) * cos(angle));
      double lngPoint = lngRad +
          atan2(sin(angle) * sin(d) * cos(latRad),
              cos(d) - sin(latRad) * sin(latPoint));
      circlePoints
          .add(LatLng(latPoint * (180.0 / pi), lngPoint * (180.0 / pi)));
    }
    return circlePoints;
  }
}