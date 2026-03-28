// lib/features/admin_bookings/presentation/widgets/check_in_out_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

/// يعرض حوارًا لتسجيل وصول الضيف أو مغادرته مع خيارات تشغيل إضافية.
/// Shows a dialog for guest check-in or check-out with extra options.
class CheckInOutDialog extends StatefulWidget {
  /// يحدد معرّف الحجز المرتبط بهذه العملية.
  /// Identifies the booking tied to this action.
  final String bookingId;

  /// يحدد ما إذا كانت العملية هي وصول أم مغادرة.
  /// Indicates whether the action is check-in or check-out.
  final bool isCheckIn;

  /// يستدعى عند تأكيد العملية بعد إدخال البيانات المطلوبة.
  /// Called when the action is confirmed after required inputs are filled.
  final VoidCallback onConfirm;

  /// ينشئ مربع الحوار مع نوع العملية والرد النهائي.
  /// Creates the dialog with the action type and completion callback.
  const CheckInOutDialog({
    super.key,
    required this.bookingId,
    required this.isCheckIn,
    required this.onConfirm,
  });

  /// ينشئ الحالة المتحركة المسؤولة عن النموذج والانتقالات.
  /// Creates the animated state that drives the form and transitions.
  @override
  State<CheckInOutDialog> createState() => _CheckInOutDialogState();
}

/// يدير تفاصيل الحوار بما في ذلك الحركة والخيارات وعدد الضيوف.
/// Manages the dialog details including animation, options, and guest count.
class _CheckInOutDialogState extends State<CheckInOutDialog>
    with SingleTickerProviderStateMixin {
  /// متحكم الحركة الذي يطلق ظهور الحوار.
  /// Animation controller that drives the dialog entrance.
  late AnimationController _animationController;

  /// مقياس الظهور المستخدم في الانتقال المرئي.
  /// Scale animation used for the visual entrance.
  late Animation<double> _scaleAnimation;

  /// دوران خفيف يضيف إحساسًا بالحركة إلى الأيقونة أو الرأس.
  /// Subtle rotation that adds motion to the icon or header.
  late Animation<double> _rotationAnimation;

  /// يلتقط ملاحظات الموظف حول الوصول أو المغادرة.
  /// Captures staff notes for the check-in or check-out action.
  final TextEditingController _notesController = TextEditingController();

  /// يحدد وجود الأمتعة مع الضيف.
  /// Indicates whether the guest has luggage.
  bool _hasLuggage = false;

  /// يحدد الحاجة إلى المساعدة.
  /// Indicates whether assistance is needed.
  bool _needsAssistance = false;

  /// يحدد ما إذا كان الضيف ضمن فئة VIP.
  /// Indicates whether the guest is treated as VIP.
  bool _isVIP = false;

  /// عدد الضيوف المرتبطين بالحجز الجاري معالجته.
  /// Number of guests associated with the booking being processed.
  int _guestsCount = 2;

  /// يهيئ الحركة ويبدأ ظهور مربع الحوار بسلاسة.
  /// Initializes the animations and starts the dialog entrance.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  /// يحرر المتحكمات النصية والحركية عند إغلاق الحوار.
  /// Disposes the text and animation controllers when the dialog closes.
  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// يبني واجهة الحوار الكاملة بما في ذلك الرأس والمحتوى والأزرار.
  /// Builds the full dialog UI including header, content, and actions.
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 4),
        backgroundColor: Colors.transparent,
        child: Container(
          width: 450,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: widget.isCheckIn
                    ? AppTheme.success.withValues(alpha: 0.2)
                    : AppTheme.warning.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.darkCard.withValues(alpha: 0.95),
                      AppTheme.darkCard.withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: widget.isCheckIn
                        ? AppTheme.success.withValues(alpha: 0.3)
                        : AppTheme.warning.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: _buildContent(),
                      ),
                    ),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// يبني رأس الحوار مع عنوان الإجراء والمؤشرات المرئية.
  /// Builds the dialog header with the action title and visual indicators.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isCheckIn
              ? [
                  AppTheme.success.withValues(alpha: 0.15),
                  AppTheme.success.withValues(alpha: 0.05),
                ]
              : [
                  AppTheme.warning.withValues(alpha: 0.15),
                  AppTheme.warning.withValues(alpha: 0.05),
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
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.isCheckIn
                          ? [
                              AppTheme.success,
                              AppTheme.success.withValues(alpha: 0.7)
                            ]
                          : [
                              AppTheme.warning,
                              AppTheme.warning.withValues(alpha: 0.7)
                            ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.isCheckIn
                            ? AppTheme.success.withValues(alpha: 0.4)
                            : AppTheme.warning.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.isCheckIn
                        ? CupertinoIcons.arrow_down_circle_fill
                        : CupertinoIcons.arrow_up_circle_fill,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isCheckIn ? 'تسجيل الوصول' : 'تسجيل المغادرة',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.doc_text,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'حجز #${widget.bookingId.substring(0, 8)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      CupertinoIcons.time,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      Formatters.formatTime(DateTime.now()),
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              CupertinoIcons.xmark_circle_fill,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// يختار المحتوى الأنسب بين الوصول والمغادرة.
  /// Chooses the appropriate content for check-in or check-out.
  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGuestsCounter(),
          const SizedBox(height: 20),
          _buildOptions(),
          const SizedBox(height: 20),
          _buildNotesField(),
          if (widget.isCheckIn) ...[
            const SizedBox(height: 20),
            _buildCheckInInfo(),
          ],
        ],
      ),
    );
  }

  /// يعرض عدادًا لتعديل عدد الضيوف قبل تنفيذ العملية.
  /// Displays a counter used to adjust the guest count before confirming.
  Widget _buildGuestsCounter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.person_2_fill,
            color: AppTheme.primaryBlue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'عدد الضيوف',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.darkBorder.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                _buildCounterButton(
                  icon: CupertinoIcons.minus,
                  onTap: () {
                    if (_guestsCount > 1) {
                      setState(() => _guestsCount--);
                    }
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _guestsCount.toString(),
                    style: AppTextStyles.heading3.copyWith(
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                _buildCounterButton(
                  icon: CupertinoIcons.plus,
                  onTap: () {
                    setState(() => _guestsCount++);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// يبني زرًا صغيرًا لزيادة أو إنقاص قيمة العداد.
  /// Builds a small button that increments or decrements the counter.
  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  /// يعرض مفاتيح الخيارات الإضافية مثل الأمتعة والمساعدة وVIP.
  /// Shows extra toggles such as luggage, assistance, and VIP.
  Widget _buildOptions() {
    return Column(
      children: [
        _buildOptionTile(
          icon: CupertinoIcons.bag_fill,
          title: 'لديه أمتعة',
          value: _hasLuggage,
          onChanged: (value) => setState(() => _hasLuggage = value),
        ),
        const SizedBox(height: 12),
        _buildOptionTile(
          icon: CupertinoIcons.hand_raised_fill,
          title: 'يحتاج مساعدة',
          value: _needsAssistance,
          onChanged: (value) => setState(() => _needsAssistance = value),
        ),
        const SizedBox(height: 12),
        _buildOptionTile(
          icon: CupertinoIcons.star_fill,
          title: 'ضيف VIP',
          value: _isVIP,
          onChanged: (value) => setState(() => _isVIP = value),
        ),
      ],
    );
  }

  /// يبني بطاقة خيار واحدة مع حالة التفعيل والنص والأيقونة.
  /// Builds one option tile with icon, text, and active state.
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: value
            ? AppTheme.primaryBlue.withValues(alpha: 0.05)
            : AppTheme.darkBackground.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? AppTheme.primaryBlue.withValues(alpha: 0.3)
              : AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: value ? AppTheme.primaryBlue : AppTheme.textMuted,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: value ? AppTheme.textWhite : AppTheme.textMuted,
                  ),
                ),
                const Spacer(),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: value,
                    onChanged: onChanged,
                    activeThumbColor: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// يعرض حقل الملاحظات الذي يرافق عملية الوصول أو المغادرة.
  /// Shows the notes field that accompanies the check-in or check-out flow.
  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textWhite,
        ),
        decoration: InputDecoration(
          hintText: 'ملاحظات إضافية...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 50, left: 12, right: 12),
            child: Icon(
              CupertinoIcons.text_bubble,
              color: AppTheme.textMuted,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  /// يعرض بطاقة توضيحية تلخص ما سيحدث عند تأكيد الوصول.
  /// Shows an informational card summarizing what happens on check-in.
  Widget _buildCheckInInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.info.withValues(alpha: 0.1),
            AppTheme.info.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.info_circle_fill,
            color: AppTheme.info,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'معلومات مهمة',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'تأكد من التحقق من هوية الضيف ووسيلة الدفع',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// يبني أزرار الإلغاء والتأكيد في نهاية الحوار.
  /// Builds the cancel and confirm buttons at the end of the dialog.
  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.darkBorder.withValues(alpha: 0.3),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Text(
                      'إلغاء',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isCheckIn
                      ? [
                          AppTheme.success.withValues(alpha: 0.8),
                          AppTheme.success,
                        ]
                      : [
                          AppTheme.warning.withValues(alpha: 0.8),
                          AppTheme.warning,
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.isCheckIn
                        ? AppTheme.success.withValues(alpha: 0.4)
                        : AppTheme.warning.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    widget.onConfirm();
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isCheckIn
                              ? CupertinoIcons.checkmark_circle_fill
                              : CupertinoIcons.arrow_up_circle_fill,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.isCheckIn
                              ? 'تأكيد تسجيل الوصول'
                              : 'تأكيد تسجيل المغادرة',
                          style: AppTextStyles.buttonMedium.copyWith(
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
          ),
        ],
      ),
    );
  }
}
