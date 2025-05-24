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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              video.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Channel: ${video.channelTitle}",
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text("Views: ${video.viewCount}",
                style: const TextStyle(fontSize: 14)),
            Text("Likes: ${video.likeCount}",
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
