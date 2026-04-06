import 'package:cloud_firestore/cloud_firestore.dart';

/// Announcement Model
/// Represents important announcements from admin/teachers
/// Contains announcement content, priority, and target audience

class AnnouncementModel {
  final String announcementId; // Unique announcement ID
  final String title; // Announcement title
  final String message; // Full announcement text
  final String priority; // "low" | "medium" | "high" | "urgent"
  final String targetRole; // "all" | "student" | "teacher"
  final String targetDepartment; // "all" | specific departmentId
  final String targetYear; // "all" | specific year
  final String attachmentUrl; // Optional attachment URL
  final String publishedBy; // Admin/Teacher UID
  final String publishedByName; // Publisher name (denormalized)
  final String publishedByRole; // Publisher role (denormalized)
  final bool isActive; // Show/hide announcement
  final DateTime? expiresAt; // Auto-hide after this date
  final int viewCount; // Number of views
  final DateTime createdAt; // Publication timestamp
  final DateTime updatedAt; // Last update timestamp

  AnnouncementModel({
    required this.announcementId,
    required this.title,
    required this.message,
    this.priority = 'medium',
    this.targetRole = 'all',
    this.targetDepartment = 'all',
    this.targetYear = 'all',
    this.attachmentUrl = '',
    required this.publishedBy,
    this.publishedByName = '',
    this.publishedByRole = '',
    this.isActive = true,
    this.expiresAt,
    this.viewCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert AnnouncementModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'announcementId': announcementId,
      'title': title,
      'message': message,
      'priority': priority,
      'targetRole': targetRole,
      'targetDepartment': targetDepartment,
      'targetYear': targetYear,
      'attachmentUrl': attachmentUrl,
      'publishedBy': publishedBy,
      'publishedByName': publishedByName,
      'publishedByRole': publishedByRole,
      'isActive': isActive,
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      'viewCount': viewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create AnnouncementModel from Firestore document
  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      announcementId: map['announcementId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      priority: map['priority'] ?? 'medium',
      targetRole: map['targetRole'] ?? 'all',
      targetDepartment: map['targetDepartment'] ?? 'all',
      targetYear: map['targetYear'] ?? 'all',
      attachmentUrl: map['attachmentUrl'] ?? '',
      publishedBy: map['publishedBy'] ?? '',
      publishedByName: map['publishedByName'] ?? '',
      publishedByRole: map['publishedByRole'] ?? '',
      isActive: map['isActive'] ?? true,
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      viewCount: map['viewCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
    String? title,
    String? message,
    String? priority,
    String? targetRole,
    String? targetDepartment,
    String? targetYear,
    String? attachmentUrl,
    String? publishedBy,
    String? publishedByName,
    String? publishedByRole,
    bool? isActive,
    DateTime? expiresAt,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnnouncementModel(
      announcementId: announcementId ?? this.announcementId,
      title: title ?? this.title,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      targetRole: targetRole ?? this.targetRole,
      targetDepartment: targetDepartment ?? this.targetDepartment,
      targetYear: targetYear ?? this.targetYear,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      publishedBy: publishedBy ?? this.publishedBy,
      publishedByName: publishedByName ?? this.publishedByName,
      publishedByRole: publishedByRole ?? this.publishedByRole,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if announcement is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get priority color
  String get priorityColor {
    switch (priority) {
      case 'urgent':
        return '#FF0000'; // Red
      case 'high':
        return '#FF6B00'; // Orange
      case 'medium':
        return '#FFB800'; // Yellow
      case 'low':
        return '#4CAF50'; // Green
      default:
        return '#757575'; // Gray
    }
  }

  @override
  String toString() {
    return 'AnnouncementModel(announcementId: $announcementId, title: $title, priority: $priority)';
  }
}
