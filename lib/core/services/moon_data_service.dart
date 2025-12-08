import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/moon_model.dart';

/// Service for loading and accessing moon data.
class MoonDataService {
  static final MoonDataService _instance = MoonDataService._internal();
  factory MoonDataService() => _instance;
  MoonDataService._internal();

  List<Moon>? _cachedMoons;

  /// Loads all moons from the local JSON file.
  Future<List<Moon>> getAllMoons() async {
    if (_cachedMoons != null) {
      return _cachedMoons!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/moons.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedMoons = jsonList.map((json) => Moon.fromJson(json)).toList();
      return _cachedMoons!;
    } catch (e) {
      print('Error loading moons: $e');
      return [];
    }
  }

  /// Gets a moon by its ID.
  Future<Moon?> getMoonById(String id) async {
    final moons = await getAllMoons();
    try {
      return moons.firstWhere((moon) => moon.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Gets all moons for a specific planet.
  Future<List<Moon>> getMoonsForPlanet(String planetId) async {
    final moons = await getAllMoons();
    return moons.where((moon) => moon.planetId == planetId).toList();
  }

  /// Clears the cache.
  void clearCache() {
    _cachedMoons = null;
  }
}
