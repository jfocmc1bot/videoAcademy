// lib/screens/video_player_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../services/device_info_services.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String videoId;
  final String videoTitle;

  VideoPlayerScreen({
    required this.videoUrl,
    required this.videoId,
    required this.videoTitle,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  bool _isPlayerReady = false;
  DateTime? _playStartTime;
  final DeviceInfoService _deviceInfoService = DeviceInfoService();

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      )..addListener(_listener);
    }

    _playStartTime = DateTime.now();
    _logVideoPlay();
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
  }

  void _logVideoPlay() async {
    final Map<String, dynamic> deviceInfo =
        await _deviceInfoService.getDeviceInfo();
    analytics.logEvent(
      name: 'video_played',
      parameters: {
        'video_id': widget.videoId,
        'video_title': widget.videoTitle,
        'start_time': _playStartTime?.toIso8601String() ?? '',
        'is_connected_to_wifi': deviceInfo['is_connected_to_wifi'] ? '1' : '0',
        'bandwidth': deviceInfo['bandwidth'],
        'system_version': deviceInfo['device_info']['system_version'],
        'model': deviceInfo['device_info']['model'],
      },
    );
  }

  void _logVideoEnd() async {
    if (_playStartTime != null) {
      final playEndTime = DateTime.now();
      final playDuration = playEndTime.difference(_playStartTime!).inSeconds;
      final Map<String, dynamic> deviceInfo =
          await _deviceInfoService.getDeviceInfo();
      analytics.logEvent(
        name: 'video_ended',
        parameters: {
          'video_id': widget.videoId,
          'video_title': widget.videoTitle,
          'start_time': _playStartTime?.toIso8601String() ?? '',
          'end_time': playEndTime.toIso8601String(),
          'play_duration': playDuration,
          'is_connected_to_wifi': deviceInfo['is_connected_to_wifi'],
          'bandwidth': deviceInfo['bandwidth'],
          'system_version': deviceInfo['device_info']['system_version'],
          'model': deviceInfo['device_info']['model'],
        },
      );
    }
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    _logVideoEnd();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (metaData) {
          _logVideoEnd();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reprodução concluída!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
      builder: (context, player) => Scaffold(
        appBar: AppBar(
          title: Text(widget.videoTitle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Colors.black,
              child: Center(child: player),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                title: Text(widget.videoTitle),
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
