class FuelSite {
  final int siteId;
  final String name;
  final String address;
  final String brand;
  final double lat;
  final double lng;

  FuelSite({
    required this.siteId,
    required this.name,
    required this.address,
    required this.brand,
    required this.lat,
    required this.lng,
  });

  factory FuelSite.fromJson(Map<String, dynamic> json) {
    return FuelSite(
      siteId: json['S'] as int,
      name: json['N'] as String,
      address: json['A'] as String,
      brand: json['B'] as String,
      lat: (json['Lat'] as num).toDouble(),
      lng: (json['Lng'] as num).toDouble(),
    );
  }
}
