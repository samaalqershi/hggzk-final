// lib/features/settings/presentation/pages/language_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

/// تعرض شاشة اختيار اللغة وتطبيقها مباشرة على إعدادات التطبيق.
/// Presents the language-selection screen and applies the chosen language to
/// app settings.
class LanguageSettingsPage extends StatefulWidget {
  /// ينشئ شاشة إعدادات اللغة.
  /// Creates the language settings page.
  const LanguageSettingsPage({super.key});

  /// ينشئ حالة الصفحة المسؤولة عن الحركة والاختيار والتفاعل.
  /// Creates the page state that handles animation, selection, and feedback.
  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

/// يدير تفاعل صفحة اللغة، بدءًا من التحريك البصري وحتى تحديث الاختيار.
/// Manages the language page interaction, from motion to selection updates.
class _LanguageSettingsPageState extends State<LanguageSettingsPage>
    with TickerProviderStateMixin {
  /// يتحكم في ظهور الصفحة تدريجيًا عند فتحها.
  /// Controls the page fade-in when it first appears.
  late AnimationController _fadeController;

  /// يحرك المحتوى بخفة من الأسفل إلى الأعلى.
  /// Drives the subtle upward slide for the content.
  late AnimationController _slideController;

  /// يضيف نبضًا بصريًا خفيفًا إلى الخلفية.
  /// Adds a subtle pulsing motion to the background.
  late AnimationController _pulseController;

  /// يحرّك تمييز البطاقة المختارة عند تبديل اللغة.
  /// Animates the selected-card highlight when switching languages.
  late AnimationController _selectionController;

  /// قيمة التلاشي المستخدمة في انتقال الصفحة.
  /// Fade animation used by the page transition.
  late Animation<double> _fadeAnimation;

  /// إزاحة الحركة المستخدمة لرفع المحتوى برفق.
  /// Slide animation used to lift the content gently.
  late Animation<Offset> _slideAnimation;

  /// قيمة النبض الخلفي المستخدم في الرسم.
  /// Pulse animation value used by the background painter.
  late Animation<double> _pulseAnimation;

  /// خيارات اللغة المعروضة للمستخدم داخل الواجهة.
  /// Language options shown to the user in the UI.
  List<_UltraMinimalLanguage> _localizedLanguages(BuildContext context) => [
        _UltraMinimalLanguage(
          code: 'ar',
          name: context.tr('settings.item.languageArabic'),
          subtitle: context.tr('settings.item.languageArabic'),
          icon: '🇾🇪',
          direction: 'RTL',
        ),
        _UltraMinimalLanguage(
          code: 'en',
          name: context.tr('settings.item.languageEnglish'),
          subtitle: context.tr('settings.item.languageEnglish'),
          icon: '🇬🇧',
          direction: 'LTR',
        ),
      ];

  /// يهيئ المتحكمات الحركية ويبدأ الانتقالات الأولى للصفحة.
  /// Initializes animation controllers and starts the first page transitions.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCurrentLanguage();
  }

  /// ينشئ جميع الحركات المستخدمة في الخلفية والبطاقات والتنبيهات.
  /// Builds all animations used by the background, cards, and feedback.
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  /// يقرأ اللغة المحفوظة من SettingsBloc ليعرض الاختيار الحالي بدقة.
  /// Reads the saved language from SettingsBloc so the current selection is accurate.
  void _loadCurrentLanguage() {
    // The current language is read directly from SettingsBloc in build().
  }

  /// يحرر متحكمات الحركة حتى لا تبقى موارد معلقّة بعد مغادرة الصفحة.
  /// Disposes animation controllers to avoid dangling resources after leaving the page.
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  /// يبني الصفحة الكاملة بخلفية زخرفية ومحتوى قابل للتمرير.
  /// Builds the full page with a decorative background and scrollable content.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Ultra minimal gradient background
          _buildUltraMinimalBackground(),

          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildUltraMinimalHeader(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildContent(),
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

  /// يرسم خلفية خفيفة جدًا تعتمد على تدرج ونقاط ضوئية متحركة.
  /// Renders a very subtle background using a gradient and animated light orbs.
  Widget _buildUltraMinimalBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkBackground,
            AppTheme.darkBackground.withBlue(AppTheme.darkBackground.blue + 4),
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _UltraSubtleBackgroundPainter(
              pulseAnimation: _pulseAnimation.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  /// يبني رأس الصفحة الذي يوضح العنوان ويوفر زر الرجوع والأيقونة.
  /// Builds the page header with title, back button, and language icon.
  Widget _buildUltraMinimalHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Back button
          _buildMinimalBackButton(),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('settings.language.title'),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textWhite.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('settings.language.subtitle'),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppTheme.textMuted.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // Language icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.08),
                  AppTheme.primaryPurple.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.translate,
              color: AppTheme.primaryBlue.withOpacity(0.5),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// يبني زر الرجوع الذي يغلق الصفحة مع اهتزاز لمسي خفيف.
  /// Builds the back button that closes the page with a light haptic cue.
  Widget _buildMinimalBackButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.pop();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.05),
            width: 0.5,
          ),
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          color: AppTheme.textWhite,
          size: 14,
        ),
      ),
    );
  }

  /// يبني المحتوى الرئيسي ويقرأ الحالة من SettingsBloc ليعكس الاختيار الحالي.
  /// Builds the main content and reads SettingsBloc to reflect the active choice.
  Widget _buildContent() {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        String currentLanguage = 'ar';
        final languages = _localizedLanguages(context);

        if (state is SettingsLoaded || state is SettingsUpdated) {
          final settings = (state is SettingsLoaded)
              ? state.settings
              : (state as SettingsUpdated).settings;
          currentLanguage = settings.preferredLanguage;
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Language cards
              ...List.generate(languages.length, (index) {
                final language = languages[index];
                final isSelected = language.code == currentLanguage;

                return TweenAnimationBuilder<double>(
                  key: ValueKey(language.code),
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 15 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: _buildUltraMinimalLanguageCard(
                          language: language,
                          isSelected: isSelected,
                          onTap: () => _selectLanguage(language.code),
                        ),
                      ),
                    );
                  },
                );
              }),

              const SizedBox(height: 40),

              // Info section
              _buildInfoSection(currentLanguage),
            ],
          ),
        );
      },
    );
  }

  /// يبني بطاقة لغة واحدة مع حالة تحديد وتغذية لمسية وانتقال بصري.
  /// Builds one language card with selected state, haptics, and visual transition.
  Widget _buildUltraMinimalLanguageCard({
    required _UltraMinimalLanguage language,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (isSelected) return;
        _selectionController.forward(from: 0);
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.05),
                    AppTheme.primaryPurple.withOpacity(0.02),
                  ],
                )
              : null,
          color: !isSelected ? AppTheme.darkCard.withOpacity(0.03) : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue.withOpacity(0.2)
                : AppTheme.darkBorder.withOpacity(0.05),
            width: isSelected ? 1 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // Flag/Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 44 : 40,
              height: isSelected ? 44 : 40,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.1),
                          AppTheme.primaryPurple.withOpacity(0.05),
                        ],
                      )
                    : null,
                color: !isSelected ? AppTheme.darkCard.withOpacity(0.05) : null,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryBlue.withOpacity(0.15)
                      : AppTheme.darkBorder.withOpacity(0.05),
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  language.icon,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: isSelected ? 22 : 20,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Language info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        language.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? AppTheme.primaryBlue.withOpacity(0.9)
                              : AppTheme.textWhite.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryBlue.withOpacity(0.1)
                              : AppTheme.darkCard.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          language.direction,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 9,
                            color: isSelected
                                ? AppTheme.primaryBlue.withOpacity(0.7)
                                : AppTheme.textMuted.withOpacity(0.4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    language.subtitle,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: AppTheme.textMuted.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 22 : 20,
              height: isSelected ? 22 : 20,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.8),
                          AppTheme.primaryPurple.withOpacity(0.6),
                        ],
                      )
                    : null,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AppTheme.darkBorder.withOpacity(0.1),
                  width: isSelected ? 0 : 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// يبني قسمًا توضيحيًا يشرح أثر تغيير اللغة للمستخدم.
  /// Builds an informational block that explains what language changes affect.
  Widget _buildInfoSection(String currentLanguage) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.info.withOpacity(0.03 * _pulseAnimation.value),
                AppTheme.info.withOpacity(0.01 * _pulseAnimation.value),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.info.withOpacity(0.08),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppTheme.info.withOpacity(0.6),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('settings.language.infoTitle'),
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.info.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('settings.language.infoDescription'),
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        color: AppTheme.textMuted.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// يرسل حدث تغيير اللغة إلى SettingsBloc ثم يعرض رسالة تأكيد قصيرة.
  /// Dispatches the language change event to SettingsBloc and then shows a short confirmation.
  void _selectLanguage(String languageCode) {
    context.read<SettingsBloc>().add(UpdateLanguageEvent(languageCode));

    _showUltraMinimalSnackBar(languageCode);
  }

  /// يعرض رسالة نجاح عابرة تؤكد اللغة الجديدة بعد التبديل.
  /// Shows a transient success message confirming the new language choice.
  void _showUltraMinimalSnackBar(String languageCode) {
    HapticFeedback.mediumImpact();

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _UltraMinimalSnackBar(languageCode: languageCode),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}

/// شريط تأكيد عابر يعرض نجاح تغيير اللغة بأسلوب خفيف ومركّز.
/// Transient confirmation bar that highlights a successful language change.
class _UltraMinimalSnackBar extends StatefulWidget {
  /// رمز اللغة الذي يحدد نص الرسالة المعروضة.
  /// Language code that determines the displayed message.
  final String languageCode;

  /// ينشئ شريط التأكيد العابر المرتبط بالرمز اللغوي الحالي.
  /// Creates the transient confirmation bar for the current language code.
  const _UltraMinimalSnackBar({
    required this.languageCode,
  });

  /// ينشئ حالة الشريط المؤقت مع حركة الدخول والخروج.
  /// Creates the transient snackbar state with entrance and exit motion.
  @override
  State<_UltraMinimalSnackBar> createState() => _UltraMinimalSnackBarState();
}

/// يدير حركة ظهور واختفاء الشريط المؤقت.
/// Manages the show and hide animation for the transient snackbar.
class _UltraMinimalSnackBarState extends State<_UltraMinimalSnackBar>
    with SingleTickerProviderStateMixin {
  /// يتحكم في دورة دخول وخروج الشريط المؤقت.
  /// Drives the snackbar's show and hide cycle.
  late AnimationController _controller;

  /// يضبط الشفافية أثناء الحركة.
  /// Controls opacity during the motion.
  late Animation<double> _fadeAnimation;

  /// يحرّك الشريط من الأسفل إلى موضعه النهائي.
  /// Slides the snackbar upward into place.
  late Animation<Offset> _slideAnimation;

  /// يهيئ الحركة ويشغل الإظهار الأولي ثم يبدأ الإخفاء المؤجل.
  /// Sets up the animation and starts the delayed hide sequence.
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  /// يحرر متحكم الحركة بعد انتهاء عرض الشريط.
  /// Disposes the animation controller once the snackbar is removed.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// يبني الشريط المؤقت مع رسالة مناسبة بحسب اللغة المختارة.
  /// Builds the transient snackbar with a message that matches the selected language.
  @override
  Widget build(BuildContext context) {
    final isArabic = widget.languageCode == 'ar';

    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.success.withOpacity(0.2),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.success.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.success.withOpacity(0.2),
                              AppTheme.success.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: AppTheme.success.withOpacity(0.8),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isArabic
                            ? context.tr('settings.language.changedArabic')
                            : context.tr('settings.language.changedEnglish'),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppTheme.textWhite.withOpacity(0.9),
                        ),
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
}

/// نموذج صغير يصف لغة واحدة مع بيانات العرض الخاصة بها.
/// Small model describing one language and its display metadata.
class _UltraMinimalLanguage {
  /// رمز اللغة المستخدم للحفظ والمقارنة.
  /// Language code used for persistence and comparison.
  final String code;

  /// الاسم الظاهر للمستخدم داخل البطاقة.
  /// Display name shown to the user in the card.
  final String name;

  /// تسمية ثانوية توضح الاسم بلغته الأخرى.
  /// Secondary label that clarifies the language in the alternate script.
  final String subtitle;

  /// الرمز المرئي أو العلم المستخدم في البطاقة.
  /// Visual icon or flag displayed in the card.
  final String icon;

  /// اتجاه الكتابة المرتبط باللغة.
  /// Writing direction associated with the language.
  final String direction;

  /// ينشئ وصف اللغة المصغّر المستخدم داخل البطاقات.
  /// Creates the compact language descriptor used in cards.
  const _UltraMinimalLanguage({
    required this.code,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.direction,
  });
}

/// رسّام خلفية خفيف جدًا يضيف نقطتين ضوئيتين دون تشويش على المحتوى.
/// Very subtle background painter that adds two light orbs without distracting from the content.
class _UltraSubtleBackgroundPainter extends CustomPainter {
  /// مقدار النبض المستخدم لتقوية أو تهدئة الوهج.
  /// Pulse amount used to strengthen or soften the glow.
  final double pulseAnimation;

  /// ينشئ الرسّام مع قيمة النبض الحالية.
  /// Creates the painter with the current pulse value.
  _UltraSubtleBackgroundPainter({
    required this.pulseAnimation,
  });

  /// يرسم الوهج الخلفي الهادئ الذي يحدد هوية الصفحة.
  /// Paints the quiet background glow that gives the page its identity.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    // Single subtle gradient orb
    final center = Offset(
      size.width * 0.8,
      size.height * 0.2,
    );

    paint.shader = RadialGradient(
      colors: [
        AppTheme.primaryBlue.withOpacity(0.02 * pulseAnimation),
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: 200));

    canvas.drawCircle(center, 200, paint);

    // Second subtle orb
    final center2 = Offset(
      size.width * 0.2,
      size.height * 0.7,
    );

    paint.shader = RadialGradient(
      colors: [
        AppTheme.primaryPurple.withOpacity(0.01 * pulseAnimation),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: center2, radius: 150));

    canvas.drawCircle(center2, 150, paint);
  }

  /// يعيد الرسم دائمًا لأن النبض يتغير باستمرار.
  /// Always repaints because the pulse value changes continuously.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
