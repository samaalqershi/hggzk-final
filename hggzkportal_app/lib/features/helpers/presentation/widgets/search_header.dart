import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

/// يعرّف الكلاس `SearchHeader`.
/// Describes the `SearchHeader` class.
class SearchHeader extends StatelessWidget {
  /// Holds the `title` value.
  /// العربية: يخزن القيمة `title`.
  final String title;

  /// يخزن العضو `searchHint`.
  /// Holds the `searchHint` member.
  final String searchHint;

  /// يخزن العضو `searchController`.
  /// Holds the `searchController` member.
  final TextEditingController searchController;

  /// ينفذ العملية `Function`.
  /// Runs the `Function` operation.
  final Function(String) onSearchChanged;

  /// يخزن العضو `onClearSearch`.
  /// Holds the `onClearSearch` member.
  final VoidCallback onClearSearch;

  /// ينشئ مثيلاً من `SearchHeader`.
  /// Builds an instance of `SearchHeader`.
  const SearchHeader({
    super.key,
    required this.title,
    required this.searchHint,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: AppTextStyles.heading2.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(height: 16),

          // Search Field
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkSurface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.darkBorder.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
              ),
              decoration: InputDecoration(
                hintText: searchHint,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textMuted.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppTheme.textMuted,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: AppTheme.textMuted,
                        ),
                        onPressed: () {
                          searchController.clear();
                          onClearSearch();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
