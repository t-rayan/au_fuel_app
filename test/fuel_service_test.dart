import 'package:flutter_test/flutter_test.dart';
import 'package:au_fuel/services/fuel_service.dart';

void main() {
  test('print getFuelTypes data', () async {
    final service = FuelService();
    await service.getFuelTypes();
  });
}
