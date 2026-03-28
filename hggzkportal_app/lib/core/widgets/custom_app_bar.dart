// lib/core/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// شريط علوي موحّد يستخدمه البورتال للحفاظ على نفس طبقة العنوان والأفعال والتنقل.
/// Shared portal app bar that keeps titles, leading actions, and trailing actions visually consistent.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// النص الرئيسي الظاهر في منتصف الشريط أو في بدايته بحسب الإعدادات.
  /// The main title shown in the bar, centered or aligned depending on configuration.
  final String title;

  /// الأزرار أو الاختصارات التي تظهر في طرف الشريط.
  /// Action widgets rendered on the trailing side of the app bar.
  final List<Widget>? actions;

  /// ويدجت البداية مثل زر الرجوع أو زر القائمة.
  /// Leading widget such as a back button or menu trigger.
  final Widget? leading;

  /// يحدد ما إذا كان العنوان سيتمركز داخل الشريط أم لا.
  /// Controls whether the title is centered within the bar.
  final bool centerTitle;

  /// ارتفاع الظل المستخدم خلف الشريط.
  /// Elevation applied behind the app bar surface.
  final double? elevation;

  /// لون الخلفية عندما لا يكفي التدرج أو عندما يحتاج المستدعي إلى تخصيص مباشر.
  /// Optional solid background color when a caller needs to override the gradient treatment.
  final Color? backgroundColor;

  /// مساحة إضافية أسفل الشريط مثل `TabBar`.
  /// Optional bottom widget such as a `TabBar`.
  final PreferredSizeWidget? bottom;

  /// Creates a reusable portal app bar with consistent title and gradient styling.
  /// ينشئ شريطًا علويًا موحدًا يحافظ على نمط العنوان والتدرج البصري في البورتال.
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.bottom,
  });

  /// Builds the branded app bar surface while preserving the caller's actions and layout.
  /// يبني سطح الشريط الموحّد مع الحفاظ على أفعال المستدعي وترتيب العناصر.
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation ?? 0,
      leading: leading,
      actions: actions,
      bottom: bottom,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.95),
              AppColors.primary.withValues(alpha: 0.85),
            ],
          ),
        ),
      ),
    );
  }

  /// Calculates the toolbar height plus the optional bottom widget height.
  /// يعيد ارتفاع الشريط الأساسي مع ارتفاع العنصر السفلي الاختياري.
  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}
