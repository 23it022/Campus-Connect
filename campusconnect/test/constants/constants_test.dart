import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campusconnect/shared/constants/constants.dart';

/// Unit Tests for App Constants
/// Validates color values, text styles, spacing, and validation rules

void main() {
  group('AppColors', () {
    test('primary color should be correct hex value', () {
      expect(AppColors.primary, const Color(0xFF6C63FF));
    });

    test('error color should be red variant', () {
      expect(AppColors.error, const Color(0xFFF44336));
    });

    test('success color should be green variant', () {
      expect(AppColors.success, const Color(0xFF4CAF50));
    });

    test('all status colors should be non-null', () {
      expect(AppColors.success, isNotNull);
      expect(AppColors.error, isNotNull);
      expect(AppColors.warning, isNotNull);
      expect(AppColors.info, isNotNull);
    });
  });

  group('AppSpacing', () {
    test('spacing values should be in ascending order', () {
      expect(AppSpacing.xs < AppSpacing.sm, isTrue);
      expect(AppSpacing.sm < AppSpacing.md, isTrue);
      expect(AppSpacing.md < AppSpacing.lg, isTrue);
      expect(AppSpacing.lg < AppSpacing.xl, isTrue);
      expect(AppSpacing.xl < AppSpacing.xxl, isTrue);
    });

    test('border radius values should be positive', () {
      expect(AppSpacing.radiusSm, greaterThan(0));
      expect(AppSpacing.radiusMd, greaterThan(0));
      expect(AppSpacing.radiusLg, greaterThan(0));
    });
  });

  group('AppValidation', () {
    test('minPasswordLength should be at least 6', () {
      expect(AppValidation.minPasswordLength, greaterThanOrEqualTo(6));
    });

    test('maxBioLength should be reasonable', () {
      expect(AppValidation.maxBioLength, greaterThan(0));
      expect(AppValidation.maxBioLength, lessThanOrEqualTo(500));
    });

    test('maxPostLength should be reasonable', () {
      expect(AppValidation.maxPostLength, greaterThan(0));
    });
  });

  group('AppStrings', () {
    test('appName should be CampusConnect', () {
      expect(AppStrings.appName, 'CampusConnect');
    });

    test('error messages should not be empty', () {
      expect(AppStrings.errorGeneric.isNotEmpty, isTrue);
      expect(AppStrings.errorNetwork.isNotEmpty, isTrue);
      expect(AppStrings.errorAuth.isNotEmpty, isTrue);
    });
  });

  group('FirebaseCollections', () {
    test('collection names should match expected values', () {
      expect(FirebaseCollections.users, 'users');
      expect(FirebaseCollections.posts, 'posts');
      expect(FirebaseCollections.events, 'events');
      expect(FirebaseCollections.groups, 'groups');
      expect(FirebaseCollections.messages, 'messages');
    });
  });

  group('AppTextStyles', () {
    test('h1 font size should be larger than h2', () {
      expect(AppTextStyles.h1.fontSize!, greaterThan(AppTextStyles.h2.fontSize!));
    });

    test('h2 font size should be larger than h3', () {
      expect(AppTextStyles.h2.fontSize!, greaterThan(AppTextStyles.h3.fontSize!));
    });

    test('body1 should be larger than body2', () {
      expect(AppTextStyles.body1.fontSize!, greaterThan(AppTextStyles.body2.fontSize!));
    });

    test('caption should be smallest text style', () {
      expect(AppTextStyles.caption.fontSize!, lessThan(AppTextStyles.body2.fontSize!));
    });
  });
}
