import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final String fullName;
  final String role;

  const HomeScreen({
    super.key,
    required this.fullName,
    required this.role,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String getRoleTitle(String role) {
    if (role == "Admin") {
      return "Yönetici Paneli";
    } else if (role == "Staff") {
      return "Görevli Paneli";
    } else if (role == "Student") {
      return "Öğrenci Paneli";
    } else {
      return "Ana Sayfa";
    }
  }

  String getRoleDescription(String role) {
    if (role == "Admin") {
      return "Bu alan ileride yöneticinin kullanıcıları, kütüphane ayarlarını ve genel sistemi yönetmesi için kullanılacak.";
    } else if (role == "Staff") {
      return "Bu alan ileride görevlinin koltuk durumlarını takip etmesi ve kütüphane kullanımını yönetmesi için kullanılacak.";
    } else if (role == "Student") {
      return "Bu alan ileride öğrencinin kütüphanedeki uygun koltukları görmesi ve oturum durumunu takip etmesi için kullanılacak.";
    } else {
      return "Kullanıcı rolü tanımlanamadı.";
    }
  }

  Future<void> logout(BuildContext context) async {
    final authService = AuthService();

    await authService.logout();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Çıkış yapıldı."),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final String title = getRoleTitle(widget.role);
    final String description = getRoleDescription(widget.role);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: 700,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hoş geldin ${widget.fullName}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Rol: ${widget.role}",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          logout(context);
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text("Çıkış Yap"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}