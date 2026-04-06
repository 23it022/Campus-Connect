import 'package:cloud_firestore/cloud_firestore.dart';

/// Report Model
/// Represents a report submitted by a user for inappropriate content

enum ReportReason {
  spam,
  harassment,
  falseInformation,
  hateSpeech,
  violence,
  inappropriateContent,
  other;

  String get label {
    switch (this) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return 'Harassment or Bullying';
      case ReportReason.falseInformation:
        return 'False Information';
      case ReportReason.hateSpeech:
        return 'Hate Speech';
      case ReportReason.violence:
        return 'Violence or Dangerous Content';
      case ReportReason.inappropriateContent:
        return 'Inappropriate Content';
      case ReportReason.other:
        return 'Other';
    }
  }

  static ReportReason fromString(String value) {
    return ReportReason.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => ReportReason.other,
    );
  }
}

class ReportModel {
  final String reportId;
  final String postId;
  final String reporterId;
  final String reporterName;
  final ReportReason reason;
  final String details;
  final DateTime timestamp;
  final bool isReviewed;

  ReportModel({
    required this.reportId,
    required this.postId,
    required this.reporterId,
    required this.reporterName,
    required this.reason,
    this.details = '',
    DateTime? timestamp,
    this.isReviewed = false,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'postId': postId,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reason': reason.name,
      'details': details,
      'timestamp': Timestamp.fromDate(timestamp),
      'isReviewed': isReviewed,
    };
  }

  /// Create from Map
  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      reportId: map['reportId'] ?? '',
      postId: map['postId'] ?? '',
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? '',
      reason: ReportReason.fromString(map['reason'] ?? 'other'),
      details: map['details'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isReviewed: map['isReviewed'] ?? false,
    );
  }

  /// Create from DocumentSnapshot
  factory ReportModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel.fromMap(data);
  }
}
