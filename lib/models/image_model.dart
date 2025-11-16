class ImageModel {
  final String path;
  final String name;
  final int size;
  final DateTime modified;

  ImageModel({
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      path: json['path'] ?? '',
      name: json['name'] ?? '',
      size: json['size'] ?? 0,
      modified: DateTime.parse(json['modified'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'name': name,
      'size': size,
      'modified': modified.toIso8601String(),
    };
  }
}

class SearchResult {
  final List<ImageModel> images;
  final String query;
  final int count;

  SearchResult({
    required this.images,
    required this.query,
    required this.count,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    var imageList = (json['images'] as List?)
        ?.map((i) => ImageModel.fromJson(i))
        .toList() ?? [];
    return SearchResult(
      images: imageList,
      query: json['query'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}
