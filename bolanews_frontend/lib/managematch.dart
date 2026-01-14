import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageMatchPage extends StatefulWidget {
  const ManageMatchPage({super.key});

  @override
  State<ManageMatchPage> createState() => _ManageMatchPageState();
}

class _ManageMatchPageState extends State<ManageMatchPage> {
  List matches = [];
  bool isLoading = true;

  final Color primaryColor = const Color(0xFF1E3A8A);

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  // --- HELPER UNTUK KONVERSI LIST KE TEKS (UNTUK FORM) ---
  String _formatListToText(List? list) {
    if (list == null || list.isEmpty) return "";
    return list.map((item) {
      String name = item['player_name'] ?? "";
      String team = (item['team_type'] == 'home') ? "(Home)" : "(Away)";
      return "$name $team";
    }).join(", ");
  }

  // --- AMBIL SEMUA DATA PERTANDINGAN ---
  Future<void> fetchMatches() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/matches'));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        setState(() {
          matches = jsonDecode(decodedBody);
          isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar("Gagal mengambil data: $e");
      setState(() => isLoading = false);
    }
  }

  // --- FUNGSI SAVE (CREATE / UPDATE) ---
  Future<void> saveMatch({String? id, required Map<String, dynamic> data}) async {
    try {
      // Perhatikan URL: pastikan /api/auth sesuai dengan route di backend Anda
      final url = id == null 
          ? 'http://10.0.2.2:5000/api/auth/matches' 
          : 'http://10.0.2.2:5000/api/auth/matches/$id';
      
      final response = id == null 
          ? await http.post(
              Uri.parse(url), 
              headers: {"Content-Type": "application/json"}, 
              body: jsonEncode(data))
          : await http.put(
              Uri.parse(url), 
              headers: {"Content-Type": "application/json"}, 
              body: jsonEncode(data));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar(id == null ? "Berhasil Disimpan" : "Berhasil Diupdate");
        fetchMatches(); // Refresh data setelah simpan
      } else {
        _showSnackBar("Gagal: ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Koneksi Terputus: $e");
    }
  }

  // --- HAPUS PERTANDINGAN ---
  Future<void> deleteMatch(String id) async {
    try {
      final response = await http.delete(Uri.parse('http://10.0.2.2:5000/api/auth/matches/$id'));
      if (response.statusCode == 200) {
        _showSnackBar("Pertandingan dihapus");
        fetchMatches();
      }
    } catch (e) {
      _showSnackBar("Gagal menghapus");
    }
  }

  // --- PARSE TEXT KE ARRAY OBJEK UNTUK DATABASE ---
  List<Map<String, dynamic>> _parseInputToData(String text) {
    if (text.isEmpty) return [];
    return text.split(',').where((s) => s.trim().isNotEmpty).map((e) {
      bool isAway = e.toLowerCase().contains('(away)');
      return {
        "player_name": e.replaceAll(RegExp(r'\(Home\)|\(Away\)', caseSensitive: false), '').trim(),
        "team_type": isAway ? "away" : "home"
      };
    }).toList();
  }

  // --- FORM INPUT MODAL ---
  void _showMatchForm({Map? match}) async {
    final isEdit = match != null;
    
    // Jika Edit, ambil data detail terlebih dahulu (untuk mendapatkan scorers_list & lineups_list)
    Map<String, dynamic> fullMatchData = isEdit ? Map<String, dynamic>.from(match) : {};
    
    if (isEdit) {
      try {
        final res = await http.get(Uri.parse('http://10.0.2.2:5000/api/matches/${match['id']}'));
        if (res.statusCode == 200) {
          fullMatchData = jsonDecode(res.body);
        }
      } catch (e) {
        debugPrint("Gagal load detail untuk edit: $e");
      }
    }

    final leagueCtrl = TextEditingController(text: fullMatchData['league'] ?? "");
    final hTeamCtrl = TextEditingController(text: fullMatchData['homeTeam'] ?? "");
    final aTeamCtrl = TextEditingController(text: fullMatchData['awayTeam'] ?? "");
    final hLogoCtrl = TextEditingController(text: fullMatchData['homeLogo'] ?? "");
    final aLogoCtrl = TextEditingController(text: fullMatchData['awayLogo'] ?? "");
    final hScoreCtrl = TextEditingController(text: (fullMatchData['homeScore'] ?? 0).toString());
    final aScoreCtrl = TextEditingController(text: (fullMatchData['awayScore'] ?? 0).toString());
    final timeCtrl = TextEditingController(text: fullMatchData['matchTime'] ?? "");
    final statusCtrl = TextEditingController(text: fullMatchData['status'] ?? "Upcoming");
    final scorersCtrl = TextEditingController(text: _formatListToText(fullMatchData['scorers_list'])); 
    final lineupCtrl = TextEditingController(text: _formatListToText(fullMatchData['lineups_list'])); 

    bool isLive = (fullMatchData['isLive'] == 1 || fullMatchData['isLive'] == true);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? "Edit Match" : "Tambah Match Baru"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildField(leagueCtrl, "League"),
                Row(
                  children: [
                    Expanded(child: _buildField(hTeamCtrl, "Home")),
                    const SizedBox(width: 10),
                    Expanded(child: _buildField(aTeamCtrl, "Away")),
                  ],
                ),
                _buildField(hLogoCtrl, "Logo Home (URL)"),
                _buildField(aLogoCtrl, "Logo Away (URL)"),
                Row(
                  children: [
                    Expanded(child: _buildField(hScoreCtrl, "Score H", isNumber: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildField(aScoreCtrl, "Score A", isNumber: true)),
                  ],
                ),
                _buildField(timeCtrl, "Time (e.g 45')"),
                _buildField(statusCtrl, "Status (Live/FT)"),
                SwitchListTile(
                  title: const Text("Live Now"),
                  value: isLive,
                  onChanged: (val) => setDialogState(() => isLive = val),
                ),
                const Divider(),
                const Text("Detail (Pemain, Pisah Koma)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                _buildField(scorersCtrl, "Scorers", hint: "Nama (Home), Nama (Away)"),
                _buildField(lineupCtrl, "Lineups", hint: "Nama (Home), Nama (Away)"),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("BATAL")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () {
                final data = {
                  "league": leagueCtrl.text,
                  "homeTeam": hTeamCtrl.text,
                  "awayTeam": aTeamCtrl.text,
                  "homeLogo": hLogoCtrl.text,
                  "awayLogo": aLogoCtrl.text,
                  "homeScore": int.tryParse(hScoreCtrl.text) ?? 0,
                  "awayScore": int.tryParse(aScoreCtrl.text) ?? 0,
                  "matchTime": timeCtrl.text,
                  "status": statusCtrl.text,
                  "isLive": isLive ? 1 : 0,
                  "scorers": _parseInputToData(scorersCtrl.text),
                  "lineUps": _parseInputToData(lineupCtrl.text), 
                };
                
                saveMatch(id: isEdit ? fullMatchData['id'].toString() : null, data: data);
                Navigator.pop(context);
              },
              child: const Text("SIMPAN", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, {bool isNumber = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label, hintText: hint, 
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MATCH MANAGER"), 
        backgroundColor: primaryColor, 
        foregroundColor: Colors.white,
        actions: [IconButton(onPressed: fetchMatches, icon: const Icon(Icons.refresh))],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : RefreshIndicator(
              onRefresh: fetchMatches,
              child: ListView.builder(
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final m = matches[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text("${m['homeTeam']} ${m['homeScore']} - ${m['awayScore']} ${m['awayTeam']}"),
                      subtitle: Text("${m['league']} | ${m['matchTime']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showMatchForm(match: m)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => deleteMatch(m['id'].toString())),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showMatchForm(), 
        child: const Icon(Icons.add, color: Colors.white)
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }
}