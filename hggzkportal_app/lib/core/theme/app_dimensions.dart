import 'package:flutter/material.dart';

/// قياسات موحّدة تضبط الفراغات، الأحجام، ونقاط التحول حتى تبقى الواجهات متناسقة.
/// Shared sizing tokens for spacing, typography, and responsive breakpoints across the portal UI.
class AppDimensions {
  /// Arabic: يمنع إنشاء مثيل لأن هذا الصف مجرد مخزن لقيم القياس والرديفات.
  /// English: Prevents instantiation because this class only exposes sizing tokens and helpers.
  AppDimensions._();

  /// Arabic: الحد الأعلى لعرض الهاتف قبل الانتقال إلى تخطيط أكبر.
  /// English: Maximum width treated as mobile before switching to larger layouts.
  static const double mobileBreakpoint = 600.0;

  /// Arabic: الحد الأعلى لعرض الجهاز اللوحي قبل الانتقال إلى سطح المكتب.
  /// English: Maximum width treated as tablet before switching to desktop layouts.
  static const double tabletBreakpoint = 900.0;

  /// Arabic: نقطة الانتقال الرئيسية إلى تخطيط سطح المكتب.
  /// English: Main threshold used to switch to desktop layouts.
  static const double desktopBreakpoint = 1200.0;

  /// Arabic: نقطة الانتقال إلى الشاشات الكبيرة جدًا.
  /// English: Threshold used for extra-large desktop screens.
  static const double largeDesktopBreakpoint = 1800.0;

  /// Arabic: وحدة الأساس التي تُبنى عليها أغلب قياسات الفراغ.
  /// English: Base unit used by the spacing system for consistent rhythm.
  static const double baseUnit = 8.0;

  /// Arabic: أقل حشو جانبي يستخدم للمسافات الدقيقة جدًا.
  /// English: Smallest padding token used for fine-grained spacing.
  static const double paddingXXSmall = 2.0;

  /// Arabic: حشو صغير للمسافات المتقاربة بين العناصر.
  /// English: Small padding used for closely grouped elements.
  static const double paddingXSmall = 6.0;

  /// Arabic: الحشو الأساسي للمساحات الاعتيادية حول العناصر.
  /// English: Standard padding for regular component spacing.
  static const double paddingSmall = 12.0;

  /// Arabic: حشو متوسط يمنح العناصر مجالًا بصريًا أوسع.
  /// English: Medium padding that gives components more breathing room.
  static const double paddingMedium = 20.0;

  /// Arabic: حشو كبير يحدد الأقسام أو الكتل البصرية.
  /// English: Large padding used to separate visual sections.
  static const double paddingLarge = 32.0;

  /// Arabic: حشو واسع للصفحات أو الحاويات الكبيرة.
  /// English: Extra-large padding used for roomy pages and containers.
  static const double paddingXLarge = 48.0;

  /// Arabic: حشو كبير جدًا للواجهات المفتوحة أو المجموعات المستقلة.
  /// English: Very large padding used for expansive layouts.
  static const double paddingXXLarge = 64.0;

  /// Arabic: أكبر قيمة حشو ضمن هذا النظام لتكوين فراغ بصري واضح.
  /// English: Largest padding token for strong visual separation.
  static const double paddingXXXLarge = 80.0;

  /// Arabic: الحشو القياسي لمحتوى الشاشات الصغيرة.
  /// English: Default content padding used on mobile screens.
  static const double screenPaddingMobile = 20.0;

  /// Arabic: الحشو القياسي لمحتوى الشاشات المتوسطة.
  /// English: Default content padding used on tablet screens.
  static const double screenPaddingTablet = 32.0;

  /// Arabic: الحشو القياسي لمحتوى الشاشات الواسعة.
  /// English: Default content padding used on desktop screens.
  static const double screenPaddingDesktop = 48.0;

  /// Arabic: فراغ صغير جدًا بين العناصر المتقاربة.
  /// English: Very small spacing used between tightly packed elements.
  static const double spaceXXSmall = 2.0;

  /// Arabic: فراغ صغير للمجموعات البصرية القريبة.
  /// English: Small spacing for nearby visual groups.
  static const double spaceXSmall = 6.0;

  /// Arabic: فراغ أساسي للترتيب العام بين العناصر.
  /// English: Standard spacing used throughout the layout.
  static const double spaceSmall = 12.0;

  /// Arabic: فراغ متوسط يفصل بين العناصر دون إرباك التكوين.
  /// English: Medium spacing that separates elements without breaking rhythm.
  static const double spaceMedium = 20.0;

  /// Arabic: فراغ كبير لبناء فصل واضح بين الأقسام.
  /// English: Large spacing used to separate larger content areas.
  static const double spaceLarge = 32.0;

  /// Arabic: فراغ أكبر يمنح الأقسام المستقلة حضورًا أوضح.
  /// English: Extra-large spacing for distinct content blocks.
  static const double spaceXLarge = 48.0;

  /// Arabic: فراغ واسع جدًا للأجزاء الكبيرة أو التخطيطات الممتدة.
  /// English: Very large spacing for broad layouts and wide sections.
  static const double spaceXXLarge = 64.0;

  /// Arabic: أكبر فراغ تباعدي في النظام الحالي.
  /// English: Largest spacing token in the current scale.
  static const double spaceXXXLarge = 96.0;

  /// Arabic: مسافة فصل صغيرة بين الأقسام المتتابعة.
  /// English: Small separation used between consecutive sections.
  static const double sectionSpacingSmall = 40.0;

  /// Arabic: مسافة فصل متوسطة للأقسام الاعتيادية.
  /// English: Medium separation used for regular sections.
  static const double sectionSpacingMedium = 60.0;

  /// Arabic: مسافة فصل كبيرة للأقسام البارزة أو الطويلة.
  /// English: Large separation used for prominent or long sections.
  static const double sectionSpacingLarge = 80.0;

  /// Arabic: أصغر حجم خط للاستخدامات الدقيقة جدًا أو البيانات الثانوية.
  /// English: Smallest font size used for very compact metadata.
  static const double textXXSmall = 10.0;

  /// Arabic: حجم خط صغير للتعليقات أو التوضيحات المختصرة.
  /// English: Small font size used for hints and compact labels.
  static const double textXSmall = 12.0;

  /// Arabic: حجم خط صغير قياسي للنصوص المساعدة.
  /// English: Standard small font size for helper copy.
  static const double textSmall = 14.0;

  /// Arabic: حجم خط متوسط للنصوص العامة.
  /// English: Medium font size used for most general copy.
  static const double textMedium = 16.0;

  /// Arabic: حجم خط أكبر قليلًا للعناوين الخفيفة أو البطاقات.
  /// English: Larger font size used for light headings or cards.
  static const double textLarge = 18.0;

  /// Arabic: حجم خط كبير للعناوين الأكثر حضورًا.
  /// English: Large font size used for more visible headings.
  static const double textXLarge = 22.0;

  /// Arabic: حجم خط كبير جدًا لعناوين واضحة أو أرقام لافتة.
  /// English: Extra-large font size used for prominent headings or key numbers.
  static const double textXXLarge = 28.0;

  /// Arabic: أصغر مستوى للعناوين المتدرجة.
  /// English: Smallest heading level in the display scale.
  static const double headingXSmall = 20.0;

  /// Arabic: مستوى عنوان صغير لروؤس الأقسام الفرعية.
  /// English: Small heading size used for subsection titles.
  static const double headingSmall = 24.0;

  /// Arabic: مستوى عنوان متوسط مناسب للعناوين الرئيسية داخل الصفحات.
  /// English: Medium heading size used for main in-page headings.
  static const double headingMedium = 32.0;

  /// Arabic: مستوى عنوان كبير للمناطق البارزة.
  /// English: Large heading size used for prominent sections.
  static const double headingLarge = 40.0;

  /// Arabic: مستوى عنوان أكبر للعناوين الافتتاحية أو البطاقات المميزة.
  /// English: Extra-large heading size for introductory or featured titles.
  static const double headingXLarge = 48.0;

  /// Arabic: حجم العرض المستخدم في العناوين المفتاحية.
  /// English: Display size used for key feature headings.
  static const double headingDisplay = 64.0;

  /// Arabic: أكبر حجم عرض مخصص للعناوين hero في الصفحات.
  /// English: Hero display size used for the largest page titles.
  static const double headingHero = 80.0;

  /// Arabic: ارتفاع سطر مضغوط للعناوين أو النصوص الكثيفة.
  /// English: Tight line height used for headings or compact text.
  static const double lineHeightTight = 1.2;

  /// Arabic: ارتفاع سطر قياسي للنصوص اليومية.
  /// English: Normal line height for general-purpose copy.
  static const double lineHeightNormal = 1.5;

  /// Arabic: ارتفاع سطر مريح للنصوص الطويلة أو الوصفية.
  /// English: Relaxed line height for longer descriptive text.
  static const double lineHeightRelaxed = 1.75;

  /// Arabic: ارتفاع سطر واسع جدًا للنصوص التي تحتاج تنفسًا بصريًا.
  /// English: Loose line height for copy that needs extra breathing room.
  static const double lineHeightLoose = 2.0;

  /// Arabic: تباعد ضيق بين الحروف للنصوص الكبيرة أو العناوين.
  /// English: Tight letter spacing used for large text and headings.
  static const double letterSpacingTight = -0.5;

  /// Arabic: التباعد الطبيعي بين الحروف.
  /// English: Normal letter spacing used for most text.
  static const double letterSpacingNormal = 0.0;

  /// Arabic: تباعد واسع قليلًا لإبراز بعض التسميات أو الأكواد.
  /// English: Wider spacing used to emphasize labels or codes.
  static const double letterSpacingWide = 0.5;

  /// Arabic: تباعد واسع جدًا للعناوين العلوية أو الوسوم.
  /// English: Extra-wide spacing used for overlines or prominent labels.
  static const double letterSpacingExtraWide = 1.0;

  /// Arabic: نصف قطر صفري للحواف الحادة تمامًا.
  /// English: Zero radius for fully sharp corners.
  static const double radiusNone = 0.0;

  /// Arabic: نصف قطر صغير للحواف الهادئة.
  /// English: Small radius used for subtle rounded corners.
  static const double radiusXSmall = 6.0;

  /// Arabic: نصف قطر صغير قياسي.
  /// English: Standard small radius for regular components.
  static const double radiusSmall = 12.0;

  /// Arabic: نصف قطر متوسط للبطاقات والأسطح.
  /// English: Medium radius used for cards and surfaces.
  static const double radiusMedium = 16.0;

  /// Arabic: نصف قطر كبير للحاويات الأوضح بروزًا.
  /// English: Large radius used for more prominent containers.
  static const double radiusLarge = 20.0;

  /// Arabic: نصف قطر واسع للعناصر المميزة أو النوافذ المنبثقة.
  /// English: Extra-large radius used for featured elements and dialogs.
  static const double radiusXLarge = 28.0;

  /// Arabic: نصف قطر كبير جدًا يمنح العنصر مظهرًا ناعمًا.
  /// English: Very large radius that produces a soft, premium shape.
  static const double radiusXXLarge = 40.0;

  /// Arabic: نصف قطر دائري شبه كامل للأزرار والأيقونات الدائرية.
  /// English: Near-circular radius used for pill buttons and round controls.
  static const double radiusCircular = 999.0;

  /// Arabic: اسم بديل لنصف قطر الحواف الصغيرة للتوافق مع الثيمات القديمة.
  /// English: Alias for the extra-small radius kept for theme compatibility.
  static const double borderRadiusXs = radiusXSmall;

  /// Arabic: نصف قطر البطاقات القياسي.
  /// English: Standard card radius.
  static const double cardRadius = 20.0;

  /// Arabic: نصف قطر بطاقات أصغر قليلًا.
  /// English: Slightly smaller radius for compact cards.
  static const double cardRadiusSmall = 16.0;

  /// Arabic: نصف قطر النوافذ المنبثقة.
  /// English: Radius used for modal dialogs.
  static const double modalRadius = 28.0;

  /// Arabic: نصف قطر اللوحات السفلية.
  /// English: Radius used for bottom sheets.
  static const double bottomSheetRadius = 32.0;

  /// Arabic: حجم الأيقونة الأصغر جدًا للاستخدامات الدقيقة.
  /// English: Very small icon size for compact UI elements.
  static const double iconXXSmall = 14.0;

  /// Arabic: حجم أيقونة صغير.
  /// English: Small icon size.
  static const double iconXSmall = 18.0;

  /// Arabic: حجم أيقونة قياسي.
  /// English: Standard icon size.
  static const double iconSmall = 22.0;

  /// Arabic: حجم أيقونة متوسط.
  /// English: Medium icon size.
  static const double iconMedium = 26.0;

  /// Arabic: حجم أيقونة كبير.
  /// English: Large icon size.
  static const double iconLarge = 32.0;

  /// Arabic: حجم أيقونة أكبر للعناصر البارزة.
  /// English: Extra-large icon size for more prominent controls.
  static const double iconXLarge = 40.0;

  /// Arabic: حجم أيقونة كبير جدًا.
  /// English: Very large icon size.
  static const double iconXXLarge = 56.0;

  /// Arabic: حجم أيقونة ضخم للرموز أو الرسوم البارزة.
  /// English: Huge icon size used for standout glyphs or illustrations.
  static const double iconHuge = 72.0;

  /// Arabic: ارتفاع زر صغير جدًا.
  /// English: Extra-small button height.
  static const double buttonHeightXSmall = 36.0;

  /// Arabic: ارتفاع زر صغير.
  /// English: Small button height.
  static const double buttonHeightSmall = 44.0;

  /// Arabic: ارتفاع زر متوسط.
  /// English: Medium button height.
  static const double buttonHeightMedium = 52.0;

  /// Arabic: ارتفاع زر كبير.
  /// English: Large button height.
  static const double buttonHeightLarge = 60.0;

  /// Arabic: ارتفاع زر كبير جدًا.
  /// English: Extra-large button height.
  static const double buttonHeightXLarge = 68.0;

  /// Arabic: ارتفاع حقل إدخال صغير.
  /// English: Small input field height.
  static const double inputHeightSmall = 48.0;

  /// Arabic: ارتفاع حقل إدخال متوسط.
  /// English: Medium input field height.
  static const double inputHeightMedium = 56.0;

  /// Arabic: ارتفاع حقل إدخال كبير.
  /// English: Large input field height.
  static const double inputHeightLarge = 64.0;

  /// Arabic: ارتفاع شريط التطبيق القياسي.
  /// English: Standard app bar height.
  static const double appBarHeight = 64.0;

  /// Arabic: ارتفاع شريط التطبيق الأكبر.
  /// English: Taller app bar height used in premium layouts.
  static const double appBarHeightLarge = 72.0;

  /// Arabic: ارتفاع شريط التبويبات.
  /// English: Tab bar height.
  static const double tabBarHeight = 56.0;

  /// Arabic: ارتفاع شريط التنقل السفلي.
  /// English: Bottom navigation height.
  static const double bottomNavHeight = 72.0;

  /// Arabic: ارتفاع شريط التنقل السفلي عند ظهور التسمية.
  /// English: Bottom navigation height when labels are shown.
  static const double bottomNavHeightWithLabel = 80.0;

  /// Arabic: ارتفاع بطاقة صغيرة.
  /// English: Small card height.
  static const double cardHeightSmall = 100.0;

  /// Arabic: ارتفاع بطاقة متوسطة.
  /// English: Medium card height.
  static const double cardHeightMedium = 140.0;

  /// Arabic: ارتفاع بطاقة كبيرة.
  /// English: Large card height.
  static const double cardHeightLarge = 200.0;

  /// Arabic: ارتفاع عنصر قائمة صغير.
  /// English: Small list item height.
  static const double listItemHeightSmall = 64.0;

  /// Arabic: ارتفاع عنصر قائمة متوسط.
  /// English: Medium list item height.
  static const double listItemHeightMedium = 80.0;

  /// Arabic: ارتفاع عنصر قائمة كبير.
  /// English: Large list item height.
  static const double listItemHeightLarge = 96.0;

  /// Arabic: ارتفاع بطاقة العقار الأساسية.
  /// English: Standard property card height.
  static const double propertyCardHeight = 320.0;

  /// Arabic: ارتفاع بطاقة العقار المضغوطة.
  /// English: Compact property card height.
  static const double propertyCardHeightCompact = 240.0;

  /// Arabic: ارتفاع صورة بطاقة العقار الأساسية.
  /// English: Standard property card image height.
  static const double propertyCardImageHeight = 200.0;

  /// Arabic: ارتفاع صورة بطاقة العقار المضغوطة.
  /// English: Compact property card image height.
  static const double propertyCardImageHeightCompact = 140.0;

  /// Arabic: ارتفاع البطاقة المميزة.
  /// English: Featured card height.
  static const double featuredCardHeight = 400.0;

  /// Arabic: عرض البطاقة المميزة.
  /// English: Featured card width.
  static const double featuredCardWidth = 300.0;

  /// Arabic: ارتفاع شريط البحث.
  /// English: Search bar height.
  static const double searchBarHeight = 64.0;

  /// Arabic: ارتفاع شريط البحث الموسع.
  /// English: Expanded search bar height.
  static const double searchBarHeightExpanded = 72.0;

  /// Arabic: ارتفاع شريحة الفلتر.
  /// English: Filter chip height.
  static const double filterChipHeight = 40.0;

  /// Arabic: ارتفاع شريط الفلاتر.
  /// English: Filter bar height.
  static const double filterBarHeight = 56.0;

  /// Arabic: حجم يوم التقويم.
  /// English: Calendar day tile size.
  static const double calendarDaySize = 48.0;

  /// Arabic: ارتفاع عرض الشهر في التقويم.
  /// English: Month view height in the calendar.
  static const double calendarMonthHeight = 360.0;

  /// Arabic: ارتفاع منتقي نطاق التاريخ.
  /// English: Date-range picker height.
  static const double dateRangePickerHeight = 400.0;

  /// Arabic: ارتفاع ملخص الحجز.
  /// English: Booking summary height.
  static const double bookingSummaryHeight = 180.0;

  /// Arabic: ارتفاع منطقة عرض السعر.
  /// English: Price display height.
  static const double priceDisplayHeight = 80.0;

  /// Arabic: ارتفاع بطاقة المراجعة.
  /// English: Review card height.
  static const double reviewCardHeight = 160.0;

  /// Arabic: حجم نجمة التقييم القياسية.
  /// English: Standard rating star size.
  static const double ratingStarSize = 20.0;

  /// Arabic: حجم نجمة التقييم الكبيرة.
  /// English: Large rating star size.
  static const double ratingStarSizeLarge = 28.0;

  /// Arabic: عرض زر صغير.
  /// English: Small button width.
  static const double buttonWidthSmall = 120.0;

  /// Arabic: عرض زر متوسط.
  /// English: Medium button width.
  static const double buttonWidthMedium = 160.0;

  /// Arabic: عرض زر كبير.
  /// English: Large button width.
  static const double buttonWidthLarge = 220.0;

  /// Arabic: عرض ممتد كامل للعناصر التي يجب أن تملأ المساحة.
  /// English: Full-width token used when a component should stretch fully.
  static const double buttonWidthFull = double.infinity;

  /// Arabic: أقصى عرض للمحتوى في الهاتف.
  /// English: Maximum content width on mobile screens.
  static const double maxContentWidthMobile = 600.0;

  /// Arabic: أقصى عرض للمحتوى في الأجهزة اللوحية.
  /// English: Maximum content width on tablets.
  static const double maxContentWidthTablet = 900.0;

  /// Arabic: أقصى عرض للمحتوى في سطح المكتب.
  /// English: Maximum content width on desktop screens.
  static const double maxContentWidthDesktop = 1200.0;

  /// Arabic: أقصى عرض للمحتوى في الشاشات الكبيرة جدًا.
  /// English: Maximum content width on large displays.
  static const double maxContentWidthLarge = 1440.0;

  /// Arabic: عرض الشريط الجانبي المضغوط.
  /// English: Compact sidebar width.
  static const double sidebarWidthCompact = 72.0;

  /// Arabic: عرض الشريط الجانبي المتوسط.
  /// English: Medium sidebar width.
  static const double sidebarWidthMedium = 280.0;

  /// Arabic: عرض الشريط الجانبي الكبير.
  /// English: Large sidebar width.
  static const double sidebarWidthLarge = 320.0;

  /// Arabic: عرض لوحة الفلاتر.
  /// English: Filter panel width.
  static const double filterPanelWidth = 320.0;

  /// Arabic: الارتفاع الصفري دون أي بروز.
  /// English: Zero elevation with no shadow.
  static const double elevationNone = 0.0;

  /// Arabic: ارتفاع صغير جدًا للظلال البسيطة.
  /// English: Very small elevation for subtle shadows.
  static const double elevationXSmall = 1.0;

  /// Arabic: ارتفاع صغير.
  /// English: Small elevation.
  static const double elevationSmall = 2.0;

  /// Arabic: ارتفاع متوسط.
  /// English: Medium elevation.
  static const double elevationMedium = 4.0;

  /// Arabic: ارتفاع كبير.
  /// English: Large elevation.
  static const double elevationLarge = 8.0;

  /// Arabic: ارتفاع أكبر للعناصر البارزة.
  /// English: Extra-large elevation for prominent elements.
  static const double elevationXLarge = 12.0;

  /// Arabic: أعلى ارتفاع قياسي في النظام.
  /// English: Highest standard elevation in the scale.
  static const double elevationXXLarge = 24.0;

  /// Arabic: مقدار تمويه صغير جدًا للظل.
  /// English: Very small shadow blur radius.
  static const double shadowBlurXSmall = 4.0;

  /// Arabic: مقدار تمويه صغير للظل.
  /// English: Small shadow blur radius.
  static const double shadowBlurSmall = 8.0;

  /// Arabic: مقدار تمويه متوسط للظل.
  /// English: Medium shadow blur radius.
  static const double shadowBlurMedium = 16.0;

  /// Arabic: مقدار تمويه كبير للظل.
  /// English: Large shadow blur radius.
  static const double shadowBlurLarge = 24.0;

  /// Arabic: مقدار تمويه أكبر جدًا للظل.
  /// English: Extra-large shadow blur radius.
  static const double shadowBlurXLarge = 40.0;

  /// Arabic: مقدار انتشار سلبي خفيف لتقليل حدة الظل.
  /// English: Subtle negative spread to soften the shadow edge.
  static const double shadowSpreadSubtle = -2.0;

  /// Arabic: مقدار انتشار افتراضي للظل.
  /// English: Default shadow spread value.
  static const double shadowSpreadNormal = 0.0;

  /// Arabic: مقدار انتشار واسع للظل.
  /// English: Wide shadow spread value.
  static const double shadowSpreadWide = 4.0;

  /// Arabic: حد صفري بلا خط.
  /// English: No border width.
  static const double borderNone = 0.0;

  /// Arabic: حد رفيع للعناصر الخفيفة.
  /// English: Thin border for light separators.
  static const double borderThin = 1.0;

  /// Arabic: حد متوسط للعناصر الأكثر وضوحًا.
  /// English: Medium border for more visible separation.
  static const double borderMedium = 1.5;

  /// Arabic: حد سميك للعناصر البارزة أو التحديدات.
  /// English: Thick border used for emphasis or selection.
  static const double borderThick = 2.0;

  /// Arabic: حد عريض جدًا للحالات الخاصة.
  /// English: Bold border used in special emphasis cases.
  static const double borderBold = 3.0;

  /// Arabic: حجم الصورة المصغرة الصغير جدًا.
  /// English: Very small thumbnail size.
  static const double thumbnailSizeXSmall = 48.0;

  /// Arabic: حجم الصورة المصغرة الصغير.
  /// English: Small thumbnail size.
  static const double thumbnailSizeSmall = 64.0;

  /// Arabic: حجم الصورة المصغرة المتوسط.
  /// English: Medium thumbnail size.
  static const double thumbnailSizeMedium = 96.0;

  /// Arabic: حجم الصورة المصغرة الكبير.
  /// English: Large thumbnail size.
  static const double thumbnailSizeLarge = 128.0;

  /// Arabic: حجم الصورة الشخصية الصغير جدًا.
  /// English: Very small avatar size.
  static const double avatarSizeXSmall = 28.0;

  /// Arabic: حجم الصورة الشخصية الصغير.
  /// English: Small avatar size.
  static const double avatarSizeSmall = 36.0;

  /// Arabic: حجم الصورة الشخصية المتوسط.
  /// English: Medium avatar size.
  static const double avatarSizeMedium = 48.0;

  /// Arabic: حجم الصورة الشخصية الكبير.
  /// English: Large avatar size.
  static const double avatarSizeLarge = 64.0;

  /// Arabic: حجم الصورة الشخصية الكبير جدًا.
  /// English: Extra-large avatar size.
  static const double avatarSizeXLarge = 96.0;

  /// Arabic: ارتفاع صورة المعرض.
  /// English: Gallery image height.
  static const double galleryImageHeight = 360.0;

  /// Arabic: حجم صورة المعاينة في المعرض.
  /// English: Thumbnail size used in galleries.
  static const double galleryThumbnailSize = 80.0;

  /// Arabic: المسافة بين صور المعرض.
  /// English: Spacing used between gallery items.
  static const double gallerySpacing = 12.0;

  /// Arabic: ارتفاع صورة الهيرو في الهاتف.
  /// English: Hero image height on mobile devices.
  static const double heroImageHeightMobile = 240.0;

  /// Arabic: ارتفاع صورة الهيرو في الجهاز اللوحي.
  /// English: Hero image height on tablets.
  static const double heroImageHeightTablet = 360.0;

  /// Arabic: ارتفاع صورة الهيرو في سطح المكتب.
  /// English: Hero image height on desktop screens.
  static const double heroImageHeightDesktop = 480.0;

  /// Arabic: ارتفاع الخريطة الصغير.
  /// English: Small map height.
  static const double mapHeightSmall = 200.0;

  /// Arabic: ارتفاع الخريطة المتوسط.
  /// English: Medium map height.
  static const double mapHeightMedium = 300.0;

  /// Arabic: ارتفاع الخريطة الكبير.
  /// English: Large map height.
  static const double mapHeightLarge = 400.0;

  /// Arabic: ارتفاع الخريطة الممتد على كامل المساحة.
  /// English: Fullscreen map height token.
  static const double mapHeightFullscreen = double.infinity;

  /// Arabic: حجم مؤشر الخريطة.
  /// English: Map marker size.
  static const double mapMarkerSize = 48.0;

  /// Arabic: حجم تجمع الخرائط.
  /// English: Map cluster size.
  static const double mapClusterSize = 56.0;

  /// Arabic: قيمة مدة الحركة الفورية.
  /// English: Duration value for instant animations.
  static const int animationInstant = 0;

  /// Arabic: مدة حركة سريعة.
  /// English: Fast animation duration.
  static const int animationFast = 150;

  /// Arabic: مدة حركة قياسية.
  /// English: Normal animation duration.
  static const int animationNormal = 250;

  /// Arabic: مدة حركة بطيئة.
  /// English: Slow animation duration.
  static const int animationSlow = 350;

  /// Arabic: مدة حركة بطيئة جدًا.
  /// English: Slowest animation duration.
  static const int animationSlowest = 500;

  /// Arabic: المنحنى الافتراضي للرسوم الحركية.
  /// English: Default animation curve.
  static const Curve animationCurveDefault = Curves.easeInOutCubic;

  /// Arabic: منحنى حاد ينهي الحركة بسرعة.
  /// English: Sharp curve that ends motion quickly.
  static const Curve animationCurveSharp = Curves.easeOutQuart;

  /// Arabic: منحنى ناعم للحركات الانسيابية.
  /// English: Smooth curve for fluid motion.
  static const Curve animationCurveSmooth = Curves.easeInOutQuint;

  /// Arabic: عدد أعمدة الشبكة في الهاتف.
  /// English: Grid column count on mobile devices.
  static const int gridColumnsMobile = 2;

  /// Arabic: عدد أعمدة الشبكة في الجهاز اللوحي.
  /// English: Grid column count on tablets.
  static const int gridColumnsTablet = 3;

  /// Arabic: عدد أعمدة الشبكة في سطح المكتب.
  /// English: Grid column count on desktop.
  static const int gridColumnsDesktop = 4;

  /// Arabic: عدد أعمدة الشبكة في الشاشات الكبيرة جدًا.
  /// English: Grid column count on large displays.
  static const int gridColumnsLarge = 5;

  /// Arabic: فراغ الشبكة الصغير.
  /// English: Small grid spacing.
  static const double gridSpacingSmall = 12.0;

  /// Arabic: فراغ الشبكة المتوسط.
  /// English: Medium grid spacing.
  static const double gridSpacingMedium = 20.0;

  /// Arabic: فراغ الشبكة الكبير.
  /// English: Large grid spacing.
  static const double gridSpacingLarge = 28.0;

  /// Arabic: نسبة العرض إلى الارتفاع للمربع.
  /// English: Aspect ratio for square tiles.
  static const double gridAspectRatioSquare = 1.0;

  /// Arabic: نسبة العرض إلى الارتفاع الأفقي.
  /// English: Landscape aspect ratio for grid tiles.
  static const double gridAspectRatioLandscape = 1.33;

  /// Arabic: نسبة العرض إلى الارتفاع العمودية.
  /// English: Portrait aspect ratio for grid tiles.
  static const double gridAspectRatioPortrait = 0.75;

  /// Arabic: نسبة العرض إلى الارتفاع الواسعة.
  /// English: Wide aspect ratio for grid tiles.
  static const double gridAspectRatioWide = 1.77;

  /// Arabic: عرض النافذة الصغيرة.
  /// English: Small modal width.
  static const double modalWidthSmall = 320.0;

  /// Arabic: عرض النافذة المتوسط.
  /// English: Medium modal width.
  static const double modalWidthMedium = 480.0;

  /// Arabic: عرض النافذة الكبير.
  /// English: Large modal width.
  static const double modalWidthLarge = 640.0;

  /// Arabic: الحد الأقصى لارتفاع النافذة كنسبة من الشاشة.
  /// English: Maximum modal height as a fraction of screen height.
  static const double modalMaxHeight = 0.9; // 90% of screen height
  /// Arabic: الحد الأقصى لارتفاع اللوحة السفلية كنسبة من الشاشة.
  /// English: Maximum bottom sheet height as a fraction of screen height.
  static const double bottomSheetMaxHeight = 0.85;

  /// Arabic: الحد الأدنى لارتفاع اللوحة السفلية.
  /// English: Minimum bottom sheet height.
  static const double bottomSheetMinHeight = 120.0;

  /// Arabic: حجم زر الإجراء العائم الصغير.
  /// English: Small floating action button size.
  static const double fabSizeSmall = 48.0;

  /// Arabic: حجم زر الإجراء العائم المتوسط.
  /// English: Medium floating action button size.
  static const double fabSizeMedium = 56.0;

  /// Arabic: حجم زر الإجراء العائم الكبير.
  /// English: Large floating action button size.
  static const double fabSizeLarge = 64.0;

  /// Arabic: الهامش المحيط بالعناصر العائمة.
  /// English: Margin around floating elements.
  static const double fabMargin = 16.0;

  /// Arabic: يعيد الحشو المناسب بحسب عرض الشاشة الحالي.
  /// English: Returns the appropriate padding for the current screen width.
  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return screenPaddingMobile;
    if (width < tabletBreakpoint) return screenPaddingTablet;
    return screenPaddingDesktop;
  }

  /// Arabic: يعيد عدد الأعمدة المناسب للشبكة الحالية بحسب عرض الشاشة.
  /// English: Returns the proper grid column count for the current screen width.
  static int getResponsiveGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return gridColumnsMobile;
    if (width < tabletBreakpoint) return gridColumnsTablet;
    if (width < desktopBreakpoint) return gridColumnsDesktop;
    return gridColumnsLarge;
  }

  /// Arabic: يعيد عرض المحتوى المناسب للشاشة الحالية مع استخدام قيم احتياطية ثابتة.
  /// English: Returns the appropriate content width for the current screen with fallback breakpoints.
  static double getResponsiveContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return width;
    if (width < tabletBreakpoint) return maxContentWidthTablet;
    if (width < desktopBreakpoint) return maxContentWidthDesktop;
    return maxContentWidthLarge;
  }

  /// Arabic: يتحقق ما إذا كانت الشاشة الحالية ضمن فئة الهاتف.
  /// English: Checks whether the current screen should be treated as mobile.
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  /// Arabic: يتحقق ما إذا كانت الشاشة الحالية ضمن فئة الجهاز اللوحي.
  /// English: Checks whether the current screen should be treated as tablet.
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  /// Arabic: يتحقق ما إذا كانت الشاشة الحالية ضمن فئة سطح المكتب.
  /// English: Checks whether the current screen should be treated as desktop.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;
}
