import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'match_detail_page.dart';

// --- MODEL DATA KLASEMEN ---
class TeamStanding {
  final String id;
  final String teamName;
  final int mp, w, d, l, pts;
  final String goals;
  final String league;

  TeamStanding({
    required this.id, required this.teamName, required this.mp,
    required this.w, required this.d, required this.l,
    required this.pts, required this.goals, required this.league,
  });

  factory TeamStanding.fromJson(Map<String, dynamic> json) {
    return TeamStanding(
      id: json['id']?.toString() ?? "",
      teamName: json['teamName'] ?? "Unknown", 
      mp: json['mp'] ?? 0,
      w: json['w'] ?? 0,
      d: json['d'] ?? 0,
      l: json['l'] ?? 0,
      pts: json['pts'] ?? 0,
      goals: json['goals'] ?? "0:0", 
      league: json['league'] ?? "",
    );
  }
}

class StandingsPage extends StatefulWidget {
  const StandingsPage({super.key});
  @override
  State<StandingsPage> createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  String selectedLeague = "Premier League";
  List<TeamStanding> standings = [];
  List<dynamic> matches = []; 
  bool isLoading = true;
  String errorMessage = "";

  final List<String> leagues = ["Premier League", "La Liga", "Serie A", "Bundesliga", "Ligue 1"];
  final Color primaryColor = const Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      await Future.wait([
        _fetchStandings(),
        _fetchMatches(),
      ]);
    } catch (e) {
      if (mounted) setState(() => errorMessage = "Gagal terhubung ke server.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Tetap menggunakan filter liga untuk tabel klasemen
  Future<void> _fetchStandings() async {
    final url = Uri.parse('http://10.0.2.2:5000/api/standings');
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      if (mounted) {
        setState(() {
          standings = jsonResponse
              .map((data) => TeamStanding.fromJson(data))
              .where((s) => s.league.toLowerCase() == selectedLeague.toLowerCase())
              .toList();
        });
      }
    }
  }

  // MODIFIKASI: Menghapus filter agar menampilkan semua pertandingan
  Future<void> _fetchMatches() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/matches'));
    if (response.statusCode == 200) {
      List allMatches = json.decode(response.body);
      if (mounted) {
        setState(() {
          // SEKARANG: Langsung ambil semua data tanpa .where(...) filter liga
          matches = allMatches; 
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("LIGA", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: Column(
        children: [
          _buildLeagueSelector(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : RefreshIndicator(
                    onRefresh: _loadAllData,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 20),
                      children: [
                        if (standings.isNotEmpty) _buildTableCard(),
                        _buildSectionHeader("PERTANDINGAN TERBARU "),
                        _buildMatchList(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ... (Widget _buildSectionHeader, _buildTableCard, _buildColumnHeader tetap sama)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
      child: Row(
        children: [
          Icon(Icons.event_note, size: 18, color: primaryColor),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget _buildTableCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            headingRowHeight: 45,
            headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
            columns: [
              _buildColumnHeader('Pos'), 
              _buildColumnHeader('Team'), 
              _buildColumnHeader('MP'), 
              _buildColumnHeader('W'), 
              _buildColumnHeader('D'), 
              _buildColumnHeader('L'), 
              _buildColumnHeader('GD'), 
              _buildColumnHeader('Pts', isBold: true)
            ],
            rows: standings.asMap().entries.map((entry) {
              int rank = entry.key + 1;
              TeamStanding team = entry.value;
              return DataRow(cells: [
                DataCell(Text('$rank')),
                DataCell(Text(team.teamName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataCell(Text('${team.mp}')),
                DataCell(Text('${team.w}')),
                DataCell(Text('${team.d}')),
                DataCell(Text('${team.l}')),
                DataCell(Text(team.goals)),
                DataCell(Text('${team.pts}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  DataColumn _buildColumnHeader(String label, {bool isBold = false}) {
    return DataColumn(label: Text(label, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: isBold ? primaryColor : Colors.grey[700])));
  }

  Widget _buildMatchList() {
    if (matches.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Belum ada pertandingan tersedia.")));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MatchDetailPage(match: match))),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF283593), Color(0xFF1A237E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    // Menampilkan liga masing-masing pertandingan secara dinamis
                    Text(match['league'].toString().toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    match['isLive'] == 1 ? _buildLiveBadge() : const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _matchTeamWidget(match['homeTeam'], match['homeLogo']),
                    Column(
                      children: [
                        Text("${match['homeScore']} : ${match['awayScore']}", style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Text(match['status'] ?? "Upcoming", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    _matchTeamWidget(match['awayTeam'], match['awayLogo']),
                  ],
                ),
                const SizedBox(height: 15),
                const Divider(color: Colors.white24, thickness: 1),
                const SizedBox(height: 8),
                const Text("Tap untuk detail pertandingan", style: TextStyle(color: Colors.white54, fontSize: 11, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ... (Widget _buildLiveBadge, _matchTeamWidget, _buildLeagueSelector tetap sama)
  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(5)),
      child: const Text("LIVE", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _matchTeamWidget(String name, String? logo) {
    return SizedBox(
      width: 85,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Image.network(
              logo ?? '', 
              height: 40, width: 40, 
              errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 40, color: Colors.grey)
            ),
          ),
          const SizedBox(height: 8),
          Text(name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildLeagueSelector() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: leagues.length,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        itemBuilder: (context, index) {
          bool isSelected = selectedLeague == leagues[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(leagues[index]),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() => selectedLeague = leagues[index]);
                  _loadAllData(); // Tetap memanggil ini agar klasemen ikut berubah
                }
              },
              selectedColor: primaryColor,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}