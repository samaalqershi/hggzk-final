import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/review.dart';

/// Displays the management reply attached to a property review.
/// يعرض رد الإدارة المرفق بمراجعة العقار.
class ResponseCardWidget extends StatelessWidget {
  /// Reply content that will be rendered as the card body.
  /// محتوى الرد الذي سيُعرض داخل البطاقة.
  final ReviewReply reply;

  /// Builds the reply card for a single management response.
  /// ينشئ بطاقة الرد لرسالة إدارة واحدة.
  const ResponseCardWidget({
    super.key,
    required this.reply,
  });

  /// Renders the response container, header, and formatted message body.
  /// يرسم حاوية الرد والعنوان ومحتوى الرسالة منسقًا.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryViolet.withOpacity(0.12),
            AppTheme.primaryBlue.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        border: Border.all(
          color: AppTheme.primaryViolet.withOpacity(0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppDimensions.spacingMd),
          _buildContent(),
        ],
      ),
    );
  }

  /// Builds the author header and response meta row.
  /// يبني ترويسة الكاتب وصف بيانات الرد.
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.business,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    reply.replierName,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmall,
                      vertical: AppDimensions.paddingXSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusXs,
                      ),
                    ),
                    child: Text(
                      'الإدارة',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                '${reply.replierPosition} • ${_formatDate(reply.createdAt)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Renders the response body using the shared review typography.
  /// يرسم نص الرد باستخدام أنماط الخط المشتركة للمراجعات.
  Widget _buildContent() {
    return Text(
      reply.content,
      style: AppTextStyles.bodyMedium.copyWith(
        height: 1.5,
      ),
    );
  }

  /// Formats the response timestamp for the current locale.
  /// ينسق طابع زمن الرد وفق اللغة الحالية.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      return 'منذ ${(difference.inDays / 7).floor()} أسابيع';
    } else {
      return DateFormat('d MMMM yyyy', 'ar').format(date);
    }
  }
}
