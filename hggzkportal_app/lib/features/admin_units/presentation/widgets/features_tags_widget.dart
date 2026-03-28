// lib/features/admin_units/presentation/widgets/features_tags_widget.dart

import 'package:hggzkportal/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:hggzkportal/core/theme/app_text_styles.dart';

/// يمثل هذا الكلاس FeaturesTagsWidget البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for FeaturesTagsWidget in the admin unit workflow.
class FeaturesTagsWidget extends StatefulWidget {
  /// Callback fired when the feature tags string changes in the editor.
  /// استدعاء يُستخدم عند تعديل قائمة المزايا حتى تبقى البيانات المعروضة والإرسالية متزامنة.
  final Function(String) onFeaturesChanged;

  /// يحتفظ هذا الحقل بقيمة initialFeatures التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the initialFeatures value used by the admin unit workflow.
  final List<String>? initialFeatures;

  /// ينشئ هذا المُنشئ مثيلاً من FeaturesTagsWidget.
  /// This constructor creates an instance of FeaturesTagsWidget.
  const FeaturesTagsWidget({
    super.key,
    required this.onFeaturesChanged,
    this.initialFeatures,
  });

  /// ينشئ هذا الأسلوب كائن الحالة الخاص بهذه الصفحة.
  /// This method performs the createState operation in the admin unit workflow.
  @override
  State<FeaturesTagsWidget> createState() => _FeaturesTagsWidgetState();
}

/// يمثل هذا الكلاس _FeaturesTagsWidgetState البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _FeaturesTagsWidgetState in the admin unit workflow.
class _FeaturesTagsWidgetState extends State<FeaturesTagsWidget>
    with TickerProviderStateMixin {
  final _textController = TextEditingController();

  /// يحتفظ هذا الحقل بقيمة _features التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _features value used by the admin unit workflow.
  final List<String> _features = [];

  /// يحتفظ هذا الحقل بقيمة _animationController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _animationController value used by the admin unit workflow.
  late AnimationController _animationController;

  /// يحتفظ هذا الحقل بقيمة _fadeAnimation التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _fadeAnimation value used by the admin unit workflow.
  late Animation<double> _fadeAnimation;

  /// يحتفظ هذا الحقل بقيمة _suggestions التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _suggestions value used by the admin unit workflow.
  final List<String> _suggestions = [
    'واي فاي مجاني',
    'مكيف هواء',
    'تلفزيون ذكي',
    'مطبخ مجهز',
    'شرفة خاصة',
    'موقف سيارة',
    'مسبح',
    'جيم',
    'خدمة تنظيف',
    'أمن وحراسة',
    'خدمة استقبال',
    'صالة ألعاب',
    'منطقة شواء',
    'حديقة خاصة',
    'جاكوزي',
  ];

  /// ينفذ هذا الأسلوب عملية initState ضمن مسار إدارة الوحدات.
  /// This method performs the initState operation in the admin unit workflow.
  @override
  void initState() {
    super.initState();
    if (widget.initialFeatures != null) {
      _features.addAll(widget.initialFeatures!);
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  /// ينفذ هذا الأسلوب عملية dispose ضمن مسار إدارة الوحدات.
  /// This method performs the dispose operation in the admin unit workflow.
  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// ينفذ هذا الأسلوب عملية _addFeature ضمن مسار إدارة الوحدات.
  /// This method performs the _addFeature operation in the admin unit workflow.
  void _addFeature(String feature) {
    if (feature.isNotEmpty && !_features.contains(feature)) {
      setState(() {
        _features.add(feature);
        _textController.clear();
      });
      _updateFeatures();
      HapticFeedback.lightImpact();
    }
  }

  /// ينفذ هذا الأسلوب عملية _removeFeature ضمن مسار إدارة الوحدات.
  /// This method performs the _removeFeature operation in the admin unit workflow.
  void _removeFeature(String feature) {
    setState(() {
      _features.remove(feature);
    });
    _updateFeatures();
    HapticFeedback.lightImpact();
  }

  /// ينفذ هذا الأسلوب عملية _updateFeatures ضمن مسار إدارة الوحدات.
  /// This method performs the _updateFeatures operation in the admin unit workflow.
  void _updateFeatures() {
    widget.onFeaturesChanged(_features.join(','));
  }

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryPurple.withValues(alpha: 0.1),
              AppTheme.primaryBlue.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryPurple.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
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
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryPurple,
                              AppTheme.primaryBlue,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'المميزات',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildInputField(),

                  const SizedBox(height: 20),

                  _buildFeaturesList(),

                  if (_getSuggestionsToShow().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSuggestions(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildInputField ضمن مسار إدارة الوحدات.
  /// This method performs the _buildInputField operation in the admin unit workflow.
  Widget _buildInputField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
              ),
              decoration: InputDecoration(
                hintText: 'أضف ميزة جديدة...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textMuted.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                prefixIcon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppTheme.primaryPurple.withValues(alpha: 0.7),
                  size: 20,
                ),
              ),
              onSubmitted: _addFeature,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _addFeature(_textController.text);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildFeaturesList ضمن مسار إدارة الوحدات.
  /// This method performs the _buildFeaturesList operation in the admin unit workflow.
  Widget _buildFeaturesList() {
    if (_features.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.darkBorder.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 32,
                color: AppTheme.textMuted.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 8),
              Text(
                'لم تتم إضافة أي مميزات بعد',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textMuted.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _features.map((feature) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.2),
                      AppTheme.primaryPurple.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '✨',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      feature,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _removeFeature(feature),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 12,
                          color: AppTheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  /// ينفذ هذا الأسلوب عملية _getSuggestionsToShow ضمن مسار إدارة الوحدات.
  /// This method performs the _getSuggestionsToShow operation in the admin unit workflow.
  List<String> _getSuggestionsToShow() {
    return _suggestions.where((s) => !_features.contains(s)).take(5).toList();
  }

  /// ينفذ هذا الأسلوب عملية _buildSuggestions ضمن مسار إدارة الوحدات.
  /// This method performs the _buildSuggestions operation in the admin unit workflow.
  Widget _buildSuggestions() {
    final suggestions = _getSuggestionsToShow();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: AppTheme.primaryPurple.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              'اقتراحات سريعة',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((suggestion) {
            return GestureDetector(
              onTap: () => _addFeature(suggestion),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.darkBorder.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 14,
                      color: AppTheme.primaryPurple.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      suggestion,
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
