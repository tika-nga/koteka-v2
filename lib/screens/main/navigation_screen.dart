import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_marketplace_template/view_models/navigation_view_model.dart';
import 'package:flutter_marketplace_template/view_models/chats_list_view_model.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() =>
      _NavigationScreenState();
}

class _NavigationScreenState
    extends State<NavigationScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<ChatsListViewModel>()
          .refreshUnreadMessagesCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigation =
        context.watch<NavigationViewModel>();

    final chatsList =
        context.watch<ChatsListViewModel>();

    final unreadCount =
        chatsList.unreadMessagesCount;

    return Scaffold(
      body: navigation.currentScreen,
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex:
            navigation.selectedIndex,
        onDestinationSelected: (index) {
          context
              .read<NavigationViewModel>()
              .onDestinationSelected(index);

          // Messages = index 2.
          // On actualise le compteur
          // lorsque l'utilisateur ouvre
          // la partie Messages.
          if (index == 2) {
            context
                .read<ChatsListViewModel>()
                .refreshUnreadMessagesCount();
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Accueil',
          ),

          const NavigationDestination(
            icon: Icon(
              Icons.add_circle_outline,
            ),
            selectedIcon: Icon(
              Icons.add_circle,
            ),
            label: 'Déposer',
          ),

          NavigationDestination(
            icon: _messagesIcon(
              icon:
                  Icons.chat_bubble_outline,
              unreadCount: unreadCount,
            ),
            selectedIcon: _messagesIcon(
              icon:
                  Icons.chat_bubble,
              unreadCount: unreadCount,
            ),
            label: 'Messages',
          ),

          const NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _messagesIcon({
    required IconData icon,
    required int unreadCount,
  }) {
    if (unreadCount <= 0) {
      return Icon(icon);
    }

    final label =
        unreadCount > 99
            ? '99+'
            : unreadCount.toString();

    return Badge(
      label: Text(label),
      child: Icon(icon),
    );
  }
}
