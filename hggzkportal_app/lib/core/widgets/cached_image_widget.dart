import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../theme/app_dimensions.dart';
import '../utils/image_utils.dart';

/// يعرض صورة شبكة مع ذاكرة مؤقتة وبدائل مرئية للحالات الفارغة أو الفاشلة.
/// Network image wrapper with caching and visual fallbacks for loading and error states.
class CachedImageWidget extends StatelessWidget {
  /// رابط الصورة الأصلية قبل تسويته عبر ImageUtils.
  /// Raw image URL before normalization by `ImageUtils`.
  final String imageUrl;

  /// العرض الاختياري لحاوية الصورة.
  /// Optional image container width.
  final double? width;

  /// الارتفاع الاختياري لحاوية الصورة.
  /// Optional image container height.
  final double? height;

  /// طريقة ملاءمة الصورة داخل الإطار.
  /// How the image should fit inside its frame.
  final BoxFit fit;

  /// نصف قطر الزوايا عندما تحتاج الصورة إلى قص ناعم.
  /// Border radius applied when the image needs rounded corners.
  final BorderRadius? borderRadius;

  /// ويدجت بديل أثناء تحميل الصورة.
  /// Placeholder widget shown while the image is loading.
  final Widget? placeholder;

  /// ويدجت بديل عندما يفشل تحميل الصورة.
  /// Replacement widget shown when image loading fails.
  final Widget? errorWidget;

  /// يحدد ما إذا كان مؤشر التحميل سيظهر داخل الـ placeholder.
  /// Controls whether a loading spinner appears inside the placeholder.
  final bool showLoadingIndicator;

  /// لون الخلفية أسفل الصورة عندما لا تغطي الحاوية بالكامل.
  /// Background color behind the image when the container is visible.
  final Color? backgroundColor;

  /// ظلال خارجية اختيارية لرفع الصورة بصريًا عن الخلفية.
  /// Optional outer shadows for visual separation.
  final List<BoxShadow>? boxShadow;

  /// طبقة تدرج يمكن وضعها فوق الصورة.
  /// Gradient overlay layered above the image.
  final Gradient? gradient;

  /// نمط المزج عند تطبيق لون أو طبقة على الصورة.
  /// Blend mode used when applying a tint or overlay.
  final BlendMode? colorBlendMode;

  /// لون tint اختياري للصورة.
  /// Optional tint color applied to the image.
  final Color? color;

  /// ترويسات HTTP اختيارية تستخدم عند تحميل وسائط محمية.
  /// Optional HTTP headers used when loading protected media.
  final Map<String, String>? httpHeaders;

  /// Creates a cached image surface with graceful loading and failure fallbacks.
  /// ينشئ صورة مخزنة مع بدائل واضحة أثناء التحميل أو عند الفشل.
  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.showLoadingIndicator = true,
    this.backgroundColor,
    this.boxShadow,
    this.gradient,
    this.colorBlendMode,
    this.color,
    this.httpHeaders,
  });

  /// Builds the image container and layers optional overlays on top of the cached asset.
  /// يبني حاوية الصورة ويضيف فوقها الطبقات الاختيارية.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.darkCard,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Builder(
              builder: (context) {
                final resolvedUrl = ImageUtils.resolveUrl(imageUrl);
                if (resolvedUrl.isEmpty) {
                  return errorWidget ?? _buildErrorWidget();
                }

                return CachedNetworkImage(
                  imageUrl: resolvedUrl,
                  httpHeaders: httpHeaders,
                  fit: fit,
                  width: width,
                  height: height,
                  color: color,
                  colorBlendMode: colorBlendMode,
                  placeholder: (context, url) =>
                      placeholder ?? _buildPlaceholder(),
                  errorWidget: (context, url, error) =>
                      errorWidget ?? _buildErrorWidget(),
                );
              },
            ),
            if (gradient != null)
              Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the default loading placeholder used while the network image is resolving.
  /// يبني عنصر التحميل الافتراضي أثناء جلب الصورة من الشبكة.
  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.shimmer.withValues(alpha: 0.1),
      child: showLoadingIndicator
          ? Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryBlue.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: AppTheme.darkCard,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppTheme.textMuted.withValues(alpha: 0.5),
          size: AppDimensions.iconLarge,
        ),
      ),
    );
  }
}
