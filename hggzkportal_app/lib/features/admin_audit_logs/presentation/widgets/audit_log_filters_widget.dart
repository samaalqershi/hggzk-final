// lib/features/admin_audit_logs/presentation/widgets/audit_log_filters_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

/// مجموعة فلاتر قابلة لإعادة الاستخدام لتصفية سجلات التدقيق.
/// Reusable filter bundle for narrowing audit logs by user, date range, type, and search term.
class AuditLogFilters {
  /// المستخدم المراد تقييده ضمن النتائج، أو null لعدم التقييد.
  /// User to scope the results to, or null when not filtering by user.
  final String? userId;

  /// تاريخ البداية لنطاق السجل، أو null لعدم تحديد حد أدنى.
  /// Start date for the log range, or null when no lower bound is applied.
  final DateTime? startDate;

  /// تاريخ النهاية لنطاق السجل، أو null لعدم تحديد حد أعلى.
  /// End date for the log range, or null when no upper bound is applied.
  final DateTime? endDate;

  /// نوع العملية المطلوب عرضه مثل create أو update أو delete.
  /// Operation type to show, such as create, update, or delete.
  final String? operationType;

  /// نص البحث الحر داخل السجلات.
  /// Free-text search term used across the audit logs.
  final String? searchTerm;

  /// ينشئ مجموعة الفلاتر بقيم اختيارية مستقلة لكل حقل.
  /// Creates a filter bundle with independent optional values for each field.
  const AuditLogFilters({
    this.userId,
    this.startDate,
    this.endDate,
    this.operationType,
    this.searchTerm,
  });

  /// ينسخ الفلاتر مع استبدال أي قيمة يمررها المستدعي.
  /// Returns a copy of the filters with any supplied overrides applied.
  AuditLogFilters copyWith({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    String? operationType,
    String? searchTerm,
  }) {
    return AuditLogFilters(
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      operationType: operationType ?? this.operationType,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }
}

/// واجهة تفاعلية تسمح بتحديد نطاق التاريخ ونوع العملية ونص البحث.
/// Interactive filter panel that lets the user choose date range, type, and search text.
class AuditLogFiltersWidget extends StatefulWidget {
  /// الفلاتر الأولية التي تبدأ بها الواجهة، إن وجدت.
  /// Initial filters used when the widget opens, if any.
  final AuditLogFilters? initialFilters;

  /// يستدعى كلما تغيرت الفلاتر ليتم تطبيقها على القائمة الأعلى.
  /// Called whenever filters change so the parent can refresh the list.
  final Function(AuditLogFilters) onFiltersChanged;

  /// ينشئ الواجهة مع فلاتر ابتدائية ورد التحديث.
  const AuditLogFiltersWidget({
    super.key,
    this.initialFilters,
    required this.onFiltersChanged,
  });

  /// ينشئ الحالة التي تدير الحقول الزمانية والنصية.
  @override
  State<AuditLogFiltersWidget> createState() => _AuditLogFiltersWidgetState();
}

/// تدير هذه الحالة حقول الإدخال والفلاتر السريعة ونطاق التاريخ.
/// Manages text input, quick filters, and the date-range controls.
class _AuditLogFiltersWidgetState extends State<AuditLogFiltersWidget> {
  /// نسخة العمل الحالية من الفلاتر أثناء تعديل المستخدم.
  /// Working filter snapshot updated as the user edits controls.
  late AuditLogFilters _filters;

  /// يتحكم في نص البحث الحر.
  /// Controls the free-text search field.
  final TextEditingController _searchController = TextEditingController();

  /// يحدد ما إذا كانت الفلاتر الإضافية ظاهرة في العرض المضغوط.
  /// Indicates whether extra filters are visible in the compact layout.
  bool _isExpanded = false;

  /// يهيئ الحالة بقيم الفلاتر الابتدائية.
  /// Initializes state using the provided initial filters.
  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters ?? const AuditLogFilters();
    _searchController.text = _filters.searchTerm ?? '';
  }

  /// يحرر متحكم البحث عند إزالة الواجهة.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// يبني واجهة الفلاتر المناسبة حسب عرض الشاشة.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 400;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCompact) _buildCompactFilters() else _buildFullFilters(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// يبني نسخة مدمجة من الفلاتر للشاشات الضيقة.
  Widget _buildCompactFilters() {
    return Column(
      children: [
        _buildSearchField(isCompact: true),
        const SizedBox(height: 8),
        _buildCompactDateSelector(),
        const SizedBox(height: 8),
        _buildQuickFilters(isCompact: true),
        if (_isExpanded) ...[
          const SizedBox(height: 8),
          _buildOperationTypeDropdown(isCompact: true),
        ],
        const SizedBox(height: 8),
        _buildExpandButton(),
      ],
    );
  }

  /// يبني النسخة الكاملة من الفلاتر للشاشات الأوسع.
  Widget _buildFullFilters() {
    return Column(
      children: [
        _buildDateRangeSelector(),
        const SizedBox(height: 12),
        _buildSearchAndTypeRow(),
        const SizedBox(height: 12),
        _buildQuickFilters(isCompact: false),
      ],
    );
  }

  /// يبني زر التوسيع الذي يكشف المزيد من الفلاتر.
  Widget _buildExpandButton() {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.darkBorder.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isExpanded ? 'إخفاء الفلاتر' : 'المزيد من الفلاتر',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.primaryPurple,
              ),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                CupertinoIcons.chevron_down,
                size: 14,
                color: AppTheme.primaryPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// يبني محدد التاريخ المختصر الخاص بالعرض المضغوط.
  Widget _buildCompactDateSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _buildDateButton(
                  label: 'من',
                  date: _filters.startDate,
                  onTap: () => _selectDate(true),
                  isFullWidth: true,
                ),
                const SizedBox(height: 8),
                _buildDateButton(
                  label: 'إلى',
                  date: _filters.endDate,
                  onTap: () => _selectDate(false),
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// يبني شريط تحديد نطاق التاريخ في العرض الكامل.
  Widget _buildDateRangeSelector() {
    return Container(
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
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateButton(
                    label: 'من',
                    date: _filters.startDate,
                    onTap: () => _selectDate(true),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 20,
                  height: 1,
                  color: AppTheme.darkBorder.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildDateButton(
                    label: 'إلى',
                    date: _filters.endDate,
                    onTap: () => _selectDate(false),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// يبني زر تاريخ فردي يعرض التاريخ المختار أو نصًا بديلًا.
  Widget _buildDateButton({
    required String label,
    DateTime? date,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.darkBackground.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: date != null
                ? AppTheme.primaryPurple.withValues(alpha: 0.3)
                : AppTheme.darkBorder.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null ? Formatters.formatDate(date) : 'اختر التاريخ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: date != null
                          ? AppTheme.textWhite
                          : AppTheme.textMuted,
                      fontWeight: date != null ? FontWeight.w600 : null,
                      fontSize: date != null ? 13 : 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_down,
              size: 14,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  /// يبني صف البحث مع قائمة نوع العملية في العرض الكامل.
  Widget _buildSearchAndTypeRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildSearchField(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOperationTypeDropdown(),
        ),
      ],
    );
  }

  /// يبني حقل البحث الحر ويحدث الفلاتر عند كل تغيير.
  Widget _buildSearchField({bool isCompact = false}) {
    return Container(
      height: isCompact ? 40 : null,
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textWhite,
          fontSize: isCompact ? 13 : 14,
        ),
        decoration: InputDecoration(
          hintText: isCompact ? 'بحث...' : 'بحث في السجلات...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted,
            fontSize: isCompact ? 13 : 14,
          ),
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: AppTheme.textMuted,
            size: isCompact ? 18 : 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isCompact ? 12 : 16,
            vertical: isCompact ? 8 : 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _filters = _filters.copyWith(searchTerm: value);
          });
          _applyFilters();
        },
      ),
    );
  }

  /// يبني قائمة منسدلة لتحديد نوع العملية المطلوبة.
  Widget _buildOperationTypeDropdown({bool isCompact = false}) {
    return Container(
      height: isCompact ? 40 : null,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 12),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButton<String?>(
        value: _filters.operationType,
        isExpanded: true,
        dropdownColor: AppTheme.darkCard,
        underline: const SizedBox.shrink(),
        hint: Text(
          'جميع العمليات',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted,
            fontSize: isCompact ? 12 : 14,
          ),
        ),
        icon: Icon(
          CupertinoIcons.chevron_down,
          size: isCompact ? 14 : 16,
          color: AppTheme.textMuted,
        ),
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textWhite,
          fontSize: isCompact ? 12 : 14,
        ),
        items: const [
          DropdownMenuItem(value: null, child: Text('جميع العمليات')),
          DropdownMenuItem(value: 'create', child: Text('إضافة')),
          DropdownMenuItem(value: 'update', child: Text('تحديث')),
          DropdownMenuItem(value: 'delete', child: Text('حذف')),
          DropdownMenuItem(value: 'login', child: Text('دخول')),
          DropdownMenuItem(value: 'logout', child: Text('خروج')),
        ],
        onChanged: (value) {
          setState(() {
            _filters = _filters.copyWith(operationType: value);
          });
          _applyFilters();
        },
      ),
    );
  }

  /// يبني الفلاتر السريعة مثل اليوم والأسبوع والشهر.
  Widget _buildQuickFilters({bool isCompact = false}) {
    return SizedBox(
      height: isCompact ? 32 : 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildQuickFilterChip(
            label: 'اليوم',
            isSelected: _isToday(),
            onTap: _selectToday,
            isCompact: isCompact,
          ),
          _buildQuickFilterChip(
            label: 'هذا الأسبوع',
            isSelected: _isThisWeek(),
            onTap: _selectThisWeek,
            isCompact: isCompact,
          ),
          _buildQuickFilterChip(
            label: 'هذا الشهر',
            isSelected: _isThisMonth(),
            onTap: _selectThisMonth,
            isCompact: isCompact,
          ),
          _buildQuickFilterChip(
            label: 'العمليات البطيئة',
            isSelected: false,
            onTap: () {},
            isCompact: isCompact,
            color: AppTheme.warning,
          ),
          _buildQuickFilterChip(
            label: 'مسح',
            isSelected: false,
            onTap: _clearFilters,
            isAction: true,
            isCompact: isCompact,
          ),
        ],
      ),
    );
  }

  /// يبني شارة فلتر سريعة قابلة للنقر لتطبيق نطاق جاهز.
  Widget _buildQuickFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isAction = false,
    bool isCompact = false,
    Color? color,
  }) {
    final chipColor = color ?? AppTheme.primaryPurple;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isCompact ? 16 : 18),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12 : 16,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        chipColor.withValues(alpha: 0.3),
                        chipColor.withValues(alpha: 0.2),
                      ],
                    )
                  : null,
              color: isSelected
                  ? null
                  : isAction
                      ? AppTheme.error.withValues(alpha: 0.1)
                      : AppTheme.darkCard.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(isCompact ? 16 : 18),
              border: Border.all(
                color: isSelected
                    ? chipColor
                    : isAction
                        ? AppTheme.error.withValues(alpha: 0.3)
                        : AppTheme.darkBorder.withValues(alpha: 0.2),
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected
                      ? Colors.white
                      : isAction
                          ? AppTheme.error
                          : AppTheme.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                  fontSize: isCompact ? 11 : 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// يفتح منتقي التاريخ ويحدّث بداية أو نهاية النطاق.
  void _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _filters.startDate ?? DateTime.now()
          : _filters.endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryPurple,
              onPrimary: Colors.white,
              surface: AppTheme.darkCard,
              onSurface: AppTheme.textWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _filters = _filters.copyWith(startDate: picked);
        } else {
          _filters = _filters.copyWith(endDate: picked);
        }
      });
      _applyFilters();
    }
  }

  /// يتحقق من كون الفلاتر الحالية تمثل اليوم.
  bool _isToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _filters.startDate == today &&
        _filters.endDate == today.add(const Duration(days: 1));
  }

  /// يتحقق من كون الفلاتر الحالية تمثل هذا الأسبوع.
  bool _isThisWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _filters.startDate == weekStart && _filters.endDate == weekEnd;
  }

  /// يتحقق من كون الفلاتر الحالية تمثل هذا الشهر.
  bool _isThisMonth() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    return _filters.startDate == monthStart && _filters.endDate == monthEnd;
  }

  /// يضبط الفلاتر على نطاق اليوم الحالي.
  void _selectToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _filters = _filters.copyWith(
        startDate: today,
        endDate: today.add(const Duration(days: 1)),
      );
    });
    _applyFilters();
  }

  /// يضبط الفلاتر على نطاق الأسبوع الحالي.
  void _selectThisWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    setState(() {
      _filters = _filters.copyWith(
        startDate: weekStart,
        endDate: weekEnd,
      );
    });
    _applyFilters();
  }

  /// يضبط الفلاتر على نطاق الشهر الحالي.
  void _selectThisMonth() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    setState(() {
      _filters = _filters.copyWith(
        startDate: monthStart,
        endDate: monthEnd,
      );
    });
    _applyFilters();
  }

  /// يمسح جميع الفلاتر ويعيد حقل البحث إلى حالته الافتراضية.
  void _clearFilters() {
    setState(() {
      _filters = const AuditLogFilters();
      _searchController.clear();
    });
    _applyFilters();
  }

  /// يرسل الفلاتر الحالية إلى الطبقة الأعلى لتطبيقها على النتائج.
  void _applyFilters() {
    widget.onFiltersChanged(_filters);
  }
}
