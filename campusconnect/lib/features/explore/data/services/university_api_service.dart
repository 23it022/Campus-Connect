import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/university_model.dart';

/// University API Service
/// Handles all REST API calls to the Universities API
/// Base URL: http://universities.hipolabs.com/search
///
/// This service demonstrates:
/// - HTTP GET requests using the http package
/// - JSON response parsing
/// - Error handling for network failures
/// - Query parameter construction
/// - Timeout handling

class UniversityApiService {
  static const String _baseUrl = 'http://universities.hipolabs.com/search';
  static const Duration _timeout = Duration(seconds: 15);

  /// Fetch universities by country
  /// GET /search?country={country}
  /// Returns a list of UniversityModel parsed from JSON array
  Future<List<UniversityModel>> fetchUniversitiesByCountry(
      String country) async {
    try {
      // Build the URL with query parameters
      final uri = Uri.parse('$_baseUrl?country=$country');

      // Perform HTTP GET request with timeout
      final response = await http.get(uri).timeout(_timeout);

      // Check response status code
      if (response.statusCode == 200) {
        // Parse JSON response body
        final List<dynamic> jsonList = json.decode(response.body);

        // Map each JSON object to UniversityModel using fromJson()
        return jsonList
            .map((json) => UniversityModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load universities. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please check your connection.');
      }
      throw Exception('Failed to fetch universities: $e');
    }
  }

  /// Search universities by name and optional country
  /// GET /search?name={name}&country={country}
  Future<List<UniversityModel>> searchUniversities({
    required String name,
    String? country,
  }) async {
    try {
      // Build URL with multiple query parameters
      String url = '$_baseUrl?name=$name';
      if (country != null && country.isNotEmpty) {
        url += '&country=$country';
      }

      final uri = Uri.parse(url);

      // Perform GET request
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => UniversityModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Search failed. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timed out. Please check your connection.');
      }
      throw Exception('Search failed: $e');
    }
  }

  /// Fetch all universities (limited to a country for performance)
  /// Default: India
  Future<List<UniversityModel>> fetchAllUniversities() async {
    return fetchUniversitiesByCountry('India');
  }
}
