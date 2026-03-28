import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';
import '../theme/app_dimensions.dart';

/// يعرض أنماط تحميل متعددة لتناسب الشاشات الخفيفة والثقيلة على حد سواء.
/// Provides several loading styles for light and heavy screens alike.
class LoadingWidget extends StatelessWidget {
  /// النمط البصري المختار لمؤشر التحميل.
  /// Selected loading style.
  final LoadingType type;

  /// الحجم الأساسي للمؤشر عندما يحتاج إلى قياس مرن.
  /// Base size used by loaders that scale with available space.
  final double? size;

  /// اللون الرئيسي الذي يطبع شخصية المؤشر البصرية.
  /// Main accent color used by the loading indicator.
  final Color? color;

  /// الرسالة الاختيارية التي تشرح ما الذي ينتظره المستخدم.
  /// Optional message explaining what the user is waiting for.
  final String? message;

  /// مسافة خارجية تسمح بدمج المؤشر داخل بطاقات أو صفحات مختلفة.
  /// External padding that lets the loader fit inside different surfaces.
  final EdgeInsets? padding;

  /// أصل SVG المستخدم في النمط المستقبلي.
  /// SVG asset used by the futuristic loader style.
  final String? svgAsset;

  /// ينشئ المؤشر مع اختيار نمط التحميل والرسالة والهوامش.
  /// Creates the loader with a configurable style, message, and padding.
  const LoadingWidget({
    super.key,
    this.type = LoadingType.circular,
    this.size,
    this.color,
    this.message,
    this.padding,
    this.svgAsset,
  });

  /// يختار المؤشر المناسب ثم يلفه برسالة اختيارية عند الحاجة.
  /// Chooses the appropriate loader and optionally appends a message.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? AppTheme.primaryBlue;
    final effectiveSize = size ?? 40.0;
    final effectiveSvgAsset = svgAsset ?? 'assets/images/progress.svg';

    Widget loadingIndicator;

    switch (type) {
      case LoadingType.circular:
        loadingIndicator = _FuturisticLoading(
          color: effectiveColor,
          height: (effectiveSize * 5).clamp(200.0, 300.0),
          innerSize: (effectiveSize * 3.5).clamp(140.0, 200.0),
          svgAsset: effectiveSvgAsset,
        );
        break;
      case LoadingType.linear:
        loadingIndicator = _buildLinearLoader(effectiveColor);
        break;
      case LoadingType.shimmer:
        loadingIndicator = _buildShimmerLoader();
        break;
      case LoadingType.pulse:
        loadingIndicator = _buildPulseLoader(effectiveColor, effectiveSize);
        break;
      case LoadingType.dots:
        loadingIndicator = _buildDotsLoader(effectiveColor);
        break;
      case LoadingType.futuristic:
        loadingIndicator = _FuturisticLoading(
          color: effectiveColor,
          height: (effectiveSize * 5).clamp(200.0, 300.0),
          innerSize: (effectiveSize * 3.5).clamp(140.0, 200.0),
          svgAsset: effectiveSvgAsset,
        );
        break;
    }

    if (message != null) {
      loadingIndicator = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingIndicator,
          const SizedBox(height: AppDimensions.spaceMedium),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Center(child: loadingIndicator),
    );
  }

  /// يعرض شريط تقدم أفقيًا عندما تكون العملية قصيرة وواضحة.
  /// Renders a horizontal progress bar for straightforward loading states.
  Widget _buildLinearLoader(Color color) {
    return SizedBox(
      width: double.infinity,
      child: LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        backgroundColor: color.withValues(alpha: 0.2),
      ),
    );
  }

  /// يعرض سطحًا متحركًا يوحي بتحميل محتوى هيكلي.
  /// Renders a shimmering skeleton for content-heavy screens.
  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: AppTheme.shimmer,
      highlightColor: AppTheme.shimmer.withValues(alpha: 0.5),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderMedium),
        ),
      ),
    );
  }

  /// يعرض نبضة دائرية خفيفة عندما يكون المطلوب إشارة انتظار صغيرة.
  /// Renders a subtle pulsing circle for compact waiting states.
  Widget _buildPulseLoader(Color color, double size) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: size * 0.6,
                height: size * 0.6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
      onEnd: () {},
    );
  }

  /// يعرض ثلاث نقاط متحركة عندما نريد مؤشّرًا بسيطًا وغير مزعج.
  /// Renders a three-dot loader for minimal, low-distraction feedback.
  Widget _buildDotsLoader(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 200)),
          builder: (context, value, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color.withValues(alpha: value),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

/// يحدد أنماط التحميل المتاحة كي تختار الواجهة الشكل الأنسب لكل حالة.
/// Enumerates the loading styles available to the rest of the app.
enum LoadingType {
  circular,
  linear,
  shimmer,
  pulse,
  dots,
  futuristic,
}

/// النمط المستقبلي الذي يجمع الدوران والنبض والعرض داخل أصل SVG واحد.
/// Futuristic loader that combines rotation, pulsing, and SVG rendering.
class _FuturisticLoading extends StatefulWidget {
  /// لون الطابع البصري الداخلي.
  /// Accent color for the inner visual layers.
  final Color color;

  /// الارتفاع الكلي للحاوية حتى تبقى متناسقة مع بقية الشاشات.
  /// Total container height used to keep layout consistent.
  final double height;

  /// حجم الدائرة الداخلية التي تدور أو تنبض.
  /// Size of the inner circle that rotates or pulses.
  final double innerSize;

  /// ملف الـ SVG الذي يظهر داخل مؤشر التحميل.
  /// SVG asset rendered inside the loader.
  final String svgAsset;

  /// ينشئ المؤشر المستقبلي مع عناصره المرئية القابلة للضبط.
  /// Creates the futuristic loader with configurable visual elements.
  const _FuturisticLoading({
    required this.color,
    required this.height,
    required this.innerSize,
    required this.svgAsset,
  });

  /// ينشئ كائن الحالة الذي يدير حركتي الدوران والتكبير.
  /// Creates the state object that drives rotation and scale animations.
  @override
  State<_FuturisticLoading> createState() => _FuturisticLoadingState();
}

/// يدير الرسوم المتحركة الداخلية للمؤشر المستقبلي على نحو متزامن.
/// Coordinates the internal animations for the futuristic loader.
class _FuturisticLoadingState extends State<_FuturisticLoading>
    with TickerProviderStateMixin {
  /// متحكم الحركة الذي يغذي الطبقة الخارجية بالدوران المستمر.
  /// Animation controller driving the outer motion.
  late AnimationController _controller;

  /// متحكم حركة الدوران الداخلي.
  /// Animation controller for the inner rotation.
  late AnimationController _rotationController;

  /// متحكم التمدد والانكماش الذي يعطي المؤشر إحساسًا حيًا.
  /// Animation controller that creates the breathing scale effect.
  late AnimationController _scaleController;

  /// الحركة المشتقة من متحكم التكبير.
  /// Derived scale animation used by the pulsing effect.
  late Animation<double> _scaleAnimation;

  /// Initializes the state for this widget.
  /// العربية: يهيئ الحالة الخاصة بهذا العنصر.
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  /// Releases the resources used by this instance.
  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  /// يبني شجرة التحميل المناسبة وفق النمط المختار.
  /// Builds the loading tree that matches the selected style.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.height,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _rotationController,
          _scaleAnimation,
        ]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // رسم الموجات الخارجية
              CustomPaint(
                painter: _RipplePainter(
                  animationValue: _controller.value,
                  color: AppTheme.primaryBlue,
                ),
                child: const SizedBox.expand(),
              ),

              // الدائرة الخارجية الثابتة
              Container(
                width: widget.innerSize,
                height: widget.innerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.3),
                      AppTheme.primaryBlue.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    width: widget.innerSize * 0.82,
                    height: widget.innerSize * 0.82,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                    ),
                  ),
                ),
              ),

              // نترك هنا مساحة ثابتة حتى يبقى مركز المؤشر مضبوطًا.
              const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }
}

/// يرسم القوس الدائري المتحرك الذي يشكل قلب المؤشر.
/// Draws the animated circular arc that forms the loader core.
class _CircularProgressPainter extends CustomPainter {
  /// اللون المستخدم في القوس والتوهج.
  /// Color used by the arc and glow.
  final Color color;

  /// قيمة التقدم الحالية التي تحدد طول القوس.
  /// Current progress value that determines the arc length.
  final double progress;

  /// ينشئ الرسام مع اللون والتقدم المطلوبين.
  /// Creates the painter with the selected color and progress.
  _CircularProgressPainter({
    required this.color,
    required this.progress,
  });

  /// يرسم القوس واللمعة والنقاط النهائية في طبقة واحدة.
  /// Paints the arc, glow, and terminal dots in one pass.
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // رسم القوس الأول مع تدرج
    final gradient1 = SweepGradient(
      colors: [
        Colors.transparent,
        color.withValues(alpha: 0.3),
        color,
        color,
        color.withValues(alpha: 0.3),
        Colors.transparent,
      ],
      stops: const [0.0, 0.1, 0.3, 0.7, 0.9, 1.0],
      startAngle: 0,
      endAngle: 2 * 3.14159,
    );

    paint.shader = gradient1.createShader(rect);

    const startAngle = -3.14159 / 2;
    final sweepAngle = 3.14159 * progress * 1.5;

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // رسم القوس الثاني المعاكس
    final paint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.3);

    canvas.drawArc(
      rect,
      startAngle + 3.14159,
      sweepAngle * 0.6,
      false,
      paint2,
    );

    // نقاط مضيئة في نهاية الأقواس
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // حساب موقع النقطة الأولى
    final angle1 = startAngle + sweepAngle;
    final x1 = center.dx + radius * math.cos(angle1);
    final y1 = center.dy + radius * math.sin(angle1);
    canvas.drawCircle(Offset(x1, y1), 3.5, dotPaint);

    // إضافة توهج للنقطة
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(x1, y1), 6, glowPaint);

    // حساب موقع النقطة الثانية
    final angle2 = startAngle + 3.14159 + (sweepAngle * 0.6);
    final x2 = center.dx + radius * math.cos(angle2);
    final y2 = center.dy + radius * math.sin(angle2);
    canvas.drawCircle(
        Offset(x2, y2), 2.5, dotPaint..color = color.withValues(alpha: 0.7));
  }

  /// يعيد الرسم دائمًا لأن مؤشر التحميل يتغير باستمرار.
  /// Always repaints because the loader animation is continuous.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// يرسم الموجات المتدرجة خلف المؤشر المستقبلي.
/// Draws the fading ripple waves behind the futuristic loader.
class _RipplePainter extends CustomPainter {
  /// قيمة الحركة التي توسع الموجات وتصغرها.
  /// Animation value that expands and contracts the ripples.
  final double animationValue;

  /// لون الموجات.
  /// Ripple color.
  final Color color;

  /// ينشئ رسام الموجات مع قيمة الحركة واللون.
  /// Creates the ripple painter with its animation value and color.
  _RipplePainter({required this.animationValue, required this.color});

  /// يرسم دوائر متداخلة لتكوين أثر الموجة حول المؤشر.
  /// Paints concentric circles to form the ripple around the loader.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);

    // رسم 3 موجات كما في واجهة الرئيسية
    for (int i = 0; i < 3; i++) {
      final radius = 50.0 + (i * 30) + (animationValue * 20);
      final opacity = (1.0 - animationValue) * 0.3;

      paint.color = color.withValues(alpha: opacity);

      canvas.drawCircle(center, radius, paint);
    }
  }

  /// يعيد الرسم مع كل تغير في الحركة ليبقى الأثر حيًا.
  /// Repaints on every animation update to keep the effect alive.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
