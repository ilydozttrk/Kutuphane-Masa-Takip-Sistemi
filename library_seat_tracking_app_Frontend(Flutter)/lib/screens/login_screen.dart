import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'admin_dashboard_screen.dart';
import 'home_screen.dart';
import 'staff_home_screen.dart';
import 'student_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Email ve şifre alanları boş bırakılamaz.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final authService = AuthService();

      final result = await authService.login(
        email,
        password,
      );

      debugPrint("LOGIN SONUCU: $result");

      if (result != null && result["success"] == true) {
        final userData = result["data"];

        final String fullName =
            userData["fullName"]?.toString() ?? "Kullanıcı";
        final String role = userData["role"]?.toString() ?? "";

        debugPrint("GİRİŞ BAŞARILI");
        debugPrint("Kullanıcı: $fullName");
        debugPrint("Rol: $role");

        NotificationService.registerCurrentDeviceToken()
            .timeout(
              const Duration(seconds: 5),
            )
            .catchError((e) {
          debugPrint("BİLDİRİM TOKEN HATASI: $e");
        });

        if (!mounted) return;

        _showMessage("Giriş başarılı. Hoş geldin $fullName");

        if (role == "Student") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StudentHomeScreen(
                fullName: fullName,
                role: role,
              ),
            ),
          );
        } else if (role == "Staff") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StaffHomeScreen(
                fullName: fullName,
                role: role,
              ),
            ),
          );
        } else if (role == "Admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDashboardScreen(
                fullName: fullName,
                role: role,
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                fullName: fullName,
                role: role,
              ),
            ),
          );
        }
      } else {
        debugPrint("GİRİŞ BAŞARISIZ");

        if (!mounted) return;

        _showMessage("Email veya şifre hatalı.");
      }
    } catch (e) {
      debugPrint("LOGIN HATASI: $e");

      if (!mounted) return;

      _showMessage("Bir hata oluştu: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_library_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Kütüphane Masa Takip Sistemi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Kütüphanedeki masa durumlarını görüntüle,\nQR kod ile rezervasyonunu kolayca yönet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Giriş Yap",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Hesabına giriş yaparak masa durumlarını ve rezervasyon bilgilerini takip edebilirsin.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: "Email",
                          hintText: "student@example.com",
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (!isLoading) {
                            loginUser();
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Şifre",
                          hintText: "Şifrenizi girin",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF93A4C7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Giriş Yap",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Bitlis Eren Üniversitesi",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}