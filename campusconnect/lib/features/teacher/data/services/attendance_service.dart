import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/attendance_model.dart';

/// Attendance Service
/// Handles all Firebase operations for attendance tracking
class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _attendanceCollection = 'attendance';

  /// Mark attendance for a single student
  Future<AttendanceModel> markAttendance(AttendanceModel attendance) async {
    try {
      final docRef = _firestore.collection(_attendanceCollection).doc();
      final attendanceWithId = attendance.copyWith(attendanceId: docRef.id);

      await docRef.set(attendanceWithId.toMap());

      return attendanceWithId;
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }

  /// Bulk mark attendance for multiple students
  Future<void> bulkMarkAttendance(List<AttendanceModel> attendanceList) async {
    try {
      final batch = _firestore.batch();

      for (final attendance in attendanceList) {
        final docRef = _firestore.collection(_attendanceCollection).doc();
        final attendanceWithId = attendance.copyWith(attendanceId: docRef.id);
        batch.set(docRef, attendanceWithId.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to bulk mark attendance: $e');
    }
  }

  /// Update attendance record
  Future<void> updateAttendance(AttendanceModel attendance) async {
    try {
      await _firestore
          .collection(_attendanceCollection)
          .doc(attendance.attendanceId)
          .update(attendance.toMap());
    } catch (e) {
      throw Exception('Failed to update attendance: $e');
    }
  }

  /// Get attendance by subject
  Future<List<AttendanceModel>> getAttendanceBySubject(String subjectId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_attendanceCollection)
          .where('subjectId', isEqualTo: subjectId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AttendanceModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get attendance: $e');
    }
  }

  /// Get attendance by date
  Future<List<AttendanceModel>> getAttendanceByDate(
      String subjectId, DateTime date) async {
    try {
      // Create start and end of day timestamps
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final QuerySnapshot snapshot = await _firestore
          .collection(_attendanceCollection)
          .where('subjectId', isEqualTo: subjectId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs
          .map((doc) => AttendanceModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get attendance by date: $e');
    }
  }

  /// Get student attendance report
  Future<List<AttendanceModel>> getStudentAttendanceReport(
      String subjectId, String studentId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_attendanceCollection)
          .where('subjectId', isEqualTo: subjectId)
          .where('studentId', isEqualTo: studentId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AttendanceModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get student attendance report: $e');
    }
  }

  /// Calculate attendance statistics for a student
  Future<Map<String, dynamic>> getAttendanceStats(
      String subjectId, String studentId) async {
    try {
      final attendanceRecords =
          await getStudentAttendanceReport(subjectId, studentId);

      final totalClasses = attendanceRecords.length;
      final presentCount = attendanceRecords.where((a) => a.isPresent).length;
      final absentCount = attendanceRecords.where((a) => a.isAbsent).length;
      final lateCount = attendanceRecords.where((a) => a.isLate).length;

      final percentage =
          totalClasses > 0 ? (presentCount / totalClasses) * 100 : 0.0;

      return {
        'totalClasses': totalClasses,
        'present': presentCount,
        'absent': absentCount,
        'late': lateCount,
        'percentage': percentage,
      };
    } catch (e) {
      throw Exception('Failed to calculate attendance stats: $e');
    }
  }

  /// Get attendance for date range
  Future<List<AttendanceModel>> getAttendanceByDateRange(
      String subjectId, DateTime startDate, DateTime endDate) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_attendanceCollection)
          .where('subjectId', isEqualTo: subjectId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AttendanceModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get attendance by date range: $e');
    }
  }

  /// Delete attendance record
  Future<void> deleteAttendance(String attendanceId) async {
    try {
      await _firestore
          .collection(_attendanceCollection)
          .doc(attendanceId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete attendance: $e');
    }
  }

  /// Check if attendance already marked for student on a date
  Future<bool> isAttendanceMarked(
      String subjectId, String studentId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final QuerySnapshot snapshot = await _firestore
          .collection(_attendanceCollection)
          .where('subjectId', isEqualTo: subjectId)
          .where('studentId', isEqualTo: studentId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check attendance: $e');
    }
  }
}
