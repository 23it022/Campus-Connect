/// University Model
/// Represents a university fetched from the REST API
/// Includes factory constructor for JSON parsing

class UniversityModel {
  final String name;
  final String country;
  final String alphaTwoCode;
  final String? stateProvince;
  final List<String> domains;
  final List<String> webPages;

  UniversityModel({
    required this.name,
    required this.country,
    required this.alphaTwoCode,
    this.stateProvince,
    required this.domains,
    required this.webPages,
  });

  /// Factory constructor to parse JSON from API response
  /// API returns: {"name": "...", "country": "...", "alpha_two_code": "...",
  ///              "state-province": "...", "domains": [...], "web_pages": [...]}
  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      alphaTwoCode: json['alpha_two_code'] ?? '',
      stateProvince: json['state-province'],
      domains: List<String>.from(json['domains'] ?? []),
      webPages: List<String>.from(json['web_pages'] ?? []),
    );
  }

  /// Convert model back to JSON (for potential future use)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'alpha_two_code': alphaTwoCode,
      'state-province': stateProvince,
      'domains': domains,
      'web_pages': webPages,
    };
  }

  /// Get the primary website URL
  String get primaryWebsite =>
      webPages.isNotEmpty ? webPages.first : '';

  /// Get the primary domain
  String get primaryDomain =>
      domains.isNotEmpty ? domains.first : '';

  @override
  String toString() => 'UniversityModel(name: $name, country: $country)';
}
