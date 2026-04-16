import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../themes/vault_colors.dart';

class KineticMap extends StatelessWidget {
  const KineticMap({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        // Centered on Brisbane / Eight Mile Plains area
        initialCenter: const LatLng(-27.4698, 153.0251),
        initialZoom: 13,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // 1. THE DARK TILE LAYER
        // This provider gives the charcoal "Uber" look.
        TileLayer(
          urlTemplate:
              'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.bnepulse.app',
        ),

        // 2. THE ATMOSPHERIC OVERLAY (Optional)
        // Adds a 10% tint of your Vault Surface to make the map feel "housed"
        IgnorePointer(
          child: Container(color: VaultColors.surface.withOpacity(0.1)),
        ),

        // 3. MARKER LAYER (We will add your fuel prices here next)
        const MarkerLayer(markers: []),
      ],
    );
  }
}
