import 'package:hggzk/features/search/data/models/search_result_model.dart';
import 'package:hggzk/features/search/data/models/search_filter_model.dart';
import 'package:hggzk/features/search/data/models/search_statistics_model.dart';
import 'package:hggzk/core/enums/search_relaxation_level.dart';

/// العربية: يمثل نموذج البيانات `SearchPropertiesResponseModel`.
class SearchPropertiesResponseModel {
  /// العربية: يخزن القيمة `properties`.
  final List<SearchResultModel> properties;

  /// العربية: يخزن القيمة `totalCount`.
  final int totalCount;

  /// العربية: يخزن القيمة `currentPage`.
  final int currentPage;

  /// العربية: يخزن القيمة `pageSize`.
  final int pageSize;

  /// العربية: يخزن القيمة `totalPages`.
  final int totalPages;

  /// العربية: يحدد ما إذا كانت القيمة `hasPreviousPage` مفعلة.
  final bool hasPreviousPage;

  /// العربية: يحدد ما إذا كانت القيمة `hasNextPage` مفعلة.
  final bool hasNextPage;

  /// العربية: يخزن القيمة `appliedFilters`.
  final SearchFiltersModel appliedFilters;

  /// العربية: يخزن القيمة `facets`.
  final SearchFiltersModel facets;

  /// العربية: يخزن القيمة `searchTimeMs`.
  final int searchTimeMs;

  /// العربية: يخزن القيمة `statistics`.
  final SearchStatisticsModel statistics;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Fallback Search Strategy Fields
  // حقول استراتيجية البحث مع التخفيف التدريجي
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// مستوى التخفيف المطبق
  /// Applied relaxation level
  final SearchRelaxationLevel relaxationLevel;

  /// قائمة الفلاتر التي تم تخفيفها
  /// List of relaxed filters
  final List<String> relaxedFilters;

  /// استراتيجية البحث المطبقة
  /// Applied search strategy
  final String searchStrategy;

  /// المعايير الأصلية (قبل التخفيف)
  /// Original criteria (before relaxation)
  final Map<String, dynamic> originalCriteria;

  /// المعايير الفعلية (بعد التخفيف)
  /// Actual criteria (after relaxation)
  final Map<String, dynamic> actualCriteria;

  /// رسالة للمستخدم توضح التخفيف المطبق
  /// User message explaining applied relaxation
  final String? userMessage;

  /// اقتراحات لتحسين البحث
  /// Suggestions to improve search
  final List<String> suggestedActions;

  /// العربية: ينشئ مثيلًا جديدًا من `SearchPropertiesResponseModel`.
  const SearchPropertiesResponseModel({
    required this.properties,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
    required this.appliedFilters,
    required this.facets,
    required this.searchTimeMs,
    required this.statistics,
    this.relaxationLevel = SearchRelaxationLevel.exact,
    this.relaxedFilters = const [],
    this.searchStrategy = 'تطابق دقيق',
    this.originalCriteria = const {},
    this.actualCriteria = const {},
    this.userMessage,
    this.suggestedActions = const [],
  });

  /// العربية: ينشئ مثيلًا جديدًا من `SearchPropertiesResponseModel.fromJson`.
  factory SearchPropertiesResponseModel.fromJson(Map<String, dynamic> json) {
    // Debug: Print relaxation info from JSON
    print('🔍 [SearchPropertiesResponseModel] Parsing JSON...');
    print(
        '   - relaxationLevel (raw): ${json['relaxationLevel']} (${json['relaxationLevel'].runtimeType})');
    print('   - relaxedFilters: ${json['relaxedFilters']}');
    print('   - userMessage: ${json['userMessage']}');
    print('   - suggestedActions: ${json['suggestedActions']}');

    final parsedRelaxationLevel = SearchRelaxationLevelExtension.fromString(
      json['relaxationLevel'],
    );
    print('   - parsedRelaxationLevel: $parsedRelaxationLevel');
    print(
        '   - wasRelaxed: ${parsedRelaxationLevel != SearchRelaxationLevel.exact}');

    return SearchPropertiesResponseModel(
      properties: (json['properties'] as List?)
              ?.map(
                  (e) => SearchResultModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalPages: json['totalPages'] ?? 0,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      hasNextPage: json['hasNextPage'] ?? false,
      appliedFilters: SearchFiltersModel.fromJson(
          json['appliedFilters'] as Map<String, dynamic>? ?? {}),
      facets: SearchFiltersModel.fromJson(
          json['facets'] as Map<String, dynamic>? ?? {}),
      searchTimeMs: json['searchTimeMs'] ?? 0,
      statistics: SearchStatisticsModel.fromJson(
          json['statistics'] as Map<String, dynamic>? ?? {}),

      // Parse Fallback Search fields
      relaxationLevel: parsedRelaxationLevel,
      relaxedFilters: (json['relaxedFilters'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      searchStrategy: json['searchStrategy'] as String? ?? 'تطابق دقيق',
      originalCriteria:
          (json['originalCriteria'] as Map<String, dynamic>?) ?? const {},
      actualCriteria:
          (json['actualCriteria'] as Map<String, dynamic>?) ?? const {},
      userMessage: json['userMessage'] as String?,
      suggestedActions: (json['suggestedActions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  /// هل تم تطبيق تخفيف؟
  /// Was relaxation applied?
  bool get wasRelaxed => relaxationLevel != SearchRelaxationLevel.exact;

  /// عدد الفلاتر المخففة
  /// Number of relaxed filters
  int get relaxedFiltersCount => relaxedFilters.length;

  /// هل هناك اقتراحات؟
  /// Are there suggestions?
  bool get hasSuggestions => suggestedActions.isNotEmpty;
}
