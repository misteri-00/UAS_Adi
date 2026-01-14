import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();
  final imageController = TextEditingController();

  bool isLoading = false;
  final Color primaryColor = const Color(0xFF1A237E);

  Future<void> register() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty || usernameController.text.isEmpty) {
      _showMsg("Email, Username, dan Password wajib diisi!");
      return;
    }

    setState(() => isLoading = true);

    // IP 10.0.2.2 adalah jembatan Emulator Android ke Localhost Laptop
    final url = Uri.parse('http://10.0.2.2:5000/api/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "username": usernameController.text.trim().toLowerCase(),
          "email": emailController.text.trim().toLowerCase(),
          "password": passwordController.text,
          "phoneNumber": phoneController.text.trim(),
          "bio": bioController.text.trim(),
          "imageUrl": imageController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 10)); // Tambahkan timeout

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _showMsg("✅ Registrasi Berhasil!");
        if (mounted) {
          Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
        }
      } else {
        _showMsg("❌ ${data['message'] ?? "Gagal mendaftar"}");
      }
    } catch (e) {
      // Jika masuk ke sini, berarti request gagal sebelum sampai ke server
      debugPrint("Log Error: $e");
      _showMsg("⚠️ Koneksi Gagal. Periksa apakah server backend sudah RUNNING.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("DAFTAR AKUN", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Icon(Icons.sports_soccer_rounded, size: 80, color: primaryColor),
            const SizedBox(height: 10),
            const Text("Buat akun Bolanews Anda", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 30),
            
            _buildInput(nameController, "Nama Lengkap", Icons.person_outline),
            _buildInput(usernameController, "Username", Icons.alternate_email_rounded),
            _buildInput(emailController, "Email", Icons.mail_outline_rounded, type: TextInputType.emailAddress),
            _buildInput(passwordController, "Password", Icons.lock_outline_rounded, obscure: true),
            _buildInput(phoneController, "WhatsApp", Icons.phone_android_rounded, type: TextInputType.phone),
            _buildInput(imageController, "Link Foto (Opsional)", Icons.link_rounded),
            _buildInput(bioController, "Bio", Icons.notes_rounded, maxLines: 2),
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                child: isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text("DAFTAR SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, 
      {bool obscure = false, TextInputType type = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          prefixIcon: Icon(icon, color: primaryColor, size: 22),
          filled: true,
          fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
      ),
    );
  }
}