import 'package:flutter/material.dart';

class NewsDetailPage extends StatelessWidget {
  final Map<String, dynamic> news;

  const NewsDetailPage({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    // Format tanggal
    final String displayDate = (news['publishedAt'] != null) 
        ? news['publishedAt'].toString().substring(0, 10) 
        : "Baru saja";

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar yang bisa mengecil saat di-scroll
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: news['imageUrl'] != null && news['imageUrl'] != ""
                  ? Image.network(news['imageUrl'], fit: BoxFit.cover)
                  : Container(color: Colors.grey),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori & Tanggal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          news['category']?.toUpperCase() ?? "GENERAL",
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Text(displayDate, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Judul
                  Text(
                    news['title'] ?? "No Title",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const Divider(height: 40),
                  // Isi Berita (Content)
                  Text(
                    news['content'] ?? "Tidak ada isi berita.",
                    style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}