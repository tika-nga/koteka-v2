import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_marketplace_template/adapters/app_bar.dart';
import 'package:flutter_marketplace_template/models/annonce.dart';
import 'package:flutter_marketplace_template/screens/place_screen.dart';
import 'package:flutter_marketplace_template/view_models/favorite_places_view_model.dart';

class FavoritePlacesScreen extends StatefulWidget {
  const FavoritePlacesScreen({
    super.key,
  });

  @override
  State<FavoritePlacesScreen> createState() =>
      _FavoritePlacesScreenState();
}

class _FavoritePlacesScreenState
    extends State<FavoritePlacesScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _query = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _onSearchChanged,
    );
  }

  void _onSearchChanged() {
    setState(() {
      _query =
          _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(
      _onSearchChanged,
    );

    _searchController.dispose();

    super.dispose();
  }

  List<Annonce> _filtered(
    List<Annonce> annonces,
  ) {
    if (_query.isEmpty) {
      return annonces;
    }

    return annonces.where(
      (annonce) {
        return annonce.title
                .toLowerCase()
                .contains(_query) ||
            annonce.category
                .toLowerCase()
                .contains(_query) ||
            annonce.family
                .toLowerCase()
                .contains(_query) ||
            annonce.city
                .toLowerCase()
                .contains(_query) ||
            annonce.district
                .toLowerCase()
                .contains(_query);
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBar(
        showTitle: false,
        showMenu: false,
        showChat: false,
      ),
      body: Consumer<FavoritePlacesViewModel>(
        builder: (
          context,
          favVM,
          _,
        ) {
          if (favVM.isLoading &&
              favVM.favoriteAnnonces.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final annonces =
              _filtered(favVM.favoriteAnnonces);

          return RefreshIndicator(
            onRefresh: favVM.loadFavorites,
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                18,
                16,
                30,
              ),
              children: [
                const Text(
                  'Favoris',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(
                      16,
                      20,
                      94,
                      1,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${favVM.favoritesCount} annonce${favVM.favoritesCount > 1 ? 's' : ''} favorite${favVM.favoritesCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        'Rechercher dans les favoris',
                    prefixIcon:
                        const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController
                                      .clear();
                                },
                                icon: const Icon(
                                  Icons.close,
                                ),
                              ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (favVM.errorMessage != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 16,
                    ),
                    child: Text(
                      favVM.errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                if (annonces.isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      vertical: 50,
                    ),
                    child: Center(
                      child: Text(
                        'Aucune annonce favorite.',
                      ),
                    ),
                  )
                else
                  ...annonces.map(
                    (annonce) =>
                        _buildAnnonceCard(
                      context,
                      annonce,
                      favVM,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnnonceCard(
    BuildContext context,
    Annonce annonce,
    FavoritePlacesViewModel favVM,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Material(
        color:
            Theme.of(context).colorScheme.surface,
        elevation: 1.5,
        borderRadius:
            BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PlaceScreen(
                  annonce: annonce,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(10),
                  child: annonce.imageUrl.isNotEmpty
                      ? Image.network(
                          annonce.imageUrl,
                          width: 105,
                          height: 105,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) =>
                              _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        annonce.title,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${annonce.price} FC',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w700,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                      ),
                      if (annonce.category
                          .isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          annonce.category,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (annonce.location
                          .isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .location_on_outlined,
                              size: 15,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                annonce.location,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip:
                      'Retirer des favoris',
                  onPressed: () {
                    favVM.toggleFavorite(
                      annonce.id,
                      annonce: annonce,
                    );
                  },
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 105,
      height: 105,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 32,
        color: Colors.grey.shade500,
      ),
    );
  }
}
