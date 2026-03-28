import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../domain/entities/property_detail.dart';

/// Describes the PropertyImagesGridWidget widget used in the property feature.
/// العربية: يمثل العنصر `PropertyImagesGridWidget`.
class PropertyImagesGridWidget extends StatefulWidget {
  /// Keeps the images value available to this object.
  /// العربية: يخزن القيمة `images`.
  final List<PropertyImage> images;

  /// Processes the Function flow and maps it into the property feature behavior.
  /// العربية: يعالج `Function`.
  final Function(int)? onImageTap;

  /// Keeps the height value available to this object.
  /// العربية: يخزن القيمة `height`.
  final double height;

  /// Constructs the PropertyImagesGridWidget value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `PropertyImagesGridWidget`.
  const PropertyImagesGridWidget({
    super.key,
    required this.images,
    this.onImageTap,
    this.height = 320,
  });

  /// Builds the state object for this widget used by this feature.
  /// العربية: ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<PropertyImagesGridWidget> createState() =>
      _PropertyImagesGridWidgetState();
}

/// Describes the state for `PropertyImagesGridWidgetState`.
/// العربية: يمثل الحالة الخاصة بـ `PropertyImagesGridWidgetState`.
class _PropertyImagesGridWidgetState extends State<PropertyImagesGridWidget>
    with TickerProviderStateMixin {
  /// Keeps the shimmerController value available to this object.
  /// العربية: يخزن القيمة `shimmerController`.
  late AnimationController _shimmerController;

  /// Keeps the scaleController value available to this object.
  /// العربية: يخزن القيمة `scaleController`.
  late AnimationController _scaleController;

  /// Keeps the hoveredIndex value available to this object.
  /// العربية: يخزن القيمة `hoveredIndex`.
  int? _hoveredIndex;

  /// Initializes the state for this widget.
  /// العربية: يهيئ الحالة الخاصة بهذا العنصر.
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  /// Releases the resources used by this instance.
  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _shimmerController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  /// Builds the widget tree for this component.
  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return _buildEmptyState();
    }

    if (widget.images.length == 1) {
      return _buildSingleImage();
    }

    if (widget.images.length == 2) {
      return _buildTwoImagesLayout();
    }

    if (widget.images.length == 3) {
      return _buildThreeImagesLayout();
    }

    return _buildMultiImagesLayout();
  }

  /// Builds the empty state.
  /// العربية: يبني empty state.
  Widget _buildEmptyState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.6),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.15),
                    AppTheme.primaryBlue.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 28,
                color: AppTheme.textMuted.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد صور متاحة',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the single image.
  /// العربية: يبني single image.
  Widget _buildSingleImage() {
    return GestureDetector(
      onTap: () => widget.onImageTap?.call(0),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImageWithEffects(widget.images[0], 0, true),
            _buildGradientOverlay(),
            _buildImageCounter(1, 1),
          ],
        ),
      ),
    );
  }

  /// Builds the two images layout.
  /// العربية: يبني two images layout.
  Widget _buildTwoImagesLayout() {
    return SizedBox(
      height: widget.height,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => widget.onImageTap?.call(0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImageWithEffects(widget.images[0], 0, true),
                  _buildGradientOverlay(),
                ],
              ),
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () => widget.onImageTap?.call(1),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImageWithEffects(widget.images[1], 1, false),
                  _buildGradientOverlay(),
                  _buildImageCounter(2, 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the three images layout.
  /// العربية: يبني three images layout.
  Widget _buildThreeImagesLayout() {
    return SizedBox(
      height: widget.height,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => widget.onImageTap?.call(0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImageWithEffects(widget.images[0], 0, true),
                  _buildGradientOverlay(),
                ],
              ),
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onImageTap?.call(1),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImageWithEffects(widget.images[1], 1, false),
                        _buildGradientOverlay(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onImageTap?.call(2),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImageWithEffects(widget.images[2], 2, false),
                        _buildGradientOverlay(),
                        _buildImageCounter(3, 3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the multi images layout.
  /// العربية: يبني multi images layout.
  Widget _buildMultiImagesLayout() {
    return SizedBox(
      height: widget.height,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => widget.onImageTap?.call(0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImageWithEffects(widget.images[0], 0, true),
                  _buildGradientOverlay(),
                ],
              ),
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onImageTap?.call(1),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImageWithEffects(widget.images[1], 1, false),
                        _buildGradientOverlay(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => widget.onImageTap?.call(2),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _buildImageWithEffects(
                                  widget.images[2], 2, false),
                              _buildGradientOverlay(),
                            ],
                          ),
                        ),
                      ),
                      if (widget.images.length > 3) ...[
                        const SizedBox(width: 1),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => widget.onImageTap?.call(3),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (widget.images.length > 4)
                                  _buildMoreImagesOverlay(
                                      widget.images.length - 4)
                                else
                                  _buildImageWithEffects(
                                      widget.images[3], 3, false),
                                _buildGradientOverlay(),
                                if (widget.images.length == 4)
                                  _buildImageCounter(4, 4),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the image with effects.
  /// العربية: يبني image with effects.
  Widget _buildImageWithEffects(PropertyImage image, int index, bool isMain) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(_hoveredIndex == index ? 1.02 : 1.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedImageWidget(
              imageUrl: image.url,
              fit: BoxFit.cover,
            ),
            if (_hoveredIndex == index)
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ShimmerPainter(
                      shimmerPosition: _shimmerController.value,
                    ),
                  );
                },
              ),
            if (isMain)
              Positioned(
                top: 12,
                left: 12,
                child: _buildFeaturedBadge(),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the more images overlay.
  /// العربية: يبني more images overlay.
  Widget _buildMoreImagesOverlay(int remainingCount) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.images.length > 3)
          CachedImageWidget(
            imageUrl: widget.images[3].url,
            fit: BoxFit.cover,
          ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.darkBackground.withOpacity(0.7),
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.photo_library,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.primaryGradient.createShader(bounds),
                      child: Text(
                        '+$remainingCount',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'صور إضافية',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the gradient overlay.
  /// العربية: يبني gradient overlay.
  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppTheme.darkBackground.withOpacity(0.15),
          ],
        ),
      ),
    );
  }

  /// Builds the image counter.
  /// العربية: يبني image counter.
  Widget _buildImageCounter(int current, int total) {
    return Positioned(
      bottom: 10,
      right: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkBackground.withOpacity(0.7),
                  AppTheme.darkBackground.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.photo_camera,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '$current / $total',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the featured badge.
  /// العربية: يبني featured badge.
  Widget _buildFeaturedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            size: 10,
            color: Colors.white,
          ),
          const SizedBox(width: 3),
          Text(
            'مميز',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Describes the ShimmerPainter type used in the property feature.
/// العربية: يمثل `ShimmerPainter`.
class _ShimmerPainter extends CustomPainter {
  /// Keeps the shimmerPosition value available to this object.
  /// العربية: يخزن القيمة `shimmerPosition`.
  final double shimmerPosition;

  /// Constructs the ShimmerPainter value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `ShimmerPainter`.
  _ShimmerPainter({required this.shimmerPosition});

  /// Processes the paint flow and maps it into the property feature behavior.
  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment(-1.0 + shimmerPosition * 2, -1.0 + shimmerPosition * 2),
      end: Alignment(-0.5 + shimmerPosition * 2, -0.5 + shimmerPosition * 2),
      colors: [
        Colors.transparent,
        Colors.white.withOpacity(0.08),
        Colors.white.withOpacity(0.15),
        Colors.white.withOpacity(0.08),
        Colors.transparent,
      ],
      stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

  /// Processes the shouldRepaint flow and maps it into the property feature behavior.
  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
