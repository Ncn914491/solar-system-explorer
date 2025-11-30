/// Model representing a planet in the solar system.
class Planet {
  final String id;
  final String name;
  final String shortDescription;
  final String detailedDescription;
  final double diameterKm;
  final String massKg;
  final double distanceFromSunKm;
  final double orbitalPeriodDays;
  final double rotationPeriodHours;
  final double gravityMs2;
  final double averageTemperatureC;
  final int numberOfMoons;
  final String? atmosphere;
  final List<String> funFacts;
  final String? textureAsset;

  const Planet({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.detailedDescription,
    required this.diameterKm,
    required this.massKg,
    required this.distanceFromSunKm,
    required this.orbitalPeriodDays,
    required this.rotationPeriodHours,
    required this.gravityMs2,
    required this.averageTemperatureC,
    required this.numberOfMoons,
    this.atmosphere,
    this.funFacts = const [],
    this.textureAsset,
  });

  factory Planet.fromJson(Map<String, dynamic> json) {
    return Planet(
      id: json['id'] as String,
      name: json['name'] as String,
      shortDescription: json['shortDescription'] as String? ?? json['description'] as String? ?? '',
      detailedDescription: json['detailedDescription'] as String? ?? json['description'] as String? ?? '',
      diameterKm: (json['diameterKm'] as num).toDouble(),
      massKg: json['massKg'] as String,
      distanceFromSunKm: (json['distanceFromSunKm'] as num).toDouble(),
      orbitalPeriodDays: (json['orbitalPeriodDays'] as num).toDouble(),
      rotationPeriodHours: (json['rotationPeriodHours'] as num).toDouble(),
      gravityMs2: (json['gravityMs2'] as num).toDouble(),
      averageTemperatureC: (json['averageTemperatureC'] as num).toDouble(),
      numberOfMoons: json['numberOfMoons'] as int,
      atmosphere: json['atmosphere'] as String?,
      funFacts: (json['funFacts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      textureAsset: json['textureAsset'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortDescription': shortDescription,
      'detailedDescription': detailedDescription,
      'diameterKm': diameterKm,
      'massKg': massKg,
      'distanceFromSunKm': distanceFromSunKm,
      'orbitalPeriodDays': orbitalPeriodDays,
      'rotationPeriodHours': rotationPeriodHours,
      'gravityMs2': gravityMs2,
      'averageTemperatureC': averageTemperatureC,
      'numberOfMoons': numberOfMoons,
      'atmosphere': atmosphere,
      'funFacts': funFacts,
      'textureAsset': textureAsset,
    };
  }
}
