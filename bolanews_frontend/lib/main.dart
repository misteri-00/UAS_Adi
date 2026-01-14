import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';
import 'home_page.dart'; 
import 'admin_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? role = prefs.getString('role');
  String? userId = prefs.getString('userId');
  String? email = prefs.getString('email');

  Widget initialScreen;
  if (isLoggedIn) {
    if (role == "admin") {
      initialScreen = AdminPage(adminData: {
        "id": userId, 
        "email": email,
        "name": prefs.getString('name') ?? "Admin",
        "imageUrl": prefs.getString('imageUrl')
      });
    } else {
      initialScreen = HomePage(userId: userId ?? "");
    }
  } else {
    initialScreen = const LoginPage();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bolanews',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
      ),
      home: initialScreen,
      routes: {
        '/login': (context) => const LoginPage(),
        '/admin': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return AdminPage(adminData: args);
        },
        '/home': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return HomePage(userId: userId);
        },
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _isObscure = true;

  final Color primaryColor = const Color(0xFF1A237E);

  Future<void> _saveSession(Map<String, dynamic> user, String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', user['id']?.toString() ?? "");
    await prefs.setString('email', user['email'] ?? "");
    await prefs.setString('role', role);
    await prefs.setString('name', user['name'] ?? "");
    await prefs.setString('imageUrl', user['imageUrl'] ?? "");
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showMsg("Email dan Password harus diisi");
      return;
    }

    setState(() => isLoading = true);
    final url = Uri.parse('http://10.0.2.2:5000/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim().toLowerCase(),
          "password": passwordController.text, 
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final userData = data['user'];
        final String role = userData['role'] ?? "user";

        await _saveSession(userData, role);

        if (!mounted) return;

        if (role == "admin") {
          _showMsg("Selamat Datang Admin!");
          Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false, arguments: userData);
        } else {
          _showMsg("Berhasil Login!");
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false, arguments: userData['id']?.toString());
        }
      } else {
        _showMsg(data['message'] ?? "Login Gagal");
      }
    } catch (e) {
      debugPrint("Error: $e");
      _showMsg("Koneksi ke server gagal");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.sports_soccer_rounded, size: 80, color: primaryColor),
                ),
                const SizedBox(height: 15),
                Text(
                  "BOLANEWS", 
                  style: TextStyle(
                    fontSize: 30, 
                    fontWeight: FontWeight.w900, 
                    color: primaryColor,
                    letterSpacing: 1.5
                  )
                ),
                const Text(
                  "Pusat Informasi Bola Terupdate",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 50),

                _customTextField(
                  controller: emailController,
                  label: "Email / Username",
                  icon: Icons.person_outline_rounded,
                  type: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                _customTextField(
                  controller: passwordController,
                  label: "Password",
                  icon: Icons.lock_outline_rounded,
                  obscure: _isObscure,
                  isPassword: true,
                  toggleVisibility: () => setState(() => _isObscure = !_isObscure),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity, 
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: primaryColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                    child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("MASUK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum memiliki akun?", style: TextStyle(color: Colors.black54)),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const RegisterPage())
                      ),
                      child: Text(
                        "Daftar Sekarang", 
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ],
                ),

                // --- BAGIAN TEKS TAMBAHAN (DEMO ACCOUNT INFO) ---
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Informasi Akun Demo:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Admin : budi@gmail.com | Sandi : user11",
                        style: TextStyle(color: Colors.grey[700], fontSize: 11),
                      ),
                      Text(
                        "User : user@gmail.com | Sandi : user11",
                        style: TextStyle(color: Colors.grey[700], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
    VoidCallback? toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: toggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.grey[50],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}