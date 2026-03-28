import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

/// يعرّف الكلاس `SimpleFilterBar`.
/// Describes the `SimpleFilterBar` class.
class SimpleFilterBar extends StatelessWidget {
  /// Holds the `filters` value.
  /// العربية: يخزن القيمة `filters`.
  final List<FilterOption> filters;

  /// يخزن العضو `onClearFilters`.
  /// Holds the `onClearFilters` member.
  final VoidCallback? onClearFilters;

  /// ينشئ مثيلاً من `SimpleFilterBar`.
  /// Builds an instance of `SimpleFilterBar`.
  const SimpleFilterBar({
    super.key,
    required this.filters,
    this.onClearFilters,
  });

  /// ينفذ العملية `build`.
  /// Runs the `build` operation.
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (onClearFilters != null)
            GestureDetector(
              onTap: onClearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.error.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.clear_rounded,
                      size: 16,
                      color: AppTheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'مسح',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(width: 8),
          ...filters.map((filter) => _buildFilterChip(filter)),
        ],
      ),
    );
  }

  /// ينفذ العملية `_buildFilterChip`.
  /// Runs the `_buildFilterChip` operation.
  Widget _buildFilterChip(FilterOption filter) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(filter.label),
        selected: filter.isSelected,
        onSelected: filter.onChanged,
        backgroundColor: AppTheme.darkSurface.withValues(alpha: 0.3),
        selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
        labelStyle: AppTextStyles.caption.copyWith(
          color: filter.isSelected ? AppTheme.primaryBlue : AppTheme.textMuted,
        ),
        side: BorderSide(
          color: filter.isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.5)
              : AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
    );
  }
}

/// يعرّف الكلاس `FilterOption`.
/// Describes the `FilterOption` class.
class FilterOption {
  /// Holds the `label` value.
  /// العربية: يخزن القيمة `label`.
  final String label;

  /// يخزن العضو `isSelected`.
  /// Holds the `isSelected` member.
  final bool isSelected;

  /// ينفذ العملية `Function`.
  /// Runs the `Function` operation.
  final Function(bool) onChanged;

  /// ينشئ مثيلاً من `FilterOption`.
  /// Builds an instance of `FilterOption`.
  FilterOption({
    required this.label,
    required this.isSelected,
    required this.onChanged,
  });
}
