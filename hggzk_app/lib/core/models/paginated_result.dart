import 'package:equatable/equatable.dart';

/// يجمع العناصر المرسلة من API مع معلومات الصفحات حتى تستطيع الواجهات التنقل
/// بين النتائج بطريقة صحيحة ومتسقة.
/// Bundles API items with pagination metadata so UIs can move through result
/// sets consistently.
class PaginatedResult<T> extends Equatable {
  /// العناصر الفعلية في هذه الصفحة.
  /// The actual items contained in this page.
  final List<T> items;

  /// رقم الصفحة الحالية كما أرسله الخادم.
  /// The current page number reported by the backend.
  final int pageNumber;

  /// حجم الصفحة الذي استُخدم عند طلب النتائج.
  /// The page size that was requested or returned.
  final int pageSize;

  /// العدد الإجمالي للعناصر المتوافرة عبر الصفحات كلها.
  /// The total number of items available across all pages.
  final int totalCount;

  /// حقل مرن يحمل أي بيانات مرافقة إضافية من الـ API.
  /// Flexible metadata channel for any extra API-provided context.
  final Object? metadata;

  /// يمثل صفحة كاملة من البيانات بعد تطبيعها مع مقاييس التصفح.
  /// Represents one normalized page of data together with its paging metrics.
  const PaginatedResult({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    this.metadata,
  });

  /// يحمي الحسابات من أحجام صفحات غير صالحة أو صفرية.
  /// Protects calculations from invalid or zero page sizes.
  int get _safePageSize {
    if (pageSize <= 0) return items.isNotEmpty ? items.length : 1;
    return pageSize;
  }

  /// يحمي الحسابات من أرقام صفحات أقل من واحد.
  /// Protects calculations from page numbers below one.
  int get _safePageNumber => pageNumber < 1 ? 1 : pageNumber;

  /// يحسب عدد الصفحات الكلي اعتمادًا على العدد الإجمالي وحجم الصفحة.
  /// Computes how many pages exist from the total count and page size.
  int get totalPages {
    final size = _safePageSize;
    if (totalCount <= 0) return 0;
    return ((totalCount + size - 1) ~/ size);
  }

  /// يوضح ما إذا كانت هناك صفحة تسبق الصفحة الحالية.
  /// Indicates whether a page exists before the current one.
  bool get hasPreviousPage => _safePageNumber > 1;

  /// يوضح ما إذا كانت هناك صفحة لاحقة.
  /// Indicates whether another page follows the current one.
  bool get hasNextPage => totalPages > 0 && _safePageNumber < totalPages;

  /// يعيد رقم الصفحة السابقة عندما تكون متاحة.
  /// Exposes the previous page number when it exists so callers can read it without depending on implementation details.
  int? get previousPageNumber => hasPreviousPage ? _safePageNumber - 1 : null;

  /// يعيد رقم الصفحة التالية عندما تكون متاحة.
  /// Exposes the next page number when it exists so callers can read it without depending on implementation details.
  int? get nextPageNumber => hasNextPage ? _safePageNumber + 1 : null;

  /// يحسب أول موضع منطقي لهذا الجزء من النتائج.
  /// Calculates the first logical index for this page of results.
  int get startIndex =>
      (_safePageNumber - 1) * _safePageSize + (items.isEmpty ? 0 : 1);

  /// يحسب آخر موضع منطقي لهذا الجزء من النتائج.
  /// Calculates the last logical index for this page of results.
  int get endIndex => items.isEmpty ? 0 : startIndex + items.length - 1;

  /// ينشئ صفحة فارغة تُستخدم عندما لا يعيد الخادم أي عناصر.
  /// Creates an empty page used when the backend returns no items.
  factory PaginatedResult.empty({
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return PaginatedResult<T>(
      items: const [],
      pageNumber: pageNumber,
      pageSize: pageSize,
      totalCount: 0,
    );
  }

  /// يحول JSON إلى صفحة typed مع حماية ضد القيم غير الصالحة.
  /// Converts JSON into a typed page while guarding against malformed
  /// paging values.
  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawItems = (json['items'] as List?) ?? const [];
    final parsedItems = rawItems.map((item) => fromJsonT(item)).toList();

    int parseInt(dynamic v, int fallback) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? fallback;
      if (v is num) return v.toInt();
      return fallback;
    }

    final pn = parseInt(json['pageNumber'], 1);
    final ps = parseInt(json['pageSize'], 10);
    final tc = parseInt(json['totalCount'], parsedItems.length);

    return PaginatedResult<T>(
      items: parsedItems,
      pageNumber: pn < 1 ? 1 : pn,
      pageSize:
          ps <= 0 ? (parsedItems.isNotEmpty ? parsedItems.length : 10) : ps,
      totalCount: tc < 0 ? 0 : tc,
      metadata: json['metadata'],
    );
  }

  /// يعيد الصفحة إلى JSON مع الحسابات المشتقة اللازمة للعرض أو النقل.
  /// Serializes the page to JSON together with derived paging values
  /// used by UIs and APIs.
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'items': items.map((item) => toJsonT(item)).toList(),
      'pageNumber': _safePageNumber,
      'pageSize': _safePageSize,
      'totalCount': totalCount,
      'totalPages': totalPages,
      'hasPreviousPage': hasPreviousPage,
      'hasNextPage': hasNextPage,
      'previousPageNumber': previousPageNumber,
      'nextPageNumber': nextPageNumber,
      'startIndex': startIndex,
      'endIndex': endIndex,
      'metadata': metadata,
    };
  }

  /// يحدد ما الذي يجعل صفحتين متطابقتين من منظور المقارنة.
  /// Groups the fields that determine equality between two pages so the rest of the app stays type-safe.
  @override
  List<Object?> get props => [
        items,
        pageNumber,
        pageSize,
        totalCount,
        metadata,
      ];
}
