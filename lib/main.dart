import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/map_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/fuel_provider.dart';
import 'providers/auth_provider.dart';

// Provider to track if onboarding is complete for this session
final showOnboardingProvider = StateProvider<bool>((ref) => true);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nyusjimtxxuauujfqmas.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im55dXNqaW10eHh1YXV1amZxbWFzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxMTE4NzgsImV4cCI6MjA5MjY4Nzg3OH0.daPuaerxutS-cF4iFRvlvhA8pMCfonS26ZbVn4Hkvmo',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final showOnboarding = ref.watch(showOnboardingProvider);

    // Setup the Android Auto Sync listener
    ref.listen(filteredStationsProvider, (previous, next) {
      if (next.isNotEmpty) {
        const channel = MethodChannel('com.example.au_fuel/car');
        final carData = next.map((s) => {
          'name': s.name,
          'price': s.price ?? 0.0,
          'lat': s.lat,
          'lng': s.lng,
        }).toList();
        
        channel.invokeMethod('updateStations', carData);
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AU Fuel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D4D44)),
        useMaterial3: true,
      ),
      home: _getHome(isAuthenticated, showOnboarding, ref),
    );
  }

  Widget _getHome(bool isAuthenticated, bool showOnboarding, WidgetRef ref) {
    if (showOnboarding) {
      return OnboardingScreen(
        onFinish: () => ref.read(showOnboardingProvider.notifier).state = false,
      );
    }
    
    return isAuthenticated ? const MapScreen() : const LoginScreen();
  }
}
