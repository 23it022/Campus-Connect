import 'package:cloud_firestore/cloud_firestore.dart';

/// Syllabus Model
/// Represents course syllabus documents
/// Contains syllabus PDF information and academic details

class SyllabusModel {
  final String syllabusId; // Unique syllabus ID
  final String courseId; // Course ID reference
  final String courseName; // Course name (denormalized)
  final String courseCode; // Course code (denormalized)
  final String departmentId; // Department ID
  final String departmentName; // Department name (denormalized)
  final String year; // Target year
  final String semester; // Target semester
  final String title; // Syllabus title
  final String description; // Description
  final String fileUrl; // PDF URL from Firebase Storage
  final String fileName; // Original file name
  final int fileSize; // File size in bytes
  final String uploadedBy; // Teacher/Admin UID who uploaded
  final String uploadedByName; // Uploader name (denormalized)
  final String academicYear; // Academic year (e.g., "2025-2026")
  final DateTime createdAt; // Upload timestamp
  final DateTime updatedAt; // Last update timestamp

  SyllabusModel({
    required this.syllabusId,
    required this.courseId,
    this.courseName = '',
    this.courseCode = '',
    this.departmentId = '',
    this.departmentName = '',
    this.year = '',
    this.semester = '',
    required this.title,
    this.description = '',
    required this.fileUrl,
    this.fileName = '',
    this.fileSize = 0,
    required this.uploadedBy,
    this.uploadedByName = '',
    this.academicYear = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert SyllabusModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'syllabusId': syllabusId,
      'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'year': year,
      'semester': semester,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'uploadedBy': uploadedBy,
      'uploadedByName': uploadedByName,
      'academicYear': academicYear,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create SyllabusModel from Firestore document
  factory SyllabusModel.fromMap(Map<String, dynamic> map) {
    return SyllabusModel(
      syllabusId: map['syllabusId'] ?? '',
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      courseCode: map['courseCode'] ?? '',
      departmentId: map['departmentId'] ?? '',
      departmentName: map['departmentName'] ?? '',
      year: map['year'] ?? '',
      semester: map['semester'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedByName: map['uploadedByName'] ?? '',
      academicYear: map['academicYear'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create SyllabusModel from Firestore DocumentSnapshot
  factory SyllabusModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SyllabusModel.fromMap(data);
  }

  /// Create a copy of SyllabusModel with modified fields
  SyllabusModel copyWith({
    String? syllabusId,
    String? courseId,
    String? courseName,
    String? courseCode,
    String? departmentId,
    String? departmentName,
    String? year,
    String? semester,
    String? title,
    String? description,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? uploadedBy,
    String? uploadedByName,
    String? academicYear,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SyllabusModel(
      syllabusId: syllabusId ?? this.syllabusId,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      title: title ?? this.title,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedByName: uploadedByName ?? this.uploadedByName,
      academicYear: academicYear ?? this.academicYear,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SyllabusModel(syllabusId: $syllabusId, title: $title, course: $courseName)';
  }
}
