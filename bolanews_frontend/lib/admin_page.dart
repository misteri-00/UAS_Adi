import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_list_page.dart';
import 'manage_news_page.dart'; 
import 'managematch.dart'; 
import 'manage_videos_page.dart';
import 'manage_standings_page.dart'; // 1. Tambahkan Import Manage Standings

class AdminPage extends StatefulWidget {
  final Map<String, dynamic> adminData;
  const AdminPage({super.key, required this.adminData});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // --- FUNGSI LOGOUT ---
  Future<void> _handleLogout() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari Admin Panel?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("BATAL"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("LOGOUT", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); 

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("ADMIN PANEL", 
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), 
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAdminHeader(),
          
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildMenuCard("MANAGE MATCH", Icons.sports_soccer, Colors.blue),
                _buildMenuCard("MANAGE NEWS", Icons.newspaper, Colors.orange),
                _buildMenuCard("MANAGE VIDEOS", Icons.play_circle_fill, Colors.red),
                _buildMenuCard("STANDINGS", Icons.leaderboard, Colors.green), // Sekarang sudah aktif
                _buildMenuCard("USER LIST", Icons.people, Colors.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminHeader() {
    String name = widget.adminData['name'] ?? "Admin";
    String email = widget.adminData['email'] ?? "Email tidak tersedia";
    String imageUrl = widget.adminData['imageUrl'] ?? "";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo[900],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white24,
            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            child: imageUrl.isEmpty 
                ? const Icon(Icons.person, size: 40, color: Colors.white) 
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name, 
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email, 
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber, 
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: const Text("SUPER ADMIN", 
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        Widget nextPage;
        switch (title) {
          case "USER LIST":
            nextPage = const UserListPage();
            break;
          case "MANAGE NEWS":
            nextPage = const ManageNewsPage();
            break;
          case "MANAGE MATCH":
            nextPage = const ManageMatchPage(); 
            break;
          case "MANAGE VIDEOS":
            nextPage = const ManageVideosPage();
            break;
          case "STANDINGS": // 2. Tambahkan navigasi ke halaman ManageStandings
            nextPage = const ManageStandingsPage();
            break;
          default:
            return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 10,
              offset: const Offset(0, 5)
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 35, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}