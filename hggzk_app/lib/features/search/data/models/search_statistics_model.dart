import 'package:hggzk/features/search/data/models/search_filter_model.dart';

/// العربية: يمثل نموذج البيانات `SearchStatisticsModel`.
class SearchStatisticsModel {
  /// العربية: يخزن القيمة `searchDurationMs`.
  final int searchDurationMs;

  /// العربية: يخزن القيمة `appliedFiltersCount`.
  final int appliedFiltersCount;

  /// العربية: يخزن القيمة `totalResultsBeforePaging`.
  final int totalResultsBeforePaging;

  /// العربية: يخزن القيمة `suggestions`.
  final List<String> suggestions;

  /// العربية: يخزن القيمة `priceRange`.
  final PriceRangeModel? priceRange;

  /// العربية: ينشئ مثيلًا جديدًا من `SearchStatisticsModel`.
  const SearchStatisticsModel({
    required this.searchDurationMs,
    required this.appliedFiltersCount,
    required this.totalResultsBeforePaging,
    required this.suggestions,
    this.priceRange,
  });

  /// العربية: ينشئ مثيلًا جديدًا من `SearchStatisticsModel.fromJson`.
  factory SearchStatisticsModel.fromJson(Map<String, dynamic> json) {
    return SearchStatisticsModel(
      searchDurationMs: json['searchDurationMs'] ?? 0,
      appliedFiltersCount: json['appliedFiltersCount'] ?? 0,
      totalResultsBeforePaging: json['totalResultsBeforePaging'] ?? 0,
      suggestions: List<String>.from(json['suggestions'] ?? []),
      priceRange: json['priceRange'] != null
          ? PriceRangeModel.fromJson(json['priceRange'] as Map<String, dynamic>)
          : null,
    );
  }
}
