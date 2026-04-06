import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/subject_model.dart';

/// Subject Service
/// Handles all Firebase operations for subjects/courses
class SubjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _subjectsCollection = 'subjects';

  /// Create new subject
  Future<SubjectModel> createSubject(SubjectModel subject) async {
    try {
      final docRef = _firestore.collection(_subjectsCollection).doc();
      final subjectWithId = subject.copyWith(subjectId: docRef.id);

      await docRef.set(subjectWithId.toMap());

      return subjectWithId;
    } catch (e) {
      throw Exception('Failed to create subject: $e');
    }
  }

  /// Update existing subject
  Future<void> updateSubject(SubjectModel subject) async {
    try {
      await _firestore
          .collection(_subjectsCollection)
          .doc(subject.subjectId)
          .update(subject.toMap());
    } catch (e) {
      throw Exception('Failed to update subject: $e');
    }
  }

  /// Delete subject
  Future<void> deleteSubject(String subjectId) async {
    try {
      // Delete the subject
      await _firestore.collection(_subjectsCollection).doc(subjectId).delete();

      // Note: In a production app, you might want to cascade delete
      // related assignments, announcements, and attendance records
    } catch (e) {
      throw Exception('Failed to delete subject: $e');
    }
  }

  /// Get all subjects for a teacher
  Future<List<SubjectModel>> getSubjectsByTeacher(String teacherId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_subjectsCollection)
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SubjectModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get subjects: $e');
    }
  }

  /// Get subject by ID
  Future<SubjectModel?> getSubjectById(String subjectId) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection(_subjectsCollection).doc(subjectId).get();

      if (!doc.exists) return null;

      return SubjectModel.fromDocument(doc);
    } catch (e) {
      throw Exception('Failed to get subject: $e');
    }
  }

  /// Add students to subject
  Future<void> addStudentsToSubject(
      String subjectId, List<String> studentIds) async {
    try {
      await _firestore.collection(_subjectsCollection).doc(subjectId).update({
        'studentIds': FieldValue.arrayUnion(studentIds),
      });
    } catch (e) {
      throw Exception('Failed to add students: $e');
    }
  }

  /// Remove students from subject
  Future<void> removeStudentsFromSubject(
      String subjectId, List<String> studentIds) async {
    try {
      await _firestore.collection(_subjectsCollection).doc(subjectId).update({
        'studentIds': FieldValue.arrayRemove(studentIds),
      });
    } catch (e) {
      throw Exception('Failed to remove students: $e');
    }
  }

  /// Get subjects stream for real-time updates
  Stream<List<SubjectModel>> getSubjectsStream(String teacherId) {
    try {
      return _firestore
          .collection(_subjectsCollection)
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => SubjectModel.fromDocument(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to get subjects stream: $e');
    }
  }

  /// Get subjects by semester
  Future<List<SubjectModel>> getSubjectsBySemester(
      String teacherId, String semester) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_subjectsCollection)
          .where('teacherId', isEqualTo: teacherId)
          .where('semester', isEqualTo: semester)
          .orderBy('subjectName')
          .get();

      return snapshot.docs
          .map((doc) => SubjectModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get subjects by semester: $e');
    }
  }
}
