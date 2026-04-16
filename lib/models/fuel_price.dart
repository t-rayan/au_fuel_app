class FuelPrice {
  final int siteId;
  final int fuelId;
  final double price;
  final DateTime lastUpdated;

  FuelPrice({
    required this.siteId,
    required this.fuelId,
    required this.price,
    required this.lastUpdated,
  });

  factory FuelPrice.fromJson(Map<String, dynamic> json) {
    return FuelPrice(
      siteId: json['S'] as int,
      fuelId: json['F'] as int,
      price: (json['P'] as num).toDouble(),
      // The API often provides a UTC string; we parse it to local time
      lastUpdated: DateTime.parse(json['U'] as String).toLocal(),
    );
  }
}
