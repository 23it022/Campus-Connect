import 'package:flutter_test/flutter_test.dart';
import 'package:campusconnect/features/explore/domain/models/university_model.dart';

/// Unit Tests for UniversityModel
/// Tests JSON parsing, serialization, computed properties, and edge cases

void main() {
  group('UniversityModel', () {
    // ─── Test 1: fromJson with complete data ───
    test('fromJson should correctly parse complete JSON data', () {
      final json = {
        'name': 'Indian Institute of Technology Delhi',
        'country': 'India',
        'alpha_two_code': 'IN',
        'state-province': 'New Delhi',
        'domains': ['iitd.ac.in'],
        'web_pages': ['http://www.iitd.ac.in/'],
      };

      final university = UniversityModel.fromJson(json);

      expect(university.name, 'Indian Institute of Technology Delhi');
      expect(university.country, 'India');
      expect(university.alphaTwoCode, 'IN');
      expect(university.stateProvince, 'New Delhi');
      expect(university.domains, ['iitd.ac.in']);
      expect(university.webPages, ['http://www.iitd.ac.in/']);
    });

    // ─── Test 2: fromJson with missing optional fields ───
    test('fromJson should handle null state-province gracefully', () {
      final json = {
        'name': 'MIT',
        'country': 'United States',
        'alpha_two_code': 'US',
        'state-province': null,
        'domains': ['mit.edu'],
        'web_pages': ['http://www.mit.edu/'],
      };

      final university = UniversityModel.fromJson(json);

      expect(university.stateProvince, isNull);
      expect(university.name, 'MIT');
    });

    // ─── Test 3: fromJson with empty/missing fields ───
    test('fromJson should use defaults for missing fields', () {
      final json = <String, dynamic>{};

      final university = UniversityModel.fromJson(json);

      expect(university.name, '');
      expect(university.country, '');
      expect(university.alphaTwoCode, '');
      expect(university.domains, isEmpty);
      expect(university.webPages, isEmpty);
    });

    // ─── Test 4: toJson round-trip ───
    test('toJson should produce valid JSON that can be parsed back', () {
      final original = UniversityModel(
        name: 'Test University',
        country: 'India',
        alphaTwoCode: 'IN',
        stateProvince: 'Maharashtra',
        domains: ['test.ac.in'],
        webPages: ['http://test.ac.in'],
      );

      final json = original.toJson();
      final reconstructed = UniversityModel.fromJson(json);

      expect(reconstructed.name, original.name);
      expect(reconstructed.country, original.country);
      expect(reconstructed.alphaTwoCode, original.alphaTwoCode);
      expect(reconstructed.stateProvince, original.stateProvince);
      expect(reconstructed.domains, original.domains);
      expect(reconstructed.webPages, original.webPages);
    });

    // ─── Test 5: primaryWebsite getter ───
    test('primaryWebsite should return first web page or empty string', () {
      final withPages = UniversityModel(
        name: 'A',
        country: 'B',
        alphaTwoCode: 'C',
        domains: [],
        webPages: ['http://a.com', 'http://b.com'],
      );
      expect(withPages.primaryWebsite, 'http://a.com');

      final withoutPages = UniversityModel(
        name: 'A',
        country: 'B',
        alphaTwoCode: 'C',
        domains: [],
        webPages: [],
      );
      expect(withoutPages.primaryWebsite, '');
    });

    // ─── Test 6: primaryDomain getter ───
    test('primaryDomain should return first domain or empty string', () {
      final withDomains = UniversityModel(
        name: 'A',
        country: 'B',
        alphaTwoCode: 'C',
        domains: ['a.edu', 'b.edu'],
        webPages: [],
      );
      expect(withDomains.primaryDomain, 'a.edu');

      final withoutDomains = UniversityModel(
        name: 'A',
        country: 'B',
        alphaTwoCode: 'C',
        domains: [],
        webPages: [],
      );
      expect(withoutDomains.primaryDomain, '');
    });

    // ─── Test 7: toString ───
    test('toString should include name and country', () {
      final university = UniversityModel(
        name: 'IIT Delhi',
        country: 'India',
        alphaTwoCode: 'IN',
        domains: [],
        webPages: [],
      );

      expect(
        university.toString(),
        'UniversityModel(name: IIT Delhi, country: India)',
      );
    });

    // ─── Test 8: Multiple domains/webPages ───
    test('should support multiple domains and web pages', () {
      final json = {
        'name': 'Multi Domain University',
        'country': 'USA',
        'alpha_two_code': 'US',
        'domains': ['main.edu', 'alt.edu', 'research.edu'],
        'web_pages': ['http://main.edu', 'http://alt.edu'],
      };

      final university = UniversityModel.fromJson(json);

      expect(university.domains.length, 3);
      expect(university.webPages.length, 2);
    });
  });
}
