class FuelType {
  final int fuelId;
  final String name;

  FuelType({required this.fuelId, required this.name});

  factory FuelType.fromAPI(Map<String, dynamic> json) {
    return FuelType(fuelId: json['FuelId'], name: json['Name']);
  }

  @override
  String toString() {
    return 'FuelType(ID: $fuelId, Name: $name)';
  }
}
