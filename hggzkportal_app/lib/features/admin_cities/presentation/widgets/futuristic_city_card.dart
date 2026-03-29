// lib/features/admin_cities/presentation/widgets/futuristic_city_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/city.dart';
import 'city_images_collage.dart';

/// Presentation card that shows a city preview, status, and quick actions.
///
/// بطاقة عرض تُظهر معاينة المدينة وحالتها وإجراءاتها السريعة.
class FuturisticCityCard extends StatefulWidget {
  /// City record rendered inside the preview card.
  ///
  /// سجل المدينة المعروض داخل بطاقة المعاينة.
  final City city;

  /// Triggered when the card body is tapped.
  ///
  /// يُستدعى عند النقر على جسم البطاقة.
  final VoidCallback? onTap;

  /// Triggered when the edit action is requested from the card overlay.
  ///
  /// يُستدعى عند طلب تعديل البطاقة من طبقة الإجراءات.
  final VoidCallback? onEdit;

  /// Triggered when the delete action is requested from the card overlay.
  ///
  /// يُستدعى عند طلب حذف البطاقة من طبقة الإجراءات.
  final VoidCallback? onDelete;

  /// Uses a compact row layout instead of the larger square variant.
  ///
  /// يستخدم تخطيطًا مضغوطًا بدل النسخة المربعة الأكبر.
  final bool isCompact;

  /// Creates the card used inside the grid or list view.
  ///
  /// ينشئ البطاقة المستخدمة داخل عرض الشبكة أو القائمة.
  const FuturisticCityCard({
    super.key,
    required this.city,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isCompact = false,
  });

  /// ينشئ حالة البطاقة التي تدير الظهور والتفاعل والإجراءات.
  /// Creates the card state that manages motion, interaction, and actions.
  @override
  State<FuturisticCityCard> createState() => _FuturisticCityCardState();
}

/// يدير الحركة الداخلية وإظهار طبقة الإجراءات وسلوك البطاقة.
/// Manages internal motion, the action overlay, and card interaction behavior.
class _FuturisticCityCardState extends State<FuturisticCityCard>
    with SingleTickerProviderStateMixin {
  /// متحكم الحركة الذي يدير تأثيرات اللمس والانتقال.
  /// Animation controller used for touch feedback and transitions.
  late AnimationController _animationController;

  /// يحدد ما إذا كانت البطاقة في حالة مرور بصري.
  /// Indicates whether the card is currently hovered or pressed visually.
  bool _isHovered = false;

  /// يحدد ظهور طبقة الإجراءات العلوية.
  /// Controls whether the action overlay is visible.
  bool _showActions = false;

  Widget _buildSecondaryText(
    String? value, {
    double fontSize = 10,
    int maxLines = 1,
  }) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        value,
        style: AppTextStyles.caption.copyWith(
          color: AppTheme.textMuted.withValues(alpha: 0.75),
          fontSize: fontSize,
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// يجهز متحكم الحركة قبل العرض الأول للبطاقة.
  /// Initializes the animation controller before the card first renders.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  /// يحرر متحكم الحركة عند إزالة البطاقة من الشجرة.
  /// Disposes the animation controller when the card leaves the tree.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// يبني البطاقة بالنسخة الكاملة أو المضغوطة حسب الوضع.
  /// Builds the card in full or compact mode depending on configuration.
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()
        ..scale(_isHovered ? 0.98 : 1.0)
        ..rotateZ(_isHovered ? 0.002 : 0),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          setState(() => _showActions = !_showActions);
        },
        onTapDown: (_) => _setHovered(true),
        onTapUp: (_) => _setHovered(false),
        onTapCancel: () => _setHovered(false),
        child: widget.isCompact ? _buildCompactCard() : _buildFullCard(),
      ),
    );
  }

  // الكارد الكامل - استخدام AspectRatio بدلاً من الارتفاع الثابت
  /// يبني التخطيط الكامل المربع مع الصور والمحتوى وطبقة الإجراءات.
  /// Builds the square full layout with images, content, and action overlay.
  Widget _buildFullCard() {
    return AspectRatio(
      aspectRatio: 1.0, // نسبة 1:1 للكارد المربع
      child: Stack(
        children: [
          // الخلفية والإطار
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.city.isActive == true
                    ? AppTheme.success.withValues(alpha: 0.3)
                    : AppTheme.darkBorder.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowDark.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),

          // المحتوى
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final imageHeight = constraints.maxHeight * 0.65;
                final contentHeight = constraints.maxHeight * 0.35;

                return Stack(
                  children: [
                    // قسم الصور
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: imageHeight,
                      child: CityImagesCollage(
                        images: widget.city.images,
                        height: imageHeight,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        onTap: widget.onTap,
                        showImageCount: widget.city.images.length > 1,
                        enableHoverEffect: false,
                      ),
                    ),

                    // شارة الحالة
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildStatusBadge(),
                    ),

                    // قسم المحتوى
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: contentHeight,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: _buildContentSection(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // طبقة الإجراءات
          if (_showActions)
            Positioned.fill(
              child: _buildActionsOverlay(),
            ),
        ],
      ),
    );
  }

  // الكارد المضغوط
  /// يبني التخطيط المضغوط المستخدم في العروض الأضيق.
  /// Builds the compact layout used in denser views.
  Widget _buildCompactCard() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.city.isActive == true
              ? AppTheme.success.withValues(alpha: 0.3)
              : AppTheme.darkBorder.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Row(
              children: [
                // قسم الصور
                SizedBox(
                  width: 100,
                  child: CityImagesCollage(
                    images: widget.city.images.take(2).toList(),
                    height: 98, // نقص 2 بكسل للـ border
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(11),
                      bottomRight: Radius.circular(11),
                    ),
                    onTap: widget.onTap,
                    showImageCount: false,
                    enableHoverEffect: false,
                  ),
                ),

                // قسم المحتوى
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _buildCompactContent(),
                  ),
                ),
              ],
            ),
          ),

          // طبقة الإجراءات
          if (_showActions)
            Positioned.fill(
              child: _buildActionsOverlay(),
            ),
        ],
      ),
    );
  }

  // محتوى القسم السفلي للكارد الكامل
  /// يبني القسم النصي والإجرائي في البطاقة الكاملة.
  /// Builds the text and action section for the full card.
  Widget _buildContentSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // معلومات المدينة
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم المدينة
              Text(
                widget.city.name,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              _buildSecondaryText(widget.city.nameEn),
              const SizedBox(height: 2),
              // الموقع
              Row(
                children: [
                  Icon(
                    CupertinoIcons.location_solid,
                    size: 9,
                    color: AppTheme.textMuted.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      widget.city.country,
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              _buildSecondaryText(widget.city.countryEn, fontSize: 9),
              if (widget.city.propertiesCount != null) ...[
                const SizedBox(height: 2),
                _buildPropertiesCount(),
              ],
            ],
          ),
        ),
        // أزرار الإجراءات
        Row(
          children: [
            _buildActionIcon(
              icon: CupertinoIcons.pencil,
              onTap: widget.onEdit,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 6),
            _buildActionIcon(
              icon: CupertinoIcons.trash,
              onTap: widget.onDelete,
              color: AppTheme.error,
            ),
          ],
        ),
      ],
    );
  }

  // محتوى الكارد المضغوط
  /// يبني المحتوى المضغوط داخل الصف الأفقي للبطاقة.
  /// Builds the compact content inside the card's horizontal row.
  Widget _buildCompactContent() {
    return Row(
      children: [
        // معلومات المدينة
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الاسم والحالة
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.city.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _buildStatusBadge(isSmall: true),
                ],
              ),
              _buildSecondaryText(widget.city.nameEn, fontSize: 9),
              const SizedBox(height: 3),
              // الموقع
              Row(
                children: [
                  Icon(
                    CupertinoIcons.location,
                    size: 9,
                    color: AppTheme.textMuted.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      widget.city.country,
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted.withValues(alpha: 0.7),
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              _buildSecondaryText(widget.city.countryEn, fontSize: 8),
              const SizedBox(height: 3),
              // المعلومات الإضافية
              Row(
                children: [
                  if (widget.city.images.length > 2) ...[
                    _buildImageBadge(),
                    const SizedBox(width: 4),
                  ],
                  if (widget.city.propertiesCount != null)
                    _buildPropertiesCount(isSmall: true),
                ],
              ),
            ],
          ),
        ),
        // أزرار صغيرة
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionIcon(
              icon: CupertinoIcons.pencil,
              onTap: widget.onEdit,
              color: AppTheme.primaryBlue,
              size: 8,
            ),
            const SizedBox(height: 4),
            _buildActionIcon(
              icon: CupertinoIcons.trash,
              onTap: widget.onDelete,
              color: AppTheme.error,
              size: 8,
            ),
          ],
        ),
      ],
    );
  }

  // أيقونة الإجراء
  /// يبني أيقونة إجراء صغيرة قابلة للنقر مع تأثير لمس.
  /// Builds a small tappable action icon with haptic feedback.
  Widget _buildActionIcon({
    required IconData icon,
    required VoidCallback? onTap,
    required Color color,
    double size = 10,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }

  // شارة الحالة
  /// يبني شارة الحالة التي توضّح ما إذا كانت المدينة نشطة.
  /// Builds the status badge that shows whether the city is active.
  Widget _buildStatusBadge({bool isSmall = false}) {
    final isActive = widget.city.isActive == true;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 4 : 6,
        vertical: isSmall ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.success.withValues(alpha: 0.8)
            : AppTheme.textMuted.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            isActive ? 'نشط' : 'غير',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontSize: isSmall ? 8 : 9,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // عداد العقارات
  /// يعرض عدد العقارات المرتبطة بالمدينة داخل شارة صغيرة.
  /// Shows the number of properties linked to the city in a small badge.
  Widget _buildPropertiesCount({bool isSmall = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.house_fill,
            size: isSmall ? 8 : 9,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 2),
          Text(
            '${widget.city.propertiesCount ?? 0}',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.primaryBlue,
              fontSize: isSmall ? 8 : 9,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // شارة عدد الصور
  /// يعرض شارة صغيرة لعدد الصور المتاحة للمدينة.
  /// Shows a small badge for the number of images in the city.
  Widget _buildImageBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.photo,
            size: 8,
            color: AppTheme.primaryPurple,
          ),
          const SizedBox(width: 2),
          Text(
            '${widget.city.images.length}',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.primaryPurple,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  // طبقة الإجراءات
  /// يعرض طبقة الإجراءات العائمة عند طلب التعديل السريع.
  /// Shows the floating action overlay for quick editing.
  Widget _buildActionsOverlay() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.isCompact ? 11 : 15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: AppTheme.darkBackground.withValues(alpha: 0.85),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOverlayAction(
                  icon: CupertinoIcons.pencil,
                  label: 'تعديل',
                  onTap: () {
                    setState(() => _showActions = false);
                    widget.onEdit?.call();
                  },
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 12),
                _buildOverlayAction(
                  icon: CupertinoIcons.trash,
                  label: 'حذف',
                  onTap: () {
                    setState(() => _showActions = false);
                    widget.onDelete?.call();
                  },
                  color: AppTheme.error,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // زر الإجراء في الطبقة العلوية
  /// يبني زرًا داخل طبقة الإجراءات يحمل أيقونة وتسميه.
  /// Builds one button inside the action overlay with icon and label.
  Widget _buildOverlayAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// يحدّث حالة المرور ويشغّل أو يوقف الحركة المرتبطة بها.
  /// Updates the hover state and starts or stops the related animation.
  void _setHovered(bool value) {
    setState(() => _isHovered = value);
    if (value) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}
