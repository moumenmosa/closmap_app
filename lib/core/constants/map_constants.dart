/// Shared map tile configuration for home and search screens.
class MapConstants {
  MapConstants._();

  /// CartoDB Positron (light) — attribution required in production.
  static const String lightTileUrl =
      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';

  static const List<String> lightTileSubdomains = ['a', 'b', 'c', 'd'];

  static const String userAgentPackageName = 'com.closemap.closemap';
}
