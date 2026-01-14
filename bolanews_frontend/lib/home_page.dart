import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Pastikan file-file ini ada di proyekmu
import 'match_detail_page.dart'; 
import 'news_detail_page.dart';  
import 'profile_page.dart';
import 'liga_page.dart'; 
import 'video_player_page.dart'; 

class HomePage extends StatefulWidget {
  final String userId; 
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isNewsFilterSelected = true; 

  // TAMBAHAN: Controller untuk pencarian
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  Future<Map<String, dynamic>>? _latestMatchFuture;
  Future<List<dynamic>>? _newsFuture;
  Future<List<dynamic>>? _videosFuture;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isNotificationOpen = false;

  Timer? _pollingTimer;
  List<dynamic> _recentNotifications = []; 
  bool _hasNewUpdate = false;
  int? _lastNewsId;
  int? _lastVideoId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _refreshData();
    await _loadLastData(); 
    await _checkForUpdates();
    _startPolling();
  }

  // TAMBAHAN: Fungsi untuk navigasi ke tab news dan fokus ke pencarian
  void _navigateToSearch() {
    setState(() {
      _selectedIndex = 1; // Pindah ke tab News
    });
  }

  // ... (Fungsi load data, polling, dan notification tetap sama seperti kode Anda)

  Future<void> _loadLastData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastNewsId = prefs.getInt('last_news_id');
      _lastVideoId = prefs.getInt('last_video_id');
      
      String? savedNotifJson = prefs.getString('saved_notifications');
      if (savedNotifJson != null) {
        final List<dynamic> decodedList = jsonDecode(savedNotifJson);
        _recentNotifications = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    });
  }

  Future<void> _triggerManualUpdateCheck() async {
    try {
      final List<dynamic> videos = await fetchVideos();
      if (videos.isNotEmpty) {
        int currentVideoId = int.tryParse(videos[0]['id'].toString()) ?? 0;
        if (_lastVideoId == null || currentVideoId > _lastVideoId!) {
          setState(() {
            _hasNewUpdate = true;
            final newItem = Map<String, dynamic>.from(videos[0]);
            newItem['type'] = 'video';
            _recentNotifications = [newItem, ..._recentNotifications].take(5).toList();
            _lastVideoId = currentVideoId;
          });
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('last_video_id', currentVideoId);
          await prefs.setString('saved_notifications', jsonEncode(_recentNotifications));
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Video baru ditemukan!"), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      debugPrint("ERROR SAAT CEK: $e");
    }
  }

  Future<void> _resetNotificationTest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_news_id');
    await prefs.remove('last_video_id');
    await prefs.remove('saved_notifications');
    
    setState(() {
      _lastNewsId = null;
      _lastVideoId = null;
      _recentNotifications = [];
      _hasNewUpdate = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("History dibersihkan."), backgroundColor: Colors.orange),
    );
  }

  void _refreshData() {
    setState(() {
      _latestMatchFuture = fetchLatestMatch();
      _newsFuture = fetchNews();
      _videosFuture = fetchVideos();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _closeNotification();
    _searchController.dispose(); // TAMBAHAN
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<dynamic> news = await fetchNews();
      final List<dynamic> videos = await fetchVideos();

      bool updateDetected = false;
      List<dynamic> newItems = [];

      if (news.isNotEmpty) {
        int currentNewsId = int.tryParse(news[0]['id'].toString()) ?? 0;
        if (_lastNewsId != null && currentNewsId > _lastNewsId!) {
          var item = Map<String, dynamic>.from(news[0]);
          item['type'] = 'news';
          newItems.add(item);
          updateDetected = true;
        }
        _lastNewsId = currentNewsId;
        await prefs.setInt('last_news_id', currentNewsId);
      }

      if (videos.isNotEmpty) {
        int currentVideoId = int.tryParse(videos[0]['id'].toString()) ?? 0;
        if (_lastVideoId != null && currentVideoId > _lastVideoId!) {
          var item = Map<String, dynamic>.from(videos[0]);
          item['type'] = 'video';
          newItems.add(item);
          updateDetected = true;
        }
        _lastVideoId = currentVideoId;
        await prefs.setInt('last_video_id', currentVideoId);
      }

      if (updateDetected) {
        setState(() {
          _hasNewUpdate = true;
          _recentNotifications = [...newItems, ..._recentNotifications].take(5).toList();
        });
        await prefs.setString('saved_notifications', jsonEncode(_recentNotifications));
        
        if (_isNotificationOpen) {
          _closeNotification();
          _showNotificationPanel();
        }
      }
    } catch (e) {
      debugPrint("Update check error: $e");
    }
  }

  void _toggleNotification() {
    if (_isNotificationOpen) {
      _closeNotification();
    } else {
      _showNotificationPanel();
    }
  }

  void _closeNotification() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isNotificationOpen = false;
    });
  }

  void _showNotificationPanel() {
    setState(() {
      _isNotificationOpen = true;
      _hasNewUpdate = false; 
    });

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _closeNotification,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: 320, 
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(-280, 50), 
              child: Material(
                elevation: 20,
                shadowColor: Colors.black54,
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF1E1E1E), 
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildNotificationHeader(),
                      const Divider(color: Colors.white10, height: 1),
                      if (_recentNotifications.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(Icons.notifications_off_outlined, color: Colors.white24, size: 40),
                              SizedBox(height: 8),
                              Text("Belum ada pembaruan", style: TextStyle(color: Colors.white54)),
                            ],
                          ),
                        )
                      else
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _recentNotifications.length,
                            separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                            itemBuilder: (context, index) => _buildNotificationItem(_recentNotifications[index]),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(color: Color(0xFF1A237E)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Text("Update Terbaru", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          InkWell(
            onTap: _closeNotification,
            child: const Icon(Icons.close, color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(dynamic item) {
    bool isNews = item['type'] == 'news';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: isNews ? Colors.blue.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        child: Icon(
          isNews ? Icons.article_rounded : Icons.play_circle_filled_rounded,
          color: isNews ? Colors.blueAccent : Colors.redAccent,
          size: 22,
        ),
      ),
      title: Text(
        item['title'] ?? "No Title",
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          isNews ? "Klik untuk baca berita" : "Tonton cuplikan gol",
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ),
      onTap: () {
        _closeNotification();
        final Map<String, dynamic> dataFormatted = Map<String, dynamic>.from(item);
        if (isNews) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailPage(news: dataFormatted)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerPage(data: dataFormatted)));
        }
      },
    );
  }

  // --- API FETCH ---
  Future<Map<String, dynamic>> fetchLatestMatch() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/matches/latest')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Map<String, dynamic>.from(data is List ? data[0] : data);
      }
      throw Exception('Data Match Kosong');
    } catch (e) { throw Exception('Gagal memuat pertandingan'); }
  }

  Future<List<dynamic>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/news'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Gagal memuat berita');
    } catch (e) { throw Exception('Kesalahan koneksi berita'); }
  }

  Future<List<dynamic>> fetchVideos() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/videos'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Gagal memuat video');
    } catch (e) { throw Exception('Kesalahan koneksi video'); }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); 
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("BOLANEWS", style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          IconButton(onPressed: _triggerManualUpdateCheck, icon: const Icon(Icons.bolt, color: Colors.amber)),
          IconButton(onPressed: _resetNotificationTest, icon: const Icon(Icons.delete_sweep, color: Colors.grey)),
          // MODIFIKASI: Tombol search sekarang memicu navigasi ke tab news
          IconButton(onPressed: _navigateToSearch, icon: const Icon(Icons.search, color: Colors.black)),
          CompositedTransformTarget(
            link: _layerLink,
            child: Stack(
              children: [
                IconButton(
                  onPressed: _toggleNotification,
                  icon: Icon(_isNotificationOpen ? Icons.notifications : Icons.notifications_none, color: Colors.black),
                ),
                if (_hasNewUpdate)
                  Positioned(
                    right: 12, top: 12,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Yakin ingin keluar dari akun?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("BATAL")),
                    TextButton(onPressed: _logout, child: const Text("YA", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
            }, 
            icon: const Icon(Icons.logout, color: Colors.redAccent)
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(), 
          _buildNewsContent(), 
          const StandingsPage(), 
          ProfilePage(userId: widget.userId), 
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            // TAMBAHAN: Reset pencarian jika pindah tab (opsional)
            if (index != 1) {
              _searchQuery = "";
              _searchController.clear();
            }
          });
        },
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: "News"),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: "Liga"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // ... (Sisa Widget Home Content, Match Card, dll tetap sama)

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
        return await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: _latestMatchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return _buildErrorCard();
                } else if (!snapshot.hasData) {
                  return const SizedBox();
                } else {
                  return _buildLiveMatchCard(snapshot.data!);
                }
              },
            ),
            const SizedBox(height: 25),
            _buildSectionHeader("Trending Now"),
            const SizedBox(height: 15),
            _buildTrendingNewsSection(),
            const SizedBox(height: 25),
            _buildSectionHeader("Highlights"),
            const SizedBox(height: 15),
            FutureBuilder<List<dynamic>>(
              future: _videosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text("Tidak ada video highlight terbaru.");
                final videoData = snapshot.data!.take(3).toList();
                return Column(
                  children: videoData.map((video) {
                    return _buildHighlightItem(
                      video['title'] ?? "Video Match",
                      "Tonton momen terbaik pertandingan",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerPage(data: Map<String, dynamic>.from(video)))),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // MODIFIKASI: Halaman news sekarang memiliki bar pencarian
  Widget _buildNewsContent() {
    return Column(
      children: [
        // TAMBAHAN: Bar Pencarian
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: "Cari berita atau video...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              _buildFilterTab("News", _isNewsFilterSelected, () => setState(() => _isNewsFilterSelected = true)),
              const SizedBox(width: 12),
              _buildFilterTab("Videos", !_isNewsFilterSelected, () => setState(() => _isNewsFilterSelected = false)),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _isNewsFilterSelected ? _newsFuture : _videosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return const Center(child: Text("Gagal mengambil data"));
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Belum ada konten terbaru."));
              
              // TAMBAHAN: Logika Filter Pencarian
              final filteredList = snapshot.data!.where((item) {
                final title = (item['title'] ?? "").toString().toLowerCase();
                return title.contains(_searchQuery);
              }).toList();

              if (filteredList.isEmpty) {
                return const Center(child: Text("Hasil tidak ditemukan."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final item = filteredList[index];
                  return _isNewsFilterSelected 
                    ? _buildNewsCard(Map<String, dynamic>.from(item)) 
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildHighlightItem(
                          item['title'], "Watch highlights & analysis",
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VideoPlayerPage(data: Map<String, dynamic>.from(item)))),
                        ),
                      );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- SUB-WIDGETS ---
  Widget _buildFilterTab(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isActive ? const Color(0xFF1A237E) : Colors.grey[200], borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  Widget _buildLiveMatchCard(Map<String, dynamic> match) {
  return InkWell(
    // Memastikan objek 'match' dikirim secara utuh ke halaman detail
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchDetailPage(match: match),
      ),
    ),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          // Header: Liga + Badge LIVE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40), // Spacer seimbang
              Text(
                match['league']?.toUpperCase() ?? "LEAGUE",
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              _buildLiveBadge(), // Tambahan badge animasi merah
            ],
          ),
          const SizedBox(height: 20),
          
          // Row Skor Utama
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildTeam(match['homeTeam'] ?? "Home", match['homeLogo'])),
              
              // Skor Tengah
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Text(
                      "${match['homeScore'] ?? 0} : ${match['awayScore'] ?? 0}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Menit Pertandingan
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        match['matchTime'] ?? "00'",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(child: _buildTeam(match['awayTeam'] ?? "Away", match['awayLogo'])),
            ],
          ),
          
          const SizedBox(height: 15),
          const Divider(color: Colors.white24, thickness: 1),
          
          // Footer: Klik untuk detail
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              "Tap untuk detail pertandingan",
              style: TextStyle(color: Colors.white54, fontSize: 10, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    ),
  );
}

// Widget Tambahan untuk Badge LIVE di pojok
Widget _buildLiveBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(4),
    ),
    child: const Text(
      "LIVE",
      style: TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

  Widget _buildTeam(String name, String? logoUrl) {
    return Column(
      children: [
        Container(
          width: 55, height: 55, padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: logoUrl != null && logoUrl.isNotEmpty 
            ? Image.network(logoUrl, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.shield)) 
            : const Icon(Icons.shield),
        ),
        const SizedBox(height: 8),
        SizedBox(width: 80, child: Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
      ],
    );
  }

  Widget _buildTrendingNewsSection() {
    return FutureBuilder<List<dynamic>>(
      future: _newsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox(height: 150);
        if (snapshot.hasError || !snapshot.hasData) return const Text("Gagal memuat berita.");
        final trendingList = snapshot.data!;
        return SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trendingList.length > 5 ? 5 : trendingList.length,
            itemBuilder: (context, index) => _buildTrendingCard(Map<String, dynamic>.from(trendingList[index])),
          ),
        );
      },
    );
  }

  Widget _buildTrendingCard(Map<String, dynamic> news) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailPage(news: news))),
      child: Container(
        width: 260, margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3, 
                child: news['imageUrl'] != null 
                  ? Image.network(news['imageUrl'], width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey)) 
                  : Container(color: Colors.grey)
              ),
              Expanded(flex: 2, child: Padding(padding: const EdgeInsets.all(12), child: Text(news['title'] ?? "", maxLines: 2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailPage(news: news))),
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            if (news['imageUrl'] != null) Image.network(news['imageUrl'], height: 180, width: double.infinity, fit: BoxFit.cover),
            Padding(padding: const EdgeInsets.all(15), child: Text(news['title'] ?? "", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
        const Text("See More", style: TextStyle(color: Colors.blue, fontSize: 12)),
      ],
    );
  }

  Widget _buildHighlightItem(String title, String desc, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.play_circle_fill, color: Color(0xFF1A237E))),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }

  Widget _buildErrorCard() => Container(
    width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(20)),
    child: const Center(child: Text("Data pertandingan tidak tersedia saat ini", style: TextStyle(color: Colors.red))),
  );
}