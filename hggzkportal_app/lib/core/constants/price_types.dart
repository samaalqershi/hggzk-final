/// تصنيفات التسعير التي يستخدمها النظام لتمييز السياقات الموسمية أو الخاصة.
/// Price categories used to label base, seasonal, weekend, and special pricing rules.
class PriceType {
  /// Arabic: السعر القياسي الذي يمثل خط الأساس لكل باقي الأنواع.
  /// English: Baseline price type used as the default reference for all other categories.
  static const String base = 'Base';

  /// Arabic: نوع التسعير الذي يطبق على عطلة نهاية الأسبوع.
  /// English: Pricing type applied to weekend stays or bookings.
  static const String weekend = 'Weekend';

  /// Arabic: نوع التسعير المرتبط بالمواسم أو الفترات المتغيرة.
  /// English: Pricing type used for seasonal demand changes.
  static const String seasonal = 'Seasonal';

  /// Arabic: نوع التسعير المخصص للعطلات والمناسبات الرسمية.
  /// English: Pricing type used for holidays and public occasions.
  static const String holiday = 'Holiday';

  /// Arabic: نوع عام لحالات التسعير الخاصة غير المصنفة.
  /// English: Generic type for custom or exceptional pricing rules.
  static const String special = 'Special';

  /// Arabic: نوع التسعير المستخدم عند ذروة الطلب.
  /// English: Pricing type used during peak demand periods.
  static const String peak = 'Peak';

  /// Arabic: نوع التسعير المستخدم عند انخفاض الطلب أو الركود.
  /// English: Pricing type used during low-demand or off-peak periods.
  static const String offPeak = 'OffPeak';

  /// Arabic: نوع التسعير الذي يكافئ الحجز المبكر.
  /// English: Pricing type that rewards early booking behavior.
  static const String earlyBird = 'EarlyBird';

  /// Arabic: نوع التسعير الذي يصف الحجز في اللحظة الأخيرة.
  /// English: Pricing type that describes a last-minute booking.
  static const String lastMinute = 'LastMinute';

  /// Labels shown in Arabic when the UI presents a price type to the user.
  /// التسميات العربية التي تظهر عندما تعرض الواجهة نوع التسعير للمستخدم.
  static const Map<String, String> arabicNames = {
    base: 'السعر الأساسي',
    weekend: 'نهاية الأسبوع',
    seasonal: 'موسمي',
    holiday: 'العطلات',
    special: 'خاص',
    peak: 'الذروة',
    offPeak: 'الركود',
    earlyBird: 'الحجز المبكر',
    lastMinute: 'اللحظة الأخيرة',
  };

  /// Emoji shortcuts associated with each type for compact UI treatments.
  /// رموز مرئية مرتبطة بكل نوع لاستخدامها في المساحات المختصرة.
  static const Map<String, String> typeIcons = {
    base: '💰',
    weekend: '🌴',
    seasonal: '🌞',
    holiday: '🎉',
    special: '⭐',
    peak: '📈',
    offPeak: '📉',
    earlyBird: '🐦',
    lastMinute: '⏰',
  };

  /// Returns true when the string matches one of the supported pricing categories.
  /// يعيد true عندما يطابق النص أحد أصناف التسعير المدعومة.
  static bool isValidType(String type) {
    return arabicNames.containsKey(type);
  }

  /// Returns Arabic label for a type or the original token when unknown.
  /// يعيد الاسم العربي للنوع أو يعيد الرمز الأصلي إذا لم يكن معروفًا.
  static String getArabicName(String type) {
    return arabicNames[type] ?? type;
  }

  /// Returns UI emoji associated with the supplied type.
  /// يعيد الرمز التعبيري المرتبط بالنوع المطلوب.
  static String getIcon(String type) {
    return typeIcons[type] ?? '💰';
  }

  /// Returns canonical list of supported price type keys.
  /// يعيد القائمة القياسية لمفاتيح أنواع التسعير المدعومة.
  static List<String> getAllTypes() {
    return arabicNames.keys.toList();
  }
}

/// مستويات التسعير التي يمكن استخدامها لوصف الجودة أو الحزمة.
/// Pricing tiers used to describe quality or package level.
class PricingTier {
  /// Arabic: المستوى القياسي الذي يُستخدم كنقطة مرجعية افتراضية.
  /// English: Standard tier used as the default reference level.
  static const String standard = 'Standard';

  /// Arabic: المستوى المتميز الذي يشير إلى قيمة أعلى أو ميزات إضافية.
  /// English: Premium tier used for higher value or enhanced packages.
  static const String premium = 'Premium';

  /// Arabic: المستوى الفاخر المخصص للفئات الأعلى جودة.
  /// English: Luxury tier used for the highest-quality packages.
  static const String luxury = 'Luxury';

  /// Arabic: المستوى الاقتصادي الموجه للحلول الأقل تكلفة.
  /// English: Economy tier used for lower-cost packages.
  static const String economy = 'Economy';

  /// Arabic labels shown to users for each pricing tier.
  /// التسميات العربية المعروضة للمستخدم لكل مستوى تسعير.
  static const Map<String, String> arabicNames = {
    standard: 'قياسي',
    premium: 'متميز',
    luxury: 'فاخر',
    economy: 'اقتصادي',
  };

  /// Swatch colors used to distinguish tiers in badges and charts.
  /// الألوان المستخدمة لتمييز المستويات في الشارات والرسوم.
  static const Map<String, int> tierColors = {
    standard: 0xFF2196F3, // Blue
    premium: 0xFF9C27B0, // Purple
    luxury: 0xFFFFC107, // Amber
    economy: 0xFF4CAF50, // Green
  };

  /// Returns true when the input is one of the supported tier tokens.
  /// يعيد true عندما تكون القيمة واحدة من رموز المستويات المدعومة.
  static bool isValidTier(String tier) {
    return arabicNames.containsKey(tier);
  }

  /// Returns Arabic display name for the tier or the original token if missing.
  /// يعيد الاسم العربي للمستوى أو الرمز الأصلي إذا لم يوجد.
  static String getArabicName(String tier) {
    return arabicNames[tier] ?? tier;
  }

  /// Returns color associated with the tier for visual badges and cards.
  /// يعيد اللون المرتبط بالمستوى لاستخدامه في الشارات والبطاقات.
  static int getTierColor(String tier) {
    return tierColors[tier] ?? 0xFF2196F3;
  }

  /// Returns every supported pricing tier token in display order.
  /// يعيد كل رموز مستويات التسعير المدعومة بالترتيب المعروض.
  static List<String> getAllTiers() {
    return arabicNames.keys.toList();
  }
}
