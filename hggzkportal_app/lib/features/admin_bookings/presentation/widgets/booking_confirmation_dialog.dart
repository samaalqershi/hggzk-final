// lib/features/admin_bookings/presentation/widgets/booking_confirmation_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

/// يحدد ما إذا كان مربع الحوار يؤكد الحجز أو يلغيه.
/// Indicates whether the dialog confirms or cancels a booking.
enum BookingConfirmationType {
  confirm,
  cancel,
}

/// يعرض مربع حوار نهائيًا لإقرار الحجز أو إلغائه مع شرح واضح للإجراء.
/// Shows a final confirmation dialog for confirming or canceling a booking.
class BookingConfirmationDialog extends StatelessWidget {
  /// يحدد نوع الإجراء المراد تأكيده من خلال مربع الحوار.
  /// Defines the action type being confirmed in the dialog.
  final BookingConfirmationType type;

  /// يعرّف الحجز المستهدف الذي سيُنفذ عليه الإجراء.
  /// Identifies the target booking that will receive the action.
  final String bookingId;

  /// الرقم المرجعي الظاهر للمستخدم لمطابقة الحجز بسهولة.
  /// Optional reference visible to the user for easier booking matching.
  final String? bookingReference;

  /// يستدعى بعد تأكيد المستخدم للإجراء.
  /// Called after the user confirms the action.
  final VoidCallback onConfirm;

  /// نص مخصص للعنوان عندما لا تكفي الصياغة الافتراضية.
  /// Optional custom title when the default wording is not enough.
  final String? customTitle;

  /// نص مخصص للوصف التوضيحي أعلى الأزرار.
  /// Optional custom subtitle shown above the action buttons.
  final String? customSubtitle;

  /// نص مخصص لزر التأكيد في مربع الحوار.
  /// Optional custom label for the confirmation button.
  final String? customConfirmText;

  /// ينشئ مربع الحوار مع القيم المخصصة أو الافتراضية المناسبة.
  /// Creates the dialog with custom or default content values.
  const BookingConfirmationDialog({
    super.key,
    required this.type,
    required this.bookingId,
    this.bookingReference,
    required this.onConfirm,
    this.customTitle,
    this.customSubtitle,
    this.customConfirmText,
  });

  /// يبني واجهة التأكيد أو الإلغاء مع الحالة اللونية والنص المناسب.
  /// Builds the confirm/cancel dialog with the proper color and copy.
  @override
  Widget build(BuildContext context) {
    final isConfirm = type == BookingConfirmationType.confirm;
    final color = isConfirm ? AppTheme.success : AppTheme.error;
    final icon = isConfirm ? Icons.check_circle_outline : Icons.cancel_outlined;
    final defaultTitle = isConfirm ? 'تأكيد الحجز؟' : 'إلغاء الحجز؟';
    final defaultSubtitle = isConfirm
        ? 'سيتم تأكيد الحجز وإرسال إشعار للعميل'
        : 'لا يمكن التراجع عن هذا الإجراء';
    final defaultConfirmText = isConfirm ? 'تأكيد' : 'إلغاء الحجز';
    final resolvedTitle = customTitle ?? defaultTitle;
    final resolvedSubtitle = customSubtitle ?? defaultSubtitle;
    final resolvedConfirmText = customConfirmText ?? defaultConfirmText;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.1),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                resolvedTitle,
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                resolvedSubtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),

              // Booking Reference (if provided)
              if (bookingReference != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.darkBackground.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'رقم الحجز: $bookingReference',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'رجوع',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: AppTheme.textLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Confirm Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        resolvedConfirmText,
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// يفتح مربع حوار التأكيد الخاص بالحجز داخل نافذة منبثقة مركزية.
/// Opens the booking confirmation dialog in a centered modal route.
Future<void> showBookingConfirmationDialog({
  required BuildContext context,
  required BookingConfirmationType type,
  required String bookingId,
  String? bookingReference,
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    fullscreenDialog: true,
    barrierColor: Colors.black87,
    builder: (context) => BookingConfirmationDialog(
      type: type,
      bookingId: bookingId,
      bookingReference: bookingReference,
      onConfirm: onConfirm,
    ),
  );
}
