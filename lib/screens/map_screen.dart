import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/fuel_station.dart';
import '../models/fuel_type.dart';
import '../widgets/station_card.dart';
import '../providers/fuel_provider.dart';
import '../providers/marker_provider.dart';
import '../providers/locality_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;

  static const LatLng _initialPosition = LatLng(-27.5750, 153.0850);

  @override
  void initState() {
    super.initState();
    _determinePosition();
    
    // Set default fuel ID once fuel types are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fuelTypes = await ref.read(fuelTypesProvider.future);
      if (fuelTypes.isNotEmpty && ref.read(selectedFuelIdProvider) == null) {
        ref.read(selectedFuelIdProvider.notifier).state = fuelTypes.first.fuelId;
      }
    });
  }

  Future<void> _zoomIn() async {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> _goToMyLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Could not get location: $e");
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;
    setState(() {});
  }

  Future<void> _loadMapStyle() async {
    final String style = await DefaultAssetBundle.of(context).loadString('assets/map_style.json');
    _mapController?.setMapStyle(style);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Observe State from Providers
    final markers = ref.watch(markerProvider);
    final fuelTypesAsync = ref.watch(fuelTypesProvider);
    final selectedFuelId = ref.watch(selectedFuelIdProvider);
    final selectedStation = ref.watch(selectedStationProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 130, // Increased for search bar
              bottom: selectedStation != null ? 220 : 20,
            ),
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 13.5,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: markers,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _loadMapStyle();
            },
            onTap: (_) => ref.read(selectedStationProvider.notifier).state = null,
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE9ECEF), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF212529)),
                          decoration: InputDecoration(
                            hintText: 'Search suburb or postcode...',
                            hintStyle: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 14, fontWeight: FontWeight.normal),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF0D4D44), size: 22),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref.read(searchQueryProvider.notifier).state = "";
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (val) {
                            ref.read(searchQueryProvider.notifier).state = val;
                          },
                        ),
                      ),
                      
                      // Suggestions Overlay
                      Builder(
                        builder: (context) {
                          final suggestions = ref.watch(localitySuggestionsProvider);
                          if (suggestions.isEmpty) return const SizedBox.shrink();
                          
                          return Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: suggestions.map((locality) => ListTile(
                                leading: const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF0D4D44)),
                                title: Text(
                                  locality.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Colors.black, // Explicit black as requested
                                  ),
                                ),
                                onTap: () {
                                  // 1. Mark as selected in state
                                  ref.read(selectedLocalityProvider.notifier).state = locality;
                                  
                                  // 2. Update search bar text
                                  _searchController.text = locality.displayName;
                                  ref.read(searchQueryProvider.notifier).state = locality.displayName;
                                  
                                  // 3. Move Camera to the selected locality
                                  _mapController?.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                      LatLng(locality.lat, locality.lng),
                                      13.0, // Zoom in to suburb level
                                    ),
                                  );

                                  FocusScope.of(context).unfocus();
                                },
                                dense: true,
                              )).toList(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // High-Contrast Fuel Filters
                fuelTypesAsync.when(
                  data: (types) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: types.map((fuel) {
                        final bool isSelected = selectedFuelId == fuel.fuelId;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(
                              fuel.name == 'Premium Diesel' ? 'PDiesel' : fuel.name,
                            ),
                            selected: isSelected,
                            onSelected: (val) {
                              if (!isSelected) {
                                ref.read(selectedFuelIdProvider.notifier).state = fuel.fuelId;
                              }
                            },
                            showCheckmark: false,
                            selectedColor: const Color(0xFF0D4D44),
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF495057),
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF0D4D44) : const Color(0xFFE9ECEF),
                                width: 1.5,
                              ),
                            ),
                            elevation: 0,
                            pressElevation: 0,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Loading Overlay (Bottom Center)
          ref.watch(fuelStationsProvider).when(
                loading: () => Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF035E50),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              "Finding best prices...",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF2C3E38),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                data: (_) => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

          // Custom Zoom and Location Controls (Middle Right)
          Positioned(
            right: 12,
            top: MediaQuery.of(context).size.height / 2 - 80,
            child: Column(
              children: [
                FloatingActionButton.small(
                  onPressed: _zoomIn,
                  backgroundColor: Colors.white,
                  heroTag: 'zoom_in',
                  child: const Icon(Icons.add, color: Color(0xFF2C3E38)),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  onPressed: _zoomOut,
                  backgroundColor: Colors.white,
                  heroTag: 'zoom_out',
                  child: const Icon(Icons.remove, color: Color(0xFF2C3E38)),
                ),
                const SizedBox(height: 16),
                FloatingActionButton.small(
                  onPressed: _goToMyLocation,
                  backgroundColor: Colors.white,
                  heroTag: 'my_location',
                  child: const Icon(Icons.my_location, color: Colors.blueAccent),
                ),
              ],
            ),
          ),

          // Custom Overlay Card (Bottom Center)
          if (selectedStation != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: StationCard(
                station: selectedStation,
                onClose: () => ref.read(selectedStationProvider.notifier).state = null,
              ),
            ),
        ],
      ),
    );
  }
}
