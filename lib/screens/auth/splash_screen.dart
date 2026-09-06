import 'dart:async';
import 'package:eventure/navigation/app_router.dart';
import 'package:eventure/providers/auth_provider.dart';
import 'package:eventure/utils/exit_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconFadeAnimation;
  late Animation<Alignment> _alignmentAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Animasi skala untuk icon (0s - 1s)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Animasi fade-in untuk icon (0s - 0.5s)
    _iconFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    // Animasi perpindahan posisi icon (1.5s - 2.0s)
    _alignmentAnimation =
        Tween<Alignment>(
          begin: Alignment.center,
          end: Alignment.centerLeft,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.6, 0.8, curve: Curves.easeInOut),
          ),
        );

    // Animasi fade-in untuk teks (2.0s - 2.5s)
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    // Mulai animasi
    _controller.forward();

    // Navigasi setelah animasi selesai
    Timer(const Duration(milliseconds: 3500), () async {
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await (authProvider.isSignedIn())
          ? context.go(AppRoutes.home)
          : context.go(AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExitConfirmation(
      child: Scaffold(
        // Sebaiknya gunakan warna yang konsisten dengan brand Anda
        backgroundColor: const Color(0xFFF78DA7), // Warna pink dari logo Anda
        body: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return SizedBox(
                width: 280, // Lebar total gabungan icon dan teks
                height: 100, // Tinggi icon
                child: Stack(
                  alignment: _alignmentAnimation.value,
                  children: [
                    // Logo Icon
                    FadeTransition(
                      opacity: _iconFadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Image.asset(
                          'assets/logo/icon.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),

                    // Teks Logo
                    // Padding untuk memberi jarak antara icon dan teks
                    Padding(
                      padding: const EdgeInsets.only(left: 110),
                      // 100 (lebar icon) + 10 (jarak)
                      child: FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Image.asset(
                          'assets/logo/textonly.png',
                          width: 170,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
