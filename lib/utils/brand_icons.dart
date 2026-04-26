import 'package:flutter/material.dart';

class BrandIcons {
  // Map fuel brand names to icon data and brand colors
  // Map fuel brand names/IDs to icon data and brand colors
  static const Map<String, BrandIcon> brandMap = {
    'shell': BrandIcon(
      assetPath: 'assets/brands/Shell-logo.svg',
      color: Color(0xFFFFD700),
      displayName: 'Shell',
    ),
    '3421193': BrandIcon(
      assetPath: 'assets/brands/Shell-logo.svg',
      color: Color(0xFFFFD700),
      displayName: 'Shell',
    ),
    'bp': BrandIcon(
      assetPath: 'assets/brands/BP-logo.svg',
      color: Color(0xFF00AA44),
      displayName: 'BP',
    ),
    '5': BrandIcon(
      assetPath: 'assets/brands/BP-logo.svg',
      color: Color(0xFF00AA44),
      displayName: 'BP',
    ),
    'caltex': BrandIcon(
      assetPath: 'assets/brands/Caltex-logo.svg',
      color: Color(0xFFFF6B00),
      displayName: 'Caltex',
    ),
    '2': BrandIcon(
      assetPath: 'assets/brands/Caltex-logo.svg',
      color: Color(0xFFFF6B00),
      displayName: 'Caltex',
    ),
    'ampol': BrandIcon(
      assetPath: 'assets/brands/Ampol-logo.svg',
      color: Color(0xFF0066CC),
      displayName: 'Ampol',
    ),
    '3421066': BrandIcon(
      assetPath: 'assets/brands/Ampol-logo.svg',
      color: Color(0xFF0066CC),
      displayName: 'Ampol',
    ),
    '3421073': BrandIcon(
      assetPath: 'assets/brands/Ampol-logo.svg',
      color: Color(0xFF0066CC),
      displayName: 'EG Ampol',
    ),
    '7-eleven': BrandIcon(
      assetPath: 'assets/brands/7-eleven-logo.svg',
      color: Color(0xFFFF6B00),
      displayName: '7-Eleven',
    ),
    '113': BrandIcon(
      assetPath: 'assets/brands/7-eleven-logo.svg',
      color: Color(0xFFFF6B00),
      displayName: '7-Eleven',
    ),
    'freedom': BrandIcon(
      assetPath: 'assets/brands/freedom-logo.svg',
      color: Color(0xFF00AA00),
      displayName: 'Freedom',
    ),
    '110': BrandIcon(
      assetPath: 'assets/brands/freedom-logo.svg',
      color: Color(0xFF00AA00),
      displayName: 'Freedom',
    ),
    'united': BrandIcon(
      assetPath: 'assets/brands/united-logo.svg',
      color: Color(0xFFE20000),
      displayName: 'United',
    ),
    '23': BrandIcon(
      assetPath: 'assets/brands/united-logo.svg',
      color: Color(0xFFE20000),
      displayName: 'United',
    ),
    'ior': BrandIcon(
      assetPath: 'assets/brands/Ior-lorgo.svg',
      color: Color(0xFF003DA5),
      displayName: 'IOR',
    ),
    '3421075': BrandIcon(
      assetPath: 'assets/brands/Ior-lorgo.svg',
      color: Color(0xFF003DA5),
      displayName: 'IOR',
    ),
  };

  // Get brand icon by brand name or ID (case-insensitive)
  static BrandIcon getIconForBrand(String brand) {
    final lowerBrand = brand.toLowerCase().trim();

    // Direct match
    if (brandMap.containsKey(lowerBrand)) {
      return brandMap[lowerBrand]!;
    }

    // Partial match for common variations
    for (final entry in brandMap.entries) {
      if (lowerBrand.contains(entry.key.toLowerCase()) || 
          entry.key.toLowerCase().contains(lowerBrand)) {
        return entry.value;
      }
    }

    // Default to fuel icon if unknown
    return const BrandIcon(
      assetPath: 'assets/brands/default-fuel.svg',
      color: Color(0xFF035E50),
      displayName: 'Fuel Station',
    );
  }

  // Get all available brands
  static List<String> getAllBrands() => brandMap.keys.toList();
}

class BrandIcon {
  final String assetPath;
  final Color color;
  final String displayName;

  const BrandIcon({
    required this.assetPath,
    required this.color,
    required this.displayName,
  });
}
