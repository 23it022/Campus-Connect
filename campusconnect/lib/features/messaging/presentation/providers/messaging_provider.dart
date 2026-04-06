import 'package:flutter/foundation.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../data/services/messaging_service.dart';
import '../../domain/models/chat_model.dart';
import '../../domain/models/message_model.dart';

/// Messaging Provider
/// Manages state for messaging functionality
/// Handles chats, messages, and real-time updates

class MessagingProvider with ChangeNotifier {
  final MessagingService _messagingService = MessagingService();

  List<ChatModel> _chats = [];
  List<MessageModel> _currentChatMessages = [];
  bool _isLoading = false;
  String? _error;
  int _totalUnreadCount = 0;

  // Getters
  List<ChatModel> get chats => _chats;
  List<MessageModel> get currentChatMessages => _currentChatMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalUnreadCount => _totalUnreadCount;

  /// Load all chats for a user
  void loadUserChats(String userId) {
    _messagingService.getUserChatsStream(userId).listen(
      (chats) {
        _chats = chats;
        _calculateTotalUnreadCount(userId);
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  /// Load messages for a specific chat
  void loadChatMessages(String chatId) {
    _messagingService.getChatMessagesStream(chatId).listen(
      (messages) {
        _currentChatMessages = messages;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  /// Create or get a chat with another user
  Future<ChatModel?> createOrGetChat({
    required String currentUserId,
    required String otherUserId,
    required UserModel currentUser,
    required UserModel otherUser,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final chat = await _messagingService.createOrGetChat(
        currentUserId: currentUserId,
        otherUserId: otherUserId,
        currentUser: currentUser,
        otherUser: otherUser,
      );

      _isLoading = false;
      notifyListeners();
      return chat;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Send a message
  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
    String imageUrl = '',
  }) async {
    try {
      _error = null;

      await _messagingService.sendMessage(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        text: text,
        imageUrl: imageUrl,
      );

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Mark chat as read
  Future<void> markChatAsRead(String chatId, String userId) async {
    try {
      await _messagingService.markChatAsRead(chatId, userId);
      _calculateTotalUnreadCount(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Calculate total unread count
  void _calculateTotalUnreadCount(String userId) {
    _totalUnreadCount = 0;
    for (var chat in _chats) {
      _totalUnreadCount += chat.getUnreadCountForUser(userId);
    }
  }

  /// Search users for new chat
  Future<List<UserModel>> searchUsers(
      String query, String currentUserId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final users = await _messagingService.searchUsers(query, currentUserId);

      _isLoading = false;
      notifyListeners();
      return users;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  /// Get all users for new chat
  Future<List<UserModel>> getAllUsers(String currentUserId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final users = await _messagingService.getAllUsers(currentUserId);

      _isLoading = false;
      notifyListeners();
      return users;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  /// Clear current chat messages
  void clearCurrentChatMessages() {
    _currentChatMessages = [];
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
