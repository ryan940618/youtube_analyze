class VideoItem {
  final String title;
  final String videoId;
  final int viewCount;
  final int likeCount;
  final String channelTitle;

  VideoItem({
    required this.title,
    required this.videoId,
    required this.viewCount,
    required this.likeCount,
    required this.channelTitle,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      title: json['title'] ?? '',
      videoId: json['videoId'] ?? '',
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      channelTitle: json['channelTitle'] ?? '',
    );
  }
}
