import 'package:cloud_firestore/cloud_firestore.dart';

/// Subject Model
/// Represents a subject/course taught by a teacher
class SubjectModel {
  final String subjectId;
  final String teacherId;
  final String subjectName;
  final String subjectCode;
  final String semester;
  final String description;
  final List<String> studentIds;
  final DateTime createdAt;

  SubjectModel({
    required this.subjectId,
    required this.teacherId,
    required this.subjectName,
    required this.subjectCode,
    required this.semester,
    this.description = '',
    List<String>? studentIds,
    DateTime? createdAt,
  })  : studentIds = studentIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Convert SubjectModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'teacherId': teacherId,
      'subjectName': subjectName,
      'subjectCode': subjectCode,
      'semester': semester,
      'description': description,
      'studentIds': studentIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create SubjectModel from Firestore document
  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      subjectId: map['subjectId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      subjectCode: map['subjectCode'] ?? '',
      semester: map['semester'] ?? '',
      description: map['description'] ?? '',
      studentIds: List<String>.from(map['studentIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create SubjectModel from Firestore DocumentSnapshot
  factory SubjectModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubjectModel.fromMap(data);
  }

  /// Create a copy of SubjectModel with modified fields
  SubjectModel copyWith({
    String? subjectId,
    String? teacherId,
    String? subjectName,
    String? subjectCode,
    String? semester,
    String? description,
    List<String>? studentIds,
    DateTime? createdAt,
  }) {
    return SubjectModel(
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      subjectName: subjectName ?? this.subjectName,
      subjectCode: subjectCode ?? this.subjectCode,
      semester: semester ?? this.semester,
      description: description ?? this.description,
      studentIds: studentIds ?? this.studentIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get student count
  int get studentCount => studentIds.length;

  @override
  String toString() {
    return 'SubjectModel(subjectId: $subjectId, subjectName: $subjectName, subjectCode: $subjectCode)';
  }
}
