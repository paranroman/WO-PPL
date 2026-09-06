import 'package:eventure/navigation/app_router.dart';
import 'package:eventure/utils/exit_confirmation.dart';
import 'package:eventure/widgets/custom_button.dart';
import 'package:eventure/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/toast_helper.dart';
import '../../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      ToastHelper.showShortToast(emailError);
      return;
    }

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      ToastHelper.showShortToast(passwordError);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = context.read<AuthProvider>();
      final success = await auth.signIn(email: email, password: password);

      if (success) {
        if (!mounted) return;

        var user = auth.currentUserData;
        user ??= await auth.getUserData();

        if (user != null) {
          ToastHelper.showShortToast("Selamat Datang, ${user.name}!");
        } else {
          ToastHelper.showShortToast("Selamat Datang!");
        }

        if (mounted) context.go(AppRoutes.home);
      } else {
        ToastHelper.showShortToast("Email atau password salah");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ExitConfirmation(
      child: Center(
        child: Scaffold(
          backgroundColor: const Color(0xFFF78DA7),
          resizeToAvoidBottomInset: false,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.2),
              Image.asset(
                "assets/logo/inappicon.png",
                width: screenWidth * 0.3,
              ),
              SizedBox(height: screenHeight * 0.03),
              Expanded(
                child: Card(
                  elevation: 5,
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  color: const Color(0xFFFDF5F7),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        CustomTextField(
                          controller: emailController,
                          hintText: "Email",
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        CustomTextField(
                          controller: passwordController,
                          hintText: "Password",
                          icon: Icons.password,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                        ),
                        SizedBox(height: screenHeight * 0.04),

                        // 🔹 Button Masuk + loading state
                        CustomButton(
                          text: _isLoading ? "Memproses..." : "Masuk",
                          isEnabled: !_isLoading,
                          onPressed: _isLoading ? () {} : _handleLogin,
                        ),

                        if (_isLoading) ...[
                          const SizedBox(height: 12),
                          const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFD64F5C),
                              ),
                            ),
                          ),
                        ],

                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: Color(0xFF8A8A8A),
                                thickness: 0.5,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                "Atau",
                                style: TextStyle(
                                  color: const Color(0xFF8A8A8A),
                                  fontSize: (screenWidth * 0.04).clamp(
                                    14.0,
                                    18.0,
                                  ),
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: Color(0xFF8A8A8A),
                                thickness: 0.5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              "assets/images/google.png",
                              width: screenWidth * 0.1,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Belum punya akun?",
                              style: TextStyle(
                                color: const Color(0xFF8A8A8A),
                                fontSize: (screenWidth * 0.04).clamp(
                                  14.0,
                                  18.0,
                                ),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => context.go(AppRoutes.register),
                              child: Text(
                                "Daftar",
                                style: TextStyle(
                                  color: const Color(0xFFD64F5C),
                                  fontSize: (screenWidth * 0.04).clamp(
                                    14.0,
                                    18.0,
                                  ),
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
