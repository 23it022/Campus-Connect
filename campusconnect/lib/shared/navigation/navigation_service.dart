import 'package:flutter/material.dart';

/// Navigation Service
/// Provides context-independent navigation throughout the app
/// Allows navigation from anywhere without BuildContext

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static final navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate to a named route
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  /// Replace current route with a named route
  Future<dynamic> replaceTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Pop current route
  void goBack() {
    return navigatorKey.currentState!.pop();
  }

  /// Pop until a specific route
  void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }

  /// Navigate and remove all previous routes
  Future<dynamic> navigateAndRemoveUntil(String routeName,
      {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Get current context
  BuildContext? get context => navigatorKey.currentState?.context;
}
