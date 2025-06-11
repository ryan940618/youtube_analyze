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
  String _currentFilter = '';
  String _currentArg = '';

  final TextEditingController _rankController = TextEditingController();
  int rank = 1;
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

  Future<void> _filter(String filter, String by, [String arg = '']) async {
    if (_videos.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final sorted = await ApiService.sortVideos(filter, by, arg);
      setState(() {
        _videos = sorted;
        _currentFilter = filter;
        _currentSort = by;

        if (filter != "nth" && filter != "count_prefix") {
          _currentArg = arg;
        } else {
          _currentArg = '';
        }
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
          if (_videos.isNotEmpty && !_isLoading)
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
                    onSelected: (_) =>
                        _filter('sort', 'viewCount', _currentArg),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text("按讚數"),
                    selected: _currentSort == 'likeCount',
                    onSelected: (_) =>
                        _filter('sort', 'likeCount', _currentArg),
                  ),
                  if (_currentSort != '') ...[
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("由多到少"),
                      selected: _currentArg == '',
                      onSelected: (_) => _filter('sort', _currentSort),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("由少到多"),
                      selected: _currentArg == 'order=df',
                      onSelected: (_) =>
                          _filter('sort', _currentSort, 'order=df'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("特定排名"),
                      selected: _currentFilter == 'nth',
                      onSelected: (_) =>
                          _filter('nth', _currentSort, 'rank=$rank'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("特定前綴"),
                      selected: _currentFilter == 'prefix',
                      onSelected: (_) =>
                          _filter('prefix', _currentSort, 'prefix=$rank'),
                    ),
                    SizedBox(
                      width: 60,
                      height: 32,
                      child: TextField(
                        controller: _rankController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '參數',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            rank = int.tryParse(value) ?? 1;
                          });
                        },
                      ),
                    ),
                  ],
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
