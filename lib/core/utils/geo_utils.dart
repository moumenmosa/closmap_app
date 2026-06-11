import 'dart:math' as math;
import 'package:geohash_plus/geohash_plus.dart';

class GeoUtils {
  GeoUtils._();

  static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _deg2rad(double deg) => deg * math.pi / 180;

  static String encode(double lat, double lng, {int precision = 9}) {
    return GeoHash.encode(lat, lng, precision: precision).hash;
  }

  static List<String> neighbors(String hash, {int precision = 5}) {
    final base = hash.length >= precision ? hash.substring(0, precision) : hash;
    final set = <String>{base};
    try {
      final decoded = GeoHash.decode(base);
      final lat = decoded.center.latitude;
      final lng = decoded.center.longitude;
      const delta = 0.05;
      for (final dLat in [-delta, 0.0, delta]) {
        for (final dLng in [-delta, 0.0, delta]) {
          set.add(GeoHash.encode(lat + dLat, lng + dLng, precision: precision).hash);
        }
      }
    } catch (_) {}
    return set.toList();
  }

  static bool withinRadius(
    double centerLat,
    double centerLng,
    double targetLat,
    double targetLng,
    double radiusKm,
  ) {
    return distanceKm(centerLat, centerLng, targetLat, targetLng) <= radiusKm;
  }
}
