import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_marketplace_template/screens/chats_list_screen.dart';
import 'package:flutter_marketplace_template/services/auth_service.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter_marketplace_template/view_models/auth_view_model.dart';
import 'package:flutter_marketplace_template/view_models/navigation_view_model.dart';
import 'package:flutter_marketplace_template/adapters/language_dialog.dart';

/// Custom AppBar widget with configurable options
/// [showTitle] - whether to show the title
/// [showMenu] - whether to show the menu button
/// [showChat] - whether to show the chat button
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showTitle;
  final bool showMenu;
  final bool showChat;

  const CustomAppBar({
    Key? key,
    required this.showTitle,
    required this.showMenu,
    this.showChat = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String selectedLanguage =
        Localizations.localeOf(context).languageCode == 'pl'
            ? 'Polski'
            : 'English';
    final screenWidth = MediaQuery.of(context).size.width;
    final double textScale = screenWidth / 400;
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shadowColor: const Color.fromRGBO(16, 20, 94, 0.25),
      leading:
          !showTitle
              ? IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28 * textScale,
                ),
                onPressed: () {
                  context.read<AuthViewModel>().clearErrors();
                  Navigator.of(context).pop();
                },
              )
              : null,
      title:
          showTitle
              ? Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  'Koteka',
                  style: TextStyle(
                    fontFamily: 'NATS',
                    fontSize: 40 * textScale,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: -1,
                  ),
                ),
              )
              : null,
      actions: [
        if (showMenu)
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'logout':
                    await context.read<IAuthService>().logout();
                    break;
                  case 'map':
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    context.read<NavigationViewModel>().onDestinationSelected(
                      1,
                    );
                    break;
                  case 'profile':
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    context.read<NavigationViewModel>().onDestinationSelected(
                      2,
                    );
                    break;
                  case 'language':
                    showLanguageDialog(context, selectedLanguage);
                    break;
                }
              },
              color: Theme.of(context).colorScheme.surface,
              elevation: 8,
              shadowColor: const Color.fromRGBO(16, 20, 94, 0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              icon: Icon(
                Icons.menu,
                color: Theme.of(context).colorScheme.primary,
                size: 30 * textScale,
              ),
              itemBuilder: (BuildContext context) => _menuItems(context),
            ),
          ),
        if (showChat)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Icon(
                Icons.chat_outlined,
                color: const Color.fromRGBO(16, 20, 94, 1),
                size: 28 * textScale,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ChatsListScreen()),
                );
              },
            ),
          ),
      ],
    );
  }

  List<PopupMenuItem<String>> _menuItems(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double textScale = screenWidth / 400;
    final textStyle = TextStyle(
      fontFamily: 'Mplus1p',
      fontSize: 16 * textScale,
      letterSpacing: -1,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.onSecondary,
    );

    PopupMenuItem<String> buildItem(String value, IconData icon, String label) {
      return PopupMenuItem(
        value: value,
        child: Center(
          child: Container(
            width: 131,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 24 * textScale,
                ),
                const SizedBox(width: 5),
                Text(label, style: textStyle),
              ],
            ),
          ),
        ),
      );
    }

    return [
      buildItem(
        'language',
        Icons.language_outlined,
        AppLocalizations.of(context)!.language,
      ),
      buildItem('map', Icons.map_outlined, AppLocalizations.of(context)!.map),
      buildItem(
        'profile',
        Icons.account_circle_outlined,
        AppLocalizations.of(context)!.account,
      ),
      buildItem('logout', Icons.logout, AppLocalizations.of(context)!.log_out),
    ];
  }

  @override
  Size get preferredSize => Size.fromHeight(55); // możesz dopasować wysokość
}
