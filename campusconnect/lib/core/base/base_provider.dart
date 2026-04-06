import 'package:flutter/foundation.dart';

/// Base Provider Class
/// Provides common state management functionality for all providers
/// Handles loading, error, and success states

class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get error message
  String get errorMessage => _errorMessage;

  /// Set loading state
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Execute an async operation with loading and error handling
  Future<T?> executeOperation<T>(Future<T> Function() operation) async {
    try {
      setLoading(true);
      clearError();
      final result = await operation();
      setLoading(false);
      return result;
    } catch (e) {
      setError(e.toString());
      return null;
    }
  }
}
