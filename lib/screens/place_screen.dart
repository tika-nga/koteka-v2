import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_marketplace_template/models/place.dart';
import 'package:flutter_marketplace_template/screens/chat_screen.dart';
import 'package:flutter_marketplace_template/services/chat_service.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:flutter_marketplace_template/view_models/favorite_places_view_model.dart';

/// Page de détail d'une annonce Koteka
class PlaceScreen extends StatefulWidget {
  final Place place;

  const PlaceScreen({
    super.key,
    required this.place,
  });

  @override
  State<PlaceScreen> createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  bool _isOpeningConversation = false;

  Future<void> _openConversation() async {
    if (_isOpeningConversation) {
      return;
    }

    final annonceId = int.tryParse(
      widget.place.id,
    );

    if (annonceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d’identifier cette annonce.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isOpeningConversation = true;
    });

    try {
      final chatService =
          context.read<IChatService>();

      final response =
          await chatService.getOrCreateConversation(
        annonceId: annonceId,
      );

      if (!mounted) {
        return;
      }

      if (response is FetchOneSuccess<String>) {
        final conversationId = response.item;

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: conversationId,
              chatDeletedAt: null,
              lastReadMessageId: null,
              hasUnreadMessages: false,
            ),
          ),
        );

        return;
      }

      if (response is FetchOneFailure<String>) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message,
            ),
          ),
        );

        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d’ouvrir la conversation.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de l’ouverture de la conversation : $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningConversation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final screenWidth =
        MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor:
            const Color.fromRGBO(
          16,
          20,
          94,
          1,
        ),
        elevation: 0,
        title: const Text(
          'Détail de l’annonce',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: screenWidth * 0.78,
              child:
                  place.profilePicture.isNotEmpty
                      ? Image.network(
                          place.profilePicture,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Container(
                              color:
                                  Colors.grey.shade200,
                              alignment:
                                  Alignment.center,
                              child: const Icon(
                                Icons
                                    .image_not_supported_outlined,
                                size: 70,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          color:
                              Colors.grey.shade200,
                          alignment:
                              Alignment.center,
                          child: const Icon(
                            Icons.image_outlined,
                            size: 70,
                            color: Colors.grey,
                          ),
                        ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(
                        16,
                        20,
                        94,
                        0.08,
                      ),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: const TextStyle(
                              fontFamily: 'Mplus1p',
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.w600,
                              color:
                                  Color.fromRGBO(
                                16,
                                20,
                                94,
                                1,
                              ),
                            ),
                          ),
                        ),

                        Consumer<
                            FavoritePlacesViewModel>(
                          builder:
                              (
                                context,
                                favVM,
                                _,
                              ) {
                            final isFav =
                                favVM.isFavorite(
                              place.id,
                            );

                            return IconButton(
                              onPressed: () {
                                favVM.toggleFavorite(
                                  place.id,
                                  place: place,
                                );
                              },
                              icon: Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons
                                        .favorite_border,
                                size: 30,
                                color:
                                    isFav
                                        ? Colors.red
                                        : const Color
                                            .fromRGBO(
                                          16,
                                          20,
                                          94,
                                          1,
                                        ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .account_balance_wallet_outlined,
                          size: 25,
                          color: Color.fromRGBO(
                            16,
                            20,
                            94,
                            1,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          place.pricepp != null
                              ? '${place.pricepp!.$1} FC'
                              : 'Prix non renseigné',
                          style: const TextStyle(
                            fontFamily: 'Mplus1p',
                            fontSize: 21,
                            fontWeight:
                                FontWeight.w600,
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

                    if (place.address.isNotEmpty) ...[
                      const SizedBox(height: 14),

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons
                                .location_on_outlined,
                            size: 23,
                            color:
                                Color.fromRGBO(
                              16,
                              20,
                              94,
                              1,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              place.address,
                              style:
                                  const TextStyle(
                                fontFamily:
                                    'Mplus1p',
                                fontSize: 16,
                                color:
                                    Color.fromRGBO(
                                  16,
                                  20,
                                  94,
                                  1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (place.desc.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 14),

                      const Text(
                        'Description',
                        style: TextStyle(
                          fontFamily: 'Mplus1p',
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w600,
                          color:
                              Color.fromRGBO(
                            16,
                            20,
                            94,
                            1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        place.desc,
                        style: const TextStyle(
                          fontFamily: 'Mplus1p',
                          fontSize: 16,
                          height: 1.5,
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

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed:
                            _isOpeningConversation
                                ? null
                                : _openConversation,
                        style:
                            FilledButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(
                            16,
                            20,
                            94,
                            1,
                          ),
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                        icon:
                            _isOpeningConversation
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .chat_bubble_outline_rounded,
                                  ),
                        label: Text(
                          _isOpeningConversation
                              ? 'Ouverture...'
                              : 'Envoyer un message',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
