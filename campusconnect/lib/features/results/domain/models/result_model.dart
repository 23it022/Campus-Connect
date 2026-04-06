import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';

/// Result Model
/// Represents exam results and marks for a student
/// Contains marks, grades, and examination details

class ResultModel {
  final String resultId; // Unique result ID
  final String studentId; // Student UID
  final String studentName; // Student name (denormalized)
  final String rollNumber; // Student roll number (denormalized)
  final String departmentId; // Department ID
  final String departmentName; // Department name (denormalized)
  final String year; // Year (e.g., "2nd Year")
  final String semester; // Semester (e.g., "3")
  final String courseId; // Course ID
  final String courseName; // Course name (denormalized)
  final String courseCode; // Course code (denormalized)
  final String
      examType; // "Internal 1" | "Internal 2" | "Midterm" | "Final" | "Assignment"
  final DateTime examDate; // Date of examination
  final double marksObtained; // Marks scored
  final double totalMarks; // Maximum marks
  final double percentage; // Calculated percentage
  final String grade; // Letter grade (A+, A, B+, etc.)
  final String enteredBy; // Teacher UID who entered the result
  final String enteredByName; // Teacher name (denormalized)
  final bool isPublished; // Whether result is visible to students
  final DateTime createdAt; // Entry creation timestamp
  final DateTime updatedAt; // Last update timestamp

  ResultModel({
    required this.resultId,
    required this.studentId,
    this.studentName = '',
    this.rollNumber = '',
    this.departmentId = '',
    this.departmentName = '',
    this.year = '',
    this.semester = '',
    required this.courseId,
    this.courseName = '',
    this.courseCode = '',
    required this.examType,
    DateTime? examDate,
    required this.marksObtained,
    required this.totalMarks,
    double? percentage,
    String? grade,
    required this.enteredBy,
    this.enteredByName = '',
    this.isPublished = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : examDate = examDate ?? DateTime.now(),
        percentage = percentage ?? ((marksObtained / totalMarks) * 100),
        grade =
            grade ?? GradingScale.getGrade((marksObtained / totalMarks) * 100),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert ResultModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'resultId': resultId,
      'studentId': studentId,
      'studentName': studentName,
      'rollNumber': rollNumber,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'year': year,
      'semester': semester,
      'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'examType': examType,
      'examDate': Timestamp.fromDate(examDate),
      'marksObtained': marksObtained,
      'totalMarks': totalMarks,
      'percentage': percentage,
      'grade': grade,
      'enteredBy': enteredBy,
      'enteredByName': enteredByName,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create ResultModel from Firestore document
  factory ResultModel.fromMap(Map<String, dynamic> map) {
    return ResultModel(
      resultId: map['resultId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      departmentId: map['departmentId'] ?? '',
      departmentName: map['departmentName'] ?? '',
      year: map['year'] ?? '',
      semester: map['semester'] ?? '',
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      courseCode: map['courseCode'] ?? '',
      examType: map['examType'] ?? '',
      examDate: (map['examDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      marksObtained: (map['marksObtained'] ?? 0).toDouble(),
      totalMarks: (map['totalMarks'] ?? 0).toDouble(),
      percentage: (map['percentage'] ?? 0).toDouble(),
      grade: map['grade'] ?? '',
      enteredBy: map['enteredBy'] ?? '',
      enteredByName: map['enteredByName'] ?? '',
      isPublished: map['isPublished'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create ResultModel from Firestore DocumentSnapshot
  factory ResultModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResultModel.fromMap(data);
  }

  /// Create a copy of ResultModel with modified fields
  ResultModel copyWith({
    String? resultId,
    String? studentId,
    String? studentName,
    String? rollNumber,
    String? departmentId,
    String? departmentName,
    String? year,
    String? semester,
    String? courseId,
    String? courseName,
    String? courseCode,
    String? examType,
    DateTime? examDate,
    double? marksObtained,
    double? totalMarks,
    double? percentage,
    String? grade,
    String? enteredBy,
    String? enteredByName,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResultModel(
      resultId: resultId ?? this.resultId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      rollNumber: rollNumber ?? this.rollNumber,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      examType: examType ?? this.examType,
      examDate: examDate ?? this.examDate,
      marksObtained: marksObtained ?? this.marksObtained,
      totalMarks: totalMarks ?? this.totalMarks,
      percentage: percentage ?? this.percentage,
      grade: grade ?? this.grade,
      enteredBy: enteredBy ?? this.enteredBy,
      enteredByName: enteredByName ?? this.enteredByName,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if student passed
  bool get isPassed {
    return marksObtained >= (totalMarks * 0.4); // 40% passing
  }

  /// Get grade point
  double get gradePoint {
    return GradingScale.getGradePoint(grade);
  }

  @override
  String toString() {
    return 'ResultModel(resultId: $resultId, student: $studentName, course: $courseName, marks: $marksObtained/$totalMarks, grade: $grade)';
  }
}
