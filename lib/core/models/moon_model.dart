/// Model representing a moon orbiting a planet.
class Moon {
  final String id;
  final String name;
  final String? alternativeName;
  final String planetId;
  final double diameterKm;
  final double distanceFromPlanetKm;
  final double orbitalPeriodDays;
  final String description;
  final List<String> funFacts;
  final String? discoveredBy;
  final int? discoveryYear;
  final String? imageKeyword;

  const Moon({
    required this.id,
    required this.name,
    this.alternativeName,
    required this.planetId,
    required this.diameterKm,
    required this.distanceFromPlanetKm,
    required this.orbitalPeriodDays,
    required this.description,
    this.funFacts = const [],
    this.discoveredBy,
    this.discoveryYear,
    this.imageKeyword,
  });

  factory Moon.fromJson(Map<String, dynamic> json) {
    return Moon(
      id: json['id'] as String,
      name: json['name'] as String,
      alternativeName: json['alternativeName'] as String?,
      planetId: json['planetId'] as String,
      diameterKm: (json['diameterKm'] as num).toDouble(),
      distanceFromPlanetKm: (json['distanceFromPlanetKm'] as num).toDouble(),
      orbitalPeriodDays: (json['orbitalPeriodDays'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      funFacts: (json['funFacts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      discoveredBy: json['discoveredBy'] as String?,
      discoveryYear: json['discoveryYear'] as int?,
      imageKeyword: json['imageKeyword'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'alternativeName': alternativeName,
      'planetId': planetId,
      'diameterKm': diameterKm,
      'distanceFromPlanetKm': distanceFromPlanetKm,
      'orbitalPeriodDays': orbitalPeriodDays,
      'description': description,
      'funFacts': funFacts,
      'discoveredBy': discoveredBy,
      'discoveryYear': discoveryYear,
      'imageKeyword': imageKeyword,
    };
  }
}
