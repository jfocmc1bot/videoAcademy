// lib/models/video_model.dart

class Video {
  final String id;
  final int index;
  bool isFavorite;
  final Map<String, String> category;
  final Map<String, String> session;
  final Map<String, String> title;
  final Map<String, String> description;
  final Map<String, String> youtubeUrl;
  final Map<String, String> thumbnailUrl;

  Video({
    required this.id,
    required this.index,
    this.isFavorite = false,
    required this.category,
    required this.session,
    required this.title,
    required this.description,
    required this.youtubeUrl,
    required this.thumbnailUrl,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    print("Creating Video from JSON: $json");
    final attributes = json['attributes'] as Map<String, dynamic>? ?? {};
    return Video(
      id: json['id'] ?? '',
      index: json['index'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      category: _parseStringMap(attributes['category']),
      session: _parseStringMap(attributes['session']),
      title: _parseStringMap(attributes['title']),
      description: _parseStringMap(attributes['description']),
      youtubeUrl: _parseStringMap(attributes['youtubeUrl']),
      thumbnailUrl: _parseStringMap(attributes['thumbnailUrl']),
    );
  }

  static Map<String, String> _parseStringMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value.map((key, value) => MapEntry(key, value.toString()));
    }
    return {};
  }
}
