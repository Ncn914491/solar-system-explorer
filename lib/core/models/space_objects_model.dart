/// Model representing an asteroid or dwarf planet
class Asteroid {
  final String id;
  final String name;
  final String type;
  final double diameterKm;
  final String orbitType;
  final double orbitalPeriodYears;
  final double distanceFromSunAU;
  final String description;
  final List<String> funFacts;
  final String? discoveredBy;
  final int? discoveryYear;
  final String imageKeyword;

  const Asteroid({
    required this.id,
    required this.name,
    required this.type,
    required this.diameterKm,
    required this.orbitType,
    required this.orbitalPeriodYears,
    required this.distanceFromSunAU,
    required this.description,
    this.funFacts = const [],
    this.discoveredBy,
    this.discoveryYear,
    required this.imageKeyword,
  });

  factory Asteroid.fromJson(Map<String, dynamic> json) {
    return Asteroid(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      diameterKm: (json['diameterKm'] as num).toDouble(),
      orbitType: json['orbitType'] as String,
      orbitalPeriodYears: (json['orbitalPeriodYears'] as num).toDouble(),
      distanceFromSunAU: (json['distanceFromSunAU'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      funFacts: (json['funFacts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      discoveredBy: json['discoveredBy'] as String?,
      discoveryYear: json['discoveryYear'] as int?,
      imageKeyword: json['imageKeyword'] as String? ?? '',
    );
  }
}

/// Model representing a comet
class Comet {
  final String id;
  final String name;
  final String officialName;
  final String type;
  final double nucleusDiameterKm;
  final double orbitalPeriodYears;
  final double perihelionAU;
  final double aphelionAU;
  final String description;
  final List<String> funFacts;
  final String? lastPerihelion;
  final String? nextPerihelion;
  final String? discoveredBy;
  final String imageKeyword;

  const Comet({
    required this.id,
    required this.name,
    required this.officialName,
    required this.type,
    required this.nucleusDiameterKm,
    required this.orbitalPeriodYears,
    required this.perihelionAU,
    required this.aphelionAU,
    required this.description,
    this.funFacts = const [],
    this.lastPerihelion,
    this.nextPerihelion,
    this.discoveredBy,
    required this.imageKeyword,
  });

  factory Comet.fromJson(Map<String, dynamic> json) {
    return Comet(
      id: json['id'] as String,
      name: json['name'] as String,
      officialName: json['officialName'] as String? ?? '',
      type: json['type'] as String,
      nucleusDiameterKm: (json['nucleusDiameterKm'] as num).toDouble(),
      orbitalPeriodYears: (json['orbitalPeriodYears'] as num).toDouble(),
      perihelionAU: (json['perihelionAU'] as num).toDouble(),
      aphelionAU: (json['aphelionAU'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      funFacts: (json['funFacts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      lastPerihelion: json['lastPerihelion'] as String?,
      nextPerihelion: json['nextPerihelion'] as String?,
      discoveredBy: json['discoveredBy'] as String?,
      imageKeyword: json['imageKeyword'] as String? ?? '',
    );
  }
}

/// Model representing a black hole
class BlackHole {
  final String id;
  final String name;
  final String type;
  final double massInSolarMasses;
  final double distanceLightYears;
  final String location;
  final String description;
  final List<String> funFacts;
  final String? discoveredBy;
  final int? discoveryYear;
  final String imageKeyword;

  const BlackHole({
    required this.id,
    required this.name,
    required this.type,
    required this.massInSolarMasses,
    required this.distanceLightYears,
    required this.location,
    required this.description,
    this.funFacts = const [],
    this.discoveredBy,
    this.discoveryYear,
    required this.imageKeyword,
  });

  factory BlackHole.fromJson(Map<String, dynamic> json) {
    return BlackHole(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      massInSolarMasses: (json['massInSolarMasses'] as num).toDouble(),
      distanceLightYears: (json['distanceLightYears'] as num).toDouble(),
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      funFacts: (json['funFacts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      discoveredBy: json['discoveredBy'] as String?,
      discoveryYear: json['discoveryYear'] as int?,
      imageKeyword: json['imageKeyword'] as String? ?? '',
    );
  }
}

/// Model representing a meteor shower
class MeteorShower {
  final String id;
  final String name;
  final String peakDate;
  final String activeStart;
  final String activeEnd;
  final int zenithalHourlyRate;
  final double speed;
  final String parentBody;
  final String radiantConstellation;
  final String description;
  final List<String> funFacts;
  final String bestViewingHemisphere;
  final String imageKeyword;

  const MeteorShower({
    required this.id,
    required this.name,
    required this.peakDate,
    required this.activeStart,
    required this.activeEnd,
    required this.zenithalHourlyRate,
    required this.speed,
    required this.parentBody,
    required this.radiantConstellation,
    required this.description,
    this.funFacts = const [],
    required this.bestViewingHemisphere,
    required this.imageKeyword,
  });

  factory MeteorShower.fromJson(Map<String, dynamic> json) {
    return MeteorShower(
      id: json['id'] as String,
      name: json['name'] as String,
      peakDate: json['peakDate'] as String? ?? '',
      activeStart: json['activeStart'] as String? ?? '',
      activeEnd: json['activeEnd'] as String? ?? '',
      zenithalHourlyRate: json['zenithalHourlyRate'] as int? ?? 0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0,
      parentBody: json['parentBody'] as String? ?? '',
      radiantConstellation: json['radiantConstellation'] as String? ?? '',
      description: json['description'] as String? ?? '',
      funFacts: (json['funFacts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      bestViewingHemisphere: json['bestViewingHemisphere'] as String? ?? 'Both',
      imageKeyword: json['imageKeyword'] as String? ?? '',
    );
  }
}

/// Model representing a theoretical or exotic object (White Hole, Wormhole, etc.)
class ExoticObject {
  final String id;
  final String name;
  final String type;
  final String description;
  final String mass;
  final String distance;
  final List<String> funFacts;
  final String imageKeyword;

  const ExoticObject({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.mass,
    required this.distance,
    this.funFacts = const [],
    required this.imageKeyword,
  });

  factory ExoticObject.fromJson(Map<String, dynamic> json) {
    return ExoticObject(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String? ?? '',
      mass: json['mass'] as String? ?? 'Unknown',
      distance: json['distance'] as String? ?? 'Unknown',
      funFacts: (json['funFacts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageKeyword: json['imageKeyword'] as String? ?? '',
    );
  }
}

/// Model representing a deep sky object (Galaxy, Nebula, etc.)
class DeepSkyObject {
  final String id;
  final String name;
  final String type;
  final String constellation;
  final String distance;
  final String description;
  final List<String> funFacts;
  final String imageKeyword;

  const DeepSkyObject({
    required this.id,
    required this.name,
    required this.type,
    required this.constellation,
    required this.distance,
    required this.description,
    this.funFacts = const [],
    required this.imageKeyword,
  });

  factory DeepSkyObject.fromJson(Map<String, dynamic> json) {
    return DeepSkyObject(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      constellation: json['constellation'] as String? ?? 'Unknown',
      distance: json['distance'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      funFacts: (json['funFacts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageKeyword: json['imageKeyword'] as String? ?? '',
    );
  }
}

/// Model representing a Star
class Star {
  final String id;
  final String name;
  final String type;
  final String constellation;
  final String distance;
  final String mass;
  final String radius;
  final String description;
  final List<String> funFacts;
  final String imageKeyword;

  const Star({
    required this.id,
    required this.name,
    required this.type,
    required this.constellation,
    required this.distance,
    required this.mass,
    required this.radius,
    required this.description,
    this.funFacts = const [],
    required this.imageKeyword,
  });

  factory Star.fromJson(Map<String, dynamic> json) {
    return Star(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      constellation: json['constellation'] as String? ?? 'Unknown',
      distance: json['distance'] as String? ?? 'Unknown',
      mass: json['mass'] as String? ?? 'Unknown',
      radius: json['radius'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      funFacts: (json['funFacts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageKeyword: json['imageKeyword'] as String? ?? '',
    );
  }
}
