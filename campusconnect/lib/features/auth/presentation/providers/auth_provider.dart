import '../../../../core/base/base_provider.dart';
import '../../domain/models/user_model.dart';
import '../../data/services/auth_service.dart';

/// Auth Provider
/// Manages authentication state and provides auth methods to the UI
class AuthProvider extends BaseProvider {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;

  /// Get current user
  UserModel? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Listen to auth state changes
  void initAuthListener() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        _currentUser = await _authService.getUserProfile(user.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String department,
    required String year,
  }) async {
    final result = await executeOperation(() async {
      final user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        department: department,
        year: year,
      );
      _currentUser = user;
      return user;
    });
    return result != null;
  }

  /// Sign up as teacher with email and password
  Future<bool> signUpAsTeacher({
    required String email,
    required String password,
    required String name,
    required String department,
    required String employeeId,
    required String designation,
  }) async {
    final result = await executeOperation(() async {
      final user = await _authService.signUpTeacher(
        email: email,
        password: password,
        name: name,
        department: department,
        employeeId: employeeId,
        designation: designation,
      );
      _currentUser = user;
      return user;
    });
    return result != null;
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final result = await executeOperation(() async {
      final user = await _authService.signIn(
        email: email,
        password: password,
      );
      _currentUser = user;
      return user;
    });
    return result != null;
  }

  /// Sign out
  Future<void> signOut() async {
    await executeOperation(() async {
      await _authService.signOut();
      _currentUser = null;
    });
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    final result = await executeOperation(() async {
      await _authService.resetPassword(email);
      return true;
    });
    return result ?? false;
  }

  /// Get current user profile
  Future<void> loadCurrentUser() async {
    final user = _authService.currentUser;
    if (user != null) {
      _currentUser = await _authService.getUserProfile(user.uid);
      notifyListeners();
    }
  }
}
