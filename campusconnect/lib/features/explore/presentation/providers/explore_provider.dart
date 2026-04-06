import '../../../../core/base/base_provider.dart';
import '../../domain/models/university_model.dart';
import '../../data/services/university_api_service.dart';

/// Explore Provider
/// Manages state for the Explore Universities feature
/// Extends BaseProvider for consistent loading/error handling
///
/// Demonstrates:
/// - State management for API data
/// - Loading, error, and success states
/// - Search/filter functionality
/// - Data caching to avoid redundant API calls

class ExploreProvider extends BaseProvider {
  final UniversityApiService _apiService = UniversityApiService();

  // State variables
  List<UniversityModel> _universities = [];
  List<UniversityModel> _filteredUniversities = [];
  String _selectedCountry = 'India';
  String _searchQuery = '';
  UniversityModel? _selectedUniversity;
  bool _hasLoaded = false;

  // Available countries for filtering
  static const List<String> availableCountries = [
    'India',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
  ];

  // Getters
  List<UniversityModel> get universities =>
      _searchQuery.isNotEmpty ? _filteredUniversities : _universities;
  String get selectedCountry => _selectedCountry;
  String get searchQuery => _searchQuery;
  UniversityModel? get selectedUniversity => _selectedUniversity;
  bool get hasLoaded => _hasLoaded;
  int get totalCount => _universities.length;

  /// Load universities for the selected country
  /// Makes a GET request to the REST API
  Future<void> loadUniversities() async {
    await executeOperation(() async {
      _universities =
          await _apiService.fetchUniversitiesByCountry(_selectedCountry);
      _filteredUniversities = [];
      _searchQuery = '';
      _hasLoaded = true;
      notifyListeners();
    });
  }

  /// Search universities by name within selected country
  Future<void> searchUniversities(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredUniversities = [];
      notifyListeners();
      return;
    }

    // Local filter for quick results
    _filteredUniversities = _universities
        .where((uni) =>
            uni.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();

    // If no local results, search API directly
    if (_filteredUniversities.isEmpty && query.length >= 3) {
      await executeOperation(() async {
        _filteredUniversities = await _apiService.searchUniversities(
          name: query,
          country: _selectedCountry,
        );
        notifyListeners();
      });
    }
  }

  /// Change the selected country and reload data
  Future<void> setCountry(String country) async {
    if (_selectedCountry == country) return;

    _selectedCountry = country;
    _searchQuery = '';
    _filteredUniversities = [];
    notifyListeners();

    await loadUniversities();
  }

  /// Select a university for detail view
  void selectUniversity(UniversityModel university) {
    _selectedUniversity = university;
    notifyListeners();
  }

  /// Clear selected university
  void clearSelection() {
    _selectedUniversity = null;
    notifyListeners();
  }

  /// Refresh data (pull-to-refresh)
  Future<void> refresh() async {
    await loadUniversities();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredUniversities = [];
    notifyListeners();
  }
}
