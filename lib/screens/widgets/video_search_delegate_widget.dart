import 'package:flutter/material.dart';
import '../../models/video_model.dart';
import '../../i18n/custom_localizations_delegate.dart';

class VideoSearchDelegate extends SearchDelegate {
  final List<Video> videos;
  final Function(String) onSearch;
  final String defaultLanguage;

  VideoSearchDelegate({
    required this.videos,
    required this.onSearch,
    this.defaultLanguage = 'pt',
  });

  String getLocalizedText(Map<String, String> textMap) {
    return textMap[defaultLanguage] ?? textMap.values.firstOrNull ?? '';
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = videos.where((video) {
      final title = getLocalizedText(video.title).toLowerCase();
      final category = getLocalizedText(video.category).toLowerCase();
      final session = getLocalizedText(video.session).toLowerCase();
      final queryLower = query.toLowerCase();
      return title.contains(queryLower) ||
          category.contains(queryLower) ||
          session.contains(queryLower);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final video = suggestions[index];
        return ListTile(
          leading: Image.network(getLocalizedText(video.thumbnailUrl),
              width: 100, fit: BoxFit.cover),
          title: Text(getLocalizedText(video.title),
              style: TextStyle(fontSize: 20)),
          subtitle: Text(getLocalizedText(video.description)),
          onTap: () {
            query = getLocalizedText(video.title);
            onSearch(query);
            showResults(context);
          },
        );
      },
    );
  }
}
