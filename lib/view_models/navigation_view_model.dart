import 'package:flutter/material.dart';

import 'package:flutter_marketplace_template/screens/home_screen.dart';
import 'package:flutter_marketplace_template/screens/map_screen.dart';
import 'package:flutter_marketplace_template/screens/post_ad_screen.dart';
import 'package:flutter_marketplace_template/screens/chats_list_screen.dart';
import 'package:flutter_marketplace_template/screens/profile_screen.dart';

class NavigationViewModel extends ChangeNotifier {
  NavigationViewModel({this.selectedIndex = 0});

  int selectedIndex;

  Widget currentScreen = const HomeScreen();

  final List<Widget> screens = const [
    HomeScreen(),       // 0 Accueil
    MapScreen(),        // 1 Rechercher
    PostAdScreen(),     // 2 Déposer
    ChatsListScreen(),  // 3 Messages
    ProfileScreen(),    // 4 Profil
  ];

  void onDestinationSelected(int index) {
    selectedIndex = index;
    currentScreen = screens[index];
    notifyListeners();
  }
}
