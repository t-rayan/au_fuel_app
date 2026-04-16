import 'package:au_fuel/models/fuel_type.dart';
import 'package:au_fuel/widgets/fuel_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/fuel_service.dart';
import '../models/fuel_station.dart';

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

  // Coordinates for Eight Mile Plains / Wishart area
  static const LatLng _initialPosition = LatLng(-27.5750, 153.0850);
  @override
  void initState() {
    super.initState();
    // Trigger the check as soon as the widget is created
    _determinePosition();
    // _loadFuelMarkers();
    _initialFuelData(); // Call the API to load fuel types (currently just prints to console)
  }

  Future<void> _initialFuelData() async {
    final fuelTypeData = await _fuelService.getFuelTypes();
    setState(() {
      _allFuelTypes = fuelTypeData;
      if (_allFuelTypes.isNotEmpty) {
        _selectedFuelId =
            _allFuelTypes.first.fuelId; // Default to first fuel type
      }
    });
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

  // Future<void> _loadFuelMarkers() async {
  //   List<FuelStation> stations = await _fuelService.loadStationsFromAssets();
  //   setState(() {
  //     _markers = stations.map((station) {
  //       return Marker(
  //         markerId: MarkerId(station.siteId.toString()),
  //         position: LatLng(station.lat, station.lng),
  //         infoWindow: InfoWindow(
  //           title: station.name,
  //           snippet: '${station.brand}: ${station.price}¢',
  //         ),
  //       );
  //     }).toSet();
  //   });
  // }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FuelFilterSheet(
        fuelTypes: _allFuelTypes,
        currentFuelId: _selectedFuelId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Au Fuel Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Fuel Type',
            onPressed: () {
              _openFilters();
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _initialPosition,
          zoom: 14.0,
        ),
        // This makes the map interactive
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _markers,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          // You can use the controller to move the camera later
        },
      ),
    );
  }
}
