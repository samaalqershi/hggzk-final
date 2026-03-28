// lib/features/admin_units/presentation/widgets/unit_stats_card.dart

import 'package:hggzkportal/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/widgets/glassmorphic_tooltip.dart';

/// يمثل هذا الكلاس UnitStatsCard البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitStatsCard in the admin unit workflow.
class UnitStatsCard extends StatefulWidget {
  /// This field keeps the title value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة title التي يعتمد عليها مسار إدارة الوحدات.
  final String title;

  /// يحتفظ هذا الحقل بقيمة value التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the value value used by the admin unit workflow.
  final String value;

  /// يحتفظ هذا الحقل بقيمة icon التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the icon value used by the admin unit workflow.
  final IconData icon;

  /// يحتفظ هذا الحقل بقيمة color التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the color value used by the admin unit workflow.
  final Color color;

  /// يحتفظ هذا الحقل بقيمة trend التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the trend value used by the admin unit workflow.
  final String? trend;

  /// يحتفظ هذا الحقل بقيمة isPositive التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isPositive value used by the admin unit workflow.
  final bool isPositive;

  /// يحتفظ هذا الحقل بقيمة detailedDescription التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the detailedDescription value used by the admin unit workflow.
  final String? detailedDescription;

  /// يحتفظ هذا الحقل بقيمة additionalStats التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the additionalStats value used by the admin unit workflow.
  final Map<String, dynamic>? additionalStats;

  /// ينشئ هذا المُنشئ مثيلاً من UnitStatsCard.
  /// This constructor creates an instance of UnitStatsCard.
  const UnitStatsCard({
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

  /// ينشئ هذا الأسلوب كائن الحالة الخاص بهذه الصفحة.
  /// This method performs the createState operation in the admin unit workflow.
  @override
  State<UnitStatsCard> createState() => _UnitStatsCardState();
}

/// يمثل هذا الكلاس _UnitStatsCardState البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _UnitStatsCardState in the admin unit workflow.
class _UnitStatsCardState extends State<UnitStatsCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey _cardKey = GlobalKey();

  /// يحتفظ هذا الحقل بقيمة _animationController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _animationController value used by the admin unit workflow.
  late AnimationController _animationController;

  /// يحتفظ هذا الحقل بقيمة _scaleAnimation التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _scaleAnimation value used by the admin unit workflow.
  late Animation<double> _scaleAnimation;

  /// يحتفظ هذا الحقل بقيمة _fadeAnimation التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _fadeAnimation value used by the admin unit workflow.
  late Animation<double> _fadeAnimation;

  /// يحتفظ هذا الحقل بقيمة _isHovered التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _isHovered value used by the admin unit workflow.
  bool _isHovered = false;

  /// يحتفظ هذا الحقل بقيمة _isPressed التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _isPressed value used by the admin unit workflow.
  bool _isPressed = false;

  /// ينفذ هذا الأسلوب عملية initState ضمن مسار إدارة الوحدات.
  /// This method performs the initState operation in the admin unit workflow.
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

  /// ينفذ هذا الأسلوب عملية dispose ضمن مسار إدارة الوحدات.
  /// This method performs the dispose operation in the admin unit workflow.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// ينفذ هذا الأسلوب عملية _handleLongPress ضمن مسار إدارة الوحدات.
  /// This method performs the _handleLongPress operation in the admin unit workflow.
  void _handleLongPress() {
    setState(() => _isPressed = true);

    String message = '📊 القيمة الحالية: ${widget.value}\n\n';
    message += widget.detailedDescription ?? 'معلومات تفصيلية عن الوحدات';

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
      accentColor: widget.color,
      icon: widget.icon,
      duration: const Duration(seconds: 5),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
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
                          minHeight: 95,
                          maxHeight: 120,
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
                              padding: EdgeInsets.all(padding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                      if (widget.trend != null)
                                        Flexible(
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(left: 4),
                                            constraints: BoxConstraints(
                                              maxWidth:
                                                  constraints.maxWidth * 0.5,
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isSmall ? 4 : 6,
                                                vertical: isSmall ? 2 : 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: widget.isPositive
                                                    ? AppTheme.success
                                                        .withValues(alpha: 0.1)
                                                    : AppTheme.error
                                                        .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: trendFontSize,
                                                        color: widget.isPositive
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
                                  const SizedBox(height: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
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
                                      SizedBox(height: isSmall ? 2 : 4),
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
                                                height: 1.2,
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
