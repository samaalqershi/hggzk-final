import 'package:equatable/equatable.dart';

/// Represents the city record that flows through the admin cities feature.
///
/// يعبّر عن سجل المدينة الذي تنتقل به طبقة المدن الإدارية بين العرض،
/// والمنطق، والبيانات.
class City extends Equatable {
  /// Display name used to identify the city in lists, forms, and API payloads.
  ///
  /// الاسم الظاهر الذي يعرّف المدينة في القوائم والنماذج وطلبات الـ API.
  final String name;

  /// Country name used to group cities and filter the administrative view.
  ///
  /// اسم الدولة الذي يُستخدم لتجميع المدن وتصفية العرض الإداري.
  final String country;

  /// Media references attached to the city, usually gallery or cover images.
  ///
  /// مراجع الوسائط المرتبطة بالمدينة، وغالبًا تكون صور المعرض أو الغلاف.
  final List<String> images;

  /// Timestamp of the first time this city was persisted.
  ///
  /// وقت أول حفظ للمدينة في النظام.
  final DateTime? createdAt;

  /// Timestamp of the latest update received from the backend.
  ///
  /// وقت آخر تحديث وصل من الخادم.
  final DateTime? updatedAt;

  /// Number of properties currently linked to this city.
  ///
  /// عدد العقارات المرتبطة بهذه المدينة حاليًا.
  final int? propertiesCount;

  /// Indicates whether the city should be exposed in active selections.
  ///
  /// يحدد ما إذا كانت المدينة متاحة ضمن الاختيارات النشطة.
  final bool? isActive;

  /// Extra server-provided metadata that does not have a dedicated field yet.
  ///
  /// بيانات وصفية إضافية يرسلها الخادم ولم نخصص لها حقلًا مستقلًا بعد.
  final Map<String, dynamic>? metadata;

  /// Creates a city snapshot ready for equality comparisons and UI binding.
  ///
  /// ينشئ نسخة من المدينة جاهزة للمقارنة والربط مع الواجهة.
  const City({
    required this.name,
    required this.country,
    required this.images,
    this.createdAt,
    this.updatedAt,
    this.propertiesCount,
    this.isActive = true,
    this.metadata,
  });

  /// Builds a neutral placeholder city for forms and empty-state flows.
  ///
  /// ينشئ مدينة حيادية لاستخدامها في النماذج ومسارات الحالة الفارغة.
  factory City.empty() => const City(
        name: '',
        country: '',
        images: [],
      );

  /// Produces a copy while preserving any value that is not explicitly changed.
  ///
  /// ينشئ نسخة جديدة مع الإبقاء على أي قيمة لم يتم تغييرها صراحة.
  City copyWith({
    String? name,
    String? country,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? propertiesCount,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return City(
      name: name ?? this.name,
      country: country ?? this.country,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      propertiesCount: propertiesCount ?? this.propertiesCount,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  /// يحدد السمات التي تعتمد عليها المساواة القيمة-بالقيمة لكي تُعتبر
  /// نسختان من المدينة متطابقتين داخل الحالة أو الذاكرة المؤقتة.
  /// Defines the attributes used for value-based equality so two city
  /// instances are treated as identical in state handling or caching.
  @override
  List<Object?> get props => [
        name,
        country,
        images,
        createdAt,
        updatedAt,
        propertiesCount,
        isActive,
        metadata,
      ];
}
