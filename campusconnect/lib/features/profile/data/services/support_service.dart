import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/support_ticket_model.dart';

/// Support Service
/// Handles Firebase operations for support tickets
class SupportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'support_tickets';

  /// Create support ticket
  Future<String> createTicket({
    required String userId,
    required String userName,
    required String subject,
    required String description,
    required String category,
    required String priority,
  }) async {
    try {
      // Create ticket document
      final ticketRef = _firestore.collection(_collection).doc();

      final ticket = SupportTicketModel(
        ticketId: ticketRef.id,
        userId: userId,
        userName: userName,
        subject: subject,
        description: description,
        category: category,
        priority: priority,
      );

      await ticketRef.set(ticket.toMap());
      return ticketRef.id;
    } catch (e) {
      throw Exception('Failed to create support ticket: $e');
    }
  }

  /// Get user's tickets
  Future<List<SupportTicketModel>> getUserTickets(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SupportTicketModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load tickets: $e');
    }
  }

  /// Get ticket by ID
  Future<SupportTicketModel?> getTicketById(String ticketId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(ticketId).get();

      if (!doc.exists) return null;

      return SupportTicketModel.fromDocument(doc);
    } catch (e) {
      throw Exception('Failed to load ticket: $e');
    }
  }

  /// Update ticket status
  Future<void> updateTicketStatus(String ticketId, String status) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
      };

      // If resolving, add resolved timestamp
      if (status == 'resolved' || status == 'closed') {
        updates['resolvedAt'] = Timestamp.now();
      }

      await _firestore.collection(_collection).doc(ticketId).update(updates);
    } catch (e) {
      throw Exception('Failed to update ticket status: $e');
    }
  }

  /// Add admin response
  Future<void> addAdminResponse(String ticketId, String response) async {
    try {
      await _firestore.collection(_collection).doc(ticketId).update({
        'adminResponse': response,
        'status': 'in_progress',
      });
    } catch (e) {
      throw Exception('Failed to add admin response: $e');
    }
  }

  /// Delete ticket
  Future<void> deleteTicket(String ticketId) async {
    try {
      await _firestore.collection(_collection).doc(ticketId).delete();
    } catch (e) {
      throw Exception('Failed to delete ticket: $e');
    }
  }

  /// Get all tickets (admin function)
  Future<List<SupportTicketModel>> getAllTickets({
    String? status,
    String? category,
    String? priority,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      // Apply filters
      if (status != null && status != 'all') {
        query = query.where('status', isEqualTo: status);
      }
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }
      if (priority != null && priority != 'all') {
        query = query.where('priority', isEqualTo: priority);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => SupportTicketModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load all tickets: $e');
    }
  }

  /// Stream user's tickets
  Stream<List<SupportTicketModel>> streamUserTickets(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SupportTicketModel.fromDocument(doc))
            .toList());
  }

  /// Stream ticket by ID
  Stream<SupportTicketModel?> streamTicket(String ticketId) {
    return _firestore
        .collection(_collection)
        .doc(ticketId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return SupportTicketModel.fromDocument(doc);
    });
  }

  /// Get ticket statistics for admin
  Future<Map<String, int>> getTicketStats() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();

      final stats = {
        'total': snapshot.docs.length,
        'open': 0,
        'in_progress': 0,
        'resolved': 0,
        'closed': 0,
      };

      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] as String? ?? 'open';
        stats[status] = (stats[status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get ticket statistics: $e');
    }
  }
}
