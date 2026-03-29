import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../domain/entities/unit.dart';

/// Describes the UnitsListWidget widget used in the property feature.
/// العربية: يمثل العنصر `UnitsListWidget`.
class UnitsListWidget extends StatefulWidget {
  /// Keeps the units value available to this object.
  /// العربية: يخزن القيمة `units`.
  final List<Unit> units;

  /// Processes the Function flow and maps it into the property feature behavior.
  /// العربية: يعالج `Function`.
  final Function(Unit) onUnitSelect;

  /// Keeps the selectedUnitId value available to this object.
  /// العربية: يخزن القيمة `selectedUnitId`.
  final String? selectedUnitId;

  /// Constructs the UnitsListWidget value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `UnitsListWidget`.
  const UnitsListWidget({
    super.key,
    required this.units,
    required this.onUnitSelect,
    this.selectedUnitId,
  });

  /// Builds the state object for this widget used by this feature.
  /// العربية: ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<UnitsListWidget> createState() => _UnitsListWidgetState();
}

/// Describes the state for `UnitsListWidgetState`.
/// العربية: يمثل الحالة الخاصة بـ `UnitsListWidgetState`.
class _UnitsListWidgetState extends State<UnitsListWidget>
    with TickerProviderStateMixin {
  /// Keeps the gridController value available to this object.
  /// العربية: يخزن القيمة `gridController`.
  late AnimationController _gridController;

  /// Keeps the pulseController value available to this object.
  /// العربية: يخزن القيمة `pulseController`.
  late AnimationController _pulseController;

  /// Keeps the shimmerController value available to this object.
  /// العربية: يخزن القيمة `shimmerController`.
  late AnimationController _shimmerController;

  /// Keeps the gridAnimation value available to this object.
  /// العربية: يخزن القيمة `gridAnimation`.
  late Animation<double> _gridAnimation;

  /// Keeps the pulseAnimation value available to this object.
  /// العربية: يخزن القيمة `pulseAnimation`.
  late Animation<double> _pulseAnimation;

  /// Keeps the cardControllers value available to this object.
  /// العربية: يخزن القيمة `cardControllers`.
  final Map<String, AnimationController> _cardControllers = {};

  /// Keeps the orbs value available to this object.
  /// العربية: يخزن القيمة `orbs`.
  final List<_FloatingOrb> _orbs = [];

  /// Indicates whether `isGridView` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isGridView` مفعلة.
  bool _isGridView = true;

  /// Initializes the state for this widget.
  /// العربية: يهيئ الحالة الخاصة بهذا العنصر.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateOrbs();
    _startAnimations();
  }

  /// Initializes the animations.
  /// العربية: يهيئ animations.
  void _initializeAnimations() {
    _gridController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _gridAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gridController,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  /// Generates the orbs.
  /// العربية: ينشئ orbs.
  void _generateOrbs() {
    for (int i = 0; i < 5; i++) {
      _orbs.add(_FloatingOrb());
    }
  }

  /// Starts the animations.
  /// العربية: يبدأ animations.
  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _gridController.forward();
      }
    });
  }

  /// Releases the resources used by this instance.
  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _gridController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _cardControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  /// Builds the widget tree for this component.
  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    if (widget.units.isEmpty) {
      return _buildEmptyState();
    }

    return Stack(
      children: [
        _buildAnimatedBackground(),
        Column(
          children: [
            _buildViewToggle(),
            Expanded(
              child: AnimatedBuilder(
                animation: _gridAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.95 + (_gridAnimation.value * 0.05),
                    child: _isGridView ? _buildGridView() : _buildListView(),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the view toggle.
  /// العربية: يبني view toggle.
  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkCard.withOpacity(0.6),
                  AppTheme.darkCard.withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                _buildToggleButton(
                  icon: Icons.grid_view_rounded,
                  isSelected: _isGridView,
                  onTap: () {
                    setState(() => _isGridView = true);
                    HapticFeedback.lightImpact();
                  },
                ),
                _buildToggleButton(
                  icon: Icons.view_agenda_rounded,
                  isSelected: !_isGridView,
                  onTap: () {
                    setState(() => _isGridView = false);
                    HapticFeedback.lightImpact();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the toggle button.
  /// العربية: يبني toggle button.
  Widget _buildToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : AppTheme.textMuted,
        ),
      ),
    );
  }

  /// Builds the grid view.
  /// العربية: يبني grid view.
  Widget _buildGridView() {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        // Increase vertical space to avoid internal Column overflow
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: widget.units.length,
      itemBuilder: (context, index) {
        final unit = widget.units[index];
        final isSelected =
            widget.selectedUnitId != null && unit.id == widget.selectedUnitId;

        if (!_cardControllers.containsKey(unit.id)) {
          _cardControllers[unit.id] = AnimationController(
            duration: const Duration(milliseconds: 400),
            vsync: this,
          );
        }

        return _buildCompactUnitCard(unit, isSelected, index);
      },
    );
  }

  /// Builds the list view.
  /// العربية: يبني list view.
  Widget _buildListView() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: widget.units.length,
      itemBuilder: (context, index) {
        final unit = widget.units[index];
        final isSelected =
            widget.selectedUnitId != null && unit.id == widget.selectedUnitId;

        if (!_cardControllers.containsKey(unit.id)) {
          _cardControllers[unit.id] = AnimationController(
            duration: const Duration(milliseconds: 400),
            vsync: this,
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildHorizontalUnitCard(unit, isSelected, index),
        );
      },
    );
  }

  /// Builds the compact unit card.
  /// العربية: يبني compact unit card.
  Widget _buildCompactUnitCard(Unit unit, bool isSelected, int index) {
    // Debug: unit card build info
    // print('[UnitsListWidget] build card: unit.id=${unit.id}, selectedUnitId=${widget.selectedUnitId}, isSelected=$isSelected');
    return GestureDetector(
      onTap: () {
        // Debug: unit card tap
        // print('[UnitsListWidget] onTap: unit.id=${unit.id}, selectedUnitId=${widget.selectedUnitId}');
        widget.onUnitSelect(unit);
        HapticFeedback.lightImpact();
        _cardControllers[unit.id]?.forward().then((_) {
          _cardControllers[unit.id]?.reverse();
        });
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? _pulseAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [
                          AppTheme.primaryBlue.withOpacity(0.25),
                          AppTheme.primaryPurple.withOpacity(0.15),
                        ]
                      : [
                          AppTheme.darkCard.withOpacity(0.7),
                          AppTheme.darkCard.withOpacity(0.5),
                        ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryBlue.withOpacity(0.5)
                      : AppTheme.darkBorder.withOpacity(0.2),
                  width: isSelected ? 1.5 : 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppTheme.primaryBlue.withOpacity(0.2)
                        : AppTheme.shadowDark.withOpacity(0.1),
                    blurRadius: isSelected ? 15 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCompactImageSection(unit, isSelected),
                      _buildCompactContent(unit, isSelected),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the horizontal unit card.
  /// العربية: يبني horizontal unit card.
  Widget _buildHorizontalUnitCard(Unit unit, bool isSelected, int index) {
    return GestureDetector(
      onTap: () {
        widget.onUnitSelect(unit);
        HapticFeedback.lightImpact();
        _cardControllers[unit.id]?.forward().then((_) {
          _cardControllers[unit.id]?.reverse();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    AppTheme.primaryBlue.withOpacity(0.25),
                    AppTheme.primaryPurple.withOpacity(0.15),
                  ]
                : [
                    AppTheme.darkCard.withOpacity(0.7),
                    AppTheme.darkCard.withOpacity(0.5),
                  ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue.withOpacity(0.5)
                : AppTheme.darkBorder.withOpacity(0.2),
            width: isSelected ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryBlue.withOpacity(0.2)
                  : AppTheme.shadowDark.withOpacity(0.1),
              blurRadius: isSelected ? 15 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              children: [
                _buildHorizontalImageSection(unit, isSelected),
                Expanded(
                  child: _buildHorizontalContent(context, unit, isSelected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the compact image section.
  /// العربية: يبني compact image section.
  Widget _buildCompactImageSection(Unit unit, bool isSelected) {
    return Stack(
      children: [
        Hero(
          tag: 'unit_image_${unit.id}',
          child: Container(
            // Reduce image height to give more room for bottom content
            height: 128,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (unit.images.isNotEmpty)
                  CachedImageWidget(
                    imageUrl: unit.images.first.url,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    color: AppTheme.darkCard,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppTheme.textMuted,
                        size: 32,
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.darkBackground.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isSelected)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              unit.unitTypeName,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (unit.images.length > 1)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkBackground.withOpacity(0.8),
                    AppTheme.darkBackground.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    size: 10,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${unit.images.length}',
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
    );
  }

  /// Builds the horizontal image section.
  /// العربية: يبني horizontal image section.
  Widget _buildHorizontalImageSection(Unit unit, bool isSelected) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(14),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (unit.images.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
              child: CachedImageWidget(
                imageUrl: unit.images.first.url,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: AppTheme.textMuted,
                  size: 24,
                ),
              ),
            ),
          if (isSelected)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the compact content.
  /// العربية: يبني compact content.
  Widget _buildCompactContent(Unit unit, bool isSelected) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => isSelected
                      ? AppTheme.primaryGradient.createShader(bounds)
                      : LinearGradient(
                          colors: [AppTheme.textWhite, AppTheme.textWhite],
                        ).createShader(bounds),
                  child: Text(
                    unit.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                if (unit.dynamicFields.isNotEmpty) _buildMiniFeatures(unit),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color:
                    !isSelected ? AppTheme.primaryBlue.withOpacity(0.2) : null,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: isSelected ? Colors.white : AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the horizontal content.
  /// العربية: يبني horizontal content.
  Widget _buildHorizontalContent(
    BuildContext context,
    Unit unit,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (bounds) => isSelected
                          ? AppTheme.primaryGradient.createShader(bounds)
                          : LinearGradient(
                              colors: [AppTheme.textWhite, AppTheme.textWhite],
                            ).createShader(bounds),
                      child: Text(
                        unit.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (unit.customFeatures.isNotEmpty)
                Text(
                  unit.customFeatures,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          if (unit.dynamicFields.isNotEmpty) _buildMiniFeatures(unit),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.primaryGradient : null,
              color: !isSelected ? AppTheme.primaryBlue.withOpacity(0.2) : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isSelected
                  ? context.tr('property.units.selected')
                  : context.tr('property.units.select'),
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? Colors.white : AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the mini features.
  /// العربية: يبني mini features.
  Widget _buildMiniFeatures(Unit unit) {
    final features = unit.dynamicFields
        .expand((group) => group.fieldValues)
        .take(3)
        .toList();

    return Wrap(
      spacing: 4,
      runSpacing: 3,
      children: features.map((field) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getFieldIcon(field.fieldName),
                size: 10,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 3),
              Text(
                '${field.value}',
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Builds the empty state.
  /// العربية: يبني empty state.
  Widget _buildEmptyState() {
    final context = this.context;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.2),
                    AppTheme.primaryBlue.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.meeting_room_outlined,
                size: 48,
                color: AppTheme.primaryBlue.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: Text(
                context.tr('property.units.noUnitsAvailable'),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('property.units.allUnitsBookedNow'),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the animated background.
  /// العربية: يبني animated background.
  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return CustomPaint(
            painter: _OrbsPainter(
              orbs: _orbs,
              animationValue: _shimmerController.value,
            ),
          );
        },
      ),
    );
  }

  /// Exposes the field icon.
  /// العربية: يعيد field icon.
  IconData _getFieldIcon(String fieldName) {
    final name = fieldName.toLowerCase();
    if (name.contains('bed') || name.contains('سرير')) return Icons.bed;
    if (name.contains('bath') || name.contains('حمام')) return Icons.bathroom;
    if (name.contains('area') || name.contains('مساحة'))
      return Icons.square_foot;
    if (name.contains('guest') || name.contains('ضيف')) return Icons.people;
    return Icons.info_outline;
  }

  /// Exposes the pricing period.
  /// العربية: يعيد pricing period.
  String _getPricingPeriod(BuildContext context, PricingMethod method) {
    switch (method) {
      case PricingMethod.hourly:
        return context.tr('property.units.hour');
      case PricingMethod.daily:
        return context.tr('property.units.night');
      case PricingMethod.weekly:
        return context.tr('property.units.week');
      case PricingMethod.monthly:
        return context.tr('property.units.month');
    }
  }
}

/// Describes the FloatingOrb type used in the property feature.
/// العربية: يمثل `FloatingOrb`.
class _FloatingOrb {
  /// Keeps the x value available to this object.
  /// العربية: يخزن القيمة `x`.
  late double x;

  /// Keeps the y value available to this object.
  /// العربية: يخزن القيمة `y`.
  late double y;

  /// Keeps the size value available to this object.
  /// العربية: يخزن القيمة `size`.
  late double size;

  /// Keeps the speed value available to this object.
  /// العربية: يخزن القيمة `speed`.
  late double speed;

  /// Keeps the color value available to this object.
  /// العربية: يخزن القيمة `color`.
  late Color color;

  /// Keeps the opacity value available to this object.
  /// العربية: يخزن القيمة `opacity`.
  late double opacity;

  /// Constructs the FloatingOrb value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `FloatingOrb`.
  _FloatingOrb() {
    reset();
  }

  /// Processes the reset flow and maps it into the property feature behavior.
  /// العربية: يعالج `reset`.
  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    size = math.Random().nextDouble() * 30 + 20;
    speed = math.Random().nextDouble() * 0.0005 + 0.0002;
    opacity = math.Random().nextDouble() * 0.05 + 0.02;

    final colors = [
      AppTheme.primaryBlue,
      AppTheme.primaryPurple,
      AppTheme.primaryCyan,
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }

  /// Updates the required operation for `update`.
  /// العربية: يحدّث العملية المطلوبة لـ `update`.
  void update() {
    y -= speed;
    if (y < -0.1) {
      y = 1.1;
      x = math.Random().nextDouble();
    }
  }
}

/// Describes the OrbsPainter type used in the property feature.
/// العربية: يمثل `OrbsPainter`.
class _OrbsPainter extends CustomPainter {
  /// Keeps the orbs value available to this object.
  /// العربية: يخزن القيمة `orbs`.
  final List<_FloatingOrb> orbs;

  /// Keeps the animationValue value available to this object.
  /// العربية: يخزن القيمة `animationValue`.
  final double animationValue;

  /// Constructs the OrbsPainter value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `OrbsPainter`.
  _OrbsPainter({
    required this.orbs,
    required this.animationValue,
  });

  /// Processes the paint flow and maps it into the property feature behavior.
  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    for (var orb in orbs) {
      orb.update();

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            orb.color.withOpacity(orb.opacity),
            orb.color.withOpacity(0),
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(orb.x * size.width, orb.y * size.height),
          radius: orb.size,
        ))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(orb.x * size.width, orb.y * size.height),
        orb.size,
        paint,
      );
    }
  }

  /// Processes the shouldRepaint flow and maps it into the property feature behavior.
  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
