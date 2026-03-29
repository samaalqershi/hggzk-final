import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/rating_widget.dart';
import '../../domain/entities/property_detail.dart';

/// Hero header for the property details screen.
/// ترويسة رئيسية لشاشة تفاصيل العقار.
///
/// It combines the cover surface, favorite state, share action, and animated
/// stats so the first section of the details page feels complete.
/// يجمع هذا العنصر سطح الغلاف وحالة المفضلة وفعل المشاركة والإحصاءات المتحركة
/// حتى تبدو أول منطقة في صفحة التفاصيل مكتملة.
class PropertyHeaderWidget extends StatefulWidget {
  /// Property details model rendered by the header.
  /// نموذج تفاصيل العقار المعروض في الترويسة.
  final PropertyDetail property;

  /// Reflects whether the current property is already saved.
  /// يوضح ما إذا كان العقار محفوظًا بالفعل.
  final bool isFavorite;

  /// Shows loading feedback while the favorite toggle is pending.
  /// يعرض تغذية راجعة أثناء انتظار تبديل المفضلة.
  final bool isFavoritePending;

  /// Toggles the saved state of the property.
  /// يبدّل حالة حفظ العقار.
  final VoidCallback onFavoriteToggle;

  /// Opens the share flow for this property.
  /// يفتح مسار المشاركة لهذا العقار.
  final VoidCallback onShare;

  /// Builds the animated hero header for property details.
  /// ينشئ الترويسة البطولية المتحركة لتفاصيل العقار.
  const PropertyHeaderWidget({
    super.key,
    required this.property,
    required this.isFavorite,
    required this.isFavoritePending,
    required this.onFavoriteToggle,
    required this.onShare,
  });

  /// Builds the animation state for the header used by this feature.
  /// ينشئ حالة الحركة الخاصة بالترويسة.
  @override
  State<PropertyHeaderWidget> createState() => _PropertyHeaderWidgetState();
}

/// Coordinates the header animations and hero styling.
/// ينسق حركات الترويسة وأسلوبها البصري.
class _PropertyHeaderWidgetState extends State<PropertyHeaderWidget>
    with TickerProviderStateMixin {
  /// Drives the favorite pulse animation.
  /// يقود حركة نبض زر المفضلة.
  late AnimationController _heartController;

  /// Animates the decorative shimmer overlay.
  /// يحرك طبقة اللمعان الزخرفية.
  late AnimationController _shimmerController;

  /// Fades and scales the stats row into view.
  /// يدرج صف الإحصاءات بالتدرج والتكبير.
  late AnimationController _statsController;

  /// Keeps the background glow breathing gently.
  /// يجعل التوهج الخلفي يتنفس بلطف.
  late AnimationController _glowController;

  /// Scales the favorite button when the property is saved.
  /// يغيّر حجم زر المفضلة عند حفظ العقار.
  late Animation<double> _heartAnimation;

  /// Moves the shimmer highlight across the background.
  /// يحرك اللمعة عبر الخلفية.
  late Animation<double> _shimmerAnimation;

  /// Reveals the rating and summary stats row.
  /// يكشف صف التقييم والإحصاءات.
  late Animation<double> _statsAnimation;

  /// Softens the ambient glow behind the card.
  /// يخفف التوهج المحيط خلف البطاقة.
  late Animation<double> _glowAnimation;

  /// Prepares the layered header animations when the widget mounts.
  /// يجهز الحركات المتداخلة للترويسة عند تركيب العنصر.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  /// Configures the controllers that drive the header effects.
  /// يضبط المتحكمات التي تقود تأثيرات الترويسة.
  void _initializeAnimations() {
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _heartAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.elasticOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(_shimmerController);

    _statsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutBack,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  /// Kicks off the stat reveal after the initial header setup.
  /// يبدأ إظهار الإحصاءات بعد تجهيز الترويسة.
  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _statsController.forward();
      }
    });
  }

  /// Releases all animation controllers owned by the header.
  /// يحرر جميع متحكمات الحركة المملوكة للترويسة.
  @override
  void dispose() {
    _heartController.dispose();
    _shimmerController.dispose();
    _statsController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  /// Builds the layered header surface used above property details.
  /// يبني السطح المتداخل المستخدم أعلى تفاصيل العقار.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.9),
            AppTheme.darkCard.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Stack(
            children: [
              Positioned.fill(child: _buildAnimatedBackground()),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFuturisticHeader(),
                    const SizedBox(height: 12),
                    _buildFuturisticLocation(),
                    const SizedBox(height: 12),
                    _buildFuturisticStats(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the small rating badge anchored to the header.
  /// يبني شارة التقييم الصغيرة المثبتة على الترويسة.
  Widget _buildHeaderAverageRating() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.warning.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 12,
            color: AppTheme.warning,
          ),
          const SizedBox(width: 4),
          Text(
            widget.property.averageRating.toStringAsFixed(1),
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the atmospheric background pattern behind the card.
  /// يبني النمط المحيط خلف البطاقة.
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPatternPainter(
            shimmerPosition: _shimmerAnimation.value,
            glowIntensity: _glowAnimation.value,
          ),
        );
      },
    );
  }

  /// Builds the main title row and primary property summary.
  /// يبني صف العنوان الرئيسي وملخص العقار الأساسي.
  Widget _buildFuturisticHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: Text(
                  widget.property.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildFuturisticTag(
                    label: widget.property.typeName,
                    icon: Icons.home_work,
                    gradient: AppTheme.primaryGradient,
                  ),
                  const SizedBox(width: 6),
                  if (widget.property.averageRating > 0)
                    _buildHeaderAverageRating(),
                ],
              ),
            ],
          ),
        ),
        _buildFavoriteButton(),
      ],
    );
  }

  /// Builds the small label that identifies the property category.
  /// يبني الوسم الصغير الذي يعرّف فئة العقار.
  Widget _buildFuturisticTag({
    required String label,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the action button used to toggle favorites.
  /// يبني زر الفعل المستخدم لتبديل المفضلة.
  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: () {
        if (widget.isFavoritePending) {
          HapticFeedback.selectionClick();
          return;
        }
        widget.onFavoriteToggle();
        if (!widget.isFavorite) {
          _heartController.forward().then((_) {
            _heartController.reverse();
          });
        }
        HapticFeedback.mediumImpact();
      },
      child: AnimatedBuilder(
        animation: _heartAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isFavorite ? _heartAnimation.value : 1.0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: widget.isFavorite
                    ? LinearGradient(
                        colors: [
                          AppTheme.error,
                          AppTheme.error.withOpacity(0.7),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          AppTheme.darkCard.withOpacity(0.7),
                          AppTheme.darkCard.withOpacity(0.5),
                        ],
                      ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isFavorite
                      ? Colors.transparent
                      : AppTheme.textMuted.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Icon(
                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: widget.isFavorite ? Colors.white : AppTheme.textMuted,
                size: 16,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the address and map-context row shown under the title.
  /// يبني صف العنوان وسياق الموقع أسفل العنوان.
  Widget _buildFuturisticLocation() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.primaryCyan.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('property.header.location'),
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.property.address}, ${widget.property.city}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the quick stats row for views, bookings, and unit count.
  /// يبني صف الإحصاءات السريعة للمشاهدات والحجوزات وعدد الوحدات.
  Widget _buildFuturisticStats() {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _statsAnimation.value,
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.visibility_outlined,
                  value: widget.property.viewCount.toString(),
                  label: context.tr('property.header.view'),
                  color: AppTheme.primaryBlue,
                  delay: 0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.bookmark_outline,
                  value: widget.property.bookingCount.toString(),
                  label: context.tr('property.header.book'),
                  color: AppTheme.primaryPurple,
                  delay: 50,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.home_outlined,
                  value: widget.property.unitsCount.toString(),
                  label: context.tr('property.header.unit'),
                  color: AppTheme.primaryCyan,
                  delay: 100,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds one compact metric tile used by the stats row.
  /// يبني بطاقة قياس صغيرة مستخدمة داخل صف الإحصاءات.
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required int delay,
  }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(0.25),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 4),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                ).createShader(bounds),
                child: Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Paints the subtle geometric background behind the property header.
/// يرسم الخلفية الهندسية الخفيفة خلف ترويسة العقار.
class _BackgroundPatternPainter extends CustomPainter {
  /// Horizontal progress used to sweep the shimmer overlay.
  /// تقدم أفقي يستخدم لتمرير طبقة اللمعان.
  final double shimmerPosition;

  /// Strength of the ambient glow layer.
  /// شدة طبقة التوهج المحيط.
  final double glowIntensity;

  /// Builds the custom painter used by the header backdrop used by this feature.
  /// ينشئ الرسام المخصص المستخدم في خلفية الترويسة.
  _BackgroundPatternPainter({
    required this.shimmerPosition,
    required this.glowIntensity,
  });

  /// Draws the grid and shimmer overlays behind the header content.
  /// يرسم الشبكة وطبقة اللمعان خلف محتوى الترويسة.
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3
      ..color = AppTheme.primaryBlue.withOpacity(0.03);

    const gridSize = 20.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final shimmerRect = Rect.fromLTWH(
      shimmerPosition * size.width - 80,
      0,
      160,
      size.height,
    );

    final shimmerGradient = LinearGradient(
      colors: [
        Colors.transparent,
        AppTheme.primaryBlue.withOpacity(0.05 * glowIntensity),
        Colors.transparent,
      ],
    );

    final shimmerPaint = Paint()
      ..shader = shimmerGradient.createShader(shimmerRect)
      ..style = PaintingStyle.fill;

    canvas.drawRect(shimmerRect, shimmerPaint);
  }

  /// Repaints whenever the shimmer position or glow intensity changes.
  /// يعيد الرسم عندما يتغير موضع اللمعان أو شدة التوهج.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
