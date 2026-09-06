import 'package:eventure/api/database_service.dart';
import 'package:eventure/navigation/app_router.dart';
import 'package:eventure/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrScreen extends StatefulWidget {
  final String eventId;

  const ScanQrScreen({super.key, required this.eventId});

  @override
  State<ScanQrScreen> createState() => ScanQrScreenState();
}

class ScanQrScreenState extends State<ScanQrScreen> {
  final _manualController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isSubmitting = false;
  bool _isScannerVisible = true;

  @override
  void dispose() {
    _manualController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _submitQrValue(String raw) async {
    if (_isSubmitting) return;

    final value = raw.trim();
    final parts = value.split('|').map((e) => e.trim()).toList();
    if (parts.length != 2) {
      _snack('QR tidak valid', Colors.red);
      return;
    }

    final scannedEventId = parts[0];
    final participantId = parts[1];

    if (scannedEventId != widget.eventId) {
      _snack('QR bukan untuk event ini', Colors.red);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await DatabaseService().markAttendance(widget.eventId, participantId);
      if (!mounted) return;
      _snack('Kehadiran berhasil dicatat', Colors.green);
      context.go(
        AppRoutes.eventDashboard.replaceFirst(":eventId", widget.eventId),
      );
    } catch (_) {
      _snack(
        'Gagal mencatat kehadiran (pastikan peserta sudah RSVP)',
        Colors.orange,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFD64A53);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AppHeader(),

            const SizedBox(height: 12),

            Row(
              children: [
                InkWell(
                  onTap: () {
                    context.go(
                      AppRoutes.eventDashboard.replaceFirst(
                        ":eventId",
                        widget.eventId,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Scan QR Peserta',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Text(
                    _isScannerVisible
                        ? 'Arahkan kamera ke QR peserta.'
                        : 'Mode input manual.',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => _isScannerVisible = !_isScannerVisible),
                  child: Text(
                    _isScannerVisible ? 'Input Manual' : 'Pakai Kamera',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_isScannerVisible) ...[
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: MobileScanner(
                      controller: _scannerController,
                      onDetect: (capture) async {
                        if (_isSubmitting) return;

                        final barcodes = capture.barcodes;
                        if (barcodes.isEmpty) return;

                        final rawValue = barcodes.first.rawValue;
                        if (rawValue == null || rawValue.trim().isEmpty) return;

                        await _scannerController.stop();
                        await _submitQrValue(rawValue);

                        if (mounted) {
                          await _scannerController.start();
                        }
                      },
                      errorBuilder: (context, error) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Kamera tidak bisa dibuka.\n\n'
                              'Cek permission kamera (AndroidManifest / Info.plist) '
                              'dan coba restart app.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              if (_isSubmitting)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ] else ...[
              const Text(
                'Untuk demo cepat: tempel hasil QR di bawah (format: eventId|userId).',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _manualController,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'eventId|userId',
                  hintStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () => _submitQrValue(_manualController.text),
                  child: const Text(
                    'Konfirmasi Kehadiran',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
