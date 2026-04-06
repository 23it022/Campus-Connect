import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/announcement_model.dart';

/// Announcement Service
/// Handles all Firebase operations for announcements
class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _announcementsCollection = 'announcements';

  /// Create new announcement
  Future<AnnouncementModel> createAnnouncement(
      AnnouncementModel announcement) async {
    try {
      final docRef = _firestore.collection(_announcementsCollection).doc();
      final announcementWithId =
          announcement.copyWith(announcementId: docRef.id);

      await docRef.set(announcementWithId.toMap());

      return announcementWithId;
    } catch (e) {
      throw Exception('Failed to create announcement: $e');
    }
  }

  /// Update existing announcement
  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    try {
      await _firestore
          .collection(_announcementsCollection)
          .doc(announcement.announcementId)
          .update(announcement.toMap());
    } catch (e) {
      throw Exception('Failed to update announcement: $e');
    }
  }

  /// Delete announcement
  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _firestore
          .collection(_announcementsCollection)
          .doc(announcementId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete announcement: $e');
    }
  }

  /// Get all announcements by teacher
  Future<List<AnnouncementModel>> getAnnouncementsByTeacher(
      String teacherId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_announcementsCollection)
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AnnouncementModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get announcements: $e');
    }
  }

  /// Get announcements by subject
  Future<List<AnnouncementModel>> getAnnouncementsBySubject(
      String subjectId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_announcementsCollection)
          .where('subjectIds', arrayContains: subjectId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AnnouncementModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get announcements: $e');
    }
  }

  /// Get announcement by ID
  Future<AnnouncementModel?> getAnnouncementById(String announcementId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_announcementsCollection)
          .doc(announcementId)
          .get();

      if (!doc.exists) return null;

      return AnnouncementModel.fromDocument(doc);
    } catch (e) {
      throw Exception('Failed to get announcement: $e');
    }
  }

  /// Get announcements stream for real-time updates
  Stream<List<AnnouncementModel>> getAnnouncementsStream(String teacherId) {
    try {
      return _firestore
          .collection(_announcementsCollection)
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => AnnouncementModel.fromDocument(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to get announcements stream: $e');
    }
  }

  /// Get recent announcements (last 7 days)
  Future<List<AnnouncementModel>> getRecentAnnouncements(
      String teacherId) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final QuerySnapshot snapshot = await _firestore
          .collection(_announcementsCollection)
          .where('teacherId', isEqualTo: teacherId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => AnnouncementModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recent announcements: $e');
    }
  }
}
