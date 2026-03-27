// lib/features/home/presentation/pages/futuristic_home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hggzk/features/home/presentation/widgets/futuristic_home_app_bar.dart';
import 'package:hggzk/features/home/presentation/widgets/futuristic_unit_type_card.dart';
import 'package:hggzk/features/home/presentation/widgets/hero_banner_widget.dart';
import 'package:hggzk/features/home/presentation/widgets/elegant_property_types_section.dart';
import 'package:hggzk/features/home/presentation/widgets/elegant_unit_types_section.dart';
import 'package:hggzk/features/home/presentation/widgets/refresh_indicator_widget.dart';
import 'package:hggzk/features/home/presentation/widgets/section_loading_widget.dart';
import 'package:hggzk/features/home/presentation/widgets/section_visibility_detector.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../domain/entities/section.dart';
import '../../domain/entities/unit_type.dart';
import '../../../search/domain/entities/search_filter.dart' show UnitTypeField;
import '../../../reference/presentation/widgets/city_selector_dialog.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../services/filter_storage_service.dart';
import 'package:get_it/get_it.dart';
import '../widgets/sections/base_section_widget.dart';
import '../../../../presentation/navigation/main_tab_notification.dart';
import '../../../booking/presentation/widgets/date_picker_widget.dart';
import '../../../booking/presentation/widgets/guest_selector_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _backgroundAnimationController;
  late AnimationController _particlesAnimationController;
  late AnimationController _glowAnimationController;
  late AnimationController _contentAnimationController;
  late AnimationController _waveAnimationController;
  late AnimationController _shimmerController;

  // Animations
  late Animation<double> _backgroundRotationAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _shimmerAnimation;

  // Scroll and Particles
  final ScrollController _scrollController = ScrollController();
  final List<_AdvancedParticle> _particles = [];
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();

  // State
  bool _showFloatingSearch = false;
  double _scrollOffset = 0;
  double _scrollVelocity = 0;
  DateTime _lastScrollTime = DateTime.now();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _initializeAnimations();
    _generateAdvancedParticles();
    _setupScrollListener();
    _startAnimations();

    // Load home data with delay for smooth animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<HomeBloc>().add(const LoadHomeDataEvent());
      }
    });
  }

  Widget _buildExpiredDatesWarning() {
    try {
      final selections =
          GetIt.instance<FilterStorageService>().getHomeSelections();
      final hasExpired = selections['hasExpiredSavedDates'] == true;
      if (!hasExpired) {
        return const SizedBox.shrink();
      }
    } catch (_) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.warning.withOpacity(0.18),
            AppTheme.warning.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.warning.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.warning.withOpacity(0.9),
                  AppTheme.warning.withOpacity(0.7),
                ],
              ),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تاريخ الوصول المحفوظ أقدم من اليوم',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'تم تجاهل التواريخ القديمة. يرجى اختيار تواريخ جديدة قبل البدء في البحث للحصول على نتائج دقيقة.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _initializeAnimations() {
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _particlesAnimationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _waveAnimationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _backgroundRotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.linear,
    ));

    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuart),
    ));

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _waveAnimationController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _generateAdvancedParticles() {
    for (int i = 0; i < 30; i++) {
      _particles.add(_AdvancedParticle());
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final now = DateTime.now();
      final timeDiff = now.difference(_lastScrollTime).inMilliseconds;

      if (timeDiff > 0) {
        _scrollVelocity =
            (_scrollController.offset - _scrollOffset).abs() / timeDiff;
      }

      setState(() {
        _scrollOffset = _scrollController.offset;
        _showFloatingSearch = _scrollOffset > 150;
        _lastScrollTime = now;
      });

      // Parallax effect for particles
      for (var particle in _particles) {
        particle.parallaxOffset = _scrollOffset * 0.001;
      }
    });
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _contentAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _particlesAnimationController.dispose();
    _glowAnimationController.dispose();
    _contentAnimationController.dispose();
    _waveAnimationController.dispose();
    _shimmerController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Advanced animated background
          _buildAdvancedBackground(),

          // Floating particles with parallax
          _buildAdvancedParticles(),

          // Main content
          _buildMainContent(),

          // Floating search bar
          _buildFloatingSearchBar(),
        ],
      ),
    );
  }

  Widget _buildAdvancedBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _backgroundRotationAnimation,
        _waveAnimation,
        _glowAnimationController,
      ]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2,
                AppTheme.darkBackground3,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Wave overlay
              CustomPaint(
                painter: _AdvancedWavePainter(
                  waveAnimation: _waveAnimation.value,
                  glowIntensity: _glowAnimationController.value,
                  scrollOffset: _scrollOffset,
                ),
                size: Size.infinite,
              ),

              // Grid pattern
              CustomPaint(
                painter: _FuturisticGridPainter(
                  rotation: _backgroundRotationAnimation.value * 0.1,
                  opacity: 0.03,
                  scrollOffset: _scrollOffset,
                ),
                size: Size.infinite,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdvancedParticles() {
    return AnimatedBuilder(
      animation: _particlesAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: _AdvancedParticlePainter(
            particles: _particles,
            animationValue: _particlesAnimationController.value,
            scrollVelocity: _scrollVelocity,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMainContent() {
    return FuturisticRefreshIndicator(
      key: _refreshKey,
      onRefresh: _handleRefresh,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          // Build slivers conditionally
          final slivers = <Widget>[];

          // 1. Always add App Bar
          slivers.add(
            FuturisticHomeAppBar(
              isExpanded: !_showFloatingSearch,
              scrollOffset: _scrollOffset,
              onNotificationTap: () => _navigateToNotifications(),
              onProfileTap: () => _navigateToProfile(),
              onLocationTap: _openCitySelector,
              currentLocation:
                  GetIt.instance<LocalStorageService>().getSelectedCity(),
            ),
          );

          // 2. Property types and unit types are now shown inside content (not pinned)

          // 3. Main Content
          slivers.add(
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _contentFadeAnimation,
                child: SlideTransition(
                  position: _contentSlideAnimation,
                  child: _buildContent(),
                ),
              ),
            ),
          );

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: slivers,
          );
        },
      ),
    );
  }

  Widget _buildFloatingSearchBar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutExpo,
      top: _showFloatingSearch ? 0 : -100,
      left: 0,
      right: 0,
      child: _buildCompactSearchBar(),
    );
  }

  Widget _buildCompactSearchBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.darkCard.withOpacity(0.95),
            AppTheme.darkCard.withOpacity(0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Back to top button
                  _buildFloatingActionButton(
                    icon: Icons.arrow_upward_rounded,
                    onTap: _scrollToTop,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryBlue.withOpacity(0.2),
              AppTheme.primaryPurple.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildCompactSearchField() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.6),
            AppTheme.darkSurface.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: TextField(
        style: AppTextStyles.bodySmall.copyWith(
          color: AppTheme.textWhite,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن وجهتك...',
          hintStyle: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: AppTheme.textMuted,
          ),
        ),
        onSubmitted: _handleSearch,
      ),
    );
  }

  Widget _buildContent() {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // تحذير في حال كانت التواريخ المحفوظة أقدم من اليوم الحالي
              _buildExpiredDatesWarning(),
            ],
          ),
        ),

        // Property Types Section - NEW ELEGANT DESIGN
        _buildPropertyTypesSection(),

        // Unit Types Section - NEW ELEGANT DESIGN
        _buildUnitTypesSection(),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Dynamic unit fields لم تعد تُستخدم في فلترة البحث، لذا تم إخفاؤها من الصفحة الرئيسية
              _buildDynamicFieldsSection(),

              const SizedBox(height: 20),

              // Sections content
              _buildSectionsContent(),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Footer - يظهر فقط بعد تحميل البيانات
        _buildConditionalFooter(isDesktop, isTablet),

        const SizedBox(
            height:
                16), // مساحة صغيرة للتنفس - padding الأساسي يأتي من NavigationPage
      ],
    );
  }

  Widget _buildConditionalFooter(bool isDesktop, bool isTablet) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded) {
          return _buildCompanyFooter(isDesktop, isTablet);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCompanyFooter(bool isDesktop, bool isTablet) {
    final currentYear = DateTime.now().year;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(
        top: isDesktop ? 60 : 40,
        left: isDesktop ? 24 : 16,
        right: isDesktop ? 24 : 16,
        bottom: 20,
      ),
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 40 : 30,
        horizontal: isDesktop ? 40 : 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.darkCard.withOpacity(0.8), // ✅ زيادة من 0.3 إلى 0.8
                  AppTheme.darkCard.withOpacity(0.6), // ✅ زيادة من 0.15 إلى 0.6
                ]
              : [
                  AppTheme.lightCard.withOpacity(0.9),
                  AppTheme.lightCard.withOpacity(0.7),
                ],
        ),
        border: Border.all(
          color: isDark
              ? AppTheme.darkBorder.withOpacity(0.4) // ✅ زيادة من 0.1 إلى 0.4
              : AppTheme.lightBorder.withOpacity(0.3),
          width: 1, // ✅ زيادة من 0.5 إلى 1
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3) // ✅ ظل أقوى
                : Colors.black.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          if (isDark) // ✅ توهج إضافي في الوضع المظلم
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              blurRadius: 50,
              spreadRadius: 10,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                // Logo Section - مُحسّن ✨
                AnimatedBuilder(
                  animation: _glowAnimationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 3 * _glowAnimationController.value),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    AppTheme.primaryBlue
                                        .withOpacity(0.2), // ✅ زيادة من 0.05
                                    AppTheme.primaryPurple
                                        .withOpacity(0.15), // ✅ زيادة من 0.05
                                  ]
                                : [
                                    AppTheme.primaryBlue.withOpacity(0.1),
                                    AppTheme.primaryPurple.withOpacity(0.08),
                                  ],
                          ),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.glowBlue
                                    .withOpacity(0.3) // ✅ زيادة من 0.1
                                : AppTheme.primaryBlue.withOpacity(0.2),
                            width: 1.5, // ✅ زيادة من 0.5
                          ),
                          boxShadow: [
                            // ✅ ظل أقوى للشعار
                            BoxShadow(
                              color: isDark
                                  ? AppTheme.primaryBlue.withOpacity(0.3)
                                  : AppTheme.primaryBlue.withOpacity(0.1),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: _buildLogo(isDesktop, isTablet),
                      ),
                    );
                  },
                ),
                SizedBox(width: isDesktop ? 32 : 20),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Copyright Section - مُحسّن
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.copyright_rounded,
                                size: 14,
                                color: isDark
                                    ? AppTheme.textLight
                                        .withOpacity(0.8) // ✅ زيادة الوضوح
                                    : AppTheme.textMuted.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$currentYear',
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark
                                      ? AppTheme
                                          .textLight // ✅ إزالة الشفافية الإضافية
                                      : AppTheme.textMuted,
                                  fontWeight:
                                      FontWeight.w500, // ✅ جعل النص أثقل
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'أرما سوفت للبرمجة والتطوير',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark
                                  ? AppTheme.textWhite
                                      .withOpacity(0.9) // ✅ تغيير من textMuted
                                  : AppTheme.textDark,
                              fontWeight: FontWeight.w600, // ✅ أثقل
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'جميع الحقوق محفوظة',
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppTheme.textLight
                                  .withOpacity(0.8) // ✅ زيادة من 0.5
                              : AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Phone Number - مُحسّن
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6), // ✅ زيادة الحشو
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.inputBackground
                                  .withOpacity(0.3) // ✅ زيادة من 0.1
                              : AppTheme.inputBackground.withOpacity(0.5),
                          borderRadius:
                              BorderRadius.circular(8), // ✅ زيادة من 6
                          border: Border.all(
                            color: isDark
                                ? AppTheme.darkBorder
                                    .withOpacity(0.4) // ✅ زيادة من 0.1
                                : AppTheme.lightBorder.withOpacity(0.5),
                            width: 1, // ✅ زيادة من 0.5
                          ),
                          boxShadow: [
                            // ✅ إضافة ظل للوضوح
                            BoxShadow(
                              color: isDark
                                  ? AppTheme.primaryBlue.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 12,
                              color: isDark
                                  ? AppTheme.textLight.withOpacity(0.7)
                                  : AppTheme.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '+967 777 517 527',
                                    maxLines: 1,
                                    style: AppTextStyles.caption.copyWith(
                                      color: isDark
                                          ? AppTheme.textLight.withOpacity(
                                              0.9) // ✅ زيادة من 0.4
                                          : AppTheme.textMuted,
                                      fontFamily: 'monospace',
                                      fontWeight:
                                          FontWeight.w500, // ✅ إضافة وزن
                                    ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDesktop, bool isTablet) {
    final double logoWidth = isDesktop ? 120 : (isTablet ? 96 : 72);
    final double logoHeight = logoWidth * 1.2475;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String assetPath = isDark
        ? 'assets/images/arma_logo_light.png'
        : 'assets/images/arma_logo.png';

    return Image.asset(
      assetPath,
      width: logoWidth,
      height: logoHeight,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          _buildLogoPlaceholder(logoWidth, logoHeight),
    );
  }

  Widget _buildLogoPlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withOpacity(0.8),
            AppTheme.primaryPurple.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.glowBlue.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          'H',
          style: AppTextStyles.h2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactWelcomeSection() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    AppTheme.primaryCyan,
                    AppTheme.primaryBlue,
                    AppTheme.primaryPurple,
                  ],
                  stops: [
                    0.0,
                    0.5 + 0.3 * _shimmerAnimation.value,
                    1.0,
                  ],
                ).createShader(bounds);
              },
              child: Text(
                'مرحبًا بك',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _glowAnimationController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(
                          0.3 + 0.2 * _glowAnimationController.value,
                        ),
                        blurRadius: 10 + 5 * _glowAnimationController.value,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainSearchBar() {
    return GestureDetector(
      onTap: () => _navigateToSearch(),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.7),
              AppTheme.darkCard.withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'إلى أين تريد الذهاب؟',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textMuted.withOpacity(0.7),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: AppTheme.textMuted.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicContent() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) return const SizedBox.shrink();

        return const Column(
          children: [
            // Property types grid
            // if (state.propertyTypes.isNotEmpty)
            //   FuturisticPropertyTypesGrid(
            //     propertyTypes: state.propertyTypes,
            //     selectedTypeId: state.selectedPropertyTypeId,
            //     onTypeSelected: (id) {
            //       context.read<HomeBloc>().add(
            //             UpdatePropertyTypeFilterEvent(propertyTypeId: id),
            //           );
            //     },
            //     isCompact: true,
            //   ),

            // Unit types and dynamic fields
            // if (state.selectedPropertyTypeId != null)
            //   _buildUnitTypesAndFields(state),
          ],
        );
      },
    );
  }

  Widget _buildUnitTypesAndFields(HomeLoaded state) {
    final List<UnitType> unitTypes =
        state.unitTypes[state.selectedPropertyTypeId] ?? <UnitType>[];

    if (unitTypes.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 12),

        // Unit types horizontal list
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: unitTypes.length,
            itemBuilder: (context, index) {
              final unitType = unitTypes[index];
              final isSelected = state.selectedUnitTypeId == unitType.id;

              return Padding(
                padding: EdgeInsets.only(
                  right: index == 0 ? 0 : 4,
                  left: index == unitTypes.length - 1 ? 0 : 4,
                ),
                child: FuturisticUnitTypeCard(
                  id: unitType.id,
                  name: unitType.name,
                  icon: unitType.icon ?? 'bed',
                  isSelected: isSelected,
                  animationDelay: Duration(milliseconds: index * 50),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.read<HomeBloc>().add(
                          UpdateUnitTypeSelectionEvent(unitTypeId: unitType.id),
                        );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompactExploreButton(HomeLoaded state) {
    // Compute enablement based on dates, guests (if required), and required fields
    UnitType? selectedUnit;
    if (state.selectedPropertyTypeId != null &&
        state.selectedUnitTypeId != null) {
      final unitTypes =
          state.unitTypes[state.selectedPropertyTypeId] ?? const <UnitType>[];
      try {
        selectedUnit =
            unitTypes.firstWhere((u) => u.id == state.selectedUnitTypeId);
      } catch (_) {}
    }

    final df = Map<String, dynamic>.from(state.dynamicFieldValues);
    final DateTime? checkIn =
        df['checkIn'] is DateTime ? df['checkIn'] as DateTime : null;
    final DateTime? checkOut =
        df['checkOut'] is DateTime ? df['checkOut'] as DateTime : null;
    final int adults = (df['adults'] as int?) ?? 0;
    final int children = (df['children'] as int?) ?? 0;
    final bool datesOk = checkIn != null && checkOut != null;
    bool guestsOk = true;
    if (selectedUnit != null &&
        (selectedUnit.isHasAdults || selectedUnit.isHasChildren)) {
      guestsOk = (!selectedUnit.isHasAdults || adults >= 1) &&
          (!selectedUnit.isHasChildren || children >= 0);
    }
    // لم نعد نعتبر الحقول الديناميكية شرطاً لتفعيل زر الاستكشاف
    bool fieldsOk = true;

    final bool isEnabled =
        selectedUnit != null && datesOk && guestsOk && fieldsOk;

    final int guestsCount = adults + children;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: GestureDetector(
          onTap: isEnabled
              ? () {
                  HapticFeedback.lightImpact();

                  final Map<String, dynamic> params = {
                    'propertyTypeId': state.selectedPropertyTypeId,
                    'unitTypeId': state.selectedUnitTypeId,
                  };

                  // ✅ FIX: تمرير المدينة من LocalStorage
                  final selectedCity =
                      GetIt.instance<LocalStorageService>().getSelectedCity();
                  if (selectedCity.isNotEmpty) {
                    params['city'] = selectedCity;
                  }

                  if (checkIn != null)
                    params['checkIn'] = checkIn.toIso8601String();
                  if (checkOut != null)
                    params['checkOut'] = checkOut.toIso8601String();
                  // لا تمرر guestsCount لأنواع الوحدات التي لا تدعم بالغين/أطفال
                  final bool supportsGuests = selectedUnit != null &&
                      (selectedUnit.isHasAdults || selectedUnit.isHasChildren);
                  if (supportsGuests) {
                    params['adults'] = adults;
                    params['children'] = children;
                  }

                  debugPrint('🔍 [HomePage] params to be sent: $params');
                  context.push('/search', extra: params);
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isEnabled
                  ? AppTheme.primaryGradient
                  : LinearGradient(
                      colors: [
                        AppTheme.textMuted.withOpacity(0.3),
                        AppTheme.textMuted.withOpacity(0.2),
                      ],
                    ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.explore_rounded,
                  size: 18,
                  color: isEnabled
                      ? Colors.white
                      : AppTheme.textMuted.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'استكشف',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isEnabled
                        ? Colors.white
                        : AppTheme.textMuted.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeUnitInlineFilters(UnitType selectedUnit, HomeLoaded state) {
    final DateTime now = DateTime.now();
    final DateTime? checkIn = state.dynamicFieldValues['checkIn'] as DateTime?;
    final DateTime? checkOut =
        state.dynamicFieldValues['checkOut'] as DateTime?;
    final int adults = (state.dynamicFieldValues['adults'] as int?) ?? 0;
    final int children = (state.dynamicFieldValues['children'] as int?) ?? 0;
    final int adultsMax = _resolveGuestMax(
      selectedUnit,
      fieldNameCandidates: const ['adults', 'adult'],
      defaultMax: 10,
    );
    final int childrenMax = _resolveGuestMax(
      selectedUnit,
      fieldNameCandidates: const ['children', 'child'],
      defaultMax: 5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // نفس تصميم اختيار التواريخ في صفحة الحجز (مكدس وبتأثير Blur)
        Container(
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                children: [
                  DatePickerWidget(
                    label: 'تاريخ الوصول',
                    selectedDate: checkIn,
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365)),
                    onDateSelected: (date) {
                      HapticFeedback.selectionClick();
                      final updatedValues =
                          Map<String, dynamic>.from(state.dynamicFieldValues);
                      updatedValues['checkIn'] = date;
                      if (checkOut != null && checkOut.isBefore(date)) {
                        updatedValues.remove('checkOut');
                      }
                      context.read<HomeBloc>().add(
                            UpdateDynamicFieldValuesEvent(
                                values: updatedValues),
                          );
                    },
                    icon: Icons.calendar_today_rounded,
                  ),
                  Container(
                    height: 0.5,
                    color: AppTheme.darkBorder.withOpacity(0.1),
                  ),
                  DatePickerWidget(
                    label: 'تاريخ المغادرة',
                    selectedDate: checkOut,
                    firstDate: checkIn?.add(const Duration(days: 1)) ??
                        now.add(const Duration(days: 1)),
                    lastDate: now.add(const Duration(days: 365)),
                    onDateSelected: (date) {
                      HapticFeedback.selectionClick();
                      final updatedValues =
                          Map<String, dynamic>.from(state.dynamicFieldValues);
                      updatedValues['checkOut'] = date;
                      context.read<HomeBloc>().add(
                            UpdateDynamicFieldValuesEvent(
                                values: updatedValues),
                          );
                    },
                    enabled: checkIn != null,
                    icon: Icons.calendar_today_outlined,
                  ),
                ],
              ),
            ),
          ),
        ),

        // نفس تصميم اختيار الضيوف في صفحة إنشاء الحجز
        if (selectedUnit.isHasAdults || selectedUnit.isHasChildren) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.darkCard.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  children: [
                    if (selectedUnit.isHasAdults)
                      GuestSelectorWidget(
                        label: 'البالغين',
                        count: adults,
                        minCount: 1,
                        maxCount: adultsMax,
                        enabled: true,
                        onChanged: (count) {
                          HapticFeedback.selectionClick();
                          final updatedValues = Map<String, dynamic>.from(
                              state.dynamicFieldValues);
                          updatedValues['adults'] = count;
                          context.read<HomeBloc>().add(
                                UpdateDynamicFieldValuesEvent(
                                    values: updatedValues),
                              );
                        },
                      ),
                    if (selectedUnit.isHasAdults && selectedUnit.isHasChildren)
                      const SizedBox(height: 10),
                    if (selectedUnit.isHasChildren)
                      GuestSelectorWidget(
                        label: 'الأطفال',
                        subtitle: '(أقل من 12 سنة)',
                        count: children,
                        minCount: 0,
                        maxCount: childrenMax,
                        enabled: true,
                        onChanged: (count) {
                          HapticFeedback.selectionClick();
                          final updatedValues = Map<String, dynamic>.from(
                              state.dynamicFieldValues);
                          updatedValues['children'] = count;
                          context.read<HomeBloc>().add(
                                UpdateDynamicFieldValuesEvent(
                                    values: updatedValues),
                              );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  int _resolveGuestMax(
    UnitType unit, {
    required List<String> fieldNameCandidates,
    required int defaultMax,
  }) {
    int? maxFromField;

    for (final field in unit.fields) {
      final fieldName = field.fieldName.toLowerCase();
      final matches = fieldNameCandidates.any(
        (candidate) => fieldName == candidate || fieldName.contains(candidate),
      );
      if (!matches) continue;

      final dynamic rawMax = field.validationRules['max'] ??
          field.validationRules['maxValue'] ??
          field.fieldOptions['max'] ??
          field.fieldOptions['maxValue'];

      final parsedMax = _toPositiveInt(rawMax);
      if (parsedMax != null && parsedMax > 0) {
        maxFromField = parsedMax;
        break;
      }
    }

    if (maxFromField != null) {
      return maxFromField > defaultMax ? maxFromField : defaultMax;
    }

    if (unit.maxCapacity > defaultMax) {
      return unit.maxCapacity;
    }

    return defaultMax;
  }

  int? _toPositiveInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value > 0 ? value : null;
    if (value is double) {
      final v = value.round();
      return v > 0 ? v : null;
    }
    if (value is String) {
      final v = int.tryParse(value.trim());
      if (v != null && v > 0) return v;
      final dv = double.tryParse(value.trim());
      if (dv != null) {
        final rounded = dv.round();
        return rounded > 0 ? rounded : null;
      }
    }
    return null;
  }

  Widget _buildExploreOnlySection(HomeLoaded state) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutExpo,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withOpacity(0.05),
            AppTheme.primaryPurple.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'كل شيء جاهز!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ابدأ البحث عن العقار المثالي',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildCompactExploreButton(state),
        ],
      ),
    );
  }

  Widget _buildDynamicFieldsHeader(UnitType selectedUnit) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryPurple.withOpacity(0.2),
                AppTheme.primaryCyan.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.primaryPurple.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Icon(
            Icons.tune_rounded,
            size: 16,
            color: AppTheme.primaryPurple.withOpacity(0.9),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تخصيص البحث',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'حدد تفضيلاتك للعثور على ${selectedUnit.name} المثالي',
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        // مؤشر متحرك
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryCyan.withOpacity(
                  0.5 + 0.3 * _pulseAnimation.value,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryCyan.withOpacity(
                      0.3 * _pulseAnimation.value,
                    ),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDynamicFieldsSection() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) return const SizedBox.shrink();

        // تحقق من وجود نوع وحدة محدد
        if (state.selectedUnitTypeId == null ||
            state.selectedPropertyTypeId == null) {
          return const SizedBox.shrink();
        }

        final unitTypes = state.unitTypes[state.selectedPropertyTypeId] ?? [];

        // تحقق من وجود أنواع وحدات
        if (unitTypes.isEmpty) {
          return const SizedBox.shrink();
        }

        // استخدام firstWhere مع معالجة الخطأ بشكل صحيح
        UnitType? selectedUnit;
        try {
          selectedUnit = unitTypes.firstWhere(
            (u) => u.id == state.selectedUnitTypeId,
          );
        } catch (e) {
          // في حالة عدم العثور على الوحدة المحددة
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutExpo,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkCard.withOpacity(0.3),
                AppTheme.darkSurface.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان القسم
                    _buildDynamicFieldsHeader(selectedUnit),

                    const SizedBox(height: 16),

                    // حقول التاريخ والضيوف
                    _buildHomeUnitInlineFilters(selectedUnit, state),

                    const SizedBox(height: 20),

                    // زر الاستكشاف
                    _buildExploreNowButton(unitTypes, state),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExploreNowButton(List<UnitType> unitTypes, HomeLoaded state) {
    // التحقق من وجود أنواع وحدات
    if (unitTypes.isEmpty || state.selectedUnitTypeId == null) {
      return const SizedBox.shrink();
    }

    // البحث عن الوحدة المحددة بشكل آمن
    UnitType? selectedUnit;
    try {
      selectedUnit = unitTypes.firstWhere(
        (u) => u.id == state.selectedUnitTypeId,
      );
    } catch (e) {
      return const SizedBox.shrink();
    }

    // Dates and guests validation
    final df = state.dynamicFieldValues;
    final DateTime? checkIn =
        df['checkIn'] is DateTime ? df['checkIn'] as DateTime : null;
    final DateTime? checkOut =
        df['checkOut'] is DateTime ? df['checkOut'] as DateTime : null;
    final int adults = (df['adults'] as int?) ?? 0;
    final int children = (df['children'] as int?) ?? 0;
    final bool datesOk = checkIn != null && checkOut != null;
    bool guestsOk = true;
    if (selectedUnit.isHasAdults || selectedUnit.isHasChildren) {
      guestsOk = (!selectedUnit.isHasAdults || adults >= 1) &&
          (!selectedUnit.isHasChildren || children >= 0);
    }

    final bool canShow = state.selectedPropertyTypeId != null &&
        state.selectedUnitTypeId != null &&
        datesOk &&
        guestsOk;

    if (!canShow) {
      // عرض رسالة توضيحية عند عدم استيفاء الشروط
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.warning.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: AppTheme.warning.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'يرجى ملء جميع الحقول المطلوبة للمتابعة',
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.warning.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // عرض نفس تصميم مربع "كل شيء جاهز" مع زر استكشاف صغير وأنيق
    return _buildExploreOnlySection(state);
  }

  Widget _buildSectionsContent() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const SectionLoadingWidget();
        }

        if (state is HomeLoaded) {
          // if (state.sections.isEmpty) {
          //   return const HeroBanner();
          // }

          return Column(
            children: state.sections.map((section) {
              final sectionData = state.sectionData[section.id];

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SectionVisibilityDetector(
                  sectionId: section.id,
                  child: BaseSectionWidget(
                    section: section,
                    data: sectionData,
                    isLoadingMore:
                        state.sectionsLoadingMore[section.id] ?? false,
                    onViewAll: () => _navigateToSection(section),
                    onItemTap: _navigateToProperty,
                    onLoadMore: () {
                      context.read<HomeBloc>().add(
                            LoadMoreSectionDataEvent(sectionId: section.id),
                          );
                    },
                  ),
                ),
              );
            }).toList(),
          );
        }

        if (state is HomeError) {
          return _buildErrorWidget(state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.error.withOpacity(0.1),
            AppTheme.error.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppTheme.error.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.error.withOpacity(0.7),
                  AppTheme.error.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleRefresh,
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
          ),
        ],
      ),
    );
  }

  // Navigation methods
  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    context.read<HomeBloc>().add(const RefreshHomeDataEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _handleSearch(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isNotEmpty) {
      context.push('/search', extra: {
        'searchTerm': normalizedQuery,
      });
    }
  }

  void _handleQuickFilter(String type) {
    HapticFeedback.lightImpact();
    // Handle quick filter selection
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutExpo,
    );
  }

  void _openFilters() {
    HapticFeedback.mediumImpact();
    // Open filters modal
  }

  Future<void> _openCitySelector() async {
    HapticFeedback.lightImpact();
    final selected = await CitySelectorDialog.show(context);
    if (!mounted) return;
    if (selected != null && selected.isNotEmpty) {
      setState(() {}); // refresh AppBar text via currentLocation getter
      // Reload home data (sections and dependent content) for the new city
      context.read<HomeBloc>().add(const LoadHomeDataEvent(forceRefresh: true));
      // Persist city also in FilterStorageService (merge with existing current filters)
      final fss = GetIt.instance<FilterStorageService>();
      final existing = fss.getCurrentFilters() ?? <String, dynamic>{};
      existing['city'] = selected;
      await fss.saveCurrentFilters(existing);
    }
  }

  void _navigateToSearch() {
    final selectedCity =
        GetIt.instance<LocalStorageService>().getSelectedCity();
    final searchParams = <String, dynamic>{
      if (selectedCity.isNotEmpty) 'city': selectedCity,
    };
    context.push('/search', extra: searchParams);
  }

  void _navigateToNotifications() {
    context.push('/notifications');
  }

  void _navigateToProfile() {
    const SwitchMainTabNotification(4).dispatch(context);
  }

  void _navigateToSection(Section section) {
    context.push('/section/${section.id}', extra: section);
  }

  void _navigateToProperty(String id) {
    context.push('/property/$id');
  }

  Widget _buildPropertyTypesSection() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded || state.propertyTypes.isEmpty) {
          return const SizedBox.shrink();
        }

        return ElegantPropertyTypesSection(
          propertyTypes: state.propertyTypes,
          selectedTypeId: state.selectedPropertyTypeId,
          onTypeSelected: (id) {
            HapticFeedback.selectionClick();
            context.read<HomeBloc>().add(
                  UpdatePropertyTypeFilterEvent(propertyTypeId: id),
                );
          },
        );
      },
    );
  }

  Widget _buildUnitTypesSection() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded || state.selectedPropertyTypeId == null) {
          return const SizedBox.shrink();
        }

        final unitTypes =
            state.unitTypes[state.selectedPropertyTypeId] ?? const [];
        if (unitTypes.isEmpty) {
          return const SizedBox.shrink();
        }

        return ElegantUnitTypesSection(
          unitTypes: unitTypes,
          selectedUnitTypeId: state.selectedUnitTypeId,
          onUnitTypeSelected: (unitTypeId) {
            HapticFeedback.lightImpact();
            context.read<HomeBloc>().add(
                  UpdateUnitTypeSelectionEvent(unitTypeId: unitTypeId),
                );
          },
        );
      },
    );
  }
}

// Advanced Particle Model
class _AdvancedParticle {
  // Marked as late because they are initialized in reset() and constructor before use
  late double x, y, z;
  late double vx, vy, vz;
  late double radius;
  late double opacity;
  late Color color;
  double parallaxOffset = 0;
  late double rotationSpeed;

  _AdvancedParticle() {
    reset();
    rotationSpeed = (math.Random().nextDouble() - 0.5) * 0.01;
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    z = math.Random().nextDouble();
    vx = (math.Random().nextDouble() - 0.5) * 0.001;
    vy = (math.Random().nextDouble() - 0.5) * 0.001;
    vz = (math.Random().nextDouble() - 0.5) * 0.0005;
    radius = math.Random().nextDouble() * 2 + 0.5;
    opacity = math.Random().nextDouble() * 0.3 + 0.1;

    final colors = [
      AppTheme.primaryBlue,
      AppTheme.primaryPurple,
      AppTheme.primaryCyan,
      AppTheme.neonBlue,
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }

  void update(double scrollVelocity) {
    x += vx + (scrollVelocity * 0.00001);
    y += vy - parallaxOffset;
    z += vz;

    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;
    if (z < 0 || z > 1) vz = -vz;
  }
}

// Painters
class _AdvancedParticlePainter extends CustomPainter {
  final List<_AdvancedParticle> particles;
  final double animationValue;
  final double scrollVelocity;

  _AdvancedParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.scrollVelocity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update(scrollVelocity);

      final scale = 0.5 + particle.z * 0.5;
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * scale)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          2 * (1 - particle.z),
        );

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius * scale,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AdvancedWavePainter extends CustomPainter {
  final double waveAnimation;
  final double glowIntensity;
  final double scrollOffset;

  _AdvancedWavePainter({
    required this.waveAnimation,
    required this.glowIntensity,
    required this.scrollOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryBlue.withOpacity(0.03 * glowIntensity),
          AppTheme.primaryPurple.withOpacity(0.02 * glowIntensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, 0);

    for (double x = 0; x <= size.width; x += 10) {
      final y = 50 +
          math.sin((x / size.width * 4 * math.pi) +
                  (waveAnimation * 2 * math.pi) -
                  (scrollOffset * 0.01)) *
              30;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FuturisticGridPainter extends CustomPainter {
  final double rotation;
  final double opacity;
  final double scrollOffset;

  _FuturisticGridPainter({
    required this.rotation,
    required this.opacity,
    required this.scrollOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryBlue.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);
    canvas.translate(-size.width / 2, -size.height / 2);

    const spacing = 30.0;
    final offset = scrollOffset * 0.1 % spacing;

    for (double x = -spacing + offset; x < size.width + spacing; x += spacing) {
      canvas.drawLine(
        Offset(x, -size.height),
        Offset(x, size.height * 2),
        paint,
      );
    }

    for (double y = -spacing + offset;
        y < size.height + spacing;
        y += spacing) {
      canvas.drawLine(
        Offset(-size.width, y),
        Offset(size.width * 2, y),
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PropertyTypesBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _PropertyTypesBarDelegate({
    required this.child,
    this.height = 56.0,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: height,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PropertyTypesBarDelegate oldDelegate) {
    return child != oldDelegate.child || height != oldDelegate.height;
  }
}
