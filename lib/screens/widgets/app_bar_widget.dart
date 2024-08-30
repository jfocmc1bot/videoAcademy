// lib/screens/widgets/app_bar_widget.dart

import 'package:flutter/material.dart';
import '../../i18n/custom_localizations_delegate.dart';
import 'video_search_delegate_widget.dart';

AppBar buildAppBar({
  required BuildContext context,
  required bool isShowingFavorites,
  required VoidCallback onFavoriteToggle,
  required String searchTerm,
  required Function(String) onSearch,
}) {
  return AppBar(
    title: Text(CustomLocalizations.of(context)!.translate('video_list')),
    actions: [
      IconButton(
        icon: Icon(isShowingFavorites ? Icons.favorite : Icons.favorite_border),
        onPressed: onFavoriteToggle,
        color: isShowingFavorites ? Colors.red : Colors.white,
      ),
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          showSearch(
            context: context,
            delegate: VideoSearchDelegate(videos: [], onSearch: onSearch),
          );
        },
      ),
    ],
  );
}
