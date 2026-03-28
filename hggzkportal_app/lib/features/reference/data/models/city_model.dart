import '../../domain/entities/city.dart' as domain;

/// يعرّف الكلاس `CityModel`.
/// Describes the `CityModel` class.
class CityModel {
  /// Holds the `name` value.
  /// العربية: يخزن القيمة `name`.
  final String name;

  /// يخزن العضو `country`.
  /// Holds the `country` member.
  final String country;

  /// يخزن العضو `images`.
  /// Holds the `images` member.
  final List<String> images;

  /// ينشئ مثيلاً من `CityModel`.
  /// Builds an instance of `CityModel`.
  const CityModel({
    required this.name,
    required this.country,
    this.images = const <String>[],
  });

  /// ينشئ مثيلاً من `CityModel`.
  /// Builds an instance of `CityModel`.
  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ??
          const <String>[],
    );
  }

  /// ينفذ العملية `toJson`.
  /// Runs the `toJson` operation.
  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'images': images,
      };

  domain.City toEntity() =>
      domain.City(name: name, country: country, images: images);
}
