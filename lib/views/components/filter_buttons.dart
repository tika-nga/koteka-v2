import 'package:flutter/material.dart';

import 'package:flutter_marketplace_template/adapters/place_filter_dialog.dart';

/// Bouton de filtrage Koteka.
///
/// Il ouvre la fenêtre de filtres et renvoie le résultat
/// à l'écran qui l'utilise.
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

/// Bouton de réinitialisation Koteka.
///
/// Il ne dépend plus de PlacesModel, FilterViewModel
/// ni de l'ancienne carte Google Maps.
Widget resetFilterButton(
  BuildContext context,
  double textScale, {
  VoidCallback? onReset,
}) {
  return TextButton(
    onPressed: onReset,
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
          'Réinitialiser',
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
