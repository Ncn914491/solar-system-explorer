import 'package:flutter_test/flutter_test.dart';
import 'package:solar_system_explorer/core/services/nasa_api_service.dart';
import 'package:solar_system_explorer/core/models/apod_model.dart';

void main() {
  test('Verify NasaApiService compiles and instantiates', () {
    final service = NasaApiService();
    expect(service, isNotNull);
  });

  test('Verify ApodModel parsing', () {
    final json = {
      "date": "2023-10-27",
      "explanation": "Test explanation",
      "media_type": "image",
      "service_version": "v1",
      "title": "Test Title",
      "url": "https://apod.nasa.gov/apod/image/2310/Test.jpg"
    };
    
    final model = ApodModel.fromJson(json);
    expect(model.title, "Test Title");
    expect(model.date.year, 2023);
  });
}
