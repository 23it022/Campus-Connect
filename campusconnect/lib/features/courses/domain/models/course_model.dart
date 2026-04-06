import 'package:cloud_firestore/cloud_firestore.dart';

/// Course Model
/// Represents a course/subject in the college
/// Contains course details, teacher assignment, and enrollment information

class CourseModel {
  final String courseId; // Unique course ID
  final String courseName; // Full course name
  final String courseCode; // Course code (e.g., "CSE301")
  final String departmentId; // Department offering this course
  final String departmentName; // Department name (denormalized)
  final String year; // Target year ("1st Year", "2nd Year", etc.)
  final String semester; // Target semester ("1", "2", etc.)
  final String teacherId; // Assigned teacher's UID
  final String teacherName; // Teacher name (denormalized)
  final int credits; // Credit hours (3, 4, etc.)
  final String type; // "Theory" | "Practical" | "Theory+Practical"
  final String description; // Course description
  final String syllabusUrl; // PDF URL from Firebase Storage
  final List<String> enrolledStudents; // Array of student UIDs
  final int totalStudents; // Enrollment count
  final DateTime createdAt; // Course creation timestamp
  final DateTime updatedAt; // Last update timestamp

  CourseModel({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.departmentId,
    this.departmentName = '',
    required this.year,
    required this.semester,
    this.teacherId = '',
    this.teacherName = '',
    this.credits = 0,
    this.type = 'Theory',
    this.description = '',
    this.syllabusUrl = '',
    List<String>? enrolledStudents,
    this.totalStudents = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : enrolledStudents = enrolledStudents ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert CourseModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'year': year,
      'semester': semester,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'credits': credits,
      'type': type,
      'description': description,
      'syllabusUrl': syllabusUrl,
      'enrolledStudents': enrolledStudents,
      'totalStudents': totalStudents,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create CourseModel from Firestore document
  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      courseCode: map['courseCode'] ?? '',
      departmentId: map['departmentId'] ?? '',
      departmentName: map['departmentName'] ?? '',
      year: map['year'] ?? '',
      semester: map['semester'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      credits: map['credits'] ?? 0,
      type: map['type'] ?? 'Theory',
      description: map['description'] ?? '',
      syllabusUrl: map['syllabusUrl'] ?? '',
      enrolledStudents: List<String>.from(map['enrolledStudents'] ?? []),
      totalStudents: map['totalStudents'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create CourseModel from Firestore DocumentSnapshot
  factory CourseModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourseModel.fromMap(data);
  }

  /// Create a copy of CourseModel with modified fields
  CourseModel copyWith({
    String? courseId,
    String? courseName,
    String? courseCode,
    String? departmentId,
    String? departmentName,
    String? year,
    String? semester,
    String? teacherId,
    String? teacherName,
    int? credits,
    String? type,
    String? description,
    String? syllabusUrl,
    List<String>? enrolledStudents,
    int? totalStudents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      credits: credits ?? this.credits,
      type: type ?? this.type,
      description: description ?? this.description,
      syllabusUrl: syllabusUrl ?? this.syllabusUrl,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      totalStudents: totalStudents ?? this.totalStudents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if a student is enrolled in this course
  bool isStudentEnrolled(String studentId) {
    return enrolledStudents.contains(studentId);
  }

  @override
  String toString() {
    return 'CourseModel(courseId: $courseId, courseName: $courseName, courseCode: $courseCode, teacher: $teacherName)';
  }
}
