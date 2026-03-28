// lib/core/widgets/loading_overlay.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// طبقة تحميل خفيفة تُستخدم عند انتظار البيانات أو تنفيذ عملية طويلة.
/// Lightweight loading overlay used while waiting for data or a long-running action.
class LoadingOverlay extends StatelessWidget {
  /// الرسالة الاختيارية التي تشرح سبب الانتظار للمستخدم.
  /// Optional message that explains why the user is waiting.
  final String? message;

  /// يحدد ما إذا كانت الطبقة ستغطي الشاشة كاملة أم ستظهر داخل المحتوى فقط.
  /// Controls whether the overlay covers the whole screen or stays inline.
  final bool isFullScreen;

  /// ينشئ طبقة تحميل قابلة لإعادة الاستخدام داخل النماذج والشاشات.
  /// Creates a reusable loading layer for forms and screens.
  const LoadingOverlay({
    super.key,
    this.message,
    this.isFullScreen = false,
  });

  /// يبني مؤشّر التحميل مع وضع ملء الشاشة عندما يحتاج السياق إلى حجب كامل.
  /// Builds the loading indicator and switches to full-screen mode when needed.
  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (isFullScreen) {
      return Scaffold(
        backgroundColor: AppColors.background.withValues(alpha: 0.9),
        body: content,
      );
    }

    return content;
  }
}
