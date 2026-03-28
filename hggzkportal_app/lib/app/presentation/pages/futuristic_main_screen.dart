// lib/app/presentation/pages/futuristic_main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:hggzkportal/core/theme/app_theme.dart';
import 'package:hggzkportal/features/admin_hub/presentation/pages/admin_hub_page.dart';
import 'package:hggzkportal/features/auth/presentation/pages/profile_page.dart';

/// غلاف تنقل رئيسي يثبت واجهة الإدارة والحساب ضمن هيكل واحد متحرك.
/// Primary shell that keeps the admin hub and profile area inside one animated navigation scaffold.
class MainScreen extends StatefulWidget {
  /// ينشئ الغلاف الرئيسي الذي يضم صفحات التنقل الأساسية في التطبيق.
  /// Creates the main shell that hosts the app's primary navigation pages.
  const MainScreen({super.key});

  @override

  /// ينشئ كائن الحالة الذي يدير الصفحة النشطة وحركات شريط التنقل.
  /// Creates the state object that manages the active page and nav motion.
  State<MainScreen> createState() => _MainScreenState();
}

/// يدير الصفحة النشطة، والانتقال بين التبويبات، وحركات شريط التنقل.
/// Owns the active page, tab transitions, and nav-bar motion state.
class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  /// المؤشر الحالي داخل شريط التنقل السفلي.
  /// The currently selected tab index in the bottom navigation bar.
  int _currentIndex = 0;

  /// يتحكم في الانتقال بين صفحات الغلاف بدون إعادة بناء غير لازمة.
  /// Controls page switching without forcing unnecessary rebuilds.
  late PageController _pageController;

  /// يتحكم في حركة الانتقال الأساسية بين حالات شريط التنقل.
  /// Drives the core transition motion for the navigation bar.
  late AnimationController _navAnimationController;

  /// يدير موجة اللمعان التي تتحرك فوق الشريط السفلي.
  /// Drives the glow sweep that passes over the bottom bar.
  late AnimationController _glowAnimationController;

  /// يدير نبضات العناصر البصرية الدقيقة في الشريط.
  /// Controls the subtle particle motion used by the navigation chrome.
  late AnimationController _particleAnimationController;

  /// يتحكم في حركة الموجة التي تتبع التبويب النشط.
  /// Controls the wave motion that follows the active tab.
  late AnimationController _waveAnimationController;

  /// يطبق حركة النبض على العناصر المختارة لإبرازها بصريًا.
  /// Applies a pulsing motion to selected items for visual emphasis.
  late AnimationController _pulseAnimationController;

  /// القيمة المتحركة التي تحدد شدة اللمعان فوق الشريط.
  /// Animated value that controls the glow intensity above the bar.
  late Animation<double> _glowAnimation;

  /// القيمة المتحركة التي تحدد شكل الموجة المتبدلة مع التبويب النشط.
  /// Animated value that shapes the wave tied to the active tab.
  late Animation<double> _waveAnimation;

  /// القيمة المتحركة التي تضبط مقدار تكبير العنصر النشط.
  /// Animated value that adjusts how much the active item scales.
  late Animation<double> _pulseAnimation;

  /// حركات مستقلة لكل عنصر حتى يمكن إدخال كل تبويب على حدة.
  /// Independent animations per item so each tab can enter separately.
  final Map<int, AnimationController> _itemAnimations = {};

  /// قيم التحجيم الناتجة لكل عنصر لتغذية تأثير الدخول المتدرج.
  /// Derived scale values per item used for the staggered entrance effect.
  final Map<int, Animation<double>> _itemScaleAnimations = {};

  // List<Widget> get _pages => [
  //   const FuturisticHomePage(),
  //   SearchPage(initialParams: widget.initialSearchParams),
  //   const MyBookingsPage(),
  //   const ConversationsPage(),
  //   const ProfilePage(),
  // ];
  /// Keeps the shell pages in a stable order so tab indexes remain predictable.
  /// يثبت صفحات الغلاف بترتيب ثابت حتى يبقى ربط المؤشر بالصفحة واضحًا.
  List<Widget> get _pages => [
        const NavigationPage(child: AdminHubPage()),
        const NavigationPage(child: ProfilePage()),
      ];

  /// Metadata for the bottom navigation items, including icon states and accent colors.
  /// بيانات عناصر التنقل السفلي: الأيقونات والحالات النشطة والتدرجات اللونية.
  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.dashboard_customize_outlined,
      activeIcon: Icons.dashboard_customize_rounded,
      label: 'الإدارة',
      gradient: LinearGradient(
        colors: [AppTheme.neonBlue, AppTheme.neonPurple],
      ),
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'حسابي',
      gradient: LinearGradient(
        colors: [AppTheme.primaryViolet, AppTheme.neonPurple],
      ),
    ),
  ];

  @override

  /// يهيئ وحدات التحكم والحركات ويبدأ تسلسل الظهور عند فتح الشاشة.
  /// Initializes controllers and animations, then starts the entrance
  /// sequence when the screen opens.
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _startAnimations();
  }

  /// Creates the controllers that coordinate page switching and nav-bar motion.
  /// ينشئ وحدات التحكم التي تنسق الانتقال بين الصفحات وحركة شريط التنقل.
  void _initializeControllers() {
    _pageController = PageController(initialPage: _currentIndex);

    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

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

  /// Maps controller output into the glow, wave, and pulse curves used by the shell.
  /// يحول خرج وحدات التحكم إلى منحنيات اللمعان والموجة والنَّبض في الغلاف.
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

  /// Starts the perpetual shell motion and staggers the item intro animations.
  /// يبدأ الحركة المستمرة للغلاف ويُدخل عناصر التنقل بتتابع متدرج.
  void _startAnimations() {
    _glowAnimationController.repeat(reverse: true);
    _particleAnimationController.repeat();
    _waveAnimationController.repeat();
    _pulseAnimationController.repeat(reverse: true);

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

  @override

  /// يفك الموارد المرتبطة بالصفحات والحركات حتى لا تبقى مؤشرات عالقة.
  /// Releases the page and animation resources so no tickers remain attached.
  void dispose() {
    _pageController.dispose();
    _navAnimationController.dispose();
    _glowAnimationController.dispose();
    _particleAnimationController.dispose();
    _waveAnimationController.dispose();
    _pulseAnimationController.dispose();

    for (var controller in _itemAnimations.values) {
      controller.dispose();
    }

    super.dispose();
  }

  /// يبدّل التبويب النشط ويشغّل حركة الانتقال بين الصفحات.
  /// Switches the active tab and triggers the page transition animation.
  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      // Haptic feedback
      HapticFeedback.lightImpact();

      // Animate transition
      _navAnimationController.forward().then((_) {
        _navAnimationController.reset();
      });

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

  @override

  /// يبني الغلاف الكامل مع صفحة محتوى ثابتة وشريط تنقل سفلي متحرك.
  /// Builds the full shell with a stable content page and animated bottom bar.
  Widget build(BuildContext context) {
    return Scaffold(
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
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFuturisticBottomBar(),
          ),
        ],
      ),
    );
  }

  /// يبني الشريط السفلي المخصص بما يشمل الخلفية الزجاجية والضوء والموجة.
  /// Builds the custom bottom bar with glass background, glow, and wave
  /// effects.
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

  /// يرسم خلفية زجاجية شفافة تمنح الشريط عمقًا بصريًا خفيفًا.
  /// Draws a translucent glass background that gives the bar visual depth.
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
                  AppTheme.darkCard.withValues(alpha: 0.7),
                  AppTheme.darkSurface.withValues(alpha: 0.9),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// يرسم موجة لونية تتحرك مع التبويب النشط لتوضيح موقعه بصريًا.
  /// Paints a moving color wave that visually tracks the active tab.
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

  /// يرسم خط اللمعان العلوي الذي يزداد حضوره مع الحركة الحالية.
  /// Draws the top glow line that intensifies with the current motion.
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
                  _navItems[_currentIndex].gradient.colors[0].withValues(
                        alpha: 0.3 + (_glowAnimation.value * 0.4),
                      ),
                  _navItems[_currentIndex].gradient.colors[1].withValues(
                        alpha: 0.3 + (_glowAnimation.value * 0.4),
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
                      .withValues(alpha: 0.5),
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

  /// يصف صف عناصر التنقل نفسه بحيث يحتفظ كل عنصر بمكانه وحركته.
  /// Lays out the navigation items so each item keeps its own position and
  /// motion.
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

  /// يبني عنصر التنقل الفردي مع الأيقونة والوسم وتأثيرات التحديد.
  /// Builds a single navigation item with icon, label, and selection effects.
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
                                item.gradient.colors[0].withValues(
                                  alpha: 0.3 * _glowAnimation.value,
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
                                        .withValues(alpha: 0.4),
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
                                  : AppTheme.textMuted.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),

                      // Notification badge removed
                    ],
                  ),

                  const SizedBox(height: 2),

                  // Label
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: isSelected ? 10 : 9,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? item.gradient.colors[0]
                          : AppTheme.textMuted.withValues(alpha: 0.6),
                      height: 1.0,
                    ),
                    child: Text(item.label),
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

  // Notification badge removed with notifications feature
}

// Navigation Item Model
/// يصف عنصر تنقل واحدًا مع حالته العادية والنشطة ولونه المميز.
/// Describes a single navigation item with inactive/active icons, label, and
/// accent gradient.
class _NavItem {
  /// الأيقونة المستخدمة عندما يكون العنصر غير محدد.
  /// Icon shown when the item is not selected.
  final IconData icon;

  /// الأيقونة المستخدمة عندما يصبح العنصر هو التبويب النشط.
  /// Icon shown when the item becomes the active tab.
  final IconData activeIcon;

  /// النص الظاهر أسفل الأيقونة في شريط التنقل.
  /// The label displayed under the icon in the navigation bar.
  final String label;

  /// التدرج اللوني الذي يغذي الخلفية والوهج الخاصين بالعنصر.
  /// Accent gradient used by the item's background and glow effects.
  final LinearGradient gradient;

  /// ينشئ بيانات عنصر التنقل مع كل مكوناته المرئية.
  /// Creates navigation item metadata with all visual components.
  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.gradient,
  });
}

// Wave Effect Painter
/// يرسم الموجة السفلية التي تلتف حول التبويب النشط أسفل الشريط.
/// Paints the bottom wave that wraps around the active tab under the bar.
class _WaveEffectPainter extends CustomPainter {
  /// قيمة الحركة الحالية التي تحدد شكل الموجة في هذه اللحظة.
  /// The current animation value that shapes the wave at this moment.
  final double animation;

  /// فهرس التبويب النشط الذي يجب أن تتركز حوله الموجة.
  /// Index of the active tab that the wave should center on.
  final int currentIndex;

  /// الألوان الممثلة لكل عنصر تنقل وتستخدم في التدرج المرسوم.
  /// Colors representing each navigation item and used by the painted gradient.
  final List<Color> itemColors;

  /// ينشئ الرسام مع القيم التي يحتاجها لتلوين الموجة وتحريكها.
  /// Creates the painter with the values required to color and animate the
  /// wave.
  _WaveEffectPainter({
    required this.animation,
    required this.currentIndex,
    required this.itemColors,
  });
  @override

  /// يرسم الموجة الملوّنة بناءً على العنصر النشط وقيمة الحركة الحالية.
  /// Paints the colored wave based on the active item and current animation
  /// value.
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          itemColors[currentIndex].withValues(alpha: 0.1),
          itemColors[currentIndex].withValues(alpha: 0.05),
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

  @override

  /// يعيد دائمًا true لأن الرسام يعتمد مباشرة على قيمة الحركة المتغيرة.
  /// Always returns true because the painter depends directly on the changing
  /// animation value.
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// يضيف الحشو السفلي اللازم حتى لا يغطي شريط التنقل محتوى الصفحة.
/// Adds the bottom padding needed so the navigation bar does not cover page
/// content.
class NavigationPage extends StatelessWidget {
  /// المحتوى الذي يجب أن يبقى فوق شريط التنقل السفلي.
  /// The page content that must remain above the bottom navigation bar.
  final Widget child;

  /// ينشئ غلافًا بسيطًا يرفع الصفحة فوق المساحة التي يشغلها الشريط السفلي.
  /// Creates a simple wrapper that lifts the page above the bottom bar area.
  const NavigationPage({
    super.key,
    required this.child,
  });
  @override

  /// يعرض المحتوى مع حشو سفلي محسوب من ارتفاع شريط التنقل وSafeArea.
  /// Renders the content with bottom padding derived from the nav bar height
  /// and SafeArea.
  Widget build(BuildContext context) {
    // حساب الارتفاع الكلي لشريط التنقل مع SafeArea
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final totalBottomPadding = 75.0 + bottomPadding;

    return Padding(
      padding: EdgeInsets.only(bottom: totalBottomPadding),
      child: child,
    );
  }
}
