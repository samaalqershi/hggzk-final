// lib/features/admin_properties/presentation/widgets/property_card_widget.dart

import 'package:hggzkportal/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:hggzkportal/core/theme/app_text_styles.dart';
import '../../domain/entities/property.dart';
import '../../../../core/widgets/property_identity_card_tooltip.dart';

class PropertyCardWidget extends StatefulWidget {
  /// العربية: يخزن القيمة `property`.
  final Property property;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  const PropertyCardWidget({
    super.key,
    required this.property,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });
  @override
  State<PropertyCardWidget> createState() => _PropertyCardWidgetState();
}

class _PropertyCardWidgetState extends State<PropertyCardWidget>
    with SingleTickerProviderStateMixin {
  final GlobalKey _cardKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showPropertyCard() {
    setState(() => _isPressed = true);

    HapticFeedback.mediumImpact();

    final property = widget.property;
    PropertyIdentityCardTooltip.show(
      context: context,
      targetKey: _cardKey,
      propertyId: property.id,
      name: property.name,
      nameEn: property.nameEn,
      typeName: property.typeName,
      typeNameEn: property.typeNameEn,
      ownerName: property.ownerName,
      address: property.address,
      addressEn: property.addressEn,
      city: property.city,
      cityEn: property.cityEn,
      starRating: property.starRating,
      coverImage: property.images.isNotEmpty
          ? property.images.first.thumbnails.large
          : null,
      isApproved: property.isApproved,
      isFeatured: property.isFeatured,
      createdAt: property.createdAt,
      viewCount: property.viewCount,
      bookingCount: property.bookingCount,
      averageRating: property.averageRating,
      shortDescription: property.shortDescription,
      shortDescriptionEn: property.shortDescriptionEn,
      currency: property.currency,
      amenitiesCount: property.amenities.length,
      policiesCount: property.policies.length,
      unitsCount: property.stats?.totalBookings ?? 0,
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  bool _hasSecondary(String? secondary, String primary) {
    if (secondary == null) {
      return false;
    }

    final trimmed = secondary.trim();
    return trimmed.isNotEmpty && trimmed != primary.trim();
  }

  Widget _buildBilingualText(
    String primary, {
    String? secondary,
    TextStyle? primaryStyle,
    TextStyle? secondaryStyle,
    int primaryMaxLines = 1,
    int secondaryMaxLines = 1,
  }) {
    final showSecondary = _hasSecondary(secondary, primary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          primary,
          style: primaryStyle,
          maxLines: primaryMaxLines,
          overflow: TextOverflow.ellipsis,
        ),
        if (showSecondary) ...[
          const SizedBox(height: 2),
          Text(
            secondary!,
            style: secondaryStyle ??
                primaryStyle?.copyWith(
                  color: AppTheme.textMuted,
                  fontSize: (primaryStyle.fontSize ?? 14) - 1,
                ),
            maxLines: secondaryMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: GestureDetector(
        key: _cardKey,
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        onLongPress: _showPropertyCard,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isHovered
                        ? [
                            AppTheme.primaryBlue.withValues(alpha: 0.1),
                            AppTheme.primaryPurple.withValues(alpha: 0.05),
                          ]
                        : [
                            AppTheme.darkCard.withValues(alpha: 0.7),
                            AppTheme.darkCard.withValues(alpha: 0.5),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isPressed
                        ? AppTheme.primaryBlue.withValues(alpha: 0.7)
                        : _isHovered
                            ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                            : AppTheme.darkBorder.withValues(alpha: 0.3),
                    width: _isPressed ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? AppTheme.primaryBlue.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.1),
                      blurRadius: _isHovered ? 20 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Background Image
                      if (widget.property.images.isNotEmpty)
                        Positioned.fill(
                          child: Image.network(
                            widget.property.images.first.thumbnails.medium,
                            fit: BoxFit.cover,
                          ),
                        ),

                      // Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppTheme.darkBackground.withValues(alpha: 0.7),
                                AppTheme.darkBackground.withValues(alpha: 0.9),
                              ],
                              stops: const [0.3, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Glass Effect
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.property.isApproved
                                        ? AppTheme.success
                                            .withValues(alpha: 0.2)
                                        : AppTheme.warning
                                            .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: widget.property.isApproved
                                          ? AppTheme.success
                                              .withValues(alpha: 0.5)
                                          : AppTheme.warning
                                              .withValues(alpha: 0.5),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    widget.property.isApproved
                                        ? 'معتمد'
                                        : 'قيد المراجعة',
                                    style: AppTextStyles.caption.copyWith(
                                      color: widget.property.isApproved
                                          ? AppTheme.success
                                          : AppTheme.warning,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                // Actions
                                if (widget.showActions && _isHovered)
                                  Row(
                                    children: [
                                      if (widget.onEdit != null)
                                        _buildActionButton(
                                          Icons.edit_rounded,
                                          widget.onEdit!,
                                        ),
                                      if (widget.onDelete != null) ...[
                                        const SizedBox(width: 4),
                                        _buildActionButton(
                                          Icons.delete_rounded,
                                          widget.onDelete!,
                                          color: AppTheme.error,
                                        ),
                                      ],
                                    ],
                                  ),
                              ],
                            ),

                            const Spacer(),

                            // Property Name
                            _buildBilingualText(
                              widget.property.name,
                              secondary: widget.property.nameEn,
                              primaryStyle: AppTextStyles.heading3.copyWith(
                                color: AppTheme.textWhite,
                                fontWeight: FontWeight.bold,
                              ),
                              secondaryStyle: AppTextStyles.caption.copyWith(
                                color: AppTheme.textMuted,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Location
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: AppTheme.primaryBlue
                                      .withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: _buildBilingualText(
                                    widget.property.city,
                                    secondary: widget.property.cityEn,
                                    primaryStyle:
                                        AppTextStyles.caption.copyWith(
                                      color: AppTheme.textMuted,
                                    ),
                                    secondaryStyle:
                                        AppTextStyles.caption.copyWith(
                                      color: AppTheme.textMuted
                                          .withValues(alpha: 0.75),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Bottom Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Star Rating
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < widget.property.starRating
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      size: 14,
                                      color: AppTheme.warning,
                                    );
                                  }),
                                ),

                                // Type Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _buildBilingualText(
                                    widget.property.typeName,
                                    secondary: widget.property.typeNameEn,
                                    primaryStyle:
                                        AppTextStyles.caption.copyWith(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    secondaryStyle:
                                        AppTextStyles.caption.copyWith(
                                      color: AppTheme.primaryBlue
                                          .withValues(alpha: 0.8),
                                    ),
                                    secondaryMaxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppTheme.darkBackground.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: (color ?? AppTheme.primaryBlue).withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: color ?? AppTheme.primaryBlue,
        ),
      ),
    );
  }
}
