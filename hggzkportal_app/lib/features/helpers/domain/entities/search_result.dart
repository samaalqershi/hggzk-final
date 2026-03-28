import 'package:equatable/equatable.dart';

/// يعرّف الكلاس `SearchResult`.
/// Describes the `SearchResult` class.
class SearchResult<T> extends Equatable {
  /// Holds the `item` value.
  /// العربية: يخزن القيمة `item`.
  final T item;

  /// يخزن العضو `id`.
  /// Holds the `id` member.
  final String id;

  /// يخزن العضو `title`.
  /// Holds the `title` member.
  final String title;

  /// يخزن العضو `subtitle`.
  /// Holds the `subtitle` member.
  final String subtitle;

  /// يخزن العضو `imageUrl`.
  /// Holds the `imageUrl` member.
  final String? imageUrl;

  /// يخزن العضو `metadata`.
  /// Holds the `metadata` member.
  final Map<String, dynamic>? metadata;

  /// ينشئ مثيلاً من `SearchResult`.
  /// Builds an instance of `SearchResult`.
  const SearchResult({
    required this.item,
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.metadata,
  });

  /// يعيد قيمة `props`.
  /// Exposes the `props` value.
  @override
  List<Object?> get props => [id, title, subtitle, imageUrl, metadata];
}
