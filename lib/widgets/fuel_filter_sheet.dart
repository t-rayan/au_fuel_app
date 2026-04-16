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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF121212), // Sleek Dark Theme
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 45,
              height: 5,
              margin: const EdgeInsets.only(bottom: 25),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const Text(
            "FUEL TYPE",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Fuel Type Chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.fuelTypes.map((fuel) {
              bool isSelected = _selectedId == fuel.fuelId;
              return ChoiceChip(
                label: Text(fuel.name),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedId = fuel.fuelId),
                selectedColor: const Color(0xFFFFD700), // Yellow/Gold
                backgroundColor: Colors.grey[900],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),

          const SizedBox(height: 40),

          // --- THE APPLY BUTTON ---
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              onPressed: () {
                // For now, it just closes the sheet
                Navigator.pop(context, _selectedId);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Apply Filters",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, color: Colors.black, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
