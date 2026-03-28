import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// واجهة خطأ قابلة لإعادة الاستخدام تعرض أيقونة ورسالة وزر إعادة المحاولة حسب الحاجة.
/// Reusable error surface that renders an icon, title, message, and optional retry action.
class CustomErrorWidget extends StatelessWidget {
  /// الرسالة التوضيحية الاختيارية التي تشرح سبب الفشل للمستخدم.
  /// Optional explanatory message shown to the user.
  final String? message;

  /// عنوان مخصص يعلو الرسالة عندما يحتاج السياق إلى تسمية أدق.
  /// Custom title shown above the message when the context needs a clearer label.
  final String? title;

  /// callback استدعاء عند الضغط على زر إعادة المحاولة.
  /// Callback triggered when the retry button is pressed.
  final VoidCallback? onRetry;

  /// أيقونة اختيارية تسمح للمستدعي بتخصيص الشكل البصري الكامل.
  /// Optional override icon supplied by the caller.
  final Widget? icon;

  /// يحدد نوع الخطأ الافتراضي عندما لا يمرر المستدعي عنوانًا أو أيقونة خاصة.
  /// Default error category used when the caller does not provide custom branding.
  final ErrorType type;

  /// Creates a reusable error state that can be dropped into list, page, or dialog layouts.
  /// ينشئ حالة خطأ قابلة لإعادة الاستخدام داخل الصفحات أو القوائم أو الحوارات.
  const CustomErrorWidget({
    super.key,
    this.message,
    this.title,
    this.onRetry,
    this.icon,
    this.type = ErrorType.general,
  });

  /// Builds the error panel and conditionally adds the retry action when provided.
  /// يبني لوحة الخطأ ويضيف زر الإعادة فقط عندما يكون متاحًا.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(context),
            const SizedBox(height: AppDimensions.spaceLarge),
            _buildTitle(context),
            if (message != null) ...[
              const SizedBox(height: AppDimensions.spaceSmall),
              _buildMessage(context),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spaceXLarge),
              _buildRetryButton(context),
            ],
          ],
        ),
      ),
    );
  }

  /// Picks a default icon/color pair for the selected error type when the caller does not override it.
  /// يختار الأيقونة واللون الافتراضيين لنوع الخطأ عندما لا يوفّر المستدعي بديلًا.
  Widget _buildIcon(BuildContext context) {
    if (icon != null) return icon!;

    IconData iconData;
    Color iconColor;

    switch (type) {
      case ErrorType.network:
        iconData = Icons.wifi_off_rounded;
        iconColor = AppTheme.error;
        break;
      case ErrorType.server:
        iconData = Icons.cloud_off_rounded;
        iconColor = AppTheme.error;
        break;
      case ErrorType.notFound:
        iconData = Icons.search_off_rounded;
        iconColor = AppTheme.textMuted;
        break;
      case ErrorType.permission:
        iconData = Icons.lock_outline_rounded;
        iconColor = AppTheme.warning;
        break;
      case ErrorType.general:
        iconData = Icons.error_outline_rounded;
        iconColor = AppTheme.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: AppDimensions.iconXLarge,
        color: iconColor,
      ),
    );
  }

  /// Resolves a visible title either from the caller or from the error type.
  /// يحدد العنوان الظاهر من المستدعي أو من نوع الخطأ نفسه.
  Widget _buildTitle(BuildContext context) {
    String displayTitle = title ?? _getDefaultTitle();

    return Text(
      displayTitle,
      style: AppTextStyles.heading3.copyWith(
        color: AppTheme.textWhite,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Renders the supporting message with truncation so layout stays compact.
  /// يعرض الرسالة الداعمة مع قص مناسب حتى تبقى المساحة مضبوطة.
  Widget _buildMessage(BuildContext context) {
    return Text(
      message!,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppTheme.textMuted,
      ),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Renders the retry action using the portal's error accent styling.
  /// يعرض إجراء إعادة المحاولة بأسلوب لوني يلفت الانتباه.
  Widget _buildRetryButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.error.withValues(alpha: 0.7),
            AppTheme.error.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onRetry,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded,
                    color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  'إعادة المحاولة',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Returns default title for the active error category.
  /// يعيد العنوان الافتراضي لفئة الخطأ الحالية.
  String _getDefaultTitle() {
    switch (type) {
      case ErrorType.network:
        return 'لا يوجد اتصال بالإنترنت';
      case ErrorType.server:
        return 'خطأ في الخادم';
      case ErrorType.notFound:
        return 'لم يتم العثور على النتائج';
      case ErrorType.permission:
        return 'ليس لديك صلاحية';
      case ErrorType.general:
        return 'حدث خطأ ما';
    }
  }
}
enum ErrorType {
  general,
  network,
  server,
  notFound,
  permission,
}
