import 'package:cloud_firestore/cloud_firestore.dart';

/// Department Model
/// Represents an academic department in the college
/// Contains department information, HOD details, and statistics

class DepartmentModel {
  final String departmentId; // Unique department ID
  final String
      name; // Department name (e.g., "Computer Science and Engineering")
  final String code; // Department code (e.g., "CSE", "MECH", "EE")
  final String hodName; // Head of Department name
  final String hodId; // HOD user ID (teacher)
  final String description; // Department description
  final int totalStudents; // Total enrolled students
  final int totalTeachers; // Total faculty members
  final int totalCourses; // Total courses offered
  final DateTime createdAt; // Department creation timestamp
  final DateTime updatedAt; // Last update timestamp

  DepartmentModel({
    required this.departmentId,
    required this.name,
    required this.code,
    this.hodName = '',
    this.hodId = '',
    this.description = '',
    this.totalStudents = 0,
    this.totalTeachers = 0,
    this.totalCourses = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert DepartmentModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'departmentId': departmentId,
      'name': name,
      'code': code,
      'hodName': hodName,
      'hodId': hodId,
      'description': description,
      'totalStudents': totalStudents,
      'totalTeachers': totalTeachers,
      'totalCourses': totalCourses,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create DepartmentModel from Firestore document
  factory DepartmentModel.fromMap(Map<String, dynamic> map) {
    return DepartmentModel(
      departmentId: map['departmentId'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      hodName: map['hodName'] ?? '',
      hodId: map['hodId'] ?? '',
      description: map['description'] ?? '',
      totalStudents: map['totalStudents'] ?? 0,
      totalTeachers: map['totalTeachers'] ?? 0,
      totalCourses: map['totalCourses'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create DepartmentModel from Firestore DocumentSnapshot
  factory DepartmentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DepartmentModel.fromMap(data);
  }

  /// Create a copy of DepartmentModel with modified fields
  DepartmentModel copyWith({
    String? departmentId,
    String? name,
    String? code,
    String? hodName,
    String? hodId,
    String? description,
    int? totalStudents,
    int? totalTeachers,
    int? totalCourses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DepartmentModel(
      departmentId: departmentId ?? this.departmentId,
      name: name ?? this.name,
      code: code ?? this.code,
      hodName: hodName ?? this.hodName,
      hodId: hodId ?? this.hodId,
      description: description ?? this.description,
      totalStudents: totalStudents ?? this.totalStudents,
      totalTeachers: totalTeachers ?? this.totalTeachers,
      totalCourses: totalCourses ?? this.totalCourses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DepartmentModel(departmentId: $departmentId, name: $name, code: $code)';
  }
}
