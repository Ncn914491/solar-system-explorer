/// API Constants for NASA Services
class ApiConstants {
  // Prevent instantiation
  ApiConstants._();

  /// Base URL for NASA API
  static const String baseUrl = 'https://api.nasa.gov';

  /// NASA API Key
  /// In a production app, this should be injected via environment variables or a secure storage.
  static const String apiKey = 'YOUR_API_KEY_HERE';

  /// APOD Endpoint
  static const String apodEndpoint = '/planetary/apod';
}
