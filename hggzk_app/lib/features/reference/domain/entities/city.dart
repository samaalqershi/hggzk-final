/// Describes `City`.
/// العربية: يمثل `City`.
class City {
  /// Keeps the `name` value.
  /// العربية: يخزن القيمة `name`.
  final String name;

  /// Keeps the `country` value.
  /// العربية: يخزن القيمة `country`.
  final String country;

  /// Keeps the `images` value.
  /// العربية: يخزن القيمة `images`.
  final List<String> images;

  /// Builds a new `City` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `City`.
  const City({
    required this.name,
    required this.country,
    this.images = const <String>[],
  });
}
