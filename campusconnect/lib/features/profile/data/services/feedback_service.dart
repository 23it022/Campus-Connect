import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/feedback_model.dart';

/// Feedback Service
/// Handles Firebase operations for user feedback
class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'feedback';

  /// Submit feedback
  Future<String> submitFeedback({
    required String userId,
    required String userName,
    required int rating,
    required String comment,
    required String category,
  }) async {
    try {
      // Create feedback document
      final feedbackRef = _firestore.collection(_collection).doc();

      final feedback = FeedbackModel(
        feedbackId: feedbackRef.id,
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        category: category,
      );

      await feedbackRef.set(feedback.toMap());
      return feedbackRef.id;
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  /// Get user's feedback history
  Future<List<FeedbackModel>> getUserFeedback(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FeedbackModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load feedback: $e');
    }
  }

  /// Get all feedback (admin function)
  Future<List<FeedbackModel>> getAllFeedback({
    String? category,
    int? minRating,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      // Apply filters
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }
      if (minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => FeedbackModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load all feedback: $e');
    }
  }

  /// Get average rating
  Future<double> getAverageRating() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();

      if (snapshot.docs.isEmpty) return 0.0;

      final totalRating = snapshot.docs.fold<int>(
        0,
        (sum, doc) => sum + (doc.data()['rating'] as int? ?? 0),
      );

      return totalRating / snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to calculate average rating: $e');
    }
  }

  /// Get feedback count by rating
  Future<Map<int, int>> getRatingDistribution() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();

      final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (var doc in snapshot.docs) {
        final rating = doc.data()['rating'] as int? ?? 0;
        if (rating >= 1 && rating <= 5) {
          distribution[rating] = (distribution[rating] ?? 0) + 1;
        }
      }

      return distribution;
    } catch (e) {
      throw Exception('Failed to get rating distribution: $e');
    }
  }

  /// Delete feedback
  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _firestore.collection(_collection).doc(feedbackId).delete();
    } catch (e) {
      throw Exception('Failed to delete feedback: $e');
    }
  }

  /// Stream user's feedback
  Stream<List<FeedbackModel>> streamUserFeedback(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromDocument(doc))
            .toList());
  }
}
