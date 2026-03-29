// lib/features/notifications/presentation/widgets/notification_filter_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:hggzk/core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Expandable filter panel that lets the user narrow notifications by type
/// and unread state.
/// لوحة فلاتر قابلة للفتح تضيق الإشعارات حسب النوع وحالة غير المقروء.
class NotificationFilterWidget extends StatefulWidget {
  /// Currently selected notification type filter.
  /// نوع الفلتر الحالي للإشعارات.
  final String? selectedType;

  /// Whether the list should show unread notifications only.
  /// يحدد ما إذا كانت القائمة تعرض غير المقروء فقط.
  final bool? showUnreadOnly;

  /// Notifies the host screen whenever the filter selection changes.
  /// يبلغ الشاشة المضيفة عند تغيّر الفلتر.
  final Function(String?, bool?) onFilterChanged;

  /// Builds the notification filter panel.
  /// ينشئ لوحة فلترة الإشعارات.
  const NotificationFilterWidget({
    super.key,
    this.selectedType,
    this.showUnreadOnly,
    required this.onFilterChanged,
  });

  /// Creates the mutable filter state.
  /// ينشئ حالة الفلتر القابلة للتغيير.
  @override
  State<NotificationFilterWidget> createState() =>
      _NotificationFilterWidgetState();
}

/// Tracks the expanded state and the active filter selections.
/// يتتبع حالة الفتح والاختيارات النشطة للفلاتر.
class _NotificationFilterWidgetState extends State<NotificationFilterWidget> {
  /// Internal copy of the selected type.
  /// نسخة داخلية من نوع الفلتر المختار.
  late String? _selectedType;

  /// Internal toggle for unread-only mode.
  /// مفتاح داخلي لوضع غير المقروء فقط.
  late bool _showUnreadOnly;

  /// Whether the panel is currently expanded.
  /// يحدد ما إذا كانت اللوحة مفتوحة الآن.
  bool _isExpanded = false;

  /// Available filter choices shown to the user.
  /// خيارات الفلاتر المتاحة للمستخدم.
  final List<FilterOption> _filterOptions = [
    FilterOption('all', 'all', CupertinoIcons.square_grid_2x2),
    FilterOption('booking', 'booking', CupertinoIcons.calendar),
    FilterOption('payment', 'payment', CupertinoIcons.creditcard_fill),
    FilterOption('promotion', 'promotion', CupertinoIcons.gift_fill),
    FilterOption('system', 'system', CupertinoIcons.gear_solid),
  ];

  /// Seeds the local state from the widget inputs.
  /// يهيئ الحالة المحلية من مدخلات الواجهة.
  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _showUnreadOnly = widget.showUnreadOnly ?? false;
  }

  /// Renders the compact header and the expanded filter options.
  /// يرسم الرأس المضغوط وخيارات الفلتر عند التوسيع.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 400;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isExpanded ? (isCompact ? 150 : 120) : 50,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12 : 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.darkBorder.withValues(alpha: 0.2),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(isCompact),
                  if (_isExpanded) ...[
                    const SizedBox(height: 12),
                    if (isCompact)
                      _buildCompactFilters()
                    else
                      _buildFullFilters(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the tap target that toggles the filter panel.
  /// ينشئ منطقة النقر التي تبدل فتح اللوحة وإغلاقها.
  Widget _buildHeader(bool isCompact) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.line_horizontal_3_decrease,
            color: AppTheme.primaryBlue,
            size: isCompact ? 18 : 20,
          ),
          SizedBox(width: isCompact ? 8 : 12),
          Text(
            context.tr(
              'notifications.page.filterAll',
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (_selectedType != null || _showUnreadOnly) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getActiveFiltersCount().toString(),
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              CupertinoIcons.chevron_down,
              color: AppTheme.textMuted,
              size: isCompact ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the compact layout used on narrow widths.
  /// ينشئ التخطيط المضغوط المستخدم في الشاشات الضيقة.
  Widget _buildCompactFilters() {
    return Column(
      children: [
        // Type filters as scrollable chips
        SizedBox(
          height: 32,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _filterOptions.length,
            itemBuilder: (context, index) {
              final option = _filterOptions[index];
              return _buildFilterChip(option);
            },
          ),
        ),
        const SizedBox(height: 12),
        // Unread toggle
        _buildUnreadToggle(isCompact: true),
      ],
    );
  }

  /// Builds the wider layout used on larger screens.
  /// ينشئ التخطيط الأوسع المستخدم في الشاشات الكبيرة.
  Widget _buildFullFilters() {
    return Column(
      children: [
        // Type filter chips in a row
        SizedBox(
          height: 36,
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filterOptions.length,
                  itemBuilder: (context, index) {
                    final option = _filterOptions[index];
                    return _buildFilterChip(option);
                  },
                ),
              ),
              const SizedBox(width: 16),
              _buildUnreadToggle(isCompact: false),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds one selectable notification type chip.
  /// ينشئ شريحة اختيار واحدة لنوع الإشعار.
  Widget _buildFilterChip(FilterOption option) {
    final isSelected = _selectedType == option.value ||
        (option.value == 'all' && _selectedType == null);
    final label = _labelForOption(context, option.value);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedType = option.value == 'all' ? null : option.value;
            });
            widget.onFilterChanged(_selectedType, _showUnreadOnly);
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.primaryGradient : null,
              color:
                  isSelected ? null : AppTheme.darkCard.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : AppTheme.darkBorder.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  option.icon,
                  size: 14,
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? Colors.white : AppTheme.textMuted,
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

  /// Builds the unread-only toggle switch-like control.
  /// ينشئ عنصر التبديل لوضع غير المقروء فقط.
  Widget _buildUnreadToggle({required bool isCompact}) {
    return GestureDetector(
      onTap: () {
        setState(() => _showUnreadOnly = !_showUnreadOnly);
        widget.onFilterChanged(_selectedType, _showUnreadOnly);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 10 : 12,
          vertical: isCompact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          gradient: _showUnreadOnly ? AppTheme.primaryGradient : null,
          color:
              _showUnreadOnly ? null : AppTheme.darkCard.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _showUnreadOnly
                ? Colors.transparent
                : AppTheme.darkBorder.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _showUnreadOnly
                    ? Colors.white
                    : AppTheme.darkBorder.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _showUnreadOnly
                  ? Icon(
                      CupertinoIcons.checkmark,
                      size: 12,
                      color: AppTheme.primaryBlue,
                    )
                  : null,
            ),
            const SizedBox(width: 6),
            Text(
              context.tr(
                'notifications.page.filterUnread',
              ),
              style: AppTextStyles.caption.copyWith(
                color: _showUnreadOnly ? Colors.white : AppTheme.textMuted,
                fontWeight: _showUnreadOnly ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Counts how many filters are currently active.
  /// يحصي عدد الفلاتر النشطة حاليًا.
  int _getActiveFiltersCount() {
    int count = 0;
    if (_selectedType != null) count++;
    if (_showUnreadOnly) count++;
    return count;
  }

  String _labelForOption(BuildContext context, String value) {
    switch (value) {
      case 'all':
        return context.tr('notifications.page.filterAll');
      case 'booking':
        return context.tr(
          'notifications.page.filterBooking',
        );
      case 'payment':
        return context.tr(
          'notifications.page.filterPayment',
        );
      case 'promotion':
        return context.tr(
          'notifications.page.filterPromotion',
        );
      case 'system':
        return context.tr(
          'notifications.page.filterSystem',
        );
      default:
        return value;
    }
  }
}

/// Represents one selectable notification filter option.
/// يمثل خيار فلترة واحدًا يمكن اختياره.
class FilterOption {
  /// Internal value used when the filter is applied.
  /// القيمة الداخلية المستخدمة عند تطبيق الفلتر.
  final String value;

  /// Localized label shown in the chip.
  /// التسمية المحلية الظاهرة داخل الشريحة.
  final String label;

  /// Icon used to visually distinguish the filter.
  /// الأيقونة المستخدمة لتمييز الفلتر بصريًا.
  final IconData icon;

  /// Builds one filter option descriptor.
  /// ينشئ وصفًا لخيار فلترة واحد.
  FilterOption(this.value, this.label, this.icon);
}
