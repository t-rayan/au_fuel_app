// lib/models/fuel_station.dart

class FuelStation {
  final int siteId;
  final String name;
  final String brand;
  final String address;
  final double lat;
  final double lng;
  final double? price; // This will be injected from the Price API
  final DateTime? lastUpdated;

  FuelStation({
    required this.siteId,
    required this.name,
    required this.brand,
    required this.address,
    required this.lat,
    required this.lng,
    this.price,
    this.lastUpdated,
  });
}
