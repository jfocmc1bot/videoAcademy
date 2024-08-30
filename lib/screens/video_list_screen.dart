// lib/screens/video_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'video_player_screen.dart';
import '../models/video_model.dart';
import '../services/favorite_service.dart';
import '../services/connectivity_service.dart';
import '../i18n/custom_localizations_delegate.dart';
import 'widgets/app_bar_widget.dart';
import 'widgets/bottom_navigation_bar_widget.dart';
import 'widgets/video_tile_widget.dart';

class VideoListScreen extends StatefulWidget {
  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FavoriteService _favoriteService = FavoriteService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final String _defaultLanguage = 'pt';

  List<Video> _videos = [];
  List<Video> _filteredVideos = [];
  Set<String> _favoriteVideoIds = {};
  bool _isShowingFavorites = false;
  bool _isLoading = false;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _fetchVideos();
    _loadFavoriteVideoIds();
  }

  Future<void> _fetchVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await _firestore.collection('videos').get();

      final List<Video> videos = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        QuerySnapshot attributesSnapshot =
            await doc.reference.collection('attributes').get();
        Map<String, dynamic> attributes = {};
        for (var attrDoc in attributesSnapshot.docs) {
          attributes[attrDoc.id] = attrDoc.data();
        }
        videos.add(Video(
          id: doc.id,
          index: data['index'] ?? 0,
          category: _parseStringMap(attributes['category']),
          session: _parseStringMap(attributes['session']),
          title: _parseStringMap(attributes['title']),
          description: _parseStringMap(attributes['description']),
          youtubeUrl: _parseStringMap(attributes['youtubeUrl']),
          thumbnailUrl: _parseStringMap(attributes['thumbnailUrl']),
        ));
      }

      setState(() {
        _videos = videos;
        _filterFavoritesAndSearch();
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Falha ao carregar vídeos. Tente novamente.')));
    }
  }

  Map<String, String> _parseStringMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value.map((key, value) => MapEntry(key, value.toString()));
    }
    return {};
  }

  Future<void> _loadFavoriteVideoIds() async {
    final favoriteVideoIds = await _favoriteService.getFavoriteVideoIds();
    setState(() {
      _favoriteVideoIds = favoriteVideoIds;
      _updateFavorites();
    });
  }

  void _updateFavorites() {
    setState(() {
      _videos.forEach((video) {
        video.isFavorite = _favoriteVideoIds.contains(video.id);
      });
      _filterFavoritesAndSearch();
    });
  }

  void _toggleFavorite(Video video) async {
    await _favoriteService.toggleFavorite(video.id);

    setState(() {
      if (video.isFavorite) {
        video.isFavorite = false;
        _favoriteVideoIds.remove(video.id);
      } else {
        video.isFavorite = true;
        _favoriteVideoIds.add(video.id);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(video.isFavorite
            ? CustomLocalizations.of(context)!.translate('add_favorites')
            : CustomLocalizations.of(context)!.translate('remove_favorites')),
      ),
    );
  }

  void _onSearch(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm;
      _filterFavoritesAndSearch();
    });
  }

  void _filterFavoritesAndSearch() {
    _filteredVideos = _videos.where((video) {
      final matchesFavorite = !_isShowingFavorites || video.isFavorite;
      final matchesSearch = video.title[_defaultLanguage]
              ?.toLowerCase()
              .contains(_searchTerm.toLowerCase()) ??
          false;
      return matchesFavorite && matchesSearch;
    }).toList();
  }

  Future<void> _playVideo(Video video) async {
    bool isConnected = await _connectivityService.isConnected();
    bool isWifi = await _connectivityService.isConnectedToWiFi();

    if (isConnected) {
      if (isWifi) {
        _navigateToVideoPlayer(video);
      } else {
        _showMobileDataWarning(video);
      }
    } else {
      _showNoInternetAlert();
    }
  }

  void _navigateToVideoPlayer(Video video) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoUrl: video.youtubeUrl[_defaultLanguage] ?? '',
          videoId: video.id,
          videoTitle: video.title[_defaultLanguage] ?? '',
        ),
      ),
    );
  }

  void _showNoInternetAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(CustomLocalizations.of(context)!.translate('no_connection')),
        content:
            Text(CustomLocalizations.of(context)!.translate('no_wifi_desc')),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showMobileDataWarning(Video video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(CustomLocalizations.of(context)!.translate('no_wifi')),
        content:
            Text(CustomLocalizations.of(context)!.translate('no_wifi_desc')),
        actions: [
          TextButton(
            child: Text(CustomLocalizations.of(context)!.translate('no')),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text(CustomLocalizations.of(context)!.translate('yes')),
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToVideoPlayer(video);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;
    final appBar = buildAppBar(
      context: context,
      isShowingFavorites: _isShowingFavorites,
      onFavoriteToggle: () {
        setState(() {
          _isShowingFavorites = !_isShowingFavorites;
          _filterFavoritesAndSearch();
        });
      },
      searchTerm: _searchTerm,
      onSearch: _onSearch,
    );

    return Scaffold(
      appBar: appBar,
      body: Container(
        height: height - appBar.preferredSize.height,
        width: width,
        child: Column(
          children: [
            if (_isLoading)
              Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_filteredVideos.isEmpty)
              Expanded(
                  child: Center(
                      child: Text(CustomLocalizations.of(context)!
                          .translate('none_found'))))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredVideos.length,
                  itemBuilder: (context, index) {
                    final video = _filteredVideos[index];
                    return buildVideoTile(
                      context: context,
                      video: video,
                      onFavoriteToggle: () => _toggleFavorite(video),
                      onPlay: () => _playVideo(video),
                      defaultLanguage: _defaultLanguage,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context: context,
        isShowingFavorites: _isShowingFavorites,
        onTap: (index) {
          setState(() {
            _isShowingFavorites = index == 1;
            _filterFavoritesAndSearch();
          });
        },
      ),
    );
  }
}
