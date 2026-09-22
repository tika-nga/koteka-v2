class Annonce {
  final int id;
  final String title;
  final int price;
  final String city;
  final String district;
  final String description;
  final String family;
  final String category;
  final String imageUrl;

  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final String? userId;

  final String? brand;
  final String? model;
  final int? manufactureYear;
  final int? horsepower;
  final String? fuelType;
  final int? mileage;
  final String? itemCondition;
  final String? itemType;
  final String? compatibleConsole;
  final int? usageHours;
  final String? pricingType;

  final DateTime? expiresAt;
  final DateTime? renewedAt;
  final int renewalCount;

  final int priceDropCount;
  final DateTime? lastPriceDropAt;

  final bool isActive;

  final bool promotionActive;
  final DateTime? promotionStartedAt;
  final DateTime? promotionExpiresAt;

  const Annonce({
    required this.id,
    required this.title,
    required this.price,
    required this.city,
    required this.district,
    required this.description,
    required this.family,
    required this.category,
    required this.imageUrl,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.userId,
    this.brand,
    this.model,
    this.manufactureYear,
    this.horsepower,
    this.fuelType,
    this.mileage,
    this.itemCondition,
    this.itemType,
    this.compatibleConsole,
    this.usageHours,
    this.pricingType,
    this.expiresAt,
    this.renewedAt,
    this.renewalCount = 0,
    this.priceDropCount = 0,
    this.lastPriceDropAt,
    this.isActive = true,
    this.promotionActive = false,
    this.promotionStartedAt,
    this.promotionExpiresAt,
  });

  bool get isService =>
      family.trim().toLowerCase() ==
      'prestations de services';

  bool get isQuote =>
      isService &&
      pricingType
              ?.trim()
              .toLowerCase() ==
          'sur devis';

  String get priceLabel {
    if (isQuote) {
      return 'Sur devis';
    }

    return '$price FC';
  }

  String get location {
    final values = [
      city.trim(),
      district.trim(),
    ].where(
      (value) => value.isNotEmpty,
    );

    return values.join(' • ');
  }

  factory Annonce.fromJson(
    Map<String, dynamic> json,
  ) {
    return Annonce(
      id: _readInt(json['id']),
      title:
          json['title']?.toString() ??
              '',
      price:
          _readInt(json['price']),
      city:
          json['city']?.toString() ??
              '',
      district:
          json['district']
                  ?.toString() ??
              '',
      description:
          json['description']
                  ?.toString() ??
              '',
      family:
          json['family']?.toString() ??
              '',
      category:
          json['category']
                  ?.toString() ??
              '',
      imageUrl:
          json['imageUrl']
                  ?.toString() ??
              '',
      latitude:
          _readNullableDouble(
        json['latitude'],
      ),
      longitude:
          _readNullableDouble(
        json['longitude'],
      ),
      createdAt:
          _readDateTime(
        json['created_at'],
      ),
      userId:
          json['user_id']?.toString(),
      brand:
          _readNullableString(
        json['brand'],
      ),
      model:
          _readNullableString(
        json['model'],
      ),
      manufactureYear:
          _readNullableInt(
        json['manufacture_year'],
      ),
      horsepower:
          _readNullableInt(
        json['horsepower'],
      ),
      fuelType:
          _readNullableString(
        json['fuel_type'],
      ),
      mileage:
          _readNullableInt(
        json['mileage'],
      ),
      itemCondition:
          _readNullableString(
        json['item_condition'],
      ),
      itemType:
          _readNullableString(
        json['item_type'],
      ),
      compatibleConsole:
          _readNullableString(
        json['compatible_console'],
      ),
      usageHours:
          _readNullableInt(
        json['usage_hours'],
      ),
      pricingType:
          _readNullableString(
        json['pricing_type'],
      ),
      expiresAt:
          _readDateTime(
        json['expires_at'],
      ),
      renewedAt:
          _readDateTime(
        json['renewed_at'],
      ),
      renewalCount:
          _readInt(
        json['renewal_count'],
      ),
      priceDropCount:
          _readInt(
        json['price_drop_count'],
      ),
      lastPriceDropAt:
          _readDateTime(
        json['last_price_drop_at'],
      ),
      isActive:
          _readBool(
        json['is_active'],
        fallback: true,
      ),
      promotionActive:
          _readBool(
        json['promotion_active'],
      ),
      promotionStartedAt:
          _readDateTime(
        json['promotion_started_at'],
      ),
      promotionExpiresAt:
          _readDateTime(
        json['promotion_expires_at'],
      ),
    );
  }

  static int _readInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    final text =
        value?.toString().trim() ??
            '';

    if (text.isEmpty) {
      return 0;
    }

    return int.tryParse(
          text
              .replaceAll(' ', '')
              .replaceAll(',', '')
              .replaceAll('.', ''),
        ) ??
        0;
  }

  static int? _readNullableInt(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    final text =
        value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return int.tryParse(
      text
          .replaceAll(' ', '')
          .replaceAll(',', '')
          .replaceAll('.', ''),
    );
  }

  static double?
      _readNullableDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    final text =
        value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return double.tryParse(
      text.replaceAll(',', '.'),
    );
  }

  static String?
      _readNullableString(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final text =
        value.toString().trim();

    return text.isEmpty
        ? null
        : text;
  }

  static DateTime? _readDateTime(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  static bool _readBool(
    dynamic value, {
    bool fallback = false,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final text =
        value
            .toString()
            .trim()
            .toLowerCase();

    if (text == 'true' ||
        text == '1') {
      return true;
    }

    if (text == 'false' ||
        text == '0') {
      return false;
    }

    return fallback;
  }
}
