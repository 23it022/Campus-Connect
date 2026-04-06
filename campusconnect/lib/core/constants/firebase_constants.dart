/// Firebase Constants
/// Contains all Firestore collection names, Storage paths, and field names
/// Used throughout the app to maintain consistency

class FirebaseCollections {
  // Prevent instantiation
  FirebaseCollections._();

  // Firestore Collections
  static const String users = 'users';
  static const String departments = 'departments';
  static const String courses = 'courses';
  static const String attendance = 'attendance';
  static const String results = 'results';
  static const String syllabus = 'syllabus';
  static const String timetables = 'timetables';
  static const String notes = 'notes';
  static const String events = 'events';
  static const String announcements = 'announcements';
  static const String chats = 'chats';
  static const String groups = 'groups';
  static const String notifications = 'notifications';
  static const String posts = 'posts';

  // Sub-collections
  static const String messages = 'messages';
  static const String students = 'students';
  static const String members = 'members';
}

class FirebaseStoragePaths {
  // Prevent instantiation
  FirebaseStoragePaths._();

  // Storage Paths
  static const String profileImages = 'profile_images';
  static const String syllabus = 'syllabus';
  static const String timetables = 'timetables';
  static const String notes = 'notes';
  static const String events = 'events';
  static const String announcements = 'announcements';
  static const String chatMedia = 'chat_media';
  static const String groupMedia = 'group_media';
  static const String postImages = 'post_images';
  static const String imports = 'imports'; // Excel imports
}

class FirebaseFields {
  // Prevent instantiation
  FirebaseFields._();

  // Common Fields
  static const String uid = 'uid';
  static const String email = 'email';
  static const String name = 'name';
  static const String role = 'role';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String isActive = 'isActive';

  // User Fields
  static const String profileImage = 'profileImage';
  static const String bio = 'bio';
  static const String phone = 'phone';
  static const String departmentId = 'departmentId';
  static const String departmentName = 'departmentName';
  static const String year = 'year';
  static const String semester = 'semester';
  static const String rollNumber = 'rollNumber';
  static const String enrollmentYear = 'enrollmentYear';
  static const String employeeId = 'employeeId';
  static const String designation = 'designation';
  static const String subjects = 'subjects';
  static const String courseIds = 'courseIds';
  static const String lastActive = 'lastActive';
  static const String isEmailVerified = 'isEmailVerified';

  // Course Fields
  static const String courseId = 'courseId';
  static const String courseName = 'courseName';
  static const String courseCode = 'courseCode';
  static const String teacherId = 'teacherId';
  static const String teacherName = 'teacherName';
  static const String credits = 'credits';
  static const String type = 'type';
  static const String description = 'description';
  static const String syllabusUrl = 'syllabusUrl';
  static const String enrolledStudents = 'enrolledStudents';
  static const String totalStudents = 'totalStudents';

  // Attendance Fields
  static const String attendanceId = 'attendanceId';
  static const String date = 'date';
  static const String presentStudents = 'presentStudents';
  static const String absentStudents = 'absentStudents';
  static const String presentCount = 'presentCount';
  static const String absentCount = 'absentCount';
  static const String topic = 'topic';
  static const String remarks = 'remarks';

  // Result Fields
  static const String resultId = 'resultId';
  static const String studentId = 'studentId';
  static const String studentName = 'studentName';
  static const String examType = 'examType';
  static const String examDate = 'examDate';
  static const String marksObtained = 'marksObtained';
  static const String totalMarks = 'totalMarks';
  static const String percentage = 'percentage';
  static const String grade = 'grade';
  static const String enteredBy = 'enteredBy';
  static const String enteredByName = 'enteredByName';
  static const String isPublished = 'isPublished';

  // File Fields
  static const String fileUrl = 'fileUrl';
  static const String fileName = 'fileName';
  static const String fileSize = 'fileSize';
  static const String fileType = 'fileType';
  static const String uploadedBy = 'uploadedBy';
  static const String uploadedByName = 'uploadedByName';

  // Notification Fields
  static const String notificationId = 'notificationId';
  static const String recipientId = 'recipientId';
  static const String title = 'title';
  static const String message = 'message';
  static const String actionType = 'actionType';
  static const String actionData = 'actionData';
  static const String senderId = 'senderId';
  static const String senderName = 'senderName';
  static const String senderRole = 'senderRole';
  static const String isRead = 'isRead';
  static const String readAt = 'readAt';

  // Chat Fields
  static const String chatId = 'chatId';
  static const String participants = 'participants';
  static const String participantNames = 'participantNames';
  static const String participantRoles = 'participantRoles';
  static const String lastMessage = 'lastMessage';
  static const String lastMessageBy = 'lastMessageBy';
  static const String lastMessageTime = 'lastMessageTime';
  static const String unreadCount = 'unreadCount';

  // Message Fields
  static const String messageId = 'messageId';
  static const String text = 'text';
  static const String imageUrl = 'imageUrl';
  static const String timestamp = 'timestamp';

  // Group Fields
  static const String groupId = 'groupId';
  static const String members = 'members';
  static const String memberCount = 'memberCount';
  static const String admins = 'admins';
  static const String onlyAdminsCanPost = 'onlyAdminsCanPost';
}

class UserRoles {
  // Prevent instantiation
  UserRoles._();

  static const String admin = 'admin';
  static const String teacher = 'teacher';
  static const String student = 'student';
}

class ExamTypes {
  // Prevent instantiation
  ExamTypes._();

  static const String internal1 = 'Internal 1';
  static const String internal2 = 'Internal 2';
  static const String midterm = 'Midterm';
  static const String final_ = 'Final';
  static const String assignment = 'Assignment';

  static List<String> get all => [
        internal1,
        internal2,
        midterm,
        final_,
        assignment,
      ];
}

class CourseTypes {
  // Prevent instantiation
  CourseTypes._();

  static const String theory = 'Theory';
  static const String practical = 'Practical';
  static const String theoryPractical = 'Theory+Practical';

  static List<String> get all => [theory, practical, theoryPractical];
}

class GradingScale {
  // Prevent instantiation
  GradingScale._();

  static String getGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    if (percentage >= 40) return 'D';
    return 'F';
  }

  static double getGradePoint(String grade) {
    switch (grade) {
      case 'A+':
        return 10.0;
      case 'A':
        return 9.0;
      case 'B+':
        return 8.0;
      case 'B':
        return 7.0;
      case 'C':
        return 6.0;
      case 'D':
        return 5.0;
      default:
        return 0.0;
    }
  }
}
