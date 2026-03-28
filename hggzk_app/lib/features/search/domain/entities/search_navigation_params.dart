import 'package:equatable/equatable.dart';

/// Carries search context between pages so the filters can be restored.
/// يحمل سياق البحث بين الصفحات حتى يمكن استعادة الفلاتر.
class SearchNavigationParams extends Equatable {
  /// Selected property type.
  /// نوع العقار المحدد.
  final String? propertyTypeId;

  /// Selected unit type.
  /// نوع الوحدة المحدد.
  final String? unitTypeId;

  /// Selected city.
  /// المدينة المحددة.
  final String? city;

  /// Free-text search term.
  /// نص البحث الحر.
  final String? searchTerm;

  /// Arrival date.
  /// تاريخ الوصول.
  final DateTime? checkIn;

  /// Departure date.
  /// تاريخ المغادرة.
  final DateTime? checkOut;

  /// Adult guest count.
  /// عدد البالغين.
  final int? adults;

  /// Child guest count.
  /// عدد الأطفال.
  final int? children;

  /// Total guest count.
  /// إجمالي عدد الضيوف.
  final int? guestsCount;

  /// Bundles the navigation context used by the search experience.
  /// يجمع سياق التنقل المستخدم في تجربة البحث.
  const SearchNavigationParams({
    this.propertyTypeId,
    this.unitTypeId,
    this.city,
    this.searchTerm,
    this.checkIn,
    this.checkOut,
    this.adults,
    this.children,
    this.guestsCount,
  });

  /// Returns a new context snapshot with the requested overrides.
  /// يعيد لقطة جديدة للسياق مع الاستبدالات المطلوبة.
  SearchNavigationParams copyWith({
    String? propertyTypeId,
    String? unitTypeId,
    String? city,
    String? searchTerm,
    DateTime? checkIn,
    DateTime? checkOut,
    int? adults,
    int? children,
    int? guestsCount,
  }) {
    return SearchNavigationParams(
      propertyTypeId: propertyTypeId ?? this.propertyTypeId,
      unitTypeId: unitTypeId ?? this.unitTypeId,
      city: city ?? this.city,
      searchTerm: searchTerm ?? this.searchTerm,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      guestsCount: guestsCount ?? this.guestsCount,
    );
  }

  /// Serializes the navigation context so it can be passed across routes.
  /// يحول سياق التنقل إلى `Map` حتى يمكن تمريره بين المسارات.
  Map<String, dynamic> toMap() => {
        'propertyTypeId': propertyTypeId,
        'unitTypeId': unitTypeId,
        'city': city,
        'searchTerm': searchTerm,
        'checkIn': checkIn?.toIso8601String(),
        'checkOut': checkOut?.toIso8601String(),
        'adults': adults,
        'children': children,
        'guestsCount': guestsCount,
      };

  /// Rebuilds the navigation context from a serialized route payload.
  /// يعيد بناء سياق التنقل من حمولة مسار مسلسلة.
  factory SearchNavigationParams.fromMap(Map<String, dynamic> map) {
    return SearchNavigationParams(
      propertyTypeId: map['propertyTypeId'] as String?,
      unitTypeId: map['unitTypeId'] as String?,
      city: map['city'] as String?,
      searchTerm: map['searchTerm'] as String?,
      checkIn: map['checkIn'] != null
          ? DateTime.tryParse(map['checkIn'] as String)
          : null,
      checkOut: map['checkOut'] != null
          ? DateTime.tryParse(map['checkOut'] as String)
          : null,
      adults: map['adults'] is int
          ? map['adults'] as int
          : int.tryParse(map['adults']?.toString() ?? ''),
      children: map['children'] is int
          ? map['children'] as int
          : int.tryParse(map['children']?.toString() ?? ''),
      guestsCount: map['guestsCount'] as int?,
    );
  }

  /// Keeps equality aligned with the restored navigation context.
  /// يحافظ على ثبات المقارنة مع سياق التنقل المستعاد.
  @override
  List<Object?> get props => [
        propertyTypeId,
        unitTypeId,
        city,
        searchTerm,
        checkIn,
        checkOut,
        adults,
        children,
        guestsCount,
      ];
}
