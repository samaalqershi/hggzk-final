import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';

/// يمثل هذا الكلاس AssignSectionsModal البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for AssignSectionsModal in the admin unit workflow.
class AssignSectionsModal extends StatefulWidget {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String unitId;

  /// يحتفظ هذا الحقل بقيمة onClose التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the onClose value used by the admin unit workflow.
  final VoidCallback onClose;

  /// ينفذ هذا الأسلوب عملية Function ضمن مسار إدارة الوحدات.
  /// This method performs the Function operation in the admin unit workflow.
  final Function(List<String>) onAssign;

  /// ينشئ هذا المُنشئ مثيلاً من AssignSectionsModal.
  /// This constructor creates an instance of AssignSectionsModal.
  const AssignSectionsModal({
    super.key,
    required this.unitId,
    required this.onClose,
    required this.onAssign,
  });

  /// ينشئ هذا الأسلوب كائن الحالة الخاص بهذه الصفحة.
  /// This method performs the createState operation in the admin unit workflow.
  @override
  State<AssignSectionsModal> createState() => _AssignSectionsModalState();
}

/// يمثل هذا الكلاس _AssignSectionsModalState البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _AssignSectionsModalState in the admin unit workflow.
class _AssignSectionsModalState extends State<AssignSectionsModal>
    with SingleTickerProviderStateMixin {
  /// يحتفظ هذا الحقل بقيمة _animationController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _animationController value used by the admin unit workflow.
  late AnimationController _animationController;

  /// يحتفظ هذا الحقل بقيمة _scaleAnimation التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _scaleAnimation value used by the admin unit workflow.
  late Animation<double> _scaleAnimation;

  /// يحتفظ هذا الحقل بقيمة _fadeAnimation التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _fadeAnimation value used by the admin unit workflow.
  late Animation<double> _fadeAnimation;

  /// يحتفظ هذا الحقل بقيمة _selectedSections التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _selectedSections value used by the admin unit workflow.
  final List<String> _selectedSections = [];

  // Mock sections data
  /// يحتفظ هذا الحقل بقيمة _sections التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _sections value used by the admin unit workflow.
  final List<Map<String, dynamic>> _sections = [
    {'id': '1', 'name': 'عروض خاصة', 'icon': '🎯'},
    {'id': '2', 'name': 'الأكثر مشاهدة', 'icon': '👁️'},
    {'id': '3', 'name': 'جديد', 'icon': '✨'},
    {'id': '4', 'name': 'موصى به', 'icon': '⭐'},
    {'id': '5', 'name': 'عروض الصيف', 'icon': '☀️'},
    {'id': '6', 'name': 'عروض العائلات', 'icon': '👨‍👩‍👧‍👦'},
  ];

  /// ينفذ هذا الأسلوب عملية initState ضمن مسار إدارة الوحدات.
  /// This method performs the initState operation in the admin unit workflow.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
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

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 400),
              margin: const EdgeInsets.all(AppDimensions.paddingLarge),
              decoration: BoxDecoration(
                gradient: AppTheme.darkGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      _buildContent(),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildHeader ضمن مسار إدارة الوحدات.
  /// This method performs the _buildHeader operation in the admin unit workflow.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.1),
            AppTheme.primaryPurple.withValues(alpha: 0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: const Icon(
              Icons.category,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إضافة إلى الأقسام',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
                Text(
                  'حدد الأقسام لإضافة الوحدة إليها',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onClose();
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: AppTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildContent ضمن مسار إدارة الوحدات.
  /// This method performs the _buildContent operation in the admin unit workflow.
  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: Column(
          children: _sections.map((section) {
            final isSelected = _selectedSections.contains(section['id']);

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (isSelected) {
                    _selectedSections.remove(section['id']);
                  } else {
                    _selectedSections.add(section['id']);
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.spaceSmall),
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            AppTheme.primaryBlue.withValues(alpha: 0.2),
                            AppTheme.primaryPurple.withValues(alpha: 0.1),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            AppTheme.darkCard.withValues(alpha: 0.3),
                            AppTheme.darkCard.withValues(alpha: 0.1),
                          ],
                        ),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                        : AppTheme.darkBorder.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.primaryGradient : null,
                        color: isSelected ? null : AppTheme.darkCard,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : AppTheme.darkBorder.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: AppDimensions.spaceMedium),
                    Text(
                      section['icon']!,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: AppDimensions.spaceMedium),
                    Expanded(
                      child: Text(
                        section['name']!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected
                              ? AppTheme.textWhite
                              : AppTheme.textLight,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildFooter ضمن مسار إدارة الوحدات.
  /// This method performs the _buildFooter operation in the admin unit workflow.
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (_selectedSections.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Text(
                'تم تحديد ${_selectedSections.length} قسم',
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          const Spacer(),
          _buildButton(
            label: 'إلغاء',
            onTap: widget.onClose,
            isPrimary: false,
          ),
          const SizedBox(width: AppDimensions.spaceSmall),
          _buildButton(
            label: 'تطبيق',
            onTap: () {
              widget.onAssign(_selectedSections);
              widget.onClose();
            },
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildButton ضمن مسار إدارة الوحدات.
  /// This method performs the _buildButton operation in the admin unit workflow.
  Widget _buildButton({
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppTheme.primaryGradient : null,
          color: isPrimary ? null : AppTheme.darkCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: isPrimary
              ? null
              : Border.all(
                  color: AppTheme.darkBorder.withValues(alpha: 0.3),
                  width: 1,
                ),
        ),
        child: Text(
          label,
          style: AppTextStyles.buttonMedium.copyWith(
            color: isPrimary ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}
