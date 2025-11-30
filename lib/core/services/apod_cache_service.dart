import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/apod_model.dart';

/// Service for caching APOD data locally
class ApodCacheService {
  static const String _cacheKey = 'apod_cached_data';
  static const String _cacheTimestampKey = 'apod_cache_timestamp';

  /// Saves APOD data to local cache
  Future<void> cacheApodData(ApodModel apod) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(apod.toJson());
      await prefs.setString(_cacheKey, jsonString);
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silently fail - caching is optional
      print('Failed to cache APOD data: $e');
    }
  }

  /// Retrieves cached APOD data if available
  Future<ApodModel?> getCachedApod() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);
      
      if (jsonString == null) {
        return null;
      }

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return ApodModel.fromJson(jsonData);
    } catch (e) {
      print('Failed to load cached APOD: $e');
      return null;
    }
  }

  /// Returns the timestamp when APOD was last cached
  Future<DateTime?> getCacheTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);
      
      if (timestamp == null) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return null;
    }
  }

  /// Checks if cached data exists
  Future<bool> hasCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_cacheKey);
  }

  /// Clears cached APOD data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
    } catch (e) {
      print('Failed to clear APOD cache: $e');
    }
  }
}
