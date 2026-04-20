import 'package:flutter/material.dart';

class BrandIcons {
  // Map fuel brand names to icon data and brand colors
  static const Map<String, BrandIcon> brandMap = {
    'shell': BrandIcon(
      icon: Icons.local_gas_station,
      assetPath: 'assets/brands/shell.svg',
      color: Color(0xFFFFD700), // Gold
      displayName: 'Shell',
    ),
    'bp': BrandIcon(
      icon: Icons.local_gas_station,
      assetPath: 'assets/brands/bp.svg',
      color: Color(0xFF00AA44), // Green
      displayName: 'BP',
    ),
    'caltex': BrandIcon(
      icon: Icons.local_gas_station,
      assetPath: 'assets/brands/caltex.svg',
      color: Color(0xFFFF6B00), // Orange
      displayName: 'Caltex',
    ),
    'mobil': BrandIcon(
      icon: Icons.local_gas_station,
      assetPath: 'assets/brands/mobil.svg',
      color: Color(0xFFE20000), // Red
      displayName: 'Mobil',
    ),
    'ampol': BrandIcon(
      icon: Icons.local_gas_station,
      assetPath: 'assets/brands/ampol.svg',
      color: Color(0xFF0066CC), // Blue
      displayName: 'Ampol',
    ),
    'woolworths': BrandIcon(
      icon: Icons.local_gas_station,
      assetPath: 'assets/brands/woolworths.svg',
      color: Color(0xFF00AA00), // Green
      displayName: 'Woolworths',
    ),
    'aldi': BrandIcon(
      icon: Icons.local_gas_station,
      assetPath: 'assets/brands/aldi.svg',
      color: Color(0xFFCC0000), // Red
      displayName: 'ALDI',
    ),
    'costco': BrandIcon(
      icon: Icons.local_gas_station,
      assetPath: 'assets/brands/costco.svg',
      color: Color(0xFF003DA5), // Dark Blue
      displayName: 'Costco',
    ),
    '7-eleven': BrandIcon(
      icon: Icons.local_gas_station,
      assetPath: 'assets/brands/7eleven.svg',
      color: Color(0xFFFF6B00), // Orange
      displayName: '7-Eleven',
    ),
    '7eleven': BrandIcon(
      icon: Icons.local_gas_station,
      assetPath: 'assets/brands/7eleven.svg',
      color: Color(0xFFFF6B00), // Orange
      displayName: '7-Eleven',
    ),
    'independent': BrandIcon(
      icon: Icons.local_gas_station,
      assetPath: 'assets/brands/independent.svg',
      color: Color(0xFF666666), // Gray
      displayName: 'Independent',
    ),
  };

  // Get brand icon by brand name (case-insensitive)
  static BrandIcon getIconForBrand(String brand) {
    final lowerBrand = brand.toLowerCase().trim();

    // Direct match
    if (brandMap.containsKey(lowerBrand)) {
      return brandMap[lowerBrand]!;
    }

    // Partial match for common variations
    for (final entry in brandMap.entries) {
      if (lowerBrand.contains(entry.key) || entry.key.contains(lowerBrand)) {
        return entry.value;
      }
    }

    // Default to generic gas station icon
    return const BrandIcon(
      icon: Icons.local_gas_station,
      assetPath: 'assets/brands/independent.svg',
      color: Color(0xFF999999), // Light Gray
      displayName: 'Fuel Station',
    );
  }

  // Get all available brands
  static List<String> getAllBrands() => brandMap.keys.toList();
}

class BrandIcon {
  final IconData icon;
  final String assetPath;
  final Color color;
  final String displayName;

  const BrandIcon({
    required this.icon,
    required this.assetPath,
    required this.color,
    required this.displayName,
  });
}
