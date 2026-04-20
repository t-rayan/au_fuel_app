import 'package:flutter/material.dart';
import '../models/fuel_type.dart';

class FuelFilterSheet extends StatefulWidget {
  final List<FuelType> fuelTypes;
  final int? currentFuelId;

  const FuelFilterSheet({
    super.key,
    required this.fuelTypes,
    required this.currentFuelId,
  });

  @override
  State<FuelFilterSheet> createState() => _FuelFilterSheetState();
}

class _FuelFilterSheetState extends State<FuelFilterSheet> {
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.currentFuelId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      // Make it match Google Maps bottom sheet styling
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFDADCE0), // Google Maps generic grey handle
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filter by Fuel Type",
                style: TextStyle(
                  color: Color(0xFF202124), // Google dark grey
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF5F6368)),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 16),

          // Fuel Type Chips
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: widget.fuelTypes.map((fuel) {
              bool isSelected = _selectedId == fuel.fuelId;
              return ChoiceChip(
                label: Text(fuel.name),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedId = fuel.fuelId),
                selectedColor: const Color(0xFFE8F0FE), // Google Maps light blue selection
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF1967D2) : const Color(0xFF3C4043),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF1A73E8) : const Color(0xFFDADCE0),
                    width: 1,
                  ),
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),

          const SizedBox(height: 30),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8), // Google Blue
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context, _selectedId),
              child: const Text(
                "Show results",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
