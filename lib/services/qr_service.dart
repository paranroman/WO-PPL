import 'dart:convert';

/// A service to handle the creation and parsing of QR code data.
class QrService {
  /// Generates a structured JSON string to be encoded into a QR code.
  ///
  /// Using JSON makes the QR data robust and easy to extend in the future
  /// without breaking older versions of the scanner.
  String generateQrData({required String eventId, required String userId}) {
    final Map<String, String> data = {'eventId': eventId, 'userId': userId};
    return jsonEncode(data);
  }

  /// Parses the JSON string scanned from a QR code.
  ///
  /// Returns a map containing the eventId and userId.
  /// Returns null if the scanned data is not in the expected format.
  Map<String, String>? parseQrData(String scannedData) {
    try {
      final Map<String, dynamic> decodedData = jsonDecode(scannedData);

      // Basic validation to ensure the required keys are present.
      if (decodedData.containsKey('eventId') &&
          decodedData.containsKey('userId')) {
        return {
          'eventId': decodedData['eventId'],
          'userId': decodedData['userId'],
        };
      }
      return null;
    } catch (e) {
      // Handle cases where the scanned data is not valid JSON.
      print('Error parsing QR data: $e');
      return null;
    }
  }
}
