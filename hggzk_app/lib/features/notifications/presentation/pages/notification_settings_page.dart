// lib/features/notifications/presentation/pages/notification_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

/// تعرض شاشة إعدادات الإشعارات بحيث يستطيع المستخدم تخصيص القنوات والفئات
/// التي يريد استقبالها، مع حفظ فوري للتغييرات عند التبديل.
/// Shows the notification settings screen so the user can configure the
/// channels and categories they want, with changes saved immediately on
/// toggle.
class NotificationSettingsPage extends StatefulWidget {
  /// ينشئ صفحة إعدادات الإشعارات.
  /// Creates the notification settings page.
  const NotificationSettingsPage({super.key});

  /// ينشئ الحالة التي تدير قراءة الإعدادات وتعديلها داخل الصفحة.
  /// Creates the state object that manages loading and editing settings on the
  /// page.
  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

/// تدير نسخة الإعدادات الحالية وتنسق بين الواجهة و`NotificationBloc`.
/// Manages the current settings snapshot and coordinates between the UI and
/// `NotificationBloc`.
class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  /// خريطة الإعدادات الحالية المحفوظة محليًا أو المزامنة من bloc.
  /// Current settings map restored from the bloc or local state.
  Map<String, bool> _settings = {};

  /// يحدد ما إذا كانت هناك تعديلات لم تُرسل بعد.
  /// Indicates whether there are unsaved changes pending.
  bool _hasChanges = false;

  /// يبدأ تحميل إعدادات الإشعارات عند فتح الصفحة.
  /// Starts loading notification settings when the page opens.
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// يطلب الإعدادات الحالية من bloc.
  /// Requests the current settings from the bloc.
  void _loadSettings() {
    context.read<NotificationBloc>().add(
          const LoadNotificationSettingsEvent(),
        );
  }

  /// يبني الصفحة مع شريط علوي ومحتوى يستجيب لحالة التحميل.
  /// Builds the page with an app bar and content that reacts to the loading
  /// state.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: _buildAppBar(),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationSettingsLoaded) {
            setState(() {
              _settings = state.settings;
            });
          } else if (state is NotificationError) {
            _showErrorSnackbar(state.message);
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading ||
              state is NotificationSettingsLoading) {
            return const LoadingWidget(
              type: LoadingType.futuristic,
              message: 'جاري تحميل الإعدادات...',
            );
          }

          return _buildContent();
        },
      ),
      // Arabic: أزيل زر الحفظ لأن التحديثات تُرسل فور التبديل.
      // English: The save button was removed because updates are sent
      // immediately on toggle.
      bottomNavigationBar: null,
    );
  }

  /// Arabic: يبني الشريط العلوي مع زر العودة وعنوان الشاشة.
  /// English: Builds the app bar with the back button and page title.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.darkBackground,
      elevation: 0,
      title: Text(
        'إعدادات الإشعارات',
        style: AppTextStyles.h2.copyWith(
          color: AppTheme.textWhite,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
          CupertinoIcons.arrow_right,
          color: AppTheme.textWhite,
        ),
      ),
    );
  }

  /// Arabic: يبني المحتوى الرئيسي المكوّن من أقسام الإعدادات المختلفة.
  /// English: Builds the main content made of the different settings sections.
  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'قنوات الإشعارات',
            icon: CupertinoIcons.bell_circle_fill,
            children: [
              _buildSettingTile(
                key: 'push_notifications',
                title: 'الإشعارات الفورية',
                subtitle: 'تلقي إشعارات فورية على جهازك',
                icon: CupertinoIcons.device_phone_portrait,
              ),
              _buildSettingTile(
                key: 'email_notifications',
                title: 'البريد الإلكتروني',
                subtitle: 'تلقي إشعارات عبر البريد الإلكتروني',
                icon: CupertinoIcons.mail,
              ),
              _buildSettingTile(
                key: 'sms_notifications',
                title: 'الرسائل النصية',
                subtitle: 'تلقي إشعارات عبر رسائل SMS',
                icon: CupertinoIcons.bubble_left,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'إشعارات الحجوزات',
            icon: CupertinoIcons.calendar,
            children: [
              _buildSettingTile(
                key: 'booking_confirmed',
                title: 'تأكيد الحجز',
                subtitle: 'إشعار عند تأكيد حجز جديد',
                icon: CupertinoIcons.checkmark_circle,
              ),
              _buildSettingTile(
                key: 'booking_cancelled',
                title: 'إلغاء الحجز',
                subtitle: 'إشعار عند إلغاء حجز',
                icon: CupertinoIcons.xmark_circle,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'إشعارات المدفوعات',
            icon: CupertinoIcons.creditcard,
            children: [
              _buildSettingTile(
                key: 'payment_received',
                title: 'استلام دفعة',
                subtitle: 'إشعار عند استلام دفعة جديدة',
                icon: CupertinoIcons.money_dollar_circle,
              ),
              _buildSettingTile(
                key: 'payment_refunded',
                title: 'استرداد دفعة',
                subtitle: 'إشعار عند استرداد دفعة',
                icon: CupertinoIcons.arrow_counterclockwise_circle,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'إشعارات أخرى',
            icon: CupertinoIcons.square_grid_2x2,
            children: [
              _buildSettingTile(
                key: 'promotion_new',
                title: 'العروض والخصومات',
                subtitle: 'إشعار بالعروض والخصومات الجديدة',
                icon: CupertinoIcons.gift,
              ),
              _buildSettingTile(
                key: 'system_updates',
                title: 'تحديثات النظام',
                subtitle: 'إشعار بتحديثات وصيانة النظام',
                icon: CupertinoIcons.gear,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Arabic: يبني مجموعة من الإعدادات تحت عنوان واحد مع أيقونة مرجعية.
  /// English: Builds a grouped section of settings under one title and
  /// reference icon.
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.05),
                      AppTheme.primaryPurple.withValues(alpha: 0.03),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.darkBorder.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
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
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  /// Arabic: يبني صفًا واحدًا لإعداد قابل للتبديل مع عنوان ووصف وأيقونة.
  /// English: Builds a single toggleable setting row with a title, subtitle,
  /// and icon.
  Widget _buildSettingTile({
    required String key,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.darkBackground.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: _settings[key] ?? false,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() {
                _settings[key] = value;
                _hasChanges = false; // Arabic: لا توجد تغييرات معلّقة بعد الآن.
                // English: No pending changes remain after the instant save.
              });
              // Arabic: نرسل التحديث فورًا إلى bloc بدون زر حفظ منفصل.
              // English: Send the update to the bloc immediately without a
              // separate save button.
              context.read<NotificationBloc>().add(
                    UpdateNotificationSettingsEvent(settings: _settings),
                  );
            },
            activeTrackColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  /// Arabic: يعرض رسالة خطأ خفيفة عند فشل تحميل الإعدادات أو حفظها.
  /// English: Shows a lightweight error snackbar when loading or saving the
  /// settings fails.
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              CupertinoIcons.xmark_circle_fill,
              color: AppTheme.error,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.darkCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
