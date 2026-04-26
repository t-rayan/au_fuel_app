import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// Provider to handle the list of favorite station IDs
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier(ref);
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final Ref _ref;

  FavoritesNotifier(this._ref) : super({}) {
    // Automatically fetch favorites from Supabase when the user logs in
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final supabase = _ref.read(supabaseProvider);
    try {
      final response = await supabase
          .from('favorites')
          .select('station_id')
          .eq('user_id', user.id);

      final fetchedIds = (response as List).map((row) => row['station_id'] as String).toSet();
      state = fetchedIds;
    } catch (e) {
      // Log error or show notification
    }
  }

  Future<void> toggleFavorite(String stationId) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final supabase = _ref.read(supabaseProvider);
    final isCurrentlyFavorite = state.contains(stationId);

    // 1. Optimistic UI update (update locally first for instant feel)
    if (isCurrentlyFavorite) {
      state = {...state}..remove(stationId);
    } else {
      state = {...state}..add(stationId);
    }

    try {
      // 2. Sync with Supabase
      if (isCurrentlyFavorite) {
        await supabase
            .from('favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('station_id', stationId);
      } else {
        await supabase.from('favorites').insert({
          'user_id': user.id,
          'station_id': stationId,
        });
      }
    } catch (e) {
      // Revert local state if the network call fails
      if (isCurrentlyFavorite) {
        state = {...state}..add(stationId);
      } else {
        state = {...state}..remove(stationId);
      }
    }
  }
}
