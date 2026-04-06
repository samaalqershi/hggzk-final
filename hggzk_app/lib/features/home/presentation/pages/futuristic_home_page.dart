// lib/features/home/presentation/pages/futuristic_home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hggzk/features/home/presentation/widgets/futuristic_home_app_bar.dart';
import 'package:hggzk/features/home/presentation/widgets/premium_property_types_bar.dart';
import 'package:hggzk/features/home/presentation/widgets/refresh_indicator_widget.dart';
import 'package:hggzk/features/home/presentation/widgets/section_loading_widget.dart';
import 'package:hggzk/features/home/presentation/widgets/section_visibility_detector.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:hggzk/core/localization/locale_manager.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../domain/entities/section.dart';
import '../../domain/entities/unit_type.dart';
import '../../../reference/presentation/widgets/city_selector_dialog.dart';
import 'package:hggzk/core/services/local_storage_service.dart';
import 'package:hggzk/core/services/filter_storage_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hggzk/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:hggzk/features/settings/presentation/bloc/settings_state.dart';
import '../widgets/sections/base_section_widget.dart';
import 'package:hggzk/app/navigation/switch_main_tab_notification.dart';
import '../../../booking/presentation/widgets/date_picker_widget.dart';
import '../../../booking/presentation/widgets/guest_selector_widget.dart';

/// تمثل الصفحة الرئيسية للتطبيق، وتجمع بين أدوات التصفح السريعة والفلاتر
/// والأقسام الديناميكية داخل تجربة بصرية واحدة متدرجة.
/// Represents the app's home screen, combining quick browsing tools, filters,
/// and dynamic sections inside one layered visual experience.
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Arabic: متحكمات الحركة التي تقود الخلفية والمحتوى والتوهج.
  // English: Animation controllers that drive the background, content, and
  // glow effects.
  late AnimationController _backgroundAnimationController;
  late AnimationController _particlesAnimationController;
  late AnimationController _glowAnimationController;
  late AnimationController _contentAnimationController;
  late AnimationController _waveAnimationController;

  // Arabic: الحركات المشتقة من المتحكمات السابقة.
  // English: Animations derived from the controllers above.
  late Animation<double> _backgroundRotationAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _waveAnimation;

  // Arabic: أدوات التمرير والجسيمات التي تصنع العمق البصري.
  // English: Scroll and particle tooling that creates visual depth.
  final ScrollController _scrollController = ScrollController();
  final List<_AdvancedParticle> _particles = [];
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();
  final GlobalKey _dynamicFieldsSectionKey = GlobalKey();

  // Arabic: حالة الظهور التفاعلي داخل الصفحة الرئيسية.
  // English: Interactive state used within the home screen.
  bool _showFloatingSearch = false;
  double _scrollOffset = 0;
  double _scrollVelocity = 0;
  DateTime _lastScrollTime = DateTime.now();
  late String _activeLanguageCode;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  /// يهيئ الحركات الأولية ويؤخر التحميل قليلًا حتى يظهر الانتقال الافتتاحي
  /// بسلاسة قبل بدء جلب البيانات.
  /// Initializes the opening animations and delays data loading slightly so
  /// the entrance transition remains smooth before fetching begins.
  @override
  void initState() {
    super.initState();

    _initializeAnimations();
    _generateAdvancedParticles();
    _setupScrollListener();
    _startAnimations();
    _activeLanguageCode = LocaleManager.getCurrentLocale().languageCode;

    // Arabic: نؤخر التحميل قليلًا حتى لا يقطع ظهور الحركات الافتتاحية.
    // English: Delay loading slightly so the entrance animation remains smooth.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<HomeBloc>().add(const LoadHomeDataEvent());
      }
    });
  }

  /// يبني تنبيهًا يوضح للمستخدم أن التواريخ المخزنة أصبحت قديمة وتم تجاهلها
  /// إلى أن يختار تواريخ جديدة.
  /// Builds a warning that explains when stored dates have gone stale and were
  /// ignored until the user chooses new ones.
  Widget _buildExpiredDatesWarning(BuildContext context) {
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
                  context.tr('home.savedDatesWarningTitle'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('home.savedDatesWarningBody'),
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

  /// يهيئ مجموعة الحركات التي تمنح الصفحة عمقها البصري وتدرج ظهور محتواها.
  /// Sets up the animation suite that gives the page its depth and staged
  /// content reveal.
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

  /// ينشئ الجسيمات الخلفية المستخدمة لإضافة عمق وحركة مستمرة إلى الصفحة.
  /// Creates the background particles used to add depth and continuous motion
  /// to the page.
  void _generateAdvancedParticles() {
    for (int i = 0; i < 30; i++) {
      _particles.add(_AdvancedParticle());
    }
  }

  /// يربط التمرير بخصائص الواجهة التفاعلية مثل سرعة الحركة وظهور شريط البحث
  /// وتأثير البارالاكس على الجسيمات.
  /// Connects scrolling to interactive UI properties such as motion velocity,
  /// floating-search visibility, and particle parallax.
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

      // Arabic: نحرك الجسيمات بنسبة بسيطة لتوليد parallax.
      // English: Move particles slightly to create a parallax effect.
      for (var particle in _particles) {
        particle.parallaxOffset = _scrollOffset * 0.001;
      }
    });
  }

  /// يطلق حركة إظهار المحتوى الرئيسي بعد اكتمال الافتتاحية الأولى للصفحة.
  /// Starts the main content reveal once the initial page entrance has settled.
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
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override

  /// يبني الهيكل العام للصفحة مع الخلفية المتحركة والمحتوى القابل للتمرير
  /// وشريط البحث العائم.
  /// Builds the overall page shell with the animated background, scrollable
  /// content, and floating search affordance.
  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        String? nextLanguageCode;
        if (state is SettingsLoaded) {
          nextLanguageCode = state.settings.preferredLanguage;
        } else if (state is SettingsUpdated) {
          nextLanguageCode = state.settings.preferredLanguage;
        }

        if (nextLanguageCode != null &&
            nextLanguageCode != _activeLanguageCode) {
          _activeLanguageCode = nextLanguageCode;
          context
              .read<HomeBloc>()
              .add(const LoadHomeDataEvent(forceRefresh: true));
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Stack(
          children: [
            // Arabic: الخلفية المتقدمة المتحركة.
            // English: Advanced animated background.
            _buildAdvancedBackground(),

            // Arabic: جسيمات عائمة مع parallax.
            // English: Floating particles with parallax.
            _buildAdvancedParticles(),

            // Arabic: المحتوى الرئيسي.
            // English: Main content.
            _buildMainContent(),

            // Arabic: شريط البحث العائم.
            // English: Floating search bar.
            _buildFloatingSearchBar(),
          ],
        ),
      ),
    );
  }

  /// يبني الطبقات الخلفية الزخرفية التي تمنح الصفحة مظهرها الموجي والشبكي.
  /// Builds the decorative background layers responsible for the wave and grid
  /// look.
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
              // Arabic: طبقة الموجة.
              // English: Wave overlay.
              CustomPaint(
                painter: _AdvancedWavePainter(
                  waveAnimation: _waveAnimation.value,
                  glowIntensity: _glowAnimationController.value,
                  scrollOffset: _scrollOffset,
                ),
                size: Size.infinite,
              ),

              // Arabic: نمط الشبكة.
              // English: Grid pattern.
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

  /// يبني طبقة الجسيمات المتحركة التي تطفو فوق الخلفية الأساسية.
  /// Builds the moving particle layer that floats above the primary
  /// background.
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

  /// يبني منطقة المحتوى الرئيسية، بما فيها شريط التطبيق والمحتوى المتدرج
  /// داخل `CustomScrollView`.
  /// Builds the main content region, including the app bar and staged content
  /// inside a `CustomScrollView`.
  Widget _buildMainContent() {
    return FuturisticRefreshIndicator(
      key: _refreshKey,
      onRefresh: _handleRefresh,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          // Arabic: نبني الـ slivers بشكل شرطي بحسب الحالة.
          // English: Build slivers conditionally based on state.
          final slivers = <Widget>[];

          // Arabic: نضيف شريط التطبيق دائمًا.
          // English: Always add the app bar.
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

          if (state is HomeLoaded && state.propertyTypes.isNotEmpty) {
            final hasUnits = state.selectedPropertyTypeId != null &&
                (state.unitTypes[state.selectedPropertyTypeId] ?? const [])
                    .isNotEmpty;
            final double headerHeight = hasUnits ? 104.0 : 56.0;

            slivers.add(
              SliverPersistentHeader(
                pinned: true,
                delegate: _PropertyTypesBarDelegate(
                  height: headerHeight,
                  child: PremiumPropertyTypesBar(
                    propertyTypes: state.propertyTypes,
                    selectedTypeId: state.selectedPropertyTypeId,
                    onTypeSelected: (id) {
                      HapticFeedback.selectionClick();
                      context.read<HomeBloc>().add(
                            UpdatePropertyTypeFilterEvent(propertyTypeId: id),
                          );
                    },
                    onUnitTypeSelected: (unitTypeId) {
                      HapticFeedback.lightImpact();
                      context.read<HomeBloc>().add(
                            UpdateUnitTypeSelectionEvent(
                              unitTypeId: unitTypeId,
                            ),
                          );
                      _revealDynamicFieldsSection();
                    },
                    scrollOffset: _scrollOffset,
                  ),
                ),
              ),
            );
          }

          // Arabic: نضيف المحتوى الرئيسي.
          // English: Add the main content.
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

  /// يبني شريط البحث العائم الذي يظهر بعد تجاوز مسافة تمرير كافية.
  /// Builds the floating search bar that appears after the user scrolls far
  /// enough down the page.
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

  /// يبني النسخة المضغوطة من الشريط العائم والمثبتة أعلى الشاشة.
  /// Builds the compact version of the floating bar pinned at the top of the
  /// screen.
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
                  // Arabic: زر العودة إلى أعلى الصفحة.
                  // English: Back-to-top button.
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

  Widget _buildContent() {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1200;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          _buildExpiredDatesWarning(context),
          const SizedBox(height: 20),
          _buildDynamicFieldsSection(),
          const SizedBox(height: 20),
          _buildSectionsContent(),
          _buildConditionalFooter(isDesktop, isTablet),
          const SizedBox(height: 16),
        ],
      ),
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
                // Arabic: قسم الشعار المحسن.
                // English: Enhanced logo section.
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
                            // Arabic: ظل أقوى للشعار.
                            // English: Stronger logo shadow.
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
                      // Arabic: قسم الحقوق المحسن.
                      // English: Enhanced copyright section.
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
                            context.tr('home.copyrightCompany'),
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
                        context.tr('home.copyrightAllRightsReserved'),
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppTheme.textLight
                                  .withOpacity(0.8) // ✅ زيادة من 0.5
                              : AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Arabic: رقم الهاتف بتنسيق أوضح.
                      // English: Phone number with clearer formatting.
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
                            // Arabic: ظل إضافي لتحسين الوضوح.
                            // English: Extra shadow for readability.
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

  Widget _buildCompactExploreButton(HomeLoaded state) {
    // Arabic: نحسب إمكانية التفعيل بناءً على التواريخ والضيوف والحقول
    // المطلوبة.
    // English: Compute enablement from dates, guests, and required fields.
    final selectedUnitId = state.selectedUnitTypeId;
    final unitTypes = state.selectedPropertyTypeId != null
        ? state.unitTypes[state.selectedPropertyTypeId] ?? const <UnitType>[]
        : const <UnitType>[];
    if (selectedUnitId == null) {
      return const SizedBox.shrink();
    }

    final hasSelectedUnit = unitTypes.any((u) => u.id == selectedUnitId);
    if (!hasSelectedUnit) {
      return const SizedBox.shrink();
    }

    final selectedUnit = unitTypes.firstWhere((u) => u.id == selectedUnitId);

    final df = Map<String, dynamic>.from(state.dynamicFieldValues);
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
    // لم نعد نعتبر الحقول الديناميكية شرطاً لتفعيل زر الاستكشاف
    bool fieldsOk = true;

    final bool isEnabled = datesOk && guestsOk && fieldsOk;

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

                  params['checkIn'] = checkIn.toIso8601String();
                  params['checkOut'] = checkOut.toIso8601String();
                  // لا تمرر guestsCount لأنواع الوحدات التي لا تدعم بالغين/أطفال
                  final bool supportsGuests =
                      selectedUnit.isHasAdults || selectedUnit.isHasChildren;
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
                  context.tr('home.explore'),
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
                    label: context.tr('home.checkIn'),
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
                    label: context.tr('home.checkOut'),
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
                        label: context.tr('home.adults'),
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
                        label: context.tr('home.children'),
                        subtitle: context.tr('home.childrenUnder12'),
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
                  context.tr('home.allReadyTitle'),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('home.allReadySubtitle'),
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
                context.tr('home.customizeSearch'),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.tr(
                  'home.idealPropertyHint',
                  params: {'unitName': selectedUnit.name},
                ),
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

        final selectedUnitId = state.selectedUnitTypeId;
        if (selectedUnitId == null) {
          return const SizedBox.shrink();
        }

        final hasSelectedUnit = unitTypes.any((u) => u.id == selectedUnitId);
        if (!hasSelectedUnit) {
          return const SizedBox.shrink();
        }

        final selectedUnit =
            unitTypes.firstWhere((u) => u.id == selectedUnitId);

        return Container(
          key: _dynamicFieldsSectionKey,
          child: AnimatedContainer(
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
                      _buildDynamicFieldsHeader(selectedUnit),
                      const SizedBox(height: 16),
                      _buildHomeUnitInlineFilters(selectedUnit, state),
                      const SizedBox(height: 20),
                      _buildExploreNowButton(unitTypes, state),
                    ],
                  ),
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
    final selectedUnitId = state.selectedUnitTypeId;
    final hasSelectedUnit =
        selectedUnitId != null && unitTypes.any((u) => u.id == selectedUnitId);
    if (!hasSelectedUnit) {
      return const SizedBox.shrink();
    }
    final selectedUnit = unitTypes.firstWhere((u) => u.id == selectedUnitId);

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

    final bool canShow = datesOk && guestsOk;

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
                context.tr('home.fillRequiredFields'),
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.warning.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Arabic: نعرض بطاقة جاهزية صغيرة مع زر استكشاف أنيق.
    // English: Show a compact readiness card with a neat explore button.
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
                        context.tr('home.retry'),
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

  // Arabic: أساليب التنقل داخل الصفحة الرئيسية.
  // English: Navigation methods for the home flow.
  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    context.read<HomeBloc>().add(const RefreshHomeDataEvent());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutExpo,
    );
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

  void _revealDynamicFieldsSection() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      final targetContext = _dynamicFieldsSectionKey.currentContext;
      if (targetContext == null) return;
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutExpo,
        alignment: 0.08,
      );
    });
  }
}

// Arabic: نموذج الجسيمات المتقدمة.
// English: Advanced particle model.
class _AdvancedParticle {
  // Arabic: متأخر لأن قيمه تتهيأ في reset() أو عند الإنشاء قبل الاستخدام.
  // English: Marked late because the values are initialized in reset() or the
  // constructor before use.
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

// Arabic: الرسامون المسؤولون عن الخلفيات والتأثيرات.
// English: Painters responsible for the backgrounds and effects.
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
