import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// يعرض رسالة خطأ متناسقة مع أيقونة وحل اختياري لإعادة المحاولة.
/// Displays a consistent error state with an icon and an optional retry action.
class CustomErrorWidget extends StatelessWidget {
  /// التفصيل الإضافي الذي يوضح سبب الخطأ أو ما الذي تعطل تحديدًا.
  /// Additional detail describing what failed or why the screen could not load.
  final String? message;

  /// عنوان مختصر يحدد نوع المشكلة قبل عرض التفاصيل.
  /// Short headline that frames the error before any supporting message.
  final String? title;

  /// إجراء يعيد تشغيل المسار الذي فشل بدل ترك المستخدم في حالة انسداد.
  /// Callback that retries the failed flow instead of leaving the user stuck.
  final VoidCallback? onRetry;

  /// أيقونة مخصصة عندما يحتاج السياق إلى رمز مختلف عن الرموز الافتراضية.
  /// Custom icon for flows that need a more specific visual cue.
  final Widget? icon;

  /// يصنف الخطأ حتى نختار التمثيل البصري والعبارة الأنسب تلقائيًا.
  /// Error category used to pick the best default icon and title.
  final ErrorType type;

  /// ينشئ حالة الخطأ مع دعم الرسالة الاختيارية وزر إعادة المحاولة.
  /// Creates the error state with optional detail text and a retry affordance.
  const CustomErrorWidget({
    super.key,
    this.message,
    this.title,
    this.onRetry,
    this.icon,
    this.type = ErrorType.general,
  });

  /// يبني بطاقة الخطأ حتى تبقى كل حالات الفشل ضمن لغة بصرية واحدة.
  /// Builds the error card so every failure state follows one visual language.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(context),
            const SizedBox(height: AppDimensions.spacingLg),
            _buildTitle(context),
            if (message != null) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              _buildMessage(context),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacingXl),
              _buildRetryButton(context),
            ],
          ],
        ),
      ),
    );
  }

  /// يختار الأيقونة المناسبة حسب نوع الخطأ أو يستخدم الأيقونة المخصصة.
  /// Chooses the default icon for the error type or uses the custom override.
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
      default:
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

  /// يعرض العنوان الفعلي ويعود إلى عنوان افتراضي إذا لم يمرر المستدعي شيئًا.
  /// Renders the actual title or falls back to a contextual default.
  Widget _buildTitle(BuildContext context) {
    String displayTitle = title ?? _getDefaultTitle();

    return Text(
      displayTitle,
      style: AppTextStyles.h3.copyWith(
        color: AppTheme.textWhite,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// يعرض الشرح الإضافي مع حدود تمنع النص الطويل من كسر التخطيط.
  /// Renders the supporting text while keeping long messages from breaking layout.
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

  /// يظهر زر إعادة المحاولة عندما يكون من المفيد منح المستخدم مسارًا مباشرًا.
  /// Shows a retry button when the user should be given a direct recovery path.
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

  /// يعيد عنوانًا افتراضيًا متوافقًا مع نوع الخطأ الحالي.
  /// Returns the contextual title for the selected error type.
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
      default:
        return 'حدث خطأ ما';
    }
  }
}

/// Groups the allowed values for `ErrorType` so the rest of the app stays type-safe.
/// العربية: يعرّف القيم المتاحة للنوع `ErrorType`.
enum ErrorType {
  general,
  network,
  server,
  notFound,
  permission,
}
