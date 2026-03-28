import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Assuming you use SVG for icons
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// حالة فراغ عامة تعرض نصًا، وأيقونة أو صورة، وإجراءً اختياريًا للمستخدم.
/// Generic empty state that can show text, an icon or image, and an optional action.
class EmptyWidget extends StatelessWidget {
  /// الرسالة الأساسية التي تشرح لماذا الشاشة فارغة الآن.
  /// The main message explaining why the screen is empty.
  final String message;

  /// مسار صورة أو SVG يستخدم عندما نريد حالة فراغ مرئية بدل النص فقط.
  /// Path to an illustration used when the empty state needs a visual cue.
  final String?
      emptyImage; // Path to an empty state illustration (e.g., SVG or PNG)
  /// أيقونة بديلة للحالات التي لا تحتاج صورة كاملة.
  /// Alternative icon for compact empty states.
  final IconData? icon;
  /// ويدجت إجراء اختياري مثل زر الإضافة أو زر إعادة التحميل.
  /// Optional action widget such as an add button or reload button.
  final Widget?
      actionWidget; // Optional widget for action (e.g., button to add item)

  /// Creates a reusable empty-state surface for lists, dashboards, and detail pages.
  /// ينشئ حالة فراغ قابلة لإعادة الاستخدام في القوائم واللوحات وصفحات التفاصيل.
  const EmptyWidget({
    super.key,
    required this.message,
    this.emptyImage,
    this.icon, // 🎯 parameter جديد
    this.actionWidget,
  });

  /// Builds the empty state and prefers the most specific visual provided by the caller.
  /// يبني حالة الفراغ ويختار أكثر تمثيل بصري محدد يمرره المستدعي.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🎯 عرض الأيقونة إذا تم تمريرها
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.darkBorder.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: AppTheme.textMuted,
                ),
              )
            // عرض الصورة إذا كانت موجودة
            else if (emptyImage != null &&
                emptyImage!.toLowerCase().endsWith('.svg'))
              SvgPicture.asset(
                emptyImage!,
                height: 100, // Adjust size as needed
              )
            else if (emptyImage != null)
              Image.asset(
                emptyImage!,
                height: 100, // Adjust size as needed
              ),
            const SizedBox(height: 20.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.7),
              ),
            ),
            if (actionWidget != null) ...[
              const SizedBox(height: 24.0),
              actionWidget!,
            ],
          ],
        ),
      ),
    );
  }
}
