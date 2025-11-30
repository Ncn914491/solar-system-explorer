class Star {
  final int id;
  final String name;
  final double ra; // Right ascension in degrees (0-360)
  final double dec; // Declination in degrees (-90 to +90)
  final double magnitude; // Apparent magnitude (lower = brighter)
  final double? distanceLightYears;
  final String? spectralType;
  final String? constellation;

  Star({
    required this.id,
    required this.name,
    required this.ra,
    required this.dec,
    required this.magnitude,
    this.distanceLightYears,
    this.spectralType,
    this.constellation,
  });

  factory Star.fromJson(Map<String, dynamic> json) {
    return Star(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      ra: (json['ra'] as num?)?.toDouble() ?? 0.0,
      dec: (json['dec'] as num?)?.toDouble() ?? 0.0,
      magnitude: (json['magnitude'] as num?)?.toDouble() ?? 6.0,
      distanceLightYears: (json['distanceLightYears'] as num?)?.toDouble(),
      spectralType: json['spectralType'] as String?,
      constellation: json['constellation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ra': ra,
      'dec': dec,
      'magnitude': magnitude,
      'distanceLightYears': distanceLightYears,
      'spectralType': spectralType,
      'constellation': constellation,
    };
  }

  /// Returns true if this star has a proper name (not unnamed)
  bool get hasName => name.isNotEmpty;

  /// Returns display name (or "Unnamed Star" if no name)
  String get displayName => hasName ? name : 'Unnamed Star';

  /// Returns a relative brightness scale (0.0 to 1.0) based on magnitude
  /// Lower magnitude = brighter, so we invert and normalize
  double get relativeBrightness {
    // Magnitude range: -1.5 (Sirius, brightest) to ~6.0 (dimmest visible)
    // Normalize to 0.0-1.0 scale
    const minMag = -1.5;
    const maxMag = 6.5;
    final normalized = 1.0 - ((magnitude - minMag) / (maxMag - minMag));
    return normalized.clamp(0.0, 1.0);
  }
}
