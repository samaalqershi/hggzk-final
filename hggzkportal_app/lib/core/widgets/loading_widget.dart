import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';
import '../theme/app_dimensions.dart';

/// عنصر تحميل متعدد الأشكال يعرض نفس حالة الانتظار بصيغ مختلفة حسب السياق.
/// Flexible loading surface that can render circular, shimmer, pulse, dots, or linear feedback.
class LoadingWidget extends StatelessWidget {
  /// يحدد النمط المرئي المطلوب لعرض حالة التحميل.
  /// Chooses the visual treatment used to communicate loading state.
  final LoadingType type;

  /// الحجم الأساسي لبعض الأنماط مثل الـ pulse أو circular.
  /// Base size used by modes such as circular and pulse loaders.
  final double? size;

  /// لون الحالة الرئيسي المستخدم في العناصر المتحركة.
  /// Primary accent color for the moving parts of the loader.
  final Color? color;

  /// رسالة اختيارية توضح ما الذي يجري أثناء الانتظار.
  /// Optional status message shown below the loader.
  final String? message;

  /// مساحة خارجية تسمح بملاءمة العنصر داخل واجهات مختلفة.
  /// Optional outer padding used to fit the loader into different layouts.
  final EdgeInsets? padding;

  /// ملف SVG الذي تستخدمه النسخة المستقبلية من مؤشر التحميل الدائري.
  /// SVG asset used by the futuristic circular loader variant.
  final String? svgAsset;

  /// Creates a loader widget that adapts to the available space and messaging needs.
  /// ينشئ عنصر تحميل يتكيف مع المساحة المتاحة ومع الحاجة إلى نص توضيحي.
  const LoadingWidget({
    super.key,
    this.type = LoadingType.circular,
    this.size,
    this.color,
    this.message,
    this.padding,
    this.svgAsset,
  });

  /// Chooses the loader style, rescales it to the viewport, and appends optional helper text.
  /// يختار نمط التحميل، يضبط حجمه بحسب المساحة، ويضيف نصًا مساعدًا اختياريًا.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? AppTheme.primaryBlue;
    final effectiveSize = size ?? 40.0;
    final effectiveSvgAsset = svgAsset ?? 'assets/images/progress.svg';

    return LayoutBuilder(
      builder: (context, constraints) {
        double baseHeight = (effectiveSize * 5).clamp(200.0, 300.0);
        double baseInner = (effectiveSize * 3.5).clamp(140.0, 200.0);

        if (constraints.maxHeight.isFinite) {
          final reservedForText = message != null ? 80.0 : 0.0;
          final available = (constraints.maxHeight - reservedForText)
              .clamp(120.0, double.infinity);
          if (available < baseHeight) {
            final scale = (available / baseHeight).clamp(0.6, 1.0);
            baseHeight *= scale;
            baseInner *= scale;
          }
        }

        Widget loadingIndicator;

        switch (type) {
          case LoadingType.circular:
            loadingIndicator = _FuturisticLoading(
              color: effectiveColor,
              height: baseHeight,
              innerSize: baseInner,
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
              height: baseHeight,
              innerSize: baseInner,
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
      },
    );
  }

  /// Builds a full-width progress bar used for straightforward loading feedback.
  /// يبني شريط تقدم بعرض كامل مناسبًا للحالات البسيطة.
  Widget _buildLinearLoader(Color color) {
    return SizedBox(
      width: double.infinity,
      child: LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        backgroundColor: color.withValues(alpha: 0.2),
      ),
    );
  }

  /// Renders a skeleton placeholder that suggests content is still arriving.
  /// يعرض هيكلًا وهميًا يوحي بأن المحتوى لا يزال قيد التحميل.
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

  /// Builds a breathing pulse indicator for compact loading states.
  /// يبني مؤشرًا نابضًا يصلح للحالات المختصرة.
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

  /// Builds an animated dots indicator for lightweight waiting states.
  /// يبني مؤشر نقاط متحركة للحالات الخفيفة.
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

/// أوضاع العرض المتاحة لعنصر التحميل.
/// Rendering modes available to `LoadingWidget`.
enum LoadingType {
  circular,
  linear,
  shimmer,
  pulse,
  dots,
  futuristic,
}
class _FuturisticLoading extends StatefulWidget {
  final Color color;
  final double height;
  final double innerSize;
  final String svgAsset;
  const _FuturisticLoading({
    required this.color,
    required this.height,
    required this.innerSize,
    required this.svgAsset,
  });
  @override
  State<_FuturisticLoading> createState() => _FuturisticLoadingState();
}
class _FuturisticLoadingState extends State<_FuturisticLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
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
  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
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
                      AppTheme.primaryBlue.withValues(alpha: 0.3),
                      AppTheme.primaryBlue.withValues(alpha: 0.1),
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

              // الدائرة المتحركة
              const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }
}

// رسام الموجات
class _RipplePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  _RipplePainter({required this.animationValue, required this.color});
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
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
