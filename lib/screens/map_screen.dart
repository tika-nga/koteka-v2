import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_marketplace_template/adapters/app_bar.dart';
import 'package:flutter_marketplace_template/models/annonce.dart';
import 'package:flutter_marketplace_template/screens/place_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _query = '';
  String? _selectedFamily;
  String? _selectedCategory;

  final Map<String, List<String>> _categoriesParFamille = {
    'Véhicules': [
      'Voitures',
      'Camions',
      'Motos',
      'Vélos',
      'Pièces automobiles',
      'Pièces moto/quad',
    ],
    'Électronique': [
      'Ordinateurs',
      'Photo / Audio / Caméra',
      'Consoles et jeux vidéo',
    ],
    'Électroménager': [
      'Électroménager',
    ],
    'Maison / Ndaku': [
      'Ameublement',
    ],
    'Autres': [
      'Autres',
    ],
  };

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _onSearchChanged,
    );
  }

  void _onSearchChanged() {
    final value =
        _searchController.text.trim().toLowerCase();

    if (value == _query) {
      return;
    }

    setState(() {
      _query = value;
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

  Future<List<Annonce>> _loadAnnonces() async {
    final response = await Supabase.instance.client
        .from('annonces')
        .select()
        .order(
          'created_at',
          ascending: false,
        );

    return List<Map<String, dynamic>>.from(
      response,
    ).map(Annonce.fromJson).toList();
  }

  List<Annonce> _filter(
    List<Annonce> annonces,
  ) {
    return annonces.where(
      (annonce) {
        if (_selectedFamily != null &&
            annonce.family != _selectedFamily) {
          return false;
        }

        if (_selectedCategory != null &&
            annonce.category != _selectedCategory) {
          return false;
        }

        if (_query.isEmpty) {
          return true;
        }

        final searchable = [
          annonce.title,
          annonce.description,
          annonce.family,
          annonce.category,
          annonce.city,
          annonce.district,
        ].join(' ').toLowerCase();

        return searchable.contains(_query);
      },
    ).toList();
  }

  void _reset() {
    _searchController.clear();

    setState(() {
      _query = '';
      _selectedFamily = null;
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        _selectedFamily == null
            ? <String>[]
            : _categoriesParFamille[
                    _selectedFamily] ??
                <String>[];

    return Scaffold(
      backgroundColor:
          Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBar(
        showTitle: true,
        showMenu: false,
        showChat: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            30,
          ),
          children: [
            const Text(
              'Rechercher',
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
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              textInputAction:
                  TextInputAction.search,
              decoration: InputDecoration(
                hintText:
                    'Téléphone, voiture, meuble...',
                prefixIcon:
                    const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
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
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Catégories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(
                    Icons.refresh,
                    size: 18,
                  ),
                  label: const Text(
                    'Réinitialiser',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal,
              child: Row(
                children:
                    _categoriesParFamille.keys.map(
                  (family) {
                    final selected =
                        family == _selectedFamily;

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        right: 8,
                      ),
                      child: ChoiceChip(
                        label: Text(family),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            if (selected) {
                              _selectedFamily = null;
                              _selectedCategory =
                                  null;
                            } else {
                              _selectedFamily =
                                  family;
                              _selectedCategory =
                                  null;
                            }
                          });
                        },
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
            if (_selectedFamily != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map(
                  (category) {
                    final selected =
                        category ==
                            _selectedCategory;

                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory =
                              selected
                                  ? null
                                  : category;
                        });
                      },
                    );
                  },
                ).toList(),
              ),
            ],
            const SizedBox(height: 22),
            FutureBuilder<List<Annonce>>(
              future: _loadAnnonces(),
              builder: (
                context,
                snapshot,
              ) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding:
                        const EdgeInsets.all(
                      20,
                    ),
                    child: Text(
                      'Erreur de chargement : '
                      '${snapshot.error}',
                      textAlign:
                          TextAlign.center,
                    ),
                  );
                }

                final annonces = _filter(
                  snapshot.data ??
                      <Annonce>[],
                );

                if (annonces.isEmpty) {
                  return const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      vertical: 50,
                    ),
                    child: Center(
                      child: Text(
                        'Aucune annonce trouvée.',
                      ),
                    ),
                  );
                }

                return Column(
                  children: annonces.map(
                    (annonce) {
                      return _buildAnnonceCard(
                        annonce,
                      );
                    },
                  ).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnonceCard(
    Annonce annonce,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
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
            padding:
                const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(10),
                  child:
                      annonce.imageUrl.isNotEmpty
                          ? Image.network(
                              annonce.imageUrl,
                              width: 105,
                              height: 105,
                              fit:
                                  BoxFit.cover,
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
                        annonce.title.isEmpty
                            ? 'Sans titre'
                            : annonce.title,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
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
                          color:
                              Theme.of(context)
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
                          style:
                              const TextStyle(
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
                const Icon(
                  Icons.chevron_right,
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
