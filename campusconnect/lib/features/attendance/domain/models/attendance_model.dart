import 'package:cloud_firestore/cloud_firestore.dart';

/// Attendance Model
/// Represents daily attendance for a course
/// Contains attendance records, present/absent student lists, and class details

class AttendanceModel {
  final String attendanceId; // Unique attendance record ID
  final String courseId; // Reference to course
  final String courseName; // Course name (denormalized)
  final String courseCode; // Course code (denormalized)
  final String teacherId; // Teacher who marked attendance
  final String teacherName; // Teacher name (denormalized)
  final DateTime date; // Date of class
  final String departmentId; // Department ID
  final String departmentName; // Department name (denormalized)
  final String year; // Year (e.g., "2nd Year")
  final String semester; // Semester (e.g., "3")
  final List<String> presentStudents; // Array of present student UIDs
  final List<String> absentStudents; // Array of absent student UIDs
  final int totalStudents; // Total enrolled students
  final int presentCount; // Number of students present
  final int absentCount; // Number of students absent
  final String topic; // Topic covered in class
  final String remarks; // Additional remarks
  final DateTime createdAt; // Record creation timestamp
  final DateTime updatedAt; // Last update timestamp

  AttendanceModel({
    required this.attendanceId,
    required this.courseId,
    this.courseName = '',
    this.courseCode = '',
    required this.teacherId,
    this.teacherName = '',
    required this.date,
    this.departmentId = '',
    this.departmentName = '',
    this.year = '',
    this.semester = '',
    List<String>? presentStudents,
    List<String>? absentStudents,
    this.totalStudents = 0,
    int? presentCount,
    int? absentCount,
    this.topic = '',
    this.remarks = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : presentStudents = presentStudents ?? [],
        absentStudents = absentStudents ?? [],
        presentCount = presentCount ?? (presentStudents?.length ?? 0),
        absentCount = absentCount ?? (absentStudents?.length ?? 0),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert AttendanceModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'attendanceId': attendanceId,
      'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'date': Timestamp.fromDate(date),
      'departmentId': departmentId,
      'departmentName': departmentName,
      'year': year,
      'semester': semester,
      'presentStudents': presentStudents,
      'absentStudents': absentStudents,
      'totalStudents': totalStudents,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'topic': topic,
      'remarks': remarks,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create AttendanceModel from Firestore document
  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      attendanceId: map['attendanceId'] ?? '',
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      courseCode: map['courseCode'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      departmentId: map['departmentId'] ?? '',
      departmentName: map['departmentName'] ?? '',
      year: map['year'] ?? '',
      semester: map['semester'] ?? '',
      presentStudents: List<String>.from(map['presentStudents'] ?? []),
      absentStudents: List<String>.from(map['absentStudents'] ?? []),
      totalStudents: map['totalStudents'] ?? 0,
      presentCount: map['presentCount'] ?? 0,
      absentCount: map['absentCount'] ?? 0,
      topic: map['topic'] ?? '',
      remarks: map['remarks'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create AttendanceModel from Firestore DocumentSnapshot
  factory AttendanceModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceModel.fromMap(data);
  }

  /// Create a copy of AttendanceModel with modified fields
  AttendanceModel copyWith({
    String? attendanceId,
    String? courseId,
    String? courseName,
    String? courseCode,
    String? teacherId,
    String? teacherName,
    DateTime? date,
    String? departmentId,
    String? departmentName,
    String? year,
    String? semester,
    List<String>? presentStudents,
    List<String>? absentStudents,
    int? totalStudents,
    int? presentCount,
    int? absentCount,
    String? topic,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceModel(
      attendanceId: attendanceId ?? this.attendanceId,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      date: date ?? this.date,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      presentStudents: presentStudents ?? this.presentStudents,
      absentStudents: absentStudents ?? this.absentStudents,
      totalStudents: totalStudents ?? this.totalStudents,
      presentCount: presentCount ?? this.presentCount,
      absentCount: absentCount ?? this.absentCount,
      topic: topic ?? this.topic,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if a student was present
  bool isStudentPresent(String studentId) {
    return presentStudents.contains(studentId);
  }

  /// Check if a student was absent
  bool isStudentAbsent(String studentId) {
    return absentStudents.contains(studentId);
  }

  /// Calculate attendance percentage
  double get attendancePercentage {
    if (totalStudents == 0) return 0.0;
    return (presentCount / totalStudents) * 100;
  }

  @override
  String toString() {
    return 'AttendanceModel(courseId: $courseId, date: $date, present: $presentCount/$totalStudents)';
  }
}
