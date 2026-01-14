import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

import 'dart:async';



class UserListPage extends StatefulWidget {

  const UserListPage({super.key});



  @override

  State<UserListPage> createState() => _UserListPageState();

}



class _UserListPageState extends State<UserListPage> {

  List users = [];

  bool isLoading = true;



  // TEMA WARNA ADMIN PANEL (BIRU)

  final Color primaryColor = const Color(0xFF1E3A8A); // Indigo/Blue Gelap

  final Color accentColor = const Color(0xFF3B82F6);  // Biru Terang

  final Color backgroundColor = const Color(0xFFF1F5F9); // Biru Abu-abu sangat muda



  @override

  void initState() {

    super.initState();

    fetchUsers();

  }



  Future<void> fetchUsers() async {

    setState(() => isLoading = true);

    try {

      final response = await http.get(

        Uri.parse('http://10.0.2.2:5000/api/auth/users'),

      ).timeout(const Duration(seconds: 10));



      if (response.statusCode == 200) {

        setState(() {

          users = jsonDecode(response.body);

          isLoading = false;

        });

      } else {

        _showSnackBar("Gagal memuat data");

        setState(() => isLoading = false);

      }

    } catch (e) {

      _showSnackBar("Koneksi error");

      setState(() => isLoading = false);

    }

  }



  Future<void> createUser(String name, String username, String email, String password, String role) async {

    try {

      final response = await http.post(

        Uri.parse('http://10.0.2.2:5000/api/auth/users'),

        headers: {"Content-Type": "application/json"},

        body: jsonEncode({

          "name": name,

          "username": username,

          "email": email,

          "password": password,

          "role": role

        }),

      );

      if (response.statusCode == 201) {

        _showSnackBar("User berhasil ditambahkan");

        fetchUsers();

      }

    } catch (e) {

      _showSnackBar("Terjadi kesalahan koneksi");

    }

  }



  Future<void> deleteUser(String id) async {

    try {

      final response = await http.delete(Uri.parse('http://10.0.2.2:5000/api/auth/users/$id'));

      if (response.statusCode == 200) {

        _showSnackBar("User berhasil dihapus");

        fetchUsers();

      }

    } catch (e) {

      _showSnackBar("Gagal menghapus");

    }

  }



  Future<void> toggleRole(String id, String currentRole) async {

    String newRole = currentRole == 'admin' ? 'user' : 'admin';

    try {

      final response = await http.put(

        Uri.parse('http://10.0.2.2:5000/api/auth/users/$id/role'),

        headers: {"Content-Type": "application/json"},

        body: jsonEncode({"role": newRole}),

      );

      if (response.statusCode == 200) {

        _showSnackBar("Role diperbarui ke ${newRole.toUpperCase()}");

        fetchUsers();

      }

    } catch (e) {

      _showSnackBar("Gagal memperbarui role");

    }

  }



  void _showSnackBar(String message) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text(message),

        behavior: SnackBarBehavior.floating,

        backgroundColor: primaryColor,

      ),

    );

  }



  void _showAddUserDialog() {

    final nameCtrl = TextEditingController();

    final userCtrl = TextEditingController();

    final emailCtrl = TextEditingController();

    final passCtrl = TextEditingController();

    String selectedRole = 'user';



    showDialog(

      context: context,

      builder: (context) => StatefulBuilder(

        builder: (context, setDialogState) => AlertDialog(

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

          title: Text("Tambah User Baru", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),

          content: SingleChildScrollView(

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: [

                _buildTextField(nameCtrl, "Nama Lengkap"),

                _buildTextField(userCtrl, "Username"),

                _buildTextField(emailCtrl, "Email"),

                _buildTextField(passCtrl, "Password", isObscure: true),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(

                  value: selectedRole,

                  items: ['user', 'admin'].map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(),

                  onChanged: (val) => setDialogState(() => selectedRole = val!),

                  decoration: InputDecoration(

                    labelText: "Role",

                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),

                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentColor), borderRadius: BorderRadius.circular(10)),

                  ),

                ),

              ],

            ),

          ),

          actions: [

            TextButton(onPressed: () => Navigator.pop(context), child: Text("BATAL", style: TextStyle(color: Colors.grey[600]))),

            ElevatedButton(

              onPressed: () {

                if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {

                  createUser(nameCtrl.text, userCtrl.text, emailCtrl.text, passCtrl.text, selectedRole);

                  Navigator.pop(context);

                }

              },

              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),

              child: const Text("SIMPAN"),

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildTextField(TextEditingController ctrl, String label, {bool isObscure = false}) {

    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 8.0),

      child: TextField(

        controller: ctrl,

        obscureText: isObscure,

        decoration: InputDecoration(

          labelText: label,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),

          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accentColor), borderRadius: BorderRadius.circular(10)),

        ),

      ),

    );

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: backgroundColor,

      appBar: AppBar(

        title: const Text("USER MANAGEMENT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),

        backgroundColor: primaryColor,

        foregroundColor: Colors.white,

        centerTitle: true,

        elevation: 4,

      ),

      body: isLoading

          ? Center(child: CircularProgressIndicator(color: accentColor))

          : users.isEmpty

              ? const Center(child: Text("Tidak ada user ditemukan"))

              : RefreshIndicator(

                  onRefresh: fetchUsers,

                  color: accentColor,

                  child: ListView.builder(

                    padding: const EdgeInsets.all(12),

                    itemCount: users.length,

                    itemBuilder: (context, index) {

                      final user = users[index];

                      String initial = user['name'] != null && user['name'].isNotEmpty ? user['name'][0].toUpperCase() : "?";

                      bool isAdmin = user['role'] == 'admin';

                     

                      return Card(

                        elevation: 1,

                        margin: const EdgeInsets.only(bottom: 12),

                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

                        child: ListTile(

                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                          leading: CircleAvatar(

                            radius: 25,

                            backgroundColor: isAdmin ? primaryColor : accentColor.withOpacity(0.1),

                            child: Text(initial, style: TextStyle(color: isAdmin ? Colors.white : accentColor, fontWeight: FontWeight.bold, fontSize: 20)),

                          ),

                          title: Text(user['name'] ?? "No Name", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),

                          subtitle: Column(

                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              Text(user['email'] ?? "-", style: TextStyle(color: Colors.grey[600], fontSize: 13)),

                              const SizedBox(height: 6),

                              InkWell(

                                onTap: () => toggleRole(user['id'].toString(), user['role']),

                                child: Container(

                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),

                                  decoration: BoxDecoration(

                                    color: isAdmin ? primaryColor : Colors.white,

                                    borderRadius: BorderRadius.circular(20),

                                    border: Border.all(color: isAdmin ? primaryColor : accentColor),

                                  ),

                                  child: Row(

                                    mainAxisSize: MainAxisSize.min,

                                    children: [

                                      Icon(isAdmin ? Icons.verified_user : Icons.person, size: 12, color: isAdmin ? Colors.white : accentColor),

                                      const SizedBox(width: 4),

                                      Text(

                                        user['role']?.toString().toUpperCase() ?? "USER",

                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAdmin ? Colors.white : accentColor),

                                      ),

                                    ],

                                  ),

                                ),

                              ),

                            ],

                          ),

                          trailing: IconButton(

                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),

                            onPressed: () => _confirmDelete(user['id'].toString(), user['name']),

                          ),

                        ),

                      );

                    },

                  ),

                ),

      floatingActionButton: FloatingActionButton.extended(

        onPressed: _showAddUserDialog,

        backgroundColor: primaryColor,

        label: const Text("ADD USER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),

        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),

      ),

    );

  }



  void _confirmDelete(String id, String? name) {

    showDialog(

      context: context,

      builder: (context) => AlertDialog(

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

        title: const Text("Hapus User?"),

        content: Text("Apakah Anda yakin ingin menghapus data\n'${name ?? 'user ini'}'?"),

        actions: [

          TextButton(onPressed: () => Navigator.pop(context), child: Text("BATAL", style: TextStyle(color: Colors.grey[600]))),

          ElevatedButton(

            onPressed: () {

              Navigator.pop(context);

              deleteUser(id);

            },

            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

            child: const Text("HAPUS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),

          ),

        ],

      ),

    );

  }

}