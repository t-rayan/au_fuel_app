import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/locality.dart';

class LocalityService {
  /// Loads the localities dataset from assets in a background isolate.
  static Future<List<Locality>> loadLocalities() async {
    try {
      // Step 1: Load raw JSON string from assets
      final jsonString = await rootBundle.loadString('assets/data/localities.json');
      
      // Step 2: Use 'compute' to offload parsing to a background thread.
      // This prevents the UI from freezing while processing thousands of entries.
      return await compute(_parseJson, jsonString);
    } catch (e) {
      debugPrint("Error loading local locality data: $e");
      return [];
    }
  }

  /// Pure function for isolate processing
  static List<Locality> _parseJson(String raw) {
    final List<dynamic> data = jsonDecode(raw);
    return data.map((item) => Locality.fromJson(item)).toList();
  }
}
