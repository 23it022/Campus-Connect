import 'package:cloud_firestore/cloud_firestore.dart';

/// Assignment Submission Model
/// Represents a student's submission for an assignment
class AssignmentSubmissionModel {
  final String submissionId;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final String fileUrl;
  final String fileName;
  final DateTime submittedAt;
  final int? marks;
  final String feedback;
  final String status; // pending, graded

  AssignmentSubmissionModel({
    required this.submissionId,
    required this.assignmentId,
    required this.studentId,
    this.studentName = '',
    this.fileUrl = '',
    this.fileName = '',
    DateTime? submittedAt,
    this.marks,
    this.feedback = '',
    this.status = 'pending',
  }) : submittedAt = submittedAt ?? DateTime.now();

  /// Convert AssignmentSubmissionModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'submissionId': submissionId,
      'assignmentId': assignmentId,
      'studentId': studentId,
      'studentName': studentName,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'marks': marks,
      'feedback': feedback,
      'status': status,
    };
  }

  /// Create AssignmentSubmissionModel from Firestore document
  factory AssignmentSubmissionModel.fromMap(Map<String, dynamic> map) {
    return AssignmentSubmissionModel(
      submissionId: map['submissionId'] ?? '',
      assignmentId: map['assignmentId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      submittedAt:
          (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      marks: map['marks'],
      feedback: map['feedback'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }

  /// Create AssignmentSubmissionModel from Firestore DocumentSnapshot
  factory AssignmentSubmissionModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AssignmentSubmissionModel.fromMap(data);
  }

  /// Create a copy of AssignmentSubmissionModel with modified fields
  AssignmentSubmissionModel copyWith({
    String? submissionId,
    String? assignmentId,
    String? studentId,
    String? studentName,
    String? fileUrl,
    String? fileName,
    DateTime? submittedAt,
    int? marks,
    String? feedback,
    String? status,
  }) {
    return AssignmentSubmissionModel(
      submissionId: submissionId ?? this.submissionId,
      assignmentId: assignmentId ?? this.assignmentId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      submittedAt: submittedAt ?? this.submittedAt,
      marks: marks ?? this.marks,
      feedback: feedback ?? this.feedback,
      status: status ?? this.status,
    );
  }

  /// Check if submission is graded
  bool get isGraded => status == 'graded';

  /// Check if submission has a file
  bool get hasFile => fileUrl.isNotEmpty;

  @override
  String toString() {
    return 'AssignmentSubmissionModel(submissionId: $submissionId, studentId: $studentId, status: $status)';
  }
}
