import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_marketplace_template/models/annonce.dart';
import 'package:flutter_marketplace_template/screens/chat_screen.dart';
import 'package:flutter_marketplace_template/services/chat_service.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:flutter_marketplace_template/view_models/favorite_places_view_model.dart';

class PlaceScreen extends StatefulWidget {
  final Annonce annonce;

  const PlaceScreen({
    super.key,
    required this.annonce,
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

    setState(() {
      _isOpeningConversation = true;
    });

    try {
      final chatService = context.read<IChatService>();

      final response =
          await chatService.getOrCreateConversation(
        annonceId: widget.annonce.id,
      );

      if (!mounted) {
        return;
      }

      if (response is FetchOneSuccess<String>) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: response.item,
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
            content: Text(response.message),
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
    final annonce = widget.annonce;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromRGBO(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: screenWidth * 0.78,
              child: annonce.imageUrl.isNotEmpty
                  ? Image.network(
                      annonce.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            annonce.title.isEmpty
                                ? 'Sans titre'
                                : annonce.title,
                            style: const TextStyle(
                              fontFamily: 'Mplus1p',
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(
                                16,
                                20,
                                94,
                                1,
                              ),
                            ),
                          ),
                        ),
                        Consumer<FavoritePlacesViewModel>(
                          builder: (
                            context,
                            favVM,
                            _,
                          ) {
                            final isFav =
                                favVM.isFavorite(
                              annonce.id,
                            );

                            return IconButton(
                              onPressed: () {
                                favVM.toggleFavorite(
                                  annonce.id,
                                  annonce: annonce,
                                );
                              },
                              icon: Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 30,
                                color: isFav
                                    ? Colors.red
                                    : const Color.fromRGBO(
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
                          Icons.account_balance_wallet_outlined,
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
                          '${annonce.price} FC',
                          style: const TextStyle(
                            fontFamily: 'Mplus1p',
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(
                              16,
                              20,
                              94,
                              1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (annonce.category.isNotEmpty ||
                        annonce.family.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(
                            Icons.category_outlined,
                            size: 22,
                            color: Color.fromRGBO(
                              16,
                              20,
                              94,
                              1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              annonce.category.isNotEmpty
                                  ? annonce.category
                                  : annonce.family,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (annonce.location.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 23,
                            color: Color.fromRGBO(
                              16,
                              20,
                              94,
                              1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              annonce.location,
                              style: const TextStyle(
                                fontFamily: 'Mplus1p',
                                fontSize: 16,
                                color: Color.fromRGBO(
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
                    if (annonce.description.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 14),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontFamily: 'Mplus1p',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(
                            16,
                            20,
                            94,
                            1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        annonce.description,
                        style: const TextStyle(
                          fontFamily: 'Mplus1p',
                          fontSize: 16,
                          height: 1.5,
                          color: Color.fromRGBO(
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
                        onPressed: _isOpeningConversation
                            ? null
                            : _openConversation,
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(
                            16,
                            20,
                            94,
                            1,
                          ),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isOpeningConversation
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
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
                            fontWeight: FontWeight.w600,
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

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 70,
        color: Colors.grey,
      ),
    );
  }
}
