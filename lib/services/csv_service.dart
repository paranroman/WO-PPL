import 'package:csv/csv.dart';
import '../models/attendance_model.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';

/// A service to handle CSV-related operations, like generating reports.
class CsvService {
  /// Generates a CSV string from event attendance data.
  ///
  /// This method takes the event details and lists of all registered users
  /// and their attendance records to create a comprehensive report.
  String generateAttendanceCsv({
    required EventModel event,
    required List<UserModel> registeredUsers,
    required List<AttendanceModel> attendanceRecords,
  }) {
    // Create a map for quick lookups of attendance status by userId
    final attendanceMap = {
      for (var record in attendanceRecords) record.userId: record,
    };

    // Define the header row for the CSV file.
    List<String> header = [
      'User ID',
      'Name',
      'Email',
      'Registered At',
      'Attendance Status',
      'Attended At',
    ];

    // Create the data rows.
    List<List<String>> rows = [];
    rows.add(header);

    for (var user in registeredUsers) {
      final attendance = attendanceMap[user.uid];

      String attendanceStatus = attendance?.attended == true
          ? 'Hadir'
          : 'Absen';
      String registeredAt =
          attendance?.registeredAt.toLocal().toString() ?? 'N/A';
      String attendedAt = attendance?.attendedAt?.toLocal().toString() ?? 'N/A';

      rows.add([
        user.uid,
        user.name,
        user.email,
        registeredAt,
        attendanceStatus,
        attendedAt,
      ]);
    }

    // Use the csv package to convert the list of lists into a CSV string.
    return const ListToCsvConverter().convert(rows);
  }
}
