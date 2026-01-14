import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageNewsPage extends StatefulWidget {
  const ManageNewsPage({super.key});

  @override
  State<ManageNewsPage> createState() => _ManageNewsPageState();
}

class _ManageNewsPageState extends State<ManageNewsPage> {
  List newsList = [];
  bool isLoading = true;

  // TEMA WARNA ADMIN PANEL (BIRU)
  final Color primaryColor = const Color(0xFF1E3A8A); // Indigo/Blue Gelap
  final Color accentColor = const Color(0xFF3B82F6);  // Biru Terang
  final Color backgroundColor = const Color(0xFFF1F5F9); // Biru Abu-abu muda

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/news'));
      if (response.statusCode == 200) {
        setState(() {
          newsList = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Gagal mengambil data berita");
    }
  }

  Future<void> addNews(String title, String img, String cat, String content) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/auth/news'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "imageUrl": img,
          "category": cat,
          "content": content
        }),
      );
      if (response.statusCode == 201) {
        _showSnackBar("Berita berhasil ditambah");
        fetchNews();
      }
    } catch (e) {
      _showSnackBar("Kesalahan koneksi");
    }
  }

  Future<void> updateNews(String id, String title, String img, String cat, String content) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:5000/api/auth/news/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "imageUrl": img,
          "category": cat,
          "content": content
        }),
      );
      if (response.statusCode == 200) {
        _showSnackBar("Berita berhasil diperbarui");
        fetchNews();
      }
    } catch (e) {
      _showSnackBar("Terjadi kesalahan koneksi");
    }
  }

  Future<void> deleteNews(String id) async {
    try {
      final response = await http.delete(Uri.parse('http://10.0.2.2:5000/api/auth/news/$id'));
      if (response.statusCode == 200) {
        _showSnackBar("Berita dihapus");
        fetchNews();
      }
    } catch (e) {
      _showSnackBar("Gagal menghapus");
    }
  }

  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: primaryColor,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final imgCtrl = TextEditingController();
    final catCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Tambah Berita Baru", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(titleCtrl, "Judul Berita"),
              _buildTextField(imgCtrl, "URL Gambar"),
              _buildTextField(catCtrl, "Kategori"),
              _buildTextField(contentCtrl, "Konten Lengkap", maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("BATAL", style: TextStyle(color: Colors.grey[600]))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                addNews(titleCtrl.text, imgCtrl.text, catCtrl.text, contentCtrl.text);
                Navigator.pop(context);
              }
            },
            child: const Text("SIMPAN"),
          )
        ],
      ),
    );
  }

  void _showEditDialog(Map item) {
    final titleCtrl = TextEditingController(text: item['title']?.toString());
    final imgCtrl = TextEditingController(text: item['imageUrl']?.toString());
    final catCtrl = TextEditingController(text: item['category']?.toString());
    final contentCtrl = TextEditingController(text: item['content']?.toString());
    String currentId = item['id'].toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Edit Berita", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(titleCtrl, "Judul Berita"),
              _buildTextField(imgCtrl, "URL Gambar"),
              _buildTextField(catCtrl, "Kategori"),
              _buildTextField(contentCtrl, "Konten Lengkap", maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("BATAL", style: TextStyle(color: Colors.grey[600]))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
            onPressed: () {
              updateNews(currentId, titleCtrl.text, imgCtrl.text, catCtrl.text, contentCtrl.text);
              Navigator.pop(context);
            },
            child: const Text("UPDATE"),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[700]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("NEWS MANAGEMENT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: accentColor))
        : newsList.isEmpty 
            ? const Center(child: Text("Belum ada berita."))
            : RefreshIndicator(
                onRefresh: fetchNews,
                color: accentColor,
                child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: newsList.length,
                    itemBuilder: (context, index) {
                      final item = newsList[index];
                      String title = item['title']?.toString() ?? "No Title";
                      String category = item['category']?.toString() ?? "Umum";
                      String img = item['imageUrl']?.toString() ?? "";

                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: img.isNotEmpty 
                              ? Image.network(img, width: 70, height: 70, fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(width: 70, color: Colors.grey[300], child: const Icon(Icons.broken_image)))
                              : Container(width: 70, color: Colors.grey[300], child: const Icon(Icons.image)),
                          ),
                          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor)),
                          subtitle: Container(
                            margin: const EdgeInsets.only(top: 8),
                            child: Text(category.toUpperCase(), 
                              style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_note, color: Colors.blue, size: 28),
                                onPressed: () => _showEditDialog(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
                                onPressed: () => _confirmDelete(item['id'].toString(), title),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: primaryColor,
        label: const Text("ADD NEWS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmDelete(String id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Hapus Berita?"),
        content: Text("Yakin ingin menghapus berita:\n'$title'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("BATAL", style: TextStyle(color: Colors.grey[600]))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteNews(id);
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("HAPUS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}