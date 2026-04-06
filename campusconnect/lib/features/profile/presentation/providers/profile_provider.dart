import '../../../../core/base/base_provider.dart';
import '../../data/services/feedback_service.dart';
import '../../data/services/support_service.dart';
import '../../domain/models/feedback_model.dart';
import '../../domain/models/support_ticket_model.dart';

/// Profile Provider
/// Manages state for feedback and support features
class ProfileProvider extends BaseProvider {
  final FeedbackService _feedbackService = FeedbackService();
  final SupportService _supportService = SupportService();

  // Feedback state
  List<FeedbackModel> _userFeedback = [];
  double _averageRating = 0.0;

  // Support ticket state
  List<SupportTicketModel> _userTickets = [];
  SupportTicketModel? _selectedTicket;

  // Getters
  List<FeedbackModel> get userFeedback => _userFeedback;
  double get averageRating => _averageRating;
  List<SupportTicketModel> get userTickets => _userTickets;
  SupportTicketModel? get selectedTicket => _selectedTicket;

  // ========== FEEDBACK OPERATIONS ==========

  /// Submit feedback
  Future<bool> submitFeedback({
    required String userId,
    required String userName,
    required int rating,
    required String comment,
    required String category,
  }) async {
    final result = await executeOperation(() async {
      final feedbackId = await _feedbackService.submitFeedback(
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        category: category,
      );

      // Reload user feedback after submission
      await loadUserFeedback(userId);

      return feedbackId;
    });

    return result != null;
  }

  /// Load user's feedback history
  Future<void> loadUserFeedback(String userId) async {
    await executeOperation(() async {
      _userFeedback = await _feedbackService.getUserFeedback(userId);
      notifyListeners();
    });
  }

  /// Load average rating
  Future<void> loadAverageRating() async {
    await executeOperation(() async {
      _averageRating = await _feedbackService.getAverageRating();
      notifyListeners();
    });
  }

  /// Delete feedback
  Future<bool> deleteFeedback(String feedbackId, String userId) async {
    final result = await executeOperation(() async {
      await _feedbackService.deleteFeedback(feedbackId);

      // Reload feedback after deletion
      await loadUserFeedback(userId);
    });

    return result != null;
  }

  // ========== SUPPORT TICKET OPERATIONS ==========

  /// Create support ticket
  Future<bool> createTicket({
    required String userId,
    required String userName,
    required String subject,
    required String description,
    required String category,
    required String priority,
  }) async {
    final result = await executeOperation(() async {
      final ticketId = await _supportService.createTicket(
        userId: userId,
        userName: userName,
        subject: subject,
        description: description,
        category: category,
        priority: priority,
      );

      // Reload tickets after creation
      await loadUserTickets(userId);

      return ticketId;
    });

    return result != null;
  }

  /// Load user's tickets
  Future<void> loadUserTickets(String userId) async {
    await executeOperation(() async {
      _userTickets = await _supportService.getUserTickets(userId);
      notifyListeners();
    });
  }

  /// Load ticket by ID
  Future<void> loadTicket(String ticketId) async {
    await executeOperation(() async {
      _selectedTicket = await _supportService.getTicketById(ticketId);
      notifyListeners();
    });
  }

  /// Update ticket status
  Future<bool> updateTicketStatus(
      String ticketId, String status, String userId) async {
    final result = await executeOperation(() async {
      await _supportService.updateTicketStatus(ticketId, status);

      // Reload ticket and tickets list
      await loadTicket(ticketId);
      await loadUserTickets(userId);
    });

    return result != null;
  }

  /// Delete ticket
  Future<bool> deleteTicket(String ticketId, String userId) async {
    final result = await executeOperation(() async {
      await _supportService.deleteTicket(ticketId);

      // Reload tickets after deletion
      await loadUserTickets(userId);
      _selectedTicket = null;
    });

    return result != null;
  }

  /// Clear selected ticket
  void clearSelectedTicket() {
    _selectedTicket = null;
    notifyListeners();
  }

  /// Get open tickets count
  int get openTicketsCount {
    return _userTickets.where((ticket) => ticket.isOpen).length;
  }

  /// Get resolved tickets count
  int get resolvedTicketsCount {
    return _userTickets
        .where((ticket) =>
            ticket.status == 'resolved' || ticket.status == 'closed')
        .length;
  }
}
