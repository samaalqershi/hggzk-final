import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../theme/app_dimensions.dart';
import '../utils/image_utils.dart';

/// يعرض صورة شبكية مع كاش وبديل جاهز للحالات التي تفشل فيها التحميلات.
/// Displays a cached network image with graceful placeholders and error fallbacks.
class CachedImageWidget extends StatelessWidget {
  /// رابط الصورة الأصلية قبل أن يمر عبر محلل الروابط الداخلي.
  /// Source image URL before it is normalized by the URL resolver.
  final String imageUrl;

  /// العرض النهائي الذي يجب أن تحتله الصورة داخل التخطيط.
  /// Final width the image should occupy in the layout.
  final double? width;

  /// الارتفاع النهائي عندما لا يعتمد العنصر على المحتوى التلقائي.
  /// Final height used when the widget is not allowed to size itself.
  final double? height;

  /// طريقة ملاءمة الصورة داخل الصندوق المحيط بها.
  /// How the image should fit within its bounds.
  final BoxFit fit;

  /// تدوير الزوايا للحفاظ على انسجام الصورة مع بطاقة العرض.
  /// Corner radius used to match the surrounding card or surface.
  final BorderRadius? borderRadius;

  /// بديل اختياري يظهر أثناء جلب الصورة.
  /// Optional widget shown while the image is loading.
  final Widget? placeholder;

  /// بديل اختياري يظهر عندما لا يمكن تحميل الصورة.
  /// Optional widget shown when the image fails to load.
  final Widget? errorWidget;

  /// يحدد ما إذا كان placeholder يعرض مؤشر تحميل واضح.
  /// Controls whether the placeholder shows an explicit loading indicator.
  final bool showLoadingIndicator;

  /// لون الخلفية تحت الصورة قبل وصول المحتوى الشبكي.
  /// Background color beneath the image before the network asset is ready.
  final Color? backgroundColor;

  /// ظلال اختيارية لرفع الصورة بصريًا عن الخلفية.
  /// Optional shadows used to lift the image off the background.
  final List<BoxShadow>? boxShadow;

  /// تدرج فوق الصورة عندما يحتاج التصميم إلى طبقة لون إضافية.
  /// Gradient overlay applied when the design needs an extra color layer.
  final Gradient? gradient;

  /// نمط المزج المستخدم عند تلوين الصورة برمجيًا.
  /// Blend mode applied when tinting the image programmatically.
  final BlendMode? colorBlendMode;

  /// اللون المطبق فوق الصورة عندما تكون هناك حاجة إلى tint موحد.
  /// Tint color applied when the image needs a consistent overlay.
  final Color? color;

  /// Optional request headers used by protected media endpoints.
  /// ترويسات طلب اختيارية تستخدم مع مسارات الوسائط المحمية.
  final Map<String, String>? httpHeaders;

  /// ينشئ الصورة المخزنة مع placeholder وerror state قابلين للتخصيص.
  /// Creates the cached image with customizable loading and error fallbacks.
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

  /// يبني الحاوية التي تجمع الصورة مع بدائلها البصرية في مكان واحد.
  /// Builds the image wrapper that keeps loading and error fallbacks together.
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

  /// يظهر مساحة تحميل بسيطة لا تربك المستخدم قبل وصول الصورة.
  /// Shows a lightweight loading surface before the network image arrives.
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

  /// يعرض بديلاً محايدًا عندما لا يمكن تفسير الرابط أو جلب الصورة.
  /// Displays a neutral fallback when the URL cannot be resolved or loaded.
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
