import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/search_result.dart';

/// يعرّف الكلاس `SearchItemCard`.
/// Describes the `SearchItemCard` class.
class SearchItemCard extends StatelessWidget {
  /// Holds the `item` value.
  /// العربية: يخزن القيمة `item`.
  final SearchResult item;

  /// يخزن العضو `onTap`.
  /// Holds the `onTap` member.
  final VoidCallback onTap;

  /// يخزن العضو `isSelected`.
  /// Holds the `isSelected` member.
  final bool isSelected;

  /// ينشئ مثيلاً من `SearchItemCard`.
  /// Builds an instance of `SearchItemCard`.
  const SearchItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.isSelected = false,
  });

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : AppTheme.darkCard.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                : AppTheme.darkBorder.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Image or Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.darkSurface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                      ),
                    )
                  : _buildPlaceholderIcon(),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Selection Indicator
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ينفذ العملية `_buildPlaceholderIcon`.
  /// Runs the `_buildPlaceholderIcon` operation.
  Widget _buildPlaceholderIcon() {
    IconData iconData;

    // Determine icon based on metadata
    if (item.metadata != null) {
      if (item.metadata!.containsKey('role')) {
        iconData = Icons.person_rounded;
      } else if (item.metadata!.containsKey('type')) {
        iconData = Icons.business_rounded;
      } else if (item.metadata!.containsKey('unitType')) {
        iconData = Icons.room_preferences_rounded;
      } else if (item.metadata!.containsKey('country')) {
        iconData = Icons.location_city_rounded;
      } else if (item.metadata!.containsKey('status')) {
        iconData = Icons.calendar_today_rounded;
      } else {
        iconData = Icons.folder_rounded;
      }
    } else {
      iconData = Icons.folder_rounded;
    }

    return Icon(
      iconData,
      color: AppTheme.textMuted.withValues(alpha: 0.5),
      size: 24,
    );
  }
}
