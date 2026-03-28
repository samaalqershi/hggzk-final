// lib/core/constants/animation_constants.dart

import 'package:flutter/animation.dart';

/// Arabic: مركز القيم القياسية للحركات حتى تستخدم الشاشات نفس الإيقاع واللغة البصرية.
/// English: Central animation tokens that keep motion, timing, and transitions consistent across the app.
class AnimationConstants {
  /// Arabic: يمنع إنشاء مثيل من هذا الصف لأنه يعمل كحاوية ثوابت فقط.
  /// English: Prevents instantiation because this class is used as a constant holder only.
  AnimationConstants._();

  /// Arabic: اسم الانتقال المستخدم عندما تكون الحركة تلاشيًا بسيطًا.
  /// English: Token used when a widget or route relies on a fade transition.
  static const String fadeAnimation = 'fade';

  /// Arabic: اسم الانتقال المستخدم للحركات التي تنزلق من طرف الشاشة.
  /// English: Token used for transitions that slide content from an edge.
  static const String slideAnimation = 'slide';

  /// Arabic: اسم الانتقال المستخدم لتكبير أو تصغير العناصر أثناء الظهور.
  /// English: Token used for scale-based entrance or emphasis animations.
  static const String scaleAnimation = 'scale';

  /// Arabic: اسم الانتقال المستخدم للحركة الدورانية في العناصر التفاعلية.
  /// English: Token used for rotation-based motion in interactive elements.
  static const String rotateAnimation = 'rotate';

  /// Arabic: اسم الانتقال المستخدم لإظهار العمق أو الحركة البصرية البطيئة.
  /// English: Token used for depth-like motion and slow visual shifts.
  static const String parallaxAnimation = 'parallax';

  /// Arabic: اسم الانتقال المستخدم لتمرير تأثير اللمعان عبر العناصر.
  /// English: Token used for shimmer sweeps across placeholders and cards.
  static const String shimmerAnimation = 'shimmer';

  /// Arabic: اسم الانتقال المستخدم لإظهار نبضة خفيفة حول العنصر.
  /// English: Token used for subtle pulse feedback around a widget.
  static const String pulseAnimation = 'pulse';

  /// Arabic: اسم الانتقال المستخدم لحركة الارتداد الصغيرة في الواجهات.
  /// English: Token used for small bounce feedback in the UI.
  static const String bounceAnimation = 'bounce';

  /// Arabic: اسم الانتقال المستخدم للحركة التي تقلب العنصر بين الجهتين.
  /// English: Token used for flip-style motion between the two faces of a widget.
  static const String flipAnimation = 'flip';

  /// Arabic: أقل مدة مستخدمة للحركات السريعة جدًا مثل الاهتزازات الخفيفة.
  /// English: Shortest duration used for very fast motion such as light feedback.
  static const Duration microDuration = Duration(milliseconds: 100);

  /// Arabic: مدة قصيرة تناسب التفاعل السريع أو الانتقال الخفيف.
  /// English: Short duration suitable for quick interactions or light transitions.
  static const Duration shortDuration = Duration(milliseconds: 200);

  /// Arabic: المدة الافتراضية للحركات العامة التي يجب أن تبقى واضحة وغير مزعجة.
  /// English: Default duration for general-purpose motion that should remain noticeable but calm.
  static const Duration mediumDuration = Duration(milliseconds: 300);

  /// Arabic: مدة أطول للحركات التي تحتاج حضورًا بصريًا أو انتقالًا واضحًا.
  /// English: Longer duration for motions that need stronger visual presence.
  static const Duration longDuration = Duration(milliseconds: 500);

  /// Arabic: مدة ممتدة للتأثيرات التي يُراد لها أن تبدو أكثر سلاسة وهدوءًا.
  /// English: Extended duration for effects that should feel smoother and slower.
  static const Duration extraLongDuration = Duration(milliseconds: 800);

  /// Arabic: المنحنى الافتراضي الذي يوازن بين البداية والنهاية بسلاسة.
  /// English: Default curve that balances motion in and out smoothly.
  static const Curve defaultCurve = Curves.easeInOut;

  /// Arabic: منحنى مناسب لحركات الارتداد والنتوءات السريعة.
  /// English: Curve suited for bounce-like motion and quick rebounds.
  static const Curve bounceCurve = Curves.bounceOut;

  /// Arabic: منحنى مرن يعطي إحساسًا مطاطيًا أو نابضًا.
  /// English: Elastic curve that creates a spring-like motion.
  static const Curve elasticCurve = Curves.elasticOut;

  /// Arabic: منحنى يجمع بين السرعة في البداية والهدوء في النهاية.
  /// English: Curve that starts fast and settles gently at the end.
  static const Curve fastOutSlowInCurve = Curves.fastOutSlowIn;

  /// Arabic: منحنى يخفف السرعة تدريجيًا عند الاقتراب من النهاية.
  /// English: Curve that gradually slows the motion toward the end.
  static const Curve decelerateCurve = Curves.decelerate;

  /// Arabic: مقدار الإزاحة المستخدمة لمحاكاة العمق في تأثيرات المنظر المتحرك.
  /// English: Offset factor used to simulate depth in parallax effects.
  static const double parallaxOffset = 0.3;

  /// Arabic: سرعة حركة المنظر المتحرك نسبةً إلى التمرير أو التحريك.
  /// English: Relative speed of parallax movement during scroll or drag.
  static const double parallaxSpeed = 0.5;

  /// Arabic: البداية الافتراضية لتدرج اللمعان خارج حدود العنصر.
  /// English: Default start point for the shimmer gradient outside the widget bounds.
  static const double shimmerGradientStart = -1.0;

  /// Arabic: النهاية الافتراضية لتدرج اللمعان بعد عبور العنصر كاملًا.
  /// English: Default end point for the shimmer gradient after it crosses the widget.
  static const double shimmerGradientEnd = 2.0;

  /// Arabic: مدة دورة اللمعان الكاملة حتى لا يبدو التأثير متقطعًا.
  /// English: Full shimmer cycle duration to keep the effect continuous.
  static const Duration shimmerDuration = Duration(milliseconds: 1500);

  /// Arabic: أقل مقياس يستخدم عند تصغير العنصر أثناء الحركة أو الاختيار.
  /// English: Minimum scale applied when a widget shrinks during motion or selection.
  static const double minScale = 0.8;

  /// Arabic: المقياس الطبيعي للعنصر عند عدم وجود تأثير بصري خاص.
  /// English: Normal scale used when the widget is in its resting state.
  static const double maxScale = 1.0;

  /// Arabic: المقياس المستخدم لإظهار ضغط المستخدم على العنصر.
  /// English: Scale used to show press feedback on interactive controls.
  static const double pressedScale = 0.95;

  /// Arabic: المقياس المستخدم عند المرور فوق العنصر في الواجهات الداعمة لذلك.
  /// English: Scale used when hovering over widgets in hover-aware interfaces.
  static const double hoverScale = 1.05;

  /// Arabic: مقدار الإزاحة الافتراضي لحركة الانزلاق القصيرة.
  /// English: Default offset amount for a short slide motion.
  static const double slideOffset = 50.0;

  /// Arabic: مقدار إزاحة أكبر للحركات التي تحتاج دخولًا أو خروجًا أوضح.
  /// English: Larger offset used for motions that need a more visible entry or exit.
  static const double slideOffsetLarge = 100.0;

  /// Arabic: ربع دورة كاملة، ويُستخدم غالبًا في الحركات الجزئية.
  /// English: Quarter-turn value, commonly used in partial rotations.
  static const double quarterRotation = 0.25;

  /// Arabic: نصف دورة كاملة للحركات التي تقلب العنصر بشكل واضح.
  /// English: Half-turn value for motions that visibly flip the widget.
  static const double halfRotation = 0.5;

  /// Arabic: دورة كاملة تستخدم عند الحاجة إلى لف العنصر تمامًا.
  /// English: Full-turn value used when the widget should rotate completely.
  static const double fullRotation = 1.0;

  /// Arabic: الشفافية الكاملة عند إخفاء العنصر أو تعطيله بصريًا.
  /// English: Fully transparent state used when the widget should disappear visually.
  static const double invisibleOpacity = 0.0;

  /// Arabic: شفافية منخفضة تناسب العناصر الثانوية أو غير النشطة.
  /// English: Low opacity used for secondary or inactive elements.
  static const double dimOpacity = 0.3;

  /// Arabic: شفافية متوسطة لإظهار العنصر مع تقليل البروز.
  /// English: Medium opacity used to keep the element visible without dominance.
  static const double halfOpacity = 0.5;

  /// Arabic: شفافية مرتفعة تجعل العنصر مرئيًا بوضوح مع لمسة خفيفة من التخفيف.
  /// English: High opacity that keeps the element clearly visible with slight softening.
  static const double almostVisibleOpacity = 0.8;

  /// Arabic: الشفافية الكاملة عندما يكون العنصر ظاهرًا بالكامل.
  /// English: Full opacity when the widget should be completely visible.
  static const double visibleOpacity = 1.0;

  /// Arabic: التأخير القصير بين عناصر متتابعة في التسلسل الحركي.
  /// English: Short delay between items in a staggered animation sequence.
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// Arabic: تأخير أطول قليلًا لإبراز التتابع بين العناصر.
  /// English: Slightly longer stagger delay to make ordering more noticeable.
  static const Duration staggerDelayLong = Duration(milliseconds: 100);

  /// Arabic: بادئة وسم الهيرو الخاصة بصور العقارات.
  /// English: Hero tag prefix used for property images.
  static const String propertyImageHeroTag = 'property_image_';

  /// Arabic: بادئة وسم الهيرو الخاصة بعناوين العقارات.
  /// English: Hero tag prefix used for property titles.
  static const String propertyTitleHeroTag = 'property_title_';

  /// Arabic: بادئة وسم الهيرو الخاصة بأسعار العقارات.
  /// English: Hero tag prefix used for property prices.
  static const String propertyPriceHeroTag = 'property_price_';

  /// Arabic: بادئة وسم الهيرو الخاصة بصور المدن.
  /// English: Hero tag prefix used for city images.
  static const String cityImageHeroTag = 'city_image_';

  /// Arabic: عامل تصغير البطاقات غير النشطة في السلايدر.
  /// English: Scale factor applied to inactive carousel cards.
  static const double carouselScaleFactor = 0.85;

  /// Arabic: مدة انتقال البطاقات أثناء التنقل في السلايدر.
  /// English: Transition duration for moving between carousel items.
  static const Duration carouselTransitionDuration =
      Duration(milliseconds: 400);

  /// Arabic: مدة الانتقال القياسية بين الصفحات.
  /// English: Standard page transition duration.
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);

  /// Arabic: المنحنى القياسي المستخدم في انتقالات الصفحات.
  /// English: Default curve used for page transitions.
  static const Curve pageTransitionCurve = Curves.easeInOut;

  /// Arabic: فترة التحديث بين نبضات العد التنازلي.
  /// English: Tick interval used by countdown timers.
  static const Duration countdownTickDuration = Duration(seconds: 1);

  /// Arabic: مدة النبضة المرئية في مؤقت العد التنازلي.
  /// English: Pulse duration used to highlight countdown changes.
  static const Duration countdownPulseDuration = Duration(milliseconds: 600);

  /// Arabic: مدة الدوران الكاملة في مؤشرات التحميل.
  /// English: Full rotation duration for loading indicators.
  static const Duration loadingRotationDuration = Duration(seconds: 1);

  /// Arabic: سرعة الدوران القياسية لمؤشر التحميل.
  /// English: Standard rotation speed for loading indicators.
  static const double loadingRotationSpeed = 1.0;

  /// Arabic: مدة التغذية الراجعة عند النقر الخفيف على العنصر.
  /// English: Feedback duration used for a light tap interaction.
  static const Duration tapFeedbackDuration = Duration(milliseconds: 100);

  /// Arabic: مدة رد الفعل عند الضغط المطول قبل تنفيذ الإجراء.
  /// English: Feedback duration used before a long-press action completes.
  static const Duration longPressDuration = Duration(milliseconds: 500);

  /// Arabic: حساسية السحب التي تتحكم في سرعة استجابة العنصر.
  /// English: Drag sensitivity that controls how quickly the widget reacts to movement.
  static const double dragSensitivity = 1.0;

  /// Arabic: قيمة المنظور المستخدمة لمنح تأثير ثلاثي الأبعاد خفيف.
  /// English: Perspective value used to create a subtle 3D effect.
  static const double perspective = 0.002;

  /// Arabic: معامل الدوران الذي يحدد مقدار الميل البصري.
  /// English: Rotation factor that controls the amount of visual tilt.
  static const double rotationFactor = 0.3;

  /// Arabic: عامل العمق المستخدم لتعزيز الإحساس بالطبقات.
  /// English: Depth factor used to strengthen the layered appearance.
  static const double depthFactor = 0.8;
}
