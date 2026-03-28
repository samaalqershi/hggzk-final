// lib/core/widgets/empty_state_widget.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// حالة فراغ قابلة لإعادة الاستخدام للشاشات التي لا تملك بيانات بعد أو لا تحتوي نتائج.
/// Reusable empty state for screens that have no data yet or no results to show.
class EmptyStateWidget extends StatelessWidget {
  /// الأيقونة الاختيارية التي تمثل طبيعة الحالة الفارغة.
  /// Optional icon that represents the type of empty state.
  final IconData? icon;

  /// العنوان الرئيسي الذي يشرح الحالة للمستخدم.
  /// Main title that explains the state to the user.
  final String title;

  /// وصف إضافي يوضح لماذا لا توجد بيانات أو ما الذي يحدث الآن.
  /// Additional context describing why there is no data or what is happening.
  final String? subtitle;

  /// نص الإجراء الاختياري مثل "إضافة" أو "إعادة تحميل".
  /// Optional action label such as "Add" or "Reload".
  final String? actionLabel;

  /// استدعاء اختياري لتنفيذ الإجراء الموجود في الحالة الفارغة.
  /// Optional callback for the empty-state action.
  final VoidCallback? onAction;

  /// ينشئ حالة فراغ مرنة للصفحات والقوائم ولوحات المعلومات.
  /// Creates a flexible empty state for pages, lists, and dashboards.
  const EmptyStateWidget({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  /// يبني الحالة الفارغة ويختار بين الأيقونة أو النص أو الإجراء بحسب المدخلات.
  /// Builds the empty state and chooses between icon, text, and action based on inputs.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
