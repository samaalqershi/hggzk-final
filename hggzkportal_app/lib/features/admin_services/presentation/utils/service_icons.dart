import 'package:flutter/material.dart';

/// 🎨 Service Icons Utility
class ServiceIcons {
  /// العربية: ينشئ مثيلًا جديدًا من `ServiceIcons._`.
  ServiceIcons._();

  /// Service Icon Model
  static const List<ServiceIconData> icons = [
    // خدمات التنظيف
    ServiceIconData(
      name: 'cleaning_services',
      label: 'خدمة تنظيف',
      icon: Icons.cleaning_services,
      category: 'تنظيف',
    ),
    ServiceIconData(
      name: 'dry_cleaning',
      label: 'تنظيف جاف',
      icon: Icons.dry_cleaning,
      category: 'تنظيف',
    ),
    ServiceIconData(
      name: 'local_laundry_service',
      label: 'خدمة غسيل',
      icon: Icons.local_laundry_service,
      category: 'تنظيف',
    ),
    ServiceIconData(
      name: 'iron',
      label: 'كوي الملابس',
      icon: Icons.iron,
      category: 'تنظيف',
    ),
    ServiceIconData(
      name: 'wash',
      label: 'غسيل',
      icon: Icons.wash,
      category: 'تنظيف',
    ),
    ServiceIconData(
      name: 'soap',
      label: 'صابون',
      icon: Icons.soap,
      category: 'تنظيف',
    ),
    ServiceIconData(
      name: 'sanitizer',
      label: 'معقم',
      icon: Icons.sanitizer,
      category: 'تنظيف',
    ),
    ServiceIconData(
      name: 'plumbing',
      label: 'سباكة',
      icon: Icons.plumbing,
      category: 'تنظيف',
    ),

    // خدمات الطعام والضيافة
    ServiceIconData(
      name: 'room_service',
      label: 'خدمة الغرف',
      icon: Icons.room_service,
      category: 'ضيافة',
    ),
    ServiceIconData(
      name: 'restaurant',
      label: 'مطعم',
      icon: Icons.restaurant,
      category: 'ضيافة',
    ),
    ServiceIconData(
      name: 'local_cafe',
      label: 'مقهى',
      icon: Icons.local_cafe,
      category: 'ضيافة',
    ),
    ServiceIconData(
      name: 'local_bar',
      label: 'بار',
      icon: Icons.local_bar,
      category: 'ضيافة',
    ),
    ServiceIconData(
      name: 'breakfast_dining',
      label: 'إفطار',
      icon: Icons.breakfast_dining,
      category: 'ضيافة',
    ),
    ServiceIconData(
      name: 'lunch_dining',
      label: 'غداء',
      icon: Icons.lunch_dining,
      category: 'ضيافة',
    ),
    ServiceIconData(
      name: 'dinner_dining',
      label: 'عشاء',
      icon: Icons.dinner_dining,
      category: 'ضيافة',
    ),
    ServiceIconData(
      name: 'delivery_dining',
      label: 'توصيل طعام',
      icon: Icons.delivery_dining,
      category: 'ضيافة',
    ),
    ServiceIconData(
      name: 'takeout_dining',
      label: 'طعام للخارج',
      icon: Icons.takeout_dining,
      category: 'ضيافة',
    ),
    ServiceIconData(
      name: 'ramen_dining',
      label: 'وجبات سريعة',
      icon: Icons.ramen_dining,
      category: 'ضيافة',
    ),
    ServiceIconData(
      name: 'icecream',
      label: 'آيس كريم',
      icon: Icons.icecream,
      category: 'ضيافة',
    ),
    ServiceIconData(
      name: 'cake',
      label: 'كيك',
      icon: Icons.cake,
      category: 'ضيافة',
    ),
    ServiceIconData(
      name: 'local_pizza',
      label: 'بيتزا',
      icon: Icons.local_pizza,
      category: 'ضيافة',
    ),
    ServiceIconData(
      name: 'fastfood',
      label: 'وجبات سريعة',
      icon: Icons.fastfood,
      category: 'ضيافة',
    ),

    // خدمات النقل والمواصلات
    ServiceIconData(
      name: 'airport_shuttle',
      label: 'نقل مطار',
      icon: Icons.airport_shuttle,
      category: 'نقل',
    ),
    ServiceIconData(
      name: 'local_taxi',
      label: 'تاكسي',
      icon: Icons.local_taxi,
      category: 'نقل',
    ),
    ServiceIconData(
      name: 'car_rental',
      label: 'تأجير سيارات',
      icon: Icons.car_rental,
      category: 'نقل',
    ),
    ServiceIconData(
      name: 'car_repair',
      label: 'صيانة سيارات',
      icon: Icons.car_repair,
      category: 'نقل',
    ),
    ServiceIconData(
      name: 'directions_car',
      label: 'سيارة خاصة',
      icon: Icons.directions_car,
      category: 'نقل',
    ),
    ServiceIconData(
      name: 'directions_bus',
      label: 'حافلة',
      icon: Icons.directions_bus,
      category: 'نقل',
    ),
    ServiceIconData(
      name: 'directions_boat',
      label: 'قارب',
      icon: Icons.directions_boat,
      category: 'نقل',
    ),
    ServiceIconData(
      name: 'directions_bike',
      label: 'دراجة',
      icon: Icons.directions_bike,
      category: 'نقل',
    ),
    ServiceIconData(
      name: 'electric_bike',
      label: 'دراجة كهربائية',
      icon: Icons.electric_bike,
      category: 'نقل',
    ),
    ServiceIconData(
      name: 'electric_scooter',
      label: 'سكوتر كهربائي',
      icon: Icons.electric_scooter,
      category: 'نقل',
    ),
    ServiceIconData(
      name: 'local_shipping',
      label: 'شحن محلي',
      icon: Icons.local_shipping,
      category: 'نقل',
    ),
    ServiceIconData(
      name: 'local_parking',
      label: 'موقف سيارات',
      icon: Icons.local_parking,
      category: 'نقل',
    ),

    // خدمات الاتصالات والإنترنت
    ServiceIconData(
      name: 'wifi',
      label: 'واي فاي',
      icon: Icons.wifi,
      category: 'اتصالات',
    ),
    ServiceIconData(
      name: 'wifi_calling',
      label: 'مكالمات واي فاي',
      icon: Icons.wifi_calling,
      category: 'اتصالات',
    ),
    ServiceIconData(
      name: 'router',
      label: 'راوتر',
      icon: Icons.router,
      category: 'اتصالات',
    ),
    ServiceIconData(
      name: 'phone_in_talk',
      label: 'خدمة هاتف',
      icon: Icons.phone_in_talk,
      category: 'اتصالات',
    ),
    ServiceIconData(
      name: 'phone_callback',
      label: 'اتصال مجاني',
      icon: Icons.phone_callback,
      category: 'اتصالات',
    ),
    ServiceIconData(
      name: 'support_agent',
      label: 'دعم العملاء',
      icon: Icons.support_agent,
      category: 'اتصالات',
    ),
    ServiceIconData(
      name: 'headset_mic',
      label: 'خدمة عملاء',
      icon: Icons.headset_mic,
      category: 'اتصالات',
    ),
    ServiceIconData(
      name: 'mail',
      label: 'بريد',
      icon: Icons.mail,
      category: 'اتصالات',
    ),
    ServiceIconData(
      name: 'markunread_mailbox',
      label: 'صندوق بريد',
      icon: Icons.markunread_mailbox,
      category: 'اتصالات',
    ),
    ServiceIconData(
      name: 'print',
      label: 'طباعة',
      icon: Icons.print,
      category: 'اتصالات',
    ),
    ServiceIconData(
      name: 'scanner',
      label: 'ماسح ضوئي',
      icon: Icons.scanner,
      category: 'اتصالات',
    ),
    ServiceIconData(
      name: 'fax',
      label: 'فاكس',
      icon: Icons.fax,
      category: 'اتصالات',
    ),

    // خدمات الترفيه والاستجمام
    ServiceIconData(
      name: 'spa',
      label: 'سبا',
      icon: Icons.spa,
      category: 'ترفيه',
    ),
    ServiceIconData(
      name: 'hot_tub',
      label: 'جاكوزي',
      icon: Icons.hot_tub,
      category: 'ترفيه',
    ),
    ServiceIconData(
      name: 'pool',
      label: 'مسبح',
      icon: Icons.pool,
      category: 'ترفيه',
    ),
    ServiceIconData(
      name: 'fitness_center',
      label: 'صالة رياضية',
      icon: Icons.fitness_center,
      category: 'ترفيه',
    ),
    ServiceIconData(
      name: 'sports_tennis',
      label: 'تنس',
      icon: Icons.sports_tennis,
      category: 'ترفيه',
    ),
    ServiceIconData(
      name: 'sports_golf',
      label: 'جولف',
      icon: Icons.sports_golf,
      category: 'ترفيه',
    ),
    ServiceIconData(
      name: 'sports_soccer',
      label: 'كرة قدم',
      icon: Icons.sports_soccer,
      category: 'ترفيه',
    ),
    ServiceIconData(
      name: 'sports_basketball',
      label: 'كرة سلة',
      icon: Icons.sports_basketball,
      category: 'ترفيه',
    ),
    ServiceIconData(
      name: 'casino',
      label: 'كازينو',
      icon: Icons.casino,
      category: 'ترفيه',
    ),
    ServiceIconData(
      name: 'theater_comedy',
      label: 'مسرح',
      icon: Icons.theater_comedy,
      category: 'ترفيه',
    ),
    ServiceIconData(
      name: 'movie',
      label: 'سينما',
      icon: Icons.movie,
      category: 'ترفيه',
    ),
    ServiceIconData(
      name: 'music_note',
      label: 'موسيقى',
      icon: Icons.music_note,
      category: 'ترفيه',
    ),
    ServiceIconData(
      name: 'nightlife',
      label: 'حياة ليلية',
      icon: Icons.nightlife,
      category: 'ترفيه',
    ),
    ServiceIconData(
      name: 'celebration',
      label: 'احتفالات',
      icon: Icons.celebration,
      category: 'ترفيه',
    ),

    // خدمات الأعمال
    ServiceIconData(
      name: 'business_center',
      label: 'مركز أعمال',
      icon: Icons.business_center,
      category: 'أعمال',
    ),
    ServiceIconData(
      name: 'meeting_room',
      label: 'قاعة اجتماعات',
      icon: Icons.meeting_room,
      category: 'أعمال',
    ),
    ServiceIconData(
      name: 'co_present',
      label: 'عرض تقديمي',
      icon: Icons.co_present,
      category: 'أعمال',
    ),
    ServiceIconData(
      name: 'groups',
      label: 'مجموعات',
      icon: Icons.groups,
      category: 'أعمال',
    ),
    ServiceIconData(
      name: 'event',
      label: 'فعاليات',
      icon: Icons.event,
      category: 'أعمال',
    ),
    ServiceIconData(
      name: 'event_available',
      label: 'حجز فعاليات',
      icon: Icons.event_available,
      category: 'أعمال',
    ),
    ServiceIconData(
      name: 'event_seat',
      label: 'مقاعد فعاليات',
      icon: Icons.event_seat,
      category: 'أعمال',
    ),
    ServiceIconData(
      name: 'mic',
      label: 'ميكروفون',
      icon: Icons.mic,
      category: 'أعمال',
    ),
    ServiceIconData(
      name: 'videocam',
      label: 'كاميرا فيديو',
      icon: Icons.videocam,
      category: 'أعمال',
    ),
    ServiceIconData(
      name: 'desktop_windows',
      label: 'كمبيوتر',
      icon: Icons.desktop_windows,
      category: 'أعمال',
    ),
    ServiceIconData(
      name: 'laptop',
      label: 'لابتوب',
      icon: Icons.laptop,
      category: 'أعمال',
    ),

    // خدمات الصحة والعناية
    ServiceIconData(
      name: 'medical_services',
      label: 'خدمات طبية',
      icon: Icons.medical_services,
      category: 'صحة',
    ),
    ServiceIconData(
      name: 'local_hospital',
      label: 'مستشفى',
      icon: Icons.local_hospital,
      category: 'صحة',
    ),
    ServiceIconData(
      name: 'local_pharmacy',
      label: 'صيدلية',
      icon: Icons.local_pharmacy,
      category: 'صحة',
    ),
    ServiceIconData(
      name: 'emergency',
      label: 'طوارئ',
      icon: Icons.emergency,
      category: 'صحة',
    ),
    ServiceIconData(
      name: 'vaccines',
      label: 'لقاحات',
      icon: Icons.vaccines,
      category: 'صحة',
    ),
    ServiceIconData(
      name: 'healing',
      label: 'علاج',
      icon: Icons.healing,
      category: 'صحة',
    ),
    ServiceIconData(
      name: 'monitor_heart',
      label: 'مراقبة صحية',
      icon: Icons.monitor_heart,
      category: 'صحة',
    ),
    ServiceIconData(
      name: 'health_and_safety',
      label: 'صحة وأمان',
      icon: Icons.health_and_safety,
      category: 'صحة',
    ),
    ServiceIconData(
      name: 'masks',
      label: 'كمامات',
      icon: Icons.masks,
      category: 'صحة',
    ),
    ServiceIconData(
      name: 'psychology',
      label: 'استشارة نفسية',
      icon: Icons.psychology,
      category: 'صحة',
    ),
    ServiceIconData(
      name: 'self_improvement',
      label: 'تطوير ذاتي',
      icon: Icons.self_improvement,
      category: 'صحة',
    ),

    // خدمات التسوق
    ServiceIconData(
      name: 'shopping_cart',
      label: 'عربة تسوق',
      icon: Icons.shopping_cart,
      category: 'تسوق',
    ),
    ServiceIconData(
      name: 'shopping_bag',
      label: 'حقيبة تسوق',
      icon: Icons.shopping_bag,
      category: 'تسوق',
    ),
    ServiceIconData(
      name: 'local_mall',
      label: 'مول',
      icon: Icons.local_mall,
      category: 'تسوق',
    ),
    ServiceIconData(
      name: 'local_grocery_store',
      label: 'بقالة',
      icon: Icons.local_grocery_store,
      category: 'تسوق',
    ),
    ServiceIconData(
      name: 'local_convenience_store',
      label: 'متجر صغير',
      icon: Icons.local_convenience_store,
      category: 'تسوق',
    ),
    ServiceIconData(
      name: 'store',
      label: 'متجر',
      icon: Icons.store,
      category: 'تسوق',
    ),
    ServiceIconData(
      name: 'storefront',
      label: 'واجهة متجر',
      icon: Icons.storefront,
      category: 'تسوق',
    ),
    ServiceIconData(
      name: 'local_offer',
      label: 'عروض',
      icon: Icons.local_offer,
      category: 'تسوق',
    ),
    ServiceIconData(
      name: 'loyalty',
      label: 'برنامج ولاء',
      icon: Icons.loyalty,
      category: 'تسوق',
    ),
    ServiceIconData(
      name: 'card_giftcard',
      label: 'بطاقة هدية',
      icon: Icons.card_giftcard,
      category: 'تسوق',
    ),

    // خدمات الأطفال والعائلة
    ServiceIconData(
      name: 'child_care',
      label: 'رعاية أطفال',
      icon: Icons.child_care,
      category: 'عائلة',
    ),
    ServiceIconData(
      name: 'baby_changing_station',
      label: 'غرفة تغيير',
      icon: Icons.baby_changing_station,
      category: 'عائلة',
    ),
    ServiceIconData(
      name: 'child_friendly',
      label: 'صديق للأطفال',
      icon: Icons.child_friendly,
      category: 'عائلة',
    ),
    ServiceIconData(
      name: 'toys',
      label: 'ألعاب',
      icon: Icons.toys,
      category: 'عائلة',
    ),
    ServiceIconData(
      name: 'stroller',
      label: 'عربة أطفال',
      icon: Icons.stroller,
      category: 'عائلة',
    ),
    ServiceIconData(
      name: 'family_restroom',
      label: 'حمام عائلي',
      icon: Icons.family_restroom,
      category: 'عائلة',
    ),
    ServiceIconData(
      name: 'escalator_warning',
      label: 'تحذير أطفال',
      icon: Icons.escalator_warning,
      category: 'عائلة',
    ),
    ServiceIconData(
      name: 'pregnant_woman',
      label: 'خدمات حوامل',
      icon: Icons.pregnant_woman,
      category: 'عائلة',
    ),

    // خدمات الحيوانات الأليفة
    ServiceIconData(
      name: 'pets',
      label: 'حيوانات أليفة',
      icon: Icons.pets,
      category: 'حيوانات',
    ),

    // خدمات الأمان
    ServiceIconData(
      name: 'security',
      label: 'أمن',
      icon: Icons.security,
      category: 'أمان',
    ),
    ServiceIconData(
      name: 'local_police',
      label: 'شرطة',
      icon: Icons.local_police,
      category: 'أمان',
    ),
    ServiceIconData(
      name: 'shield',
      label: 'حماية',
      icon: Icons.shield,
      category: 'أمان',
    ),
    ServiceIconData(
      name: 'verified_user',
      label: 'مستخدم موثق',
      icon: Icons.verified_user,
      category: 'أمان',
    ),
    ServiceIconData(
      name: 'lock',
      label: 'قفل',
      icon: Icons.lock,
      category: 'أمان',
    ),
    ServiceIconData(
      name: 'key',
      label: 'مفتاح',
      icon: Icons.key,
      category: 'أمان',
    ),
    ServiceIconData(
      name: 'doorbell',
      label: 'جرس الباب',
      icon: Icons.doorbell,
      category: 'أمان',
    ),
    ServiceIconData(
      name: 'camera_alt',
      label: 'كاميرا مراقبة',
      icon: Icons.camera_alt,
      category: 'أمان',
    ),

    // خدمات مالية
    ServiceIconData(
      name: 'local_atm',
      label: 'صراف آلي',
      icon: Icons.local_atm,
      category: 'مالية',
    ),
    ServiceIconData(
      name: 'account_balance',
      label: 'بنك',
      icon: Icons.account_balance,
      category: 'مالية',
    ),
    ServiceIconData(
      name: 'currency_exchange',
      label: 'صرافة',
      icon: Icons.currency_exchange,
      category: 'مالية',
    ),
    ServiceIconData(
      name: 'payment',
      label: 'دفع',
      icon: Icons.payment,
      category: 'مالية',
    ),
    ServiceIconData(
      name: 'credit_card',
      label: 'بطاقة ائتمان',
      icon: Icons.credit_card,
      category: 'مالية',
    ),
    ServiceIconData(
      name: 'account_balance_wallet',
      label: 'محفظة',
      icon: Icons.account_balance_wallet,
      category: 'مالية',
    ),
    ServiceIconData(
      name: 'savings',
      label: 'توفير',
      icon: Icons.savings,
      category: 'مالية',
    ),

    // خدمات أخرى
    ServiceIconData(
      name: 'handshake',
      label: 'استقبال',
      icon: Icons.handshake,
      category: 'أخرى',
    ),
    ServiceIconData(
      name: 'luggage',
      label: 'أمتعة',
      icon: Icons.luggage,
      category: 'أخرى',
    ),
    ServiceIconData(
      name: 'umbrella',
      label: 'مظلة',
      icon: Icons.umbrella,
      category: 'أخرى',
    ),
    ServiceIconData(
      name: 'translate',
      label: 'ترجمة',
      icon: Icons.translate,
      category: 'أخرى',
    ),
    ServiceIconData(
      name: 'tour',
      label: 'جولة سياحية',
      icon: Icons.tour,
      category: 'أخرى',
    ),
    ServiceIconData(
      name: 'map',
      label: 'خريطة',
      icon: Icons.map,
      category: 'أخرى',
    ),
    ServiceIconData(
      name: 'info',
      label: 'معلومات',
      icon: Icons.info,
      category: 'أخرى',
    ),
  ];

  /// Get icon by name
  static IconData getIconByName(String name) {
    final iconData = icons.firstWhere(
      (icon) => icon.name == name,
      orElse: () => const ServiceIconData(
        name: 'room_service',
        label: 'خدمة الغرف',
        icon: Icons.room_service,
        category: 'ضيافة',
      ),
    );
    return iconData.icon;
  }

  /// Get categories
  static List<String> getCategories() {
    final categories = icons.map((icon) => icon.category).toSet().toList();
    categories.sort();
    categories.insert(0, 'الكل');
    return categories;
  }

  /// Filter icons by category
  static List<ServiceIconData> filterByCategory(String category) {
    if (category == 'الكل') return icons;
    return icons.where((icon) => icon.category == category).toList();
  }

  /// Search icons
  static List<ServiceIconData> searchIcons(String query) {
    final lowerQuery = query.toLowerCase();
    return icons.where((icon) {
      return icon.name.toLowerCase().contains(lowerQuery) ||
          icon.label.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

/// Service Icon Data Model
class ServiceIconData {
  /// العربية: يخزن القيمة `name`.
  final String name;
  final String label;
  final IconData icon;
  final String category;
  const ServiceIconData({
    required this.name,
    required this.label,
    required this.icon,
    required this.category,
  });
}
