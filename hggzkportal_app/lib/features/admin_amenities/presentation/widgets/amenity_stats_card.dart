import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/glassmorphic_tooltip.dart';

/// بطاقة إحصائية تفاعلية تعرض قيمة مرفق مع ملخص مرئي وتلميح تفصيلي.
/// Interactive stats card that shows an amenity metric with a visual summary and detailed tooltip.
class AmenityStatsCard extends StatefulWidget {
  /// عنوان البطاقة الذي يوضح نوع الإحصاء.
  /// Card title that explains the metric.
  final String title;

  /// القيمة الأساسية التي تعرضها البطاقة.
  /// Main value displayed by the card.
  final String value;

  /// الأيقونة التي تمثل الإحصاء.
  /// Icon representing the metric.
  final IconData icon;

  /// التدرج المستخدم لتلوين القيمة والعناصر البصرية.
  /// Gradient used to color the value and visual layers.
  final Gradient gradient;

  /// وصف اختياري قصير أسفل العنوان أو بجانب القيمة.
  /// Optional short description below the title or beside the value.
  final String? subtitle;

  /// نسبة مئوية اختيارية مرتبطة بالمقياس.
  /// Optional percentage associated with the metric.
  final double? percentage;

  /// وصف إضافي يظهر في التلميح عند الضغط المطول.
  /// Additional description shown in the tooltip on long press.
  final String? detailedDescription;

  /// إحصاءات إضافية تضاف داخل التلميح التفصيلي.
  /// Extra stats appended inside the detailed tooltip.
  final Map<String, dynamic>? additionalStats;

  /// ينشئ بطاقة الإحصاء مع القيم والأسلوب الممررين.
  /// Creates the stats card with the supplied values and styling.
  const AmenityStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.subtitle,
    this.percentage,
    this.detailedDescription,
    this.additionalStats,
  });

  /// ينشئ الحالة المسؤولة عن الحركة والتفاعل مع البطاقة.
  /// Creates the state responsible for motion and interaction with the card.
  @override
  State<AmenityStatsCard> createState() => _AmenityStatsCardState();
}

/// تدير هذه الحالة التحريك الدائري والنبض وحالات hover والضغط.
/// Manages looping animation, pulse, and hover/press states.
class _AmenityStatsCardState extends State<AmenityStatsCard>
    with SingleTickerProviderStateMixin {
  /// مفتاح البطاقة المستخدم لربط التلميح بها.
  /// Card key used to anchor the tooltip to this widget.
  final GlobalKey _cardKey = GlobalKey();

  /// يتحكم في الحركة الدائرية للبطاقة.
  /// Controls the looping animation for the card.
  late AnimationController _animationController;

  /// قيمة التكبير المستخدمة لإبراز البطاقة.
  /// Scale value used to emphasize the card.
  late Animation<double> _scaleAnimation;

  /// قيمة الدوران الخاصة بالخلفية الدائرية.
  /// Rotation value for the circular background element.
  late Animation<double> _rotationAnimation;

  /// يحدد ما إذا كان المؤشر فوق البطاقة.
  /// Indicates whether the pointer is hovering over the card.
  bool _isHovered = false;

  /// يحدد ما إذا كانت البطاقة مضغوطة مؤقتًا.
  /// Indicates whether the card is temporarily pressed.
  bool _isPressed = false;

  /// يهيئ الأنيميشن الدورية عند إنشاء البطاقة.
  /// Initializes the looping animation when the card is created.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  /// يحرر متحكم الحركة عند إزالة البطاقة من الشجرة.
  /// Disposes the animation controller when the card leaves the tree.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// يعرض التلميح التفصيلي ويضبط حالة الضغط المؤقتة.
  /// Shows the detailed tooltip and toggles the temporary pressed state.
  void _handleLongPress() {
    setState(() => _isPressed = true);

    Color color = widget.gradient.colors.first;
    String message = '📊 القيمة الحالية: ${widget.value}\n\n';
    message += widget.detailedDescription ?? 'معلومات تفصيلية عن المرافق';

    if (widget.additionalStats != null && widget.additionalStats!.isNotEmpty) {
      message += '\n\n📈 تفاصيل إضافية:';
      widget.additionalStats!.forEach((key, value) {
        message += '\n• $key: $value';
      });
    }

    GlasmorphicTooltip.show(
      context: context,
      targetKey: _cardKey,
      title: widget.title,
      message: message,
      accentColor: color,
      icon: widget.icon,
      duration: const Duration(seconds: 5),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  /// يبني البطاقة الكاملة مع الخلفية والأيقونة والقيمة والوصف.
  /// Builds the full card with background layers, icon, value, and description.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _cardKey,
      onLongPress: _handleLongPress,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_isHovered ? -0.05 : 0)
            ..rotateY(_isHovered ? 0.05 : 0)
            ..scale(_isHovered ? 1.02 : 1.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkCard.withValues(alpha: 0.8),
                AppTheme.darkCard.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isPressed
                  ? widget.gradient.colors.first.withValues(alpha: 0.7)
                  : _isHovered
                      ? widget.gradient.colors.first.withValues(alpha: 0.5)
                      : AppTheme.darkBorder.withValues(alpha: 0.3),
              width: _isPressed ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.gradient.colors.first.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.2),
                blurRadius: _isHovered ? 25 : 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Stack(
                children: [
                  // Background Pattern
                  if (_isHovered)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _PatternPainter(
                          color: widget.gradient.colors.first
                              .withValues(alpha: 0.05),
                        ),
                      ),
                    ),

                  // Floating Icon Background
                  Positioned(
                    top: -20,
                    right: -20,
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: widget.gradient.scale(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: widget.gradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: widget.gradient.colors.first
                                    .withValues(alpha: 0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.paddingMedium),

                        // Title
                        Text(
                          widget.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),

                        // Value with Info Icon
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _scaleAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _isHovered
                                        ? _scaleAnimation.value
                                        : 1.0,
                                    child: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          widget.gradient.createShader(bounds),
                                      child: Text(
                                        widget.value,
                                        style: AppTextStyles.heading1.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppTheme.textMuted.withValues(alpha: 0.5),
                              size: 14,
                            ),
                          ],
                        ),

                        // Subtitle or Percentage
                        if (widget.subtitle != null ||
                            widget.percentage != null)
                          Row(
                            children: [
                              if (widget.subtitle != null)
                                Text(
                                  widget.subtitle!,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppTheme.textMuted
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              if (widget.percentage != null) ...[
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.percentage! > 0
                                        ? AppTheme.success
                                            .withValues(alpha: 0.2)
                                        : AppTheme.error.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        widget.percentage! > 0
                                            ? Icons.trending_up_rounded
                                            : Icons.trending_down_rounded,
                                        size: 12,
                                        color: widget.percentage! > 0
                                            ? AppTheme.success
                                            : AppTheme.error,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.percentage!.abs().toStringAsFixed(1)}%',
                                        style: AppTextStyles.caption.copyWith(
                                          color: widget.percentage! > 0
                                              ? AppTheme.success
                                              : AppTheme.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// يرسم نمطًا خلفيًا خفيفًا يعزز الإحساس بالعمق داخل البطاقة.
/// Draws a light background pattern that enhances depth inside the card.
class _PatternPainter extends CustomPainter {
  /// لون النمط الخلفي.
  /// Color used for the background pattern.
  final Color color;

  /// ينشئ الرسّام بلون النمط المحدد.
  /// Creates the painter with the chosen pattern color.
  _PatternPainter({required this.color});

  /// يرسم خطوط النمط الخلفي على اللوحة.
  /// Paints the background pattern lines onto the canvas.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 20.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height / 3, size.height),
        paint,
      );
    }
  }

  /// لا يعيد الرسم لأن النمط ثابت ولا يعتمد على حالة متغيرة.
  /// Does not repaint because the pattern is static and state-independent.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
