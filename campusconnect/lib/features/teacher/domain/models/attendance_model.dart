import 'package:cloud_firestore/cloud_firestore.dart';

/// Attendance Model
/// Represents attendance record for a student in a subject
class AttendanceModel {
  final String attendanceId;
  final String subjectId;
  final String studentId;
  final String studentName;
  final DateTime date;
  final String status; // present, absent, late
  final String markedBy;
  final String remarks;

  AttendanceModel({
    required this.attendanceId,
    required this.subjectId,
    required this.studentId,
    this.studentName = '',
    required this.date,
    required this.status,
    required this.markedBy,
    this.remarks = '',
  });

  /// Convert AttendanceModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'attendanceId': attendanceId,
      'subjectId': subjectId,
      'studentId': studentId,
      'studentName': studentName,
      'date': Timestamp.fromDate(date),
      'status': status,
      'markedBy': markedBy,
      'remarks': remarks,
    };
  }

  /// Create AttendanceModel from Firestore document
  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      attendanceId: map['attendanceId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'absent',
      markedBy: map['markedBy'] ?? '',
      remarks: map['remarks'] ?? '',
    );
  }

  /// Create AttendanceModel from Firestore DocumentSnapshot
  factory AttendanceModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceModel.fromMap(data);
  }

  /// Create a copy of AttendanceModel with modified fields
  AttendanceModel copyWith({
    String? attendanceId,
    String? subjectId,
    String? studentId,
    String? studentName,
    DateTime? date,
    String? status,
    String? markedBy,
    String? remarks,
  }) {
    return AttendanceModel(
      attendanceId: attendanceId ?? this.attendanceId,
      subjectId: subjectId ?? this.subjectId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      date: date ?? this.date,
      status: status ?? this.status,
      markedBy: markedBy ?? this.markedBy,
      remarks: remarks ?? this.remarks,
    );
  }

  /// Check if student was present
  bool get isPresent => status == 'present';

  /// Check if student was absent
  bool get isAbsent => status == 'absent';

  /// Check if student was late
  bool get isLate => status == 'late';

  @override
  String toString() {
    return 'AttendanceModel(attendanceId: $attendanceId, studentId: $studentId, status: $status)';
  }
}
