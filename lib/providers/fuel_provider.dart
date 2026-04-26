import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/fuel_station.dart';
import '../models/fuel_type.dart';
import '../services/fuel_service.dart';
import 'locality_provider.dart';

// 1. Service Provider
final fuelServiceProvider = Provider((ref) => FuelService());

// 2. State Providers for UI Filters and Selection
final selectedFuelIdProvider = StateProvider<int?>((ref) => null);
final selectedStationProvider = StateProvider<FuelStation?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => "");

// 3. Data Providers (Fetching from API)
final fuelTypesProvider = FutureProvider<List<FuelType>>((ref) async {
  final service = ref.watch(fuelServiceProvider);
  return service.getFuelTypes();
});

final fuelStationsProvider = FutureProvider<List<FuelStation>>((ref) async {
  final service = ref.watch(fuelServiceProvider);
  final fuelId = ref.watch(selectedFuelIdProvider);
  
  if (fuelId == null) return [];
  
  return service.getRealTimeData(fuelId);
});


// 4. List of stations (Used for UI)
final filteredStationsProvider = Provider<List<FuelStation>>((ref) {
  final stationsAsync = ref.watch(fuelStationsProvider);
  final selectedLocality = ref.watch(selectedLocalityProvider);
  
  final list = stationsAsync.value ?? [];
  
  if (selectedLocality == null) return list;

  // If a suburb is selected, sort the entire QLD list by distance to that suburb
  final sortedList = List<FuelStation>.from(list);
  
  sortedList.sort((a, b) {
    final distA = Geolocator.distanceBetween(
      selectedLocality.lat, selectedLocality.lng, a.lat, a.lng
    );
    final distB = Geolocator.distanceBetween(
      selectedLocality.lat, selectedLocality.lng, b.lat, b.lng
    );
    return distA.compareTo(distB);
  });

  return sortedList;
});

// 5. Cheapest Station Provider (Respects sorting)
final cheapestStationProvider = Provider<FuelStation?>((ref) {
  final stations = ref.watch(filteredStationsProvider);
  
  final validStations = stations.where((s) => s.price != null && s.price! > 0 && s.price! < 9000).toList();
  
  if (validStations.isEmpty) return null;

  FuelStation cheapest = validStations.first;
  for (var station in validStations) {
    if (station.price != null && station.price! < cheapest.price!) {
      cheapest = station;
    }
  }
  return cheapest;
});
