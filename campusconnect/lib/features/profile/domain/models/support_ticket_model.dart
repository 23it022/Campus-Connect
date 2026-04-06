import 'package:cloud_firestore/cloud_firestore.dart';

/// Support Ticket Model
/// Represents a support request from a user
class SupportTicketModel {
  final String ticketId;
  final String userId;
  final String userName;
  final String subject;
  final String description;
  final String category;
  final String status; // open, in_progress, resolved, closed
  final String priority; // low, medium, high
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? adminResponse;

  SupportTicketModel({
    required this.ticketId,
    required this.userId,
    required this.userName,
    required this.subject,
    required this.description,
    required this.category,
    this.status = 'open',
    this.priority = 'medium',
    DateTime? createdAt,
    this.resolvedAt,
    this.adminResponse,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Get status color
  String get statusColor {
    switch (status) {
      case 'open':
        return '#FF9800'; // Orange
      case 'in_progress':
        return '#2196F3'; // Blue
      case 'resolved':
        return '#4CAF50'; // Green
      case 'closed':
        return '#9E9E9E'; // Grey
      default:
        return '#9E9E9E';
    }
  }

  /// Get priority color
  String get priorityColor {
    switch (priority) {
      case 'low':
        return '#4CAF50'; // Green
      case 'medium':
        return '#FF9800'; // Orange
      case 'high':
        return '#F44336'; // Red
      default:
        return '#9E9E9E';
    }
  }

  /// Check if ticket is open
  bool get isOpen => status == 'open' || status == 'in_progress';

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'userId': userId,
      'userName': userName,
      'subject': subject,
      'description': description,
      'category': category,
      'status': status,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'adminResponse': adminResponse,
    };
  }

  /// Create from Firestore map
  factory SupportTicketModel.fromMap(Map<String, dynamic> map) {
    return SupportTicketModel(
      ticketId: map['ticketId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      subject: map['subject'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
      status: map['status'] ?? 'open',
      priority: map['priority'] ?? 'medium',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
      adminResponse: map['adminResponse'],
    );
  }

  /// Create from Firestore document
  factory SupportTicketModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportTicketModel.fromMap(data);
  }

  /// Copy with method
  SupportTicketModel copyWith({
    String? ticketId,
    String? userId,
    String? userName,
    String? subject,
    String? description,
    String? category,
    String? status,
    String? priority,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? adminResponse,
  }) {
    return SupportTicketModel(
      ticketId: ticketId ?? this.ticketId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      adminResponse: adminResponse ?? this.adminResponse,
    );
  }

  @override
  String toString() {
    return 'SupportTicketModel(id: $ticketId, subject: $subject, status: $status)';
  }
}
