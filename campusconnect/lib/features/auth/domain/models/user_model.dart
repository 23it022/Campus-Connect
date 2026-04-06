import 'package:cloud_firestore/cloud_firestore.dart';

/// User Model
/// Represents a student user in the CampusConnect app
/// Contains all user profile information stored in Firestore

class UserModel {
  final String uid; // Unique user ID
  final String name; // User's display name
  final String email; // User's email address
  final String
      department; // User's department (kept for backward compatibility)
  final String year; // Year of study (e.g., '1st Year', '2nd Year')
  final String profileImage; // Profile image URL
  final String bio; // User bio/description
  final String role; // User role: 'admin', 'teacher', or 'student'
  final bool isActive; // Account status (for ban functionality)
  final DateTime createdAt; // Account creation timestamp
  final DateTime lastActive; // Last active timestamp

  // Additional common fields
  final String phone; // Contact phone number
  final String departmentId; // Department ID reference
  final String departmentName; // Department name (denormalized)
  final bool isEmailVerified; // Email verification status

  // Student-specific fields
  final String semester; // Current semester ('1', '2', '3', etc.)
  final String rollNumber; // Student roll number
  final int enrollmentYear; // Year of enrollment (e.g., 2021)

  // Teacher-specific fields
  final String employeeId; // Teacher employee ID
  final String designation; // Professor, Associate Professor, etc.
  final List<String> subjects; // Subjects taught (names)
  final List<String> courseIds; // Assigned course IDs

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.department,
    required this.year,
    this.profileImage = '',
    this.bio = '',
    this.role = 'student',
    this.isActive = true,
    DateTime? createdAt,
    DateTime? lastActive,
    // Additional fields
    this.phone = '',
    this.departmentId = '',
    this.departmentName = '',
    this.isEmailVerified = false,
    // Student fields
    this.semester = '',
    this.rollNumber = '',
    this.enrollmentYear = 0,
    // Teacher fields
    this.employeeId = '',
    this.designation = '',
    List<String>? subjects,
    List<String>? courseIds,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastActive = lastActive ?? DateTime.now(),
        subjects = subjects ?? [],
        courseIds = courseIds ?? [];

  /// Convert UserModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'department': department,
      'year': year,
      'profileImage': profileImage,
      'bio': bio,
      'role': role,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      // Additional fields
      'phone': phone,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'isEmailVerified': isEmailVerified,
      // Student fields
      'semester': semester,
      'rollNumber': rollNumber,
      'enrollmentYear': enrollmentYear,
      // Teacher fields
      'employeeId': employeeId,
      'designation': designation,
      'subjects': subjects,
      'courseIds': courseIds,
    };
  }

  /// Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      department: map['department'] ?? '',
      year: map['year'] ?? '',
      profileImage: map['profileImage'] ?? '',
      bio: map['bio'] ?? '',
      role: map['role'] ?? 'student',
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (map['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // Additional fields
      phone: map['phone'] ?? '',
      departmentId: map['departmentId'] ?? '',
      departmentName: map['departmentName'] ?? '',
      isEmailVerified: map['isEmailVerified'] ?? false,
      // Student fields
      semester: map['semester'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      enrollmentYear: map['enrollmentYear'] ?? 0,
      // Teacher fields
      employeeId: map['employeeId'] ?? '',
      designation: map['designation'] ?? '',
      subjects: List<String>.from(map['subjects'] ?? []),
      courseIds: List<String>.from(map['courseIds'] ?? []),
    );
  }

  /// Create UserModel from Firestore DocumentSnapshot
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  /// Create a copy of UserModel with modified fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? department,
    String? year,
    String? profileImage,
    String? bio,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastActive,
    // Additional fields
    String? phone,
    String? departmentId,
    String? departmentName,
    bool? isEmailVerified,
    // Student fields
    String? semester,
    String? rollNumber,
    int? enrollmentYear,
    // Teacher fields
    String? employeeId,
    String? designation,
    List<String>? subjects,
    List<String>? courseIds,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      year: year ?? this.year,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      // Additional fields
      phone: phone ?? this.phone,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      // Student fields
      semester: semester ?? this.semester,
      rollNumber: rollNumber ?? this.rollNumber,
      enrollmentYear: enrollmentYear ?? this.enrollmentYear,
      // Teacher fields
      employeeId: employeeId ?? this.employeeId,
      designation: designation ?? this.designation,
      subjects: subjects ?? this.subjects,
      courseIds: courseIds ?? this.courseIds,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, department: $department, year: $year)';
  }
}
