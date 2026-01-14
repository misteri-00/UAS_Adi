import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditMatchPage extends StatefulWidget {
  final Map<String, dynamic> match;
  const EditMatchPage({super.key, required this.match});

  @override
  State<EditMatchPage> createState() => _EditMatchPageState();
}

class _EditMatchPageState extends State<EditMatchPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  late TextEditingController _homeScoreCtrl;
  late TextEditingController _awayScoreCtrl;
  late TextEditingController _matchTimeCtrl;
  late TextEditingController _statusCtrl;
  late TextEditingController _leagueCtrl;
  
  // Tambahan Controller untuk Scorers dan Lineups
  late TextEditingController _scorersCtrl;
  late TextEditingController _lineupsCtrl;
  
  late bool _isLive;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _homeScoreCtrl = TextEditingController(text: widget.match['homeScore'].toString());
    _awayScoreCtrl = TextEditingController(text: widget.match['awayScore'].toString());
    _matchTimeCtrl = TextEditingController(text: widget.match['matchTime']);
    _statusCtrl = TextEditingController(text: widget.match['status']);
    _leagueCtrl = TextEditingController(text: widget.match['league']);
    _isLive = widget.match['isLive'] == 1;

    // Inisialisasi teks dari list database
    _scorersCtrl = TextEditingController(text: _formatListToText(widget.match['scorers_list']));
    _lineupsCtrl = TextEditingController(text: _formatListToText(widget.match['lineups_list']));
  }

  // Helper untuk mengubah List DB menjadi String Teks
  String _formatListToText(List? list) {
    if (list == null || list.isEmpty) return "";
    return list.map((item) {
      String name = item['player_name'] ?? "";
      String team = (item['team_type'] == 'home') ? "(Home)" : "(Away)";
      return "$name $team";
    }).join(", ");
  }

  // Helper untuk mengubah String Teks menjadi List JSON untuk Backend
  List<Map<String, dynamic>> _parseInputToData(String text) {
    if (text.isEmpty) return [];
    return text.split(',').where((s) => s.trim().isNotEmpty).map((e) {
      bool isAway = e.toLowerCase().contains('(away)');
      return {
        "player_name": e.replaceAll(RegExp(r'\(Home\)|\(Away\)', caseSensitive: false), '').trim(),
        "minute": 0, 
        "team_type": isAway ? "away" : "home"
      };
    }).toList();
  }

  Future<void> _updateData() async {
    final url = 'http://10.0.2.2:5000/api/auth/matches/${widget.match['id']}';
    
    // Siapkan body dengan data yang diperbarui termasuk list kompleks
    final body = {
      ...widget.match, 
      "homeScore": int.tryParse(_homeScoreCtrl.text) ?? 0,
      "awayScore": int.tryParse(_awayScoreCtrl.text) ?? 0,
      "matchTime": _matchTimeCtrl.text,
      "status": _statusCtrl.text,
      "league": _leagueCtrl.text,
      "isLive": _isLive ? 1 : 0,
      "scorers": _parseInputToData(_scorersCtrl.text),
      "lineUps": _parseInputToData(_lineupsCtrl.text), // Sesuai key Backend
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pertandingan Berhasil Diperbarui!"), backgroundColor: Colors.green)
        );
        Navigator.pop(context, true); 
      } else {
        print("Response Error: ${response.body}");
        _showErrorSnackBar("Gagal Update: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorSnackBar("Koneksi Error: $e");
    }
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Match"),
        backgroundColor: const Color(0xFF1976D2),
        actions: [
          IconButton(icon: const Icon(Icons.save, size: 28), onPressed: _updateData)
        ],
      ),
      body: Column(
        children: [
          _buildEditableHeader(),
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: const [Tab(text: "Informasi Utama"), Tab(text: "Scorers & Lineups")],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildAdvancedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF1976D2),
      child: Column(
        children: [
          TextField(
            controller: _leagueCtrl,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
            decoration: const InputDecoration(border: InputBorder.none, hintText: "Nama Liga"),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTeamCol(widget.match['homeTeam'], widget.match['homeLogo']),
              Row(
                children: [
                  _scoreBox(_homeScoreCtrl),
                  const Text(" : ", style: TextStyle(color: Colors.white, fontSize: 30)),
                  _scoreBox(_awayScoreCtrl),
                ],
              ),
              _buildTeamCol(widget.match['awayTeam'], widget.match['awayLogo']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scoreBox(TextEditingController ctrl) {
    return Container(
      width: 60,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: ctrl,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInputField(_matchTimeCtrl, "Waktu Pertandingan", Icons.timer),
        _buildInputField(_statusCtrl, "Status Teks (Live/FT)", Icons.info_outline),
        SwitchListTile(
          title: const Text("Tampilkan Label Live"),
          subtitle: const Text("Akan memunculkan indikator merah di aplikasi user"),
          value: _isLive,
          activeColor: Colors.red,
          onChanged: (val) => setState(() => _isLive = val),
        ),
      ],
    );
  }

  Widget _buildAdvancedTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("PENCETAK GOL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        const SizedBox(height: 8),
        _buildInputField(_scorersCtrl, "Scorers", Icons.sports_soccer, hint: "Vini (Home), Rodri (Away)"),
        const SizedBox(height: 20),
        const Text("SUSUNAN PEMAIN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(height: 8),
        _buildInputField(_lineupsCtrl, "Lineups", Icons.people, hint: "Alisson (Home), Ederson (Away)"),
        const Card(
          color: Color(0xFFFFF9C4),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Format: Nama Pemain (Home) atau Nama Pemain (Away). Pisahkan antar pemain dengan koma.",
              style: TextStyle(fontSize: 11, color: Colors.black87),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildInputField(TextEditingController ctrl, String label, IconData icon, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildTeamCol(String name, String? logoUrl) {
    return Column(
      children: [
        Image.network(logoUrl ?? "", width: 50, height: 50, errorBuilder: (_, __, ___) => const Icon(Icons.shield, color: Colors.white, size: 50)),
        const SizedBox(height: 5),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}