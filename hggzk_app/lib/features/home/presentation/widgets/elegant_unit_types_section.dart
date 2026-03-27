import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../domain/entities/unit_type.dart';

class ElegantUnitTypesSection extends StatefulWidget {
  final List<UnitType> unitTypes;
  final String? selectedUnitTypeId;
  final Function(String?) onUnitTypeSelected;

  const ElegantUnitTypesSection({
    super.key,
    required this.unitTypes,
    this.selectedUnitTypeId,
    required this.onUnitTypeSelected,
  });

  @override
  State<ElegantUnitTypesSection> createState() =>
      _ElegantUnitTypesSectionState();
}

class _ElegantUnitTypesSectionState extends State<ElegantUnitTypesSection>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _showLeftGradient = false;
  bool _showRightGradient = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        setState(() {
          _showLeftGradient = _scrollController.offset > 10;
          _showRightGradient = _scrollController.offset <
              _scrollController.position.maxScrollExtent - 10;
        });
      }
    });
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.unitTypes.isEmpty) return const SizedBox.shrink();

    UnitType? selectedUnitType;
    if (widget.selectedUnitTypeId != null) {
      for (final u in widget.unitTypes) {
        if (u.id == widget.selectedUnitTypeId) {
          selectedUnitType = u;
          break;
        }
      }
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHintMessage(),
              const SizedBox(height: 12),
              _buildPickerButton(context, selectedUnitType),
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
              'يرجى تحديد نوع الوحدة',
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
    UnitType? selectedUnitType,
  ) {
    final bool isSelected = selectedUnitType != null;
    final Color baseColor = AppTheme.darkCard.withOpacity(0.35);
    final Color borderColor = isSelected
        ? AppTheme.primaryPurple.withOpacity(0.30)
        : AppTheme.darkBorder.withOpacity(0.18);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          _showUnitTypePickerSheet(context, selectedUnitType);
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
                      ? AppTheme.primaryPurple.withOpacity(0.12)
                      : AppTheme.darkCard.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryPurple.withOpacity(0.20)
                        : AppTheme.darkBorder.withOpacity(0.16),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isSelected
                      ? IconMapper.getIconFromString(selectedUnitType!.icon)
                      : Icons.meeting_room_rounded,
                  size: 18,
                  color: isSelected
                      ? AppTheme.primaryPurple.withOpacity(0.95)
                      : AppTheme.textMuted.withOpacity(0.75),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نوع الوحدة',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedUnitType?.name ?? '—',
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

  Future<void> _showUnitTypePickerSheet(
    BuildContext context,
    UnitType? selectedUnitType,
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
                            'اختر نوع الوحدة',
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
                              color: AppTheme.primaryPurple.withOpacity(0.9),
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
                          child: _buildUnitTypesList(sheetContext: sheetContext),
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

  Widget _buildUnitTypesList({BuildContext? sheetContext}) {
    return Column(
      children: widget.unitTypes.map((u) {
        final bool isSelected = widget.selectedUnitTypeId == u.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _handleSelection(u.id, popContext: sheetContext),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryPurple.withOpacity(0.12)
                      : AppTheme.darkCard.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryPurple.withOpacity(0.28)
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
                            ? AppTheme.primaryPurple.withOpacity(0.14)
                            : AppTheme.darkBackground.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryPurple.withOpacity(0.22)
                              : AppTheme.darkBorder.withOpacity(0.16),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        IconMapper.getIconFromString(u.icon),
                        size: 18,
                        color: isSelected
                            ? AppTheme.primaryPurple.withOpacity(0.95)
                            : AppTheme.textMuted.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppTheme.textWhite.withOpacity(0.95),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            u.description,
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
                        color: AppTheme.primaryPurple.withOpacity(0.95),
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
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPurple.withOpacity(
                      0.12 + 0.08 * _pulseAnimation.value,
                    ),
                    AppTheme.primaryCyan.withOpacity(
                      0.08 + 0.05 * _pulseAnimation.value,
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryPurple.withOpacity(
                    0.2 + 0.1 * _pulseAnimation.value,
                  ),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(
                      0.15 * _pulseAnimation.value,
                    ),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                Icons.meeting_room_rounded,
                size: 20,
                color: AppTheme.primaryPurple.withOpacity(0.9),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أنواع الوحدات المتاحة',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'اختر نوع الوحدة المناسب لك',
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

  Widget _buildUnitTypesCarousel() {
    return SizedBox(
      height: 120,
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            itemCount: widget.unitTypes.length,
            itemBuilder: (context, index) {
              return _ElegantUnitTypeCard(
                unitType: widget.unitTypes[index],
                isSelected: widget.selectedUnitTypeId ==
                    widget.unitTypes[index].id,
                onTap: () => _handleSelection(widget.unitTypes[index].id),
                animationDelay: Duration(milliseconds: index * 60),
              );
            },
          ),
          if (_showLeftGradient || _showRightGradient)
            _buildScrollIndicators(),
        ],
      ),
    );
  }

  Widget _buildScrollIndicators() {
    return IgnorePointer(
      child: Row(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _showLeftGradient ? 1.0 : 0.0,
            child: Container(
              width: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkBackground.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: AppTheme.primaryPurple.withOpacity(0.6),
                ),
              ),
            ),
          ),
          const Spacer(),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _showRightGradient ? 1.0 : 0.0,
            child: Container(
              width: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.darkBackground.withOpacity(0.8),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppTheme.primaryPurple.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSelection(String unitTypeId, {BuildContext? popContext}) {
    HapticFeedback.selectionClick();
    if (widget.selectedUnitTypeId == unitTypeId) return;
    widget.onUnitTypeSelected(unitTypeId);

    if (popContext != null) {
      Navigator.of(popContext).pop();
    }
  }
}

class _ElegantUnitTypeCard extends StatefulWidget {
  final UnitType unitType;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration animationDelay;

  const _ElegantUnitTypeCard({
    required this.unitType,
    required this.isSelected,
    required this.onTap,
    this.animationDelay = Duration.zero,
  });

  @override
  State<_ElegantUnitTypeCard> createState() => _ElegantUnitTypeCardState();
}

class _ElegantUnitTypeCardState extends State<_ElegantUnitTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_ElegantUnitTypeCard oldWidget) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration:
          Duration(milliseconds: 500 + widget.animationDelay.inMilliseconds),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.7 + 0.3 * animValue,
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
                      width: 115,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: widget.isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryPurple.withOpacity(
                                    0.2 + 0.15 * _glowAnimation.value,
                                  ),
                                  blurRadius: 16 + 8 * _glowAnimation.value,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: AppTheme.primaryCyan.withOpacity(
                                    0.1 + 0.05 * _glowAnimation.value,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
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
                                        AppTheme.primaryPurple.withOpacity(
                                          isDarkMode ? 0.15 : 0.2,
                                        ),
                                        AppTheme.primaryCyan.withOpacity(
                                          isDarkMode ? 0.10 : 0.15,
                                        ),
                                      ]
                                    : [
                                        isDarkMode
                                            ? Colors.white.withOpacity(0.04)
                                            : Colors.white.withOpacity(0.7),
                                        isDarkMode
                                            ? Colors.white.withOpacity(0.02)
                                            : Colors.white.withOpacity(0.5),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: widget.isSelected
                                    ? AppTheme.primaryPurple.withOpacity(
                                        0.4 + 0.2 * _glowAnimation.value,
                                      )
                                    : isDarkMode
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.white.withOpacity(0.5),
                                width: widget.isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _buildContent(isDarkMode),
                                if (widget.isSelected)
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: _buildSelectionIndicator(),
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
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(isDarkMode),
          const SizedBox(height: 8),
          Text(
            widget.unitType.name,
            style: AppTextStyles.caption.copyWith(
              color: widget.isSelected
                  ? AppTheme.primaryPurple
                  : isDarkMode
                      ? AppTheme.textWhite.withOpacity(0.85)
                      : AppTheme.textDark.withOpacity(0.9),
              fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(bool isDarkMode) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isSelected
              ? [
                  AppTheme.primaryPurple.withOpacity(0.2),
                  AppTheme.primaryCyan.withOpacity(0.15),
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
              ? AppTheme.primaryPurple.withOpacity(0.3)
              : isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: widget.isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primaryPurple.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Icon(
        IconMapper.getIconFromString(widget.unitType.icon),
        size: 22,
        color: widget.isSelected
            ? AppTheme.primaryPurple
            : isDarkMode
                ? AppTheme.textWhite.withOpacity(0.7)
                : AppTheme.textDark.withOpacity(0.8),
      ),
    );
  }

  Widget _buildSelectionIndicator() {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPurple,
            AppTheme.primaryCyan,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Icon(
        Icons.check_rounded,
        size: 12,
        color: Colors.white,
      ),
    );
  }
}
