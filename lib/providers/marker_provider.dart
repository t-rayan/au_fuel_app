import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/fuel_station.dart';
import '../utils/marker_generator.dart';
import 'fuel_provider.dart';

class MarkerNotifier extends StateNotifier<Set<Marker>> {
  final Ref ref;
  Map<String, BitmapDescriptor> _iconCache = {};

  MarkerNotifier(this.ref) : super({}) {
    // Watch for changes in either stations or selection to rebuild markers
    ref.listen<List<FuelStation>>(filteredStationsProvider, (prev, next) => _rebuild());
    ref.listen<FuelStation?>(selectedStationProvider, (prev, next) => _rebuild());
    ref.listen<FuelStation?>(cheapestStationProvider, (prev, next) => _rebuild());
    
    // Initial build
    _rebuild();
  }

  Future<void> _rebuild() async {
    final stations = ref.read(filteredStationsProvider);
    final selectedStation = ref.read(selectedStationProvider);
    final cheapestStation = ref.read(cheapestStationProvider);
    
    // 1. Identify all unique required icons (Brand + Price + Selection + Cheapest state)
    final Set<String> uniqueIconKeys = {};
    final Map<String, (String, String, bool, bool)> keyToData = {};
    
    for (var station in stations) {
      final bool isSelected = selectedStation?.siteId == station.siteId;
      final bool isCheapest = cheapestStation?.siteId == station.siteId;
      final String priceStr = _getFormattedPrice(station.price);
      final String cacheKey = "${station.brand}_${priceStr}_${isSelected}_$isCheapest";
      
      if (!_iconCache.containsKey(cacheKey)) {
        uniqueIconKeys.add(cacheKey);
        keyToData[cacheKey] = (station.brand, priceStr, isSelected, isCheapest);
      }
    }

    // 2. Generate ONLY the missing unique icons in parallel
    if (uniqueIconKeys.isNotEmpty) {
      await Future.wait(uniqueIconKeys.map((key) async {
        final data = keyToData[key]!;
        final icon = await MarkerGenerator.createBrandMarker(
          data.$1,
          data.$2,
          isSelected: data.$3,
          isCheapest: data.$4,
        );
        _iconCache[key] = icon;
      }));
    }

    // 3. Build markers using the now-populated cache
    final Set<Marker> newMarkers = stations.map((station) {
      final bool isSelected = selectedStation?.siteId == station.siteId;
      final bool isCheapest = cheapestStation?.siteId == station.siteId;
      final String priceStr = _getFormattedPrice(station.price);
      final String cacheKey = "${station.brand}_${priceStr}_${isSelected}_$isCheapest";
      
      return Marker(
        markerId: MarkerId(station.siteId.toString()),
        position: LatLng(station.lat, station.lng),
        icon: _iconCache[cacheKey]!,
        zIndex: isSelected ? 2.0 : (isCheapest ? 1.5 : 1.0),
        onTap: () {
          ref.read(selectedStationProvider.notifier).state = station;
        },
      );
    }).toSet();
    
    state = newMarkers;
  }

  String _getFormattedPrice(double? price) {
    return (price != null && price < 9000)
        ? '\$${(price / 1000).toStringAsFixed(2)}'
        : 'N/A';
  }
}

final markerProvider = StateNotifierProvider<MarkerNotifier, Set<Marker>>((ref) {
  return MarkerNotifier(ref);
});
