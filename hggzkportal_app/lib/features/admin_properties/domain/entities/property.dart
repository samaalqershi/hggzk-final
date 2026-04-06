// lib/features/admin_properties/domain/entities/property.dart

import 'package:equatable/equatable.dart';
import 'property_image.dart';
import 'amenity.dart';
import 'nearby_place.dart';
import 'policy.dart';

/// Describes a managed property together with the operational data the portal
/// needs to approve, search, rank, and present it.
///
/// يصف عقارًا مدارًا مع البيانات التشغيلية التي تحتاجها البوابة للموافقة
/// عليه والبحث فيه وترتيبه وعرضه.
class Property extends Equatable {
  /// Stable identifier used across admin, booking, and analytics screens.
  ///
  /// المعرّف الثابت المستخدم عبر الإدارة والحجز والتحليلات.
  final String id;

  /// Owner account that manages the property.
  ///
  /// حساب المالك المسؤول عن العقار.
  final String ownerId;

  /// Property type classification used for filtering and segmentation.
  ///
  /// تصنيف نوع العقار المستخدم في الفلترة والتقسيم.
  final String typeId;

  /// Display name shown to managers and in the catalog.
  ///
  /// اسم العرض الظاهر للإدارة وفي القوائم.
  final String name;

  /// English display name stored for bilingual catalogs and client apps.
  ///
  /// اسم العرض الإنجليزي المخزن لدعم الكتالوجات الثنائية اللغة.
  final String? nameEn;

  /// Short marketing copy that appears in compact cards.
  ///
  /// وصف تسويقي قصير يظهر في البطاقات المختصرة.
  final String? shortDescription;

  /// English short marketing copy used in English experiences.
  ///
  /// وصف تسويقي قصير بالإنجليزية يستخدم في التجارب الإنجليزية.
  final String? shortDescriptionEn;

  /// Street address used by staff and mapping tools.
  ///
  /// العنوان البريدي المستخدم من قبل الفريق وأدوات الخرائط.
  final String address;

  /// English address variant displayed when the viewer uses English.
  ///
  /// نسخة إنجليزية من العنوان تظهر عند استخدام الإنجليزية.
  final String? addressEn;

  /// City or locality used for search and grouping.
  ///
  /// المدينة أو المنطقة المستخدمة في البحث والتجميع.
  final String city;

  /// English city/locality label used by bilingual cards and details.
  ///
  /// الاسم الإنجليزي للمدينة أو المنطقة لاستخدامه في العرض الثنائي اللغة.
  final String? cityEn;

  /// Optional latitude for map rendering and proximity search.
  ///
  /// خط العرض الاختياري لعرض الموقع والبحث القريب.
  final double? latitude;

  /// Optional longitude for map rendering and proximity search.
  ///
  /// خط الطول الاختياري لعرض الموقع والبحث القريب.
  final double? longitude;

  /// Provider-assigned star rating used in ranking and presentation.
  ///
  /// التصنيف النجمي المعتمد الذي يدخل في العرض والترتيب.
  final int starRating;

  /// Full descriptive text shown on the detail page.
  ///
  /// النص الوصفي الكامل المعروض في صفحة التفاصيل.
  final String description;

  /// English descriptive text shown in English detail pages.
  ///
  /// النص الوصفي الإنجليزي الذي يظهر في صفحات التفاصيل الإنجليزية.
  final String? descriptionEn;

  /// Indicates whether the property has passed review and can be shown live.
  ///
  /// يوضح ما إذا كان العقار قد اجتاز المراجعة وأصبح قابلًا للنشر.
  final bool isApproved;

  /// Creation timestamp used in audit and sorting views.
  ///
  /// وقت الإنشاء المستخدم في التدقيق والفرز.
  final DateTime createdAt;

  /// Number of property detail page views.
  ///
  /// عدد مرات مشاهدة صفحة تفاصيل العقار.
  final int viewCount;

  /// Number of bookings associated with this property.
  ///
  /// عدد الحجوزات المرتبطة بهذا العقار.
  final int bookingCount;

  /// Aggregated guest review score.
  ///
  /// متوسط تقييم الضيوف المجمع.
  final double averageRating;

  /// Default currency used by pricing and commission calculations.
  ///
  /// العملة الافتراضية المستخدمة في التسعير والعمولات.
  final String currency;

  /// Marks properties that should be highlighted in the portal.
  ///
  /// يميز العقارات التي يجب إبرازها داخل البوابة.
  final bool isFeatured;

  /// Optional commission rate configured by the platform.
  ///
  /// نسبة العمولة الاختيارية التي يضبطها النظام.
  final double? systemCommissionRate;

  /// Display name of the property owner.
  ///
  /// اسم العرض لمالك العقار.
  final String ownerName;

  /// Human-readable property type label.
  ///
  /// التسمية المقروءة بشريًا لنوع العقار.
  final String typeName;

  /// English property type label used when bilingual content is available.
  ///
  /// تسمية نوع العقار بالإنجليزية عند توفر المحتوى الثنائي اللغة.
  final String? typeNameEn;

  /// Optional distance value used by map and search experiences.
  ///
  /// المسافة الاختيارية المستخدمة في تجارب الخرائط والبحث.
  final double? distanceKm;

  /// Visual gallery attached to the property.
  ///
  /// معرض الصور المرتبط بالعقار.
  final List<PropertyImage> images;

  /// Amenities exposed to guests and used by search filters.
  ///
  /// المزايا الظاهرة للضيوف والمستخدمة في فلاتر البحث.
  final List<Amenity> amenities;

  /// Property policies that shape booking rules and guest expectations.
  ///
  /// سياسات العقار التي تحدد قواعد الحجز وتوقعات الضيف.
  final List<Policy> policies;

  /// Real nearby places surfaced in property details.
  ///
  /// الأماكن القريبة الحقيقية المعروضة في تفاصيل العقار.
  final List<NearbyPlace> nearbyPlaces;

  /// Optional dashboard metrics returned alongside the property payload.
  ///
  /// مؤشرات اختيارية تعود مع حمولة العقار لتغذية اللوحات.
  final PropertyStats? stats;

  /// Creates the property aggregate used by management screens and public
  /// presentation layers.
  ///
  /// ينشئ مجمع العقار الذي تستخدمه شاشات الإدارة وطبقات العرض العام.
  const Property({
    required this.id,
    required this.ownerId,
    required this.typeId,
    required this.name,
    this.nameEn,
    this.shortDescription,
    this.shortDescriptionEn,
    required this.address,
    this.addressEn,
    required this.city,
    this.cityEn,
    this.latitude,
    this.longitude,
    required this.starRating,
    required this.description,
    this.descriptionEn,
    required this.isApproved,
    required this.createdAt,
    this.viewCount = 0,
    this.bookingCount = 0,
    this.averageRating = 0.0,
    this.currency = 'YER',
    this.isFeatured = false,
    this.systemCommissionRate,
    required this.ownerName,
    required this.typeName,
    this.typeNameEn,
    this.distanceKm,
    this.images = const [],
    this.amenities = const [],
    this.policies = const [],
    this.nearbyPlaces = const [],
    this.stats,
  });

  /// Indicates whether both map coordinates are available.
  ///
  /// يحدد ما إذا كانت إحداثيات الخريطة متوفرة بالكامل.
  bool get hasLocation => latitude != null && longitude != null;

  /// Flags records that still await approval before publishing.
  ///
  /// يميز السجلات التي ما زالت بانتظار الموافقة قبل النشر.
  bool get isPending => !isApproved;

  /// Returns a concise combined address string for cards and headers.
  ///
  /// يعيد عنوانًا مختصرًا مجمعًا للبطاقات والرؤوس.
  String get formattedAddress => '$address, $city';

  /// Returns the English combined address when English variants are available.
  ///
  /// يعيد العنوان المجمع بالإنجليزية عند توفر النسخ الإنجليزية.
  String get formattedAddressEn {
    final parts = <String>[
      (addressEn ?? address).trim(),
      (cityEn ?? city).trim(),
    ].where((value) => value.isNotEmpty).toList();

    return parts.join(', ');
  }

  /// Keeps equality aligned with the visible property snapshot.
  ///
  /// يربط المقارنة بلقطة العقار الظاهرة.
  @override
  List<Object?> get props => [
        id,
        ownerId,
        typeId,
        name,
        nameEn,
        shortDescription,
        shortDescriptionEn,
        address,
        addressEn,
        city,
        cityEn,
        latitude,
        longitude,
        starRating,
        description,
        descriptionEn,
        isApproved,
        createdAt,
        viewCount,
        bookingCount,
        averageRating,
        currency,
        isFeatured,
        systemCommissionRate,
        ownerName,
        typeName,
        typeNameEn,
        distanceKm,
        images,
        amenities,
        policies,
        nearbyPlaces,
        stats,
      ];
}

/// Carries the summary metrics that appear beside a property in admin views.
///
/// يحمل المؤشرات المختصرة التي تظهر بجانب العقار في شاشات الإدارة.
class PropertyStats extends Equatable {
  /// Total booking count for this property snapshot.
  ///
  /// إجمالي عدد الحجوزات لهذا العقار.
  final int totalBookings;

  /// Bookings that are currently active.
  ///
  /// الحجوزات النشطة حاليًا.
  final int activeBookings;

  /// Average guest rating for the property.
  ///
  /// متوسط تقييم الضيوف للعقار.
  final double averageRating;

  /// Number of guest reviews included in the average.
  ///
  /// عدد المراجعات التي دخلت في المتوسط.
  final int reviewCount;

  /// Occupancy percentage for the current reporting window.
  ///
  /// نسبة الإشغال خلال فترة التقرير الحالية.
  final double occupancyRate;

  /// Revenue generated during the current month or report period.
  ///
  /// الإيرادات المتولدة خلال الشهر الحالي أو فترة التقرير.
  final double monthlyRevenue;

  /// Creates the compact statistics block that accompanies a property.
  ///
  /// ينشئ كتلة الإحصاءات المختصرة المرافقة للعقار.
  const PropertyStats({
    required this.totalBookings,
    required this.activeBookings,
    required this.averageRating,
    required this.reviewCount,
    required this.occupancyRate,
    required this.monthlyRevenue,
  });

  /// Keeps equality scoped to the summary metrics.
  ///
  /// يربط المقارنة بمؤشرات الملخص فقط.
  @override
  List<Object> get props => [
        totalBookings,
        activeBookings,
        averageRating,
        reviewCount,
        occupancyRate,
        monthlyRevenue,
      ];
}
