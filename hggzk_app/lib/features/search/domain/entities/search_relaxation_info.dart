import 'package:equatable/equatable.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:hggzk/core/enums/search_relaxation_level.dart';

/// Captures how the backend relaxed a search query to produce matches.
/// يلتقط طريقة تخفيف الخادم لاستعلام البحث حتى يتمكن من إنتاج نتائج.
class SearchRelaxationInfo extends Equatable {
  /// Exact relaxation tier chosen by the backend.
  /// مستوى التخفيف المحدد من الخادم.
  final SearchRelaxationLevel relaxationLevel;

  /// Filters that were loosened to broaden the result set.
  /// الفلاتر التي تم تخفيفها لتوسيع مجموعة النتائج.
  final List<String> relaxedFilters;

  /// Search strategy label returned with the relaxed response.
  /// وسم استراتيجية البحث المعاد مع الاستجابة المخففة.
  final String searchStrategy;

  /// Original query criteria before the backend widened them.
  /// معايير الاستعلام الأصلية قبل أن يوسعها الخادم.
  final Map<String, dynamic> originalCriteria;

  /// Criteria actually applied after relaxation.
  /// المعايير الفعلية المطبقة بعد التخفيف.
  final Map<String, dynamic> actualCriteria;

  /// Optional message shown to explain why the search broadened.
  /// رسالة اختيارية تشرح لماذا تم توسيع البحث.
  final String? userMessage;

  /// Suggestions that help the user tighten the search again.
  /// اقتراحات تساعد المستخدم على تضييق البحث من جديد.
  final List<String> suggestedActions;

  /// Builds a structured explanation for relaxed search results.
  /// ينشئ شرحًا منظمًا للنتائج التي بُنيت عبر بحث مخفف.
  const SearchRelaxationInfo({
    required this.relaxationLevel,
    required this.relaxedFilters,
    required this.searchStrategy,
    required this.originalCriteria,
    required this.actualCriteria,
    this.userMessage,
    required this.suggestedActions,
  });

  /// True when the backend had to relax the original query.
  /// تكون صحيحة عندما يضطر الخادم إلى تخفيف الاستعلام الأصلي.
  bool get wasRelaxed => relaxationLevel != SearchRelaxationLevel.exact;

  /// Number of filters that were widened or ignored.
  /// عدد الفلاتر التي تم توسيعها أو تجاهلها.
  int get relaxedFiltersCount => relaxedFilters.length;

  /// True when a user-facing explanation is available.
  /// تكون صحيحة عندما تتوفر رسالة موجهة للمستخدم.
  bool get hasUserMessage => userMessage != null && userMessage!.isNotEmpty;

  /// True when the backend returned suggestions for a tighter retry.
  /// تكون صحيحة عندما يعيد الخادم اقتراحات لإعادة بحث أدق.
  bool get hasSuggestions => suggestedActions.isNotEmpty;

  /// Empty baseline used when no relaxation metadata is available.
  /// نسخة أساسية فارغة تستخدم عندما لا تتوفر بيانات التخفيف.
  static SearchRelaxationInfo get empty => SearchRelaxationInfo(
        relaxationLevel: SearchRelaxationLevel.exact,
        relaxedFilters: const [],
        searchStrategy:
            AppLocalizations.translateSync('core.searchRelaxation.exact'),
        originalCriteria: const {},
        actualCriteria: const {},
        userMessage: null,
        suggestedActions: const [],
      );

  /// Rebuilds the relaxation summary from a search response payload.
  /// يعيد بناء ملخص التخفيف من حمولة استجابة البحث.
  factory SearchRelaxationInfo.fromResponse({
    required SearchRelaxationLevel relaxationLevel,
    required List<String> relaxedFilters,
    required String searchStrategy,
    required Map<String, dynamic> originalCriteria,
    required Map<String, dynamic> actualCriteria,
    String? userMessage,
    required List<String> suggestedActions,
  }) {
    return SearchRelaxationInfo(
      relaxationLevel: relaxationLevel,
      relaxedFilters: relaxedFilters,
      searchStrategy: searchStrategy,
      originalCriteria: originalCriteria,
      actualCriteria: actualCriteria,
      userMessage: userMessage,
      suggestedActions: suggestedActions,
    );
  }

  /// Returns a new instance with any supplied fields replaced.
  /// يعيد نسخة جديدة مع استبدال أي حقول يتم تمريرها.
  SearchRelaxationInfo copyWith({
    SearchRelaxationLevel? relaxationLevel,
    List<String>? relaxedFilters,
    String? searchStrategy,
    Map<String, dynamic>? originalCriteria,
    Map<String, dynamic>? actualCriteria,
    String? userMessage,
    List<String>? suggestedActions,
  }) {
    return SearchRelaxationInfo(
      relaxationLevel: relaxationLevel ?? this.relaxationLevel,
      relaxedFilters: relaxedFilters ?? this.relaxedFilters,
      searchStrategy: searchStrategy ?? this.searchStrategy,
      originalCriteria: originalCriteria ?? this.originalCriteria,
      actualCriteria: actualCriteria ?? this.actualCriteria,
      userMessage: userMessage ?? this.userMessage,
      suggestedActions: suggestedActions ?? this.suggestedActions,
    );
  }

  /// Keeps equality aligned with the relaxation payload.
  /// يحافظ على ثبات المقارنة مع حمولة التخفيف.
  @override
  List<Object?> get props => [
        relaxationLevel,
        relaxedFilters,
        searchStrategy,
        originalCriteria,
        actualCriteria,
        userMessage,
        suggestedActions,
      ];

  /// Produces a compact debug representation of the relaxation summary.
  /// ينتج تمثيلًا مختصرًا للتصحيح الخاص بملخص التخفيف.
  @override
  String toString() {
    return 'SearchRelaxationInfo('
        'level: $relaxationLevel, '
        'filters: ${relaxedFilters.length}, '
        'strategy: $searchStrategy, '
        'hasMessage: $hasUserMessage, '
        'suggestions: ${suggestedActions.length}'
        ')';
  }
}
