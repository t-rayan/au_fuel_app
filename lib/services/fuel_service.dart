import 'dart:convert';
import 'package:au_fuel/core/api_config.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/fuel_station.dart';
import '../models/fuel_type.dart';

class FuelService {
  final String authToken = 'f477b753-ce77-4aac-8b50-b72775f3fbc4';
  final String fuelTypesUrl =
      'https://fppdirectapi-prod.fuelpricesqld.com.au/Subscriber/GetCountryFuelTypes?countryId=21';

  Future<List<FuelStation>> getRealTimeData() async {
    try {
      // 1. Fetch Site Details
      final sitesUrl = Uri.parse(
        "${ApiConfig.baseUrl}/Subscriber/GetFullSiteDetails?countryId=21&geoRegionLevel=3&geoRegionId=1",
      );
      final sitesResponse = await http.get(
        sitesUrl,
        headers: ApiConfig.headers,
      );

      // 2. Fetch Prices
      final pricesUrl = Uri.parse(
        "${ApiConfig.baseUrl}/Price/GetSitesPrices?countryId=21&geoRegionLevel=3&geoRegionId=1",
      );
      final pricesResponse = await http.get(
        pricesUrl,
        headers: ApiConfig.headers,
      );

      if (sitesResponse.statusCode == 200 && pricesResponse.statusCode == 200) {
        final sitesData = json.decode(sitesResponse.body);
        final pricesData = json.decode(pricesResponse.body);

        // This is where we will "Merge" the two lists based on SiteId
        return _mergeSitesAndPrices(sitesData, pricesData);
      } else {
        throw Exception("API Error: ${sitesResponse.statusCode}");
      }
    } catch (e) {
      print("Error fetching fuel data: $e");
      return []; // Return empty list on failure to prevent app crash
    }
  }

  List<FuelStation> _mergeSitesAndPrices(
    dynamic sitesJson,
    dynamic pricesJson,
  ) {
    // We will implement the merge logic here next!
    return [];
  }

  // This function returns a List of our Model objects

  // this function loads fuel types from the API and returns a list of FuelType objects

  Future<List<FuelType>> getFuelTypes() async {
    try {
      final response = await http.get(
        Uri.parse(fuelTypesUrl),
        headers: {
          'Authorization': 'FPDAPI SubscriberToken=$authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("Fuel types loaded successfully!");
        final data = json.decode(response.body);
        List<dynamic> fuelList = data['Fuels'];
        return fuelList.map((json) => FuelType.fromAPI(json)).toList();
      } else {
        print("Failed to load fuel types. Status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error loading fuel types: $e");
      return [];
    }
  }
}
