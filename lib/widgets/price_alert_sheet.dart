import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/price_alerts_provider.dart';

class PriceAlertSheet extends ConsumerStatefulWidget {
  final String stationId;
  final String stationName;
  final String fuelType;
  final double currentPrice;

  const PriceAlertSheet({
    super.key,
    required this.stationId,
    required this.stationName,
    required this.fuelType,
    required this.currentPrice,
  });

  @override
  ConsumerState<PriceAlertSheet> createState() => _PriceAlertSheetState();
}

class _PriceAlertSheetState extends ConsumerState<PriceAlertSheet> {
  late double _targetPrice;

  @override
  void initState() {
    super.initState();
    // Default target to 5 cents below current price
    _targetPrice = widget.currentPrice - 50.0; 
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Alert',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E3D2F),
                ),
              ),
              const Icon(Icons.notifications_active, color: Color(0xFF0D4D44)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Notify me when ${widget.fuelType} drops below your target at ${widget.stationName}.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          
          Center(
            child: Column(
              children: [
                Text(
                  '${(_targetPrice / 1000).toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0D4D44),
                  ),
                ),
                Text(
                  'CENTS PER LITRE',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black26,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Slider(
            value: _targetPrice,
            min: widget.currentPrice - 500, // Up to 50 cents below
            max: widget.currentPrice,
            divisions: 50,
            activeColor: const Color(0xFF0D4D44),
            inactiveColor: Colors.black12,
            onChanged: (val) => setState(() => _targetPrice = val),
          ),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(priceAlertsProvider.notifier).setAlert(
                  stationId: widget.stationId,
                  fuelType: widget.fuelType,
                  targetPrice: _targetPrice,
                );
                if (mounted) Navigator.pop(context);
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alert Set! We\'ll watch the prices for you.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D4D44),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                'Create Alert',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
