import 'package:flutter/material.dart';
import '../models/video_item.dart';
import '../services/api.dart';
import '../widgets/video_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<VideoItem> _videos = [];
  bool _isLoading = false;
  String _currentSort = '';

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final videos = await ApiService.searchVideos(query);
      setState(() {
        _videos = videos;
        _currentSort = '';
      });
    } catch (e) {
      print('Search error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sort(String by) async {
    if (_videos.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final sorted = await ApiService.sortVideos(by);
      setState(() {
        _videos = sorted;
        _currentSort = by;
      });
    } catch (e) {
      print('Sort error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generate() async {
    setState(() => _isLoading = true);

    try {
      final videos = await ApiService.getGenerated();
      setState(() {
        _videos = videos;
        _currentSort = '';
      });
    } catch (e) {
      print('Search error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Youtube 結果搜尋與排序',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: '搜尋...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    '搜尋',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _generate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              '產生隨機結果',
              style: TextStyle(color: Colors.white),
            ),
          ),
          if (_videos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Text("排序:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text("觀看次數"),
                    selected: _currentSort == 'viewCount',
                    onSelected: (_) => _sort('viewCount'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text("按讚數"),
                    selected: _currentSort == 'likeCount',
                    onSelected: (_) => _sort('likeCount'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _videos.isEmpty
                    ? const Center(child: Text('無任何影片'))
                    : ListView.builder(
                        itemCount: _videos.length,
                        itemBuilder: (context, index) {
                          return VideoCard(video: _videos[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
