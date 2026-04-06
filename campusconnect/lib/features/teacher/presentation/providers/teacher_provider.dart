import 'package:flutter/material.dart';
import '../../data/services/subject_service.dart';
import '../../data/services/assignment_service.dart';
import '../../data/services/announcement_service.dart';
import '../../data/services/attendance_service.dart';
import '../../domain/models/subject_model.dart';
import '../../domain/models/assignment_model.dart';
import '../../domain/models/assignment_submission_model.dart';
import '../../domain/models/announcement_model.dart';
import '../../domain/models/attendance_model.dart';

/// Teacher Provider
/// Manages state for all teacher-related operations
class TeacherProvider with ChangeNotifier {
  final SubjectService _subjectService = SubjectService();
  final AssignmentService _assignmentService = AssignmentService();
  final AnnouncementService _announcementService = AnnouncementService();
  final AttendanceService _attendanceService = AttendanceService();

  // State variables
  List<SubjectModel> _subjects = [];
  List<AssignmentModel> _assignments = [];
  List<AssignmentSubmissionModel> _submissions = [];
  List<AnnouncementModel> _announcements = [];
  List<AttendanceModel> _attendanceRecords = [];

  bool _isLoading = false;
  String? _errorMessage;

  // File upload progress
  double _uploadProgress = 0.0;

  // Getters
  List<SubjectModel> get subjects => _subjects;
  List<AssignmentModel> get assignments => _assignments;
  List<AssignmentSubmissionModel> get submissions => _submissions;
  List<AnnouncementModel> get announcements => _announcements;
  List<AttendanceModel> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get uploadProgress => _uploadProgress;

  // Dashboard stats
  int get totalSubjects => _subjects.length;
  int get pendingAssignments => _assignments.where((a) => !a.isOverdue).length;
  int get recentAnnouncements => _announcements.length;

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // --- Subject Methods ---

  /// Load all subjects for a teacher
  Future<void> loadSubjects(String teacherId) async {
    try {
      _setLoading(true);
      _setError(null);

      _subjects = await _subjectService.getSubjectsByTeacher(teacherId);

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Create new subject
  Future<bool> createSubject(SubjectModel subject) async {
    try {
      _setLoading(true);
      _setError(null);

      final newSubject = await _subjectService.createSubject(subject);
      _subjects.insert(0, newSubject);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update existing subject
  Future<bool> updateSubject(SubjectModel subject) async {
    try {
      _setLoading(true);
      _setError(null);

      await _subjectService.updateSubject(subject);

      final index =
          _subjects.indexWhere((s) => s.subjectId == subject.subjectId);
      if (index != -1) {
        _subjects[index] = subject;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Delete subject
  Future<bool> deleteSubject(String subjectId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _subjectService.deleteSubject(subjectId);

      _subjects.removeWhere((s) => s.subjectId == subjectId);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // --- Assignment Methods ---

  /// Load assignments for a subject
  Future<void> loadAssignmentsBySubject(String subjectId) async {
    try {
      _setLoading(true);
      _setError(null);

      _assignments =
          await _assignmentService.getAssignmentsBySubject(subjectId);

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Load all assignments for a teacher
  Future<void> loadAssignmentsByTeacher(String teacherId) async {
    try {
      _setLoading(true);
      _setError(null);

      _assignments =
          await _assignmentService.getAssignmentsByTeacher(teacherId);

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Create new assignment
  Future<bool> createAssignment(AssignmentModel assignment) async {
    try {
      _setLoading(true);
      _setError(null);

      final newAssignment =
          await _assignmentService.createAssignment(assignment);
      _assignments.insert(0, newAssignment);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update assignment
  Future<bool> updateAssignment(AssignmentModel assignment) async {
    try {
      _setLoading(true);
      _setError(null);

      await _assignmentService.updateAssignment(assignment);

      final index = _assignments
          .indexWhere((a) => a.assignmentId == assignment.assignmentId);
      if (index != -1) {
        _assignments[index] = assignment;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Delete assignment
  Future<bool> deleteAssignment(String assignmentId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _assignmentService.deleteAssignment(assignmentId);

      _assignments.removeWhere((a) => a.assignmentId == assignmentId);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Load submissions for an assignment
  Future<void> loadSubmissions(String assignmentId) async {
    try {
      _setLoading(true);
      _setError(null);

      _submissions = await _assignmentService.getSubmissions(assignmentId);

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Grade a submission
  Future<bool> gradeSubmission(
      String submissionId, int marks, String feedback) async {
    try {
      _setLoading(true);
      _setError(null);

      await _assignmentService.gradeSubmission(submissionId, marks, feedback);

      final index =
          _submissions.indexWhere((s) => s.submissionId == submissionId);
      if (index != -1) {
        _submissions[index] = _submissions[index].copyWith(
          marks: marks,
          feedback: feedback,
          status: 'graded',
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // --- Announcement Methods ---

  /// Load announcements for a teacher
  Future<void> loadAnnouncements(String teacherId) async {
    try {
      _setLoading(true);
      _setError(null);

      _announcements =
          await _announcementService.getAnnouncementsByTeacher(teacherId);

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Create announcement
  Future<bool> createAnnouncement(AnnouncementModel announcement) async {
    try {
      _setLoading(true);
      _setError(null);

      final newAnnouncement =
          await _announcementService.createAnnouncement(announcement);
      _announcements.insert(0, newAnnouncement);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update announcement
  Future<bool> updateAnnouncement(AnnouncementModel announcement) async {
    try {
      _setLoading(true);
      _setError(null);

      await _announcementService.updateAnnouncement(announcement);

      final index = _announcements
          .indexWhere((a) => a.announcementId == announcement.announcementId);
      if (index != -1) {
        _announcements[index] = announcement;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Delete announcement
  Future<bool> deleteAnnouncement(String announcementId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _announcementService.deleteAnnouncement(announcementId);

      _announcements.removeWhere((a) => a.announcementId == announcementId);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // --- Attendance Methods ---

  /// Mark attendance
  Future<bool> markAttendance(AttendanceModel attendance) async {
    try {
      _setLoading(true);
      _setError(null);

      final newAttendance = await _attendanceService.markAttendance(attendance);
      _attendanceRecords.insert(0, newAttendance);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Bulk mark attendance
  Future<bool> bulkMarkAttendance(List<AttendanceModel> attendanceList) async {
    try {
      _setLoading(true);
      _setError(null);

      await _attendanceService.bulkMarkAttendance(attendanceList);

      _attendanceRecords.insertAll(0, attendanceList);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Load attendance for a subject
  Future<void> loadAttendanceBySubject(String subjectId) async {
    try {
      _setLoading(true);
      _setError(null);

      _attendanceRecords =
          await _attendanceService.getAttendanceBySubject(subjectId);

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Load attendance for a specific date
  Future<void> loadAttendanceByDate(String subjectId, DateTime date) async {
    try {
      _setLoading(true);
      _setError(null);

      _attendanceRecords =
          await _attendanceService.getAttendanceByDate(subjectId, date);

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Get attendance statistics
  Future<Map<String, dynamic>?> getAttendanceStats(
      String subjectId, String studentId) async {
    try {
      return await _attendanceService.getAttendanceStats(subjectId, studentId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Update upload progress
  void updateUploadProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }

  /// Reset upload progress
  void resetUploadProgress() {
    _uploadProgress = 0.0;
    notifyListeners();
  }
}
