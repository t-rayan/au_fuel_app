import 'dart:convert';
import 'package:au_fuel/core/api_config.dart';
import 'package:au_fuel/models/fuel_price.dart';
import 'package:au_fuel/models/fuel_site.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/fuel_station.dart';

import '../models/fuel_type.dart';

class FuelService {
  Future<List<FuelStation>> getRealTimeData(int selectedFuelId) async {
    try {
      final sitesUrl = Uri.parse(
        "${ApiConfig.baseUrl}/Subscriber/GetFullSiteDetails?countryId=21&geoRegionLevel=3&geoRegionId=1",
      );
      final pricesUrl = Uri.parse(
        "${ApiConfig.baseUrl}/Price/GetSitesPrices?countryId=21&geoRegionLevel=3&geoRegionId=1",
      );

      // Perform both requests
      final responses = await Future.wait([
        http.get(sitesUrl, headers: ApiConfig.headers),
        http.get(pricesUrl, headers: ApiConfig.headers),
      ]);

      final sitesResponse = responses[0];
      final pricesResponse = responses[1];

      if (sitesResponse.statusCode == 200 && pricesResponse.statusCode == 200) {
        final sitesData = json.decode(sitesResponse.body);
        final pricesData = json.decode(pricesResponse.body);

        // 2. PASS the lists and the selected ID to the merge function
        // Note: QLD API typically wraps the list in keys like 'S' (Sites) and 'SitePrices'
        return _mergeSitesAndPrices(
          sitesData['S'] ?? [],
          pricesData['SitePrices'] ?? [],
          selectedFuelId,
        );
      } else {
        throw Exception("API Error");
      }
    } catch (e) {
      debugPrint("Error fetching fuel data: $e");
      return [];
    }
  }

  List<FuelStation> _mergeSitesAndPrices(
    List<dynamic> sitesJson,
    List<dynamic> pricesJson,
    int selectedFuelId,
  ) {
    // 3. Convert JSON to Model Lists first
    final List<FuelSite> sites = sitesJson
        .map((s) => FuelSite.fromJson(s))
        .toList();
    final List<FuelPrice> prices = pricesJson
        .map((p) => FuelPrice.fromJson(p))
        .toList();

    // 4. Filter prices to ONLY the fuel type the user wants
    final filteredPrices = prices
        .where((p) => p.fuelId == selectedFuelId)
        .toList();

    // 5. Map SiteId -> Price for O(1) instant lookup
    final priceMap = {for (var p in filteredPrices) p.siteId: p};

    // 6. Create the final FuelStation list
    return sites
        .map((site) {
          final priceData = priceMap[site.siteId];

          return FuelStation(
            siteId: site.siteId,
            name: site.name,
            brand: site.brand,
            address: site.address,
            lat: site.lat,
            lng: site.lng,
            price: priceData?.price,
            lastUpdated: priceData?.lastUpdated,
          );
        })
        .where((station) => station.price != null)
        .toList();
  }

  Future<List<FuelType>> getFuelTypes() async {
    final fuelTypesUrl =
        '${ApiConfig.baseUrl}/Subscriber/GetCountryFuelTypes?countryId=21';

    try {
      final response = await http.get(
        Uri.parse(fuelTypesUrl),
        headers: ApiConfig.headers,
      );
      debugPrint("🔥 RESPONSECODE: Data received: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> fuelList = data['Fuels'];

        // Desired IDs and Names mapping for Australian popular fuels
        const Map<int, String> popularFuels = {
          2: '91',
          12: 'E10',
          5: 'U95',
          8: 'U98',
          3: 'Diesel',
          14: 'Premium Diesel',
          4: 'LPG',
        };

        List<FuelType> parsedFuels = [];
        for (var item in fuelList) {
          int id = item['FuelId'];
          if (popularFuels.containsKey(id)) {
            parsedFuels.add(FuelType(fuelId: id, name: popularFuels[id]!));
          }
        }
        return parsedFuels;
      } else {
        debugPrint(
          "CODEOFERROR: Failed to load fuel types. Status code: ${response.statusCode}",
        );
        return [];
      }
    } catch (e) {
      debugPrint("CODEOFERROR: Error loading fuel types: $e");
      return [];
    }
  }
}
