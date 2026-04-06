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

  /// Optional thumbnail URL used when the media item is a video.
  /// رابط مصغّر اختياري يُستخدم عندما تكون الوسيطة فيديو.
  final String? thumbnailUrl;

  /// Optional MIME type used to infer whether the media is a video.
  /// نوع MIME اختياري لمعرفة ما إذا كانت الوسيطة فيديو.
  final String? mimeType;

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
    this.thumbnailUrl,
    this.mimeType,
    this.onTap,
    this.onRemove,
    this.size = 100,
  });

  /// Renders the image preview with its optional remove affordance.
  /// يرسم معاينة الصورة مع زر الإزالة الاختياري.
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVideo = mimeType?.toLowerCase().startsWith('video/') ?? false;
    final previewUrl = isVideo && (thumbnailUrl?.isNotEmpty == true)
        ? thumbnailUrl!
        : imageUrl;
    final borderColor = isDark
        ? AppTheme.darkBorder.withValues(alpha: 0.9)
        : AppTheme.lightBorder.withValues(alpha: 0.95);
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.2 : 0.06);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
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
                imageUrl: previewUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
              if (isVideo)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.18),
                    child: Center(
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
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
