import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/utils/image_utils.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/property_detail.dart';

/// Describes the `PropertyGalleryPage` page widget.
/// العربية: يمثل عنصر الصفحة `PropertyGalleryPage`.
class PropertyGalleryPage extends StatefulWidget {
  /// Keeps the images value available to this object.
  /// العربية: يخزن القيمة `images`.
  final List<PropertyImage> images;

  /// Keeps the initialIndex value available to this object.
  /// العربية: يخزن القيمة `initialIndex`.
  final int initialIndex;

  /// Constructs the PropertyGalleryPage value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `PropertyGalleryPage`.
  const PropertyGalleryPage({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  /// Builds the state object for this widget used by this feature.
  /// العربية: ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<PropertyGalleryPage> createState() => _PropertyGalleryPageState();
}

/// Describes the state for `PropertyGalleryPageState`.
/// العربية: يمثل الحالة الخاصة بـ `PropertyGalleryPageState`.
class _PropertyGalleryPageState extends State<PropertyGalleryPage>
    with TickerProviderStateMixin {
  /// Keeps the pageController value available to this object.
  /// العربية: يخزن القيمة `pageController`.
  late PageController _pageController;

  /// Keeps the fadeController value available to this object.
  /// العربية: يخزن القيمة `fadeController`.
  late AnimationController _fadeController;

  /// Keeps the slideController value available to this object.
  /// العربية: يخزن القيمة `slideController`.
  late AnimationController _slideController;

  /// Keeps the glowController value available to this object.
  /// العربية: يخزن القيمة `glowController`.
  late AnimationController _glowController;

  /// Keeps the particleController value available to this object.
  /// العربية: يخزن القيمة `particleController`.
  late AnimationController _particleController;

  /// Keeps the fadeAnimation value available to this object.
  /// العربية: يخزن القيمة `fadeAnimation`.
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation; // Top bar slide (from top)
  late Animation<Offset>
      _bottomInfoSlideAnimation; // Bottom info panel slide (from bottom)
  /// Keeps the glowAnimation value available to this object.
  /// العربية: يخزن القيمة `glowAnimation`.
  late Animation<double> _glowAnimation;

  /// Keeps the currentIndex value available to this object.
  /// العربية: يخزن القيمة `currentIndex`.
  late int _currentIndex;

  /// Keeps the showInfo value available to this object.
  /// العربية: يخزن القيمة `showInfo`.
  bool _showInfo = true;

  /// Keeps the orbs value available to this object.
  /// العربية: يخزن القيمة `orbs`.
  final List<_FloatingOrb> _orbs = [];

  /// Initializes the state for this widget.
  /// العربية: يهيئ الحالة الخاصة بهذا العنصر.
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeAnimations();
    _generateOrbs();
    _startAnimations();
  }

  /// Initializes the animations.
  /// العربية: يهيئ animations.
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Top bar slides down from -0.2 to 0
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Bottom info panel slides up from +0.2 to 0
    _bottomInfoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  /// Generates the orbs.
  /// العربية: ينشئ orbs.
  void _generateOrbs() {
    for (int i = 0; i < 5; i++) {
      _orbs.add(_FloatingOrb());
    }
  }

  /// Starts the animations.
  /// العربية: يبدأ animations.
  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
  }

  /// Releases the resources used by this instance.
  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  /// Builds the widget tree for this component.
  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),

          // Floating orbs
          _buildFloatingOrbs(),

          // Photo gallery
          _buildPhotoGallery(),

          // Glass morphism top bar
          _buildFuturisticTopBar(),

          // Bottom info panel
          if (_showInfo) _buildFuturisticBottomInfo(),

          // Page indicator
          _buildFuturisticPageIndicator(),
        ],
      ),
    );
  }

  /// Builds the animated background.
  /// العربية: يبني animated background.
  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkBackground,
            AppTheme.darkBackground.withOpacity(0.9),
            AppTheme.darkBackground.withOpacity(0.8),
          ],
        ),
      ),
    );
  }

  /// Builds the floating orbs.
  /// العربية: يبني floating orbs.
  Widget _buildFloatingOrbs() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: _OrbPainter(
            orbs: _orbs,
            animationValue: _particleController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  /// Builds the photo gallery.
  /// العربية: يبني photo gallery.
  Widget _buildPhotoGallery() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showInfo = !_showInfo;
        });
        if (_showInfo) {
          _fadeController.forward();
          _slideController.forward();
        } else {
          _fadeController.reverse();
          _slideController.reverse();
        }
      },
      child: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(
              ImageUtils.resolveUrl(widget.images[index].url),
            ),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            heroAttributes: PhotoViewHeroAttributes(
              tag: 'property_image_${widget.images[index].id}',
            ),
          );
        },
        itemCount: widget.images.length,
        loadingBuilder: (context, event) => Center(
          child: _buildFuturisticLoader(event),
        ),
        backgroundDecoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        pageController: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          HapticFeedback.lightImpact();
        },
      ),
    );
  }

  /// Builds the futuristic loader.
  /// العربية: يبني futuristic loader.
  Widget _buildFuturisticLoader(ImageChunkEvent? event) {
    final progress = event == null
        ? 0.0
        : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1);

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.2),
            AppTheme.primaryBlue.withOpacity(0.05),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryBlue,
            ),
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the futuristic top bar.
  /// العربية: يبني futuristic top bar.
  Widget _buildFuturisticTopBar() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.darkBackground.withOpacity(0.9),
                AppTheme.darkBackground.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGlassButton(
                        icon: Icons.close,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      _buildImageCounter(),
                      Row(
                        children: [
                          _buildGlassButton(
                            icon: Icons.download_outlined,
                            onPressed: _downloadImage,
                          ),
                          const SizedBox(width: 12),
                          _buildGlassButton(
                            icon: Icons.share_outlined,
                            onPressed: _shareImage,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the glass button.
  /// العربية: يبني glass button.
  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.6),
            AppTheme.darkCard.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: AppTheme.textWhite,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the image counter.
  /// العربية: يبني image counter.
  Widget _buildImageCounter() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(
                  0.3 * _glowAnimation.value,
                ),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            '${_currentIndex + 1} / ${widget.images.length}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  /// Builds the futuristic bottom info.
  /// العربية: يبني futuristic bottom info.
  Widget _buildFuturisticBottomInfo() {
    final currentImage = widget.images[_currentIndex];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _bottomInfoSlideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppTheme.darkBackground.withOpacity(0.95),
                  AppTheme.darkBackground.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                    top: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (currentImage.caption.isNotEmpty) ...[
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppTheme.primaryGradient.createShader(bounds),
                          child: Text(
                            currentImage.caption,
                            style: AppTextStyles.h2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (currentImage.altText.isNotEmpty)
                        Text(
                          currentImage.altText,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppTheme.textLight.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                      if (currentImage.tags.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildFuturisticTags(currentImage.tags),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the futuristic tags.
  /// العربية: يبني futuristic tags.
  Widget _buildFuturisticTags(String tags) {
    final tagList = tags.split(',').where((t) => t.trim().isNotEmpty).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tagList.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryBlue.withOpacity(0.2),
                AppTheme.primaryPurple.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            tag.trim(),
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Builds the futuristic page indicator.
  /// العربية: يبني futuristic page indicator.
  Widget _buildFuturisticPageIndicator() {
    if (widget.images.length <= 1) return const SizedBox.shrink();

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 120,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withOpacity(0.6),
                AppTheme.darkCard.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              widget.images.length > 10 ? 10 : widget.images.length,
              (index) {
                final actualIndex = _calculateIndicatorIndex(index);
                final isSelected = actualIndex == _currentIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isSelected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.primaryGradient : null,
                    color: !isSelected
                        ? AppTheme.textWhite.withOpacity(0.3)
                        : null,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Processes the calculateIndicatorIndex flow and maps it into the property feature behavior.
  /// العربية: يعالج `calculateIndicatorIndex`.
  int _calculateIndicatorIndex(int index) {
    if (widget.images.length <= 10) return index;

    final start = (_currentIndex - 4).clamp(0, widget.images.length - 10);
    return start + index;
  }

  /// Shares the image.
  /// العربية: يشارك image.
  void _shareImage() {
    HapticFeedback.mediumImpact();
    // Implement share functionality
  }

  /// Processes the downloadImage flow and maps it into the property feature behavior.
  /// العربية: يعالج `downloadImage`.
  void _downloadImage() {
    HapticFeedback.mediumImpact();
    // Implement download functionality
  }
}

// Floating orbs for background effect
/// Describes the FloatingOrb type used in the property feature.
/// العربية: يمثل `FloatingOrb`.
class _FloatingOrb {
  /// Keeps the x value available to this object.
  /// العربية: يخزن القيمة `x`.
  late double x;

  /// Keeps the y value available to this object.
  /// العربية: يخزن القيمة `y`.
  late double y;

  /// Keeps the radius value available to this object.
  /// العربية: يخزن القيمة `radius`.
  late double radius;

  /// Keeps the vx value available to this object.
  /// العربية: يخزن القيمة `vx`.
  late double vx;

  /// Keeps the vy value available to this object.
  /// العربية: يخزن القيمة `vy`.
  late double vy;

  /// Keeps the color value available to this object.
  /// العربية: يخزن القيمة `color`.
  late Color color;

  /// Keeps the opacity value available to this object.
  /// العربية: يخزن القيمة `opacity`.
  late double opacity;

  /// Constructs the FloatingOrb value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `FloatingOrb`.
  _FloatingOrb() {
    reset();
  }

  /// Processes the reset flow and maps it into the property feature behavior.
  /// العربية: يعالج `reset`.
  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    radius = math.Random().nextDouble() * 100 + 50;
    vx = (math.Random().nextDouble() - 0.5) * 0.0005;
    vy = (math.Random().nextDouble() - 0.5) * 0.0005;
    opacity = math.Random().nextDouble() * 0.1 + 0.05;

    final colors = [
      AppTheme.primaryBlue,
      AppTheme.primaryPurple,
      AppTheme.primaryCyan,
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }

  /// Updates the required operation for `update`.
  /// العربية: يحدّث العملية المطلوبة لـ `update`.
  void update() {
    x += vx;
    y += vy;

    if (x < -0.1 || x > 1.1) vx = -vx;
    if (y < -0.1 || y > 1.1) vy = -vy;
  }
}

/// Describes the OrbPainter type used in the property feature.
/// العربية: يمثل `OrbPainter`.
class _OrbPainter extends CustomPainter {
  /// Keeps the orbs value available to this object.
  /// العربية: يخزن القيمة `orbs`.
  final List<_FloatingOrb> orbs;

  /// Keeps the animationValue value available to this object.
  /// العربية: يخزن القيمة `animationValue`.
  final double animationValue;

  /// Constructs the OrbPainter value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `OrbPainter`.
  _OrbPainter({
    required this.orbs,
    required this.animationValue,
  });

  /// Processes the paint flow and maps it into the property feature behavior.
  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    for (var orb in orbs) {
      orb.update();

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            orb.color.withOpacity(orb.opacity),
            orb.color.withOpacity(0),
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(orb.x * size.width, orb.y * size.height),
          radius: orb.radius,
        ))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(orb.x * size.width, orb.y * size.height),
        orb.radius,
        paint,
      );
    }
  }

  /// Processes the shouldRepaint flow and maps it into the property feature behavior.
  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
