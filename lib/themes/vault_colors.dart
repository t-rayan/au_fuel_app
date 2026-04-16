import 'package:flutter/material.dart';

class VaultColors {
  // --- 1. THE FOUNDATION: TONAL LAYERS ---
  // Hierarchy is achieved through tonal shifts, not 1px lines.

  /// Level 0: The Base "Void" background.
  static const Color surface = Color(0xFF131313);

  /// Level 1: Low-elevation sections.
  static const Color surfaceLow = Color(0xFF1C1B1B);

  /// Level 2: Interactive Cards (High-elevation).
  static const Color surfaceHigh = Color(0xFF2A2A2A);

  /// Level 3: Top-level Modals and Bottom Sheets.
  static const Color surfaceHighest = Color(0xFF353534);

  // --- 2. ACCENTS & STATES ---

  /// Primary Accent: Gold for high-importance actions.
  static const Color primaryGold = Color(0xFFFFD700);

  /// Secondary Accent: Wattle Green for brand/pulse indicators.
  static const Color wattleGreen = Color(0xFF008650);

  /// Savings: Positive price trends.
  static const Color savingsGreen = Color(0xFF78DC77);

  /// Warning: Price peaks or errors.
  static const Color pricePeakRed = Color(0xFFFFB4AB);

  // --- 3. TYPOGRAPHY COLORS ---

  /// Primary Text: Use instead of pure white to reduce eye strain.
  static const Color onSurface = Color(0xFFE5E2E1);

  /// Secondary Text: For metadata and labels.
  static const Color onSurfaceVariant = Colors.white60;
}
