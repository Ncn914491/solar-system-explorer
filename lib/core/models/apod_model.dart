import 'package:intl/intl.dart';

/// Model representing the Astronomy Picture of the Day (APOD).
class ApodModel {
  final String title;
  final String explanation;
  final String url;
  final String? hdurl;
  final String mediaType;
  final DateTime date;
  final String? copyright;

  const ApodModel({
    required this.title,
    required this.explanation,
    required this.url,
    this.hdurl,
    required this.mediaType,
    required this.date,
    this.copyright,
  });

  /// Factory method to create an [ApodModel] from a JSON map.
  factory ApodModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse date
    DateTime parseDate(String? dateStr) {
      if (dateStr == null) return DateTime.now();
      try {
        return DateFormat('yyyy-MM-dd').parse(dateStr);
      } catch (e) {
        return DateTime.now();
      }
    }

    return ApodModel(
      title: json['title'] as String? ?? 'Untitled',
      explanation: json['explanation'] as String? ?? 'No description available.',
      url: json['url'] as String? ?? '',
      hdurl: json['hdurl'] as String?,
      mediaType: json['media_type'] as String? ?? 'image',
      date: parseDate(json['date'] as String?),
      copyright: json['copyright'] as String?,
    );
  }

  /// Converts the model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'explanation': explanation,
      'url': url,
      if (hdurl != null) 'hdurl': hdurl,
      'media_type': mediaType,
      'date': DateFormat('yyyy-MM-dd').format(date),
      if (copyright != null) 'copyright': copyright,
    };
  }

  @override
  String toString() {
    return 'ApodModel(title: $title, date: $date, mediaType: $mediaType)';
  }
}
