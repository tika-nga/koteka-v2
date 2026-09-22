import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_marketplace_template/models/annonce.dart';
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
  final TextEditingController _searchController =
      TextEditingController();

  String? _selectedFamily;
  String? _selectedCategory;

  int? _selectedMinPrice;
  int? _selectedMaxPrice;

  String? _selectedCity;
  String? _selectedCommune;
  int? _selectedDistanceKm;

  Position? _userPosition;
  bool _isGettingPosition = false;

  String _searchQuery = '';
  String _selectedSort = 'recent';

  final Map<String, List<String>> _categoriesParFamille = {
    'Véhicules': [
      'Voitures',
      'Camions',
      'Motos / Quads',
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
      'Meubles',
    ],
    'Matériel chantier': [
      'Machines',
      'Outillage',
    ],
    'Prestations de services': [
      'Bâtiment / Construction',
      'Mécanique automobile / moto',
      'Électricité',
      'Plomberie',
      'Menuiserie',
      'Peinture',
      'Informatique / Téléphonie',
      'Transport / Livraison',
      'Nettoyage',
      'Couture',
      'Coiffure / Beauté',
      'Événementiel',
      'Formation / Cours',
      'Autres services',
    ],
    'Autres': [
      'Autres',
    ],
  };

  final Map<String, IconData> _familyIcons = {
    'Véhicules': Icons.directions_car_outlined,
    'Électronique': Icons.devices_outlined,
    'Électroménager': Icons.kitchen_outlined,
    'Maison / Ndaku': Icons.chair_outlined,
    'Matériel chantier': Icons.construction_outlined,
    'Prestations de services': Icons.handyman_outlined,
    'Autres': Icons.category_outlined,
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

    if (value == _searchQuery) {
      return;
    }

    setState(() {
      _searchQuery = value;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(
      _onSearchChanged,
    );

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

    return List<Map<String, dynamic>>.from(
      response,
    );
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<Position?> _getCurrentPosition() async {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!mounted) {
        return null;
      }

      final openSettings = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Localisation désactivée',
            ),
            content: const Text(
              'Activez la localisation du téléphone '
              'pour rechercher les annonces à proximité.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },
                child: const Text(
                  'Annuler',
                ),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    true,
                  );
                },
                child: const Text(
                  'Ouvrir les paramètres',
                ),
              ),
            ],
          );
        },
      );

      if (openSettings == true) {
        await Geolocator.openLocationSettings();
      }

      return null;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _showMessage(
        'La localisation doit être autorisée '
        'pour utiliser le filtre de distance.',
      );

      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) {
        return null;
      }

      final openSettings = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Autorisation de localisation',
            ),
            content: const Text(
              'L’accès à la localisation a été refusé. '
              'Vous pouvez l’autoriser dans les '
              'paramètres de Koteka.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },
                child: const Text(
                  'Annuler',
                ),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    true,
                  );
                },
                child: const Text(
                  'Ouvrir les paramètres',
                ),
              ),
            ],
          );
        },
      );

      if (openSettings == true) {
        await Geolocator.openAppSettings();
      }

      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      _showMessage(
        'Impossible de récupérer votre position.',
      );

      return null;
    }
  }

  Future<void> _applyFilterResult(
    dynamic result,
  ) async {
    Position? newPosition = _userPosition;

    if (result.distanceKm != null) {
      if (_isGettingPosition) {
        return;
      }

      setState(() {
        _isGettingPosition = true;
      });

      try {
        newPosition =
            await _getCurrentPosition();
      } finally {
        if (mounted) {
          setState(() {
            _isGettingPosition = false;
          });
        }
      }

      if (newPosition == null) {
        return;
      }
    } else {
      newPosition = null;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedMinPrice = result.minPrice;
      _selectedMaxPrice = result.maxPrice;
      _selectedCity = result.city;
      _selectedCommune = result.commune;
      _selectedDistanceKm = result.distanceKm;
      _userPosition = newPosition;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedFamily = null;
      _selectedCategory = null;

      _selectedMinPrice = null;
      _selectedMaxPrice = null;

      _selectedCity = null;
      _selectedCommune = null;

      _selectedDistanceKm = null;
      _userPosition = null;

      _selectedSort = 'recent';

      _searchController.clear();
      _searchQuery = '';
    });
  }

  int _readPrice(
    Map<String, dynamic> annonce,
  ) {
    final rawPrice =
        annonce['price']?.toString() ?? '';

    final cleaned = rawPrice
        .replaceAll(' ', '')
        .replaceAll(',', '')
        .replaceAll('.', '');

    return int.tryParse(cleaned) ?? 0;
  }

  bool _isQuote(
    Map<String, dynamic> annonce,
  ) {
    final family =
        annonce['family']?.toString().trim() ?? '';

    final pricingType =
        annonce['pricing_type']?.toString().trim() ?? '';

    return family == 'Prestations de services' &&
        pricingType == 'Sur devis';
  }

  double? _readDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  String _normalize(String? value) {
    return (value ?? '')
        .trim()
        .toLowerCase();
  }

  bool _matchesSearch(
    Map<String, dynamic> annonce,
  ) {
    if (_searchQuery.isEmpty) {
      return true;
    }

    final searchable = [
      annonce['title'],
      annonce['description'],
      annonce['family'],
      annonce['category'],
      annonce['city'],
      annonce['district'],

      // Nouvelles caractéristiques.
      annonce['brand'],
      annonce['model'],
      annonce['manufacture_year'],
      annonce['horsepower'],
      annonce['fuel_type'],
      annonce['mileage'],
      annonce['item_condition'],
      annonce['item_type'],
      annonce['compatible_console'],
      annonce['usage_hours'],
      annonce['pricing_type'],
    ]
        .map(
          (value) => _normalize(
            value?.toString(),
          ),
        )
        .join(' ');

    return searchable.contains(
      _searchQuery,
    );
  }

  bool _matchesFamilyAndCategory(
    Map<String, dynamic> annonce,
  ) {
    final family =
        annonce['family']?.toString().trim() ?? '';

    final category =
        annonce['category']?.toString().trim() ?? '';

    if (_selectedFamily != null &&
        family != _selectedFamily) {
      return false;
    }

    if (_selectedCategory != null &&
        category != _selectedCategory) {
      return false;
    }

    return true;
  }

  double? _distanceKm(
    Map<String, dynamic> annonce,
  ) {
    if (_userPosition == null) {
      return null;
    }

    final latitude =
        _readDouble(
      annonce['latitude'],
    );

    final longitude =
        _readDouble(
      annonce['longitude'],
    );

    if (latitude == null ||
        longitude == null) {
      return null;
    }

    final metres =
        Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      latitude,
      longitude,
    );

    return metres / 1000;
  }

  bool _matchesOtherFilters(
    Map<String, dynamic> annonce,
  ) {
    final price =
        _readPrice(annonce);

    final city =
        annonce['city']?.toString().trim() ?? '';

    final commune =
        annonce['district']?.toString().trim() ?? '';

    final quote =
        _isQuote(annonce);

    // Une prestation "Sur devis" n'a pas de prix
    // comparable. Si un filtre de prix est actif,
    // elle n'est donc pas incluse.
    if ((_selectedMinPrice != null ||
            _selectedMaxPrice != null) &&
        quote) {
      return false;
    }

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

    if (_selectedDistanceKm != null) {
      final distance =
          _distanceKm(annonce);

      if (distance == null) {
        return false;
      }

      if (distance >
          _selectedDistanceKm!) {
        return false;
      }
    }

    return true;
  }

  List<Map<String, dynamic>> _filterAndSort(
    List<Map<String, dynamic>> annonces,
  ) {
    final result =
        annonces.where((annonce) {
      return _matchesSearch(annonce) &&
          _matchesFamilyAndCategory(
            annonce,
          ) &&
          _matchesOtherFilters(
            annonce,
          );
    }).toList();

    switch (_selectedSort) {
      case 'price_asc':
        result.sort((a, b) {
          final aQuote = _isQuote(a);
          final bQuote = _isQuote(b);

          // Les prestations "Sur devis" restent
          // après les annonces ayant un vrai prix.
          if (aQuote && !bQuote) {
            return 1;
          }

          if (!aQuote && bQuote) {
            return -1;
          }

          if (aQuote && bQuote) {
            return 0;
          }

          return _readPrice(a).compareTo(
            _readPrice(b),
          );
        });
        break;

      case 'price_desc':
        result.sort((a, b) {
          final aQuote = _isQuote(a);
          final bQuote = _isQuote(b);

          if (aQuote && !bQuote) {
            return 1;
          }

          if (!aQuote && bQuote) {
            return -1;
          }

          if (aQuote && bQuote) {
            return 0;
          }

          return _readPrice(b).compareTo(
            _readPrice(a),
          );
        });
        break;

      case 'recent':
      default:
        result.sort((a, b) {
          final dateA =
              DateTime.tryParse(
            a['created_at']?.toString() ?? '',
          );

          final dateB =
              DateTime.tryParse(
            b['created_at']?.toString() ?? '',
          );

          if (dateA == null &&
              dateB == null) {
            return 0;
          }

          if (dateA == null) {
            return 1;
          }

          if (dateB == null) {
            return -1;
          }

          return dateB.compareTo(
            dateA,
          );
        });
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
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
          controller: _scrollController,
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
            _buildSearchBar(),

            const SizedBox(height: 20),

            _buildCategorySection(),

            const SizedBox(height: 18),

            _buildFilterRow(),

            if (_selectedDistanceKm != null)
              _buildDistanceInformation(),

            if (_isGettingPosition)
              const Padding(
                padding:
                    EdgeInsets.symmetric(
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Recherche de votre position...',
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            _buildSectionTitle(),

            const SizedBox(height: 8),

            FutureBuilder<
                List<Map<String, dynamic>>>(
              future: _loadAnnonces(),
              builder:
                  (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding:
                        EdgeInsets.all(30),
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

                final annonces =
                    snapshot.data ?? [];

                final annoncesFiltrees =
                    _filterAndSort(
                  annonces,
                );

                if (annoncesFiltrees.isEmpty) {
                  return const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      vertical: 40,
                    ),
                    child: Center(
                      child: Text(
                        'Aucune annonce ne correspond '
                        'à votre recherche.',
                        textAlign:
                            TextAlign.center,
                      ),
                    ),
                  );
                }

                return Column(
                  children:
                      annoncesFiltrees.map(
                    (annonce) {
                      return _buildAnnonceCard(
                        context,
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

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      textInputAction:
          TextInputAction.search,
      decoration: InputDecoration(
        hintText:
            'Que recherchez-vous ? / Olingi nini ?',
        prefixIcon:
            const Icon(
          Icons.search,
        ),
        suffixIcon:
            _searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip:
                        'Effacer la recherche',
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: const Icon(
                      Icons.close,
                    ),
                  ),
        filled: true,
        fillColor:
            Theme.of(context).colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              BorderSide(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(
                  alpha: 0.25,
                ),
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              BorderSide(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(
                  alpha: 0.25,
                ),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              BorderSide(
            width: 1.5,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    final subCategories =
        _selectedFamily == null
            ? <String>[]
            : _categoriesParFamille[
                    _selectedFamily] ??
                <String>[];

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Catégories',
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection:
              Axis.horizontal,
          child: Row(
            children:
                _categoriesParFamille.keys.map(
              (family) {
                return _familyButton(
                  family,
                  _familyIcons[family] ??
                      Icons.category_outlined,
                );
              },
            ).toList(),
          ),
        ),

        if (_selectedFamily != null) ...[
          const SizedBox(height: 14),

          Text(
            _selectedFamily!,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w600,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                subCategories.map(
              (category) {
                return _subCategoryButton(
                  category,
                );
              },
            ).toList(),
          ),
        ],
      ],
    );
  }

  Widget _familyButton(
    String family,
    IconData icon,
  ) {
    final selected =
        _selectedFamily == family;

    return Padding(
      padding:
          const EdgeInsets.only(
        right: 10,
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(14),
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
          width: 92,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 10,
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
                BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(
                    alpha:
                        selected ? 0.8 : 0.2,
                  ),
            ),
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 25,
                color: selected
                    ? Theme.of(context)
                        .colorScheme
                        .onSecondary
                    : Theme.of(context)
                        .colorScheme
                        .primary,
              ),

              const SizedBox(height: 6),

              Text(
                family,
                maxLines: 2,
                textAlign:
                    TextAlign.center,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.15,
                  fontWeight:
                      FontWeight.w600,
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
      ),
    );
  }

  Widget _subCategoryButton(
    String category,
  ) {
    final selected =
        _selectedCategory == category;

    return ChoiceChip(
      label: Text(
        category,
        overflow:
            TextOverflow.ellipsis,
      ),
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
  }

  Widget _buildFilterRow() {
    final screenWidth =
        MediaQuery.of(context).size.width;

    final textScale =
        screenWidth / 400;

    return Row(
      children: [
        Expanded(
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
            initialDistanceKm:
                _selectedDistanceKm,
            onFilter: (result) {
              _applyFilterResult(
                result,
              );
            },
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: OutlinedButton.icon(
            onPressed:
                _resetFilters,
            icon: const Icon(
              Icons.refresh,
              size: 18,
            ),
            label: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Réinitialiser',
              ),
            ),
            style:
                OutlinedButton.styleFrom(
              minimumSize:
                  const Size(
                0,
                42,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceInformation() {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 10,
      ),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(
                alpha: 0.06,
              ),
          borderRadius:
              BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.near_me_outlined,
              size: 18,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                'Annonces à moins de '
                '$_selectedDistanceKm km',
                style: TextStyle(
                  fontSize: 13,
                  color:
                      Theme.of(context)
                          .colorScheme
                          .primary,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    final hasActiveSearchOrFilter =
        _searchQuery.isNotEmpty ||
        _selectedFamily != null ||
        _selectedCategory != null ||
        _selectedMinPrice != null ||
        _selectedMaxPrice != null ||
        _selectedCity != null ||
        _selectedCommune != null ||
        _selectedDistanceKm != null;

    final title = hasActiveSearchOrFilter
        ? 'Résultats'
        : 'Annonces récentes';

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Trier les annonces',
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
                  'Prix croissant',
                ),
              ),
              PopupMenuItem<String>(
                value: 'price_desc',
                child: Text(
                  'Prix décroissant',
                ),
              ),
            ];
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(
                      alpha: 0.25,
                    ),
              ),
            ),
            child: const Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Icon(
                  Icons.sort,
                  size: 18,
                ),
                SizedBox(width: 5),
                Text('Trier'),
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
    final annonceModel =
        Annonce.fromJson(
      annonce,
    );

    final title =
        annonceModel.title.isEmpty
            ? 'Sans titre'
            : annonceModel.title;

    final city =
        annonceModel.city;

    final district =
        annonceModel.district;

    final family =
        annonceModel.family;

    final category =
        annonceModel.category;

    final imageUrl =
        annonceModel.imageUrl;

    final distance =
        _selectedDistanceKm == null
            ? null
            : _distanceKm(
                annonce,
              );

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Material(
        color:
            Theme.of(context)
                .colorScheme
                .surface,
        elevation: 1.5,
        shadowColor:
            Colors.black.withValues(
          alpha: 0.12,
        ),
        borderRadius:
            BorderRadius.circular(14),
        clipBehavior:
            Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    PlaceScreen(
                  annonce:
                      annonceModel,
                ),
              ),
            );
          },
          child: Padding(
            padding:
                const EdgeInsets.all(
              10,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                  child:
                      imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 112,
                              height: 112,
                              fit:
                                  BoxFit.cover,
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
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      minHeight: 112,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          annonceModel
                              .priceLabel,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .w700,
                            color:
                                Theme.of(
                                        context)
                                    .colorScheme
                                    .primary,
                          ),
                        ),

                        if (category.isNotEmpty ||
                            family.isNotEmpty) ...[
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            category.isNotEmpty
                                ? category
                                : family,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],

                        const SizedBox(
                          height: 5,
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .location_on_outlined,
                              size: 15,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Expanded(
                              child: Text(
                                district.isNotEmpty
                                    ? '$city • $district'
                                    : city,
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

                        if (distance !=
                            null) ...[
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons
                                    .near_me_outlined,
                                size: 14,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Text(
                                  '${distance.toStringAsFixed(distance < 10 ? 1 : 0)} km',
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style:
                                      const TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight
                                            .w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(
                        alpha: 0.55,
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
      width: 112,
      height: 112,
      color:
          Colors.grey.shade200,
      alignment:
          Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 34,
        color:
            Colors.grey.shade500,
      ),
    );
  }
}
