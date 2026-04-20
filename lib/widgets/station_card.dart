import 'package:flutter/material.dart';
import '../models/fuel_station.dart';

class StationCard extends StatelessWidget {
  final FuelStation station;
  final VoidCallback onClose;

  const StationCard({
    super.key,
    required this.station,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Format price, handling QLD API 9999 out of stock fallback
    final String priceString = (station.price != null && station.price! < 9000)
        ? '\$${(station.price! / 1000).toStringAsFixed(2)}'
        : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Badge & Favorite Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF9FFB8D), // Light Neon Green
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3D2F),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.favorite_border, color: Color(0xFF135A74)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            station.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF212529),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Subtitle (Distance & Address)
          Text(
            '1.2 km • ${station.address}', // Mocked distance, use real if available
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6C757D),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // Bottom Row: Price & Go Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${station.brand}'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6C757D),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    priceString,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF035E50), // Dark Teal
                    ),
                  ),
                ],
              ),
              
              // Go Button
              ElevatedButton.icon(
                onPressed: () {
                  // Navigation integration here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF035E50), // Dark Teal
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.navigation, size: 20),
                label: const Text(
                  'Go',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
