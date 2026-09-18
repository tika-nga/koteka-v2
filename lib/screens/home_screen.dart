import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_marketplace_template/models/place.dart';
import 'package:flutter_marketplace_template/screens/place_screen.dart';
import 'package:flutter_marketplace_template/views/components/filter_buttons.dart';
import 'package:flutter_marketplace_template/adapters/app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedFamily;
  String? _selectedCategory;

  int? _selectedMinPrice;
  int? _selectedMaxPrice;

  String? _selectedCity;
  String? _selectedCommune;

  String _searchQuery = '';
  String _selectedSort = 'recent';

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

  final Map<String, IconData> _familyIcons = {
    'Véhicules': Icons.directions_car,
    'Électronique': Icons.devices,
    'Électroménager': Icons.kitchen,
    'Maison / Ndaku': Icons.home_outlined,
    'Autres': Icons.category_outlined,
  };

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final value = _searchController.text.trim().toLowerCase();

    if (value == _searchQuery) return;

    setState(() {
      _searchQuery = value;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadAnnonces() async {
    final response = await Supabase.instance.client
        .from('annonces')
        .select()
        .order(
          'created_at',
          ascending: false,
        );

    return List<Map<String, dynamic>>.from(response);
  }

  void _resetFilters() {
    setState(() {
      _selectedFamily = null;
      _selectedCategory = null;

      _selectedMinPrice = null;
      _selectedMaxPrice = null;

      _selectedCity = null;
      _selectedCommune = null;

      _selectedSort = 'recent';

      _searchController.clear();
      _searchQuery = '';
    });
  }

  int _readPrice(Map<String, dynamic> annonce) {
    final rawPrice = annonce['price']?.toString() ?? '';

    final cleaned = rawPrice
        .replaceAll(' ', '')
        .replaceAll(',', '')
        .replaceAll('.', '');

    return int.tryParse(cleaned) ?? 0;
  }

  String _normalize(String? value) {
    return (value ?? '').trim().toLowerCase();
  }

  bool _matchesSearch(Map<String, dynamic> annonce) {
    if (_searchQuery.isEmpty) {
      return true;
    }

    final title = _normalize(
      annonce['title']?.toString(),
    );

    final family = _normalize(
      annonce['family']?.toString(),
    );

    final category = _normalize(
      annonce['category']?.toString(),
    );

    return title.contains(_searchQuery) ||
        family.contains(_searchQuery) ||
        category.contains(_searchQuery);
  }

  bool _matchesFamilyAndCategory(
    Map<String, dynamic> annonce,
  ) {
    final family = annonce['family']?.toString().trim() ?? '';
    final category =
        annonce['category']?.toString().trim() ?? '';

    if (_selectedFamily != null) {
      if (family.isNotEmpty) {
        if (family != _selectedFamily) {
          return false;
        }
      } else {
        // Compatibilité avec les anciennes annonces
        // qui n'ont pas encore de valeur "family".
        final allowedCategories =
            _categoriesParFamille[_selectedFamily] ?? [];

        if (!allowedCategories.contains(category)) {
          return false;
        }
      }
    }

    if (_selectedCategory != null &&
        category != _selectedCategory) {
      return false;
    }

    return true;
  }

  bool _matchesOtherFilters(
    Map<String, dynamic> annonce,
  ) {
    final price = _readPrice(annonce);

    final city =
        annonce['city']?.toString().trim() ?? '';

    final commune =
        annonce['district']?.toString().trim() ?? '';

    if (_selectedMinPrice != null &&
        price < _selectedMinPrice!) {
      return false;
    }

    if (_selectedMaxPrice != null &&
        price > _selectedMaxPrice!) {
      return false;
    }

    if (_selectedCity != null &&
        city != _selectedCity) {
      return false;
    }

    if (_selectedCommune != null &&
        commune != _selectedCommune) {
      return false;
    }

    return true;
  }

  List<Map<String, dynamic>> _filterAndSort(
    List<Map<String, dynamic>> annonces,
  ) {
    final result = annonces.where((annonce) {
      if (!_matchesSearch(annonce)) {
        return false;
      }

      if (!_matchesFamilyAndCategory(annonce)) {
        return false;
      }

      if (!_matchesOtherFilters(annonce)) {
        return false;
      }

      return true;
    }).toList();

    switch (_selectedSort) {
      case 'price_asc':
        result.sort(
          (a, b) => _readPrice(a).compareTo(
            _readPrice(b),
          ),
        );
        break;

      case 'price_desc':
        result.sort(
          (a, b) => _readPrice(b).compareTo(
            _readPrice(a),
          ),
        );
        break;

      case 'recent':
      default:
        result.sort((a, b) {
          final dateA = DateTime.tryParse(
            a['created_at']?.toString() ?? '',
          );

          final dateB = DateTime.tryParse(
            b['created_at']?.toString() ?? '',
          );

          if (dateA == null && dateB == null) {
            return 0;
          }

          if (dateA == null) {
            return 1;
          }

          if (dateB == null) {
            return -1;
          }

          return dateB.compareTo(dateA);
        });
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = screenWidth / 400;

    return Scaffold(
      backgroundColor:
          Theme.of(context).colorScheme.surface,

      appBar: CustomAppBar(
        showTitle: true,
        showMenu: true,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
            top: 20,
            bottom: 30,
          ),
          children: [
            _buildSearchPanel(
              context,
              textScale,
            ),

            const SizedBox(height: 15),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadAnnonces(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Erreur de chargement : ${snapshot.error}',
                    ),
                  );
                }

                final annonces = snapshot.data ?? [];

                final annoncesFiltrees =
                    _filterAndSort(annonces);

                if (annoncesFiltrees.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: Text(
                        'Aucune annonce ne correspond à votre recherche.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics:
                      const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: annoncesFiltrees.length,
                  itemBuilder: (context, index) {
                    return _buildAnnonceCard(
                      context,
                      annoncesFiltrees[index],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPanel(
    BuildContext context,
    double textScale,
  ) {
    final subCategories =
        _selectedFamily == null
            ? <String>[]
            : _categoriesParFamille[_selectedFamily] ??
                <String>[];

    return Container(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 10,
        bottom: 15,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(
              16,
              20,
              94,
              0.25,
            ),
            blurRadius: 3,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 9,
            ),
            child: Text(
              'Que recherchez-vous ? / Olingi nini ?',
              style: TextStyle(
                fontFamily: 'Mplus1p',
                fontSize: 18 * textScale,
                letterSpacing: -1,
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Divider(
            height: 5,
            thickness: 0.5,
            color: Color.fromRGBO(
              195,
              196,
              215,
              1,
            ),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
              ),
              suffixIcon:
                  _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(
                            Icons.close,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
              hintText:
                  'Téléphone, voiture, meuble...',
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Catégories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 9),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  _categoriesParFamille.keys.map(
                (family) {
                  return _familyChip(
                    family,
                    _familyIcons[family] ??
                        Icons.category_outlined,
                  );
                },
              ).toList(),
            ),
          ),

          if (_selectedFamily != null) ...[
            const SizedBox(height: 12),

            Text(
              _selectedFamily!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 7),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: subCategories.map(
                  (category) {
                    return _subCategoryChip(
                      category,
                    );
                  },
                ).toList(),
              ),
            ),
          ],

          const SizedBox(height: 16),

          const Divider(
            height: 5,
            thickness: 0.5,
            color: Color.fromRGBO(
              195,
              196,
              215,
              1,
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: filterButton(
              context,
              textScale,
              initialMinPrice:
                  _selectedMinPrice,
              initialMaxPrice:
                  _selectedMaxPrice,
              initialCity:
                  _selectedCity,
              initialCommune:
                  _selectedCommune,
              onFilter: (result) {
                setState(() {
                  _selectedMinPrice =
                      result.minPrice;

                  _selectedMaxPrice =
                      result.maxPrice;

                  _selectedCity =
                      result.city;

                  _selectedCommune =
                      result.commune;
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          _buildActionBar(context),

          const SizedBox(height: 4),

          const Divider(
            height: 5,
            thickness: 0.5,
            color: Color.fromRGBO(
              195,
              196,
              215,
              1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _familyChip(
    String family,
    IconData icon,
  ) {
    final selected =
        _selectedFamily == family;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            _selectedFamily = null;
            _selectedCategory = null;
          } else {
            _selectedFamily = family;
            _selectedCategory = null;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(
          right: 7,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context)
                  .colorScheme
                  .secondary
              : Theme.of(context)
                  .colorScheme
                  .surface,
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .primary,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected
                  ? Theme.of(context)
                      .colorScheme
                      .onSecondary
                  : Theme.of(context)
                      .colorScheme
                      .primary,
            ),

            const SizedBox(width: 5),

            Text(
              family,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: selected
                    ? Theme.of(context)
                        .colorScheme
                        .onSecondary
                    : Theme.of(context)
                        .colorScheme
                        .primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subCategoryChip(
    String category,
  ) {
    final selected =
        _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            _selectedCategory = null;
          } else {
            _selectedCategory = category;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(
          right: 7,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context)
                  .colorScheme
                  .tertiary
              : Theme.of(context)
                  .colorScheme
                  .surface,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.55),
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar(
    BuildContext context,
  ) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        SizedBox(
          height: 38,
          child: OutlinedButton.icon(
            onPressed: _resetFilters,
            icon: const Icon(
              Icons.refresh,
              size: 19,
            ),
            label: const Text(
              'Réinitialiser',
            ),
          ),
        ),

        PopupMenuButton<String>(
          initialValue: _selectedSort,
          onSelected: (value) {
            setState(() {
              _selectedSort = value;
            });
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem<String>(
                value: 'recent',
                child: Text(
                  'Plus récentes',
                ),
              ),
              PopupMenuItem<String>(
                value: 'price_asc',
                child: Text(
                  'Prix : du moins cher au plus cher',
                ),
              ),
              PopupMenuItem<String>(
                value: 'price_desc',
                child: Text(
                  'Prix : du plus cher au moins cher',
                ),
              ),
            ];
          },
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .secondary,
              borderRadius:
                  BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sort,
                  size: 20,
                  color: Theme.of(context)
                      .colorScheme
                      .onSecondary,
                ),

                const SizedBox(width: 6),

                Text(
                  'Trier',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSecondary,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnonceCard(
    BuildContext context,
    Map<String, dynamic> annonce,
  ) {
    final title =
        annonce['title']?.toString() ??
            'Sans titre';

    final price =
        annonce['price']?.toString() ?? '';

    final city =
        annonce['city']?.toString() ?? '';

    final district =
        annonce['district']?.toString() ?? '';

    final family =
        annonce['family']?.toString() ?? '';

    final category =
        annonce['category']?.toString() ?? '';

    final imageUrl =
        annonce['ImageUrl']?.toString() ??
            annonce['imageUrl']?.toString() ??
            '';

    final place =
        PlaceExtension.placeholder();

    place.id =
        annonce['id']?.toString() ?? '';

    place.name = title;

    place.address = district.isNotEmpty
        ? '$city, $district'
        : city;

    place.profilePicture = imageUrl;

    place.desc =
        annonce['description']?.toString() ??
            annonce['desc']?.toString() ??
            '';

    final parsedPrice =
        _readPrice(annonce);

    place.pricepp = (
      parsedPrice,
      parsedPrice,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                PlaceScreen(
              place: place,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(8),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
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

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      '$price FC',
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    if (family.isNotEmpty ||
                        category.isNotEmpty) ...[
                      const SizedBox(height: 7),

                      Text(
                        [
                          family,
                          category,
                        ]
                            .where(
                              (value) =>
                                  value.isNotEmpty,
                            )
                            .join(' • '),
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                      ),
                    ],

                    const SizedBox(height: 7),

                    Text(
                      district.isNotEmpty
                          ? '$city • $district'
                          : city,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 120,
      height: 120,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 40,
      ),
    );
  }
}
