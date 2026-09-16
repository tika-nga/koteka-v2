import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_marketplace_template/functions.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter_marketplace_template/view_models/filter_view_model.dart';
import 'package:flutter_marketplace_template/view_models/places_model.dart';
import 'package:flutter_marketplace_template/views/components/filter_buttons.dart';
import 'package:flutter_marketplace_template/adapters/app_bar.dart';
import 'package:flutter_marketplace_template/views/components/search_text_field.dart';

/// Home screen displaying a list of places with filtering and sorting options
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String selectedSortOption = 'default';

  void onScroll() {
  // Désactivé temporairement :
  // les annonces Koteka sont déjà chargées depuis Supabase
  // par le FutureBuilder.
}

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFirstFetch();
    });
  }

  Future<void> _initFirstFetch() async {
    final homeVM = context.read<PlacesModel>();

    if (homeVM.isLoading) {
      late VoidCallback sub;

      sub = () async {
        if (!homeVM.isLoading) {
          homeVM.removeListener(sub);

          if (!mounted) return;

          await _firstFetch();
        }
      };

      homeVM.addListener(sub);
    } else {
      await _firstFetch();
    }
  }

  Future<void> _firstFetch() async {
    final homeVM = context.read<PlacesModel>();
    final filterVM = context.read<FilterViewModel>();

    final String? order = filterVM.orderBy;
    final bool? asc = filterVM.sortAsc;

    if (order != null && asc != null) {
      selectedSortOption = '${order}_${asc ? 'asc' : 'desc'}';
    } else {
      selectedSortOption = 'default';
    }

    homeVM.clearPlaces();
    homeVM.clearMarkers();

    await homeVM.fetchFilteredPlaces(
      buildMarkers: false,
      context: context,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = screenWidth / 400;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        showTitle: true,
        showMenu: true,
      ),
      body: Consumer<PlacesModel>(
        builder: (context, homeViewModel, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 20,
                bottom: 30,
              ),
              children: [
                Container(
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
                        color: Color.fromRGBO(16, 20, 94, 0.25),
                        blurRadius: 3,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 9),
                        child: Text(
                          'Que recherchez-vous ? / Olingi nini ?',
                          style: TextStyle(
                            fontFamily: 'Mplus1p',
                            fontSize: 18 * textScale,
                            letterSpacing: -1,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Divider(
                        height: 5,
                        thickness: 0.5,
                        color: Color.fromRGBO(195, 196, 215, 1),
                      ),

                      Padding(
                        padding: EdgeInsets.only(
                          left: 12 * textScale,
                          top: 10,
                          bottom: 15,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  size: 18 * textScale,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    'Rechercher une annonce / Luka eloko',
                                    style: TextStyle(
                                      fontFamily: 'Mplus1p',
                                      fontSize: 16 * textScale,
                                      letterSpacing: -1,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Padding(
                              padding: EdgeInsets.only(
                                right: 15 * textScale,
                              ),
                              child: SearchByNameField(
                                controller: _searchController,
                                textScale: 1,
                                hintText:
                                    'Ex. téléphone, voiture, meuble...',
                                primaryColor:
                                    Theme.of(context).colorScheme.primary,
                                onSubmitted: (value) async {
                                  final filter =
                                      context.read<FilterViewModel>();

                                  filter.resetFilters();
                                  filter.setSearchByNameQuery(value);

                                  final placesModel =
                                      context.read<PlacesModel>();

                                  filter.setExpanded(false);
                                  placesModel.clearPlaces();
                                  placesModel.clearMarkers();

                                  await placesModel.fetchFilteredPlaces(
                                    buildMarkers: false,
                                    context: context,
                                  );
                                },
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

                            const SizedBox(height: 10),

                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _categoryChip(
                                    'Voitures',
                                    Icons.directions_car,
                                  ),
                                  _categoryChip(
                                    'Pièces automobiles',
                                    Icons.car_repair,
                                  ),
                                  _categoryChip(
                                    'Motos',
                                    Icons.two_wheeler,
                                  ),
                                  _categoryChip(
                                    'Pièces motos',
                                    Icons.build,
                                  ),
                                  _categoryChip(
                                    'Meubles',
                                    Icons.chair,
                                  ),
                                  _categoryChip(
                                    'Vélos',
                                    Icons.pedal_bike,
                                  ),
                                  _categoryChip(
                                    'Divers',
                                    Icons.category,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(
                        height: 5,
                        thickness: 0.5,
                        color: Color.fromRGBO(195, 196, 215, 1),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                          top: 14,
                          bottom: 6,
                        ),
                        child: Center(
                          child: filterButton(
                            context,
                            textScale,
                          ),
                        ),
                      ),

                      _buildActionBar(context),

                      const Divider(
                        height: 5,
                        thickness: 0.5,
                        color: Color.fromRGBO(195, 196, 215, 1),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                /// Liste des annonces Koteka depuis Supabase
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: Supabase.instance.client
                      .from('annonces')
                      .select()
                      .order(
                        'createdAt',
                        ascending: false,
                      ),
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

                    if (annonces.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: Text(
                            'Aucune annonce disponible pour le moment.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics:
                          const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: annonces.length,
                      itemBuilder: (context, index) {
                        final annonce = annonces[index];

                        final title =
                            annonce['title']?.toString() ??
                                'Sans titre';

                        final price =
                            annonce['price']?.toString() ?? '';

                        final city =
                            annonce['city']?.toString() ?? '';

                        final district =
                            annonce['district']?.toString() ?? '';

                        final imageUrl =
    annonce['ImageUrl']?.toString() ??
    annonce['imageUrl']?.toString() ??
    '';

                        return InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceScreen(
          place: Place.fromJson(annonce),
        ),
      ),
    );
  },
  child: Card(
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
                                            return Container(
                                              width: 120,
                                              height: 120,
                                              color: Colors
                                                  .grey.shade200,
                                              child: const Icon(
                                                Icons
                                                    .image_not_supported,
                                                size: 40,
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          width: 120,
                                          height: 120,
                                          color:
                                              Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.image,
                                            size: 40,
                                          ),
                                        ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style:
                                            const TextStyle(
                                          fontSize: 17,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        '$price FC',
                                        style:
                                            const TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        district.isNotEmpty
                                            ? '$city • $district'
                                            : city,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _categoryChip(
    String label,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () async {
        final filter =
            context.read<FilterViewModel>();

        final placesModel =
            context.read<PlacesModel>();

        filter.resetFilters();
        filter.setSearchByNameQuery(label);

        placesModel.clearPlaces();
        placesModel.clearMarkers();

        await placesModel.fetchFilteredPlaces(
          buildMarkers: false,
          context: context,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color:
                  Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color:
                    Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the action bar with reset filters button and sorting menu
  Widget _buildActionBar(BuildContext context) {
    final filterViewModel =
        context.read<FilterViewModel>();

    final homeViewModel =
        context.read<PlacesModel>();

    final screenWidth =
        MediaQuery.of(context).size.width;

    final textScale = screenWidth / 393;

    return Padding(
      padding: EdgeInsets.only(
        left: 10 * textScale,
        right: 10 * textScale,
        bottom: 10,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 5,
        runSpacing: 8,
        children: [
          resetFilterButton(
            context,
            textScale,
            onReset: () {
              setState(() {
                selectedSortOption = 'default';
                _searchController.clear();
              });
            },
          ),

          PopupMenuButton<String>(
            constraints:
                const BoxConstraints(maxWidth: 190),
            padding: EdgeInsets.zero,
            onSelected: (String value) async {
              setState(() {
                selectedSortOption = value;
              });

              switch (value) {
                case 'default':
                  homeViewModel.clearPlaces();
                  homeViewModel.clearMarkers();
                  filterViewModel.setOrderBy(null);
                  filterViewModel.setSortAsc(null);
                  break;

                case 'price_asc':
                  filterViewModel.setOrderBy('price');
                  filterViewModel.setSortAsc(true);
                  homeViewModel.clearPlaces();
                  homeViewModel.clearMarkers();
                  break;

                case 'price_desc':
                  filterViewModel.setOrderBy('price');
                  filterViewModel.setSortAsc(false);
                  homeViewModel.clearPlaces();
                  homeViewModel.clearMarkers();
                  break;

                case 'distance_asc':
                  if (await checkAndShowUserLocationPermissionDenied(
                    filterVM: filterViewModel,
                    placesModel: homeViewModel,
                    context: context,
                  )) {
                    return;
                  }

                  filterViewModel.setOrderBy('distance');
                  filterViewModel.setSortAsc(true);
                  homeViewModel.clearPlaces();
                  homeViewModel.clearMarkers();
                  break;

                case 'distance_desc':
                  if (await checkAndShowUserLocationPermissionDenied(
                    filterVM: filterViewModel,
                    placesModel: homeViewModel,
                    context: context,
                  )) {
                    return;
                  }

                  filterViewModel.setOrderBy('distance');
                  filterViewModel.setSortAsc(false);
                  homeViewModel.clearPlaces();
                  homeViewModel.clearMarkers();
                  break;
              }

              if (filterViewModel.orderBy != 'distance' ||
                  (filterViewModel.searchNearbyUser ==
                          false &&
                      filterViewModel.selectedLocation !=
                          null) ||
                  (filterViewModel.searchNearbyUser ==
                          true &&
                      filterViewModel.userLocation !=
                          null)) {
                await homeViewModel.fetchFilteredPlaces(
                  buildMarkers: false,
                  context: context,
                );
              }
            },
            color:
                Theme.of(context).colorScheme.surface,
            elevation: 8,
            shadowColor:
                const Color.fromRGBO(16, 20, 94, 0.25),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(8),
            ),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'close',
                enabled: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.sort,
                          style: TextStyle(
                            fontFamily: 'Mplus1p',
                            fontSize:
                                16 * textScale,
                            letterSpacing: -1,
                            fontWeight:
                                FontWeight.w500,
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.close,
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                            size: 20 * textScale,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Divider(
                      height: 1,
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
              ),

              _sortMenuItem(
                context,
                value: 'default',
                text:
                    AppLocalizations.of(context)!
                        .default_sort,
                textScale: textScale,
              ),

              _sortMenuItem(
                context,
                value: 'price_asc',
                text:
                    AppLocalizations.of(context)!
                        .highest_price,
                textScale: textScale,
              ),

              _sortMenuItem(
                context,
                value: 'price_desc',
                text:
                    AppLocalizations.of(context)!
                        .lowest_price,
                textScale: textScale,
              ),

              _sortMenuItem(
                context,
                value: 'distance_asc',
                text:
                    AppLocalizations.of(context)!
                        .highest_distance,
                textScale: textScale,
              ),

              _sortMenuItem(
                context,
                value: 'distance_desc',
                text:
                    AppLocalizations.of(context)!
                        .lowest_distance,
                textScale: textScale,
              ),
            ],
            child: Container(
              width: 135 * textScale,
              height: 36,
              padding: EdgeInsets.symmetric(
                horizontal: 10 * textScale,
              ),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.secondary,
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sort,
                    color: Theme.of(context)
                        .colorScheme
                        .onSecondary,
                    size: 24 * textScale,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.sort,
                      style: TextStyle(
                        fontFamily: 'Mplus1p',
                        fontSize: 16 * textScale,
                        letterSpacing: -1,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _sortMenuItem(
    BuildContext context, {
    required String value,
    required String text,
    required double textScale,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Center(
        child: Container(
          width: 158,
          height: 36,
          alignment: Alignment.center,
          padding:
              const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: selectedSortOption == value
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context)
                    .colorScheme
                    .secondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Mplus1p',
              fontSize: 16 * textScale,
              letterSpacing: -1,
              fontWeight: FontWeight.w500,
              color: Theme.of(context)
                  .colorScheme
                  .onSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
