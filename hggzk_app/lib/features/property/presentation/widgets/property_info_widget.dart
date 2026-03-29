import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/property_detail.dart';

/// Expands the property description and supporting info blocks in the detail
/// screen.
/// يوسّع وصف العقار وكتل المعلومات الداعمة في شاشة التفاصيل.
class PropertyInfoWidget extends StatefulWidget {
  /// Property snapshot rendered by this section.
  /// لقطة العقار المعروضة في هذا القسم.
  final PropertyDetail property;

  /// Builds the animated property-info section.
  /// ينشئ قسم معلومات العقار المتحرك.
  const PropertyInfoWidget({
    super.key,
    required this.property,
  });

  /// Creates the widget state that drives description and grid animations.
  /// ينشئ حالة العنصر التي تقود حركات الوصف والشبكة.
  @override
  State<PropertyInfoWidget> createState() => _PropertyInfoWidgetState();
}

/// Coordinates the expand, grid, and glow animations for the info section.
/// ينسق حركات التوسيع والشبكة والتوهج في قسم المعلومات.
class _PropertyInfoWidgetState extends State<PropertyInfoWidget>
    with TickerProviderStateMixin {
  /// Controls the description expand/collapse animation.
  /// يتحكم في حركة توسيع الوصف أو طيه.
  late AnimationController _expandController;

  /// Drives the entrance of the info grid.
  /// يقود ظهور شبكة المعلومات.
  late AnimationController _gridController;

  /// Repeats the ambient glow effect behind the section.
  /// يكرر تأثير التوهج المحيط خلف القسم.
  late AnimationController _glowController;

  /// Animation that mirrors the expanded description height.
  /// حركة تعكس ارتفاع الوصف عند التوسيع.
  late Animation<double> _expandAnimation;

  /// Animation that reveals the info grid with a gentle delay.
  /// حركة تكشف شبكة المعلومات بتأخير لطيف.
  late Animation<double> _gridAnimation;

  /// Tracks whether the description is fully expanded.
  /// يتتبع ما إذا كان الوصف موسعًا بالكامل.
  bool _isDescriptionExpanded = false;

  /// Prepares the widget state before the first frame.
  /// يجهز حالة العنصر قبل الإطار الأول.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  /// Sets up the animation controllers and tweens used by the section.
  /// يهيئ متحكمات وحركات القسم المستخدمة في العرض.
  void _initializeAnimations() {
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _gridController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    _gridAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gridController,
      curve: Curves.easeOutBack,
    ));
  }

  /// Starts the delayed entrance animation for the info grid.
  /// يبدأ حركة الظهور المؤجلة لشبكة المعلومات.
  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _gridController.forward();
      }
    });
  }

  /// Releases the animation controllers owned by the widget.
  /// يحرر متحكمات الحركة المملوكة للعنصر.
  @override
  void dispose() {
    _expandController.dispose();
    _gridController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  /// Builds the property info section with description and quick facts.
  /// يبني قسم معلومات العقار مع الوصف والحقائق السريعة.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.property.description.isNotEmpty) ...[
          _buildFuturisticSectionTitle(
            context.tr('property.info.description'),
            Icons.description_outlined,
          ),
          const SizedBox(height: 10),
          _buildFuturisticExpandableText(),
          const SizedBox(height: 16),
        ],
        _buildFuturisticSectionTitle(
          context.tr('property.info.details'),
          Icons.info_outline,
        ),
        const SizedBox(height: 10),
        _buildFuturisticInfoGrid(),
        if (widget.property.ownerName.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildFuturisticOwnerInfo(),
        ],
      ],
    );
  }

  /// Builds the futuristic section title.
  /// العربية: يبني futuristic section title.
  Widget _buildFuturisticSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 8),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the futuristic expandable text.
  /// العربية: يبني futuristic expandable text.
  Widget _buildFuturisticExpandableText() {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withOpacity(0.5),
                AppTheme.darkCard.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.15),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedCrossFade(
                    firstChild: Text(
                      widget.property.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        height: 1.5,
                        color: AppTheme.textLight,
                      ),
                    ),
                    secondChild: Text(
                      widget.property.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        height: 1.5,
                        color: AppTheme.textLight,
                      ),
                    ),
                    crossFadeState: _isDescriptionExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDescriptionExpanded = !_isDescriptionExpanded;
                      });
                      if (_isDescriptionExpanded) {
                        _expandController.forward();
                      } else {
                        _expandController.reverse();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isDescriptionExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isDescriptionExpanded
                                ? context.tr('property.info.showLess')
                                : context.tr('property.info.showMore'),
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the futuristic info grid.
  /// العربية: يبني futuristic info grid.
  Widget _buildFuturisticInfoGrid() {
    final items = [
      _InfoItem(
        icon: Icons.home_work_outlined,
        label: context.tr('property.info.type'),
        value: widget.property.typeName,
        color: AppTheme.primaryBlue,
      ),
      _InfoItem(
        icon: Icons.stars_outlined,
        label: context.tr('property.info.category'),
        value: context.tr(
          'property.info.stars',
          params: {'count': widget.property.starRating},
        ),
        color: AppTheme.warning,
      ),
      _InfoItem(
        icon: Icons.location_city_outlined,
        label: context.tr('property.info.city'),
        value: widget.property.city,
        color: AppTheme.primaryCyan,
      ),
      _InfoItem(
        icon: Icons.apartment_outlined,
        label: context.tr('property.info.unitsCount'),
        value: context.tr(
          'property.info.unitsValue',
          params: {'count': widget.property.unitsCount},
        ),
        color: AppTheme.primaryPurple,
      ),
    ];

    return AnimatedBuilder(
      animation: _gridAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _gridAnimation.value,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildFuturisticInfoCard(item, index);
            },
          ),
        );
      },
    );
  }

  /// Builds the futuristic info card.
  /// العربية: يبني futuristic info card.
  Widget _buildFuturisticInfoCard(_InfoItem item, int index) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                item.color.withOpacity(0.15),
                item.color.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: item.color.withOpacity(0.3),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: item.color.withOpacity(0.08 * _glowController.value),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  size: 14,
                  color: item.color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.label,
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.value,
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the futuristic owner info.
  /// العربية: يبني futuristic owner info.
  Widget _buildFuturisticOwnerInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryViolet.withOpacity(0.15),
            AppTheme.primaryBlue.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryViolet.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('property.info.owner'),
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.primaryViolet,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: Text(
                    widget.property.ownerName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.success.withOpacity(0.2),
                  AppTheme.success.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.success.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  context.tr('property.info.online'),
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Describes the InfoItem type used in the property feature.
/// العربية: يمثل `InfoItem`.
class _InfoItem {
  /// Keeps the icon value available to this object.
  /// العربية: يخزن القيمة `icon`.
  final IconData icon;

  /// Keeps the label value available to this object.
  /// العربية: يخزن القيمة `label`.
  final String label;

  /// Keeps the value value available to this object.
  /// العربية: يخزن القيمة `value`.
  final String value;

  /// Keeps the color value available to this object.
  /// العربية: يخزن القيمة `color`.
  final Color color;

  /// Constructs the InfoItem value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `InfoItem`.
  _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
