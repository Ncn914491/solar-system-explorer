import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/apod_model.dart';

/// Service for caching APOD data and images locally
class ApodCacheService {
  static const String _cacheKey = 'apod_cached_data';
  static const String _cacheTimestampKey = 'apod_cache_timestamp';
  static const String _imageCacheKey = 'apod_cached_image_base64';
  static const String _imageUrlKey = 'apod_cached_image_url';

  /// Saves APOD data to local cache
  Future<void> cacheApodData(ApodModel apod) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(apod.toJson());
      await prefs.setString(_cacheKey, jsonString);
      await prefs.setInt(
          _cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);

      // Also cache the image if it's an image type
      if (apod.mediaType == 'image') {
        await _cacheImage(apod.url);
      }
    } catch (e) {
      // Silently fail - caching is optional
      debugPrint('Failed to cache APOD data: $e');
    }
  }

  /// Downloads and caches the image as base64
  Future<void> _cacheImage(String imageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we already have this image cached
      final cachedUrl = prefs.getString(_imageUrlKey);
      if (cachedUrl == imageUrl) {
        debugPrint('Image already cached for URL: $imageUrl');
        return;
      }

      // Use CORS proxy on web
      String fetchUrl = imageUrl;
      if (kIsWeb) {
        fetchUrl =
            'https://api.allorigins.win/raw?url=${Uri.encodeComponent(imageUrl)}';
      }

      debugPrint('Caching APOD image from: $fetchUrl');

      final response = await http.get(Uri.parse(fetchUrl)).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Image download timeout');
        },
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final base64Image = base64Encode(bytes);

        // Store the base64 image and the original URL
        await prefs.setString(_imageCacheKey, base64Image);
        await prefs.setString(_imageUrlKey, imageUrl);

        debugPrint('Successfully cached APOD image (${bytes.length} bytes)');
      } else {
        debugPrint('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to cache APOD image: $e');
      // Don't throw - image caching failure is not critical
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
      debugPrint('Failed to load cached APOD: $e');
      return null;
    }
  }

  /// Returns cached image as bytes, or null if not available
  Future<Uint8List?> getCachedImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64Image = prefs.getString(_imageCacheKey);

      if (base64Image == null || base64Image.isEmpty) {
        return null;
      }

      return base64Decode(base64Image);
    } catch (e) {
      debugPrint('Failed to load cached image: $e');
      return null;
    }
  }

  /// Returns the URL of the cached image
  Future<String?> getCachedImageUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_imageUrlKey);
    } catch (e) {
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

  /// Checks if cached image exists
  Future<bool> hasCachedImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_imageCacheKey);
  }

  /// Clears cached APOD data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
      await prefs.remove(_imageCacheKey);
      await prefs.remove(_imageUrlKey);
    } catch (e) {
      debugPrint('Failed to clear APOD cache: $e');
    }
  }
}
