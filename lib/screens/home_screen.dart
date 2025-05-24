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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Search'),
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
                      hintText: 'Search YouTube videos...',
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
                  child: const Text('Go'),
                ),
              ],
            ),
          ),
          if (_videos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Text("Sort by:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text("Views"),
                    selected: _currentSort == 'viewCount',
                    onSelected: (_) => _sort('viewCount'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text("Likes"),
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
                    ? const Center(child: Text('No videos found'))
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
