import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// PDF Helper
/// Utility class for PDF file operations
/// Handles PDF picking, permission management, and file validation

class PdfHelper {
  /// Request storage permission (for downloading PDFs)
  static Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting storage permission: $e');
      return false;
    }
  }

  /// Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking storage permission: $e');
      return false;
    }
  }

  /// Pick PDF file from device
  static Future<PlatformFile?> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
      return null;
    } catch (e) {
      print('Error picking PDF file: $e');
      return null;
    }
  }

  /// Pick multiple PDF files from device
  static Future<List<PlatformFile>?> pickMultiplePdfFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files;
      }
      return null;
    } catch (e) {
      print('Error picking PDF files: $e');
      return null;
    }
  }

  /// Validate PDF file size (max 20MB)
  static bool validatePdfSize(PlatformFile file, {int maxSizeMB = 20}) {
    if (file.size == 0) return false;
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return file.size <= maxSizeBytes;
  }

  /// Validate PDF file extension
  static bool validatePdfExtension(PlatformFile file) {
    final extension = file.extension?.toLowerCase();
    return extension == 'pdf';
  }

  /// Get PDF file size in human-readable format
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Validate PDF file (size + extension)
  static Map<String, dynamic> validatePdfFile(
    PlatformFile file, {
    int maxSizeMB = 20,
  }) {
    final errors = <String>[];

    // Check extension
    if (!validatePdfExtension(file)) {
      errors.add('File must be a PDF');
    }

    // Check size
    if (!validatePdfSize(file, maxSizeMB: maxSizeMB)) {
      errors.add('File size must be less than ${maxSizeMB}MB');
    }

    // Check if file has data
    if (file.size == 0) {
      errors.add('File is empty');
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'fileName': file.name,
      'fileSize': getFileSizeString(file.size),
      'fileSizeBytes': file.size,
    };
  }

  /// Pick and validate PDF file
  static Future<Map<String, dynamic>?> pickAndValidatePdf({
    int maxSizeMB = 20,
  }) async {
    try {
      final file = await pickPdfFile();
      if (file == null) return null;

      final validation = validatePdfFile(file, maxSizeMB: maxSizeMB);

      return {
        'file': file,
        'validation': validation,
      };
    } catch (e) {
      print('Error picking and validating PDF: $e');
      return null;
    }
  }

  /// Get file name without extension
  static String getFileNameWithoutExtension(String fileName) {
    if (fileName.contains('.')) {
      return fileName.substring(0, fileName.lastIndexOf('.'));
    }
    return fileName;
  }

  /// Generate unique file name
  static String generateUniqueFileName(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nameWithoutExt = getFileNameWithoutExtension(originalName);
    final extension = originalName.contains('.')
        ? originalName.substring(originalName.lastIndexOf('.'))
        : '.pdf';
    return '${nameWithoutExt}_$timestamp$extension';
  }

  /// Common PDF sizes for validation
  static const int maxSyllabusSizeMB = 20;
  static const int maxNotesSizeMB = 20;
  static const int maxTimetableSizeMB = 5;

  /// Validate syllabus PDF
  static Map<String, dynamic> validateSyllabusPdf(PlatformFile file) {
    return validatePdfFile(file, maxSizeMB: maxSyllabusSizeMB);
  }

  /// Validate notes PDF
  static Map<String, dynamic> validateNotesPdf(PlatformFile file) {
    return validatePdfFile(file, maxSizeMB: maxNotesSizeMB);
  }

  /// Validate timetable PDF
  static Map<String, dynamic> validateTimetablePdf(PlatformFile file) {
    return validatePdfFile(file, maxSizeMB: maxTimetableSizeMB);
  }
}
