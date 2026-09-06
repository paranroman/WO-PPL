import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/app_router.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Konsistensi Warna ---
    final Color scaffoldBg = const Color(0xFFF9F5F6);
    final Color brandColor = const Color(0xFFE55B5B);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: brandColor),
          onPressed: () => context.go(AppRoutes.home), // Kembali
        ),
        title: const Text(
          "Tentang Aplikasi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --- 1. Logo & Versi App ---
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset('assets/logo/icon.png', fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "E-VENTURE",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: brandColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text("Versi 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // --- 2. Deskripsi Aplikasi ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Apa itu E-Venture?",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "E-Venture adalah aplikasi mobile yang dirancang untuk mempermudah pengelolaan acara kampus secara digital dan terintegrasi. Aplikasi ini membantu panitia dalam membuat dan mengelola event, membuka pendaftaran online, serta mencatat kehadiran peserta menggunakan sistem QR Code yang cepat dan akurat.\n\n"
                      "Melalui E-Venture, proses administrasi acara menjadi lebih efisien karena data peserta diolah secara otomatis dan tersimpan dengan aman. Panitia dapat memantau pendaftaran, kehadiran, dan laporan acara secara real-time, tanpa perlu pencatatan manual.\n\n"
                      "Bagi peserta, E-Venture memberikan pengalaman yang praktis dan modern. Seluruh proses, mulai dari registrasi event hingga absensi kehadiran, dapat dilakukan langsung melalui smartphone, sehingga acara kampus menjadi lebih tertata, transparan, dan profesional.",
                      style: TextStyle(color: Colors.grey[700], height: 1.5),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Overview",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "E-Venture didesain untuk mendukung 2 role utama dalam manajemen event:",
                      style: TextStyle(color: Colors.grey[700], height: 1.5),
                    ),
                    const SizedBox(height: 8),
                    _buildRoleItem(
                      "Pengguna",
                      "Mencari dan mendaftar event yang tersedia.",
                      brandColor,
                    ),
                    const SizedBox(height: 6),
                    _buildRoleItem(
                      "Panitia",
                      "Membuat dan memonitor event yang sudah dibuat.",
                      brandColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- 3. Menu Info Legal & Sosial ---
              _buildInfoMenu(brandColor),

              const SizedBox(height: 40),

              // --- 4. Copyright Footer ---
              Text(
                "© 2025 E-Venture Team.\nAll Rights Reserved.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Role Item
  Widget _buildRoleItem(String role, String description, Color brandColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: brandColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey[700], height: 1.5),
              children: [
                TextSpan(
                  text: "$role: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget Helper untuk Menu Bawah
  Widget _buildInfoMenu(Color brandColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile("Syarat & Ketentuan", Icons.description_outlined, brandColor),
          const Divider(height: 1, indent: 20, endIndent: 20, color: Colors.black12),
          _buildListTile("Kebijakan Privasi", Icons.privacy_tip_outlined, brandColor),
          const Divider(height: 1, indent: 20, endIndent: 20, color: Colors.black12),
          _buildListTile("Kunjungi Website Kami", Icons.language, brandColor),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
      onTap: () {
        // Aksi dummy
      },
    );
  }
}
