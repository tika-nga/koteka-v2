import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_marketplace_template/functions.dart';
import 'package:flutter_marketplace_template/models/place.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter_marketplace_template/models/category_tags_enums.dart';
import 'package:provider/provider.dart';
import 'package:flutter_marketplace_template/screens/chat_screen.dart';
import 'package:flutter_marketplace_template/services/chat_service.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:flutter_marketplace_template/services/user_service.dart';
import 'package:flutter_marketplace_template/view_models/favorite_places_view_model.dart';
import 'package:flutter_marketplace_template/adapters/app_bar.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Screen displaying detailed information about a place
class PlaceScreen extends StatelessWidget {
  final Place place;

  const PlaceScreen({super.key, required this.place});

  Widget _textWithIcon({
  required BuildContext context,
  required Object icon,
  required String title,
  VoidCallback? onTap,
  bool isActive = false,
}) {
  final Widget iconWidget;

  if (icon is FaIconData) {
    iconWidget = FaIcon(
      icon,
      color: Theme.of(context).colorScheme.primary,
      size: 24,
    );
  } else if (icon is IconData) {
    iconWidget = Icon(
      icon,
      color: Theme.of(context).colorScheme.primary,
      size: 24,
    );
  } else {
    iconWidget = const SizedBox.shrink();
  }

  return InkWell(
    onTap: isActive ? (onTap ?? () {}) : () {},
    child: Padding(
      padding: const EdgeInsets.only(
        left: 10,
        top: 10,
        bottom: 10,
      ),
      child: Row(
        children: [
          iconWidget,
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Mplus1p',
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    ),
  );
}
  /// Opens Google Maps with a pre-filled search query
  Future<void> openInGoogleMaps({required String query}) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}';
    await runUrl(url);
  }

  /// Copies phone number to clipboard
  void copyToClipboard(BuildContext context, String number) {
    Clipboard.setData(ClipboardData(text: number)).then((_) {
      //showSuccessSnackbar(context, "Number copied to clipboard");
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = screenWidth / 400;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(showTitle: false, showMenu: true),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 230,
            collapsedHeight: 75,
            backgroundColor: Color.fromRGBO(16, 20, 94, 1),
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final double percent =
                    (constraints.maxHeight - kToolbarHeight) /
                    (260 - kToolbarHeight);

                return FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, top: 15),
                  title: Opacity(
                    opacity: percent == 0 ? 0 : 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: (percent > 0.1 ? 0 : 240) * textScale,
                              height: 32,
                              child: Text(
                                place.name,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                  fontFamily: 'Mplus1p',
                                  fontSize: 24 * textScale,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: (percent > 0.1 ? 0 : 240) * textScale,
                              height: 18,
                              child: Text(
                                place.address.split(',').first,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                  fontFamily: 'Mplus1p',
                                  fontSize: 12 * textScale,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: Opacity(
                            opacity: percent > 0.10 ? 0 : 1,
                            child: Consumer<FavoritePlacesViewModel>(
                              builder: (context, favVM, _) {
                                final isFav = favVM.isFavorite(place.id);
                                return Row(
                                  children: [
                                    FloatingActionButton(
                                      heroTag: 'love_tag_home',
                                      onPressed: () {
                                        favVM.toggleFavorite(
                                          place.id,
                                          place: place,
                                        );
                                      },
                                      shape: const CircleBorder(),
                                      mini: true,
                                      backgroundColor:
                                          isFav
                                              ? Color.fromRGBO(0, 102, 255, 1)
                                              : Theme.of(
                                                context,
                                              ).colorScheme.onSecondary,
                                      child:
                                          isFav
                                              ? Icon(
                                                Icons.favorite,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSecondary,
                                              )
                                              : Icon(
                                                Icons.favorite_outline,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
                                              ),
                                    ),
                                    FloatingActionButton(
                                      heroTag: 'chat_tag_home',
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    PlaceScreen(place: place),
                                          ),
                                        );
                                      },
                                      shape: const CircleBorder(),
                                      mini: true,
                                      backgroundColor: Color.fromRGBO(
                                        0,
                                        102,
                                        255,
                                        1,
                                      ),
                                      child: Icon(
                                        Icons.chat,
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Picture
                      Image.network(
                        place.profilePicture,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 48),
                            ),
                      ),

                      // Gradient
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 150,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Color.fromRGBO(16, 20, 94, 1),
                                // Color.fromRGBO(16, 20, 94, 0),
                                Color.fromRGBO(16, 20, 94, 0.95),
                                Color.fromRGBO(16, 20, 94, 0.8),
                                Color.fromRGBO(16, 20, 94, 0.4),
                                Color.fromRGBO(16, 20, 94, 0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Text ON BACKGROUND
                      Positioned(
                        left: 20,
                        bottom: 10,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 240 * textScale,
                                  height: 35,
                                  child: Text(
                                    place.name,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style: TextStyle(
                                      fontFamily: 'Mplus1p',
                                      fontSize:
                                          24 *
                                          textScale, //screenWidth < 300 ? 15 : 18,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSecondary,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 240 * textScale,
                                  height: 19,
                                  child: Text(
                                    place.address.split(',').first,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style: TextStyle(
                                      fontFamily: 'Mplus1p',
                                      fontSize: 12 * textScale,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Consumer<FavoritePlacesViewModel>(
                              builder: (context, favVM, _) {
                                final isFav = favVM.isFavorite(place.id);
                                return Row(
                                  children: [
                                    FloatingActionButton(
                                      heroTag: null,
                                      onPressed: () {
                                        favVM.toggleFavorite(
                                          place.id,
                                          place: place,
                                        );
                                      },
                                      shape: const CircleBorder(),
                                      mini: true,
                                      backgroundColor:
                                          isFav
                                              ? Color.fromRGBO(0, 102, 255, 1)
                                              : Theme.of(
                                                context,
                                              ).colorScheme.onSecondary,
                                      child:
                                          isFav
                                              ? Icon(
                                                Icons.favorite,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onSecondary,
                                              )
                                              : Icon(
                                                Icons.favorite_outline,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
                                              ),
                                    ),
                                    FloatingActionButton(
                                      heroTag: 'chat_tag_home_2',
                                      onPressed: () async {
                                        String? userId =
                                            context
                                                .read<IUserService>()
                                                .getCurrentUserId();
                                        if (userId == null) {
                                          return;
                                        }
                                        String chatId = '';
                                        final response = await context
                                            .read<IChatService>()
                                            .getOrCreateChat(
                                              receiverId: place.id,
                                              placeName: place.name,
                                            );
                                        if (response
                                            is FetchOneSuccess<String>) {
                                          chatId = response.item;
                                        } else {
                                          return;
                                        }
                                        if (chatId.isEmpty) {
                                          return;
                                        }
                                        DateTime? chatDeletedAt;
                                        final dateResponse = await context
                                            .read<IChatService>()
                                            .getChatDeletedAt(chatId: chatId);
                                        if (dateResponse
                                            is FetchOneSuccess<DateTime?>) {
                                          chatDeletedAt = dateResponse.item;
                                        } else {
                                          return;
                                        }
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) => ChatScreen(
                                                  chatId: chatId,
                                                  chatDeletedAt: chatDeletedAt,
                                                ),
                                          ),
                                        );
                                      },
                                      shape: const CircleBorder(),
                                      mini: true,
                                      backgroundColor: Color.fromRGBO(
                                        0,
                                        102,
                                        255,
                                        1,
                                      ),
                                      child: Icon(
                                        Icons.chat,
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Zawartość ekranu (tekst itd.)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 25, right: 25, top: 20),
              child: Column(
                children: [
                  Container(
                    //padding: const EdgeInsets.only(left: 3, right: 3, top: 3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(16, 20, 94, 0.1),
                          blurRadius: 3,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            categoryIcons[place.category],
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            getCategoryName(
                                              context,
                                              place.category,
                                            ),
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                              fontSize: 15,
                                              fontFamily: 'Mplus1p',
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons
                                                .account_balance_wallet_outlined,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${place.pricepp?.$1} - ${place.pricepp?.$2} zł',
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                              fontSize: 15,
                                              fontFamily: 'Mplus1p',
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (place.tags != null &&
                                      place.tags!.isNotEmpty)
                                    TagList(
                                      tags: place.tags!,
                                      textSize: 14,
                                      iconSize: 20,
                                    ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 3,
                                  right: 3,
                                ),
                                child: Divider(
                                  height: 5,
                                  thickness: 0.5,
                                  color: const Color.fromRGBO(195, 196, 215, 1),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                place.desc,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 15,
                                  fontFamily: 'Mplus1p',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 3,
                                  right: 3,
                                ),
                                child: Divider(
                                  height: 5,
                                  thickness: 0.5,
                                  color: const Color.fromRGBO(195, 196, 215, 1),
                                ),
                              ),
                              const SizedBox(height: 16),

                              Padding(
                                padding: EdgeInsets.only(left: 0),
                                child: TextButton(
                                  onPressed:
                                      () => openInGoogleMaps(
                                        query:
                                            '${place.name}, ${place.address}',
                                      ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color.fromRGBO(
                                      16,
                                      20,
                                      94,
                                      1,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10 * textScale,
                                      vertical: 4 * textScale,
                                    ),
                                    minimumSize: const Size(0, 36),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: 3 * textScale,
                                      bottom: 3 * textScale,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            right: 5,
                                            top: 0,
                                            bottom: 0,
                                          ),
                                          child: Icon(
                                            Icons.map_outlined,
                                            color: Color.fromRGBO(
                                              255,
                                              255,
                                              255,
                                              1,
                                            ),
                                            size: 24 * textScale,
                                          ),
                                        ),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.open_in_map,
                                          style: TextStyle(
                                            fontFamily: 'Mplus1p',
                                            fontSize: 16 * textScale,
                                            letterSpacing: -1,
                                            fontWeight: FontWeight.w500,
                                            color: Color.fromRGBO(
                                              255,
                                              255,
                                              255,
                                              1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Column(
                                  children: [
                                    // telefon
                                    _textWithIcon(
                                      context: context,
                                      icon: Icons.phone,
                                      title: place.phoneNumber,
                                      onTap:
                                          () => copyToClipboard(
                                            context,
                                            place.phoneNumber,
                                          ),
                                      isActive: true,
                                    ),

                                    //mail
                                    if (place.emailAddress != null &&
                                        place.emailAddress!.isNotEmpty)
                                      _textWithIcon(
                                        context: context,
                                        icon: Icons.email_outlined,
                                        title: place.emailAddress!,
                                        onTap:
                                            () => goToMail(
                                              place.emailAddress!,
                                              context,
                                              subject:
                                                  'Zapytanie o ${place.name}',
                                            ),
                                        isActive: true,
                                      ),

                                    //_buildLink('Strona', place.urlLink, Icons.link),
                                    if (place.urlLink != null &&
                                        place.urlLink!.isNotEmpty)
                                      _textWithIcon(
                                        context: context,
                                        icon: Symbols.captive_portal,
                                        title: 'strona internetowa',
                                        onTap: () => runUrl(place.urlLink!),
                                        isActive: true,
                                      ),
                                    //_buildLink('Instagram', place.igLink, FontAwesomeIcons.instagram),
                                    if (place.igLink != null &&
                                        place.igLink!.isNotEmpty)
                                      _textWithIcon(
                                        context: context,
                                        icon: FontAwesomeIcons.instagram,
                                        title: 'instagram',
                                        onTap: () => runUrl(place.igLink!),
                                        isActive: true,
                                      ),
                                    //_buildLink('Facebook', place.fbLink, FontAwesomeIcons.facebook),
                                    if (place.fbLink != null &&
                                        place.fbLink!.isNotEmpty)
                                      _textWithIcon(
                                        context: context,
                                        icon: FontAwesomeIcons.facebook,
                                        title: 'facebook',
                                        onTap: () => runUrl(place.fbLink!),
                                        isActive: true,
                                      ),
                                    //Tagi
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Wyświetlanie menu
                  Container(
                    padding: const EdgeInsets.only(left: 4, top: 3, bottom: 7),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(16, 20, 94, 0.1),
                          blurRadius: 3,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: Theme.of(context).colorScheme.primary,
                        collapsedIconColor:
                            Theme.of(context).colorScheme.primary,

                        title: Text(
                          AppLocalizations.of(context)!.menu,
                          style: TextStyle(
                            fontFamily: 'Mplus1p',
                            fontSize: 24 * textScale,
                            letterSpacing: -1,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        initiallyExpanded: false,
                        children: [
                          if (place.menu != null &&
                              place.menu!.groups.isNotEmpty)
                            ...place.menu!.groups.map(
                              (group) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 3,
                                        right: 3,
                                        bottom: 5,
                                      ),
                                      child: Divider(
                                        height: 5,
                                        thickness: 0.5,
                                        color: const Color.fromRGBO(
                                          195,
                                          196,
                                          215,
                                          1,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: Text(
                                        group.title,
                                        style: TextStyle(
                                          fontFamily: 'Mplus1p',
                                          fontSize: 16 * textScale,
                                          letterSpacing: -1,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ...group.elements.map(
                                      (e) => Padding(
                                        padding: const EdgeInsets.only(
                                          left: 30,
                                          right: 30,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              e.$1,
                                              style: TextStyle(
                                                fontFamily: 'Mplus1p',
                                                fontSize: 14 * textScale,
                                                letterSpacing: -1,
                                                fontWeight: FontWeight.w300,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                            ),
                                            Text(
                                              '${e.$2} zł',
                                              style: TextStyle(
                                                fontFamily: 'Mplus1p',
                                                fontSize: 14 * textScale,
                                                letterSpacing: -1,
                                                fontWeight: FontWeight.w300,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                AppLocalizations.of(context)!.no_menu,
                                style: TextStyle(
                                  fontFamily: 'Mplus1p',
                                  fontSize: 24 * textScale,
                                  letterSpacing: -1,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Wyświetlanie propozycji randek
                  Container(
                    padding: const EdgeInsets.only(left: 4, top: 3, bottom: 7),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(16, 20, 94, 0.1),
                          blurRadius: 3,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: Theme.of(context).colorScheme.primary,
                        collapsedIconColor:
                            Theme.of(context).colorScheme.primary,
                        title: Text(
                          AppLocalizations.of(context)!.date_ideas,
                          style: TextStyle(
                            fontFamily: 'Mplus1p',
                            fontSize: 24 * textScale,
                            letterSpacing: -1,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        initiallyExpanded: false,
                        children: [
                          if (place.datePropositions != null &&
                              place.datePropositions!.isNotEmpty)
                            ...place.datePropositions!.map(
                              (dp) => Padding(
                                padding: const EdgeInsets.only(
                                  left: 4.0,
                                  right: 4.0,
                                  bottom: 5.0,
                                ),
                                child: ListTile(
                                  //title: Text(dp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Divider(
                                        height: 5,
                                        thickness: 0.5,
                                        color: const Color.fromRGBO(
                                          195,
                                          196,
                                          215,
                                          1,
                                        ),
                                      ),
                                      if (dp.photo != null &&
                                          dp.photo!.isNotEmpty)
                                        Card(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 4,
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: SizedBox(
                                            width: screenWidth,
                                            height: 144,
                                            child: Stack(
                                              children: [
                                                Image.network(
                                                  dp.photo!,
                                                  width: double.infinity,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                  // Handling of loading image errors
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Container(
                                                        width: double.infinity,
                                                        height: 120,
                                                        color: Colors.grey[300],
                                                        child: const Icon(
                                                          Icons.broken_image,
                                                          size: 48,
                                                        ),
                                                      ),
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  left: 0,
                                                  right: 0,
                                                  height:
                                                      80, // wysokość gradientu
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment
                                                                .bottomCenter,
                                                        end:
                                                            Alignment.topCenter,
                                                        colors: [
                                                          Color.fromRGBO(
                                                            16,
                                                            20,
                                                            94,
                                                            1,
                                                          ),
                                                          // Color.fromRGBO(16, 20, 94, 0),
                                                          Color.fromRGBO(
                                                            16,
                                                            20,
                                                            94,
                                                            0.95,
                                                          ),
                                                          Color.fromRGBO(
                                                            16,
                                                            20,
                                                            94,
                                                            0.8,
                                                          ),
                                                          Color.fromRGBO(
                                                            16,
                                                            20,
                                                            94,
                                                            0.4,
                                                          ),
                                                          Color.fromRGBO(
                                                            16,
                                                            20,
                                                            94,
                                                            0.1,
                                                          ),
                                                          Colors.transparent,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                Positioned(
                                                  left: 11,
                                                  bottom: 10,
                                                  right: 11,
                                                  child: Text(
                                                    dp.title,
                                                    overflow: TextOverflow.fade,
                                                    softWrap: false,
                                                    style: TextStyle(
                                                      fontFamily: 'Mplus1p',
                                                      fontSize:
                                                          18 *
                                                          textScale, //screenWidth < 300 ? 15 : 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color.fromRGBO(
                                                        255,
                                                        255,
                                                        255,
                                                        1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 4),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                left: 0,
                                                                right: 5,
                                                                top: 0,
                                                                bottom: 0,
                                                              ),
                                                          child: Icon(
                                                            Icons
                                                                .account_balance_wallet_outlined,
                                                            color:
                                                                Color.fromRGBO(
                                                                  16,
                                                                  20,
                                                                  94,
                                                                  1,
                                                                ),
                                                            size:
                                                                16 * textScale,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${dp.pricepp.$1} - ${dp.pricepp.$2} zł',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Mplus1p',
                                                            fontSize:
                                                                11 * textScale,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                Color.fromRGBO(
                                                                  16,
                                                                  20,
                                                                  94,
                                                                  1,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                left: 0,
                                                                right: 5,
                                                                top: 0,
                                                                bottom: 0,
                                                              ),
                                                          child: Icon(
                                                            Icons
                                                                .schedule_outlined,
                                                            color:
                                                                Color.fromRGBO(
                                                                  16,
                                                                  20,
                                                                  94,
                                                                  1,
                                                                ),
                                                            size:
                                                                16 * textScale,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${formatDuration(dp.time.$1)} - ${formatDuration(dp.time.$2)}',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Mplus1p',
                                                            fontSize:
                                                                11 * textScale,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                Color.fromRGBO(
                                                                  16,
                                                                  20,
                                                                  94,
                                                                  1,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                left: 0,
                                                                right: 5,
                                                                top: 0,
                                                                bottom: 0,
                                                              ),
                                                          child: Icon(
                                                            Icons
                                                                .group_outlined,
                                                            color:
                                                                Color.fromRGBO(
                                                                  16,
                                                                  20,
                                                                  94,
                                                                  1,
                                                                ),
                                                            size:
                                                                16 * textScale,
                                                          ),
                                                        ),
                                                        Text(
                                                          dp.peopleType.name,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Mplus1p',
                                                            fontSize:
                                                                11 * textScale,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                Color.fromRGBO(
                                                                  16,
                                                                  20,
                                                                  94,
                                                                  1,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                left: 0,
                                                                right: 5,
                                                                top: 0,
                                                                bottom: 0,
                                                              ),
                                                          child: Icon(
                                                            categoryIcons[dp
                                                                .category],
                                                            color:
                                                                Color.fromRGBO(
                                                                  16,
                                                                  20,
                                                                  94,
                                                                  1,
                                                                ),
                                                            size:
                                                                16 * textScale,
                                                          ),
                                                        ),
                                                        Text(
                                                          dp.category.name,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Mplus1p',
                                                            fontSize:
                                                                11 * textScale,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                Color.fromRGBO(
                                                                  16,
                                                                  20,
                                                                  94,
                                                                  1,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                if (dp.tags != null &&
                                                    dp.tags!.isNotEmpty)
                                                  TagList(
                                                    tags: dp.tags!,
                                                    textSize: 12,
                                                    iconSize: 12,
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              dp.desc,
                                              style: TextStyle(
                                                fontFamily: 'Mplus1p',
                                                fontSize: 14 * textScale,
                                                letterSpacing: -1,
                                                fontWeight: FontWeight.w300,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                AppLocalizations.of(context)!.no_date_ideas,
                                style: TextStyle(
                                  fontFamily: 'Mplus1p',
                                  fontSize: 24 * textScale,
                                  letterSpacing: -1,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TagList extends StatelessWidget {
  final List<String> tags;
  final double textSize;
  final double iconSize;

  const TagList({
    Key? key,
    required this.tags,
    required this.textSize,
    required this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.tags,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: textSize,
                fontFamily: 'Mplus1p',
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.sell_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: iconSize,
            ),
          ],
        ),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 100,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: tags.map((tag) => _TagChip(tag: tag)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;

  const _TagChip({Key? key, required this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          tag,
          style: TextStyle(
            fontFamily: 'Mplus1p',
            fontSize: 11,
            fontWeight: FontWeight.w300,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }
}
