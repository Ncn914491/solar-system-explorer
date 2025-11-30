import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nasa_image_model.dart';

class NasaImageService {
  static const String _baseUrl = 'https://images-api.nasa.gov';

  /// Searches for images related to the query (e.g., planet name).
  /// Returns a list of [NasaImageModel].
  Future<List<NasaImageModel>> searchImages(String query) async {
    final cacheKey = 'nasa_images_$query';
    final prefs = await SharedPreferences.getInstance();

    // Helper to parse JSON
    List<NasaImageModel> parseData(Map<String, dynamic> data) {
      final List<dynamic> items = data['collection']?['items'] ?? [];
      return items
          .map((item) => NasaImageModel.fromJson(item))
          .where((image) => image.thumbnailUrl.isNotEmpty)
          .toList();
    }

    try {
      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
        'q': query,
        'media_type': 'image',
        'page': '1',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Cache the successful response
        await prefs.setString(cacheKey, response.body);
        
        final Map<String, dynamic> data = jsonDecode(response.body);
        return parseData(data);
      } else {
        throw Exception('Failed to load images: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error searching NASA images (network): $e');
      
      // Try to load from cache
      if (prefs.containsKey(cacheKey)) {
        debugPrint('Loading NASA images from cache for $query');
        final cachedData = prefs.getString(cacheKey);
        if (cachedData != null) {
          try {
            final Map<String, dynamic> data = jsonDecode(cachedData);
            return parseData(data);
          } catch (cacheError) {
            debugPrint('Error parsing cached data: $cacheError');
          }
        }
      }
      
      // If no cache or cache failed, rethrow
      throw Exception('Error searching NASA images and no offline cache: $e');
    }
  }

  /// Fetches the actual full-size image URL from the collection JSON URL.
  /// The [collectionUrl] comes from [NasaImageModel.fullImageUrl].
  Future<String?> getOriginalImageUrl(String collectionUrl) async {
    try {
      // The collection URL points to a JSON array of URLs for different sizes
      // e.g. ["http...~orig.jpg", "http...~medium.jpg", ...]
      // We want to find 'orig' or 'large' or 'medium'.
      // Note: The collection URL might be http, we should ensure we can handle it.
      // NASA assets often use http.
      
      final response = await http.get(Uri.parse(collectionUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> urls = jsonDecode(response.body);
        // Prefer 'orig' or 'large'
        // The list is usually strings.
        
        // Simple strategy: look for 'orig.jpg' or 'large.jpg'
        String? bestUrl;
        
        // Sort of priority: orig > large > medium > small
        for (var url in urls) {
          final u = url.toString();
          if (u.contains('~orig')) return u;
          if (u.contains('~large')) bestUrl = u;
          if (bestUrl == null && u.contains('~medium')) bestUrl = u;
        }
        
        return bestUrl ?? (urls.isNotEmpty ? urls.first.toString() : null);
      }
    } catch (e) {
      // If we fail, just return null, UI will fallback to thumbnail
      debugPrint('Error fetching original image URL: $e');
    }
    return null;
  }
}
