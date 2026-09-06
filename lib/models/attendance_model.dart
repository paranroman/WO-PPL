/// A data model class for attendance records.
class AttendanceModel {
  final String userId;
  final String eventId;
  final DateTime registeredAt;
  bool attended;
  DateTime? attendedAt; // Nullable as it's only set when they attend

  AttendanceModel({
    required this.userId,
    required this.eventId,
    required this.registeredAt,
    this.attended = false,
    this.attendedAt,
  });

  /// Converts an AttendanceModel instance into a Map for Firebase.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'eventId': eventId,
      'registeredAt': registeredAt.toIso8601String(),
      'attended': attended,
      // Only include attendedAt if it's not null
      'attendedAt': attendedAt?.toIso8601String(),
    };
  }

  /// Creates an AttendanceModel instance from a map (JSON data from Firebase).
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      userId: json['userId'] ?? '',
      eventId: json['eventId'] ?? '',
      registeredAt: json['registeredAt'] != null
          ? DateTime.parse(json['registeredAt'])
          : DateTime.now(),
      attended: json['attended'] ?? false,
      attendedAt: json['attendedAt'] != null
          ? DateTime.parse(json['attendedAt'])
          : null,
    );
  }
}
