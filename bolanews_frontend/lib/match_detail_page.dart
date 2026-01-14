import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MatchDetailPage extends StatefulWidget {
  final Map<String, dynamic> match;

  const MatchDetailPage({super.key, required this.match});

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<dynamic> _scorers = [];
  List<dynamic> _lineups = [];
  bool _isLoadingDetail = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAdditionalData();
  }

  // --- FUNGSI FETCH DENGAN PENANGANAN ERROR LEBIH DETAIL ---
  Future<void> _fetchAdditionalData() async {
    try {
      final matchId = widget.match['id'].toString();
      final url = Uri.parse('http://10.0.2.2:5000/api/matches/$matchId');
      
      debugPrint("Mencoba memanggil: $url");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("Data detail berhasil diterima");

        setState(() {
          // Menyesuaikan dengan nama field yang dikirim oleh backend (scorers_list)
          _scorers = data['scorers_list'] ?? [];
          _lineups = data['lineups_list'] ?? [];
          _isLoadingDetail = false;
        });
      } else {
        debugPrint("Server merespon dengan error: ${response.statusCode}");
        setState(() => _isLoadingDetail = false);
      }
    } catch (e) {
      debugPrint("Gagal terhubung ke server: $e");
      setState(() => _isLoadingDetail = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Pertandingan"),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildScoreHeader(),
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(text: "Info"),
              Tab(text: "Line-ups"),
              Tab(text: "Stats"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildLineUpTab(),
                const Center(child: Text("Statistik segera hadir")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF1976D2),
      child: Column(
        children: [
          Text(
            widget.match['league'] ?? "League", 
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTeamCol(widget.match['homeTeam'] ?? "Home", widget.match['homeLogo']),
              Column(
                children: [
                  Text(
                    "${widget.match['homeScore'] ?? 0} - ${widget.match['awayScore'] ?? 0}",
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.match['matchTime'] ?? "FT",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              _buildTeamCol(widget.match['awayTeam'] ?? "Away", widget.match['awayLogo']),
            ],
          ),
          const SizedBox(height: 20),
          _buildScorersSection(), 
        ],
      ),
    );
  }

  Widget _buildScorersSection() {
    if (_isLoadingDetail) {
      return const Center(
        child: SizedBox(
          width: 15, 
          height: 15, 
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
        )
      );
    }
    
    if (_scorers.isEmpty) {
      return const Text("Tidak ada data pencetak gol", style: TextStyle(color: Colors.white60, fontSize: 11));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _scorers.where((s) => s['team_type'] == 'home').map<Widget>((s) {
              return Text("${s['player_name']} ⚽", style: const TextStyle(color: Colors.white, fontSize: 11));
            }).toList(),
          ),
        ),
        const SizedBox(width: 40, child: Icon(Icons.sports_soccer, color: Colors.white24, size: 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _scorers.where((s) => s['team_type'] == 'away').map<Widget>((s) {
              return Text("⚽ ${s['player_name']}", style: const TextStyle(color: Colors.white, fontSize: 11));
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCol(String name, String? logoUrl) {
    return Column(
      children: [
        Container(
          width: 70, height: 70, padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: logoUrl != null && logoUrl.isNotEmpty
              ? Image.network(logoUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.shield, color: Colors.grey))
              : const Icon(Icons.shield, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildLineUpTab() {
    if (_isLoadingDetail) return const Center(child: CircularProgressIndicator());
    if (_lineups.isEmpty) return const Center(child: Text("Line-up belum tersedia"));

    return Container(
      color: const Color(0xFF2E7D32),
      child: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: FieldPainter()),
          _buildTacticalGrid(),
        ],
      ),
    );
  }

  Widget _buildTacticalGrid() {
    List homePlayers = _lineups.where((p) => p['team_type'] == 'home').toList();
    List awayPlayers = _lineups.where((p) => p['team_type'] == 'away').toList();

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center, 
              spacing: 15, 
              runSpacing: 15, 
              children: awayPlayers.map((p) => _playerIcon(p, Colors.redAccent)).toList()
            )
          )
        ),
        const Divider(color: Colors.white54, thickness: 2),
        Expanded(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center, 
              spacing: 15, 
              runSpacing: 15, 
              children: homePlayers.map((p) => _playerIcon(p, Colors.blueAccent)).toList()
            )
          )
        ),
      ],
    );
  }

  Widget _playerIcon(Map p, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 14, backgroundColor: color, child: const Icon(Icons.person, size: 16, color: Colors.white)),
        const SizedBox(height: 4),
        Text(
          p['player_name'] ?? "Player", 
          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoTile(Icons.timer, "Status", widget.match['status'] ?? "-"),
        _infoTile(Icons.update, "Waktu", widget.match['matchTime'] ?? "-"),
        _infoTile(Icons.stadium, "Kompetisi", widget.match['league'] ?? "-"),
      ],
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

class FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(10, 10, size.width - 20, size.height - 20), paint);
    canvas.drawLine(Offset(10, size.height / 2), Offset(size.width - 10, size.height / 2), paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 50, paint);
  }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}