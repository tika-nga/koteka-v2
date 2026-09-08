import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_api_flutter/google_places_api_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_marketplace_template/models/category_tags_enums.dart';
import 'package:flutter_marketplace_template/screens/map_screen.dart';
import 'package:flutter_marketplace_template/view_models/filter_view_model.dart';
import 'package:flutter_marketplace_template/view_models/navigation_view_model.dart';
import 'package:flutter_marketplace_template/view_models/places_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays a dialog for filtering places
Future<void> showPlaceFilterDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: 400, // Możesz dostosować szerokość
            child: SingleChildScrollView(child: Filter()),
          ),
        ),
  );
}

/// Widget for filtering places
class Filter extends StatefulWidget {
  const Filter({super.key});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _maxDistanceController = TextEditingController();
  final _locationController = TextEditingController();
  bool _controllersInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controllersInitialized) {
      final filter = context.read<FilterViewModel>();
      _minPriceController.text = filter.selectedMinPrice?.toString() ?? '';
      _maxPriceController.text = filter.selectedMaxPrice?.toString() ?? '';
      _maxDistanceController.text =
          filter.selectedMaxDistance?.toString() ?? '';
      _locationController.text = filter.selectedLocationName ?? '';
      _controllersInitialized = true;
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _maxDistanceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gmapsKey = dotenv.get('GMAPS_API_KEY', fallback: '');
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = screenWidth / 390;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Consumer<FilterViewModel>(
        builder: (context, filter, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 11),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IgnorePointer(
                      child: Text(
                        AppLocalizations.of(context)!.filter_places,
                        style: TextStyle(
                          fontFamily: 'Mplus1p',
                          fontSize: 24 * textScale,
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
                          size: 30 * textScale,
                        ),
                        child: Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Divider(
                height: 1,
                thickness: 0.5,
                color: Color.fromRGBO(195, 196, 215, 1),
              ),
              // =======================================
              // Filtry tagów po kategoriach
              // =======================================
              if (filter.selectedCategories.isNotEmpty) ...[
                for (Category category in filter.selectedCategories) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.only(left: 11),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.sell_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 22 * textScale,
                          ),
                        ),
                        Text(
                          "${AppLocalizations.of(context)!.tags} (${getCategoryName(context, category)})",
                          style: TextStyle(
                            fontFamily: 'Mplus1p',
                            fontSize: 20 * textScale,
                            letterSpacing: -1,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 11),
                    child: Wrap(
                      spacing: 5.0,
                      runSpacing: -5.0,
                      children: [
                        for (String tag in allowedTags[category] ?? [])
                          FilterChip(
                            labelPadding: EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 0,
                            ),
                            label: Text(
                              getLocalizedTag(context, category, tag),
                              style: TextStyle(
                                fontFamily: 'Mplus1p',
                                fontSize: 14 * textScale,
                                fontWeight: FontWeight.w300,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                            selected: filter.selectedTags.contains(tag),
                            onSelected:
                                (isSelected) =>
                                    filter.toggleTag(isSelected, tag),
                            showCheckmark: false,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            selectedColor:
                                Theme.of(context).colorScheme.tertiary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide.none,
                            ),
                            side: BorderSide.none,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Color.fromRGBO(195, 196, 215, 1),
                  ),
                ],
              ],

              // =======================================
              // Wpisywaczka cen
              // =======================================
              const SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.only(left: 11),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22 * textScale,
                      ),
                    ),
                    Text(
                      '${AppLocalizations.of(context)!.price} (FC)',
                      style: TextStyle(
                        fontFamily: 'Mplus1p',
                        fontSize: 20 * textScale,
                        letterSpacing: -1,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 13, right: 13),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "minimum",
                            style: TextStyle(
                              fontFamily: 'Mplus1p',
                              fontSize: 16 * textScale,
                              fontWeight: FontWeight.w300,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: _minPriceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 8,
                                ),
                                hintText: "0 FC",
                                hintStyle: TextStyle(
                                  fontFamily: 'Mplus1p',
                                  fontSize: 14 * textScale,
                                  fontWeight: FontWeight.w300,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 3,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                final minPrice = int.tryParse(value);
                                filter.setMinPrice(minPrice);
                              },
                              style: TextStyle(
                                fontFamily: 'Mplus1p',
                                fontSize: 14 * textScale,
                                fontWeight: FontWeight.w300,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "maximum",
                            style: TextStyle(
                              fontFamily: 'Mplus1p',
                              fontSize: 16 * textScale,
                              fontWeight: FontWeight.w300,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: _maxPriceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 8,
                                ),
                                hintText: "50 FC",
                                hintStyle: TextStyle(
                                  fontFamily: 'Mplus1p',
                                  fontSize: 14 * textScale,
                                  fontWeight: FontWeight.w300,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 3,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                final maxPrice = int.tryParse(value);
                                filter.setMaxPrice(maxPrice);
                              },
                              style: TextStyle(
                                fontFamily: 'Mplus1p',
                                fontSize: 14 * textScale,
                                fontWeight: FontWeight.w300,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // =======================================
              // Wpisywaczka lokalizacji
              // =======================================
              Padding(
                padding: EdgeInsets.only(left: 7),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 3),
                      child: Icon(
                        Symbols.distance,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22 * textScale,
                      ),
                    ),
                    Text(
                      '${AppLocalizations.of(context)!.distance} (km)',
                      style: TextStyle(
                        fontFamily: 'Mplus1p',
                        fontSize: 20 * textScale,
                        letterSpacing: -1,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: 10),
                child: LocationSelector(
                  gmapsKey: gmapsKey,
                  controller: _locationController,
                ),
              ),

              /*
              PlaceSearchField(
                controller: _locationController,
                apiKey: gmapsKey,
                isLatLongRequired: true, // Fetch lat/long with place details
                //webCorsProxyUrl: "https://cors-anywhere.herokuapp.com",  // Optional for web
                onPlaceSelected: (placeId, latLng) async {
                  if (latLng != null && latLng.result.geometry != null) {
                    context.read<FilterViewModel>().setSelectedLocation(
                      LatLng(
                        latLng.result.geometry!.location.lat,
                        latLng.result.geometry!.location.lng,
                      ),
                      name: latLng.result.name,
                    );
                    print(
                      'Latitude and Longitude: ${context.read<FilterViewModel>().selectedLocation}',
                    );
                  } else {
                    print('NIE UDAŁO SIĘ POBRAĆ WSPÓŁRZĘDNYCH');
                  }
                  //print('Place ID: $placeId');
                },
                decorationBuilder: (context, child) {
                  return Material(
                    type: MaterialType.card,
                    elevation: 4,
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(8),
                    child: child,
                  );
                },
                itemBuilder:
                    (context, prediction) => ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(
                        prediction.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
              ),
*/

              // =======================================
              // Wpisywaczka max odległości
              // =======================================
              Padding(
                padding: EdgeInsets.only(left: 13),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "maximum",
                            style: TextStyle(
                              fontFamily: 'Mplus1p',
                              fontSize: 16 * textScale,
                              fontWeight: FontWeight.w300,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
SizedBox(
  width: 120,
  child: DropdownButtonFormField<int>(
    value: filter.selectedMaxDistance,
    isExpanded: true,
    decoration: InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 8,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 3,
        ),
      ),
    ),
    hint: const Text('Distance'),
    items: List.generate(
      20,
      (index) {
        final km = (index + 1) * 5;
        final meters = km * 1000;

        return DropdownMenuItem<int>(
          value: meters,
          child: Text('$km km'),
        );
      },
    ),
    onChanged: (value) {
  filter.setMaxDistance(value);
},
),
),
],
),
),
],
),
),

              // =======================================
              // // Bouton de filtrage
              // =======================================
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: TextButton(
                    onPressed: () async {
                      if (filter.selectedMaxPrice != null &&
                          filter.selectedMinPrice != null &&
                          filter.selectedMaxPrice! < filter.selectedMinPrice!) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Le prix maximum ne peut pas être inférieur au prix minimum.",
                            ),
                          ),
                        );
                        return;
                      }
                      // jeżeli ustawiono max odległość bez lokalizacji, próbuj pobrać lokalizację użytkownika
                      if (filter.selectedMaxDistance != null &&
                          filter.userLocation == null &&
                          filter.selectedLocation == null) {
                        await context.read<PlacesModel>().updateUserMarker();
                        if (filter.userLocation == null) {
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                          context.read<FilterViewModel>().setExpanded(false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Autorisez l’accès à votre localisation pour utiliser ce filtre.",
                              ),
                            ),
                          );
                        }
                      }
                      // jeżeli ustawiono orderBy na 'distance' bez lokalizacji, odmowa zapytania
                      else if (filter.orderBy == 'distance' &&
                          filter.userLocation == null &&
                          filter.selectedLocation == null) {
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                        context.read<FilterViewModel>().setExpanded(false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                               "Autorisez l’accès à votre localisation pour utiliser ce filtre.",
                            ),
                          ),
                        );
                      }
                      // w p.w. wykonujemy zapytanie do bazy
                      else {
                        final placesModel = context.read<PlacesModel>();
                        final navigationModel =
                            context.read<NavigationViewModel>();
                        final context0 = context;

                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                        filter.setExpanded(false);
                        placesModel.clearPlaces();
                        placesModel.clearMarkers();
                        await placesModel.fetchFilteredPlaces(
                          buildMarkers:
                              navigationModel.currentScreen is MapScreen,
                          context: context0,
                          getAll: navigationModel.currentScreen is MapScreen,
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 5, top: 0, bottom: 0),
                          child: Transform.rotate(
                            angle: 90 * 3.1415926535 / 180,
                            child: Icon(
                              Icons.tune,
                              color: Theme.of(context).colorScheme.onSecondary,
                              size: 22,
                            ),
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.filter,
                          style: TextStyle(
                            fontFamily: 'Mplus1p',
                            fontSize: 16,
                            letterSpacing: -1,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

enum SelectedLocationOption { none, myLocation, customLocation }

class LocationSelector extends StatefulWidget {
  final String gmapsKey;
  final TextEditingController controller;

  const LocationSelector({
    super.key,
    required this.gmapsKey,
    required this.controller,
  });

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  late SelectedLocationOption selectedOption;
  late FilterViewModel filterVM;

  PopupMenuItem<SelectedLocationOption> _locationPopupItem(
    SelectedLocationOption value,
    SelectedLocationOption selected,
    void Function() onTap,
  ) {
    return PopupMenuItem(
      value: value,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (value != selected) const SizedBox(width: 15),
          if (value == selected)
            Icon(
              Icons.check,
              size: 15,
              color: Theme.of(context).colorScheme.primary,
            ),
          const SizedBox(width: 4),
          Text(
            value == SelectedLocationOption.myLocation
                ? AppLocalizations.of(context)!.use_my_location
                : value == SelectedLocationOption.customLocation
                ? AppLocalizations.of(context)!.choose_location
                : AppLocalizations.of(context)!.no_location,
            style: TextStyle(
              fontFamily: 'Mplus1p',
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    filterVM = context.read<FilterViewModel>();
    if (filterVM.searchNearbyUser == true && filterVM.userLocation != null) {
      selectedOption = SelectedLocationOption.myLocation;
    } else if (filterVM.searchNearbyUser == false &&
        filterVM.selectedLocation != null) {
      selectedOption = SelectedLocationOption.customLocation;
    } else {
      selectedOption = SelectedLocationOption.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),

        // ==========================
        // Popup menu, zawsze widoczne
        // ==========================
        PopupMenuButton<SelectedLocationOption>(
          color: Theme.of(context).colorScheme.surface,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          initialValue: selectedOption,
          onSelected: (value) {
            setState(() {
              selectedOption = value;
              //resetowanie custom lokacji, gdy się przełączamy
              if (value != SelectedLocationOption.customLocation) {
                filterVM.clearSelectedLocation();
                widget.controller.text = '';
              }
            });
          },
          itemBuilder:
              (_) => [
                _locationPopupItem(
                  SelectedLocationOption.none,
                  selectedOption,
                  () {
                    filterVM.setSearchNearbyUser(null);
                  },
                ),
                _locationPopupItem(
                  SelectedLocationOption.myLocation,
                  selectedOption,
                  () async {
                    if (filterVM.userLocation == null) {
                      await context.read<PlacesModel>().updateUserMarker();
                      if (filterVM.userLocation == null) {
                        // nie udało się pobrać lokalizacji użytkownika
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Zezwól na dostęp do swojej lokalizacji, aby móc użyć tej opcji.",
                            ),
                          ),
                        );
                        // wróć do poprzedniej opcji
                        setState(() {
                          selectedOption = SelectedLocationOption.none;
                        });
                      } else {
                        filterVM.setSearchNearbyUser(
                          true,
                        ); // to niepotrzebne, bo ustawia się w updateUserMarker, ale daje dla czytelności
                      }
                    } else {
                      filterVM.setSearchNearbyUser(true);
                    }
                  },
                ),
                _locationPopupItem(
                  SelectedLocationOption.customLocation,
                  selectedOption,
                  () {},
                ),
              ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Symbols.keyboard_arrow_down,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                selectedOption == SelectedLocationOption.myLocation
                    ? AppLocalizations.of(context)!.use_my_location
                    : selectedOption == SelectedLocationOption.customLocation
                    ? AppLocalizations.of(context)!.choose_location
                    : AppLocalizations.of(context)!.no_location,
                style: TextStyle(
                  fontFamily: 'Mplus1p',
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ==========================
        // PlaceSearchField, widoczny tylko dla wybranej opcji
        // ==========================
        if (selectedOption == SelectedLocationOption.customLocation)
          PlaceSearchField(
            controller:
                widget
                    .controller, // nazwa jest ustawiana po wykonaniu onPlaceSelected, więc potrzebny niżej WidgetsBinding
            apiKey: widget.gmapsKey,
            isLatLongRequired: true, // Fetch lat/long with place details
            //webCorsProxyUrl: "https://cors-anywhere.herokuapp.com",  // Optional for web
            onPlaceSelected: (placeId, latLng) async {
              if (latLng != null && latLng.result.geometry != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final selectedName =
                      widget.controller.text.isNotEmpty
                          ? widget.controller.text
                          : (latLng.result.name ?? '');
                  // ustaw filtr z nazwą pochodzącą z pola (lokalizowana nazwa)
                  filterVM.setSelectedLocation(
                    LatLng(
                      latLng.result.geometry!.location.lat,
                      latLng.result.geometry!.location.lng,
                    ),
                    name: selectedName,
                  );
                  filterVM.setSearchNearbyUser(false);
                  FocusScope.of(context).unfocus(); // zamknij klawiaturę
                  print(
                    'lokalizacja: ${filterVM.selectedLocation}' +
                        widget.controller.text,
                  );
                });
              } else {
                print('NIE UDAŁO SIĘ POBRAĆ WSPÓŁRZĘDNYCH');
              }
              //print('Place ID: $placeId');
            },
            decorationBuilder: (context, child) {
              return Padding(
                padding: EdgeInsets.only(left: 2, right: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(16, 20, 94, 0.1),
                        blurRadius: 3,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: child,
                ),
              );
            },
            loadingBuilder: (context) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: Theme.of(context).colorScheme.surface,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
            builder: (context, controller, focusNode) {
              return Padding(
                padding: EdgeInsets.only(left: 2, right: 20),
                child: SizedBox(
                  height: 32,
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textAlign: TextAlign.left,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      fontFamily: 'Mplus1p',
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 5),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/marker_pin_06.svg',
                              width: 20,
                              height: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 2,
                              height: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                      hintText:
                          '${AppLocalizations.of(context)!.address}, ${AppLocalizations.of(context)!.place_name}...',
                      hintStyle: TextStyle(
                        fontFamily: 'Mplus1p',
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            itemBuilder:
                (context, prediction) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          prediction.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Mplus1p',
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            emptyBuilder: (context) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  "Brak wyników",
                  style: TextStyle(
                    fontFamily: 'Mplus1p',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        SizedBox(height: 7),
      ],
    );
  }
}
