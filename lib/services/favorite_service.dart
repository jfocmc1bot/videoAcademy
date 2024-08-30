// lib/services/favorite_service.dart

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> clearNonExistentFavorites() async {
    final favoriteVideos = await _getFavoriteVideosFromPref();
    final firebaseVideos =
        await FirebaseFirestore.instance.collection('videos').get();

    final existingVideoIds = firebaseVideos.docs.map((doc) => doc.id).toSet();
    final nonExistentVideos =
        favoriteVideos.where((id) => !existingVideoIds.contains(id)).toList();

    if (nonExistentVideos.isNotEmpty) {
      final updatedFavoriteVideos =
          favoriteVideos.toSet().difference(nonExistentVideos.toSet()).toList();
      await _saveFavoriteVideosToPref(updatedFavoriteVideos);
    }
  }
}
