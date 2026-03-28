import '../../domain/entities/city.dart' as domain;

/// Describes the data model `CityModel`.
/// العربية: يمثل نموذج البيانات `CityModel`.
class CityModel {
  /// Keeps the `name` value.
  /// العربية: يخزن القيمة `name`.
  final String name;

  /// Keeps the `country` value.
  /// العربية: يخزن القيمة `country`.
  final String country;

  /// Keeps the `images` value.
  /// العربية: يخزن القيمة `images`.
  final List<String> images;

  /// Builds a new `CityModel` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `CityModel`.
  const CityModel({
    required this.name,
    required this.country,
    this.images = const <String>[],
  });

  /// Builds a new `CityModel.fromJson` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `CityModel.fromJson`.
  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ??
          const <String>[],
    );
  }

  /// Converts this instance to a JSON representation.
  /// العربية: يحول هذا الكائن إلى تمثيل JSON.
  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'images': images,
      };

  domain.City toEntity() =>
      domain.City(name: name, country: country, images: images);
}
