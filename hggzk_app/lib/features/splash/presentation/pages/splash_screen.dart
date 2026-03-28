import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';
import 'package:hggzk/core/constants/route_constants.dart';
import 'package:hggzk/core/services/local_storage_service.dart';
import 'package:hggzk/core/widgets/app_logo_widget.dart';
import 'package:hggzk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hggzk/features/auth/presentation/bloc/auth_state.dart';

/// Guides the user through the first branded moment of the app while startup
/// checks determine whether onboarding, verification, or the main shell should
/// open next.
/// تقود المستخدم عبر اللحظة البصرية الأولى للتطبيق بينما تحدد فحوصات الإقلاع
/// ما إذا كان المسار التالي هو التهيئة الأولى أو التحقق أو الواجهة الرئيسية.
class SplashScreen extends StatefulWidget {
  /// Creates the boot-time screen that the router shows before the app settles
  /// on its real destination.
  /// ينشئ شاشة الإقلاع التي يعرضها الراوتر قبل أن يستقر التطبيق على وجهته الفعلية.
  const SplashScreen({super.key});

  /// Creates the state object that owns both the motion system and the delayed
  /// navigation handoff.
  /// ينشئ كائن الحالة الذي يدير نظام الحركة ومنطق تمرير المستخدم إلى الشاشة التالية.
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// Owns the startup choreography so the splash experience feels intentional
/// instead of being a static waiting screen, while still deciding the correct
/// next route from app state.
/// يدير هذا الكائن تسلسل الإقلاع البصري حتى لا تبدو الشاشة مجرد انتظار ساكن،
/// وفي الوقت نفسه يحدد الوجهة الصحيحة التالية اعتمادًا على حالة التطبيق.
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// Times the global fade-in that introduces the logo, title, and supporting
  /// text without abrupt transitions.
  /// يحدد توقيت التلاشي العام الذي يُدخل الشعار والعنوان والنصوص المساندة
  /// بطريقة ناعمة ومن دون انتقالات حادة.
  late AnimationController _fadeController;

  /// Adds a gentle expansion to the logo so the hero mark arrives with visual
  /// weight instead of appearing flat.
  /// يضيف تمددًا خفيفًا للشعار حتى يدخل إلى المشهد بحضور بصري أوضح بدل ظهوره
  /// بشكل مسطح.
  late AnimationController _scaleController;

  /// Keeps the ambient scene subtly alive after the first reveal by driving the
  /// breathing pulse used by glowing elements.
  /// يبقي المشهد الخلفي حيًا بشكل خفيف بعد الظهور الأول عبر نبض متكرر تستخدمه
  /// العناصر المتوهجة.
  late AnimationController _breathController;

  /// Powers the visible loading indicator so users feel that startup work is
  /// progressing in the background.
  /// يشغّل مؤشر التحميل الظاهر حتى يشعر المستخدم أن أعمال الإقلاع تتقدم في الخلفية.
  late AnimationController _progressController;

  /// Curved opacity animation shared by the main hero content.
  /// منحنى الشفافية المستخدم عبر عناصر المحتوى الرئيسية.
  late Animation<double> _fadeAnimation;

  /// Animated scale value applied to the logo container during the entrance.
  /// قيمة التكبير المتحركة المطبقة على حاوية الشعار أثناء الظهور الأول.
  late Animation<double> _scaleAnimation;

  /// Repeating pulse value used by decorative background elements to create
  /// depth and motion.
  /// قيمة نبض متكررة تستخدمها عناصر الخلفية الزخرفية لإضفاء عمق وحركة.
  late Animation<double> _breathAnimation;

  /// Maps the boot timeline to the progress bar fill amount.
  /// تربط خط زمن الإقلاع بنسبة امتلاء شريط التقدم.
  late Animation<double> _progressAnimation;

  /// Delays the title reveal until after the logo has started settling in.
  /// يؤخر ظهور العنوان حتى يبدأ الشعار بالاستقرار بصريًا.
  late Animation<double> _textFadeAnimation;

  /// Gives the title block a subtle upward slide that complements its fade.
  /// يمنح كتلة العنوان انزلاقًا صاعدًا خفيفًا يكمّل تأثير التلاشي.
  late Animation<Offset> _textSlideAnimation;

  /// Holds back the closing footer text until the primary message is already
  /// readable.
  /// يؤخر العبارة الختامية حتى تصبح الرسالة الأساسية مقروءة وواضحة أولًا.
  late Animation<double> _subtitleFadeAnimation;

  /// Prepares the animation system before the first frame, then starts the
  /// visual sequence and schedules the route decision.
  /// يجهز نظام الحركة قبل أول إطار، ثم يبدأ التسلسل البصري ويجدول قرار التوجيه.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _navigateAfterDelay();
  }

  /// Builds the full motion timeline for the splash experience, separating the
  /// entrance, idle pulse, and loading feedback so each one starts at the
  /// right moment.
  /// يبني الخط الزمني الكامل لحركة شاشة البداية، مع فصل مرحلة الظهور عن نبض
  /// الخمول وعن مؤشر التحميل حتى تبدأ كل مرحلة في توقيتها المناسب.
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

  /// Starts the reveal in short stages so the splash feels choreographed rather
  /// than having every animated element begin at once.
  /// يبدأ مشهد الظهور على مراحل قصيرة حتى تبدو الشاشة منسقة زمنيًا بدل أن تبدأ
  /// جميع العناصر المتحركة دفعة واحدة.
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

  /// Keeps the splash on screen for a fixed minimum duration, then hands off to
  /// the startup routing decision.
  /// يبقي شاشة البداية مدة دنيا ثابتة، ثم يمرر التحكم إلى منطق تحديد المسار
  /// التالي.
  void _navigateAfterDelay() {
    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      _checkAuthAndNavigate();
    });
  }

  /// Resolves the correct next screen by combining onboarding completion with
  /// the current authentication state and email-verification requirement.
  /// يحدد الشاشة التالية الصحيحة عبر الجمع بين حالة إكمال التهيئة الأولى
  /// وحالة الجلسة الحالية ومتطلب التحقق من البريد الإلكتروني.
  void _checkAuthAndNavigate() {
    final localStorage = sl<LocalStorageService>();
    final isFirstRun = !localStorage.isOnboardingCompleted();

    if (isFirstRun) {
      context.go(RouteConstants.onboardingSelection);
      return;
    }

    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final user = authState.user;
      if (user.isEmailVerified) {
        context.go(RouteConstants.main);
      } else {
        context.go(RouteConstants.verifyOtp);
      }
    } else {
      context.go(RouteConstants.main);
    }
  }

  /// Releases every animation controller created by the splash flow to keep the
  /// widget lifecycle clean.
  /// يحرر جميع متحكمات الحركة التي أنشأتها الشاشة للحفاظ على دورة حياة نظيفة
  /// ومنع تسرب الموارد.
  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _breathController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  /// Builds the branded startup scene and aligns the system overlay colors with
  /// both the dark visual treatment and the platform brightness.
  /// يبني مشهد الإقلاع البصري ويضبط ألوان شريط الحالة بما ينسجم مع الخلفية
  /// الداكنة ومع سطوع النظام الحالي.
  @override
  Widget build(BuildContext context) {
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark = platformBrightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
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
            _buildAmbientBackground(size),
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  /// Lays out the hero sequence vertically so the logo, name, loader, and
  /// footer read as one cohesive startup story.
  /// يرتب العناصر الأساسية عموديًا بحيث يُقرأ الشعار والاسم والمؤشر والعبارة
  /// الختامية كمشهد إقلاع واحد متماسك.
  Widget _buildMainContent() {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            _buildElegantLogo(),
            const SizedBox(height: 48),
            _buildAppTitle(),
            const Spacer(flex: 2),
            _buildElegantLoader(),
            const SizedBox(height: 60),
            _buildFooter(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Paints the soft glowing background shapes that give the splash depth
  /// without distracting from the central branding.
  /// يرسم الأشكال المتوهجة الناعمة التي تمنح الشاشة عمقًا بصريًا من دون أن
  /// تنافس الهوية المركزية.
  Widget _buildAmbientBackground(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -size.height * 0.15,
          left: -size.width * 0.2,
          child: _buildBlurCircle(
            diameter: size.width * 0.7,
            color: const Color(0xFF00D4FF).withOpacity(0.08),
          ),
        ),
        Positioned(
          bottom: -size.height * 0.1,
          right: -size.width * 0.15,
          child: _buildBlurCircle(
            diameter: size.width * 0.5,
            color: const Color(0xFF4A90E2).withOpacity(0.06),
          ),
        ),
        Positioned(
          top: size.height * 0.2,
          right: size.width * 0.1,
          child: _buildBlurCircle(
            diameter: size.width * 0.15,
            color: const Color(0xFF7B61FF).withOpacity(0.12),
          ),
        ),
      ],
    );
  }

  /// Creates one reusable blurred orb that can be positioned around the screen
  /// to form the layered ambient backdrop.
  /// ينشئ دائرة ضبابية قابلة لإعادة الاستخدام يمكن توزيعها حول الشاشة لتكوين
  /// الخلفية المحيطية متعددة الطبقات.
  Widget _buildBlurCircle({
    required double diameter,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _breathAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breathAnimation.value,
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color,
                  blurRadius: 100,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the hero logo treatment, including its gradient shell, glow, and
  /// combined fade/scale entrance.
  /// يبني المعالجة الرئيسية للشعار بما فيها الغلاف المتدرج والوهج وحركة الدخول
  /// المدمجة بين التلاشي والتكبير.
  Widget _buildElegantLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00D4FF),
                    Color(0xFF4A90E2),
                    Color(0xFF7B61FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D4FF).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AppLogoWidget(
                  width: 120,
                  height: 120,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Presents the product name and tagline in a way that feels premium while
  /// remaining readable during the short splash window.
  /// يعرض اسم المنتج والعبارة التسويقية بأسلوب أنيق يبقى مقروءًا رغم قصر مدة
  /// شاشة البداية.
  Widget _buildAppTitle() {
    return AnimatedBuilder(
      animation: Listenable.merge([_textFadeAnimation, _textSlideAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _textFadeAnimation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _textFadeAnimation.value)),
            child: Column(
              children: [
                const Text(
                  'HGGZK',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Smart booking made simple',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shows progress feedback so users understand the splash is covering real
  /// startup work instead of serving as a decorative pause only.
  /// يعرض تغذية راجعة عن التقدم حتى يفهم المستخدم أن الشاشة تغطي عمل إقلاع
  /// حقيقيًا وليست مجرد توقف زخرفي.
  Widget _buildElegantLoader() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          children: [
            SizedBox(
              width: 240,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: _progressAnimation.value,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF00D4FF),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading your experience...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                letterSpacing: 0.6,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Finishes the scene with a short brand statement once the primary content
  /// has already settled.
  /// يختتم المشهد بعبارة علامة تجارية قصيرة بعد أن تكون العناصر الأساسية قد
  /// استقرت وظهرت بوضوح.
  Widget _buildFooter() {
    return AnimatedBuilder(
      animation: _subtitleFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _subtitleFadeAnimation.value.clamp(0.0, 1.0),
          child: Text(
            'Booking excellence starts here',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.65),
              letterSpacing: 1.4,
            ),
          ),
        );
      },
    );
  }
}
