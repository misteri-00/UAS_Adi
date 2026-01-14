import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const VideoPlayerPage({super.key, required this.data});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;
  final Color primaryColor = const Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    
    String videoUrl = widget.data['videoUrl'] ?? "";
    String? videoId = YoutubePlayer.convertUrlToId(videoUrl);

    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? "dQw4w9WgXcQ",
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
  }

  // LOGIKA WAKTU UNTUK PUBLISHEDAT
  String _getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return "Baru saja";
    
    DateTime uploadDate;
    try {
      if (timestamp is DateTime) {
        uploadDate = timestamp;
      } else if (timestamp is String) {
        uploadDate = DateTime.parse(timestamp);
      } else {
        return "Baru saja";
      }
    } catch (e) {
      return "Baru saja";
    }

    final now = DateTime.now();
    final diff = now.difference(uploadDate);

    if (diff.inDays >= 365) {
      return "${(diff.inDays / 365).floor()} tahun lalu";
    } else if (diff.inDays >= 30) {
      return "${(diff.inDays / 30).floor()} bulan lalu";
    } else if (diff.inDays >= 7) {
      return "${(diff.inDays / 7).floor()} minggu lalu";
    } else if (diff.inDays >= 1) {
      return "${diff.inDays} hari lalu";
    } else if (diff.inHours >= 1) {
      return "${diff.inHours} jam lalu";
    } else if (diff.inMinutes >= 1) {
      return "${diff.inMinutes} menit lalu";
    } else {
      return "Baru saja";
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: primaryColor,
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.keyboard_arrow_down, color: primaryColor, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.data['category']?.toUpperCase() ?? "HIGHLIGHTS",
              style: TextStyle(
                color: primaryColor, 
                fontSize: 14, 
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              player,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Judul Video
                            Text(
                              widget.data['title'] ?? "Tanpa Judul",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                height: 1.3
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Info Waktu Saja (Menggunakan publishedAt)
                            Text(
                              _getTimeAgo(widget.data['publishedAt']),
                              style: TextStyle(
                                color: Colors.grey[600], 
                                fontSize: 13,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Divider(thickness: 1, height: 1),
                      
                      // Deskripsi Section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Deskripsi",
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 15,
                                color: Colors.black87
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Text(
                                widget.data['description'] ?? "Tidak ada deskripsi untuk video ini.",
                                style: TextStyle(
                                  color: Colors.grey[800], 
                                  fontSize: 14, 
                                  height: 1.6
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}