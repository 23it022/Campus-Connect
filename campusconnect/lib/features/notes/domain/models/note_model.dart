import 'package:cloud_firestore/cloud_firestore.dart';

/// Note Model
/// Represents study materials and notes uploaded by teachers
/// Contains PDF/document information and engagement metrics

class NoteModel {
  final String noteId; // Unique note ID
  final String courseId; // Course ID reference
  final String courseName; // Course name (denormalized)
  final String courseCode; // Course code (denormalized)
  final String departmentId; // Department ID
  final String departmentName; // Department name (denormalized)
  final String year; // Target year
  final String semester; // Target semester
  final String title; // Note title (e.g., "Chapter 1 - Introduction")
  final String description; // Description of content
  final String topic; // Topic/Unit name
  final String fileUrl; // PDF URL from Firebase Storage
  final String fileName; // Original file name
  final int fileSize; // File size in bytes
  final String fileType; // File type (pdf, doc, ppt)
  final String uploadedBy; // Teacher UID who uploaded
  final String uploadedByName; // Teacher name (denormalized)
  final int downloadCount; // Number of downloads
  final int viewCount; // Number of views
  final DateTime createdAt; // Upload timestamp
  final DateTime updatedAt; // Last update timestamp

  NoteModel({
    required this.noteId,
    required this.courseId,
    this.courseName = '',
    this.courseCode = '',
    this.departmentId = '',
    this.departmentName = '',
    this.year = '',
    this.semester = '',
    required this.title,
    this.description = '',
    this.topic = '',
    required this.fileUrl,
    this.fileName = '',
    this.fileSize = 0,
    this.fileType = 'pdf',
    required this.uploadedBy,
    this.uploadedByName = '',
    this.downloadCount = 0,
    this.viewCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert NoteModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'noteId': noteId,
      'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'year': year,
      'semester': semester,
      'title': title,
      'description': description,
      'topic': topic,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileType': fileType,
      'uploadedBy': uploadedBy,
      'uploadedByName': uploadedByName,
      'downloadCount': downloadCount,
      'viewCount': viewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create NoteModel from Firestore document
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      noteId: map['noteId'] ?? '',
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      courseCode: map['courseCode'] ?? '',
      departmentId: map['departmentId'] ?? '',
      departmentName: map['departmentName'] ?? '',
      year: map['year'] ?? '',
      semester: map['semester'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      topic: map['topic'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      fileType: map['fileType'] ?? 'pdf',
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedByName: map['uploadedByName'] ?? '',
      downloadCount: map['downloadCount'] ?? 0,
      viewCount: map['viewCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create NoteModel from Firestore DocumentSnapshot
  factory NoteModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel.fromMap(data);
  }

  /// Create a copy of NoteModel with modified fields
  NoteModel copyWith({
    String? noteId,
    String? courseId,
    String? courseName,
    String? courseCode,
    String? departmentId,
    String? departmentName,
    String? year,
    String? semester,
    String? title,
    String? description,
    String? topic,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? fileType,
    String? uploadedBy,
    String? uploadedByName,
    int? downloadCount,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      noteId: noteId ?? this.noteId,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      title: title ?? this.title,
      description: description ?? this.description,
      topic: topic ?? this.topic,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedByName: uploadedByName ?? this.uploadedByName,
      downloadCount: downloadCount ?? this.downloadCount,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get file size in human-readable format
  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  String toString() {
    return 'NoteModel(noteId: $noteId, title: $title, course: $courseName)';
  }
}
