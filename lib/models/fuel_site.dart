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
      // Use .toString() instead of 'as String' for IDs and Brands
      siteId: int.tryParse(json['S'].toString()) ?? 0,
      name: json['N']?.toString() ?? 'Unknown Station',
      address: json['A']?.toString() ?? 'Unknown Address',
      brand: json['B']?.toString() ?? 'Unknown Brand',

      // Use (num).toDouble() to safely handle both 150 (int) and 150.5 (double)
      lat: (json['Lat'] as num).toDouble(),
      lng: (json['Lng'] as num).toDouble(),
    );
  }
}
