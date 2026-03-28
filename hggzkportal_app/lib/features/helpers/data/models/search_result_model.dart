import '../../domain/entities/search_result.dart';

/// يعرّف الكلاس `SearchResultModel`.
/// Describes the `SearchResultModel` class.
class SearchResultModel<T> extends SearchResult<T> {
  /// Initializes a new `SearchResultModel` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `SearchResultModel`.
  const SearchResultModel({
    required T item,
    required String id,
    required String title,
    required String subtitle,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) : super(
          item: item,
          id: id,
          title: title,
          subtitle: subtitle,
          imageUrl: imageUrl,
          metadata: metadata,
        );

  /// ينشئ مثيلاً من `SearchResultModel`.
  /// Builds an instance of `SearchResultModel`.
  factory SearchResultModel.fromJson(
    Map<String, dynamic> json,
    T item,
  ) {
    return SearchResultModel<T>(
      item: item,
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      imageUrl: json['imageUrl'],
      metadata: json['metadata'],
    );
  }

  /// ينفذ العملية `toJson`.
  /// Runs the `toJson` operation.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }
}
