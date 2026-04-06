import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/network/firestore_service.dart';
import '../../../../shared/constants/constants.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../domain/models/chat_model.dart';
import '../../domain/models/message_model.dart';

/// Messaging Service
/// Handles all messaging-related operations with Firestore
/// Provides real-time chat and message functionality

class MessagingService {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  /// Generate a chat ID from two user IDs (sorted to ensure consistency)
  String generateChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  /// Create or get existing chat between two users
  Future<ChatModel> createOrGetChat({
    required String currentUserId,
    required String otherUserId,
    required UserModel currentUser,
    required UserModel otherUser,
  }) async {
    final chatId = generateChatId(currentUserId, otherUserId);

    // Check if chat already exists
    final chatDoc = await _firestoreService.getDocument(
      collection: FirebaseCollections.chats,
      docId: chatId,
    );

    if (chatDoc.exists) {
      return ChatModel.fromDocument(chatDoc);
    }

    // Create new chat
    final newChat = ChatModel(
      chatId: chatId,
      participants: [currentUserId, otherUserId],
      participantNames: {
        currentUserId: currentUser.name,
        otherUserId: otherUser.name,
      },
      participantRoles: {
        currentUserId: currentUser.role,
        otherUserId: otherUser.role,
      },
      participantImages: {
        currentUserId: currentUser.profileImage,
        otherUserId: otherUser.profileImage,
      },
    );

    await _firestoreService.setDocument(
      collection: FirebaseCollections.chats,
      docId: chatId,
      data: newChat.toMap(),
    );

    return newChat;
  }

  /// Get stream of all chats for a user (ordered by last message time)
  Stream<List<ChatModel>> getUserChatsStream(String userId) {
    return _firestoreService
        .streamDocuments(
      collection: FirebaseCollections.chats,
      queryBuilder: (query) => query
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true),
    )
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatModel.fromDocument(doc)).toList();
    });
  }

  /// Send a message in a chat
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
    String imageUrl = '',
  }) async {
    final messageId = _uuid.v4();
    final now = DateTime.now();

    // Create message
    final message = MessageModel(
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      imageUrl: imageUrl,
      timestamp: now,
    );

    // Add message to messages collection
    await _firestoreService.setDocument(
      collection: FirebaseCollections.messages,
      docId: messageId,
      data: message.toMap(),
    );

    // Update chat with last message info
    final chatDoc = await _firestoreService.getDocument(
      collection: FirebaseCollections.chats,
      docId: chatId,
    );

    if (chatDoc.exists) {
      final chat = ChatModel.fromDocument(chatDoc);

      // Get the other participant's ID
      final otherUserId = chat.participants.firstWhere(
        (id) => id != senderId,
        orElse: () => '',
      );

      // Update unread count for the other user
      final updatedUnreadCount = Map<String, int>.from(chat.unreadCount);
      updatedUnreadCount[otherUserId] =
          (updatedUnreadCount[otherUserId] ?? 0) + 1;

      await _firestoreService.updateDocument(
        collection: FirebaseCollections.chats,
        docId: chatId,
        data: {
          'lastMessage': text,
          'lastMessageBy': senderId,
          'lastMessageTime': Timestamp.fromDate(now),
          'unreadCount': updatedUnreadCount,
          'updatedAt': Timestamp.fromDate(now),
        },
      );
    }
  }

  /// Get stream of messages for a specific chat
  Stream<List<MessageModel>> getChatMessagesStream(String chatId) {
    return _firestoreService
        .streamDocuments(
      collection: FirebaseCollections.messages,
      queryBuilder: (query) => query
          .where('chatId', isEqualTo: chatId)
          .orderBy('timestamp', descending: false),
    )
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromDocument(doc))
          .toList();
    });
  }

  /// Mark all messages in a chat as read for a user
  Future<void> markChatAsRead(String chatId, String userId) async {
    final chatDoc = await _firestoreService.getDocument(
      collection: FirebaseCollections.chats,
      docId: chatId,
    );

    if (chatDoc.exists) {
      final chat = ChatModel.fromDocument(chatDoc);

      // Reset unread count for this user
      final updatedUnreadCount = Map<String, int>.from(chat.unreadCount);
      updatedUnreadCount[userId] = 0;

      await _firestoreService.updateDocument(
        collection: FirebaseCollections.chats,
        docId: chatId,
        data: {
          'unreadCount': updatedUnreadCount,
        },
      );
    }

    // Mark all unread messages as read
    final messagesSnapshot = await _firestoreService.getDocuments(
      collection: FirebaseCollections.messages,
      queryBuilder: (query) => query
          .where('chatId', isEqualTo: chatId)
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: userId),
    );

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in messagesSnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Get total unread count for a user across all chats
  Future<int> getTotalUnreadCount(String userId) async {
    final chatsSnapshot = await _firestoreService.getDocuments(
      collection: FirebaseCollections.chats,
      queryBuilder: (query) =>
          query.where('participants', arrayContains: userId),
    );

    int totalUnread = 0;
    for (var doc in chatsSnapshot.docs) {
      final chat = ChatModel.fromDocument(doc);
      totalUnread += chat.getUnreadCountForUser(userId);
    }

    return totalUnread;
  }

  /// Search for users to start a new chat
  Future<List<UserModel>> searchUsers(
      String query, String currentUserId) async {
    final usersSnapshot = await _firestoreService.getDocuments(
      collection: FirebaseCollections.users,
    );

    final users = usersSnapshot.docs
        .map((doc) => UserModel.fromDocument(doc))
        .where((user) =>
            user.uid != currentUserId &&
            user.isActive &&
            (user.name.toLowerCase().contains(query.toLowerCase()) ||
                user.email.toLowerCase().contains(query.toLowerCase())))
        .toList();

    return users;
  }

  /// Get all users for new chat (excluding current user)
  Future<List<UserModel>> getAllUsers(String currentUserId) async {
    final usersSnapshot = await _firestoreService.getDocuments(
      collection: FirebaseCollections.users,
      queryBuilder: (query) => query.where('isActive', isEqualTo: true),
    );

    final users = usersSnapshot.docs
        .map((doc) => UserModel.fromDocument(doc))
        .where((user) => user.uid != currentUserId)
        .toList();

    return users;
  }
}
