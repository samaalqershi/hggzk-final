// lib/app/presentation/pages/main_shell_page.dart

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hggzk/core/constants/route_constants.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:hggzk/core/theme/app_text_styles.dart';
import 'package:hggzk/core/theme/app_theme.dart';
import 'package:hggzk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hggzk/features/auth/presentation/bloc/auth_state.dart';
import 'package:hggzk/features/auth/presentation/pages/profile_page.dart';
import 'package:hggzk/features/booking/presentation/pages/my_bookings_page.dart';
import 'package:hggzk/features/chat/presentation/pages/conversations_page.dart';
import 'package:hggzk/features/favorites/presentation/pages/favorites_page.dart';
import 'package:hggzk/features/home/presentation/pages/futuristic_home_page.dart';
import 'package:hggzk/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:hggzk/features/notifications/presentation/bloc/notification_event.dart';

import 'package:hggzk/app/navigation/switch_main_tab_notification.dart';

/// غلاف التنقل الرئيسي الذي يربط التبويبات الأساسية بعد تسجيل الدخول.
/// Main authenticated shell that keeps the core tabs and their navigation state alive.
class MainScreen extends StatefulWidget {
  /// يحدد التبويب الافتراضي عند الدخول إلى الشِل لأول مرة.
  /// Determines which tab should be shown when the shell opens.
  final int initialTabIndex;

  /// يبني شاشة الشِل مع تحديد تبويب البداية مسبقًا.
  /// Builds the shell screen and seeds the initial tab selection.
  const MainScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  /// ينشئ كائن الحالة الذي يدير التنقل والرسوم المتحركة داخل الشِل.
  /// Builds the state object that coordinates tab navigation and animations.
  @override
  State<MainScreen> createState() => _MainScreenState();
}

/// يدير مزامنة الصفحة الحالية وحركة الشريط السفلي مع حالة الدخول.
/// State object that keeps the current tab, animations, and auth guard in sync.
class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  /// يحتفظ بالتبويب الظاهر حاليًا داخل الشِل.
  /// Tracks the currently visible tab inside the shell.
  int _currentIndex = 0;

  /// يتحكم في التنقل البرمجي بين صفحات التبويبات.
  /// Controls programmatic navigation between tab pages.
  late PageController _pageController;

  /// يلمع خط التوهج السفلي ليمنح الشريط السفلي حضورًا حيًا.
  /// Drives the subtle glow that keeps the bottom shell visually alive.
  late AnimationController _glowAnimationController;

  /// يحرك الجزيئات الزخرفية التي تدعم طابع الواجهة المستقبلي.
  /// Animates the decorative particles used to reinforce the futuristic feel.
  late AnimationController _particleAnimationController;

  /// يقود موجة الخلفية التي تتبع التبويب النشط.
  /// Controls the background wave that follows the active tab.
  late AnimationController _waveAnimationController;

  /// يضبط النبض الدوري لعناصر التنقل المختارة.
  /// Pulses the selected navigation elements on a loop.
  late AnimationController _pulseAnimationController;

  /// قيمة حركة التوهج المتدرجة.
  /// Animated value that drives the glow intensity.
  late Animation<double> _glowAnimation;

  /// قيمة حركة الموجة في الخلفية.
  /// Animated value for the background wave movement.
  late Animation<double> _waveAnimation;

  /// قيمة النبض التي تُطبّق على العناصر النشطة.
  /// Pulse value applied to the active item treatment.
  late Animation<double> _pulseAnimation;

  /// يملك متحكمات الحركة الخاصة بكل عنصر تنقل على حدة.
  /// Holds one animation controller per navigation item.
  final Map<int, AnimationController> _itemAnimations = {};

  /// يحتفظ بقيم التكبير المستخدمة عند تمييز العنصر النشط.
  /// Keeps one scale animation per tab so the active destination can grow subtly
  /// without rebuilding the rest of the shell.
  final Map<int, Animation<double>> _itemScaleAnimations = {};

  /// يعرض الصفحات الأربع الأساسية داخل shell مع بقاء كل صفحة في
  /// مكانها عبر التنقل بين التبويبات.
  /// Exposes the four core shell pages while preserving state across
  /// tab switches.
  List<Widget> get _pages => [
        const NavigationPage(child: HomePage()),
        const NavigationPage(child: FavoritesPage()),
        const NavigationPage(child: MyBookingsPage()),
        const NavigationPage(child: ConversationsPage()),
        const NavigationPage(child: ProfilePage()),
      ];
  List<_NavItem> get _navItems => [
        _NavItem(
          icon: Icons.home_rounded,
          activeIcon: Icons.home_rounded,
          labelKey: 'nav.home',
          gradient: LinearGradient(
            colors: [AppTheme.primaryCyan, AppTheme.primaryBlue],
          ),
        ),
        _NavItem(
          icon: Icons.explore_outlined,
          activeIcon: Icons.explore_rounded,
          labelKey: 'nav.favorites',
          gradient: LinearGradient(
            colors: [AppTheme.neonBlue, AppTheme.primaryPurple],
          ),
        ),
        _NavItem(
          icon: Icons.calendar_today_outlined,
          activeIcon: Icons.calendar_month_rounded,
          labelKey: 'nav.myBookings',
          gradient: LinearGradient(
            colors: [AppTheme.primaryPurple, AppTheme.neonPurple],
          ),
        ),
        _NavItem(
          icon: Icons.chat_bubble_outline_rounded,
          activeIcon: Icons.chat_bubble_rounded,
          labelKey: 'nav.chat',
          gradient: LinearGradient(
            colors: [AppTheme.primaryBlue, AppTheme.neonBlue],
          ),
        ),
        _NavItem(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          labelKey: 'nav.account',
          gradient: LinearGradient(
            colors: [AppTheme.primaryViolet, AppTheme.neonPurple],
          ),
        ),
      ];

  /// يجهز متحكمات التنقل والرسوم ثم يطبق قيد الدخول قبل عرض المحتوى.
  /// Prepares controllers, animations, and the auth guard before content becomes visible.
  @override
  void initState() {
    super.initState();
    // If we have initial search params, start on the Search tab (index 1)
    // if (widget.initialSearchParams != null) {
    //   _currentIndex = 1;
    // }
    _currentIndex = widget.initialTabIndex;
    _initializeControllers();
    _initializeAnimations();
    _startAnimations();

    // Load notifications only for authenticated users to avoid 401->force logout->login navigation on app start
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<NotificationBloc>().add(const LoadNotificationsEvent());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureInitialTabAuthGuard();
    });
  }

  /// يمنع الضيف من البقاء في تبويب خاص ويعيده إلى المسار المناسب.
  /// Forces unauthenticated users back to the public tab and login flow.
  void _ensureInitialTabAuthGuard() {
    if (_currentIndex == 0) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) return;

    // Guest mode: keep user on Home and open official login directly
    setState(() {
      _currentIndex = 0;
    });
    _pageController.jumpToPage(0);
    _openLoginForTab(widget.initialTabIndex);
  }

  /// يعيد المستخدم إلى صفحة الدخول مع الاحتفاظ بمعرفة التبويب المطلوب.
  /// Opens the login screen while preserving the tab the user tried to reach.
  void _openLoginForTab(int tabIndex) {
    final from = Uri.encodeComponent('${RouteConstants.main}?tab=$tabIndex');
    context.push('${RouteConstants.login}?from=$from');
  }

  /// يخلق متحكمات الصفحة والرسوم المتحركة التي يقودها الشريط السفلي.
  /// Builds the page and animation controllers used by the bottom navigation shell.
  void _initializeControllers() {
    _pageController = PageController(initialPage: _currentIndex);

    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _waveAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Initialize item animations
    for (int i = 0; i < _navItems.length; i++) {
      _itemAnimations[i] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );

      _itemScaleAnimations[i] = Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _itemAnimations[i]!,
        curve: Curves.easeOutBack,
      ));
    }
  }

  /// يحول المتحكمات إلى منحنيات حركة قابلة لإعادة الاستخدام في الواجهة.
  /// Converts controllers into the animation curves consumed by the UI.
  void _initializeAnimations() {
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowAnimationController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveAnimationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  /// يبدأ الحلقات المرئية للحياة عند فتح الشِل.
  /// Starts the repeating visual motion that gives the shell its active feel.
  void _startAnimations() {
    _glowAnimationController.repeat(reverse: true);
    _particleAnimationController.repeat();
    _waveAnimationController.repeat();
    _pulseAnimationController.repeat(reverse: true);

    // Start initial item animation
    Future.delayed(const Duration(milliseconds: 100), () {
      for (int i = 0; i < _navItems.length; i++) {
        Future.delayed(Duration(milliseconds: i * 50), () {
          if (mounted) {
            _itemAnimations[i]?.forward();
          }
        });
      }
    });
  }

  /// Releases the resources used by this instance.
  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _pageController.dispose();
    _glowAnimationController.dispose();
    _particleAnimationController.dispose();
    _waveAnimationController.dispose();
    _pulseAnimationController.dispose();

    for (var controller in _itemAnimations.values) {
      controller.dispose();
    }

    super.dispose();
  }

  /// Processes the `onTabTapped` flow and maps it into the app-level behavior.
  /// العربية: يعالج `onTabTapped`.
  void _onTabTapped(int index) {
    if (index != 0) {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        _openLoginForTab(index);
        return;
      }
    }
    if (_currentIndex != index) {
      // Haptic feedback
      HapticFeedback.lightImpact();

      setState(() {
        _currentIndex = index;
      });

      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutExpo,
      );
    }
  }

  /// Builds the widget tree for this component.
  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return NotificationListener<SwitchMainTabNotification>(
      onNotification: (notification) {
        _onTabTapped(notification.index);
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        extendBody: true,
        body: Stack(
          children: [
            // Pages with gesture support
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              physics: const NeverScrollableScrollPhysics(),
              children: _pages,
            ),

            // Futuristic bottom navigation
            Positioned(
              right: 16,
              bottom: 86 + MediaQuery.of(context).viewPadding.bottom,
              child: _buildAiAssistantLauncher(),
            ),

            // Futuristic bottom navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildFuturisticBottomBar(),
            ),
          ],
        ),
      ),
    );
  }

  /// يبني الشريط السفلي المستقبلي مع الخلفية الزجاجية والموجة وخط
  /// التوهج وأزرار التنقل.
  /// Builds the futuristic bottom bar with glass background, wave,
  /// glow line, and navigation items.
  Widget _buildFuturisticBottomBar() {
    // حساب الارتفاع الكلي بشكل ديناميكي يشمل SafeArea
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final totalHeight = 75.0 + bottomPadding;

    return Container(
      height: totalHeight,
      child: Stack(
        children: [
          // Glass morphism background
          _buildGlassBackground(totalHeight),

          // Wave effect
          _buildWaveEffect(totalHeight),

          // Glow line
          _buildGlowLine(),

          // Navigation items
          _buildNavigationItems(),
        ],
      ),
    );
  }

  /// يفتح مساعد الذكاء الاصطناعي، أو يرسل المستخدم إلى تسجيل الدخول
  /// إذا لم يكن لديه جلسة صالحة.
  /// Opens the AI assistant, or redirects to login when no valid
  /// session exists.
  void _openAiAssistant() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      final from = Uri.encodeComponent(RouteConstants.aiAssistant);
      context.push('${RouteConstants.login}?from=$from');
      return;
    }

    context.push(RouteConstants.aiAssistant);
  }

  /// يبني زر تشغيل مساعد الذكاء الاصطناعي بوصفه اختصارًا سريعًا.
  /// Builds the quick-launch button for the AI assistant.
  Widget _buildAiAssistantLauncher() {
    return GestureDetector(
      onTap: _openAiAssistant,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              AppTheme.primaryBlue,
              AppTheme.primaryPurple,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.smart_toy_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  /// يرسم الخلفية الزجاجية أسفل الشريط السفلي ليظهر أكثر عمقًا.
  /// Draws the frosted background behind the bottom bar for visual depth.
  Widget _buildGlassBackground(double totalHeight) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: totalHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.darkCard.withOpacity(0.7),
                  AppTheme.darkSurface.withOpacity(0.9),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// يرسم الموجة المتحركة التي تابعة للعنصر النشط لتوضيح الموقع الحالي.
  /// Draws the animated wave that tracks the active item and reinforces
  /// the user's location.
  Widget _buildWaveEffect(double totalHeight) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          return CustomPaint(
            size: Size(double.infinity, totalHeight),
            painter: _WaveEffectPainter(
              animation: _waveAnimation.value,
              currentIndex: _currentIndex,
              itemColors: _navItems.map((e) => e.gradient.colors[0]).toList(),
            ),
          );
        },
      ),
    );
  }

  /// يضيف خط توهج علوي يغيّر لونه تبعًا للتبويب المختار.
  /// Adds a top glow line whose color shifts with the selected tab.
  Widget _buildGlowLine() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _navItems[_currentIndex].gradient.colors[0].withOpacity(
                        0.3 + (_glowAnimation.value * 0.4),
                      ),
                  _navItems[_currentIndex].gradient.colors[1].withOpacity(
                        0.3 + (_glowAnimation.value * 0.4),
                      ),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: _navItems[_currentIndex]
                      .gradient
                      .colors[0]
                      .withOpacity(0.5),
                  blurRadius: 10 + (_glowAnimation.value * 5),
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// يوزع عناصر التنقل الأساسية بشكل متوازن فوق الشريط السفلي.
  /// Lays out the core navigation items evenly across the bottom bar.
  Widget _buildNavigationItems() {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return Positioned(
      bottom: bottomPadding,
      left: 0,
      right: 0,
      child: Container(
        height: 75,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _navItems.length,
            (index) => _buildCompactNavItem(index),
          ),
        ),
      ),
    );
  }

  /// يبني عنصر تنقل مضغوطًا مع الحالة النشطة والمؤثرات البصرية المرتبطة.
  /// Builds one compact navigation item with its active-state visual treatment.
  Widget _buildCompactNavItem(int index) {
    final isSelected = _currentIndex == index;
    final item = _navItems[index];

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _itemScaleAnimations[index]!,
          _pulseAnimation,
          _glowAnimation,
        ]),
        builder: (context, child) {
          final scale = _itemScaleAnimations[index]!.value *
              (isSelected ? _pulseAnimation.value : 1.0);

          return Transform.scale(
            scale: scale,
            child: Container(
              width: 60,
              height: 75,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with effects
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Glow effect
                      if (isSelected)
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                item.gradient.colors[0].withOpacity(
                                  0.3 * _glowAnimation.value,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                      // Icon container
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 36 : 32,
                        height: isSelected ? 36 : 32,
                        decoration: BoxDecoration(
                          gradient: isSelected ? item.gradient : null,
                          color: !isSelected ? Colors.transparent : null,
                          borderRadius:
                              BorderRadius.circular(isSelected ? 12 : 10),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: item.gradient.colors[0]
                                        .withOpacity(0.4),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                    scale: animation, child: child),
                              );
                            },
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  ...previousChildren,
                                  if (currentChild != null) currentChild,
                                ],
                              );
                            },
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              key: ValueKey<String>(
                                  'nav_icon_${index}_${isSelected ? 'active' : 'inactive'}'),
                              size: isSelected ? 20 : 18,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textMuted.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // Label
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: AppTextStyles.caption.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? item.gradient.colors[0]
                          : AppTheme.textMuted.withOpacity(0.6),
                      height: 1.0,
                    ),
                    child: Text(_navLabel(index)),
                  ),

                  // Active indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(top: 2),
                    width: isSelected ? 16 : 0,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: isSelected ? item.gradient : null,
                      borderRadius: BorderRadius.circular(1),
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

  String _navLabel(int index) {
    return context.tr(_navItems[index].labelKey);
  }
}

/// يحمل بيانات عنصر التنقل الواحد في الشريط السفلي بما في ذلك
/// الأيقونة والنسخة النشطة واللون المتدرج.
/// Carries one bottom-bar navigation item, including icon variants and
/// its gradient styling.
class _NavItem {
  /// الأيقونة في حال عدم اختيار العنصر.
  /// Icon shown when the item is inactive.
  final IconData icon;

  /// الأيقونة المستخدمة عندما يكون العنصر نشطًا.
  /// Icon shown when the item is active.
  final IconData activeIcon;

  /// مفتاح الترجمة الذي يحدد النص الظاهر أسفل الأيقونة.
  /// Translation key for the label displayed below the icon.
  final String labelKey;

  /// التدرج اللوني الذي يميّز العنصر النشط.
  /// Gradient used to highlight the active state.
  final LinearGradient gradient;

  /// يثبت بيانات عنصر التنقل كما ستظهر داخل الشريط السفلي.
  /// Builds the immutable data for one shell navigation item.
  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
    required this.gradient,
  });
}

/// يرسم خلفية موجية متحركة تمتد من العنصر النشط لتأكيد الحالة
/// المرئية الحالية.
/// Paints the animated wave backdrop that radiates from the active
/// item and marks the current state.
class _WaveEffectPainter extends CustomPainter {
  /// قيمة الموجة التي تحدد موضع الخلفية المنحنية.
  /// Wave progress value that shapes the curved backdrop.
  final double animation;

  /// فهرس العنصر النشط الذي تنطلق منه الموجة.
  /// Index of the active item that anchors the wave.
  final int currentIndex;

  /// ألوان العناصر التي تغذي التدرج البصري للموجة.
  /// Item colors used to build the wave gradient.
  final List<Color> itemColors;

  /// يهيئ الرسام بقيم الموجة واللون العنصر النشط.
  /// Initializes the painter with wave state and item colors.
  _WaveEffectPainter({
    required this.animation,
    required this.currentIndex,
    required this.itemColors,
  });

  /// يرسم الموجة المتدرجة أسفل الشريط اعتمادًا على موضع التبويب
  /// النشط وحركة المؤشر.
  /// Renders the gradient wave under the bar based on the active tab
  /// and the animation phase.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          itemColors[currentIndex].withOpacity(0.1),
          itemColors[currentIndex].withOpacity(0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final itemWidth = size.width / itemColors.length;
    final centerX = itemWidth * currentIndex + itemWidth / 2;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 5) {
      final distance = (x - centerX).abs();
      final normalizedDistance = distance / (size.width / 2);
      final waveHeight =
          (1 - normalizedDistance) * 15 * math.sin(animation * 2 * math.pi);

      path.lineTo(x, size.height - 20 - waveHeight);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  /// يعيد الرسم دائمًا لأن الموجة تعتمد على حركة مستمرة.
  /// Always repaints because the wave is driven by continuous motion.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// يضيف حشوة سفلية قياسية حتى لا يختبئ محتوى الصفحات خلف الشريط
/// السفلي الثابت.
/// Adds bottom padding so page content remains above the fixed shell
/// navigation bar.
class NavigationPage extends StatelessWidget {
  /// الصفحة أو الواجهة الفرعية التي ستُعرض فوق الحشوة السفلية.
  /// The nested page or view shown above the bottom padding.
  final Widget child;

  /// يلف الصفحة داخل مساحة تمنع التداخل مع شريط التنقل.
  /// Wraps a page in spacing that prevents overlap with the shell bar.
  const NavigationPage({
    super.key,
    required this.child,
  });

  /// يبني الحاوية التي تضمن بقاء المحتوى فوق الشريط السفلي.
  /// Builds the container that keeps content above the shell bar.
  @override
  Widget build(BuildContext context) {
    // Keep page content above the navigation shell.
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final totalBottomPadding = 75.0 + bottomPadding;

    return Padding(
      padding: EdgeInsets.only(bottom: totalBottomPadding),
      child: child,
    );
  }
}
