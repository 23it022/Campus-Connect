import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_model.dart';

/// Authentication Service
/// Handles all Firebase Authentication operations and user profile management
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user from Firebase Auth
  User? get currentUser => _auth.currentUser;

  /// Get current user stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  /// Creates Firebase Auth user and Firestore user profile
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String department,
    required String year,
  }) async {
    try {
      // Create user in Firebase Auth
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) throw Exception('User creation failed');

      // Create user profile in Firestore
      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        department: department,
        year: year,
      );

      await _createUserProfile(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign up as teacher with email and password
  /// Creates Firebase Auth user and Firestore user profile with teacher role
  Future<UserModel?> signUpTeacher({
    required String email,
    required String password,
    required String name,
    required String department,
    required String employeeId,
    required String designation,
  }) async {
    try {
      // Create user in Firebase Auth
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) throw Exception('User creation failed');

      // Create teacher profile in Firestore
      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        department: department,
        year: '',
        role: 'teacher',
        employeeId: employeeId,
        designation: designation,
      );

      await _createUserProfile(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Teacher sign up failed: $e');
    }
  }

  /// Sign in with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) throw Exception('Sign in failed');

      // Get user profile from Firestore
      return await getUserProfile(user.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  /// Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      return UserModel.fromDocument(doc);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Create user profile in Firestore
  Future<void> _createUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Update user profile in Firestore
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign in is not enabled.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
