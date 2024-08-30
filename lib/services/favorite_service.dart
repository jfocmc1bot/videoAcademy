// lib/services/favorite_service.dart

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _favoriteVideosKey = 'favoriteVideos';

  Future<List<String>> _getFavoriteVideosFromPref() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoriteVideosKey) ?? [];
  }

  Future<void> _saveFavoriteVideosToPref(List<String> favoriteVideos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteVideosKey, favoriteVideos);
  }

  Future<Set<String>> getFavoriteVideoIds() async {
    final favoriteVideos = await _getFavoriteVideosFromPref();
    return favoriteVideos.toSet();
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
}
