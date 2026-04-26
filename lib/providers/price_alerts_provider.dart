import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// Provider to manage user price alerts
final priceAlertsProvider = StateNotifierProvider<PriceAlertsNotifier, List<Map<String, dynamic>>>((ref) {
  return PriceAlertsNotifier(ref);
});

class PriceAlertsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final Ref _ref;

  PriceAlertsNotifier(this._ref) : super([]) {
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final supabase = _ref.read(supabaseProvider);
    try {
      final response = await supabase
          .from('price_alerts')
          .select()
          .eq('user_id', user.id);
      
      state = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> setAlert({
    required String stationId,
    required String fuelType,
    required double targetPrice,
  }) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final supabase = _ref.read(supabaseProvider);
    
    try {
      // Insert the new alert
      await supabase.from('price_alerts').insert({
        'user_id': user.id,
        'station_id': stationId,
        'fuel_type': fuelType,
        'target_price': targetPrice,
      });
      
      // Refresh the list
      await _fetchAlerts();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteAlert(String alertId) async {
    final supabase = _ref.read(supabaseProvider);
    try {
      await supabase.from('price_alerts').delete().eq('id', alertId);
      state = state.where((a) => a['id'] != alertId).toList();
    } catch (e) {
      // Handle error
    }
  }
}
