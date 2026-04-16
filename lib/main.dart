import 'package:au_fuel/themes/vault_colors.dart';
import 'package:au_fuel/themes/vault_typography.dart';
import 'package:flutter/material.dart';
import 'screens/map_screen.dart'; // Import your new file

void main() {
  runApp(const FuelInfoApp());
}

class FuelInfoApp extends StatelessWidget {
  const FuelInfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Au Fuel Info',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        // Level 0: The Base "Void" background
        scaffoldBackgroundColor: VaultColors.surface,

        // Applying your Editorial Scale
        textTheme: VaultTypography.textTheme,

        // Setting up the Tonal Palette for Material 3 components
        colorScheme: const ColorScheme.dark(
          surface: VaultColors.surface,
          surfaceContainerLow: VaultColors.surfaceLow,
          surfaceContainerHigh: VaultColors.surfaceHigh,
          surfaceContainerHighest: VaultColors.surfaceHighest,
          onSurface: VaultColors.onSurface,
          primary: VaultColors.primaryGold,
        ),
      ),
      home: const MapScreen(), // This tells the app to show the map first
    );
  }
}
