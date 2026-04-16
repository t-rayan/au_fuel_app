import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vault_colors.dart';

class VaultTypography {
  // Editorial Scale Implementation
  static TextTheme textTheme = TextTheme(
    // display-lg: Hero Fuel Prices (The "Price Pulse")
    displayLarge: GoogleFonts.manrope(
      fontSize: 56, // 3.5rem
      fontWeight: FontWeight.w800,
      color: VaultColors.primaryGold,
    ),

    // headline-md: Station Names, Section Headers
    headlineMedium: GoogleFonts.manrope(
      fontSize: 28, // 1.75rem
      fontWeight: FontWeight.w700,
      color: VaultColors.onSurface,
    ),

    // title-lg: Sub-headers and Card Titles
    titleLarge: GoogleFonts.inter(
      fontSize: 22, // 1.375rem
      fontWeight: FontWeight.w500,
      color: VaultColors.onSurface,
    ),

    // body-md: Primary reading text and addresses
    bodyMedium: GoogleFonts.inter(
      fontSize: 14, // 0.875rem
      fontWeight: FontWeight.w400,
      color: VaultColors.onSurface,
    ),

    // label-sm: Metadata and micro-copy
    labelSmall: GoogleFonts.inter(
      fontSize: 11, // 0.6875rem
      fontWeight: FontWeight.w500,
      color: VaultColors.onSurfaceVariant,
      letterSpacing: 0.5,
    ),
  );
}
