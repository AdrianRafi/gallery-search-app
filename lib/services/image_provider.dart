import 'package:flutter/material.dart';
import 'api_service.dart';
import '../models/image_model.dart';

class ImageProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ImageModel> _images = [];
  List<ImageModel> _searchResults = [];
  bool _isLoading = false;
  bool _serverConnected = false;
  String _error = '';

  List<ImageModel> get images => _images;
  List<ImageModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get serverConnected => _serverConnected;
  String get error => _error;

  Future<void> checkServer() async {
    _serverConnected = await _apiService.checkHealth();
    notifyListeners();
  }

  Future<void> loadImages() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _images = await _apiService.getImages();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchImages(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _searchResults = await _apiService.searchImages(query);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> analyzeImage(String path) async {
    try {
      return await _apiService.analyzeImage(path);
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
