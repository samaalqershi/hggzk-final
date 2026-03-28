import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/settings_item_widget.dart';
import '../widgets/theme_selector_widget.dart';
import '../../domain/entities/app_settings.dart';

/// تعرض مركز إعدادات التطبيق مع أقسام اللغة والثيم والخصوصية وتفضيلات
/// الحساب.
/// Presents the main settings hub with language, theme, privacy, and account
/// preference sections.
class SettingsPage extends StatefulWidget {
  /// ينشئ شاشة الإعدادات الرئيسية.
  /// Creates the main settings page.
  const SettingsPage({super.key});

  /// ينشئ الحالة التي تتولى إدارة الحركات وبناء أقسام الصفحة.
  /// Creates the state object that manages animations and builds the page
  /// sections.
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// تدير الخلفية المتحركة وبناء أقسام الإعدادات المختلفة داخل الصفحة.
/// Manages the animated background and builds the different settings sections
/// inside the page.
class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  /// متحكم حركة الخلفية العامة للصفحة.
  /// Animation controller for the page background.
  late AnimationController _backgroundAnimationController;

  /// متحكم ظهور عناصر الإعدادات داخل المحتوى.
  /// Animation controller for revealing settings items.
  late AnimationController _itemAnimationController;

  /// متحكم التوهج الخفيف المستخدم في الخلفية والزخارف.
  /// Animation controller for the subtle glow used in decorative layers.
  late AnimationController _glowAnimationController;

  /// يهيئ حركات الصفحة الأساسية عند الإنشاء.
  /// Initializes the page's core animations when it is created.
  @override
  void initState() {
    super.initState();

    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _itemAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  /// يحرر متحكمات الحركة عند إزالة الصفحة من الشجرة.
  /// Disposes the animation controllers when the page leaves the tree.
  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _itemAnimationController.dispose();
    _glowAnimationController.dispose();
    super.dispose();
  }

  /// يبني غلاف صفحة الإعدادات مع الخلفية المتحركة والمحتوى الرئيسي.
  /// Builds the settings page shell with the animated background and primary
  /// content.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),

          // Main Content
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAccountDeleteSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppTheme.success,
                  ),
                );
                context.go('/login');
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            },
            child: CustomScrollView(
              slivers: [
                _buildFuturisticAppBar(),
                SliverToBoxAdapter(
                  child: BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      if (state is SettingsLoading) {
                        return const SizedBox(
                          height: 400,
                          child: LoadingWidget(
                            type: LoadingType.circular,
                          ),
                        );
                      }

                      // Get settings from any state that has them, or use defaults
                      AppSettings settings;
                      if (state is SettingsLoaded) {
                        settings = state.settings;
                      } else if (state is SettingsUpdated) {
                        settings = state.settings;
                      } else if (state is SettingsUpdating) {
                        settings = state.currentSettings;
                      } else if (state is SettingsError &&
                          state.lastKnownSettings != null) {
                        settings = state.lastKnownSettings!;
                      } else {
                        // Default settings to ensure content always shows
                        settings = const AppSettings();
                      }

                      return _buildFuturisticContent(settings);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// يبني طبقة الخلفية المتحركة الخاصة بصفحة الإعدادات.
  /// Builds the animated background layer for the settings page.
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                math.cos(_backgroundAnimationController.value * 2 * math.pi),
                math.sin(_backgroundAnimationController.value * 2 * math.pi),
              ),
              end: Alignment(
                -math.cos(_backgroundAnimationController.value * 2 * math.pi),
                -math.sin(_backgroundAnimationController.value * 2 * math.pi),
              ),
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2,
                AppTheme.darkBackground3,
              ],
            ),
          ),
          child: CustomPaint(
            painter: _SettingsBackgroundPainter(
              animationValue: _glowAnimationController.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  /// يبني شريط التطبيق الموسع أعلى صفحة الإعدادات.
  /// Builds the expanded app bar at the top of the settings page.
  Widget _buildFuturisticAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryPurple.withOpacity(0.3),
                AppTheme.primaryBlue.withOpacity(0.2),
                Colors.transparent,
              ],
            ),
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: AppTheme.darkCard.withOpacity(0.3),
                child: Stack(
                  children: [
                    // Animated Lines
                    CustomPaint(
                      painter: _GridPatternPainter(
                        animationValue: _glowAnimationController.value,
                      ),
                      size: Size.infinite,
                    ),
                    // Title
                    SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppTheme.primaryGradient.createShader(bounds),
                              child: const Icon(
                                Icons.settings_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppTheme.primaryGradient.createShader(bounds),
                              child: Text(
                                'الإعدادات',
                                style: AppTextStyles.h1.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 28,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withOpacity(0.7),
                AppTheme.darkCard.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppTheme.textWhite,
            size: 18,
          ),
        ),
        onPressed: () => context.pop(),
      ),
    );
  }

  /// يبني محتوى صفحة الإعدادات اعتمادًا على القيم الحالية المخزنة في
  /// الإعدادات.
  /// Builds the settings page content from the current persisted settings
  /// values.
  Widget _buildFuturisticContent(AppSettings settings) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Account Section
          _buildFuturisticSection(
            title: 'الحساب',
            icon: Icons.account_circle_rounded,
            gradient: LinearGradient(
              colors: [AppTheme.primaryBlue, AppTheme.primaryCyan],
            ),
            items: [
              FuturisticSettingsItem(
                icon: Icons.person_outline_rounded,
                title: 'الملف الشخصي',
                subtitle: 'تعديل معلوماتك الشخصية',
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.primaryCyan],
                ),
                onTap: () => context.push('/profile'),
              ),
              FuturisticSettingsItem(
                icon: Icons.lock_outline_rounded,
                title: 'كلمة المرور',
                subtitle: 'تغيير كلمة المرور',
                gradient: LinearGradient(
                  colors: [AppTheme.primaryPurple, AppTheme.primaryViolet],
                ),
                onTap: () => context.push('/profile/change-password'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Preferences Section
          _buildFuturisticSection(
            title: 'التفضيلات',
            icon: Icons.tune_rounded,
            gradient: LinearGradient(
              colors: [AppTheme.primaryPurple, AppTheme.primaryViolet],
            ),
            items: [
              FuturisticSettingsItem(
                icon: Icons.language_rounded,
                title: 'اللغة',
                subtitle:
                    settings.preferredLanguage == 'ar' ? 'العربية' : 'English',
                gradient: LinearGradient(
                  colors: [AppTheme.neonBlue, AppTheme.primaryCyan],
                ),
                onTap: () => context.push('/settings/language'),
              ),
              FuturisticSettingsItem(
                icon: Icons.dark_mode_rounded,
                title: 'المظهر',
                subtitle: settings.darkMode ? 'الوضع الليلي' : 'الوضع النهاري',
                gradient: LinearGradient(
                  colors: [AppTheme.primaryViolet, AppTheme.neonPurple],
                ),
                trailing: FuturisticThemeToggle(
                  isDarkMode: settings.darkMode,
                  onChanged: (isDark) {
                    context.read<SettingsBloc>().add(UpdateThemeEvent(isDark));
                  },
                ),
              ),
              FuturisticSettingsItem(
                icon: Icons.fingerprint_rounded,
                title: 'بصمة الإصبع',
                subtitle: settings.biometricEnabled
                    ? 'مفعّل لتسجيل الدخول'
                    : 'غير مفعّل',
                gradient: LinearGradient(
                  colors: [AppTheme.primaryPurple, AppTheme.neonPurple],
                ),
                trailing: FuturisticSettingsToggle(
                  icon: Icons.fingerprint_rounded,
                  title: 'بصمة الإصبع',
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.neonPurple],
                  ),
                  value: settings.biometricEnabled,
                  onChanged: (enabled) {
                    context
                        .read<SettingsBloc>()
                        .add(UpdateBiometricEvent(enabled));
                  },
                ),
              ),
              FuturisticSettingsItem(
                icon: Icons.attach_money_rounded,
                title: 'العملة',
                subtitle: _getCurrencyName(settings.preferredCurrency),
                gradient: LinearGradient(
                  colors: [AppTheme.success, AppTheme.neonGreen],
                ),
                onTap: () => _showFuturisticCurrencySelector(
                    context, settings.preferredCurrency),
              ),
              FuturisticSettingsItem(
                icon: Icons.notifications_active_rounded,
                title: 'الإشعارات',
                subtitle: 'إدارة إعدادات الإشعارات',
                gradient: LinearGradient(
                  colors: [AppTheme.warning, Colors.orange],
                ),
                onTap: () => context.push('/notifications/settings'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Support Section
          _buildFuturisticSection(
            title: 'الدعم والمساعدة',
            icon: Icons.support_agent_rounded,
            gradient: LinearGradient(
              colors: [AppTheme.info, AppTheme.neonBlue],
            ),
            items: [
              FuturisticSettingsItem(
                icon: Icons.help_outline_rounded,
                title: 'مركز المساعدة',
                subtitle: 'الأسئلة الشائعة والدعم',
                gradient: LinearGradient(
                  colors: [AppTheme.info, AppTheme.primaryBlue],
                ),
                onTap: () => context.push('/support'),
              ),
              FuturisticSettingsItem(
                icon: Icons.privacy_tip_rounded,
                title: 'سياسة الخصوصية',
                subtitle: 'اقرأ سياسة الخصوصية',
                gradient: LinearGradient(
                  colors: [AppTheme.primaryCyan, AppTheme.neonBlue],
                ),
                onTap: () => context.push('/settings/privacy-policy'),
              ),
              FuturisticSettingsItem(
                icon: Icons.description_rounded,
                title: 'الشروط والأحكام',
                subtitle: 'اقرأ الشروط والأحكام',
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
                ),
                onTap: () => context.push('/terms'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // About Section
          _buildFuturisticSection(
            title: 'حول',
            icon: Icons.info_rounded,
            gradient: LinearGradient(
              colors: [AppTheme.primaryViolet, AppTheme.neonPurple],
            ),
            items: [
              FuturisticSettingsItem(
                icon: Icons.info_outline_rounded,
                title: 'عن التطبيق',
                subtitle: 'معلومات حول التطبيق',
                gradient: LinearGradient(
                  colors: [AppTheme.primaryViolet, AppTheme.neonPurple],
                ),
                onTap: () => context.push('/settings/about'),
              ),
              FuturisticSettingsItem(
                icon: Icons.star_rounded,
                title: 'قيم التطبيق',
                subtitle: 'شاركنا رأيك',
                gradient: LinearGradient(
                  colors: [Colors.orange, AppTheme.warning],
                ),
                onTap: () => _rateApp(),
              ),
              FuturisticSettingsItem(
                icon: Icons.share_rounded,
                title: 'شارك التطبيق',
                subtitle: 'شارك التطبيق مع أصدقائك',
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.info],
                ),
                onTap: () => _shareApp(),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Logout Button
          _buildFuturisticLogoutButton(context),

          const SizedBox(height: 16),

          // Delete Account Button
          _buildFuturisticDeleteAccountButton(context),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// يبني زر حذف الحساب الذي يقود المستخدم إلى نافذة التأكيد النهائية.
  /// Builds the delete-account button that leads the user to the final
  /// confirmation dialog.
  Widget _buildFuturisticDeleteAccountButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFuturisticDeleteAccountDialog(context),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.error.withOpacity(0.9),
              AppTheme.error.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.error.withOpacity(0.25),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showFuturisticDeleteAccountDialog(context),
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'حذف الحساب',
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// يعرض نافذة تأكيد حذف الحساب مع جمع كلمة المرور وسبب الحذف قبل إرسال
  /// الطلب إلى `AuthBloc`.
  /// Shows the delete-account confirmation dialog, collects the password and
  /// optional reason, then forwards the request to `AuthBloc`.
  void _showFuturisticDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final reasonController = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AlertDialog(
                backgroundColor: AppTheme.darkCard.withOpacity(0.95),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: AppTheme.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                title: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppTheme.error, AppTheme.error.withOpacity(0.8)],
                  ).createShader(bounds),
                  child: Text(
                    'حذف الحساب',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سيتم حذف حسابك بشكل نهائي من التطبيق. قد تبقى بعض السجلات (مثل الحجوزات) لأسباب قانونية/محاسبية.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور للتأكيد',
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => obscure = !obscure),
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: reasonController,
                        decoration: const InputDecoration(
                          labelText: 'السبب (اختياري)',
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      passwordController.dispose();
                      reasonController.dispose();
                      Navigator.pop(dialogContext);
                    },
                    child: Text(
                      'إلغاء',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppTheme.textMuted),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.error,
                          AppTheme.error.withOpacity(0.8)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final password = passwordController.text.trim();
                          final reason = reasonController.text.trim();
                          if (password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'يرجى إدخال كلمة المرور للتأكيد'),
                                backgroundColor: AppTheme.error,
                              ),
                            );
                            return;
                          }

                          Navigator.pop(dialogContext);
                          context.read<AuthBloc>().add(
                                DeleteAccountEvent(
                                  password: password,
                                  reason: reason.isEmpty ? null : reason,
                                ),
                              );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Text(
                            'حذف الحساب',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      passwordController.dispose();
      reasonController.dispose();
    });
  }

  /// يبني بطاقة قسم إعدادات موحّدة تضم عنوان القسم وأيقونته وعناصره.
  /// Builds a unified settings section card that contains the section title,
  /// icon, and child items.
  Widget _buildFuturisticSection({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required List<Widget> items,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0).toDouble(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.darkCard.withOpacity(0.6),
                    AppTheme.darkCard.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: gradient.colors[0].withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: gradient.scale(0.3),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                icon,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              title,
                              style: AppTextStyles.h3.copyWith(
                                color: AppTheme.textWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Items
                      ...items,
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

  /// يبني زر تسجيل الخروج الرئيسي أسفل الصفحة.
  /// Builds the primary logout button shown near the bottom of the page.
  Widget _buildFuturisticLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFuturisticLogoutDialog(context),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.error.withOpacity(0.8),
              AppTheme.error.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.error.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showFuturisticLogoutDialog(context),
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'تسجيل الخروج',
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// يعرض نافذة تأكيد تسجيل الخروج قبل إعادة المستخدم إلى شاشة الدخول.
  /// Shows the logout confirmation dialog before redirecting the user to the
  /// login screen.
  void _showFuturisticLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: AppTheme.darkCard.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: AppTheme.error.withOpacity(0.3),
                width: 1,
              ),
            ),
            title: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppTheme.error, AppTheme.error.withOpacity(0.8)],
              ).createShader(bounds),
              child: Text(
                'تسجيل الخروج',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: Text(
              'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'إلغاء',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppTheme.textMuted),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.error, AppTheme.error.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(dialogContext);
                      context.go('/login');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        'تسجيل الخروج',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// يعرض محدد العملة عندما يحتاج المستخدم إلى تغيير العملة المفضلة في
  /// إعداداته.
  /// Presents the currency selector when the user wants to change the
  /// preferred currency in the settings.
  void _showFuturisticCurrencySelector(
      BuildContext context, String currentCurrency) {
    // Implementation similar to logout dialog
  }

  /// يحول رمز العملة المخزن إلى اسم واضح يمكن عرضه داخل عناصر الإعدادات.
  /// Converts a stored currency code into a readable label that can be shown
  /// in the settings list.
  String _getCurrencyName(String code) {
    switch (code) {
      case 'YER':
        return 'الريال اليمني';
      case 'USD':
        return 'الدولار الأمريكي';
      case 'SAR':
        return 'الريال السعودي';
      case 'EUR':
        return 'اليورو';
      default:
        return code;
    }
  }

  /// يطلق مسار تقييم التطبيق في المتجر أو الجهة المعتمدة مستقبلًا.
  /// Triggers the future app-rating flow through the store or chosen channel.
  void _rateApp() {
    // TODO: Implement app rating
  }

  /// يطلق مسار مشاركة التطبيق عبر الوسائل المناسبة مستقبلًا.
  /// Triggers the future app-sharing flow through the appropriate platform
  /// channels.
  void _shareApp() {
    // TODO: Implement app sharing
  }
}

/// يرسم خلفية زخرفية متحركة تضيف توهجًا سداسيًا خلف محتوى صفحة الإعدادات.
/// Paints an animated decorative background that adds hexagonal glow behind
/// the settings page content.
class _SettingsBackgroundPainter extends CustomPainter {
  /// قيمة الحركة الحالية المستخدمة لتحريك عناصر الخلفية وتغيير توهجها.
  /// Current animation value used to move the background elements and vary
  /// their glow.
  final double animationValue;

  /// ينشئ الرسام مع قيمة الحركة التي تتحكم في المشهد الخلفي.
  /// Creates the painter with the animation value that drives the background
  /// scene.
  _SettingsBackgroundPainter({required this.animationValue});

  /// يرسم التوهجات السداسية العائمة فوق مساحة الصفحة بالكامل.
  /// Paints the floating hexagonal glows across the full page canvas.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw floating hexagons
    for (int i = 0; i < 5; i++) {
      final offset = Offset(
        size.width * (0.2 + i * 0.2),
        size.height * (0.3 + animationValue * 0.1 + i * 0.1),
      );

      paint.shader = RadialGradient(
        colors: [
          AppTheme.primaryPurple.withOpacity(0.05 + animationValue * 0.02),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: offset, radius: 100));

      _drawHexagon(canvas, offset, 50 + i * 10, paint);
    }
  }

  /// يرسم شكلاً سداسيًا عند موضع محدد لاستخدامه كعنصر زخرفي في الخلفية.
  /// Draws a hexagon at the given position to serve as a decorative
  /// background element.
  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  /// يحدد أن الخلفية تحتاج إلى إعادة رسم في كل إطار لأن الحركة تتغير
  /// باستمرار.
  /// Indicates that the background should repaint every frame because the
  /// animation is continuously changing.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// يرسم شبكة ضوئية خفيفة داخل ترويسة الصفحة لإبراز الطابع البصري المستقبلي.
/// Paints a subtle glowing grid inside the page header to reinforce the
/// futuristic visual style.
class _GridPatternPainter extends CustomPainter {
  /// قيمة الحركة التي تتحكم في شدة إضاءة خطوط الشبكة.
  /// Animation value that controls the intensity of the grid lines.
  final double animationValue;

  /// ينشئ الرسام مع قيمة الحركة المستخدمة لتدرج الشبكة.
  /// Creates the painter with the animation value used to animate the grid.
  _GridPatternPainter({required this.animationValue});

  /// يرسم خطوط الشبكة الأفقية والعمودية داخل مساحة الترويسة.
  /// Paints the horizontal and vertical grid lines inside the header area.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw grid lines
    const spacing = 30.0;

    for (double x = 0; x < size.width; x += spacing) {
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          AppTheme.primaryBlue.withOpacity(0.1 + animationValue * 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(x, 0, 1, size.height));

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += spacing) {
      paint.shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          AppTheme.primaryPurple.withOpacity(0.1 + animationValue * 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, y, size.width, 1));

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  /// يحدد أن الشبكة تحتاج إلى إعادة رسم مستمرة ما دامت الحركة نشطة.
  /// Indicates that the grid should repaint continuously while the animation
  /// is active.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
