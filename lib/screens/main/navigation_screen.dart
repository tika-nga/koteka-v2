import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_marketplace_template/view_models/navigation_view_model.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<NavigationViewModel>();

    return Scaffold(
      body: navigation.currentScreen,

      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: navigation.selectedIndex,

        onDestinationSelected: (index) {
          context
              .read<NavigationViewModel>()
              .onDestinationSelected(index);
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),

          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Rechercher',
          ),

          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Déposer',
          ),

          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}              ) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 40,
                  );
                }
                return IconThemeData(
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                );
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(
                    color: Colors.transparent,
                    decorationColor: Theme.of(context).colorScheme.tertiary,
                    decoration: TextDecoration.underline,
                    decorationThickness: 55,
                    fontSize: 1,
                  );
                }
                return const TextStyle(
                  color: Colors.transparent,
                  decorationColor: Colors.transparent,
                  fontSize: 2,
                );
              }),
            ),
            child: Builder(
              builder: (context) {
                return NavigationBar(
                  height: 75,
                  elevation: 4.0,
                  backgroundColor: null,
                  selectedIndex:
                      context.watch<NavigationViewModel>().selectedIndex,
                  onDestinationSelected: (index) {
                    context.read<NavigationViewModel>().onDestinationSelected(
                      index,
                    );
                  },
                  destinations: _destinations(avatarUrl),
                );
              },
            ),
          ),
          Positioned(
            bottom: 30,
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 4,
                ),
              ),
              child: SizedBox(
                width: 80,
                height: 80,
                child: FloatingActionButton(
                  heroTag: 'fab_bottom_bar',
                  backgroundColor:
                      context.watch<NavigationViewModel>().selectedIndex == 1
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.secondary,
                  shape: const CircleBorder(),
                  elevation: 0,
                  onPressed: () {
                    context.read<NavigationViewModel>().onDestinationSelected(
                      1,
                    );
                  },
                  child: Icon(
                    Icons.map_outlined,
                    color: Theme.of(context).colorScheme.onSecondary,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Container _underline(Color color) => Container(
    width: 28,
    height: 3,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(2),
    ),
  );

  // Destinations
  static List<NavigationDestination> _destinations(String? avatarUrl) {
    return <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Symbols.home),
        label: '',
        selectedIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.home),
            const SizedBox(height: 6),
            _underline(const Color.fromRGBO(0, 102, 255, 1)),
          ],
        ),
      ),
      NavigationDestination(icon: SizedBox.shrink(), label: ''),

      NavigationDestination(
        icon: ProfileAvatarWidget(
          avatarUrl: avatarUrl,
          selected: false,
          radius: 20,
        ),
        label: '',
        selectedIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileAvatarWidget(
              avatarUrl: avatarUrl,
              selected: true,
              radius: 20,
            ),
            const SizedBox(height: 6),
            _underline(const Color.fromRGBO(0, 102, 255, 1)),
          ],
        ),
      ),
    ];
  }
}
