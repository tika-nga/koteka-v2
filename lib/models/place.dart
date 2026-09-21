import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_marketplace_template/models/category_tags_enums.dart';
import 'package:flutter_marketplace_template/models/date_prop.dart';
import 'package:flutter_marketplace_template/models/menu_class.dart';

/// Ancien modèle Place.
/// Conservé temporairement jusqu'à la suppression complète
/// de l'ancienne architecture.
class Place {
  String id;
  String name;
  String address;
  String profilePicture;
  String desc;
  (int, int)? pricepp;
  MenuClass? menu;
  Category category;
  String phoneNumber;
  String? emailAddress;
  String? urlLink;
  String? igLink;
  String? fbLink;
  LatLng coordinates;
  String? localization;
  double? distance;
  List<String>? tags;
  List<DateProp>? datePropositions;
  bool? isActive;
  DateTime? paidUntil;
  double? rate;
  String? ownerId;
  bool? isNew;

  Place({
    required this.name,
    required this.id,
    required this.address,
    required this.profilePicture,
    required this.desc,
    this.pricepp,
    this.menu,
    required this.category,
    required this.phoneNumber,
    this.emailAddress,
    this.urlLink,
    this.igLink,
    this.fbLink,
    required this.coordinates,
    this.localization,
    this.distance,
    this.tags,
    this.datePropositions,
    this.isActive,
    this.paidUntil,
    this.rate,
    this.ownerId,
    this.isNew,
  }) {
    if (tags != null && tags!.isNotEmpty) {
      final allowed = allowedTags[category];

      if (!tags!.every(
        (tag) => allowed?.contains(tag) ?? false,
      )) {
        throw ArgumentError(
          'Invalid tag(s) for category $category',
        );
      }
    }
  }

  /// Conservé uniquement pour compatibilité avec
  /// l'ancien code Google Maps.
  ///
  /// L'ouverture de PlaceScreen a été supprimée,
  /// car Koteka utilise maintenant Annonce.
  Marker toMarker(
    BuildContext context,
    BitmapDescriptor icon,
  ) {
    return Marker(
      markerId: MarkerId(id),
      position: coordinates,
      icon: icon,
      infoWindow: InfoWindow(
        title: name,
        snippet: address,
      ),
    );
  }

  factory Place.fromJsonRPC(
    Map<String, dynamic> json,
  ) {
    final distance =
        _parseDistance(json['distance_m']);

    return Place(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      address:
          json['address']?.toString() ?? '',
      profilePicture:
          json['profile_picture']?.toString() ??
              '',
      desc: json['desc']?.toString() ?? '',
      pricepp: (
        int.parse(
          json['pricepp_first'].toString(),
        ),
        int.parse(
          json['pricepp_second'].toString(),
        ),
      ),
      menu: MenuClass.fromJson(
        json['menu'],
      ),
      category: Category.values.firstWhere(
        (c) =>
            c.name ==
            json['category'].toString(),
      ),
      phoneNumber:
          json['phone_number']?.toString() ??
              '',
      emailAddress:
          json['email_address']?.toString(),
      urlLink:
          json['url_link']?.toString(),
      igLink:
          json['ig_link']?.toString(),
      fbLink:
          json['fb_link']?.toString(),
      coordinates: LatLng(
        double.parse(
          json['lat'].toString(),
        ),
        double.parse(
          json['lng'].toString(),
        ),
      ),
      localization:
          json['location']?.toString(),
      distance: distance,
      isActive: json['is_active'],
      paidUntil:
          json['paid_until'] != null
              ? DateTime.tryParse(
                  json['paid_until'].toString(),
                )
              : null,
      rate: json['rate'] != null
          ? (json['rate'] as num).toDouble()
          : null,
      ownerId:
          json['owner_id']?.toString(),
      isNew: json['is_new'] ?? false,
      tags: json['tags'] != null
          ? List<String>.from(
              json['tags'],
            )
          : null,
      datePropositions:
          json['date_props'] != null &&
                  json['date_props'].isNotEmpty
              ? List<DateProp>.from(
                  json['date_props'].map(
                    (dp) =>
                        DateProp.fromOneJson(
                      dp,
                    ),
                  ),
                )
              : null,
    );
  }

  factory Place.fromJsonORM(
    Map<String, dynamic> json,
  ) {
    return Place(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      address:
          json['address']?.toString() ?? '',
      profilePicture:
          json['profile_picture']?.toString() ??
              '',
      desc: json['desc']?.toString() ?? '',
      pricepp: (
        int.parse(
          json['pricepp_first'].toString(),
        ),
        int.parse(
          json['pricepp_second'].toString(),
        ),
      ),
      menu: MenuClass.fromJson(
        json['menu'],
      ),
      category: Category.values.firstWhere(
        (c) =>
            c.name ==
            json['category'].toString(),
      ),
      phoneNumber:
          json['phone_number']?.toString() ??
              '',
      emailAddress:
          json['email_address']?.toString(),
      urlLink:
          json['url_link']?.toString(),
      igLink:
          json['ig_link']?.toString(),
      fbLink:
          json['fb_link']?.toString(),
      coordinates: LatLng(
        double.parse(
          json['coordinates_first'].toString(),
        ),
        double.parse(
          json['coordinates_second'].toString(),
        ),
      ),
      localization:
          json['location']?.toString(),
      isActive: json['is_active'],
      paidUntil:
          json['paid_until'] != null
              ? DateTime.tryParse(
                  json['paid_until'].toString(),
                )
              : null,
      rate: json['rate'] != null
          ? (json['rate'] as num).toDouble()
          : null,
      ownerId:
          json['owner_id']?.toString(),
      isNew: json['is_new'] ?? false,
      distance: null,
      tags: json['tags'] != null
          ? List<String>.from(
              json['tags'],
            )
          : null,
      datePropositions:
          json['date_props'] != null &&
                  json['date_props'].isNotEmpty
              ? List<DateProp>.from(
                  json['date_props'].map(
                    (dp) =>
                        DateProp.fromOneJson(
                      dp,
                    ),
                  ),
                )
              : null,
    );
  }
}

double? _parseDistance(
  dynamic distanceM,
) {
  if (distanceM == null) {
    return null;
  }

  final value = distanceM is num
      ? distanceM.toDouble()
      : double.tryParse(
          distanceM.toString(),
        );

  if (value == null) {
    return null;
  }

  return double.parse(
    value.toStringAsFixed(2),
  );
}

extension PlaceExtension on Place {
  static Place placeholder() {
    return Place(
      id: 'placeholder',
      name: 'Loading name',
      address: 'loading place address',
      profilePicture: '',
      desc: '',
      category: Category.cafe,
      phoneNumber: '',
      coordinates:
          const LatLng(0, 0),
    );
  }
}
