import 'package:flutter_test/flutter_test.dart';
import 'package:solar_system_explorer/core/models/planet_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Planet Model parsing check', () {
    final json = {
      "id": "test",
      "name": "Test Planet",
      "shortDescription": "Short Desc",
      "detailedDescription": "Detailed Desc",
      "diameterKm": 1000.0,
      "massKg": "10^20",
      "distanceFromSunKm": 5000.0,
      "orbitalPeriodDays": 100.0,
      "rotationPeriodHours": 24.0,
      "gravityMs2": 9.8,
      "averageTemperatureC": 20.0,
      "numberOfMoons": 1,
      "atmosphere": "Air",
      "funFacts": ["Fact 1"],
      "textureAsset": "assets/test.jpg"
    };

    final planet = Planet.fromJson(json);
    expect(planet.name, "Test Planet");
    expect(planet.shortDescription, "Short Desc");
    expect(planet.detailedDescription, "Detailed Desc");
    expect(planet.diameterKm, 1000.0);
    expect(planet.funFacts.length, 1);
  });

  // Note: Testing PlanetService.loadPlanets() with rootBundle in a unit test 
  // without a running app is tricky because assets are packaged with the app.
  // We verified the JSON structure via the model test above.
}
