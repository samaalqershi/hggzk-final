import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:hggzkportal/core/constants/route_constants.dart';
import 'package:hggzkportal/core/widgets/app_logo_widget.dart';
import 'package:hggzkportal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hggzkportal/features/auth/presentation/bloc/auth_state.dart';
import 'package:hggzkportal/injection_container.dart';
import 'package:hggzkportal/services/local_storage_service.dart';

/// شاشة بدء قصيرة تحسم الوجهة الأولى بعد قراءة التفضيل والحالة الحالية للمستخدم.
/// Startup gate that decides the first route after reading onboarding and authentication state.
class SplashScreen extends StatefulWidget {
  /// ينشئ شاشة البداية التي تقرر مسار الدخول الأول للتطبيق.
  /// Creates the splash screen that decides the app's initial entry route.
  const SplashScreen({super.key});

  @override

  /// ينشئ كائن الحالة المسؤول عن الحركة ثم التوجيه بعد التأخير.
  /// Creates the state object responsible for animation and delayed routing.
  State<SplashScreen> createState() => _SplashScreenState();
}

/// يدير حركات الشعار ويحول المستخدم من شاشة البداية إلى المسار المناسب.
/// Drives the splash animations and routes the user to the correct destination.
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// يدير التلاشي التدريجي للعناصر المرئية أثناء الظهور الأول.
  /// Controls the staged fade-in of the visible splash elements.
  late AnimationController _fadeController;

  /// يدير تكبير الشعار الأولي قبل اكتمال عرض الشاشة.
  /// Controls the initial logo scale-up before the splash settles.
  late AnimationController _scaleController;

  /// يضيف تنفسًا بصريًا خفيفًا للشعار والخلفية أثناء البقاء على الشاشة.
  /// Adds a subtle breathing motion to the logo and background while the
  /// splash is visible.
  late AnimationController _breathController;

  /// يحرك خط التحميل لإعطاء المستخدم إشارة واضحة على التقدم.
  /// Drives the loading line to give the user a clear sense of progress.
  late AnimationController _progressController;

  /// قيمة التلاشي الأساسية التي تعتمد عليها عناصر المقدمة.
  /// The base fade value used by the intro elements.
  late Animation<double> _fadeAnimation;

  /// قيمة التحجيم التي تحدد حجم الشعار أثناء الافتتاح.
  /// The scale value that sets the logo size during the intro.
  late Animation<double> _scaleAnimation;

  /// قيمة التنفس التي تضبط التمدد الطفيف المتكرر للعناصر.
  /// The breathing value that drives the slight repeated expansion.
  late Animation<double> _breathAnimation;

  /// قيمة تقدم شريط التحميل المعروض في وسط الشاشة.
  /// The progress value shown by the loading bar in the center.
  late Animation<double> _progressAnimation;

  /// يحرك ظهور اسم التطبيق بالتزامن مع تلاشي الشعار.
  /// Animates the app title as it appears alongside the logo fade.
  late Animation<double> _textFadeAnimation;

  /// يحرك عنوان التطبيق من أسفل قليلًا إلى مكانه النهائي.
  /// Slides the app title upward into its final position.
  late Animation<Offset> _textSlideAnimation;

  /// يتحكم في ظهور الوصف السفلي بعد ظهور العنوان.
  /// Controls the subtitle fade after the main title appears.
  late Animation<double> _subtitleFadeAnimation;

  @override

  /// يجهز الحركات ثم يبدأ العد التنازلي للتوجيه بعد عرض الشاشة.
  /// Prepares the animations and starts the delayed navigation countdown
  /// after the splash appears.
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _navigateAfterDelay();
  }

  /// Sets up the animation controllers and the curves that stage the splash reveal.
  /// يهيئ وحدات التحكم والحركات التي تبني تسلسل الظهور في شاشة البداية.
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutBack,
      ),
    );

    _breathController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _breathAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );
  }

  /// Starts the staged intro after a small delay so the logo feels intentional.
  /// يبدأ التسلسل المرئي بعد مهلة قصيرة ليظهر الشعار كجزء مقصود من التجربة.
  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    _fadeController.forward();
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    _breathController.repeat(reverse: true);
    _progressController.forward();
  }

  /// Keeps the splash visible long enough before handing control to the next route.
  /// يحافظ على ظهور شاشة البداية مدة كافية قبل تحويل المستخدم إلى المسار المناسب.
  void _navigateAfterDelay() {
    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      _checkAuthAndNavigate();
    });
  }

  /// Reads onboarding and auth state to decide whether to continue, verify, or log in.
  /// يقرأ حالة البداية والمصادقة ليقرر هل نكمل للتطبيق أم نتحقق أم نذهب لتسجيل الدخول.
  void _checkAuthAndNavigate() {
    final localStorage = sl<LocalStorageService>();
    final isFirstRun = !localStorage.isOnboardingCompleted();

    if (isFirstRun) {
      context.go('/onboarding/select-city-currency');
      return;
    }

    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final user = authState.user;
      if (user.isEmailVerified) {
        context.go(RouteConstants.main);
      } else {
        context.go(RouteConstants.verifyEmail);
      }
    } else {
      context.go(RouteConstants.login);
    }
  }

  /// Releases all animation controllers so the splash does not leak ticker resources.
  /// يحرر وحدات التحكم في الحركة حتى لا تبقى موارد ticker معلقة.
  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _breathController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  /// Builds the animated branded splash layout with platform-aware system UI styling.
  /// يبني واجهة البداية المعلّمة مع ضبط مظهر شريط النظام وفق سطوع الجهاز.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E21),
              Color(0xFF0D1227),
              Color(0xFF0F1433),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // الخلفية الهادئة مع الأضواء الناعمة
            _buildAmbientBackground(size),

            // المحتوى الرئيسي
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  /// يبني المحتوى المركزي للشاشة: الشعار والعنوان والتحميل والتذييل.
  /// Builds the centered splash content: logo, title, loader, and footer.
  Widget _buildMainContent() {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // الشعار الأنيق
            _buildElegantLogo(),

            const SizedBox(height: 48),

            // اسم التطبيق
            _buildAppTitle(),

            const Spacer(flex: 2),

            // مؤشر التحميل الأنيق
            _buildElegantLoader(),

            const SizedBox(height: 60),

            // النص السفلي
            _buildFooter(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// يرسم خلفية محيطة مع أضواء ناعمة ونجوم خافتة لرفع الإحساس بالعمق.
  /// Renders the ambient background with soft lights and faint stars for
  /// depth.
  Widget _buildAmbientBackground(Size size) {
    return Stack(
      children: [
        // ضوء علوي ناعم
        Positioned(
          top: -100,
          left: -50,
          child: AnimatedBuilder(
            animation: _breathAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _breathAnimation.value,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF1E88E5).withValues(alpha: 0.15),
                        const Color(0xFF1E88E5).withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // ضوء سفلي ناعم
        Positioned(
          bottom: -150,
          right: -100,
          child: AnimatedBuilder(
            animation: _breathAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _breathAnimation.value,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7C4DFF).withValues(alpha: 0.12),
                        const Color(0xFF7C4DFF).withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // نجوم خافتة
        ..._buildStars(size),
      ],
    );
  }

  /// ينشئ طبقة من النجوم العشوائية التي تتحرك معها شفافية الظهور.
  /// Creates a layer of random stars whose opacity follows the fade-in.
  List<Widget> _buildStars(Size size) {
    return List.generate(20, (index) {
      final random = math.Random(index);
      final top = random.nextDouble() * size.height;
      final left = random.nextDouble() * size.width;
      final starSize = random.nextDouble() * 2 + 1;
      final opacity = random.nextDouble() * 0.3 + 0.1;

      return Positioned(
        top: top,
        left: left,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: starSize,
            height: starSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: opacity),
            ),
          ),
        ),
      );
    });
  }

  /// يعرض الشعار داخل دائرة زجاجية مضيئة ليعكس هوية التطبيق البصرية.
  /// Displays the logo inside a glowing glass circle to reflect the app's
  /// visual identity.
  Widget _buildElegantLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _fadeAnimation,
        _scaleAnimation,
        _breathAnimation,
      ]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value * _breathAnimation.value,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E88E5).withValues(alpha: 0.2),
                    const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                    blurRadius: 40,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(70),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: Center(
                      child: const AppLogoWidget(
                        width: 62,
                        height: 62,
                        showAdaptiveBackground: true,
                        semanticsLabel: 'hggzkportal-logo',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// يبني اسم التطبيق والوصف الافتتاحي بأسلوب متدرج الظهور والتحريك.
  /// Builds the app name and opening subtitle with staged fade and motion.
  Widget _buildAppTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // اسم التطبيق
        SlideTransition(
          position: _textSlideAnimation,
          child: FadeTransition(
            opacity: _textFadeAnimation,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF64B5F6),
                  Color(0xFF42A5F5),
                  Color(0xFF7C4DFF),
                ],
              ).createShader(bounds),
              child: const Text(
                'HGGZK',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // الوصف
        FadeTransition(
          opacity: _subtitleFadeAnimation,
          child: Text(
            'نظام الحجوزات المتطور',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              letterSpacing: 4,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  /// يعرض شريط التقدم والنص المصاحب له لإظهار أن النظام يستعد للدخول.
  /// Shows the progress bar and its caption to signal that the app is
  /// preparing.
  Widget _buildElegantLoader() {
    return FadeTransition(
      opacity: _subtitleFadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // خط التحميل الأنيق
          SizedBox(
            width: 180,
            height: 8,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.centerLeft,
                  clipBehavior: Clip.none,
                  children: [
                    // الخلفية
                    Container(
                      width: 180,
                      height: 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    // الخط المتحرك
                    Container(
                      width: 180 * _progressAnimation.value,
                      height: 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF64B5F6),
                            Color(0xFF7C4DFF),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF64B5F6).withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                    // النقطة المتحركة
                    Positioned(
                      left: (180 * _progressAnimation.value) - 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF64B5F6)
                                  .withValues(alpha: 0.8),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // نص التحميل
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Text(
                'جاري التحضير...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// يضيف التذييل النهائي الذي يبرز اسم الجهة أو العلامة المطورة.
  /// Adds the final footer that highlights the developer or brand name.
  Widget _buildFooter() {
    return FadeTransition(
      opacity: _subtitleFadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // خط فاصل
          Container(
            width: 40,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // اسم الشركة
          Text(
            'ARMA-SOFT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 4,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }
}
