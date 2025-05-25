import 'package:flutter/material.dart';
import '../models/video_item.dart';

class VideoCard extends StatelessWidget {
  final VideoItem video;

  const VideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.network(
              "https://img.youtube.com/vi/${video.videoId}/mqdefault.jpg",
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image,
                    size: 100, color: Colors.grey);
              },
            ),
            const SizedBox(width: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text("ID: ${video.videoId}",
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 10),
                Text("發布者: ${video.channelTitle}",
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text("觀看次數: ${video.viewCount}",
                    style: const TextStyle(fontSize: 18)),
                Text("按讚數: ${video.likeCount}",
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
