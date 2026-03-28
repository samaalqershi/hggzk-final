import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/unit.dart';

/// يمثل هذا الكلاس FuturisticUnitMapView البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for FuturisticUnitMapView in the admin unit workflow.
class FuturisticUnitMapView extends StatefulWidget {
  /// This field keeps the units value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة units التي يعتمد عليها مسار إدارة الوحدات.
  final List<Unit> units;

  /// ينفذ هذا الأسلوب عملية Function ضمن مسار إدارة الوحدات.
  /// This method performs the Function operation in the admin unit workflow.
  final Function(Unit) onUnitSelected;

  /// ينشئ هذا المُنشئ مثيلاً من FuturisticUnitMapView.
  /// This constructor creates an instance of FuturisticUnitMapView.
  const FuturisticUnitMapView({
    super.key,
    required this.units,
    required this.onUnitSelected,
  });

  /// ينشئ هذا الأسلوب كائن الحالة الخاص بهذه الصفحة.
  /// This method performs the createState operation in the admin unit workflow.
  @override
  State<FuturisticUnitMapView> createState() => _FuturisticUnitMapViewState();
}

/// يمثل هذا الكلاس _FuturisticUnitMapViewState البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _FuturisticUnitMapViewState in the admin unit workflow.
class _FuturisticUnitMapViewState extends State<FuturisticUnitMapView>
    with TickerProviderStateMixin {
  /// يحتفظ هذا الحقل بقيمة _pulseController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _pulseController value used by the admin unit workflow.
  late AnimationController _pulseController;

  /// يحتفظ هذا الحقل بقيمة _rotationController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _rotationController value used by the admin unit workflow.
  late AnimationController _rotationController;

  /// يحتفظ هذا الحقل بقيمة _pulseAnimation التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _pulseAnimation value used by the admin unit workflow.
  late Animation<double> _pulseAnimation;

  /// يحتفظ هذا الحقل بقيمة _rotationAnimation التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _rotationAnimation value used by the admin unit workflow.
  late Animation<double> _rotationAnimation;

  /// يحتفظ هذا الحقل بقيمة _selectedUnit التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _selectedUnit value used by the admin unit workflow.
  Unit? _selectedUnit;

  /// يحتفظ هذا الحقل بقيمة _mapOffset التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _mapOffset value used by the admin unit workflow.
  Offset _mapOffset = Offset.zero;

  /// يحتفظ هذا الحقل بقيمة _mapScale التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _mapScale value used by the admin unit workflow.
  double _mapScale = 1.0;

  /// ينفذ هذا الأسلوب عملية initState ضمن مسار إدارة الوحدات.
  /// This method performs the initState operation in the admin unit workflow.
  @override
  void initState() {
    super.initState();

    /// ينفذ هذا الأسلوب عملية _initializeAnimations ضمن مسار إدارة الوحدات.
    /// This method performs the _initializeAnimations operation in the admin unit workflow.
    _initializeAnimations();
  }

  /// ينفذ هذا الأسلوب عملية _initializeAnimations ضمن مسار إدارة الوحدات.
  /// This method performs the _initializeAnimations operation in the admin unit workflow.
  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);
  }

  /// ينفذ هذا الأسلوب عملية dispose ضمن مسار إدارة الوحدات.
  /// This method performs the dispose operation in the admin unit workflow.
  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.3),
            AppTheme.darkCard.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        child: Stack(
          children: [
            _buildMapBackground(),
            _buildMapContent(),
            _buildMapControls(),
            if (_selectedUnit != null) _buildUnitDetails(_selectedUnit!),
          ],
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildMapBackground ضمن مسار إدارة الوحدات.
  /// This method performs the _buildMapBackground operation in the admin unit workflow.
  Widget _buildMapBackground() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.darkGradient,
          ),
          child: CustomPaint(
            painter: _MapBackgroundPainter(
              rotation: _rotationAnimation.value,
              scale: _mapScale,
              offset: _mapOffset,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildMapContent ضمن مسار إدارة الوحدات.
  /// This method performs the _buildMapContent operation in the admin unit workflow.
  Widget _buildMapContent() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _mapOffset += details.delta;
        });
      },
      onScaleUpdate: (details) {
        setState(() {
          _mapScale = (_mapScale * details.scale).clamp(0.5, 3.0);
        });
      },
      child: Container(
        color: Colors.transparent,
        child: Transform(
          transform: Matrix4.identity()
            ..translate(_mapOffset.dx, _mapOffset.dy)
            ..scale(_mapScale),
          child: Stack(
            children: widget.units.map((unit) {
              final position = _getUnitPosition(unit);
              return Positioned(
                left: position.dx,
                top: position.dy,
                child: _buildUnitMarker(unit),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildUnitMarker ضمن مسار إدارة الوحدات.
  /// This method performs the _buildUnitMarker operation in the admin unit workflow.
  Widget _buildUnitMarker(Unit unit) {
    final isSelected = _selectedUnit?.id == unit.id;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedUnit = unit);
        widget.onUnitSelected(unit);
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = isSelected ? _pulseAnimation.value : 1.0;

          return Transform.scale(
            scale: scale,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? AppTheme.primaryGradient
                    : LinearGradient(
                        colors: [
                          AppTheme
                              .primaryBlue, // Changed: isAvailable removed, use default color
                          AppTheme.primaryBlue.withValues(alpha: 0.8)
                        ],
                      ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                        : AppTheme.primaryBlue.withValues(
                            alpha: 0.3), // Changed: isAvailable removed
                    blurRadius: isSelected ? 20 : 10,
                    spreadRadius: isSelected ? 3 : 1,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.home,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildMapControls ضمن مسار إدارة الوحدات.
  /// This method performs the _buildMapControls operation in the admin unit workflow.
  Widget _buildMapControls() {
    return Positioned(
      top: AppDimensions.paddingLarge,
      right: AppDimensions.paddingLarge,
      child: Column(
        children: [
          _buildControlButton(
            Icons.add,
            () => setState(() => _mapScale = (_mapScale * 1.2).clamp(0.5, 3.0)),
          ),
          const SizedBox(height: AppDimensions.spaceSmall),
          _buildControlButton(
            Icons.remove,
            () => setState(() => _mapScale = (_mapScale / 1.2).clamp(0.5, 3.0)),
          ),
          const SizedBox(height: AppDimensions.spaceSmall),
          _buildControlButton(
            Icons.my_location,
            () => setState(() {
              _mapOffset = Offset.zero;
              _mapScale = 1.0;
            }),
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildControlButton ضمن مسار إدارة الوحدات.
  /// This method performs the _buildControlButton operation in the admin unit workflow.
  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withValues(alpha: 0.8),
              AppTheme.darkCard.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildUnitDetails ضمن مسار إدارة الوحدات.
  /// This method performs the _buildUnitDetails operation in the admin unit workflow.
  Widget _buildUnitDetails(Unit unit) {
    return Positioned(
      bottom: AppDimensions.paddingLarge,
      left: AppDimensions.paddingLarge,
      right: AppDimensions.paddingLarge,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.glassLight.withValues(alpha: 0.1),
                  AppTheme.glassDark.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      child: const Icon(
                        Icons.home,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unit.name,
                            style: AppTextStyles.heading3.copyWith(
                              color: AppTheme.textWhite,
                            ),
                          ),
                          Text(
                            unit.propertyName,
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Commented out: isAvailable removed
                    /*
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingSmall,
                        vertical: AppDimensions.paddingXSmall,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: unit.isAvailable
                              ? [AppTheme.success, AppTheme.success.withValues(alpha: 0.8)]
                              : [AppTheme.error, AppTheme.error.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: Text(
                        unit.isAvailable ? 'متاحة' : 'غير متاحة',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    */
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceMedium),
                Row(
                  children: [
                    // Commented out: basePrice removed
                    /*
                    _buildDetailItem(
                      Icons.attach_money,
                      unit.basePrice.displayAmount,
                      AppTheme.success,
                    ),
                    const SizedBox(width: AppDimensions.spaceMedium),
                    */
                    _buildDetailItem(
                      Icons.apartment,
                      unit.unitTypeName,
                      AppTheme.primaryBlue,
                    ),
                    if (unit.capacityDisplay.isNotEmpty) ...[
                      const SizedBox(width: AppDimensions.spaceMedium),
                      _buildDetailItem(
                        Icons.group,
                        unit.capacityDisplay,
                        AppTheme.primaryPurple,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildDetailItem ضمن مسار إدارة الوحدات.
  /// This method performs the _buildDetailItem operation in the admin unit workflow.
  Widget _buildDetailItem(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppDimensions.spaceXSmall),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  /// ينفذ هذا الأسلوب عملية _getUnitPosition ضمن مسار إدارة الوحدات.
  /// This method performs the _getUnitPosition operation in the admin unit workflow.
  Offset _getUnitPosition(Unit unit) {
    // Generate pseudo-random positions based on unit ID
    final random = math.Random(unit.id.hashCode);
    final x = 100 + random.nextDouble() * 200;
    final y = 100 + random.nextDouble() * 300;
    return Offset(x, y);
  }
}

/// يمثل هذا الكلاس _MapBackgroundPainter البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _MapBackgroundPainter in the admin unit workflow.
class _MapBackgroundPainter extends CustomPainter {
  /// This field keeps the rotation value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة rotation التي يعتمد عليها مسار إدارة الوحدات.
  final double rotation;

  /// يحتفظ هذا الحقل بقيمة scale التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the scale value used by the admin unit workflow.
  final double scale;

  /// يحتفظ هذا الحقل بقيمة offset التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the offset value used by the admin unit workflow.
  final Offset offset;

  /// ينشئ هذا المُنشئ مثيلاً من _MapBackgroundPainter.
  /// This constructor creates an instance of _MapBackgroundPainter.
  _MapBackgroundPainter({
    required this.rotation,
    required this.scale,
    required this.offset,
  });

  /// ينفذ هذا الأسلوب عملية paint ضمن مسار إدارة الوحدات.
  /// This method performs the paint operation in the admin unit workflow.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = AppTheme.primaryBlue.withValues(alpha: 0.05);

    // Draw grid
    const gridSize = 50.0;
    for (double x = -gridSize; x < size.width + gridSize; x += gridSize) {
      canvas.drawLine(
        Offset(x + offset.dx % gridSize, 0),
        Offset(x + offset.dx % gridSize, size.height),
        paint,
      );
    }
    for (double y = -gridSize; y < size.height + gridSize; y += gridSize) {
      canvas.drawLine(
        Offset(0, y + offset.dy % gridSize),
        Offset(size.width, y + offset.dy % gridSize),
        paint,
      );
    }
  }

  /// ينفذ هذا الأسلوب عملية shouldRepaint ضمن مسار إدارة الوحدات.
  /// This method performs the shouldRepaint operation in the admin unit workflow.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
