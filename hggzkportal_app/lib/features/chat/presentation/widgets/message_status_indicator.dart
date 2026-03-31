import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/message.dart';

/// Small delivery marker that explains whether a message is still sending,
/// delivered, read, or failed.
/// مؤشر صغير يوضح ما إذا كانت الرسالة ما زالت تُرسل أو وصلت أو قُرئت أو
/// فشلت.
class MessageStatusIndicator extends StatelessWidget {
  /// Delivery state that determines the icon and visual emphasis.
  /// حالة التسليم التي تحدد الأيقونة والظهور البصري.
  final String status;

  /// Optional color override used by the surrounding message bubble.
  /// لون اختياري يمكن للفقاعة المحيطة فرضه.
  final Color? color;

  /// Base icon size used to keep the status marker compact.
  /// الحجم الأساسي للأيقونة حتى يبقى المؤشر صغيرًا.
  final double size;

  /// Optional delivery receipt metadata used to infer a stronger effective
  /// status when the plain status string is stale.
  final DeliveryReceipt? deliveryReceipt;

  /// Builds the delivery marker for a single message bubble.
  /// ينشئ مؤشر التسليم لفقاعة رسالة واحدة.
  const MessageStatusIndicator({
    super.key,
    required this.status,
    this.color,
    this.size = 14, // Reduced from 16
    this.deliveryReceipt,
  });

  /// Resolves the visual icon for the current delivery status.
  /// يحدد الأيقونة المناسبة لحالة التسليم الحالية.
  @override
  Widget build(BuildContext context) {
    final effectiveStatus = _resolveEffectiveStatus();

    if (effectiveStatus == 'sending') {
      return SizedBox(
        width: size + 2,
        height: size + 2,
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: CircularProgressIndicator(
            strokeWidth: 1.6,
            valueColor: AlwaysStoppedAnimation<Color>(
              (color ?? AppTheme.textMuted).withOpacity(0.75),
            ),
          ),
        ),
      );
    }

    IconData iconData;
    Color iconColor;
    double opacity = 1.0;

    switch (effectiveStatus) {
      case 'sent':
        iconData = Icons.check_rounded;
        iconColor = color ?? AppTheme.textMuted;
        opacity = 0.6;
        break;
      case 'delivered':
        iconData = Icons.done_all_rounded;
        iconColor = color ?? AppTheme.textMuted;
        opacity = 0.7;
        break;
      case 'read':
        iconData = Icons.done_all_rounded;
        iconColor = color ?? AppTheme.primaryBlue;
        opacity = 0.9;
        break;
      case 'failed':
        iconData = Icons.error_outline_rounded;
        iconColor = AppTheme.error;
        opacity = 0.8;
        break;
      default:
        iconData = Icons.check_rounded;
        iconColor = color ?? AppTheme.textMuted;
        opacity = 0.5;
    }

    return Container(
      width: size + 2,
      height: size + 2,
      decoration: effectiveStatus == 'read'
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ],
            )
          : null,
      child: Icon(
        iconData,
        size: size,
        color: iconColor.withOpacity(opacity),
      ),
    );
  }

  String _resolveEffectiveStatus() {
    final normalizedStatus = status.trim().toLowerCase();
    final receipt = deliveryReceipt;

    if (receipt?.readAt != null || (receipt?.readBy.isNotEmpty ?? false)) {
      return 'read';
    }

    if (receipt?.deliveredAt != null) {
      return 'delivered';
    }

    return normalizedStatus;
  }
}
