import 'package:cloud_firestore/cloud_firestore.dart';

/// Assignment Model
/// Represents an assignment created by a teacher
class AssignmentModel {
  final String assignmentId;
  final String subjectId;
  final String teacherId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String fileUrl;
  final String fileName;
  final int maxMarks;
  final DateTime createdAt;

  AssignmentModel({
    required this.assignmentId,
    required this.subjectId,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.fileUrl = '',
    this.fileName = '',
    this.maxMarks = 100,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert AssignmentModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'assignmentId': assignmentId,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'fileUrl': fileUrl,
      'fileName': fileName,
      'maxMarks': maxMarks,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create AssignmentModel from Firestore document
  factory AssignmentModel.fromMap(Map<String, dynamic> map) {
    return AssignmentModel(
      assignmentId: map['assignmentId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fileUrl: map['fileUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      maxMarks: map['maxMarks'] ?? 100,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create AssignmentModel from Firestore DocumentSnapshot
  factory AssignmentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AssignmentModel.fromMap(data);
  }

  /// Create a copy of AssignmentModel with modified fields
  AssignmentModel copyWith({
    String? assignmentId,
    String? subjectId,
    String? teacherId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? fileUrl,
    String? fileName,
    int? maxMarks,
    DateTime? createdAt,
  }) {
    return AssignmentModel(
      assignmentId: assignmentId ?? this.assignmentId,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      maxMarks: maxMarks ?? this.maxMarks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if assignment is overdue
  bool get isOverdue => DateTime.now().isAfter(dueDate);

  /// Check if assignment has a file attached
  bool get hasFile => fileUrl.isNotEmpty;

  /// Get days until due
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  @override
  String toString() {
    return 'AssignmentModel(assignmentId: $assignmentId, title: $title, dueDate: $dueDate)';
  }
}
