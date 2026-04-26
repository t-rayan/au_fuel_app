import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/locality.dart';
import '../services/locality_service.dart';
import 'fuel_provider.dart';

/// Tracks the locality currently selected by the user from the search bar
final selectedLocalityProvider = StateProvider<Locality?>((ref) => null);

/// Provider for the entire static locality dataset
final allLocalitiesProvider = FutureProvider<List<Locality>>((ref) async {
  return LocalityService.loadLocalities();
});

/// Filtered provider that only includes Queensland localities
final qldLocalitiesProvider = Provider<List<Locality>>((ref) {
  final localitiesAsync = ref.watch(allLocalitiesProvider);
  return localitiesAsync.when(
    data: (list) => list.where((loc) => loc.state.toUpperCase() == 'QLD').toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Reactive provider for QLD-only search results
final localitySuggestionsProvider = Provider<List<Locality>>((ref) {
  final qldList = ref.watch(qldLocalitiesProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  if (query.isEmpty) return [];

  return qldList.where((loc) {
    final suburbMatches = loc.suburb.toLowerCase().startsWith(query);
    final postcodeMatches = loc.postcode.startsWith(query);
    
    return suburbMatches || postcodeMatches;
  }).take(10).toList();
});
