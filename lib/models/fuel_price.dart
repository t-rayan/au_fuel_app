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
      siteId: int.tryParse(json['SiteId']?.toString() ?? json['S']?.toString() ?? '0') ?? 0,
      fuelId: int.tryParse(json['FuelId']?.toString() ?? json['F']?.toString() ?? '0') ?? 0,
      price: ((json['Price'] ?? json['P'] ?? 0) as num).toDouble(),
      // Handle the Date String
      lastUpdated: DateTime.parse((json['TransactionDateUtc'] ?? json['U'] ?? DateTime.now().toIso8601String()).toString()).toLocal(),
    );
  }
}
