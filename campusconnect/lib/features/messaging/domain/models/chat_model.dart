import 'package:cloud_firestore/cloud_firestore.dart';

/// Chat Model
/// Represents a private one-on-one chat conversation
/// Contains participant information and last message data

class ChatModel {
  final String chatId; // Unique chat ID (sorted UIDs)
  final List<String> participants; // Array of 2 user UIDs
  final Map<String, String> participantNames; // Map of UID -> Name
  final Map<String, String> participantRoles; // Map of UID -> Role
  final Map<String, String>
      participantImages; // Map of UID -> Profile Image URL
  final String lastMessage; // Last message text
  final String lastMessageBy; // UID of last message sender
  final DateTime lastMessageTime; // Time of last message
  final Map<String, int> unreadCount; // Map of UID -> unread message count
  final DateTime createdAt; // Chat creation timestamp
  final DateTime updatedAt; // Last update timestamp

  ChatModel({
    required this.chatId,
    required this.participants,
    Map<String, String>? participantNames,
    Map<String, String>? participantRoles,
    Map<String, String>? participantImages,
    this.lastMessage = '',
    this.lastMessageBy = '',
    DateTime? lastMessageTime,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : participantNames = participantNames ?? {},
        participantRoles = participantRoles ?? {},
        participantImages = participantImages ?? {},
        lastMessageTime = lastMessageTime ?? DateTime.now(),
        unreadCount = unreadCount ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert ChatModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'participants': participants,
      'participantNames': participantNames,
      'participantRoles': participantRoles,
      'participantImages': participantImages,
      'lastMessage': lastMessage,
      'lastMessageBy': lastMessageBy,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create ChatModel from Firestore document
  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      chatId: map['chatId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      participantRoles: Map<String, String>.from(map['participantRoles'] ?? {}),
      participantImages:
          Map<String, String>.from(map['participantImages'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageBy: map['lastMessageBy'] ?? '',
      lastMessageTime:
          (map['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create ChatModel from Firestore DocumentSnapshot
  factory ChatModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel.fromMap(data);
  }

  /// Create a copy of ChatModel with modified fields
  ChatModel copyWith({
    String? chatId,
    List<String>? participants,
    Map<String, String>? participantNames,
    Map<String, String>? participantRoles,
    Map<String, String>? participantImages,
    String? lastMessage,
    String? lastMessageBy,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      chatId: chatId ?? this.chatId,
      participants: participants ?? this.participants,
      participantNames: participantNames ?? this.participantNames,
      participantRoles: participantRoles ?? this.participantRoles,
      participantImages: participantImages ?? this.participantImages,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageBy: lastMessageBy ?? this.lastMessageBy,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get other participant's ID (for current user)
  String getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  /// Get other participant's name
  String getOtherParticipantName(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantNames[otherId] ?? 'Unknown';
  }

  /// Get other participant's role
  String getOtherParticipantRole(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantRoles[otherId] ?? '';
  }

  /// Get other participant's image
  String getOtherParticipantImage(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    return participantImages[otherId] ?? '';
  }

  /// Get unread count for current user
  int getUnreadCountForUser(String userId) {
    return unreadCount[userId] ?? 0;
  }

  /// Check if current user has unread messages
  bool hasUnreadMessages(String userId) {
    return getUnreadCountForUser(userId) > 0;
  }

  @override
  String toString() {
    return 'ChatModel(chatId: $chatId, participants: $participants, lastMessage: $lastMessage)';
  }
}
