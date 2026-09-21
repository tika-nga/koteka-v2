import 'package:flutter/material.dart';

import 'package:flutter_marketplace_template/screens/home_screen.dart';
import 'package:flutter_marketplace_template/screens/post_ad_screen.dart';
import 'package:flutter_marketplace_template/screens/chats_list_screen.dart';
import 'package:flutter_marketplace_template/screens/profile_screen.dart';

class NavigationViewModel extends ChangeNotifier {
  NavigationViewModel({
    this.selectedIndex = 0,
  });

  int selectedIndex;

  Widget currentScreen = const HomeScreen();

  final List<Widget> screens = const [
    HomeScreen(),       // 0 Accueil
    PostAdScreen(),     // 1 Déposer
    ChatsListScreen(),  // 2 Messages
    ProfileScreen(),    // 3 Profil
  ];

  void onDestinationSelected(int index) {
    if (index < 0 || index >= screens.length) {
      return;
    }

    selectedIndex = index;
    currentScreen = screens[index];
    notifyListeners();
  }
}
