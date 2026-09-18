import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_marketplace_template/adapters/place_filter_dialog.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter_marketplace_template/screens/map_screen.dart';
import 'package:flutter_marketplace_template/view_models/filter_view_model.dart';
import 'package:flutter_marketplace_template/view_models/navigation_view_model.dart';
import 'package:flutter_marketplace_template/view_models/places_model.dart';

/// Bouton Filtrer
Widget filterButton(
  BuildContext context,
  double textScale, {
  int? initialMinPrice,
  int? initialMaxPrice,
  String? initialCity,
  String? initialCommune,
  int? initialDistanceKm,
  ValueChanged<KotekaFilterResult>? onFilter,
}) {
  return TextButton(
    onPressed: () async {
      final result = await showPlaceFilterDialog(
        context,
        initialMinPrice: initialMinPrice,
        initialMaxPrice: initialMaxPrice,
        initialCity: initialCity,
        initialCommune: initialCommune,
        initialDistanceKm: initialDistanceKm,
      );

      if (result != null && onFilter != null) {
        onFilter(result);
      }
    },
    style: TextButton.styleFrom(
      backgroundColor:
          Theme.of(context).colorScheme.secondary,
      padding: EdgeInsets.symmetric(
        horizontal: 10 * textScale,
        vertical: 4 * textScale,
      ),
      minimumSize: const Size(0, 36),
      tapTargetSize:
          MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.only(
        left: 10 * textScale,
        right: 10 * textScale,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: 5,
            ),
            child: Transform.rotate(
              angle: 90 * 3.1415926535 / 180,
              child: Icon(
                Icons.tune,
                color: Theme.of(context)
                    .colorScheme
                    .onSecondary,
                size: 22 * textScale,
              ),
            ),
          ),
          Text(
            'Filtrer',
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
        ],
      ),
    ),
  );
}

/// Bouton Réinitialiser
Widget resetFilterButton(
  BuildContext context,
  double textScale, {
  VoidCallback? onReset,
}) {
  final navigationVM =
      context.read<NavigationViewModel>();

  final filterVM =
      context.read<FilterViewModel>();

  final placesModel =
      context.read<PlacesModel>();

  final isMap =
      navigationVM.currentScreen is MapScreen;

  return TextButton(
    onPressed: () async {
      filterVM.resetFilters();

      placesModel.clearPlaces();
      placesModel.clearMarkers();
      placesModel.resetPageNumber();

      if (isMap) {
        filterVM.setOrderBy('distance');
        filterVM.setSortAsc(true);
      }

      await placesModel.fetchFilteredPlaces(
        buildMarkers: isMap,
        context: context,
        getAll: isMap,
      );

      if (onReset != null) {
        onReset();
      }
    },
    style: TextButton.styleFrom(
      backgroundColor:
          Theme.of(context).colorScheme.secondary,
      padding: EdgeInsets.only(
        left: 10 * textScale,
        right: 10 * textScale,
      ),
      minimumSize: const Size(0, 36),
      tapTargetSize:
          MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            right: 5,
          ),
          child: Icon(
            Icons.rotate_left,
            color: Theme.of(context)
                .colorScheme
                .onSecondary,
            size: 24 * textScale,
          ),
        ),
        Text(
          AppLocalizations.of(context)!
              .reset_filters,
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
      ],
    ),
  );
}
