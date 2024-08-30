// lib/services/favorite_service.dart

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_model.dart';

class FavoriteService {
  static const String _favoriteVideosKey = 'favoriteVideos';

  Future<List<String>> _getFavoriteVideosFromPref() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteVideos = prefs.getStringList(_favoriteVideosKey) ?? [];
    return favoriteVideos;
  }

  Future<void> _saveFavoriteVideosToPref(List<String> favoriteVideos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteVideosKey, favoriteVideos);
  }

  Future<List<String>> getFavoriteVideoIds() async {
    return await _getFavoriteVideosFromPref();
  }

  Future<void> toggleFavorite(String videoId) async {
    final favoriteVideos = await _getFavoriteVideosFromPref();
    if (favoriteVideos.contains(videoId)) {
      favoriteVideos.remove(videoId);
    } else {
      favoriteVideos.add(videoId);
    }
    await _saveFavoriteVideosToPref(favoriteVideos);
  }

  Future<void> clearFavorites() async {
    await _saveFavoriteVideosToPref([]);
  }
}
