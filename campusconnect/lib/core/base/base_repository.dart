/// Base Repository Class
/// Provides common functionality for all repository classes
/// Handles errors and provides standardized responses

abstract class BaseRepository {
  /// Handle repository exceptions and convert them to user-friendly messages
  String handleError(Exception e) {
    if (e.toString().contains('network')) {
      return 'Network error. Please check your connection.';
    } else if (e.toString().contains('permission')) {
      return 'Permission denied. Please try again.';
    } else if (e.toString().contains('not-found')) {
      return 'Resource not found.';
    }
    return 'An error occurred. Please try again.';
  }

  /// Log errors for debugging
  void logError(String operation, Exception e) {
    print('Error in $operation: $e');
  }
}
