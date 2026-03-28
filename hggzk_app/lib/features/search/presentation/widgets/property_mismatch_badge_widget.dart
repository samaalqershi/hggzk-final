import 'package:flutter/material.dart';
import 'package:hggzk/core/theme/app_text_styles.dart';
import '../../data/models/property_filter_mismatch_model.dart';

/// Shows the search constraints that the property does not satisfy.
/// يعرض القيود التي لا يطابقها العقار من معايير البحث.
class PropertyMismatchBadgeWidget extends StatelessWidget {
  /// Search mismatches returned by the backend.
  /// فروقات البحث التي يعيدها الخادم.
  final List<PropertyFilterMismatchModel> mismatches;

  /// True when the badge should show only the count instead of details.
  /// تكون صحيحة عندما يجب عرض العدد فقط بدل التفاصيل.
  final bool compact;

  /// Builds a compact or detailed badge depending on the available space.
  /// ينشئ شارة مختصرة أو مفصلة بحسب المساحة المتاحة.
  const PropertyMismatchBadgeWidget({
    super.key,
    required this.mismatches,
    this.compact = true,
  });

  /// Renders the mismatch badge in compact or detailed form.
  /// يرسم شارة الفروقات بصيغة مختصرة أو مفصلة.
  @override
  Widget build(BuildContext context) {
    // Hide the badge when there are no mismatches to communicate.
    if (mismatches.isEmpty) return const SizedBox.shrink();

    return compact ? _buildCompactView(context) : _buildDetailedView(context);
  }

  /// Renders the compact badge with just the mismatch count.
  /// يرسم الشارة المختصرة التي تعرض عدد الفروقات فقط.
  Widget _buildCompactView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Text(
            '${mismatches.length} فرق',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.orange[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Renders the detailed list of individual mismatches.
  /// يرسم قائمة الفروقات المفصلة لكل عنصر على حدة.
  Widget _buildDetailedView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'فروقات عن طلبك:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: mismatches.map((mismatch) {
            return _buildMismatchChip(context, mismatch);
          }).toList(),
        ),
      ],
    );
  }

  /// Builds one visual chip for a specific mismatch.
  /// يبني شريحة مرئية لفروقة واحدة محددة.
  Widget _buildMismatchChip(
      BuildContext context, PropertyFilterMismatchModel mismatch) {
    final color = _getColorForSeverity(mismatch.severity);
    final icon = _getIconForSeverity(mismatch.severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              mismatch.displayMessage,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Maps mismatch severity to the badge color.
  /// يطابق شدة الفروقة مع لون الشارة.
  Color _getColorForSeverity(MismatchSeverity severity) {
    switch (severity) {
      case MismatchSeverity.minor:
        return Colors.blue;
      case MismatchSeverity.moderate:
        return Colors.orange;
      case MismatchSeverity.major:
        return Colors.red;
    }
  }

  /// Maps mismatch severity to the badge icon.
  /// يطابق شدة الفروقة مع أيقونة الشارة.
  IconData _getIconForSeverity(MismatchSeverity severity) {
    switch (severity) {
      case MismatchSeverity.minor:
        return Icons.info_outline_rounded;
      case MismatchSeverity.moderate:
        return Icons.warning_amber_rounded;
      case MismatchSeverity.major:
        return Icons.error_outline_rounded;
    }
  }
}
