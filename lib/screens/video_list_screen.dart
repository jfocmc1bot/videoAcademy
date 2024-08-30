// lib/screens/video_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'video_player_screen.dart';
import '../models/video_model.dart';
import '../services/favorite_service.dart';
import '../services/connectivity_service.dart';
import '../i18n/custom_localizations_delegate.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../services/device_info_services.dart';
import 'widgets/app_bar_widget.dart';
import 'widgets/bottom_navigation_bar_widget.dart';
import 'widgets/video_tile_widget.dart';
import 'widgets/video_search_delegate_widget.dart';

enum ListItemType { header, video }

class ListItem {
  final ListItemType type;
  final String? headerTitle;
  final Video? video;

  ListItem.header(this.headerTitle)
      : type = ListItemType.header,
        video = null;
  ListItem.video(this.video)
      : type = ListItemType.video,
        headerTitle = null;
}

class VideoListScreen extends StatefulWidget {
  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FavoriteService _favoriteService = FavoriteService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final DeviceInfoService _deviceInfoService = DeviceInfoService();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final String _defaultLanguage = 'pt';

  List<Video> _videos = [];
  List<ListItem> _sortedItems = [];
  Set<String> _favoriteVideoIds = {};
  bool _isShowingFavorites = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchTerm = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    print("VideoListScreen initState called");
    _fetchVideos();
    _loadFavoriteVideoIds();
  }

  Future<void> _fetchVideos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print("Attempting to fetch videos from Firestore");
      QuerySnapshot querySnapshot = await _firestore.collection('videos').get();
      print("Received ${querySnapshot.docs.length} documents from Firestore");

      final List<Video> videos = [];
      for (var doc in querySnapshot.docs) {
        try {
          print("Processing document with ID: ${doc.id}");
          final data = doc.data() as Map<String, dynamic>;
          print("Document data: $data");

          // Fetch the 'attributes' subcollection
          QuerySnapshot attributesSnapshot =
              await doc.reference.collection('attributes').get();
          Map<String, dynamic> attributes = {};
          for (var attrDoc in attributesSnapshot.docs) {
            attributes[attrDoc.id] = attrDoc.data();
          }
          print("Attributes data: $attributes");

          videos.add(Video(
            id: doc.id,
            index: data['index'] ?? 0,
            isFavorite: data['isFavorite'] ?? false,
            category: _parseStringMap(attributes['category']),
            session: _parseStringMap(attributes['session']),
            title: _parseStringMap(attributes['title']),
            description: _parseStringMap(attributes['description']),
            youtubeUrl: _parseStringMap(attributes['youtubeUrl']),
            thumbnailUrl: _parseStringMap(attributes['thumbnailUrl']),
          ));
          print("Successfully added video with ID: ${doc.id}");
        } catch (e) {
          print('Error parsing video data for document ${doc.id}: $e');
        }
      }

      setState(() {
        _videos = videos;
        _sortAndGroupVideos();
        _updateFavorites();
        _isLoading = false;
      });
      print('Fetched ${videos.length} videos');
    } catch (error) {
      print('Error fetching videos: $error');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Falha ao carregar vídeos. Tente novamente.';
      });
    }
  }

  Map<String, String> _parseStringMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value.map((key, value) => MapEntry(key, value.toString()));
    }
    return {};
  }

  void _loadFavoriteVideoIds() async {
    final favoriteVideoIds = await _favoriteService.getFavoriteVideoIds();
    setState(() {
      _favoriteVideoIds = favoriteVideoIds.toSet();
      _updateFavorites();
    });
    print("Loaded favorite video IDs: $_favoriteVideoIds");
  }

  void _updateFavorites() {
    _videos.forEach((video) {
      video.isFavorite = _favoriteVideoIds.contains(video.id);
    });
    _sortAndGroupVideos();
  }

  void _toggleFavorite(Video video) async {
    await _favoriteService.toggleFavorite(video.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(video.isFavorite
            ? CustomLocalizations.of(context)!.translate('add_favorites')
            : CustomLocalizations.of(context)!.translate('remove_favorites')),
      ),
    );
    analytics.logEvent(
      name: video.isFavorite ? 'video_favorited' : 'video_unfavorited',
      parameters: {
        'video_id': video.id,
        'video_title': getLocalizedText(video.title),
      },
    );
    _loadFavoriteVideoIds();
  }

  void _onSearchChanged(String searchTerm) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _filterVideos(searchTerm);
    });
  }

  void _filterVideos(String searchTerm) {
    setState(() {
      List<Video> filteredVideos = !_isShowingFavorites
          ? _videos.where((video) {
              final title = getLocalizedText(video.title).toLowerCase();
              final category = getLocalizedText(video.category).toLowerCase();
              final session = getLocalizedText(video.session).toLowerCase();
              final searchLower = searchTerm.toLowerCase();
              return title.contains(searchLower) ||
                  category.contains(searchLower) ||
                  session.contains(searchLower);
            }).toList()
          : _videos.where((video) {
              final title = getLocalizedText(video.title).toLowerCase();
              final category = getLocalizedText(video.category).toLowerCase();
              final session = getLocalizedText(video.session).toLowerCase();
              final searchLower = searchTerm.toLowerCase();
              return video.isFavorite &&
                  (title.contains(searchLower) ||
                      category.contains(searchLower) ||
                      session.contains(searchLower));
            }).toList();

      _sortAndGroupVideos(filteredVideos);
    });
    print("Filtered videos: ${_sortedItems.length}");
  }

  void _sortAndGroupVideos([List<Video>? videosToSort]) {
    final videos = videosToSort ?? _videos;
    videos.sort((a, b) {
      int categoryComparison =
          getLocalizedText(a.category).compareTo(getLocalizedText(b.category));
      if (categoryComparison != 0) return categoryComparison;

      int sessionComparison =
          getLocalizedText(a.session).compareTo(getLocalizedText(b.session));
      if (sessionComparison != 0) return sessionComparison;

      return a.index.compareTo(b.index);
    });

    _sortedItems.clear();
    String? currentCategory;
    String? currentSession;

    for (var video in videos) {
      final category = getLocalizedText(video.category);
      final session = getLocalizedText(video.session);

      if (category != currentCategory) {
        _sortedItems.add(ListItem.header(category));
        currentCategory = category;
        currentSession = null;
      }

      if (session != currentSession) {
        _sortedItems.add(ListItem.header("  $session"));
        currentSession = session;
      }

      _sortedItems.add(ListItem.video(video));
    }

    print('Videos sorted and grouped. Total items: ${_sortedItems.length}');
  }

  String getLocalizedText(Map<String, String> textMap) {
    return textMap[_defaultLanguage] ?? textMap.values.firstOrNull ?? '';
  }

  void _logVideoSelect(Video video) async {
    final Map<String, dynamic> deviceInfo =
        await _deviceInfoService.getDeviceInfo();
    analytics.logEvent(
      name: 'video_selected',
      parameters: {
        'video_id': video.id,
        'video_title': getLocalizedText(video.title),
        'is_connected_to_wifi': deviceInfo['is_connected_to_wifi'] ? '1' : '0',
        'bandwidth': deviceInfo['bandwidth'].toString(),
        'system_version': deviceInfo['device_info']['system_version'],
        'model': deviceInfo['device_info']['model'],
      },
    );
  }

  Future<void> _playVideo(Video video) async {
    _logVideoSelect(video);
    bool isConnected = await _connectivityService.isConnected();
    bool isWifi = await _connectivityService.isConnectedToWiFi();

    print("Is connected: $isConnected");
    print("Is WiFi: $isWifi");

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

  // void _navigateToVideoPlayer(Video video) {
  //   final videoUrl = getLocalizedText(video.youtubeUrl);
  //   if (videoUrl.isNotEmpty) {
  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (context) => VideoPlayerScreen(
  //           videoUrl: videoUrl,
  //           videoId: video.id,
  //           videoTitle: getLocalizedText(video.title),
  //         ),
  //       ),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('URL do vídeo não disponível')),
  //     );
  //   }
  // }

  void _navigateToVideoPlayer(Video video) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoUrl: getLocalizedText(video.youtubeUrl),
          videoId: video.id,
          videoTitle: getLocalizedText(video.title),
        ),
      ),
    );
    // Força uma reconstrução da tela após voltar do player
    setState(() {});
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
            child: Text('OK', style: TextStyle(fontSize: 18)),
            onPressed: () {
              Navigator.of(context).pop();
            },
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
            child: Text(CustomLocalizations.of(context)!.translate('no'),
                style: TextStyle(fontSize: 18)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(CustomLocalizations.of(context)!.translate('yes'),
                style: TextStyle(fontSize: 18)),
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
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vídeos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Implementar busca
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: buildBottomNavigationBar(
        context: context,
        isShowingFavorites: _isShowingFavorites,
        onTap: (index) {
          setState(() {
            _isShowingFavorites = index == 1;
            _filterVideos(_searchTerm);
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _fetchVideos,
              child: Text("Tentar novamente"),
            ),
          ],
        ),
      );
    } else if (_sortedItems.isEmpty) {
      return Center(
          child: Text(_searchTerm.isEmpty
              ? CustomLocalizations.of(context)!.translate('none_found')
              : CustomLocalizations.of(context)!
                  .translate('no_search_results')));
    } else {
      return RefreshIndicator(
        onRefresh: _fetchVideos,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: _sortedItems.length,
          itemBuilder: (context, index) {
            final item = _sortedItems[index];
            if (item.type == ListItemType.header) {
              return Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  item.headerTitle!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue[800],
                  ),
                ),
              );
            } else {
              return buildVideoTile(
                context: context,
                video: item.video!,
                onFavoriteToggle: () => _toggleFavorite(item.video!),
                onPlay: () => _playVideo(item.video!),
                defaultLanguage: _defaultLanguage,
              );
            }
          },
        ),
      );
    }
  }
}
