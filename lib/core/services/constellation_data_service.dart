import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/constellation_model.dart';

class ConstellationDataService {
  static final ConstellationDataService _instance =
      ConstellationDataService._internal();
  
  List<Constellation>? _cachedConstellations;

  factory ConstellationDataService() {
    return _instance;
  }

  ConstellationDataService._internal();

  /// Loads all constellations from the local JSON asset.
  /// Returns a cached list if already loaded.
  Future<List<Constellation>> getAllConstellations() async {
    if (_cachedConstellations != null) {
      return _cachedConstellations!;
    }

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/constellations.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _cachedConstellations = jsonList
          .map((jsonItem) => Constellation.fromJson(jsonItem))
          .toList();

      return _cachedConstellations!;
    } catch (e) {
      // In a real app, we might want to log this error to a service
      // debugPrint('Error loading constellations: $e');
      throw Exception('Failed to load constellations data');
    }
  }

  /// Retrieves a specific constellation by its ID.
  Future<Constellation?> getConstellationById(String id) async {
    final constellations = await getAllConstellations();
    try {
      return constellations.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
