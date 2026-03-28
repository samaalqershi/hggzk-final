// lib/features/admin_units/presentation/widgets/capacity_selector_widget.dart

import 'package:hggzkportal/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:hggzkportal/core/theme/app_text_styles.dart';
import '../../domain/entities/unit_type.dart';

/// يمثل هذا الكلاس CapacitySelectorWidget البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for CapacitySelectorWidget in the admin unit workflow.
class CapacitySelectorWidget extends StatefulWidget {
  /// This field keeps the unitType value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitType التي يعتمد عليها مسار إدارة الوحدات.
  final UnitType unitType;

  /// ينفذ هذا الأسلوب عملية Function ضمن مسار إدارة الوحدات.
  /// This method performs the Function operation in the admin unit workflow.
  final Function(int?, int?) onCapacityChanged;

  /// يحتفظ هذا الحقل بقيمة initialAdults التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the initialAdults value used by the admin unit workflow.
  final int? initialAdults;

  /// يحتفظ هذا الحقل بقيمة initialChildren التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the initialChildren value used by the admin unit workflow.
  final int? initialChildren;

  /// ينشئ هذا المُنشئ مثيلاً من CapacitySelectorWidget.
  /// This constructor creates an instance of CapacitySelectorWidget.
  const CapacitySelectorWidget({
    super.key,
    required this.unitType,
    required this.onCapacityChanged,
    this.initialAdults,
    this.initialChildren,
  });

  /// ينشئ هذا الأسلوب كائن الحالة الخاص بهذه الصفحة.
  /// This method performs the createState operation in the admin unit workflow.
  @override
  State<CapacitySelectorWidget> createState() => _CapacitySelectorWidgetState();
}

/// يمثل هذا الكلاس _CapacitySelectorWidgetState البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _CapacitySelectorWidgetState in the admin unit workflow.
class _CapacitySelectorWidgetState extends State<CapacitySelectorWidget>
    with SingleTickerProviderStateMixin {
  /// يحتفظ هذا الحقل بقيمة _adults التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _adults value used by the admin unit workflow.
  int? _adults;

  /// يحتفظ هذا الحقل بقيمة _children التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _children value used by the admin unit workflow.
  int? _children;

  /// يحتفظ هذا الحقل بقيمة _animationController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _animationController value used by the admin unit workflow.
  late AnimationController _animationController;

  /// يحتفظ هذا الحقل بقيمة _scaleAnimation التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _scaleAnimation value used by the admin unit workflow.
  late Animation<double> _scaleAnimation;

  /// ينفذ هذا الأسلوب عملية initState ضمن مسار إدارة الوحدات.
  /// This method performs the initState operation in the admin unit workflow.
  @override
  void initState() {
    super.initState();

    /// ينفذ هذا الأسلوب عملية _syncInitialValues ضمن مسار إدارة الوحدات.
    /// This method performs the _syncInitialValues operation in the admin unit workflow.
    _syncInitialValues();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  /// ينفذ هذا الأسلوب عملية didUpdateWidget ضمن مسار إدارة الوحدات.
  /// This method performs the didUpdateWidget operation in the admin unit workflow.
  @override
  void didUpdateWidget(covariant CapacitySelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialAdults != widget.initialAdults ||
        oldWidget.initialChildren != widget.initialChildren ||
        oldWidget.unitType != widget.unitType) {
      _syncInitialValues();
    }
  }

  /// ينفذ هذا الأسلوب عملية dispose ضمن مسار إدارة الوحدات.
  /// This method performs the dispose operation in the admin unit workflow.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// ينفذ هذا الأسلوب عملية _syncInitialValues ضمن مسار إدارة الوحدات.
  /// This method performs the _syncInitialValues operation in the admin unit workflow.
  void _syncInitialValues() {
    _adults = widget.initialAdults ?? (widget.unitType.isHasAdults ? 1 : 0);
    _children = widget.initialChildren ?? 0;
  }

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    if (!widget.unitType.isHasAdults && !widget.unitType.isHasChildren) {
      return const SizedBox.shrink();
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.1),
              AppTheme.primaryPurple.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.group_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'السعة الاستيعابية',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      if (widget.unitType.isHasAdults)
                        Expanded(
                          child: _buildCapacityField(
                            label: 'البالغين',
                            icon: Icons.person_rounded,
                            value: _adults ?? 0,
                            onChanged: (value) {
                              setState(() => _adults = value);
                              widget.onCapacityChanged(_adults, _children);
                            },
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      if (widget.unitType.isHasAdults &&
                          widget.unitType.isHasChildren)
                        const SizedBox(width: 16),
                      if (widget.unitType.isHasChildren)
                        Expanded(
                          child: _buildCapacityField(
                            label: 'الأطفال',
                            icon: Icons.child_care_rounded,
                            value: _children ?? 0,
                            onChanged: (value) {
                              setState(() => _children = value);
                              widget.onCapacityChanged(_adults, _children);
                            },
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildCapacityField ضمن مسار إدارة الوحدات.
  /// This method performs the _buildCapacityField operation in the admin unit workflow.
  Widget _buildCapacityField({
    required String label,
    required IconData icon,
    required int value,
    required Function(int) onChanged,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCounterButton(
                icon: Icons.remove,
                onTap: () {
                  if (value > 0) {
                    onChanged(value - 1);
                  }
                },
                isEnabled: value > 0,
              ),
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      value.toString(),
                      key: ValueKey(value),
                      style: AppTextStyles.heading2.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              _buildCounterButton(
                icon: Icons.add,
                onTap: () {
                  onChanged(value + 1);
                },
                isEnabled: true,
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildCounterButton ضمن مسار إدارة الوحدات.
  /// This method performs the _buildCounterButton operation in the admin unit workflow.
  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isEnabled,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: isPrimary && isEnabled ? AppTheme.primaryGradient : null,
          color: !isPrimary
              ? (isEnabled
                  ? AppTheme.darkCard.withValues(alpha: 0.5)
                  : AppTheme.darkCard.withValues(alpha: 0.2))
              : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isEnabled
                ? (isPrimary
                    ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                    : AppTheme.darkBorder.withValues(alpha: 0.3))
                : AppTheme.darkBorder.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isEnabled
              ? (isPrimary ? Colors.white : AppTheme.textMuted)
              : AppTheme.textMuted.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
