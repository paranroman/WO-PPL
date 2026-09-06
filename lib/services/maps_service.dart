import 'package:url_launcher/url_launcher.dart';

class MapsService {
  /// Membuka aplikasi Google Maps eksternal untuk navigasi ke koordinat tertentu.
  Future<void> openMap(double latitude, double longitude) async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    final canLaunch = await canLaunchUrl(googleMapsUrl);
    if (!canLaunch) {
      throw Exception('Could not launch Google Maps');
    }

    await launchUrl(
      googleMapsUrl,
      mode: LaunchMode.externalApplication,
    );
  }
}
