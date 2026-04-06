import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

/// Excel Helper
/// Utility class for Excel file operations
/// Handles import/export of student/teacher data

class ExcelHelper {
  /// Pick Excel file from device
  static Future<PlatformFile?> pickExcelFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
      return null;
    } catch (e) {
      print('Error picking Excel file: $e');
      return null;
    }
  }

  /// Read Excel file and return as list of maps
  static Future<List<Map<String, dynamic>>> readExcelFile(
    PlatformFile file,
  ) async {
    try {
      if (file.bytes == null) {
        throw Exception('File bytes are null');
      }

      final excel = Excel.decodeBytes(file.bytes!);
      final records = <Map<String, dynamic>>[];

      // Get the first sheet
      final sheet = excel.tables.keys.first;
      final table = excel.tables[sheet];

      if (table == null || table.rows.isEmpty) {
        return records;
      }

      // First row is header
      final headers =
          table.rows[0].map((cell) => cell?.value?.toString() ?? '').toList();

      // Process data rows
      for (var i = 1; i < table.rows.length; i++) {
        final row = table.rows[i];
        final record = <String, dynamic>{};

        for (var j = 0; j < row.length && j < headers.length; j++) {
          final header = headers[j];
          final cellValue = row[j]?.value;

          // Convert cell value to appropriate type
          if (cellValue == null) {
            record[header] = '';
          } else if (cellValue is TextCellValue) {
            record[header] = cellValue.value;
          } else if (cellValue is IntCellValue) {
            record[header] = cellValue.value;
          } else if (cellValue is DoubleCellValue) {
            record[header] = cellValue.value;
          } else if (cellValue is BoolCellValue) {
            record[header] = cellValue.value;
          } else {
            record[header] = cellValue.toString();
          }
        }

        // Only add non-empty rows
        if (record.isNotEmpty) {
          records.add(record);
        }
      }

      return records;
    } catch (e) {
      print('Error reading Excel file: $e');
      rethrow;
    }
  }

  /// Create Excel file from list of maps
  static Excel createExcelFile(
    List<Map<String, dynamic>> data,
    String sheetName,
  ) {
    final excel = Excel.createExcel();
    final sheet = excel[sheetName];

    if (data.isEmpty) {
      return excel;
    }

    // Add headers
    final headers = data.first.keys.toList();
    for (var i = 0; i < headers.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i]);
    }

    // Add data rows
    for (var rowIndex = 0; rowIndex < data.length; rowIndex++) {
      final record = data[rowIndex];
      for (var colIndex = 0; colIndex < headers.length; colIndex++) {
        final key = headers[colIndex];
        final value = record[key];

        final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: colIndex,
          rowIndex: rowIndex + 1,
        ));

        if (value is int) {
          cell.value = IntCellValue(value);
        } else if (value is double) {
          cell.value = DoubleCellValue(value);
        } else if (value is bool) {
          cell.value = BoolCellValue(value);
        } else {
          cell.value = TextCellValue(value?.toString() ?? '');
        }
      }
    }

    return excel;
  }

  /// Validate student import data
  static List<String> validateStudentData(List<Map<String, dynamic>> data) {
    final errors = <String>[];
    final requiredFields = [
      'name',
      'email',
      'rollNumber',
      'department',
      'year',
      'semester'
    ];

    for (var i = 0; i < data.length; i++) {
      final record = data[i];
      final rowNum =
          i + 2; // +2 because Excel is 1-indexed and first row is header

      // Check required fields
      for (final field in requiredFields) {
        if (!record.containsKey(field) ||
            record[field]?.toString().trim().isEmpty == true) {
          errors.add('Row $rowNum: Missing or empty "$field"');
        }
      }

      // Validate email format
      if (record.containsKey('email')) {
        final email = record['email']?.toString() ?? '';
        if (!email.contains('@')) {
          errors.add('Row $rowNum: Invalid email format');
        }
      }

      // Validate year
      if (record.containsKey('year')) {
        final year = record['year']?.toString() ?? '';
        final validYears = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
        if (!validYears.contains(year)) {
          errors.add(
              'Row $rowNum: Invalid year (must be one of: ${validYears.join(", ")})');
        }
      }

      // Validate semester
      if (record.containsKey('semester')) {
        final semester = record['semester']?.toString() ?? '';
        try {
          final semNum = int.parse(semester);
          if (semNum < 1 || semNum > 8) {
            errors.add('Row $rowNum: Semester must be between 1 and 8');
          }
        } catch (e) {
          errors.add('Row $rowNum: Semester must be a number');
        }
      }
    }

    return errors;
  }

  /// Validate teacher import data
  static List<String> validateTeacherData(List<Map<String, dynamic>> data) {
    final errors = <String>[];
    final requiredFields = [
      'name',
      'email',
      'employeeId',
      'department',
      'designation'
    ];

    for (var i = 0; i < data.length; i++) {
      final record = data[i];
      final rowNum = i + 2;

      // Check required fields
      for (final field in requiredFields) {
        if (!record.containsKey(field) ||
            record[field]?.toString().trim().isEmpty == true) {
          errors.add('Row $rowNum: Missing or empty "$field"');
        }
      }

      // Validate email format
      if (record.containsKey('email')) {
        final email = record['email']?.toString() ?? '';
        if (!email.contains('@')) {
          errors.add('Row $rowNum: Invalid email format');
        }
      }

      // Validate designation
      if (record.containsKey('designation')) {
        final designation = record['designation']?.toString() ?? '';
        final validDesignations = [
          'Professor',
          'Associate Professor',
          'Assistant Professor',
          'Lecturer',
          'Guest Faculty'
        ];
        if (!validDesignations.contains(designation)) {
          errors.add(
              'Row $rowNum: Invalid designation (must be one of: ${validDesignations.join(", ")})');
        }
      }
    }

    return errors;
  }

  /// Export students to Excel
  static Future<List<int>?> exportStudentsToExcel(
    List<Map<String, dynamic>> students,
  ) async {
    try {
      final excel = createExcelFile(students, 'Students');
      return excel.encode();
    } catch (e) {
      print('Error exporting students: $e');
      return null;
    }
  }

  /// Export teachers to Excel
  static Future<List<int>?> exportTeachersToExcel(
    List<Map<String, dynamic>> teachers,
  ) async {
    try {
      final excel = createExcelFile(teachers, 'Teachers');
      return excel.encode();
    } catch (e) {
      print('Error exporting teachers: $e');
      return null;
    }
  }

  /// Generate sample student template
  static Excel generateStudentTemplate() {
    final sampleData = [
      {
        'name': 'John Doe',
        'email': 'john@example.com',
        'rollNumber': '21CS001',
        'department': 'Computer Science',
        'year': '2nd Year',
        'semester': '3',
        'phone': '9876543210',
      },
    ];

    return createExcelFile(sampleData, 'Students');
  }

  /// Generate sample teacher template
  static Excel generateTeacherTemplate() {
    final sampleData = [
      {
        'name': 'Dr. Jane Smith',
        'email': 'jane@example.com',
        'employeeId': 'EMP001',
        'department': 'Computer Science',
        'designation': 'Professor',
        'phone': '9876543210',
      },
    ];

    return createExcelFile(sampleData, 'Teachers');
  }
}
