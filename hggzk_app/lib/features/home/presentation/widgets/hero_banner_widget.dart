// lib/features/home/presentation/widgets/banners/hero_banner_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'dart:async';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image_widget.dart';

/// يعرض شريطًا بصريًا بارزًا أعلى الصفحة الرئيسية لعرض الرسائل التسويقية أو
/// العروض أو الوجهات التي نريد إبرازها قبل بقية المحتوى.
/// Renders a prominent hero banner at the top of the home screen for featured
/// messages, offers, or destinations that should lead the rest of the content.
class HeroBanner extends StatefulWidget {
  /// العناصر التي ستملأ الشرائح، ويمكن استبدالها ببيانات قادمة من الخادم.
  /// Items used to fill the slides and optionally replaced by backend data.
  final List<BannerItem>? items;
  const HeroBanner({
    super.key,
    this.items,
  });
  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _autoScrollController;
  late AnimationController _parallaxController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  int _currentIndex = 0;
  Timer? _autoScrollTimer;
  final List<_BannerParticle> _particles = [];

  // Arabic: عناصر افتراضية جاهزة إذا لم يرسل الخادم أي بيانات.
  // English: Default fallback items used when the backend provides none.
  late List<BannerItem> _bannerItems;
  bool _bannerItemsInitialized = false;
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _generateParticles();
    _startAutoScroll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerItemsInitialized) {
      return;
    }

    _initializeBannerItems(context);
    _bannerItemsInitialized = true;
  }

  /// يجهز محتوى الشرائح مع مجموعة افتراضية تحافظ على استقرار الواجهة عندما
  /// لا تصل بيانات من الخادم بعد.
  /// Prepares slide content with a fallback set that keeps the widget stable
  /// when backend data has not arrived yet.
  void _initializeBannerItems(BuildContext context) {
    _bannerItems = widget.items ??
        [
          BannerItem(
            id: '1',
            title: context.tr('home.banner.discoverTitle'),
            subtitle: context.tr('home.banner.discoverSubtitle'),
            imageUrl: 'https://via.placeholder.com/800x400',
            gradient: [AppTheme.primaryBlue, AppTheme.primaryPurple],
          ),
          BannerItem(
            id: '2',
            title: context.tr('home.banner.exclusiveTitle'),
            subtitle: context.tr('home.banner.exclusiveSubtitle'),
            imageUrl: 'https://via.placeholder.com/800x400',
            gradient: [AppTheme.success, AppTheme.primaryCyan],
          ),
          BannerItem(
            id: '3',
            title: context.tr('home.banner.fastTitle'),
            subtitle: context.tr('home.banner.fastSubtitle'),
            imageUrl: 'https://via.placeholder.com/800x400',
            gradient: [AppTheme.warning, Colors.orange],
          ),
        ];
  }

  /// يهيئ وحدات التحكم المسؤولة عن التمرير التلقائي والبارالاكس والوهج
  /// وحركة الخلفية.
  /// Initializes the controllers that drive auto paging, parallax, glow, and
  /// background motion.
  void _initializeControllers() {
    _pageController = PageController(viewportFraction: 0.9);

    _autoScrollController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _parallaxController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  /// ينشئ مجموعة الجسيمات التي تضيف للشريط عمقًا وحركة مستمرة خفيفة.
  /// Creates the particle set that adds subtle depth and continuous motion to
  /// the banner.
  void _generateParticles() {
    for (int i = 0; i < 15; i++) {
      _particles.add(_BannerParticle());
    }
  }

  /// يبدأ دورة التنقل التلقائي بين الشرائح حتى يظل الشريط نشطًا من دون تدخل
  /// المستخدم.
  /// Starts the automatic paging cycle so the banner stays active even when
  /// the user does not interact with it.
  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final nextIndex = (_currentIndex + 1) % _bannerItems.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _autoScrollController.dispose();
    _parallaxController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          // Animated particles background
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ParticlesPainter(
                  particles: _particles,
                  animationValue: _particleController.value,
                ),
                size: const Size(double.infinity, 220),
              );
            },
          ),

          // Main banner carousel
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _bannerItems.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 0.0;
                  if (_pageController.position.haveDimensions) {
                    value = index - (_pageController.page ?? 0);
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  } else {
                    value = index == 0 ? 1.0 : 0.7;
                  }

                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * 220,
                      child: _buildBannerCard(_bannerItems[index], value),
                    ),
                  );
                },
              );
            },
          ),

          // Page indicators
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _buildPageIndicators(),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard(BannerItem item, double scale) {
    return GestureDetector(
      onTap: () => _handleBannerTap(item),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: item.gradient[0].withOpacity(0.3 * scale),
                  blurRadius: 30 * scale,
                  spreadRadius: 5 * scale,
                  offset: Offset(0, 10 * scale),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image with parallax effect
                  AnimatedBuilder(
                    animation: _parallaxController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          math.sin(_parallaxController.value * 2 * math.pi) *
                              10,
                          0,
                        ),
                        child: Transform.scale(
                          scale: 1.1,
                          child: CachedImageWidget(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),

                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),

                  // Animated gradient border
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        width: 2,
                        color: Colors.transparent,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          ...item.gradient,
                          ...item.gradient.reversed,
                        ],
                        stops: [
                          0.0,
                          0.25 + (_glowController.value * 0.25),
                          0.75 - (_glowController.value * 0.25),
                          1.0,
                        ],
                      ),
                    ),
                  ),

                  // Glass effect overlay
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge
                        if (item.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: item.gradient),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: item.gradient[0].withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              item.badge!,
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        // Title with animation
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.9),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            item.title,
                            style: AppTextStyles.h1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          item.subtitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // CTA Button
                        _buildCTAButton(item),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCTAButton(BannerItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: item.gradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: item.gradient[0].withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.ctaText ?? context.tr('home.banner.exploreNow'),
            style: AppTextStyles.buttonMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_bannerItems.length, (index) {
        final isActive = index == _currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(colors: _bannerItems[index].gradient)
                : null,
            color: !isActive ? AppTheme.darkBorder.withOpacity(0.5) : null,
            borderRadius: BorderRadius.circular(4),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _bannerItems[index].gradient[0].withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }

  /// يعالج اختيار الشريحة الحالية ويشكل نقطة الربط المستقبلية مع التوجيه
  /// أو تتبع النقرات.
  /// Handles selection of the current slide and acts as the future integration
  /// point for navigation or click tracking.
  void _handleBannerTap(BannerItem item) {
    HapticFeedback.mediumImpact();
    // Handle banner tap action
  }
}

/// يصف شريحة واحدة داخل الشريط مع كل ما تحتاجه الواجهة من نص وصورة وألوان
/// وبيانات إجراء.
/// Describes a single hero-banner slide with the text, image, colors, and
/// action metadata required by the UI.
class BannerItem {
  /// معرّف ثابت يسهّل تتبع الشريحة أو استهدافها تحليليًا.
  /// Stable identifier used for analytics, tracking, or addressing the slide.
  final String id;

  /// العنوان الرئيسي الذي يقود الرسالة البصرية في الشريحة.
  /// Main headline that carries the slide's primary marketing message.
  final String title;

  /// وصف أو جملة مساندة تمنح العنوان سياقًا إضافيًا.
  /// Supporting line that adds context beneath the main title.
  final String subtitle;

  /// مصدر الصورة الخلفية التي تملأ مساحة الشريحة.
  /// Source URL for the image that fills the slide background.
  final String imageUrl;

  /// تدرج الألوان الذي يحدد هوية الشريحة والتوهج المحيط بها.
  /// Color gradient that defines the slide identity and surrounding glow.
  final List<Color> gradient;

  /// شارة قصيرة لإبراز حالة مثل "حصري" أو "جديد".
  /// Short badge used to emphasize states such as "exclusive" or "new".
  final String? badge;

  /// نص زر الدعوة إلى الإجراء عندما تحتاج الشريحة هدفًا مباشرًا.
  /// Call-to-action label when the slide should point to a direct next step.
  final String? ctaText;

  /// نوع الإجراء المتوقع عند الضغط، مثل فتح شاشة أو تطبيق فلتر.
  /// Action type expected on tap, such as opening a screen or applying a
  /// filter.
  final String? action;

  /// بيانات إضافية تسمح بتمرير سياق غني إلى الشاشة التالية أو إلى أنظمة
  /// التتبع.
  /// Extra metadata that passes richer context to the next screen or to
  /// tracking systems.
  final Map<String, dynamic>? metadata;
  BannerItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.gradient,
    this.badge,
    this.ctaText,
    this.action,
    this.metadata,
  });
}

/// يمثّل جسيمًا بصريًا صغيرًا يتحرك في الخلفية ليمنح الشريط طبقة عمق وحياة
/// من دون أن يطغى على الرسالة الأساسية.
/// Represents a tiny visual particle that moves in the background to add
/// depth and life without distracting from the main message.
class _BannerParticle {
  late double x;
  late double y;
  late double size;
  late double speed;
  late double opacity;
  late Color color;
  _BannerParticle() {
    reset();
  }
  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    size = math.Random().nextDouble() * 3 + 1;
    speed = math.Random().nextDouble() * 0.001 + 0.0005;
    opacity = math.Random().nextDouble() * 0.3 + 0.1;

    final colors = [
      AppTheme.primaryBlue,
      AppTheme.primaryPurple,
      AppTheme.primaryCyan,
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }

  void update() {
    y -= speed;
    if (y < 0) {
      reset();
      y = 1.0;
    }
  }
}

/// يرسم الجسيمات المتحركة فوق خلفية الشريط لإضافة جو بصري حي ومتنفس.
/// Paints the moving particles above the banner background to create a lively,
/// atmospheric layer.
class _ParticlesPainter extends CustomPainter {
  final List<_BannerParticle> particles;
  final double animationValue;
  _ParticlesPainter({
    required this.particles,
    required this.animationValue,
  });
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();

      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
