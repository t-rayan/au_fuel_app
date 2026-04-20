import 'package:au_fuel/models/fuel_type.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/fuel_service.dart';
import '../models/fuel_station.dart';
import '../utils/marker_generator.dart';
import '../widgets/station_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FuelService _fuelService = FuelService();

  // state variables
  Set<Marker> _markers = {};
  List<FuelType> _allFuelTypes = [];
  int? _selectedFuelId; // Maps fuelId to fuel name for easy lookup
  FuelStation? _selectedStation; // Track currently tapped marker
  List<FuelStation> _cachedStations = []; // Fixes UI lag
  Map<String, BitmapDescriptor> _priceMarkerCache =
      {}; // Fixes OOM memory crashes & rendering lag

  String _getFormattedPrice(FuelStation station) {
    return (station.price != null && station.price! < 9000)
        ? '\$${(station.price! / 1000).toStringAsFixed(2)}'
        : 'N/A';
  }

  bool _isLoading = true; // Tracks background processing for UI feedback
  final TextEditingController _searchController =
      TextEditingController(); // Search interactions
  String _searchQuery = ""; // Current search filter
  GoogleMapController?
  _mapController; // Map tracking for custom location panning

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

  // Coordinates for Eight Mile Plains / Wishart area
  static const LatLng _initialPosition = LatLng(-27.5750, 153.0850);
  @override
  void initState() {
    super.initState();
    // Trigger the check as soon as the widget is created
    _determinePosition();
    _initialFuelData(); // Call the API to load fuel types (currently just prints to console)
  }

  Future<void> _initialFuelData() async {
    debugPrint("🔥 STEP: Calling getFuelTypes()");

    final fuelTypeData = await _fuelService.getFuelTypes();
    debugPrint("🔥 STEP: Data received: ${fuelTypeData.length}");

    setState(() {
      _allFuelTypes = fuelTypeData;
      if (_allFuelTypes.isNotEmpty) {
        _selectedFuelId =
            _allFuelTypes.first.fuelId; // Default to first fuel type
      }
    });

    if (_selectedFuelId != null) {
      _loadFuelMarkers(); // Load markers for the default fuel type
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Direct the user to turn on their GPS
      return Future.error('Location services are disabled.');
    }

    // 2. Check current permission status
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // 3. THIS IS THE STEP THAT SHOWS THE POPUP
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // The user tapped "Don't ask again" - they must go to settings manually
      return Future.error('Location permissions are permanently denied.');
    }

    // 4. If we get here, permissions are granted!
    // Calling setState tells the GoogleMap widget to redraw and show the blue dot.
    setState(() {});
  }

  void _clearSelection() {
    if (_selectedStation != null) {
      final oldStation = _selectedStation!;
      setState(() {
        _selectedStation = null;
        final String oldPriceStr = _getFormattedPrice(oldStation);
        final String oldCacheKey =
            '${oldPriceStr}_${oldStation.brand}'; // Include brand in cache key
        if (_priceMarkerCache.containsKey(oldCacheKey)) {
          _markers.removeWhere(
            (m) => m.markerId.value == oldStation.siteId.toString(),
          );
          _markers.add(
            Marker(
              markerId: MarkerId(oldStation.siteId.toString()),
              position: LatLng(oldStation.lat, oldStation.lng),
              icon: _priceMarkerCache[oldCacheKey]!,
              onTap: () => _onMarkerTapped(oldStation),
            ),
          );
        }
      });
    }
  }

  Future<void> _onMarkerTapped(FuelStation newStation) async {
    final oldStation = _selectedStation;

    // Draw the new highlighted pin instantly
    final String priceString = _getFormattedPrice(newStation);
    final BitmapDescriptor highlightedIcon =
        await MarkerGenerator.createPriceMarker(priceString, isSelected: true);

    setState(() {
      _selectedStation = newStation;

      // Bring old station back to normal cached state
      if (oldStation != null && oldStation.siteId != newStation.siteId) {
        final String oldPriceStr = _getFormattedPrice(oldStation);
        final String oldCacheKey =
            '${oldPriceStr}_${oldStation.brand}'; // Include brand in cache key
        if (_priceMarkerCache.containsKey(oldCacheKey)) {
          _markers.removeWhere(
            (m) => m.markerId.value == oldStation.siteId.toString(),
          );
          _markers.add(
            Marker(
              markerId: MarkerId(oldStation.siteId.toString()),
              position: LatLng(oldStation.lat, oldStation.lng),
              icon: _priceMarkerCache[oldCacheKey]!,
              onTap: () => _onMarkerTapped(oldStation),
            ),
          );
        }
      }

      // Highlight tapped station and bring to front
      _markers.removeWhere(
        (m) => m.markerId.value == newStation.siteId.toString(),
      );
      _markers.add(
        Marker(
          markerId: MarkerId(newStation.siteId.toString()),
          position: LatLng(newStation.lat, newStation.lng),
          icon: highlightedIcon,
          zIndex: 1.0,
          onTap: () => _onMarkerTapped(newStation),
        ),
      );
    });
  }

  Future<void> _loadFuelMarkers() async {
    final bool isNetworkHit = _cachedStations.isEmpty;

    if (isNetworkHit) {
      // Instantly wipe map and show loader ONLY when hitting network
      setState(() {
        _isLoading = true;
        _markers.clear();
        _selectedStation = null;
      });
      _cachedStations = await _fuelService.getRealTimeData(_selectedFuelId!);
    }

    Set<Marker> newMarkers = {};

    for (var station in _cachedStations) {
      // Fast RAM filtering based on search bar
      if (_searchQuery.isNotEmpty) {
        final matchesName = station.name.toLowerCase().contains(_searchQuery);
        final matchesAddress = station.address.toLowerCase().contains(
          _searchQuery,
        );
        final matchesBrand = station.brand.toLowerCase().contains(_searchQuery);
        if (!matchesName && !matchesAddress && !matchesBrand) continue;
      }
      final bool isSelected = _selectedStation?.siteId == station.siteId;

      BitmapDescriptor customIcon;

      if (isSelected) {
        // Render selected specifically on demand
        final String priceString = _getFormattedPrice(station);
        customIcon = await MarkerGenerator.createPriceMarker(
          priceString,
          isSelected: true,
        );
      } else {
        // Cache globally by the rendered text rather than by the unique site ID to save 95% of memory and CPU
        final String priceString = _getFormattedPrice(station);
        final String cacheKey = priceString;
        if (_priceMarkerCache.containsKey(cacheKey)) {
          customIcon = _priceMarkerCache[cacheKey]!;
        } else {
          customIcon = await MarkerGenerator.createPriceMarker(
            priceString,
            isSelected: false,
          );
          _priceMarkerCache[cacheKey] = customIcon;
        }
      }

      newMarkers.add(
        Marker(
          markerId: MarkerId(station.siteId.toString()),
          position: LatLng(station.lat, station.lng),
          icon: customIcon,
          onTap: () => _onMarkerTapped(station),
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
      _isLoading = false; // Hide loader
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            // Shifts Google's internal UI controls (like My Location) down to avoid the Search Bar and Chips
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 120,
            ),
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            // This makes the map interactive
            myLocationEnabled: true,
            myLocationButtonEnabled:
                false, // Turned off to use our custom bottom-right layout
            zoomControlsEnabled:
                true, // Native zoom controls usually sit at the bottom right
            markers: _markers,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onTap: (_) => _clearSelection(),
          ),

          // Top UI Overlay (Search Bar + Filter Chips)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Search brand or suburb...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF035E50),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = "");
                                  _loadFuelMarkers();
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        setState(() => _searchQuery = val.toLowerCase());
                        _loadFuelMarkers(); // Fast RAM redraw
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Horizontal scrollable fuel filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _allFuelTypes.map((fuel) {
                      final bool isSelected = _selectedFuelId == fuel.fuelId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            fuel.name == 'Premium Diesel'
                                ? 'PDiesel'
                                : fuel.name,
                          ),
                          selected: isSelected,
                          onSelected: (val) {
                            if (!isSelected) {
                              setState(() {
                                _selectedFuelId = fuel.fuelId;
                                _cachedStations = []; // force network load
                                _priceMarkerCache.clear();
                              });
                              _loadFuelMarkers();
                            }
                          },
                          showCheckmark: false,
                          selectedColor: const Color(0xFF035E50),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF3C4043),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF035E50)
                                  : const Color(0xFFDADCE0),
                              width: 1,
                            ),
                          ),
                          elevation: 2,
                          pressElevation: 0,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                ),
                child: const Card(
                  elevation: 4,
                  shape: StadiumBorder(),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF035E50),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Locating stations...",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E38),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Custom Overlay Card replacing default infoWindow
          if (_selectedStation != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: StationCard(
                station: _selectedStation!,
                onClose: _clearSelection,
              ),
            ),

          // Custom Location Button specifically hovering above zoom controls
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            bottom: _selectedStation != null
                ? 180
                : 120, // Moves up cleanly when the StationCard opens
            right: 12,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _goToMyLocation,
              elevation: 4,
              heroTag: 'my_location',
              child: const Icon(Icons.my_location, color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }
}
