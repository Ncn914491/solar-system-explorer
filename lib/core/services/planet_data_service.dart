import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/planet_model.dart';

/// Service responsible for loading planet data from local assets.
class PlanetDataService {
  static const String _dataPath = 'assets/data/planets.json';

  List<Planet> _planets = [];

  /// Loads planets from the JSON asset.
  /// Returns the list of planets.
  Future<List<Planet>> getAllPlanets() async {
    if (_planets.isNotEmpty) return _planets;

    try {
      final String response = await rootBundle.loadString(_dataPath);
      final List<dynamic> data = jsonDecode(response);

      _planets = data.map((json) => Planet.fromJson(json)).toList();
      return _planets;
    } catch (e) {
      // In a real app, we might log this to a crash reporting service
      // In a real app, we might log this to a crash reporting service
      debugPrint('Error loading planet data: $e');
      // Return empty list or rethrow depending on requirements.
      // Prompt says "handle and report errors gracefully", but "expect it to succeed".
      // Returning empty list might be safer for UI than crashing, but rethrowing allows UI to show error.
      // Given "report errors gracefully", I'll print and rethrow so the caller knows something went wrong.
      throw Exception('Failed to load planet data: $e');
    }
  }

  /// Gets a planet by its ID.
  /// Returns null if not found.
  Future<Planet?> getPlanetById(String id) async {
    if (_planets.isEmpty) {
      await getAllPlanets();
    }
    try {
      return _planets.firstWhere((planet) => planet.id == id);
    } catch (e) {
      return null;
    }
  }
}
