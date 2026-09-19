import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_marketplace_template/view_models/auth_view_model.dart';

/// Barre supérieure principale de Koteka.
///
/// - Sur les écrans principaux : affiche uniquement "Koteka".
/// - Sur les pages secondaires : affiche une flèche retour.
/// - Pas de menu hamburger.
/// - Pas d'icône Messages : les messages sont accessibles
///   depuis la navigation inférieure.
class CustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool showTitle;

  // Conservés pour éviter de casser les écrans
  // qui utilisent encore les anciens paramètres.
  final bool showMenu;
  final bool showChat;

  const CustomAppBar({
    super.key,
    required this.showTitle,
    this.showMenu = false,
    this.showChat = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width;

    final double textScale =
        screenWidth / 400;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor:
          Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shadowColor:
          const Color.fromRGBO(
        16,
        20,
        94,
        0.18,
      ),

      leading: showTitle
          ? null
          : IconButton(
              tooltip: 'Retour',
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
                size: 27 * textScale,
              ),
              onPressed: () {
                try {
                  context
                      .read<AuthViewModel>()
                      .clearErrors();
                } catch (_) {
                  // Certains écrans peuvent ne pas
                  // utiliser AuthViewModel.
                }

                Navigator.of(context).maybePop();
              },
            ),

      title: showTitle
          ? Padding(
              padding:
                  const EdgeInsets.only(
                left: 8,
              ),
              child: Text(
                'Koteka',
                style: TextStyle(
                  fontFamily: 'NATS',
                  fontSize:
                      40 * textScale,
                  height: 1,
                  color:
                      Theme.of(context)
                          .colorScheme
                          .primary,
                  letterSpacing: -1,
                ),
              ),
            )
          : null,

      centerTitle: false,

      // Plus de hamburger ni d'icône chat.
      actions: const [],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(55);
}
