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

  static const Color _primaryColor = Color.fromRGBO(
    16,
    20,
    94,
    1,
  );

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

  bool get _hasCharacteristics {
    final annonce = widget.annonce;

    return annonce.brand?.isNotEmpty == true ||
        annonce.model?.isNotEmpty == true ||
        annonce.manufactureYear != null ||
        annonce.horsepower != null ||
        annonce.fuelType?.isNotEmpty == true ||
        annonce.mileage != null ||
        annonce.itemCondition?.isNotEmpty == true ||
        annonce.itemType?.isNotEmpty == true ||
        annonce.compatibleConsole?.isNotEmpty == true ||
        annonce.usageHours != null;
  }

  Widget _informationRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: _primaryColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Mplus1p',
                  fontSize: 16,
                  color: _primaryColor,
                  height: 1.35,
                ),
                children: [
                  TextSpan(
                    text: '$label : ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: value,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristics() {
    final annonce = widget.annonce;

    if (!_hasCharacteristics) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 14),

        const Text(
          'Caractéristiques',
          style: TextStyle(
            fontFamily: 'Mplus1p',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _primaryColor,
          ),
        ),

        const SizedBox(height: 16),

        if (annonce.itemType?.isNotEmpty == true)
          _informationRow(
            icon: Icons.sell_outlined,
            label: 'Type',
            value: annonce.itemType ?? '',
          ),

        if (annonce.brand?.isNotEmpty == true)
          _informationRow(
            icon: Icons.business_outlined,
            label: annonce.itemType == 'Console'
                ? 'Nom / marque'
                : 'Marque',
            value: annonce.brand ?? '',
          ),

        if (annonce.model?.isNotEmpty == true)
          _informationRow(
            icon: Icons.info_outline,
            label: annonce.itemType == 'Jeu'
                ? 'Nom du jeu'
                : 'Modèle',
            value: annonce.model ?? '',
          ),

        if (annonce.manufactureYear != null)
          _informationRow(
            icon: Icons.calendar_month_outlined,
            label: 'Année',
            value: annonce.manufactureYear.toString(),
          ),

        if (annonce.horsepower != null)
          _informationRow(
            icon: Icons.speed_outlined,
            label: 'Puissance',
            value: '${annonce.horsepower} CV',
          ),

        if (annonce.fuelType?.isNotEmpty == true)
          _informationRow(
            icon: Icons.local_gas_station_outlined,
            label: 'Carburant',
            value: annonce.fuelType ?? '',
          ),

        if (annonce.mileage != null)
          _informationRow(
            icon: Icons.route_outlined,
            label: 'Kilométrage',
            value: '${annonce.mileage} km',
          ),

        if (annonce.usageHours != null)
          _informationRow(
            icon: Icons.schedule_outlined,
            label: 'Heures d’utilisation',
            value: '${annonce.usageHours} h',
          ),

        if (annonce.compatibleConsole?.isNotEmpty == true)
          _informationRow(
            icon: Icons.sports_esports_outlined,
            label: 'Console compatible',
            value: annonce.compatibleConsole ?? '',
          ),

        if (annonce.itemCondition?.isNotEmpty == true)
          _informationRow(
            icon: Icons.verified_outlined,
            label: 'État',
            value: annonce.itemCondition ?? '',
          ),
      ],
    );
  }

  Widget _buildServiceInformation() {
    final annonce = widget.annonce;

    if (!annonce.isService) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 14),

        const Text(
          'Prestation',
          style: TextStyle(
            fontFamily: 'Mplus1p',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _primaryColor,
          ),
        ),

        const SizedBox(height: 16),

        _informationRow(
          icon: Icons.handyman_outlined,
          label: 'Service',
          value: annonce.category,
        ),

        _informationRow(
          icon: annonce.isQuote
              ? Icons.request_quote_outlined
              : Icons.payments_outlined,
          label: 'Tarification',
          value: annonce.isQuote
              ? 'Sur devis'
              : 'Prix fixe',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final annonce = widget.annonce;
    final screenWidth =
        MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _primaryColor,
        elevation: 0,
        title: Text(
          annonce.isService
              ? 'Détail de la prestation'
              : 'Détail de l’annonce',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: screenWidth * 0.78,
              color: Colors.black,
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
                            annonce.title.isEmpty
                                ? 'Sans titre'
                                : annonce.title,
                            style: const TextStyle(
                              fontFamily: 'Mplus1p',
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.w600,
                              color: _primaryColor,
                            ),
                          ),
                        ),

                        Consumer<
                            FavoritePlacesViewModel>(
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
                                    : Icons
                                        .favorite_border,
                                size: 30,
                                color: isFav
                                    ? Colors.red
                                    : _primaryColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Icon(
                          annonce.isQuote
                              ? Icons
                                  .request_quote_outlined
                              : Icons
                                  .account_balance_wallet_outlined,
                          size: 25,
                          color: _primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            annonce.priceLabel,
                            style: const TextStyle(
                              fontFamily: 'Mplus1p',
                              fontSize: 21,
                              fontWeight:
                                  FontWeight.w600,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (annonce.category.isNotEmpty ||
                        annonce.family.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.category_outlined,
                            size: 22,
                            color: _primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              annonce.category.isNotEmpty
                                  ? annonce.category
                                  : annonce.family,
                              style: const TextStyle(
                                fontFamily: 'Mplus1p',
                                fontSize: 16,
                                color: _primaryColor,
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
                            color: _primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              annonce.location,
                              style: const TextStyle(
                                fontFamily: 'Mplus1p',
                                fontSize: 16,
                                color: _primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (!annonce.isService)
                      _buildCharacteristics(),

                    if (annonce.isService)
                      _buildServiceInformation(),

                    if (annonce.description.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 14),

                      Text(
                        annonce.isService
                            ? 'Description de la prestation'
                            : 'Description',
                        style: const TextStyle(
                          fontFamily: 'Mplus1p',
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w600,
                          color: _primaryColor,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        annonce.description,
                        style: const TextStyle(
                          fontFamily: 'Mplus1p',
                          fontSize: 16,
                          height: 1.5,
                          color: _primaryColor,
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
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              _primaryColor,
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets
                                  .symmetric(
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
                              : annonce.isService
                                  ? 'Contacter le prestataire'
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
