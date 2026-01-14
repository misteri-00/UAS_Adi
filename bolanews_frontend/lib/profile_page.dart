import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // Tambahkan ini
import 'main.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _urlController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  final Color primaryColor = const Color(0xFF1A237E);
  final Color scaffoldBg = Colors.white;

  // NOMOR WHATSAPP ADMIN (Ubah sesuai nomor Anda)
  final String adminWhatsApp = "628123456789"; 

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // FUNGSI UNTUK MEMBUKA WHATSAPP
  Future<void> _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse("https://wa.me/$adminWhatsApp?text=Halo Admin, saya butuh bantuan terkait profil saya.");
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar("Tidak dapat membuka WhatsApp");
      }
    } catch (e) {
      _showErrorSnackBar("Terjadi kesalahan koneksi");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red)
    );
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/user/${widget.userId}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _nameController.text = data['name'] ?? "";
            _usernameController.text = data['username'] ?? "";
            _emailController.text = data['email'] ?? "";
            _phoneController.text = data['phoneNumber'] ?? "";
            _bioController.text = data['bio'] ?? "";
            _urlController.text = data['imageUrl'] ?? "";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isSaving = true);
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:5000/api/user/${widget.userId}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameController.text.trim(),
          "username": _usernameController.text.trim(),
          "email": _emailController.text.trim(),
          "phoneNumber": _phoneController.text.trim(),
          "bio": _bioController.text.trim(),
          "imageUrl": _urlController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("✅ Profil Berhasil Diperbarui"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ));
        setState(() => _isEditing = false);
        _fetchUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("❌ Error: $e"),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(backgroundColor: scaffoldBg, body: const Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
        title: Text("PROFIL", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            icon: Icon(_isEditing ? Icons.close : Icons.edit_note, color: primaryColor),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeaderCard(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isEditing ? _buildEditForm() : _buildInfoSection(),
              ),
            ),
            if (!_isEditing) _buildLogoutButton(),
          ],
        ),
      ),
      
      // TOMBOL MENGAMBANG WHATSAPP
      floatingActionButton: FloatingActionButton(
        onPressed: _launchWhatsApp,
        backgroundColor: const Color(0xFF25D366), // Warna Hijau WA
        elevation: 4,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  // --- Widget helper (Tetap sama seperti kode asli Anda) ---
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: NetworkImage(_urlController.text.isNotEmpty
                      ? _urlController.text
                      : "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"),
                ),
              ),
              if (_isEditing)
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.amber,
                  child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                )
            ],
          ),
          const SizedBox(height: 15),
          Text(
            _nameController.text.toUpperCase(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Text(
            "@${_usernameController.text}",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        _buildInfoTile(Icons.alternate_email_rounded, "Username", _usernameController.text),
        _buildInfoTile(Icons.email_outlined, "Email", _emailController.text),
        _buildInfoTile(Icons.phone_iphone_rounded, "Telepon", _phoneController.text),
        _buildInfoTile(Icons.info_outline_rounded, "Bio", _bioController.text),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value.isEmpty ? "-" : value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        _customTextField(_nameController, "Nama Lengkap", Icons.person_outline),
        _customTextField(_emailController, "Email", Icons.mail_outline),
        _customTextField(_phoneController, "Nomor Telepon", Icons.phone_android_outlined),
        _customTextField(_bioController, "Bio", Icons.notes_rounded),
        _customTextField(_urlController, "Link Foto Profil", Icons.link_rounded),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("SIMPAN PERUBAHAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _customTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryColor),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          filled: true,
          fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: primaryColor)),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: InkWell(
        onTap: _handleLogout,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
              const SizedBox(width: 10),
              const Text("KELUAR AKUN", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}