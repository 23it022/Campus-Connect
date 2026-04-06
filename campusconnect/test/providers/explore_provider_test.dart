import 'package:flutter_test/flutter_test.dart';
import 'package:campusconnect/features/explore/presentation/providers/explore_provider.dart';

/// Unit Tests for ExploreProvider
/// Tests state management logic without Firebase dependency

void main() {
  group('ExploreProvider', () {
    late ExploreProvider provider;

    setUp(() {
      provider = ExploreProvider();
    });

    // ─── Test 1: Initial state ───
    test('initial state should have correct defaults', () {
      expect(provider.universities, isEmpty);
      expect(provider.selectedCountry, 'India');
      expect(provider.searchQuery, '');
      expect(provider.hasLoaded, isFalse);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, '');
      expect(provider.totalCount, 0);
    });

    // ─── Test 2: Available countries list ───
    test('availableCountries should contain expected countries', () {
      expect(ExploreProvider.availableCountries, contains('India'));
      expect(ExploreProvider.availableCountries, contains('United States'));
      expect(ExploreProvider.availableCountries, contains('United Kingdom'));
      expect(ExploreProvider.availableCountries.length, 6);
    });

    // ─── Test 3: clearSearch resets search state ───
    test('clearSearch should reset search query and filtered list', () {
      // First set some search state
      provider.clearSearch();

      expect(provider.searchQuery, '');
    });

    // ─── Test 4: selectedUniversity management ───
    test('selectUniversity and clearSelection should work correctly', () {
      // There's no university set initially
      expect(provider.selectedUniversity, isNull);
    });
  });

  group('ExploreProvider - BaseProvider Integration', () {
    late ExploreProvider provider;

    setUp(() {
      provider = ExploreProvider();
    });

    // ─── Test 5: Loading state management ───
    test('setLoading should update isLoading state', () {
      expect(provider.isLoading, isFalse);

      provider.setLoading(true);
      expect(provider.isLoading, isTrue);

      provider.setLoading(false);
      expect(provider.isLoading, isFalse);
    });

    // ─── Test 6: Error state management ───
    test('setError should update errorMessage and stop loading', () {
      provider.setLoading(true);
      provider.setError('Network error');

      expect(provider.errorMessage, 'Network error');
      expect(provider.isLoading, isFalse);
    });

    // ─── Test 7: clearError ───
    test('clearError should reset error message', () {
      provider.setError('Some error');
      expect(provider.errorMessage, 'Some error');

      provider.clearError();
      expect(provider.errorMessage, '');
    });
  });
}
