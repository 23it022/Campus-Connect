import 'package:cloud_firestore/cloud_firestore.dart';

/// Timetable Model
/// Represents class schedules/timetables
/// Contains timetable document information and validity period

class TimetableModel {
  final String timetableId; // Unique timetable ID
  final String departmentId; // Department ID
  final String departmentName; // Department name (denormalized)
  final String year; // Target year
  final String semester; // Target semester
  final String title; // Timetable title
  final String description; // Description
  final String type; // "Weekly" | "Exam" | "Special"
  final String fileUrl; // PDF/Image URL from Firebase Storage
  final String fileName; // Original file name
  final DateTime validFrom; // Start date of validity
  final DateTime validTo; // End date of validity
  final String uploadedBy; // Admin/Teacher UID who uploaded
  final String uploadedByName; // Uploader name (denormalized)
  final Map<String, dynamic>? schedule; // Optional structured schedule data
  final bool isActive; // Whether this is the current timetable
  final DateTime createdAt; // Upload timestamp
  final DateTime updatedAt; // Last update timestamp

  TimetableModel({
    required this.timetableId,
    required this.departmentId,
    this.departmentName = '',
    required this.year,
    required this.semester,
    required this.title,
    this.description = '',
    this.type = 'Weekly',
    required this.fileUrl,
    this.fileName = '',
    DateTime? validFrom,
    DateTime? validTo,
    required this.uploadedBy,
    this.uploadedByName = '',
    this.schedule,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : validFrom = validFrom ?? DateTime.now(),
        validTo = validTo ?? DateTime.now().add(const Duration(days: 180)),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert TimetableModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'timetableId': timetableId,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'year': year,
      'semester': semester,
      'title': title,
      'description': description,
      'type': type,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'validFrom': Timestamp.fromDate(validFrom),
      'validTo': Timestamp.fromDate(validTo),
      'uploadedBy': uploadedBy,
      'uploadedByName': uploadedByName,
      if (schedule != null) 'schedule': schedule,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create TimetableModel from Firestore document
  factory TimetableModel.fromMap(Map<String, dynamic> map) {
    return TimetableModel(
      timetableId: map['timetableId'] ?? '',
      departmentId: map['departmentId'] ?? '',
      departmentName: map['departmentName'] ?? '',
      year: map['year'] ?? '',
      semester: map['semester'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'Weekly',
      fileUrl: map['fileUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      validFrom: (map['validFrom'] as Timestamp?)?.toDate() ?? DateTime.now(),
      validTo: (map['validTo'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 180)),
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedByName: map['uploadedByName'] ?? '',
      schedule: map['schedule'] as Map<String, dynamic>?,
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create TimetableModel from Firestore DocumentSnapshot
  factory TimetableModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TimetableModel.fromMap(data);
  }

  /// Create a copy of TimetableModel with modified fields
  TimetableModel copyWith({
    String? timetableId,
    String? departmentId,
    String? departmentName,
    String? year,
    String? semester,
    String? title,
    String? description,
    String? type,
    String? fileUrl,
    String? fileName,
    DateTime? validFrom,
    DateTime? validTo,
    String? uploadedBy,
    String? uploadedByName,
    Map<String, dynamic>? schedule,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimetableModel(
      timetableId: timetableId ?? this.timetableId,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedByName: uploadedByName ?? this.uploadedByName,
      schedule: schedule ?? this.schedule,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if timetable is currently valid
  bool get isValid {
    final now = DateTime.now();
    return now.isAfter(validFrom) && now.isBefore(validTo);
  }

  @override
  String toString() {
    return 'TimetableModel(timetableId: $timetableId, title: $title, type: $type)';
  }
}
