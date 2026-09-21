import 'package:flutter/material.dart';
import 'package:flutter_marketplace_template/models/place.dart';

/// Ancienne carte conservée temporairement pour compatibilité.
/// Elle sera supprimée avec l'ancien système Place.
class PlaceNotice extends StatelessWidget {
  final Place place;
  final double screenWidth;

  const PlaceNotice({
    super.key,
    required this.place,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final textScale = width / 400;

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: width,
        height: 144,
        child: Row(
          children: [
            SizedBox(
              width: 140,
              height: 144,
              child: place.profilePicture.isNotEmpty
                  ? Image.network(
                      place.profilePicture,
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

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Mplus1p',
                        fontSize: 16 * textScale,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (place.address.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              place.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Mplus1p',
                                fontSize: 12 * textScale,
                              ),
                            ),
                          ),
                        ],
                      ),

                    const Spacer(),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .account_balance_wallet_outlined,
                          size: 17,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            place.pricepp != null
                                ? '${place.pricepp!.$1} FC'
                                : 'Prix non renseigné',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Mplus1p',
                              fontSize: 14 * textScale,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 38,
        color: Colors.grey.shade500,
      ),
    );
  }
}
