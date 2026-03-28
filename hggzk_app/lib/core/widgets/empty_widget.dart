import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Assuming you use SVG for icons
import '../theme/app_text_styles.dart';

/// يقدّم حالة فارغة جاهزة للاستخدام عندما لا توجد بيانات أو نتائج لعرضها.
/// Provides a reusable empty state when the screen has no data or results.
class EmptyWidget extends StatelessWidget {
  /// الرسالة التي تشرح للمستخدم لماذا الشاشة فارغة أو ماذا يمكنه أن يفعل بعد ذلك.
  /// Message shown to explain why the screen is empty or what the user can do next.
  final String message;

  /// أصل الصورة أو الرسم التوضيحي الذي يدعم الحالة الفارغة بصريًا.
  /// Asset path for the illustration that gives the empty state visual context.
  final String? emptyImage;

  /// إجراء اختياري يوجّه المستخدم إلى خطوة مفيدة مثل الإضافة أو إعادة المحاولة.
  /// Optional action that helps the user continue, such as add or retry.
  final Widget? actionWidget;

  /// ينشئ الحالة الفارغة مع إبقاء النص والأصول والقائمة الجانبية قابلة للتخصيص.
  /// Creates the empty state with customizable copy, artwork, and follow-up action.
  const EmptyWidget({
    super.key,
    required this.message,
    this.emptyImage,
    this.actionWidget,
  });

  /// يبني المحتوى المركزي الذي يظهر عندما لا توجد عناصر لعرضها.
  /// Builds the centered content shown when no items are available.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emptyImage != null &&
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
                      ?.withValues(alpha: 0.7)),
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
