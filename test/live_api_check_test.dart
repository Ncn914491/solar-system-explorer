// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_system_explorer/core/services/nasa_api_service.dart';
import 'package:solar_system_explorer/core/models/apod_model.dart';
import 'package:solar_system_explorer/core/constants/api_constants.dart';

void main() {
  test('LIVE API CHECK: Fetch APOD from NASA with real key', () async {
    print('Checking API Key: ${ApiConstants.apiKey}');
    
    final service = NasaApiService();
    
    try {
      final ApodModel apod = await service.fetchApod();
      print('SUCCESS! Fetched APOD:');
      print('Title: ${apod.title}');
      print('Date: ${apod.date}');
      print('URL: ${apod.url}');
      
      expect(apod.title, isNotEmpty);
      expect(apod.url, isNotEmpty);
    } catch (e) {
      print('FAILURE: $e');
      // Fail the test if we can't fetch (unless it's a network issue on the test runner environment)
      // For now, we just print it to verify.
      rethrow;
    }
  });
}
