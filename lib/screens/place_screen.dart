import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_marketplace_template/models/place.dart';
import 'package:flutter_marketplace_template/view_models/favorite_places_view_model.dart';

/// Page de détail d'une annonce Koteka
class PlaceScreen extends StatelessWidget {
  final Place place;

  const PlaceScreen({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromRGBO(16, 20, 94, 1),
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

            // =========================
            // PHOTO DE L'ANNONCE
            // =========================
            SizedBox(
              width: double.infinity,
              height: screenWidth * 0.78,
              child: place.profilePicture.isNotEmpty
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
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 70,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        size: 70,
                        color: Colors.grey,
                      ),
                    ),
            ),

            // =========================
            // INFORMATIONS
            // =========================
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

                    // TITRE + FAVORI
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
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
                                favVM.isFavorite(place.id);

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

                    // =========================
                    // PRIX UNIQUE
                    // =========================
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

                    // =========================
                    // LOCALISATION
                    // =========================
                    if (place.address.isNotEmpty) ...[
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
                              place.address,
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

                    // =========================
                    // DESCRIPTION
                    // =========================
                    if (place.desc.isNotEmpty) ...[
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
                        place.desc,
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
