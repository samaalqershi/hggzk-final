import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/cached_image_widget.dart';

/// Shows an uploaded review image with optional tap and remove actions.
/// يعرض صورة مرفوعة للمراجعة مع أفعال اختيارية للفتح والحذف.
class UploadReviewImageWidget extends StatelessWidget {
  /// Image URL rendered inside the preview tile.
  /// رابط الصورة المعروض داخل بطاقة المعاينة.
  final String imageUrl;

  /// Opens the image preview or picker when the tile is tapped.
  /// يفتح معاينة الصورة أو منتقي الصور عند الضغط على البطاقة.
  final VoidCallback? onTap;

  /// Removes the image from the pending review attachment list.
  /// يزيل الصورة من قائمة مرفقات المراجعة المعلّقة.
  final VoidCallback? onRemove;

  /// Controls the preview tile's square size.
  /// يتحكم في حجم البطاقة المربعة للمعاينة.
  final double size;

  /// Builds the preview tile for one review image.
  /// ينشئ بطاقة المعاينة لصورة مراجعة واحدة.
  const UploadReviewImageWidget({
    super.key,
    required this.imageUrl,
    this.onTap,
    this.onRemove,
    this.size = 100,
  });

  /// Renders the image preview with its optional remove affordance.
  /// يرسم معاينة الصورة مع زر الإزالة الاختياري.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
          child: Stack(
            children: [
              CachedImageWidget(
                imageUrl: imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
              if (onRemove != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: AppTheme.textWhite,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
