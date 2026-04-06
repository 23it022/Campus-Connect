import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Admin Account Setup Script
/// Creates a single admin account for CampusConnect
///
/// Usage:
///   dart scripts/create_admin.dart <email> <password> <name>
///
/// Example:
///   dart scripts/create_admin.dart admin@campus.edu Admin@123 "Admin User"

void main(List<String> args) async {
  // Validate arguments
  if (args.length != 3) {
    print('❌ Error: Invalid arguments');
    print('Usage: dart scripts/create_admin.dart <email> <password> <name>');
    print(
        'Example: dart scripts/create_admin.dart admin@campus.edu Admin@123 "Admin User"');
    exit(1);
  }

  final email = args[0].trim();
  final password = args[1];
  final name = args[2].trim();

  // Validate email format
  if (!email.contains('@')) {
    print('❌ Error: Invalid email format');
    exit(1);
  }

  // Validate password length
  if (password.length < 6) {
    print('❌ Error: Password must be at least 6 characters');
    exit(1);
  }

  // Validate name
  if (name.isEmpty) {
    print('❌ Error: Name cannot be empty');
    exit(1);
  }

  print('🔧 Initializing Firebase...');

  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    print('✅ Firebase initialized');
    print('\n🔍 Checking for existing admin...');

    // Check if an admin already exists
    final adminQuery = await firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get();

    if (adminQuery.docs.isNotEmpty) {
      print('❌ Error: An admin account already exists!');
      print('   Email: ${adminQuery.docs.first.data()['email']}');
      print('   Name: ${adminQuery.docs.first.data()['name']}');
      print(
          '\n💡 To create a new admin, first remove the existing admin from Firebase Console.');
      exit(1);
    }

    print('✅ No existing admin found');
    print('\n👤 Creating admin account...');
    print('   Email: $email');
    print('   Name: $name');

    // Create user in Firebase Authentication
    UserCredential userCredential;
    try {
      userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('❌ Error: Email already in use');
        print('💡 This email is already registered. Use a different email.');
      } else if (e.code == 'weak-password') {
        print('❌ Error: Password is too weak');
      } else {
        print('❌ Error: ${e.message}');
      }
      exit(1);
    }

    final user = userCredential.user!;
    print('✅ Firebase Auth user created');

    // Create user profile in Firestore
    final adminData = {
      'uid': user.uid,
      'name': name,
      'email': email,
      'department': 'Administration',
      'year': 'N/A',
      'profileImage': '',
      'bio': 'System Administrator',
      'role': 'admin',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
      // Additional fields
      'phone': '',
      'departmentId': '',
      'departmentName': 'Administration',
      'isEmailVerified': false,
      // Student fields (empty for admin)
      'semester': '',
      'rollNumber': '',
      'enrollmentYear': 0,
      // Teacher fields (empty for admin)
      'employeeId': 'ADMIN001',
      'designation': 'Administrator',
      'subjects': [],
      'courseIds': [],
    };

    await firestore.collection('users').doc(user.uid).set(adminData);
    print('✅ Firestore user profile created');

    print('\n✨ Admin account created successfully!');
    print('═' * 50);
    print('📧 Email: $email');
    print('🔑 Password: $password');
    print('👤 Name: $name');
    print('🎯 Role: ADMIN');
    print('═' * 50);
    print('\n💡 You can now sign in with these credentials');
    print('🚀 Run: flutter run -d chrome');

    exit(0);
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
