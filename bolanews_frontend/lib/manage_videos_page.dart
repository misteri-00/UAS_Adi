import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageVideosPage extends StatefulWidget {
  const ManageVideosPage({super.key});

  @override
  State<ManageVideosPage> createState() => _ManageVideosPageState();
}

class _ManageVideosPageState extends State<ManageVideosPage> {
  List videos = [];
  bool isLoading = true;

  // --- RUTE API (DISESUAIKAN DENGAN authRoutes.js) ---
  // Kita gunakan satu base URL yang mengarah ke endpoint admin Anda
  final String adminUrl = 'http://10.0.2.2:5000/api/auth/videos'; 

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  // --- AMBIL DATA ---
  Future<void> fetchVideos() async {
    setState(() => isLoading = true);
    try {
      // Menggunakan adminUrl karena di authRoutes ada: router.get('/videos', ...)
      final response = await http.get(Uri.parse(adminUrl));
      if (response.statusCode == 200) {
        setState(() {
          videos = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        _showSnackBar("Gagal memuat: Status ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      _showSnackBar("Gagal memuat video: $e");
      setState(() => isLoading = false);
    }
  }

  // --- TAMBAH / UPDATE VIDEO ---
  Future<void> saveVideo({int? id, required Map<String, dynamic> data}) async {
    try {
      // Jika ID ada, maka URL menjadi .../videos/id (untuk PUT)
      // Jika ID null, maka URL tetap .../videos (untuk POST)
      final String targetUrl = id == null ? adminUrl : '$adminUrl/$id';
      
      print("Request ke: $targetUrl"); // Untuk memudahkan debug di console

      final response = id == null
          ? await http.post(
              Uri.parse(targetUrl),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(data),
            )
          : await http.put(
              Uri.parse(targetUrl),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(data),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar(id == null ? "Video ditambahkan" : "Video diperbarui");
        fetchVideos();
      } else {
        _showSnackBar("Gagal (${response.statusCode}): Periksa rute Backend");
        print("Response Body: ${response.body}");
      }
    } catch (e) {
      _showSnackBar("Error koneksi: $e");
    }
  }

  // --- HAPUS VIDEO ---
  Future<void> deleteVideo(int id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Hapus Video?"),
        content: const Text("Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("BATAL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("HAPUS", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Menggunakan adminUrl/$id untuk DELETE
        final response = await http.delete(Uri.parse('$adminUrl/$id'));
        if (response.statusCode == 200) {
          _showSnackBar("Video berhasil dihapus");
          fetchVideos();
        } else {
          _showSnackBar("Gagal menghapus: ${response.statusCode}");
        }
      } catch (e) {
        _showSnackBar("Gagal koneksi server");
      }
    }
  }

  // --- FORM DIALOG (TAMBAH & EDIT) ---
  void _showVideoForm({Map? video}) {
    final isEdit = video != null;
    final titleCtrl = TextEditingController(text: video?['title'] ?? "");
    final categoryCtrl = TextEditingController(text: video?['category'] ?? "Highlights");
    final thumbCtrl = TextEditingController(text: video?['thumbnailUrl'] ?? "");
    final urlCtrl = TextEditingController(text: video?['videoUrl'] ?? "");
    final durationCtrl = TextEditingController(text: video?['duration'] ?? "00:00");
    final descCtrl = TextEditingController(text: video?['description'] ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEdit ? "Edit Video" : "Tambah Video Baru", 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(titleCtrl, "Judul Video"),
              _buildTextField(categoryCtrl, "Kategori"),
              _buildTextField(thumbCtrl, "URL Thumbnail (Image)"),
              _buildTextField(urlCtrl, "URL Video (YouTube)"),
              _buildTextField(durationCtrl, "Durasi (ex: 10:45)"),
              _buildTextField(descCtrl, "Deskripsi", maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("BATAL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isEdit ? Colors.indigo[900] : Colors.green[700]
            ),
            onPressed: () {
              final data = {
                "title": titleCtrl.text,
                "category": categoryCtrl.text,
                "thumbnailUrl": thumbCtrl.text,
                "videoUrl": urlCtrl.text,
                "duration": durationCtrl.text,
                "description": descCtrl.text,
                "publishedAt": video?['publishedAt'] ?? DateTime.now().toIso8601String(),
              };
              saveVideo(id: isEdit ? video['id'] : null, data: data);
              Navigator.pop(context);
            },
            child: Text(isEdit ? "UPDATE" : "SIMPAN", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.indigo[900]!, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("VIDEO MANAGER", 
          style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.indigo[900]))
          : videos.isEmpty 
              ? const Center(child: Text("Tidak ada video ditemukan"))
              : RefreshIndicator(
                  onRefresh: fetchVideos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final video = videos[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: Stack(
                                children: [
                                  Image.network(
                                    video['thumbnailUrl'] ?? '',
                                    height: 190,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 190,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 50),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10, right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                                      child: Text(video['duration'] ?? "00:00", style: const TextStyle(color: Colors.white, fontSize: 12)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(video['title'] ?? 'No Title', 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 5),
                                  Text(video['category'] ?? 'General', 
                                    style: TextStyle(color: Colors.indigo[700], fontWeight: FontWeight.w600, fontSize: 13)),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.edit, size: 20),
                                  label: const Text("EDIT"),
                                  onPressed: () => _showVideoForm(video: video),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  label: const Text("HAPUS", style: TextStyle(color: Colors.red)),
                                  onPressed: () => deleteVideo(video['id']),
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo[900],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showVideoForm(),
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg), 
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.indigo[900],
      )
    );
  }
}