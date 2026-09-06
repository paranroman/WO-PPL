import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

void showQrDialog(
  BuildContext context,
  String qrData,
  String title,
  String eventId,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    useRootNavigator: true,
    builder: (dialogContext) {
      return Center(
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Kode QR Event",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                QrImageView(data: qrData, size: 220),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  "Event ID: $eventId",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext, rootNavigator: true).pop();
                    },
                    child: const Text("Tutup"),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
