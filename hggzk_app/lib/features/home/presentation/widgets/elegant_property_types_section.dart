import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../domain/entities/property_type.dart';

class ElegantPropertyTypesSection extends StatefulWidget {
  final List<PropertyType> propertyTypes;
  final String? selectedTypeId;
  final Function(String?) onTypeSelected;

  const ElegantPropertyTypesSection({
    super.key,
    required this.propertyTypes,
    this.selectedTypeId,
    required this.onTypeSelected,
  });

  @override
  State<ElegantPropertyTypesSection> createState() =>
      _ElegantPropertyTypesSectionState();
}

class _ElegantPropertyTypesSectionState
    extends State<ElegantPropertyTypesSection>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuart),
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.propertyTypes.isEmpty) return const SizedBox.shrink();

    PropertyType? selectedProperty;
    if (widget.selectedTypeId != null) {
      for (final p in widget.propertyTypes) {
        if (p.id == widget.selectedTypeId) {
          selectedProperty = p;
          break;
        }
      }
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHintMessage(),
              const SizedBox(height: 12),
              _buildPickerButton(context, selectedProperty),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHintMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.18),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppTheme.textMuted.withOpacity(0.85),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'يرجى تحديد نوع العقار',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerButton(
    BuildContext context,
    PropertyType? selectedProperty,
  ) {
    final bool isSelected = selectedProperty != null;
    final Color baseColor = AppTheme.darkCard.withOpacity(0.35);
    final Color borderColor = isSelected
        ? AppTheme.primaryBlue.withOpacity(0.35)
        : AppTheme.darkBorder.withOpacity(0.18);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          _showPropertyTypePickerSheet(context, selectedProperty);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryBlue.withOpacity(0.12)
                      : AppTheme.darkCard.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryBlue.withOpacity(0.22)
                        : AppTheme.darkBorder.withOpacity(0.16),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isSelected
                      ? IconMapper.getIconFromString(selectedProperty!.icon)
                      : Icons.category_rounded,
                  size: 18,
                  color: isSelected
                      ? AppTheme.primaryBlue.withOpacity(0.95)
                      : AppTheme.textMuted.withOpacity(0.75),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نوع العقار',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedProperty?.name ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textWhite.withOpacity(0.95),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textMuted.withOpacity(0.75),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPropertyTypePickerSheet(
    BuildContext context,
    PropertyType? selectedProperty,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final ScrollController scrollController = ScrollController();
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.darkBackground.withOpacity(0.92),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              border: Border.all(
                color: AppTheme.darkBorder.withOpacity(0.18),
                width: 1,
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppTheme.textMuted.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'اختر نوع العقار',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppTheme.textWhite,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(sheetContext).pop();
                          },
                          child: Text(
                            '',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppTheme.primaryBlue.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(sheetContext).size.height * 0.62,
                      ),
                      child: Scrollbar(
                        controller: scrollController,
                        thumbVisibility: true,
                        radius: const Radius.circular(99),
                        thickness: 4,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: _buildPropertyTypesList(sheetContext: sheetContext),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPropertyTypesList({BuildContext? sheetContext}) {
    return Column(
      children: widget.propertyTypes.map((p) {
        final bool isSelected = widget.selectedTypeId == p.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _handleSelection(p, popContext: sheetContext),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryBlue.withOpacity(0.12)
                      : AppTheme.darkCard.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryBlue.withOpacity(0.28)
                        : AppTheme.darkBorder.withOpacity(0.18),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryBlue.withOpacity(0.14)
                            : AppTheme.darkBackground.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryBlue.withOpacity(0.22)
                              : AppTheme.darkBorder.withOpacity(0.16),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        IconMapper.getIconFromString(p.icon),
                        size: 18,
                        color: isSelected
                            ? AppTheme.primaryBlue.withOpacity(0.95)
                            : AppTheme.textMuted.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppTheme.textWhite.withOpacity(0.95),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.textMuted.withOpacity(0.72),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: AppTheme.primaryBlue.withOpacity(0.95),
                      )
                    else
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppTheme.textMuted.withOpacity(0.55),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryBlue.withOpacity(0.15),
                AppTheme.primaryPurple.withOpacity(0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.category_rounded,
            size: 20,
            color: AppTheme.primaryBlue.withOpacity(0.9),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اختر نوع العقار',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'تصفح حسب نوع الإقامة المفضل لديك',
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyTypesGrid({BuildContext? sheetContext}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width > 600 ? 5 : 4;
        final childAspectRatio = width > 600 ? 0.85 : 0.72;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: widget.propertyTypes.length,
          itemBuilder: (context, index) {
            return _ElegantPropertyTypeCard(
              propertyType: widget.propertyTypes[index],
              isSelected: widget.selectedTypeId == widget.propertyTypes[index].id,
              onTap: () => _handleSelection(
                widget.propertyTypes[index],
                popContext: sheetContext,
              ),
              animationDelay: Duration(milliseconds: index * 80),
            );
          },
        );
      },
    );
  }

  Widget _buildStatisticsBadge(PropertyType property) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryBlue.withOpacity(0.12 + 0.03 * _shimmerController.value),
                AppTheme.primaryPurple.withOpacity(0.08 + 0.02 * _shimmerController.value),
                AppTheme.primaryCyan.withOpacity(0.06 + 0.02 * _shimmerController.value),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.15),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.2),
                      AppTheme.primaryPurple.withOpacity(0.15),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  IconMapper.getIconFromString(property.icon),
                  size: 20,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تم تحديد: ${property.name}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${property.propertiesCount} ${property.propertiesCount == 1 ? 'عقار' : 'عقارات'} متاحة',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted.withOpacity(0.8),
                      ),
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

  void _handleSelection(PropertyType type, {BuildContext? popContext}) {
    HapticFeedback.selectionClick();
    if (widget.selectedTypeId == type.id) return;
    widget.onTypeSelected(type.id);

    if (popContext != null) {
      Navigator.of(popContext).pop();
    }
  }
}

class _ElegantPropertyTypeCard extends StatefulWidget {
  final PropertyType propertyType;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration animationDelay;

  const _ElegantPropertyTypeCard({
    required this.propertyType,
    required this.isSelected,
    required this.onTap,
    this.animationDelay = Duration.zero,
  });

  @override
  State<_ElegantPropertyTypeCard> createState() =>
      _ElegantPropertyTypeCardState();
}

class _ElegantPropertyTypeCardState extends State<_ElegantPropertyTypeCard>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _shimmerController;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOutSine,
    ));

    if (widget.isSelected) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_ElegantPropertyTypeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
        _glowController.reset();
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration:
          Duration(milliseconds: 600 + widget.animationDelay.inMilliseconds),
      curve: Curves.elasticOut,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.5 + 0.5 * animValue,
          child: Opacity(
            opacity: animValue.clamp(0.0, 1.0),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) {
                setState(() => _isPressed = false);
                widget.onTap();
              },
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedScale(
                scale: _isPressed ? 0.92 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: widget.isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(
                                    0.15 + 0.1 * _glowAnimation.value,
                                  ),
                                  blurRadius: 15 + 5 * _glowAnimation.value,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 15,
                            sigmaY: 15,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: widget.isSelected
                                    ? [
                                        AppTheme.primaryBlue.withOpacity(
                                          isDarkMode ? 0.12 : 0.18,
                                        ),
                                        AppTheme.primaryPurple.withOpacity(
                                          isDarkMode ? 0.08 : 0.12,
                                        ),
                                      ]
                                    : [
                                        isDarkMode
                                            ? Colors.white.withOpacity(0.04)
                                            : Colors.white.withOpacity(0.75),
                                        isDarkMode
                                            ? Colors.white.withOpacity(0.02)
                                            : Colors.white.withOpacity(0.55),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: widget.isSelected
                                    ? AppTheme.primaryBlue.withOpacity(
                                        0.4 + 0.2 * _glowAnimation.value,
                                      )
                                    : isDarkMode
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.white.withOpacity(0.6),
                                width: widget.isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _buildContent(isDarkMode),
                                if (!widget.isSelected)
                                  _buildShimmerOverlay(isDarkMode),
                                if (widget.isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: _buildSelectionBadge(),
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
        );
      },
    );
  }

  Widget _buildContent(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(isDarkMode),
          const SizedBox(height: 5),
          Flexible(
            child: Text(
              widget.propertyType.name,
              style: AppTextStyles.caption.copyWith(
                color: widget.isSelected
                    ? AppTheme.primaryBlue
                    : isDarkMode
                        ? AppTheme.textWhite.withOpacity(0.85)
                        : AppTheme.textDark.withOpacity(0.9),
                fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.propertyType.propertiesCount > 0) ...[
            const SizedBox(height: 3),
            _buildCountBadge(isDarkMode),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(bool isDarkMode) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isSelected
              ? [
                  AppTheme.primaryBlue.withOpacity(0.2),
                  AppTheme.primaryPurple.withOpacity(0.15),
                ]
              : [
                  isDarkMode
                      ? AppTheme.darkCard.withOpacity(0.3)
                      : Colors.white.withOpacity(0.6),
                  isDarkMode
                      ? AppTheme.darkCard.withOpacity(0.2)
                      : Colors.white.withOpacity(0.4),
                ],
        ),
        border: Border.all(
          color: widget.isSelected
              ? AppTheme.primaryBlue.withOpacity(0.3)
              : isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: widget.isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          IconMapper.getIconFromString(widget.propertyType.icon),
          size: 22,
          color: widget.isSelected
              ? AppTheme.primaryBlue
              : isDarkMode
                  ? AppTheme.textWhite.withOpacity(0.7)
                  : AppTheme.textDark.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildCountBadge(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isSelected
              ? [
                  AppTheme.primaryBlue.withOpacity(0.2),
                  AppTheme.primaryPurple.withOpacity(0.15),
                ]
              : [
                  isDarkMode
                      ? Colors.white.withOpacity(0.06)
                      : Colors.white.withOpacity(0.5),
                  isDarkMode
                      ? Colors.white.withOpacity(0.04)
                      : Colors.white.withOpacity(0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.isSelected
              ? AppTheme.primaryBlue.withOpacity(0.3)
              : isDarkMode
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        '${widget.propertyType.propertiesCount}',
        style: AppTextStyles.caption.copyWith(
          color: widget.isSelected
              ? AppTheme.primaryBlue
              : isDarkMode
                  ? AppTheme.textMuted.withOpacity(0.7)
                  : AppTheme.textDark.withOpacity(0.8),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildShimmerOverlay(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: CustomPaint(
              painter: _ShimmerPainter(
                shimmerValue: _shimmerAnimation.value,
                isDarkMode: isDarkMode,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionBadge() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryCyan,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Icon(
        Icons.check_rounded,
        size: 14,
        color: Colors.white,
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double shimmerValue;
  final bool isDarkMode;

  _ShimmerPainter({
    required this.shimmerValue,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          isDarkMode
              ? Colors.white.withOpacity(0.02)
              : Colors.white.withOpacity(0.15),
          Colors.transparent,
        ],
        stops: [
          (shimmerValue - 0.3).clamp(0.0, 1.0),
          shimmerValue.clamp(0.0, 1.0),
          (shimmerValue + 0.3).clamp(0.0, 1.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) {
    return shimmerValue != oldDelegate.shimmerValue;
  }
}
