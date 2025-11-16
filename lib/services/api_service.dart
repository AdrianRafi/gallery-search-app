import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/image_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<ImageModel>> getImages() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/images'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final images = (data['images'] as List)
            .map((i) => ImageModel.fromJson(i))
            .toList();
        return images;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<ImageModel>> searchImages(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?q=$query'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final images = (data['results'] as List)
            .map((i) => ImageModel.fromJson(i))
            .toList();
        return images;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> analyzeImage(String path) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'path': path}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }
}
