import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_marketplace_template/adapters/place_notice.dart';
import 'package:flutter_marketplace_template/functions.dart';
import 'package:flutter_marketplace_template/screens/place_screen.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter_marketplace_template/view_models/filter_view_model.dart';
import 'package:flutter_marketplace_template/view_models/places_model.dart';
import 'package:flutter_marketplace_template/models/place.dart';
import 'package:flutter_marketplace_template/views/components/filter_buttons.dart';
import 'package:flutter_marketplace_template/adapters/app_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_marketplace_template/views/components/search_text_field.dart';

/// Home screen displaying a list of places with filtering and sorting options
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String selectedSortOption = 'default';

  /// Function to handle scroll events for infinite scrolling
  void onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<PlacesModel>().fetchFilteredPlaces(
        buildMarkers: false,
        context: context,
      );
    }
  }

  @override
  void initState() {
    _scrollController.addListener(onScroll);

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFirstFetch();
    });
  }

  Future<void> _initFirstFetch() async {
    final homeVM = context.read<PlacesModel>();
    // If a fetch is already in progress, attach and wait for it to finish
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
    String? order = filterVM.orderBy;
    bool? asc = filterVM.sortAsc;
    // restoring previous sorting after exiting the map
    if (order != null && asc != null) {
      selectedSortOption = '${order}_${asc == true ? 'asc' : 'desc'}';
    } else {
      selectedSortOption = 'default';
    }
    // first fetch of places with correct sorting
    homeVM.clearPlaces();
    homeVM.clearMarkers();
    homeVM.fetchFilteredPlaces(buildMarkers: false, context: context);
  }

  @override
  void dispose() {
    _scrollController.removeListener(onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final languageViewModel = context.read<LanguageViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = screenWidth / 400;
    // String selectedLanguage =
    //     Localizations.localeOf(context).languageCode == 'fr'
    //         ? 'French'
    //         : 'English';
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(showTitle: true, showMenu: true),
      body: Consumer<PlacesModel>(
        builder:
            (context, homeViewModel, _) => Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 18, right: 18),
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 20,
                    ),
                    children: [
                      // Section for filtering places
                      Padding(
                        padding: EdgeInsets.only(top: 14, bottom: 6),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                              top: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
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
                                  padding: EdgeInsets.only(left: 9),
                                  child: Text(
                                    'Que recherchez-vous ? / Olingi nini ?',
                                    style: TextStyle(
                                      fontFamily: 'Mplus1p',
                                      fontSize: 20 * textScale,
                                      letterSpacing: -1,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

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
      _categoryChip('Pièces automobiles', Icons.car_repair),
      _categoryChip('Motos', Icons.two_wheeler),
      _categoryChip('Pièces motos', Icons.build),
      _categoryChip('Meubles', Icons.chair),
      _categoryChip('Vélos', Icons.pedal_bike),
      _categoryChip('Divers', Icons.category),
    ],
  ),
),
                                Divider(
                                  height: 5,
                                  thickness: 0.5,
                                  color: const Color.fromRGBO(195, 196, 215, 1),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 12 * textScale,
                                    top: 10,
                                    bottom: 15,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.search,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            size: 18 * textScale,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            'Rechercher une annonce / Luka eloko',
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
                                          hintText: 'Ex. téléphone, voiture, meuble...',
                                          primaryColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
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
                                            await placesModel
                                                .fetchFilteredPlaces(
                                                  buildMarkers: false,
                                                  context: context,
                                                );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  height: 5,
                                  thickness: 0.5,
                                  color: const Color.fromRGBO(195, 196, 215, 1),
                                ),

                                /// Filter buttons section
                                Padding(
                                  padding: EdgeInsets.only(top: 14, bottom: 6),
                                  child: Center(
                                    child: filterButton(context, textScale),
                                  ),
                                ),

                                /// Action bar: reset filters and sorting menu
                                _buildActionBar(context),

                                Divider(
                                  height: 5,
                                  thickness: 0.5,
                                  color: const Color.fromRGBO(195, 196, 215, 1),
                                ),
                                const SizedBox(height: 10),

                                /// List of places
                                Consumer<PlacesModel>(
                                  builder: (context, homeViewModel, _) {
                                    final isFetching = homeViewModel.isLoading;
                                    final loadedPlaces = homeViewModel.places;

                                    // placeholders for the next ones that are still loading
                                    final placeholders =
                                        isFetching
                                            ? List.generate(
                                              5,
                                              (_) =>
                                                  PlaceExtension.placeholder(),
                                            )
                                            : [];

                                    // combine both lists
                                    final displayPlaces = [
                                      ...loadedPlaces,
                                      ...placeholders,
                                    ];

                                    return ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: displayPlaces.length,
                                      itemBuilder: (context, index) {
                                        final place = displayPlaces[index];

                                        // if it's a placeholder, wrap in Skeletonizer
                                        if (place.id == 'placeholder') {
                                          return Skeletonizer(
                                            enabled: true,
                                            effect: ShimmerEffect(),
                                            child: PlaceNotice(
                                              place: place,
                                              screenWidth: 200,
                                            ),
                                          );
                                        }

                                        // normal place
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => PlaceScreen(
                                                      place: place,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: PlaceNotice(
                                            place: place,
                                            screenWidth: 200,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  /// Builds the action bar with reset filters button and sorting menu
  Widget _buildActionBar(BuildContext context) {
    final filterViewModel = context.read<FilterViewModel>();
    final homeViewModel = context.read<PlacesModel>();

    final screenWidth = MediaQuery.of(context).size.width;
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
          // Reset filters to default values
          resetFilterButton(
            context,
            textScale,
            onReset:
                () => setState(() {
                  selectedSortOption = 'default';
                  _searchController.clear();
                }),
          ),
          // Dropdown menu for sorting listings
          PopupMenuButton<String>(
            constraints: BoxConstraints(maxWidth: 190),
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
              // if conditions match, call fetchFilteredPlaces
              if (filterViewModel.orderBy != 'distance' ||
                  (filterViewModel.searchNearbyUser == false &&
                      filterViewModel.selectedLocation != null) ||
                  (filterViewModel.searchNearbyUser == true &&
                      filterViewModel.userLocation != null)) {
                homeViewModel.fetchFilteredPlaces(
                  buildMarkers: false,
                  context: context,
                );
              }
            },
            color: Theme.of(context).colorScheme.surface,
            elevation: 8,
            shadowColor: Color.fromRGBO(16, 20, 94, 0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'close',
                    enabled: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IgnorePointer(
                              child: Text(
                                AppLocalizations.of(context)!.sort,
                                style: TextStyle(
                                  fontFamily: 'Mplus1p',
                                  fontSize: 16 * textScale,
                                  letterSpacing: -1,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: IconTheme(
                                data: IconThemeData(
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20 * textScale,
                                ),
                                child: Icon(Icons.close),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Color.fromRGBO(195, 196, 215, 1),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'default',
                    child: Center(
                      child: Container(
                        width: 158,
                        height: 36,
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selectedSortOption == 'default'
                                  ? Theme.of(context).colorScheme.tertiary
                                  : Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.default_sort,
                                style: TextStyle(
                                  fontFamily: 'Mplus1p',
                                  fontSize: 16 * textScale,
                                  letterSpacing: -1,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'price_asc',
                    child: Center(
                      child: Container(
                        width: 158,
                        height: 36,
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selectedSortOption == 'price_asc'
                                  ? Theme.of(context).colorScheme.tertiary
                                  : Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.highest_price,
                                style: TextStyle(
                                  fontFamily: 'Mplus1p',
                                  fontSize: 16 * textScale,
                                  letterSpacing: -1,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'price_desc',
                    child: Center(
                      child: Container(
                        width: 158,
                        height: 36,
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selectedSortOption == 'price_desc'
                                  ? Theme.of(context).colorScheme.tertiary
                                  : Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.lowest_price,
                                style: TextStyle(
                                  fontFamily: 'Mplus1p',
                                  fontSize: 16 * textScale,
                                  letterSpacing: -1,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'distance_asc',
                    child: Center(
                      child: Container(
                        width: 158,
                        height: 36,
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selectedSortOption == 'distance_asc'
                                  ? Theme.of(context).colorScheme.tertiary
                                  : Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.highest_distance,
                                style: TextStyle(
                                  fontFamily: 'Mplus1p',
                                  fontSize: 16 * textScale,
                                  letterSpacing: -1,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'distance_desc',
                    child: Center(
                      child: Container(
                        width: 158,
                        height: 36,
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                          bottom: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selectedSortOption == 'distance_desc'
                                  ? Theme.of(context).colorScheme.tertiary
                                  : Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.lowest_distance,
                                style: TextStyle(
                                  fontFamily: 'Mplus1p',
                                  fontSize: 16 * textScale,
                                  letterSpacing: -1,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
            child: Container(
              width: 135 * textScale,
              height: 36,
              padding: EdgeInsets.only(
                left: 10 * textScale,
                right: 10 * textScale,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 0,
                        right: 5,
                        top: 0,
                        bottom: 0,
                      ),
                      child: Icon(
                        Icons.sort,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 24 * textScale,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.sort,
                      style: TextStyle(
                        fontFamily: 'Mplus1p',
                        fontSize: 16 * textScale,
                        letterSpacing: -1,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _categoryChip(String label, IconData icon) {
  return Container(
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
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    ),
    );
}
}
