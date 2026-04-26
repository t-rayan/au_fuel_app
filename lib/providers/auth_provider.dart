import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the Supabase Client
final supabaseProvider = Provider((ref) => Supabase.instance.client);

/// Provider for the current Auth Session
final authSessionProvider = StreamProvider<Session?>((ref) {
  final client = ref.watch(supabaseProvider);
  return client.auth.onAuthStateChange.map((data) => data.session);
});

/// UI friendly provider for Auth Status
final isAuthenticatedProvider = Provider<bool>((ref) {
  final sessionAsync = ref.watch(authSessionProvider);
  return sessionAsync.value != null;
});

/// Provider for the current User
final currentUserProvider = Provider<User?>((ref) {
  final sessionAsync = ref.watch(authSessionProvider);
  return sessionAsync.value?.user;
});
