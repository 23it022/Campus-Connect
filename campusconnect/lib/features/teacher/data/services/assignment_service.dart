import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/assignment_model.dart';
import '../../domain/models/assignment_submission_model.dart';

/// Assignment Service
/// Handles all Firebase operations for assignments and submissions
class AssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _assignmentsCollection = 'assignments';
  final String _submissionsCollection = 'assignment_submissions';

  /// Create new assignment
  Future<AssignmentModel> createAssignment(AssignmentModel assignment) async {
    try {
      final docRef = _firestore.collection(_assignmentsCollection).doc();
      final assignmentWithId = assignment.copyWith(assignmentId: docRef.id);

      await docRef.set(assignmentWithId.toMap());

      return assignmentWithId;
    } catch (e) {
      throw Exception('Failed to create assignment: $e');
    }
  }

  /// Update existing assignment
  Future<void> updateAssignment(AssignmentModel assignment) async {
    try {
      await _firestore
          .collection(_assignmentsCollection)
          .doc(assignment.assignmentId)
          .update(assignment.toMap());
    } catch (e) {
      throw Exception('Failed to update assignment: $e');
    }
  }

  /// Delete assignment
  Future<void> deleteAssignment(String assignmentId) async {
    try {
      // Delete the assignment
      await _firestore
          .collection(_assignmentsCollection)
          .doc(assignmentId)
          .delete();

      // Delete all submissions for this assignment
      final submissions = await _firestore
          .collection(_submissionsCollection)
          .where('assignmentId', isEqualTo: assignmentId)
          .get();

      for (final doc in submissions.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete assignment: $e');
    }
  }

  /// Get assignments by subject
  Future<List<AssignmentModel>> getAssignmentsBySubject(
      String subjectId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_assignmentsCollection)
          .where('subjectId', isEqualTo: subjectId)
          .orderBy('dueDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => AssignmentModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get assignments: $e');
    }
  }

  /// Get assignments by teacher
  Future<List<AssignmentModel>> getAssignmentsByTeacher(
      String teacherId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_assignmentsCollection)
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AssignmentModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get assignments: $e');
    }
  }

  /// Get assignment by ID
  Future<AssignmentModel?> getAssignmentById(String assignmentId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_assignmentsCollection)
          .doc(assignmentId)
          .get();

      if (!doc.exists) return null;

      return AssignmentModel.fromDocument(doc);
    } catch (e) {
      throw Exception('Failed to get assignment: $e');
    }
  }

  /// Get all submissions for an assignment
  Future<List<AssignmentSubmissionModel>> getSubmissions(
      String assignmentId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_submissionsCollection)
          .where('assignmentId', isEqualTo: assignmentId)
          .orderBy('submittedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AssignmentSubmissionModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get submissions: $e');
    }
  }

  /// Get submission by ID
  Future<AssignmentSubmissionModel?> getSubmissionById(
      String submissionId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_submissionsCollection)
          .doc(submissionId)
          .get();

      if (!doc.exists) return null;

      return AssignmentSubmissionModel.fromDocument(doc);
    } catch (e) {
      throw Exception('Failed to get submission: $e');
    }
  }

  /// Grade a submission
  Future<void> gradeSubmission(
      String submissionId, int marks, String feedback) async {
    try {
      await _firestore
          .collection(_submissionsCollection)
          .doc(submissionId)
          .update({
        'marks': marks,
        'feedback': feedback,
        'status': 'graded',
      });
    } catch (e) {
      throw Exception('Failed to grade submission: $e');
    }
  }

  /// Create submission (student-side, but included for completeness)
  Future<AssignmentSubmissionModel> createSubmission(
      AssignmentSubmissionModel submission) async {
    try {
      final docRef = _firestore.collection(_submissionsCollection).doc();
      final submissionWithId = submission.copyWith(submissionId: docRef.id);

      await docRef.set(submissionWithId.toMap());

      return submissionWithId;
    } catch (e) {
      throw Exception('Failed to create submission: $e');
    }
  }

  /// Get pending assignments (not past due date)
  Future<List<AssignmentModel>> getPendingAssignments(String teacherId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_assignmentsCollection)
          .where('teacherId', isEqualTo: teacherId)
          .where('dueDate', isGreaterThanOrEqualTo: Timestamp.now())
          .orderBy('dueDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => AssignmentModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending assignments: $e');
    }
  }

  /// Get ungraded submissions count for a teacher
  Future<int> getUngradedSubmissionsCount(String teacherId) async {
    try {
      // First get all assignments by teacher
      final assignments = await getAssignmentsByTeacher(teacherId);
      final assignmentIds = assignments.map((a) => a.assignmentId).toList();

      if (assignmentIds.isEmpty) return 0;

      // Get ungraded submissions
      final QuerySnapshot snapshot = await _firestore
          .collection(_submissionsCollection)
          .where('assignmentId', whereIn: assignmentIds)
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get ungraded submissions count: $e');
    }
  }
}
