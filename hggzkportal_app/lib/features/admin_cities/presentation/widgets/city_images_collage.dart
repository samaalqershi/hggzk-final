// lib/features/admin_cities/presentation/widgets/city_images_collage.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image_widget.dart';

/// Displays a city image collage with layouts that adapt to the number of files.
///
/// يعرض تجميعًا لصور المدينة بتخطيطات تتكيف مع عدد الملفات.
class CityImagesCollage extends StatefulWidget {
  /// Image URLs that will be arranged into the collage.
  ///
  /// روابط الصور التي ستُرتب داخل التجميع.
  final List<String> images;

  /// Collage height used by the parent card or gallery.
  ///
  /// ارتفاع التجميع المستخدم من البطاقة أو المعرض الأب.
  final double height;

  /// Optional width override for the collage container.
  ///
  /// عرض اختياري لحاوية التجميع.
  final double? width;

  /// Optional rounded-rectangle shape applied to the collage.
  ///
  /// شكل حواف مستديرة اختياري يُطبق على التجميع.
  final BorderRadius? borderRadius;

  /// Tap callback used when the collage should open a deeper view.
  ///
  /// دالة النقر المستخدمة عند فتح عرض أعمق.
  final VoidCallback? onTap;

  /// Toggles the overlay count badge when more than one image exists.
  ///
  /// يبدّل شارة العدد عندما يوجد أكثر من صورة.
  final bool showImageCount;

  /// Enables the hover animation and shadow response.
  ///
  /// يفعّل حركة التحويم واستجابة الظل.
  final bool enableHoverEffect;

  /// Creates a collage from the provided city image URLs.
  ///
  /// ينشئ تجميعًا من روابط صور المدينة الممررة.
  const CityImagesCollage({
    super.key,
    required this.images,
    this.height = 200,
    this.width,
    this.borderRadius,
    this.onTap,
    this.showImageCount = true,
    this.enableHoverEffect = true,
  });
  @override
  State<CityImagesCollage> createState() => _CityImagesCollageState();
}

/// يدير حركة التحويم واختيار التخطيط المناسب بحسب عدد الصور.
/// Manages hover motion and chooses the proper layout based on image count.
class _CityImagesCollageState extends State<CityImagesCollage>
    with SingleTickerProviderStateMixin {
  /// متحكم الحركة الذي يفعّل تأثير التكبير والظل عند التحويم.
  /// Animation controller that drives the hover scale and shadow effect.
  late AnimationController _animationController;

  /// يهيئ متحكم الحركة قبل عرض التجميع لأول مرة.
  /// Initializes the animation controller before the collage is first shown.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// يحرر متحكم الحركة عند إزالة الودجت من الشجرة.
  /// Disposes the animation controller when the widget leaves the tree.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// يبني التجميع مع معالجة حالة الفراغ والتمرير والنقر.
  /// Builds the collage while handling empty state, hover, and tap interactions.
  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return _buildEmptyState();
    }

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.enableHoverEffect
                  ? 1.0 - (_animationController.value * 0.02)
                  : 1.0,
              child: Container(
                height: widget.height,
                width: widget.width,
                decoration: BoxDecoration(
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(16),
                  boxShadow: widget.enableHoverEffect
                      ? [
                          BoxShadow(
                            color: AppTheme.shadowDark.withValues(
                              alpha: 0.2 + (_animationController.value * 0.1),
                            ),
                            blurRadius: 20 + (_animationController.value * 10),
                            offset: Offset(
                                0, 10 + (_animationController.value * 5)),
                          ),
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(16),
                  child: _buildLayout(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// يطلق أو يوقف تأثير التحويم بحسب حالة المؤشر.
  /// Starts or stops the hover effect depending on pointer state.
  void _onHover(bool isHovered) {
    if (!widget.enableHoverEffect) return;
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  /// يختار التخطيط الأنسب بحسب عدد الصور داخل التجميع.
  /// Chooses the most suitable layout based on the number of images.
  Widget _buildLayout() {
    final imageCount = widget.images.length;

    // تحديد التخطيط بناءً على عدد الصور (مثل تيليجرام/واتساب)
    switch (imageCount) {
      case 1:
        return _buildSingleImage();
      case 2:
        return _buildTwoImages();
      case 3:
        return _buildThreeImages();
      case 4:
        return _buildFourImages();
      case 5:
        return _buildFiveImages();
      case 6:
        return _buildSixImages();
      default:
        return _buildManyImages();
    }
  }

  // تخطيط صورة واحدة
  /// يبني تخطيط صورة واحدة مع طبقة تدرج خفيفة.
  /// Builds the single-image layout with a subtle gradient overlay.
  Widget _buildSingleImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildImage(widget.images[0]),
        _buildGradientOverlay(),
      ],
    );
  }

  // تخطيط صورتين (جنب بعض)
  /// يبني تخطيطًا لصورتين جنبًا إلى جنب.
  /// Builds a side-by-side layout for two images.
  Widget _buildTwoImages() {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(child: _buildImage(widget.images[0])),
            const SizedBox(width: 2),
            Expanded(child: _buildImage(widget.images[1])),
          ],
        ),
        _buildGradientOverlay(),
      ],
    );
  }

  // تخطيط 3 صور (واحدة كبيرة يسار واثنتين صغيرتين يمين)
  /// يبني تخطيطًا من ثلاث صور يبرز صورة رئيسية وصورتين ثانويتين.
  /// Builds a three-image layout with one dominant image and two supporting ones.
  Widget _buildThreeImages() {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildImage(widget.images[0]),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _buildImage(widget.images[1])),
                  const SizedBox(height: 2),
                  Expanded(child: _buildImage(widget.images[2])),
                ],
              ),
            ),
          ],
        ),
        _buildGradientOverlay(),
      ],
    );
  }

  // تخطيط 4 صور (شبكة 2×2)
  /// يبني شبكة 2×2 لأربع صور.
  /// Builds a 2x2 grid for four images.
  Widget _buildFourImages() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildImage(widget.images[0])),
                  const SizedBox(width: 2),
                  Expanded(child: _buildImage(widget.images[1])),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildImage(widget.images[2])),
                  const SizedBox(width: 2),
                  Expanded(child: _buildImage(widget.images[3])),
                ],
              ),
            ),
          ],
        ),
        _buildGradientOverlay(),
      ],
    );
  }

  // تخطيط 5 صور (صورتين فوق و3 تحت)
  /// يبني تخطيطًا لخمس صور مع صف علوي وصف سفلي.
  /// Builds a five-image layout with one top row and one bottom row.
  Widget _buildFiveImages() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(child: _buildImage(widget.images[0])),
                  const SizedBox(width: 2),
                  Expanded(child: _buildImage(widget.images[1])),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(child: _buildImage(widget.images[2])),
                  const SizedBox(width: 2),
                  Expanded(child: _buildImage(widget.images[3])),
                  const SizedBox(width: 2),
                  Expanded(child: _buildImage(widget.images[4])),
                ],
              ),
            ),
          ],
        ),
        _buildGradientOverlay(),
      ],
    );
  }

  // تخطيط 6 صور (شبكة 3×2)
  /// يبني تخطيطًا من ست صور على صفوف متوازنة.
  /// Builds a six-image layout with balanced rows.
  Widget _buildSixImages() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildImage(widget.images[0])),
                  const SizedBox(width: 2),
                  Expanded(child: _buildImage(widget.images[1])),
                  const SizedBox(width: 2),
                  Expanded(child: _buildImage(widget.images[2])),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildImage(widget.images[3])),
                  const SizedBox(width: 2),
                  Expanded(child: _buildImage(widget.images[4])),
                  const SizedBox(width: 2),
                  Expanded(child: _buildImage(widget.images[5])),
                ],
              ),
            ),
          ],
        ),
        _buildGradientOverlay(),
      ],
    );
  }

  // تخطيط للصور الكثيرة (عرض أول 4 مع عداد)
  /// يبني تخطيط الصور الزائدة ويعرض عدد الباقي فوق آخر خانة.
  /// Builds the overflow layout and shows the remaining count on the last tile.
  Widget _buildManyImages() {
    final displayImages = widget.images.take(4).toList();
    final remainingCount = widget.images.length - 4;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildImage(displayImages[0])),
                  const SizedBox(width: 2),
                  Expanded(child: _buildImage(displayImages[1])),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildImage(displayImages[2])),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImage(displayImages[3]),
                        if (remainingCount > 0)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                            ),
                            child: Center(
                              child: Text(
                                '+$remainingCount',
                                style: AppTextStyles.heading2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        _buildGradientOverlay(),
      ],
    );
  }

  /// يبني عنصر صورة واحدًا مع التحميل والتغطية والتقاط الأخطاء.
  /// Builds a single image tile with loading, overlay, and error handling.
  Widget _buildImage(String imageUrl) {
    return CachedImageWidget(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
    );
  }

  /// يضيف طبقة تدرج لتحسين قابلية قراءة العدد أو النص فوق الصور.
  /// Adds a gradient overlay to improve text and count legibility.
  Widget _buildGradientOverlay() {
    if (!widget.showImageCount || widget.images.length <= 1) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.photo,
              size: 12,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.images.length}',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// يعرض حالة فارغة عندما لا تتوفر أي صور للمدينة.
  /// Shows the empty state when no city images are available.
  Widget _buildEmptyState() {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.photo,
              size: 32,
              color: AppTheme.textMuted.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد صور',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
