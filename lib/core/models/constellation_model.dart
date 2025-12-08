class Constellation {
  final String id;
  final String name;
  final String abbreviation;
  final String hemisphere;
  final List<String> bestViewingMonths;
  final bool zodiac;
  final List<String> mainStars;
  final String brightestStar;
  final String description;
  final String mythology;
  final double? areaSqDeg;
  final List<String>? notableObjects;
  final String? imageUrl;

  Constellation({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.hemisphere,
    required this.bestViewingMonths,
    required this.zodiac,
    required this.mainStars,
    required this.brightestStar,
    required this.description,
    required this.mythology,
    this.areaSqDeg,
    this.notableObjects,
    this.imageUrl,
  });

  factory Constellation.fromJson(Map<String, dynamic> json) {
    return Constellation(
      id: json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Unknown Constellation',
      abbreviation: json['abbreviation'] as String? ?? '',
      hemisphere: json['hemisphere'] as String? ?? 'Unknown',
      bestViewingMonths: (json['bestViewingMonths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      zodiac: json['zodiac'] as bool? ?? false,
      mainStars: (json['mainStars'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      brightestStar: json['brightestStar'] as String? ?? '',
      description: json['description'] as String? ?? '',
      mythology: json['mythology'] as String? ?? '',
      areaSqDeg: (json['areaSqDeg'] as num?)?.toDouble(),
      notableObjects: (json['notableObjects'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'abbreviation': abbreviation,
      'hemisphere': hemisphere,
      'bestViewingMonths': bestViewingMonths,
      'zodiac': zodiac,
      'mainStars': mainStars,
      'brightestStar': brightestStar,
      'description': description,
      'mythology': mythology,
      'areaSqDeg': areaSqDeg,
      'notableObjects': notableObjects,
      'imageUrl': imageUrl,
    };
  }
}
