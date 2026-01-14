import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageStandingsPage extends StatefulWidget {
  const ManageStandingsPage({super.key});

  @override
  _ManageStandingsPageState createState() => _ManageStandingsPageState();
}

class _ManageStandingsPageState extends State<ManageStandingsPage> {
  // Kita gunakan Map untuk mengelompokkan data berdasarkan Liga
  Map<String, List<dynamic>> groupedStandings = {};
  bool isLoading = true;
  final Color primaryColor = const Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    fetchStandings();
  }

  Future<void> fetchStandings() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/standings'));
      
      if (response.statusCode == 200) {
        final List fetchedData = json.decode(response.body);
        
        // --- LOGIKA PENGELOMPOKKAN (GROUPING) ---
        Map<String, List<dynamic>> tempGroups = {};
        for (var team in fetchedData) {
          String leagueName = team['league'] ?? "Lainnya";
          if (!tempGroups.containsKey(leagueName)) {
            tempGroups[leagueName] = [];
          }
          tempGroups[leagueName]!.add(team);
        }

        setState(() {
          groupedStandings = tempGroups;
          isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar("Koneksi gagal ke server");
    }
  }

  // --- FUNGSI UPDATE DENGAN DEBUGGING ---
  Future<void> updateStanding(int id, Map<String, dynamic> data) async {
  try {
    final response = await http.put(
      // Tambahkan /auth di sini
      Uri.parse('http://10.0.2.2:5000/api/auth/standings/$id'), 
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
      );

      print("Status Code: ${response.statusCode}"); // Debug Log
      print("Respon Server: ${response.body}"); // Debug Log

      if (response.statusCode == 200) {
        _showSnackBar("✅ Data Berhasil Diperbarui!");
        fetchStandings(); // Segera ambil data terbaru dari DB
      } else {
        _showSnackBar("Gagal memperbarui: ${response.statusCode}");
      }
    } catch (e) {
      print("Error Update: $e");
      _showSnackBar("Kesalahan jaringan atau server");
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> leagues = groupedStandings.keys.toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Manage Standings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedStandings.isEmpty
              ? const Center(child: Text("Tidak ada data klasemen"))
              : ListView.builder(
                  itemCount: leagues.length,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemBuilder: (context, index) {
                    String leagueName = leagues[index];
                    List<dynamic> teams = groupedStandings[leagueName]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 15, 16, 5),
                          child: Row(
                            children: [
                              const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                leagueName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: primaryColor,
                                  letterSpacing: 1.2
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...teams.map((team) => _buildTeamCard(team)).toList(),
                        const Divider(height: 30, thickness: 1, indent: 20, endIndent: 20),
                      ],
                    );
                  },
                ),
    );
  }

  Widget _buildTeamCard(Map team) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          team['teamName'] ?? "Unknown",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "MP: ${team['mp']}  |  W: ${team['w']}  |  D: ${team['d']}  |  L: ${team['l']}  |  Pts: ${team['pts']}",
          style: const TextStyle(fontSize: 13),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_note, color: Colors.blueAccent, size: 28),
          onPressed: () => _showEditDialog(team),
        ),
      ),
    );
  }

  void _showEditDialog(Map team) {
    TextEditingController mpController = TextEditingController(text: (team['mp'] ?? 0).toString());
    TextEditingController wController = TextEditingController(text: (team['w'] ?? 0).toString());
    TextEditingController dController = TextEditingController(text: (team['d'] ?? 0).toString());
    TextEditingController lController = TextEditingController(text: (team['l'] ?? 0).toString());
    TextEditingController ptsController = TextEditingController(text: (team['pts'] ?? 0).toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update ${team['teamName']}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditField(mpController, "Matches Played (MP)"),
              _buildEditField(wController, "Won (W)"),
              _buildEditField(dController, "Drawn (D)"),
              _buildEditField(lController, "Lost (L)"),
              _buildEditField(ptsController, "Points (PTS)"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () {
              updateStanding(team['id'], {
                "mp": int.tryParse(mpController.text) ?? 0,
                "w": int.tryParse(wController.text) ?? 0,
                "d": int.tryParse(dController.text) ?? 0,
                "l": int.tryParse(lController.text) ?? 0,
                "pts": int.tryParse(ptsController.text) ?? 0,
              });
              Navigator.pop(context);
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}