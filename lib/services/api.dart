import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_item.dart';

class ApiService {
  static String _baseUrl = 'http://127.0.0.1:5000';

  static void setBaseUrl(String url) {
    _baseUrl = url;
  }

  static String getBaseUrl() => _baseUrl;

  static Future<List<VideoItem>> searchVideos(String query) async {
    final uri = Uri.parse('$_baseUrl/search?query=$query');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => VideoItem.fromJson(json)).toList();
    } else {
      throw Exception('API資料載入失敗: ${response.statusCode}');
    }
  }

  static Future<List<VideoItem>> getGenerated() async {
    final uri = Uri.parse('$_baseUrl/generate');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => VideoItem.fromJson(json)).toList();
    } else {
      throw Exception('API資料載入失敗: ${response.statusCode}');
    }
  }

  static Future<List<VideoItem>> sortVideos(String by) async {
    final uri = Uri.parse('$_baseUrl/sort?by=$by');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => VideoItem.fromJson(json)).toList();
    } else {
      throw Exception('API資料載入失敗: ${response.statusCode}');
    }
  }

  static Future<VideoItem?> getNth(int rank) async {
    final uri = Uri.parse('$_baseUrl/nth?rank=$rank');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return VideoItem.fromJson(data);
    } else {
      return null;
    }
  }
}
