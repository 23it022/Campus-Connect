import 'package:cloud_firestore/cloud_firestore.dart';

/// Announcement Model
/// Represents an announcement posted by a teacher
class AnnouncementModel {
  final String announcementId;
  final String teacherId;
  final String teacherName;
  final List<String> subjectIds;
  final String title;
  final String message;
  final String imageUrl;
  final String fileUrl;
  final DateTime createdAt;

  AnnouncementModel({
    required this.announcementId,
    required this.teacherId,
    this.teacherName = '',
    List<String>? subjectIds,
    required this.title,
    required this.message,
    this.imageUrl = '',
    this.fileUrl = '',
    DateTime? createdAt,
  })  : subjectIds = subjectIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Convert AnnouncementModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'announcementId': announcementId,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'subjectIds': subjectIds,
      'title': title,
      'message': message,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create AnnouncementModel from Firestore document
  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      announcementId: map['announcementId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      subjectIds: List<String>.from(map['subjectIds'] ?? []),
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create AnnouncementModel from Firestore DocumentSnapshot
  factory AnnouncementModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel.fromMap(data);
  }

  /// Create a copy of AnnouncementModel with modified fields
  AnnouncementModel copyWith({
    String? announcementId,
    String? teacherId,
    String? teacherName,
    List<String>? subjectIds,
    String? title,
    String? message,
    String? imageUrl,
    String? fileUrl,
    DateTime? createdAt,
  }) {
    return AnnouncementModel(
      announcementId: announcementId ?? this.announcementId,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      subjectIds: subjectIds ?? this.subjectIds,
      title: title ?? this.title,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if announcement has an image
  bool get hasImage => imageUrl.isNotEmpty;

  /// Check if announcement has a file attachment
  bool get hasFile => fileUrl.isNotEmpty;

  @override
  String toString() {
    return 'AnnouncementModel(announcementId: $announcementId, title: $title)';
  }
}
