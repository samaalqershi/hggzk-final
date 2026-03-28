import 'package:equatable/equatable.dart';

/// يعبّر عن صفحة من نتائج مقسمة مع معلومات التنقل اللازمة لواجهة تعرض
/// بيانات كبيرة على دفعات.
/// Represents one page of chunked results together with the navigation
/// metadata required by UIs that load large lists incrementally.
class PaginatedResult<T> extends Equatable {
  /// العناصر الفعلية الموجودة داخل الصفحة الحالية.
  /// The actual items contained in the current page.
  final List<T> items;

  /// رقم الصفحة الحالي كما يرسله المصدر أو تحفظه الواجهة.
  /// The current page number as provided by the source or remembered by UI.
  final int pageNumber;

  /// عدد العناصر المتوقع في كل صفحة عند الحساب أو العرض.
  /// The expected item count per page used for calculation and display.
  final int pageSize;

  /// إجمالي العناصر المتاحة عبر كل الصفحات.
  /// The total number of items available across all pages.
  final int totalCount;

  /// بيانات إضافية اختيارية قد ترافق الاستجابة مثل الفلاتر أو الملحقات.
  /// Optional extra metadata that can travel with the response, such as
  /// filters or backend-specific context.
  final Object? metadata;

  /// Creates a paginated result snapshot for the given page and item set.
  const PaginatedResult({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    this.metadata,
  });

  /// يضبط حجم الصفحة على قيمة آمنة حتى لا تنهار الحسابات عندما يرسل المصدر
  /// قيمة غير صالحة.
  /// Normalizes the page size to a safe value so calculations do not break
  /// when the source sends an invalid number.
  int get _safePageSize {
    if (pageSize <= 0) return items.isNotEmpty ? items.length : 1;
    return pageSize;
  }

  /// يضبط رقم الصفحة على أقل قيمة منطقية وهي `1` عندما يأتي الرقم أقل من
  /// ذلك.
  /// Normalizes the page number to a logical minimum of `1` when a smaller
  /// value is received.
  int get _safePageNumber => pageNumber < 1 ? 1 : pageNumber;

  /// يحسب إجمالي عدد الصفحات بناءً على الحجم الآمن وعدد العناصر الكلي.
  /// Calculates the total page count from the safe page size and total items.
  int get totalPages {
    final size = _safePageSize;
    if (totalCount <= 0) return 0;
    return ((totalCount + size - 1) ~/ size);
  }

  /// يوضح ما إذا كانت هناك صفحة سابقة يمكن الرجوع إليها.
  /// Indicates whether a previous page exists that the UI can navigate to.
  bool get hasPreviousPage => _safePageNumber > 1;

  /// يوضح ما إذا كانت هناك صفحة لاحقة يمكن تحميلها.
  /// Indicates whether a next page exists that the UI can request.
  bool get hasNextPage => totalPages > 0 && _safePageNumber < totalPages;

  /// رقم الصفحة الحالي بعد التحقق من الحد الأدنى المسموح.
  /// The current page number after minimum-bound correction.
  int get currentPage => _safePageNumber;

  /// رقم الصفحة السابقة عندما تكون متاحة، وإلا يعيد `null`.
  /// The previous page number when available, otherwise `null`.
  int? get previousPageNumber => hasPreviousPage ? _safePageNumber - 1 : null;

  /// رقم الصفحة التالية عندما تكون متاحة، وإلا يعيد `null`.
  /// The next page number when available, otherwise `null`.
  int? get nextPageNumber => hasNextPage ? _safePageNumber + 1 : null;

  /// يبدأ حساب فهرس العرض من أول عنصر ظاهر في الصفحة الحالية.
  /// Returns the first visible item index for the current page.
  int get startIndex =>
      (_safePageNumber - 1) * _safePageSize + (items.isEmpty ? 0 : 1);

  /// ينهي حساب الفهرس عند آخر عنصر فعلي ضمن الصفحة الحالية.
  /// Returns the last visible item index for the current page.
  int get endIndex => items.isEmpty ? 0 : startIndex + items.length - 1;

  /// ينشئ صفحة فارغة آمنة للاستخدام في حالات عدم وجود بيانات.
  /// Creates a safe empty page that UIs can use when no data exists.
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

  /// يقرأ استجابة JSON من أشكال متعددة للبنية حتى يتعامل مع اختلافات
  /// الخوادم بين payload مباشر أو envelope.
  /// Parses JSON responses in multiple shapes so the model can handle direct
  /// payloads and wrapped envelopes from different backends.
  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    // Accept both bare payload and ResultDto-wrapped
    final Object? root;
    if (json['items'] != null) {
      root = json;
    } else if (json['data'] is Map<String, dynamic>) {
      root = json['data'];
    } else if (json['data'] is List) {
      // Envelope with list as data
      root = {
        'items': json['data'],
        'pageNumber': json['pageNumber'] ?? 1,
        'pageSize': (json['data'] as List).length,
        'totalCount': (json['data'] as List).length,
        'metadata': json['metadata'],
      };
    } else {
      // Some backends might return list directly
      if (json.isEmpty) {
        return PaginatedResult<T>.empty();
      }
      root = json;
    }

    final Map<String, dynamic> payload = Map<String, dynamic>.from(root as Map);

    // يجمع العناصر الخام قبل تحويل كل عنصر إلى النوع العام المطلوب.
    final List rawItems;
    if (payload['items'] is List) {
      rawItems = payload['items'] as List;
    } else if (payload['data'] is List) {
      rawItems = payload['data'] as List;
    } else {
      rawItems = const [];
    }
    // يحول العناصر القابلة للتحويل إلى النماذج العامة التي يتعامل معها
    // المستهلكون.
    final parsedItems = rawItems
        .whereType<Map>()
        .map((item) => fromJsonT(Map<String, dynamic>.from(item)))
        .toList();

    // يحلل القيم العددية التي قد تصل كأرقام أو نصوص أو قيم عامة.
    int parseInt(dynamic v, int fallback) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? fallback;
      if (v is num) return v.toInt();
      return fallback;
    }

    final pn = parseInt(payload['pageNumber'], 1);
    final ps = parseInt(payload['pageSize'], 10);
    final tc = parseInt(payload['totalCount'], parsedItems.length);

    return PaginatedResult<T>(
      items: parsedItems,
      pageNumber: pn < 1 ? 1 : pn,
      pageSize:
          ps <= 0 ? (parsedItems.isNotEmpty ? parsedItems.length : 10) : ps,
      totalCount: tc < 0 ? 0 : tc,
      metadata: payload['metadata'],
    );
  }

  /// يحول الصفحة الحالية إلى JSON بصيغة موحدة تراعي كل معلومات التنقل.
  /// Serializes the current page into a consistent JSON map that includes
  /// navigation metadata.
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

  /// يعرّف المساواة على أساس محتوى الصفحة والعدادات المرتبطة بها.
  /// Defines equality using the page contents and the related counters.
  @override
  List<Object?> get props => [
        items,
        pageNumber,
        pageSize,
        totalCount,
        metadata,
      ];
}
