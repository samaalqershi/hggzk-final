import 'package:equatable/equatable.dart';
import 'section_image.dart';

/// Represents a property as it appears inside a curated section, including
/// presentation fields, ranking data, and tracking metrics.
///
/// يمثل العقار كما يظهر داخل قسم منسق، مع حقول العرض وبيانات الترتيب
/// ومؤشرات التتبع.
class PropertyInSection extends Equatable {
  /// Stable identifier for the section-item record.
  ///
  /// المعرّف الثابت لسجل العنصر داخل القسم.
  final String id;

  /// Parent section that owns this property tile.
  ///
  /// القسم الأب الذي يملك بطاقة هذا العقار.
  final String sectionId;

  /// Canonical property identifier.
  ///
  /// معرّف العقار القياسي.
  final String propertyId;

  /// Display name shown in the section card.
  ///
  /// اسم العرض الظاهر في بطاقة القسم.
  final String propertyName;

  /// Property address shown to managers and in previews.
  ///
  /// عنوان العقار الظاهر للإدارة وفي المعاينات.
  final String address;

  /// City used for grouping and filtering.
  ///
  /// المدينة المستخدمة في التجميع والفلترة.
  final String city;

  /// Latitude used by map and proximity experiences.
  ///
  /// خط العرض المستخدم في الخرائط وتجارب القرب.
  final double latitude;

  /// Longitude used by map and proximity experiences.
  ///
  /// خط الطول المستخدم في الخرائط وتجارب القرب.
  final double longitude;

  /// Human-readable type label for the property.
  ///
  /// تسمية نوع العقار المقروءة بشريًا.
  final String propertyType;

  /// Provider rating used by the card and filters.
  ///
  /// التصنيف المعتمد المستخدم في البطاقة والفلاتر.
  final int starRating;

  /// Guest review average shown in the card.
  ///
  /// متوسط تقييم الضيوف الظاهر في البطاقة.
  final double averageRating;

  /// Number of reviews behind the average.
  ///
  /// عدد المراجعات التي بني عليها المتوسط.
  final int reviewsCount;

  /// Base nightly price before adjustments.
  ///
  /// السعر الليلي الأساسي قبل التعديلات.
  final double basePrice;

  /// Currency used for displayed prices.
  ///
  /// العملة المستخدمة لعرض الأسعار.
  final String currency;

  /// Primary image shown in the section card.
  ///
  /// الصورة الرئيسية الظاهرة في بطاقة القسم.
  final String? mainImageUrl;

  /// Additional media shown in the details panel.
  ///
  /// الوسائط الإضافية الظاهرة في لوحة التفاصيل.
  final List<SectionImage> additionalImages;

  /// Short editorial description used in compact views.
  ///
  /// وصف تحريري قصير يستخدم في العروض المختصرة.
  final String? shortDescription;

  /// Visual order inside the section.
  ///
  /// الترتيب المرئي داخل القسم.
  final int displayOrder;

  /// Marks the property as a featured entry.
  ///
  /// يميز العقار كعنصر بارز.
  final bool isFeatured;

  /// Optional discount percentage shown in the card.
  ///
  /// نسبة خصم اختيارية تظهر في البطاقة.
  final double? discountPercentage;

  /// Marketing copy or promotion label.
  ///
  /// نص تسويقي أو تسمية ترويجية.
  final String? promotionalText;

  /// Optional badge text.
  ///
  /// نص شارة اختياري.
  final String? badge;

  /// Badge accent color token.
  ///
  /// رمز لون الشارة.
  final String? badgeColor;

  /// Start date for displaying the property in the section.
  ///
  /// تاريخ بدء عرض العقار داخل القسم.
  final DateTime? displayFrom;

  /// End date for displaying the property in the section.
  ///
  /// تاريخ انتهاء عرض العقار داخل القسم.
  final DateTime? displayUntil;

  /// Explicit priority used when sections are sorted.
  ///
  /// الأولوية الصريحة المستخدمة عند فرز الأقسام.
  final int priority;

  /// Views attributed to this section placement.
  ///
  /// المشاهدات المنسوبة إلى موضع هذا القسم.
  final int viewsFromSection;

  /// Click count recorded from the section.
  ///
  /// عدد النقرات المسجل من القسم.
  final int clickCount;

  /// Conversion rate derived from section interactions.
  ///
  /// معدل التحويل المستنتج من تفاعلات القسم.
  final double? conversionRate;

  /// Additional structured data preserved for custom section features.
  ///
  /// بيانات إضافية منظمة محفوظة لميزات القسم المخصصة.
  final Map<String, dynamic>? metadata;

  /// Creates the placement record used by curated property sections.
  ///
  /// ينشئ سجل التموضع المستخدم في أقسام العقارات المنسقة.
  const PropertyInSection({
    required this.id,
    required this.sectionId,
    required this.propertyId,
    required this.propertyName,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.propertyType,
    required this.starRating,
    required this.averageRating,
    required this.reviewsCount,
    required this.basePrice,
    required this.currency,
    this.mainImageUrl,
    this.additionalImages = const [],
    this.shortDescription,
    required this.displayOrder,
    this.isFeatured = false,
    this.discountPercentage,
    this.promotionalText,
    this.badge,
    this.badgeColor,
    this.displayFrom,
    this.displayUntil,
    this.priority = 0,
    this.viewsFromSection = 0,
    this.clickCount = 0,
    this.conversionRate,
    this.metadata,
  });

  /// Keeps equality aligned with the section placement snapshot.
  ///
  /// يربط المقارنة بلقطة التموضع داخل القسم.
  @override
  List<Object?> get props => [
        id,
        sectionId,
        propertyId,
        propertyName,
        address,
        city,
        latitude,
        longitude,
        propertyType,
        starRating,
        averageRating,
        reviewsCount,
        basePrice,
        currency,
        mainImageUrl,
        additionalImages,
        shortDescription,
        displayOrder,
        isFeatured,
        discountPercentage,
        promotionalText,
        badge,
        badgeColor,
        displayFrom,
        displayUntil,
        priority,
        viewsFromSection,
        clickCount,
        conversionRate,
        metadata,
      ];
}
