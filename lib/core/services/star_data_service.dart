import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/star_model.dart';

class StarDataService {
  static final StarDataService _instance = StarDataService._internal();
  
  List<Star>? _cachedStars;

  factory StarDataService() {
    return _instance;
  }

  StarDataService._internal();

  /// Loads all stars from the local JSON asset.
  /// Returns a cached list if already loaded.
  Future<List<Star>> getAllStars() async {
    if (_cachedStars != null) {
      return _cachedStars!;
    }

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/stars.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _cachedStars = jsonList
          .map((jsonItem) => Star.fromJson(jsonItem))
          .toList();

      return _cachedStars!;
    } catch (e) {
      throw Exception('Failed to load star catalog data: $e');
    }
  }

  /// Returns stars visible to the naked eye (magnitude <= maxMagnitude)
  /// Typical naked eye limit is magnitude ~6.0
  Future<List<Star>> getStarsByMagnitude(double maxMagnitude) async {
    final stars = await getAllStars();
    return stars.where((star) => star.magnitude <= maxMagnitude).toList();
  }

  /// Returns all stars in a specific constellation
  Future<List<Star>> getStarsInConstellation(String constellationName) async {
    final stars = await getAllStars();
    return stars
        .where((star) =>
            star.constellation?.toLowerCase() ==
            constellationName.toLowerCase())
        .toList();
  }

  /// Returns the brightest N stars
  Future<List<Star>> getBrightestStars(int count) async {
    final stars = await getAllStars();
    final sorted = List<Star>.from(stars)
      ..sort((a, b) => a.magnitude.compareTo(b.magnitude));
    return sorted.take(count).toList();
  }

  /// Clears the cache if needed (useful for testing or memory management)
  void clearCache() {
    _cachedStars = null;
  }
}
