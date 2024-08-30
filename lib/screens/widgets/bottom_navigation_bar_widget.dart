// lib/screens/widgets/bottom_navigation_bar_widget.dart

import 'package:flutter/material.dart';
import '../../i18n/custom_localizations_delegate.dart';

BottomNavigationBar buildBottomNavigationBar({
  required BuildContext context,
  required bool isShowingFavorites,
  required ValueChanged<int> onTap,
}) {
  return BottomNavigationBar(
    items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: const Icon(Icons.home),
        label: CustomLocalizations.of(context)!.translate('home'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.favorite),
        label: CustomLocalizations.of(context)!.translate('favorites'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.account_circle),
        label: CustomLocalizations.of(context)!.translate('profile'),
      ),
    ],
    currentIndex: isShowingFavorites ? 1 : 0,
    selectedItemColor: Colors.blueAccent,
    selectedLabelStyle: const TextStyle(fontSize: 18),
    unselectedLabelStyle: const TextStyle(fontSize: 18),
    onTap: onTap,
  );
}
