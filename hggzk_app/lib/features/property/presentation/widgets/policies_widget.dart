// lib/features/property/presentation/widgets/policies_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:hggzk/features/property/domain/entities/property_policy.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Renders the policy groups and supporting notes shown before booking.
/// يعرض مجموعات السياسات والملاحظات الداعمة التي تظهر قبل الحجز.
class PoliciesWidget extends StatefulWidget {
  /// Policies to render in grouped sections.
  /// السياسات المطلوب عرضها في أقسام مجمعة.
  final List<PropertyPolicy> policies;

  /// Builds the animated policy section.
  /// ينشئ قسم السياسات المتحرك.
  const PoliciesWidget({
    super.key,
    required this.policies,
  });

  /// Creates the state object that drives the grouped policy layout.
  /// ينشئ كائن الحالة الذي يقود تخطيط السياسات المجمعة.
  @override
  State<PoliciesWidget> createState() => _PoliciesWidgetState();
}

/// Controls the fade-in animation and expanded/collapsed policy groups.
/// يتحكم في حركة التلاشي ومجموعات السياسات الموسعة أو المطوية.
class _PoliciesWidgetState extends State<PoliciesWidget>
    with SingleTickerProviderStateMixin {
  /// Controls the initial fade-in animation.
  /// يتحكم في حركة التلاشي الأولية.
  late AnimationController _fadeController;

  /// Fades the section content into view.
  /// يدرج محتوى القسم بتلاشي تدريجي.
  late Animation<double> _fadeAnimation;

  /// Tracks which policy groups are currently expanded.
  /// يتتبع مجموعات السياسات الموسعة حاليًا.
  final Map<String, bool> _expandedPolicies = {};

  /// Prepares the state before the first frame.
  /// يجهز الحالة قبل الإطار الأول.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializePolicyStates();
  }

  /// Sets up the fade animation used by the policy section.
  /// يهيئ حركة التلاشي المستخدمة في قسم السياسات.
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
  }

  /// Expands every policy group initially so the user sees the full rules.
  /// يوسع كل مجموعة سياسات مبدئيًا حتى يرى المستخدم القواعد كاملة.
  void _initializePolicyStates() {
    final groupedPolicies = _groupPoliciesByType();
    for (final type in groupedPolicies.keys) {
      _expandedPolicies[type] = true;
    }
  }

  /// Groups policies by their backend type so the UI can render sections.
  /// يجمع السياسات بحسب النوع القادم من الخادم حتى تعرضها الواجهة كأقسام.
  Map<String, List<PropertyPolicy>> _groupPoliciesByType() {
    final groupedPolicies = <String, List<PropertyPolicy>>{};
    for (final policy in widget.policies) {
      final type = policy.policyType;
      if (!groupedPolicies.containsKey(type)) {
        groupedPolicies[type] = [];
      }
      groupedPolicies[type]!.add(policy);
    }
    return groupedPolicies;
  }

  /// Releases the fade animation controller.
  /// يحرر متحكم حركة التلاشي.
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Builds the grouped policy layout shown on the property page.
  /// يبني تخطيط السياسات المجمعة الظاهر في صفحة العقار.
  @override
  Widget build(BuildContext context) {
    if (widget.policies.isEmpty) {
      return const SizedBox.shrink();
    }

    final groupedPolicies = _groupPoliciesByType();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedPolicies.entries.map((entry) {
          return _buildUltraMinimalPolicySection(
            entry.key,
            entry.value,
          );
        }).toList(),
      ),
    );
  }

  /// Builds the ultra minimal policy section.
  /// العربية: يبني ultra minimal policy section.
  Widget _buildUltraMinimalPolicySection(
      String type, List<PropertyPolicy> policies) {
    final isExpanded = _expandedPolicies[type] ?? false;
    final typeColor = _getPolicyTypeColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            typeColor.withOpacity(0.03),
            typeColor.withOpacity(0.01),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: typeColor.withOpacity(0.08),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              _buildMinimalPolicyHeader(type, typeColor, policies.length),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: isExpanded ? null : 0,
                child: isExpanded
                    ? _buildMinimalPoliciesList(policies, typeColor)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the minimal policy header.
  /// العربية: يبني minimal policy header.
  Widget _buildMinimalPolicyHeader(String type, Color color, int count) {
    final isExpanded = _expandedPolicies[type] ?? false;

    return InkWell(
      onTap: () {
        setState(() {
          _expandedPolicies[type] = !isExpanded;
        });
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.05),
              color.withOpacity(0.02),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getPolicyTypeIcon(type),
                size: 16,
                color: color.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getPolicyTypeTitle(type),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textWhite.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$count سياسة',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.expand_more,
                color: AppTheme.textMuted.withOpacity(0.3),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the minimal policies list.
  /// العربية: يبني minimal policies list.
  Widget _buildMinimalPoliciesList(
      List<PropertyPolicy> policies, Color typeColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: policies.map((policy) {
          return _buildUltraMinimalPolicyItem(policy, typeColor);
        }).toList(),
      ),
    );
  }

  /// Builds the ultra minimal policy item.
  /// العربية: يبني ultra minimal policy item.
  Widget _buildUltraMinimalPolicyItem(PropertyPolicy policy, Color typeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: policy.isActive
              ? typeColor.withOpacity(0.08)
              : AppTheme.darkBorder.withOpacity(0.05),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: policy.isActive
                  ? typeColor.withOpacity(0.05)
                  : AppTheme.darkCard.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getPolicyIcon(policy.policyContent),
              size: 14,
              color: policy.isActive
                  ? typeColor.withOpacity(0.7)
                  : AppTheme.textMuted.withOpacity(0.3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        policy.policyContent,
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.textWhite.withOpacity(0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (policy.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'إلزامي',
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.error.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  policy.description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
                if (!policy.isActive) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 10,
                        color: AppTheme.warning.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'غير مفعل',
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.warning.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Exposes the policy type icon.
  /// العربية: يعيد policy type icon.
  IconData _getPolicyTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'checkin':
      case 'check-in':
        return Icons.login;
      case 'checkout':
      case 'check-out':
        return Icons.logout;
      case 'cancellation':
        return Icons.cancel_outlined;
      case 'payment':
        return Icons.payment_outlined;
      case 'house_rules':
      case 'rules':
        return Icons.rule;
      case 'safety':
        return Icons.security_outlined;
      case 'health':
        return Icons.health_and_safety_outlined;
      default:
        return Icons.policy_outlined;
    }
  }

  /// Exposes the policy icon.
  /// العربية: يعيد policy icon.
  IconData _getPolicyIcon(String content) {
    final lowerContent = content.toLowerCase();
    if (lowerContent.contains('وقت') || lowerContent.contains('time'))
      return Icons.access_time;
    if (lowerContent.contains('دفع') || lowerContent.contains('payment'))
      return Icons.payment;
    if (lowerContent.contains('إلغاء') || lowerContent.contains('cancel'))
      return Icons.cancel;
    if (lowerContent.contains('تدخين') || lowerContent.contains('smoking'))
      return Icons.smoke_free;
    if (lowerContent.contains('حيوان') || lowerContent.contains('pet'))
      return Icons.pets;
    if (lowerContent.contains('حفلة') || lowerContent.contains('party'))
      return Icons.celebration;
    return Icons.check_circle_outline;
  }

  /// Exposes the policy type color.
  /// العربية: يعيد policy type color.
  Color _getPolicyTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'checkin':
      case 'check-in':
      case 'checkout':
      case 'check-out':
        return AppTheme.info;
      case 'cancellation':
        return AppTheme.warning;
      case 'payment':
        return AppTheme.success;
      case 'house_rules':
      case 'rules':
        return AppTheme.primaryBlue;
      case 'safety':
      case 'health':
        return AppTheme.error;
      default:
        return AppTheme.primaryPurple;
    }
  }

  /// Exposes the policy type title.
  /// العربية: يعيد policy type title.
  String _getPolicyTypeTitle(String type) {
    switch (type.toLowerCase()) {
      case 'checkin':
      case 'check-in':
        return 'تسجيل الدخول';
      case 'checkout':
      case 'check-out':
        return 'تسجيل الخروج';
      case 'cancellation':
        return 'الإلغاء';
      case 'payment':
        return 'الدفع';
      case 'house_rules':
      case 'rules':
        return 'قوانين المكان';
      case 'safety':
        return 'السلامة';
      case 'health':
        return 'الصحة';
      default:
        return 'سياسات أخرى';
    }
  }
}
