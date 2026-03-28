// lib/features/admin_properties/presentation/widgets/property_stats_card.dart

import 'package:hggzkportal/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/widgets/glassmorphic_tooltip.dart';

class PropertyStatsCard extends StatefulWidget {
  /// العربية: يخزن القيمة `title`.
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool isPositive;
  final String? detailedDescription;
  final Map<String, dynamic>? additionalStats;
  const PropertyStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.isPositive = true,
    this.detailedDescription,
    this.additionalStats,
  });
  @override
  State<PropertyStatsCard> createState() => _PropertyStatsCardState();
}

class _PropertyStatsCardState extends State<PropertyStatsCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey _cardKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;
  bool _isPressed = false;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleLongPress() {
    setState(() => _isPressed = true);

    // Build detailed message
    String message = '📊 القيمة الحالية: ${widget.value}\n\n';
    message += widget.detailedDescription ?? 'معلومات تفصيلية عن العقارات';

    if (widget.additionalStats != null && widget.additionalStats!.isNotEmpty) {
      message += '\n\n📈 تفاصيل إضافية:';
      widget.additionalStats!.forEach((key, value) {
        message += '\n• $key: $value';
      });
    }

    // Show tooltip
    GlasmorphicTooltip.show(
      context: context,
      targetKey: _cardKey,
      title: widget.title,
      message: message,
      accentColor: widget.color,
      icon: widget.icon,
      duration: const Duration(seconds: 5),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              key: _cardKey,
              onLongPress: _handleLongPress,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..translate(0.0, _isHovered ? -2.0 : 0.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // حساب الأحجام بناءً على المساحة المتاحة
                      final isSmall = constraints.maxWidth < 150;
                      final iconSize = isSmall ? 14.0 : 16.0;
                      final iconContainerSize = isSmall ? 28.0 : 32.0;
                      final valueFontSize = isSmall ? 16.0 : 20.0;
                      final titleFontSize = isSmall ? 10.0 : 11.0;
                      final trendFontSize = isSmall ? 9.0 : 10.0;
                      final trendIconSize = isSmall ? 9.0 : 10.0;
                      final padding = isSmall ? 10.0 : 12.0;

                      return Container(
                        constraints: const BoxConstraints(
                          minHeight: 92,
                          maxHeight: 118,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.color.withValues(alpha: 0.1),
                              widget.color.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isPressed
                                ? widget.color.withValues(alpha: 0.6)
                                : widget.color.withValues(alpha: 0.2),
                            width: _isPressed ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color
                                  .withValues(alpha: _isHovered ? 0.2 : 0.1),
                              blurRadius: _isHovered ? 25 : 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Padding(
                              padding: EdgeInsets.all(padding - 1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // الصف العلوي - الأيقونة والترند
                                  Flexible(
                                    flex: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // الأيقونة
                                        Container(
                                          width: iconContainerSize,
                                          height: iconContainerSize,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                widget.color
                                                    .withValues(alpha: 0.3),
                                                widget.color
                                                    .withValues(alpha: 0.1),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            widget.icon,
                                            color: widget.color,
                                            size: iconSize,
                                          ),
                                        ),

                                        // الترند
                                        if (widget.trend != null)
                                          Flexible(
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  left: 4),
                                              constraints: BoxConstraints(
                                                maxWidth:
                                                    constraints.maxWidth * 0.5,
                                              ),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: isSmall ? 4 : 6,
                                                  vertical: isSmall ? 1 : 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: widget.isPositive
                                                      ? AppTheme.success
                                                          .withValues(
                                                              alpha: 0.1)
                                                      : AppTheme.error
                                                          .withValues(
                                                              alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      widget.isPositive
                                                          ? Icons
                                                              .trending_up_rounded
                                                          : Icons
                                                              .trending_down_rounded,
                                                      size: trendIconSize,
                                                      color: widget.isPositive
                                                          ? AppTheme.success
                                                          : AppTheme.error,
                                                    ),
                                                    SizedBox(
                                                        width: isSmall ? 1 : 2),
                                                    Flexible(
                                                      child: Text(
                                                        widget.trend!,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          fontSize:
                                                              trendFontSize,
                                                          color: widget
                                                                  .isPositive
                                                              ? AppTheme.success
                                                              : AppTheme.error,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // تم توزيع المساحة باستخدام spaceBetween بدل Expanded لتجنب overflow

                                  // القيمة والعنوان
                                  Flexible(
                                    flex: 0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // القيمة
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: constraints.maxWidth,
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              widget.value,
                                              style: TextStyle(
                                                fontSize: valueFontSize,
                                                color: AppTheme.textWhite,
                                                fontWeight: FontWeight.bold,
                                                height: 1,
                                              ),
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: isSmall ? 1 : 3),

                                        // العنوان مع info icon
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                widget.title,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: titleFontSize,
                                                  color: AppTheme.textMuted,
                                                  height: 1.0,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.info_outline_rounded,
                                              color: AppTheme.textMuted
                                                  .withValues(alpha: 0.5),
                                              size: 12,
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
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
