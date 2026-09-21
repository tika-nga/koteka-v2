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
  });

  factory Annonce.fromJson(Map<String, dynamic> json) {
    return Annonce(
      id: _readInt(json['id']),
      title: json['title']?.toString().trim() ?? '',
      price: _readPrice(json['price']),
      city: json['city']?.toString().trim() ?? '',
      district: json['district']?.toString().trim() ?? '',
      description: json['description']?.toString().trim() ?? '',
      family: json['family']?.toString().trim() ?? '',
      category: json['category']?.toString().trim() ?? '',
      imageUrl: json['imageUrl']?.toString().trim() ?? '',
      latitude: _readDouble(json['latitude']),
      longitude: _readDouble(json['longitude']),
      createdAt: DateTime.tryParse(
        json['created_at']?.toString() ?? '',
      ),
      userId: json['user_id']?.toString(),
    );
  }

  String get location {
    if (city.isEmpty) {
      return district;
    }

    if (district.isEmpty) {
      return city;
    }

    return '$city, $district';
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _readPrice(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    final cleaned = (value?.toString() ?? '')
        .replaceAll(' ', '')
        .replaceAll(',', '')
        .replaceAll('.', '');

    return int.tryParse(cleaned) ?? 0;
  }

  static double? _readDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}
