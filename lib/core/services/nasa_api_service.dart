import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../constants/api_constants.dart';
import '../models/apod_model.dart';

/// Service responsible for interacting with NASA's API.
class NasaApiService {
  final http.Client _client;

  NasaApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches the Astronomy Picture of the Day (APOD).
  /// 
  /// If [date] is provided, fetches the APOD for that specific date.
  /// Otherwise, fetches today's APOD.
  /// 
  /// Throws an [Exception] if the request fails.
  Future<ApodModel> fetchApod({DateTime? date}) async {
    try {
      final queryParams = {
        'api_key': ApiConstants.apiKey,
      };

      if (date != null) {
        queryParams['date'] = DateFormat('yyyy-MM-dd').format(date);
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.apodEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ApodModel.fromJson(data);
      } else {
        throw Exception(
          'Failed to load APOD: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching APOD: $e');
    }
  }
}
