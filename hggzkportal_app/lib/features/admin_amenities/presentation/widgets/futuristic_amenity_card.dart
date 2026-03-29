import 'package:hggzkportal/features/admin_amenities/presentation/utils/amenity_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/amenity_identity_card_tooltip.dart';
import '../../domain/entities/amenity.dart';

/// بطاقة مرئية عالية التفاعل تعرض مرفقًا واحدًا مع إجراءات سريعة.
/// High-interaction amenity card that presents one amenity with quick actions.
class FuturisticAmenityCard extends StatefulWidget {
  /// المرفق الذي تعرضه البطاقة.
  /// Amenity instance rendered by the card.
  final Amenity amenity;

  /// يستدعى عند النقر على البطاقة.
  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// يستدعى عند طلب تعديل المرفق.
  /// Called when edit is requested for the amenity.
  final VoidCallback? onEdit;

  /// يستدعى عند طلب حذف المرفق.
  /// Called when delete is requested for the amenity.
  final VoidCallback? onDelete;

  /// يستدعى عند الضغط المطول على البطاقة.
  /// Called when the card is long-pressed.
  final VoidCallback? onLongPress;

  /// ينشئ البطاقة مع المرفق وإجراءاتها الاختيارية.
  /// Creates the card with the amenity and its optional actions.
  const FuturisticAmenityCard({
    super.key,
    required this.amenity,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onLongPress,
  });

  /// ينشئ الحالة المسؤولة عن الحركة والتفاعل داخل البطاقة.
  /// Creates the state that manages the card animation and interaction.
  @override
  State<FuturisticAmenityCard> createState() => _FuturisticAmenityCardState();
}

/// تدير هذه الحالة الحركات واللمعان والضغط المؤقت وعرض التلميح.
/// Manages the motion, shimmer, pressed state, and tooltip presentation.
class _FuturisticAmenityCardState extends State<FuturisticAmenityCard>
    with TickerProviderStateMixin {
  /// متحكم تكبير البطاقة عند المرور عليها.
  /// Controls the hover scale animation for the card.
  late AnimationController _hoverController;

  /// متحكم اللمعان المتكرر الذي يمر فوق البطاقة.
  /// Controls the repeating shimmer sweep.
  late AnimationController _shimmerController;

  /// متحكم النبض الخفيف للعناصر البصرية.
  /// Controls the subtle pulse used by visual accents.
  late AnimationController _pulseController;

  /// قيمة التحجيم الناتجة عن حالة المرور.
  /// Scale animation value derived from hover state.
  late Animation<double> _hoverAnimation;

  /// قيمة اللمعان المستخدمة في الخلفية الشفافة.
  /// Shimmer value used for the translucent overlay.
  late Animation<double> _shimmerAnimation;

  /// قيمة النبض المستخدمة في الزخارف العلوية.
  /// Pulse value used for the decorative accents.
  late Animation<double> _pulseAnimation;

  /// يحدد ما إذا كان المؤشر فوق البطاقة الآن.
  /// Indicates whether the pointer is currently hovering over the card.
  bool _isHovered = false;

  /// يحدد ما إذا كانت البطاقة مضغوطة مؤقتًا.
  /// Indicates whether the card is temporarily pressed.
  bool _isPressed = false;

  /// المفتاح المستخدم لربط التلميح بموقع البطاقة.
  /// Global key used to anchor the tooltip to the card position.
  final GlobalKey _cardKey = GlobalKey();

  /// يهيئ متحكمات الحركة عند إنشاء الحالة.
  /// Initializes the animation controllers when the state is created.
  @override
  void initState() {
    super.initState();

    _initializeAnimations();
  }

  /// يضبط جميع الحركات المستخدمة في البطاقة المتحركة.
  /// Sets up all animations used by the futuristic card.
  void _initializeAnimations() {
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  /// يحرر المتحكمات لتجنب التسرب عند إزالة البطاقة.
  /// Disposes the controllers to avoid leaks when the card is removed.
  @override
  void dispose() {
    _hoverController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// يبني البطاقة كاملة مع الخلفية الزخرفية والحالة والإجراءات.
  /// Builds the full card with decorative background, status, and actions.
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        key: _cardKey,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: _handleTap,
        onLongPress: _handleLongPress,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _hoverAnimation,
            _shimmerAnimation,
            _pulseAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? 0.98 : _hoverAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isHovered
                        ? [
                            AppTheme.primaryPurple.withValues(alpha: 0.15),
                            AppTheme.primaryBlue.withValues(alpha: 0.08),
                            const Color(0xFF1A0E2E).withValues(alpha: 0.1),
                          ]
                        : [
                            AppTheme.darkCard.withValues(alpha: 0.7),
                            AppTheme.darkCard.withValues(alpha: 0.5),
                            AppTheme.darkCard.withValues(alpha: 0.4),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16), // زوايا حادة هادئة
                  border: Border.all(
                    color: _isHovered
                        ? AppTheme.primaryPurple.withValues(alpha: 0.5)
                        : AppTheme.darkBorder.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? AppTheme.primaryPurple.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.1),
                      blurRadius: _isHovered ? 25 : 15,
                      offset: const Offset(0, 8),
                    ),
                    if (_isHovered)
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: -5,
                        offset: const Offset(0, -5),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Stack(
                      children: [
                        // Background Pattern
                        if (_isHovered) _buildBackgroundPattern(),

                        // Main Content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Section
                              _buildHeader(),

                              const SizedBox(height: 16),

                              // Description
                              _buildDescription(),

                              const Spacer(),

                              // Stats Grid
                              _buildStatsGrid(),

                              const SizedBox(height: 12),

                              // Footer with Actions
                              _buildFooter(),
                            ],
                          ),
                        ),

                        // Shimmer Effect
                        if (_isHovered) _buildShimmerOverlay(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// يعرض التلميح التفصيلي للمرفق الحالي عند النقر.
  /// Shows the detailed tooltip for the current amenity when tapped.
  void _handleTap() {
    HapticFeedback.lightImpact();
    _showAmenityTooltip();
    // عرض التفاصيل فقط بدون الانتقال إلى صفحة جديدة
  }

  /// يعرض التلميح ثم ينفذ رد الضغط المطول الاختياري.
  /// Shows the tooltip and then invokes the optional long-press callback.
  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    _showAmenityTooltip();
    widget.onLongPress?.call();
  }

  /// يفتح بطاقة التعريف المرتبطة بهذا المرفق.
  /// Opens the identity tooltip anchored to this amenity card.
  void _showAmenityTooltip() {
    AmenityIdentityCardTooltip.show(
      context: context,
      targetKey: _cardKey,
      amenityId: widget.amenity.id,
      name: _combineBilingual(
        widget.amenity.name,
        widget.amenity.nameEn,
      ),
      description: _combineBilingual(
        widget.amenity.description,
        widget.amenity.descriptionEn,
      ),
      icon: widget.amenity.icon,
      isAvailable: widget.amenity.isActive ?? true,
      extraCost: widget.amenity.averageExtraCost,
      currency: null,
      propertiesCount: widget.amenity.propertiesCount,
      category: null,
    );
  }

  /// يرسم طبقة خلفية زخرفية تظهر فقط أثناء التمرير.
  /// Draws a decorative background layer that appears only on hover.
  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _PatternPainter(
          animation: _shimmerAnimation.value,
          color: AppTheme.primaryPurple.withValues(alpha: 0.03),
        ),
      ),
    );
  }

  /// يرسم طبقة لمعان متحركة فوق البطاقة أثناء التفاعل.
  /// Draws an animated shimmer layer over the card during interaction.
  Widget _buildShimmerOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.transparent,
                  AppTheme.primaryPurple.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: [
                  _shimmerAnimation.value - 0.3,
                  _shimmerAnimation.value,
                  _shimmerAnimation.value + 0.3,
                ],
              ).createShader(rect);
            },
            blendMode: BlendMode.srcOver,
            child: Container(color: Colors.white),
          );
        },
      ),
    );
  }

  /// يبني رأس البطاقة الذي يجمع الأيقونة والاسم والمعرف والحالة.
  /// Builds the card header with the icon, name, ID, and status badge.
  Widget _buildHeader() {
    return Row(
      children: [
        // Icon Container - Premium Design
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale:
                  widget.amenity.isActive == true ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryPurple.withValues(alpha: 0.2),
                      AppTheme.primaryBlue.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14), // زوايا حادة هادئة
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _getAmenityIcon(widget.amenity.icon),
                  color: Colors.white,
                  size: 24,
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 12),

        // Title and ID
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.amenity.name,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (_normalizedSecondary(
                    widget.amenity.nameEn,
                    widget.amenity.name,
                  ) !=
                  null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    _normalizedSecondary(
                      widget.amenity.nameEn,
                      widget.amenity.name,
                    )!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '#${widget.amenity.id.substring(0, 8).toUpperCase()}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.primaryPurple,
                    fontSize: 10,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Status Badge
        _buildStatusBadge(),
      ],
    );
  }

  /// يبني شارة الحالة التي توضّح ما إذا كان المرفق نشطًا.
  /// Builds the status badge that shows whether the amenity is active.
  Widget _buildStatusBadge() {
    final isActive = widget.amenity.isActive == true;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [
                  AppTheme.success.withValues(alpha: 0.2),
                  AppTheme.neonGreen.withValues(alpha: 0.1),
                ]
              : [
                  AppTheme.textMuted.withValues(alpha: 0.2),
                  AppTheme.textMuted.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppTheme.success.withValues(alpha: 0.5)
              : AppTheme.textMuted.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.success.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.success : AppTheme.textMuted,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.success.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'نشط' : 'معطل',
            style: AppTextStyles.caption.copyWith(
              color: isActive ? AppTheme.success : AppTheme.textMuted,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// يبني وصفًا مختصرًا للمرفق داخل صندوق واضح القراءة.
  /// Builds a short amenity description inside a readable box.
  Widget _buildDescription() {
    final secondaryDescription = _normalizedSecondary(
      widget.amenity.descriptionEn,
      widget.amenity.description,
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.amenity.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (secondaryDescription != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                secondaryDescription,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted.withValues(alpha: 0.78),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  /// يبني صف الإحصاءات السريع الذي يعرض العقارات والتكلفة.
  /// Builds the quick stats row for properties count and cost.
  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.business_rounded,
            label: 'العقارات',
            value: '${widget.amenity.propertiesCount ?? 0}',
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            icon: Icons.attach_money_rounded,
            label: 'التكلفة',
            value: widget.amenity.averageExtraCost != null &&
                    widget.amenity.averageExtraCost! > 0
                ? '\$${widget.amenity.averageExtraCost!.toStringAsFixed(0)}'
                : 'مجاني',
            color: AppTheme.success,
          ),
        ),
      ],
    );
  }

  /// يبني بطاقة إحصاء صغيرة تعرض قيمة مع رمز ولون محددين.
  /// Builds a compact stat tile that shows a value with its icon and color.
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _combineBilingual(String primary, String? secondary) {
    final normalizedSecondary = _normalizedSecondary(secondary, primary);
    if (normalizedSecondary == null) {
      return primary;
    }

    return '$primary\n$normalizedSecondary';
  }

  String? _normalizedSecondary(String? secondary, String primary) {
    final normalized = secondary?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    if (normalized == primary.trim()) {
      return null;
    }

    return normalized;
  }

  /// يبني تذييل البطاقة الذي يعرض التاريخ وأزرار الإجراءات.
  /// Builds the card footer with the creation date and action buttons.
  Widget _buildFooter() {
    return Row(
      children: [
        // Created Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تاريخ الإنشاء',
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                ),
              ),
              Text(
                _formatDate(widget.amenity.createdAt),
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Action Buttons
        if (_isHovered && (widget.onEdit != null || widget.onDelete != null))
          Row(
            children: [
              if (widget.onEdit != null)
                _buildActionButton(
                  icon: Icons.edit_rounded,
                  color: AppTheme.primaryPurple,
                  onTap: widget.onEdit!,
                ),
              const SizedBox(width: 6),
              if (widget.onDelete != null)
                _buildActionButton(
                  icon: Icons.delete_rounded,
                  color: AppTheme.error,
                  onTap: widget.onDelete!,
                ),
            ],
          ),
      ],
    );
  }

  /// يبني زر إجراء صغيرًا مناسبًا للتعديل أو الحذف.
  /// Builds a small action button suited for edit or delete actions.
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 16,
        ),
      ),
    );
  }

  /// يحول تاريخ الإنشاء إلى نص قصير مناسب للعرض داخل البطاقة.
  /// Formats the creation date into a short card-friendly string.
  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.day}/${date.month}/${date.year}';
  }

  /// يحول اسم الأيقونة النصي إلى أيقونة Material مناسبة للمرفق.
  /// Converts the textual icon name into a matching Material icon.
  IconData _getAmenityIcon(String iconName) {
    return AmenityIcons.getIconByName(iconName)?.icon ?? Icons.star_rounded;
  }
}

/// يرسم نمطًا سداسيًا خفيفًا يعزز العمق خلف البطاقة.
/// Draws a subtle hexagon pattern that adds depth behind the card.
class _PatternPainter extends CustomPainter {
  /// قيمة الحركة التي تحدد إزاحة النمط السداسي.
  /// Animation value that controls the hexagon pattern offset.
  final double animation;

  /// لون النمط السداسي المستخدم في الخلفية.
  /// Color used for the hexagon pattern.
  final Color color;

  /// ينشئ الرسّام بقيمة الحركة واللون المطلوبين.
  /// Creates the painter with the requested animation value and color.
  _PatternPainter({
    required this.animation,
    required this.color,
  });

  /// يرسم النمط السداسي المتكرر على مساحة البطاقة.
  /// Paints the repeating hexagon pattern across the card surface.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw hexagon pattern
    const spacing = 30.0;
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        final offset = (y / spacing).floor() % 2 == 0 ? 0.0 : spacing / 2;
        _drawHexagon(
          canvas,
          Offset(x + offset + animation * spacing, y),
          10,
          paint,
        );
      }
    }
  }

  /// يرسم سداسيًا واحدًا حول المركز المحدد بالحجم واللون الحاليين.
  /// Draws a single hexagon around the given center with the current size and color.
  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override

  /// يعيد الرسم عندما تتغير قيمة الحركة أو اللون.
  /// Repaints when the animation value or color changes.
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
