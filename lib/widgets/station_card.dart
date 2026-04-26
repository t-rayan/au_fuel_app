import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/fuel_station.dart';
import '../providers/favorites_provider.dart';
import '../providers/fuel_provider.dart';
import 'price_alert_sheet.dart';

class StationCard extends ConsumerWidget {
  final FuelStation station;
  final VoidCallback onClose;

  const StationCard({
    super.key,
    required this.station,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Check if this station is favorited
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(station.siteId.toString());

    // Format price
    final String priceString = (station.price != null && station.price! < 9000)
        ? (station.price! / 1000).toStringAsFixed(2)
        : 'N/A';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Accent Bar
            Container(
              height: 6,
              width: double.infinity,
              color: const Color(0xFF0D4D44),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          station.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E3D2F),
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          // 3. Price Alert Button (Bell)
                          IconButton(
                            onPressed: () {
                              final fuelTypes = ref.read(fuelTypesProvider).value ?? [];
                              final fuelId = ref.read(selectedFuelIdProvider);
                              final fuelName = fuelTypes.firstWhere((f) => f.fuelId == fuelId, orElse: () => fuelTypes.first).name;

                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => PriceAlertSheet(
                                  stationId: station.siteId.toString(),
                                  stationName: station.name,
                                  fuelType: fuelName,
                                  currentPrice: station.price ?? 0.0,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Color(0xFFADB5BD),
                            ),
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 4),
                          // The Heart Button
                          IconButton(
                            onPressed: () => ref.read(favoritesProvider.notifier).toggleFavorite(station.siteId.toString()),
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : const Color(0xFFADB5BD),
                            ),
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: onClose,
                            icon: const Icon(Icons.close, color: Color(0xFFADB5BD)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xFF0D4D44)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          station.address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6C757D),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Price per litre',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                priceString,
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0D4D44),
                                  letterSpacing: -1.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'CENTS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0D4D44),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _buildNavButton(station),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(FuelStation station) {
    return GestureDetector(
      onTap: () async {
        final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=${station.lat},${station.lng}&travelmode=driving';
        final Uri uri = Uri.parse(googleMapsUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D4D44),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D4D44).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.directions, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Navigate',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
