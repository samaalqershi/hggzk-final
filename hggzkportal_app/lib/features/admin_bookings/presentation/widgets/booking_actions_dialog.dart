// lib/features/admin_bookings/presentation/widgets/booking_actions_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

/// يحدد نوع الإجراء الذي يمكن تنفيذه على الحجز من خلال مربع الحوار.
/// Defines the booking action type that can be triggered from the dialog.
enum BookingAction { cancel, update, confirm }

/// يعرض مربع حوار سياقي لإلغاء الحجز أو تحديثه أو تأكيده.
/// Shows a contextual dialog for canceling, updating, or confirming a booking.
class BookingActionsDialog extends StatefulWidget {
  /// يحدد معرّف الحجز الذي سيُعرض ضمن العنوان ويُستخدم في التنفيذ.
  /// Identifies the booking whose ID is shown and used during the action.
  final String bookingId;

  /// يحدد نوع العملية المراد تنفيذها على الحجز.
  /// Defines which booking action the dialog should represent.
  final BookingAction action;

  /// يستقبل سبب الإلغاء أو القيمة المرتجعة بعد التأكيد.
  /// Receives the cancellation reason or the value returned after confirmation.
  final Function(String?)? onConfirm;

  /// ينشئ مربع الحوار مع بيانات الحجز ونوع الإجراء والرد الاختياري.
  /// Creates the dialog with the booking, action type, and optional callback.
  const BookingActionsDialog({
    super.key,
    required this.bookingId,
    required this.action,
    this.onConfirm,
  });

  /// ينشئ حالة تفاعلية تدير الحركة والحقل النصي وسلوك التأكيد.
  /// Creates the interactive state that manages animation, text input, and confirmation.
  @override
  State<BookingActionsDialog> createState() => _BookingActionsDialogState();
}

/// يدير حالة مربع الحوار بما في ذلك الحركة والسبب المختار والتحقق.
/// Manages the dialog state including animation, selected reason, and validation.
class _BookingActionsDialogState extends State<BookingActionsDialog>
    with SingleTickerProviderStateMixin {
  /// متحكم الحركة المسؤول عن تدرج الظهور.
  /// Animation controller responsible for the entrance scale effect.
  late AnimationController _animationController;

  /// قيمة الحركة التي تضبط مقياس مربع الحوار أثناء الظهور.
  /// Animation value that scales the dialog during entrance.
  late Animation<double> _scaleAnimation;

  /// حقل نصي لإدخال سبب بديل عند اختيار "سبب آخر".
  /// Text controller for entering a custom reason when "Other" is selected.
  final TextEditingController _reasonController = TextEditingController();

  /// السبب المحدد حاليًا من قائمة الأسباب الجاهزة.
  /// Currently selected reason from the preset cancellation reasons.
  String? _selectedReason;

  /// قائمة الأسباب المقترحة التي تساعد الموظف على توثيق الإلغاء.
  /// Suggested reasons that help staff document the cancellation.
  final List<String> _cancellationReasons = [
    'طلب العميل',
    'عدم توفر الوحدة',
    'مشكلة في الدفع',
    'معلومات غير صحيحة',
    'سبب آخر',
  ];

  /// يجهّز الحركة الابتدائية ويشغّلها عند فتح مربع الحوار.
  /// Prepares and starts the entrance animation when the dialog opens.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  /// يحرر المتحكمات النصية والحركية عند إغلاق مربع الحوار.
  /// Releases the animation and text controllers when the dialog closes.
  @override
  void dispose() {
    _animationController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  /// يبني الهيكل المرئي العام للحوار مع الحركة والتدرج والحدود.
  /// Builds the dialog shell with animation, blur, gradient, and borders.
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(vertical: 20),
        backgroundColor: Colors.transparent,
        child: Container(
          // width: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowDark.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.darkBorder.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    Flexible(
                      child: SingleChildScrollView(
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

  /// يبني رأس الحوار مع العنوان والأيقونة ورقم الحجز المختصر.
  /// Builds the dialog header with the icon, title, and shortened booking ID.
  Widget _buildHeader() {
    final config = _getActionConfig();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  config.color.withValues(alpha: 0.2),
                  config.color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              config.icon,
              color: config.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'حجز #${widget.bookingId.substring(0, 8)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              CupertinoIcons.xmark_circle_fill,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// يختار محتوى الحوار بحسب نوع الإجراء المطلوب.
  /// Chooses the dialog content based on the requested booking action.
  Widget _buildContent() {
    if (widget.action == BookingAction.cancel) {
      return _buildCancellationContent();
    }
    return const SizedBox.shrink();
  }

  /// يعرض قائمة أسباب الإلغاء وحقل السبب البديل والتنبيه النهائي.
  /// Renders the cancellation reasons, optional custom reason field, and warning.
  Widget _buildCancellationContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سبب الإلغاء',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ..._cancellationReasons.map((reason) {
            return _buildReasonOption(reason);
          }),
          if (_selectedReason == 'سبب آخر') ...[
            const SizedBox(height: 16),
            _buildReasonTextField(),
          ],
          const SizedBox(height: 16),
          _buildWarningMessage(),
        ],
      ),
    );
  }

  /// يبني خيار سبب قابل للاختيار داخل قائمة أسباب الإلغاء.
  /// Builds a selectable cancellation reason option.
  Widget _buildReasonOption(String reason) {
    final isSelected = _selectedReason == reason;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryBlue.withValues(alpha: 0.1)
            : AppTheme.darkBackground.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.3)
              : AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedReason = reason),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : AppTheme.darkBorder,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  reason,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? AppTheme.textWhite : AppTheme.textMuted,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// يعرض حقل النص الذي يُستخدم عند اختيار "سبب آخر".
  /// Shows the text field used when the custom "Other" reason is selected.
  Widget _buildReasonTextField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: _reasonController,
        maxLines: 3,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textWhite,
        ),
        decoration: InputDecoration(
          hintText: 'اكتب السبب هنا...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  /// يعرض الرسالة التحذيرية التي تشرح أثر الإلغاء على العميل.
  /// Shows the warning message that explains the effect of cancellation.
  Widget _buildWarningMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            color: AppTheme.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'سيتم إشعار العميل بإلغاء الحجز',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// يبني صف أزرار الإلغاء والتأكيد في أسفل الحوار.
  /// Builds the cancel and confirm action buttons at the bottom of the dialog.
  Widget _buildActions() {
    final config = _getActionConfig();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
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
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.darkBackground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.darkBorder.withValues(alpha: 0.3),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(12),
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
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    config.color.withValues(alpha: 0.8),
                    config.color,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: config.color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleConfirm,
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Text(
                      config.confirmText,
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                      ),
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

  /// يتحقق من صحة البيانات ثم يغلق الحوار مع إعادة سبب الإلغاء إن وجد.
  /// Validates the input and closes the dialog while returning the reason, if any.
  void _handleConfirm() {
    debugPrint('🟢 [BookingActionsDialog] تم الضغط على زر التأكيد');
    String? reason;

    if (widget.action == BookingAction.cancel) {
      debugPrint('🟢 [BookingActionsDialog] نوع العملية: إلغاء');

      if (_selectedReason == null) {
        // Show error - يجب اختيار سبب
        debugPrint('⚠️ [BookingActionsDialog] لم يتم اختيار سبب الإلغاء');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('يرجى اختيار سبب الإلغاء'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      if (_selectedReason == 'سبب آخر') {
        if (_reasonController.text.trim().isEmpty) {
          // Show error - يجب كتابة السبب
          debugPrint('⚠️ [BookingActionsDialog] لم يتم كتابة سبب الإلغاء');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('يرجى كتابة سبب الإلغاء'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        reason = _reasonController.text.trim();
      } else {
        reason = _selectedReason;
      }

      debugPrint('✅ [BookingActionsDialog] سبب الإلغاء: $reason');
    }

    // إغلاق الديالوج وإرجاع النتيجة
    debugPrint(
        '🔙 [BookingActionsDialog] إغلاق الديالوج وإرجاع النتيجة: $reason');
    Navigator.of(context).pop(reason);
  }

  /// يحدد النص والأيقونة واللون المناسبين لنوع الإجراء الحالي.
  /// Resolves the title, icon, and color for the current action type.
  _ActionConfig _getActionConfig() {
    switch (widget.action) {
      case BookingAction.cancel:
        return _ActionConfig(
          title: 'إلغاء الحجز',
          icon: CupertinoIcons.xmark_circle_fill,
          color: AppTheme.error,
          confirmText: 'تأكيد الإلغاء',
        );
      case BookingAction.update:
        return _ActionConfig(
          title: 'تحديث الحجز',
          icon: CupertinoIcons.pencil_circle_fill,
          color: AppTheme.warning,
          confirmText: 'تحديث',
        );
      case BookingAction.confirm:
        return _ActionConfig(
          title: 'تأكيد الحجز',
          icon: CupertinoIcons.checkmark_circle_fill,
          color: AppTheme.success,
          confirmText: 'تأكيد',
        );
    }
  }
}

/// Bundles the presentational data needed to render one booking action mode.
///
/// يجمع بيانات العرض اللازمة لرسم وضع إجرائي واحد داخل حوار الحجز.
class _ActionConfig {
  /// عنوان الإجراء الظاهر في رأس الحوار.
  /// Action title shown in the dialog header.
  final String title;

  /// الأيقونة الدلالية المرتبطة بالإجراء.
  /// Semantic icon associated with the action.
  final IconData icon;

  /// اللون الأساسي المستخدم في تمييز الإجراء.
  /// Primary color used to emphasize the action.
  final Color color;

  /// النص الظاهر على زر التأكيد.
  /// Confirmation button label.
  final String confirmText;

  /// Creates the visual configuration that drives dialog copy and styling.
  ///
  /// ينشئ التكوين البصري الذي يحدد نصوص الحوار وأسلوبه.
  const _ActionConfig({
    required this.title,
    required this.icon,
    required this.color,
    required this.confirmText,
  });
}
