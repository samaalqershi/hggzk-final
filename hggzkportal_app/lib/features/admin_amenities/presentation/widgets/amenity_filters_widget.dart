import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

/// شريط فلاتر قابل للطي يضبط البحث ونوع العقار وحالة إسناد المرافق.
/// Collapsible filter bar that controls search, property type, and amenity assignment state.
class AmenityFiltersWidget extends StatefulWidget {
  /// يعيد القيم المجمعة للفلاتر بعد أي تعديل.
  /// Returns the combined filter values after any update.
  final Function(String?, bool?, bool?, String?) onFilterChanged;

  /// نص البحث الذي يبدأ به الحقل عند فتح الصفحة.
  /// Search text used to seed the field when the page opens.
  final String? initialSearchTerm;

  /// الحالة الابتدائية لفلتر المرافق المسندة.
  /// Initial state for the assigned-amenity filter.
  final bool? initialIsAssigned;

  /// الحالة الابتدائية لفلتر المرافق المجانية.
  /// Initial state for the free-amenity filter.
  final bool? initialIsFree;

  /// معرّف نوع العقار المبدئي الذي يقيّد النتائج.
  /// Initial property type id used to scope the results.
  final String? initialPropertyTypeId;

  /// ينشئ شريط الفلاتر مع القيم المبدئية الواردة من الصفحة الأم.
  /// Creates the filter bar with initial values supplied by the parent page.
  const AmenityFiltersWidget({
    super.key,
    required this.onFilterChanged,
    this.initialSearchTerm,
    this.initialIsAssigned,
    this.initialIsFree,
    this.initialPropertyTypeId,
  });

  /// ينشئ حالة الشريط التي تدير التوسيع والمدخلات والعداد.
  /// Creates the bar state that manages expansion, inputs, and counts.
  @override
  State<AmenityFiltersWidget> createState() => _AmenityFiltersWidgetState();
}

/// تدير هذه الحالة فتح وإغلاق لوحة الفلاتر وتحديث قيم البحث والاختيارات.
/// Manages opening/closing the filter panel and syncing search and option values.
class _AmenityFiltersWidgetState extends State<AmenityFiltersWidget>
    with SingleTickerProviderStateMixin {
  /// يتحكم في حركة التوسع والانكماش.
  /// Controls the expand/collapse animation.
  late AnimationController _animationController;

  /// يحدد مقدار ظهور المحتوى المنزلق.
  /// Controls how much of the content is revealed during the transition.
  late Animation<double> _expandAnimation;

  /// متحكم نص البحث.
  /// Search field text controller.
  late TextEditingController _searchController;

  /// يحدد ما إذا كانت اللوحة الموسعة ظاهرة.
  /// Indicates whether the expanded panel is visible.
  bool _isExpanded = false;

  /// نص البحث الحالي.
  /// Current search term.
  String? _searchTerm;

  /// فلتر المرافق المسندة.
  /// Assigned amenities filter.
  bool? _isAssigned;

  /// فلتر المرافق المجانية.
  /// Free amenities filter.
  bool? _isFree;

  /// معرّف نوع العقار النشط.
  /// Active property type id.
  String? _propertyTypeId;

  /// يهيئ القيم الابتدائية وحركة التوسع عند إنشاء الودجت.
  /// Initializes the initial values and expand animation when the widget is created.
  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: widget.initialSearchTerm ?? '');
    _searchTerm = widget.initialSearchTerm;
    _isAssigned = widget.initialIsAssigned;
    _isFree = widget.initialIsFree;
    _propertyTypeId = widget.initialPropertyTypeId;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  /// يحرر متحكمات النص والحركة عند إزالة الودجت.
  /// Disposes the text and animation controllers when the widget is removed.
  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// يبني الحاوية الزجاجية والرأس واللوحة القابلة للطي.
  /// Builds the glass container, header, and collapsible filter body.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              _buildHeader(),
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: _buildFilters(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// يبني الرأس القابل للنقر الذي يفتح لوحة الفلاتر ويعرض عدد الفلاتر النشطة.
  /// Builds the tappable header that opens the filter panel and shows active filter count.
  Widget _buildHeader() {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _isExpanded
                  ? AppTheme.primaryBlue.withValues(alpha: 0.2)
                  : Colors.transparent,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.filter_list_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'الفلاتر',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_hasActiveFilters()) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getActiveFiltersCount().toString(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const Spacer(),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.expand_more_rounded,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// يبني حقل البحث وفلتر نوع العقار وأزرار الحالة والإجراءات.
  /// Builds the search field, property-type filter, status toggles, and action buttons.
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 12),
          _buildPropertyTypeDropdown(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterOption(
                  'المرافق المسندة',
                  Icons.link_rounded,
                  _isAssigned == true,
                  () => _updateFilter(
                      isAssigned: _isAssigned == true ? null : true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterOption(
                  'المرافق المجانية',
                  Icons.money_off_rounded,
                  _isFree == true,
                  () => _updateFilter(isFree: _isFree == true ? null : true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _clearFilters,
                child: Text(
                  'مسح الفلاتر',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Text(
                      'تطبيق',
                      style: AppTextStyles.buttonSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// يبني خيار فلتر واحد مع حالة تفعيل مرئية.
  /// Builds a single filter option with a visible active state.
  Widget _buildFilterOption(
    String label,
    IconData icon,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.2),
                    AppTheme.primaryPurple.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: !isActive ? AppTheme.darkSurface.withValues(alpha: 0.3) : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                : AppTheme.darkBorder.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.primaryBlue : AppTheme.textMuted,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isActive ? AppTheme.primaryBlue : AppTheme.textMuted,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isActive)
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryBlue,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  /// يبدل حالة التوسيع للوحة الفلاتر ويشغل الحركة المناسبة.
  /// Toggles the filter panel expansion and plays the matching animation.
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  /// يحدث الفلاتر الجزئية دون إعادة ضبط بقية القيم.
  /// Updates partial filters without resetting the remaining values.
  void _updateFilter({bool? isAssigned, bool? isFree}) {
    setState(() {
      if (isAssigned != null) _isAssigned = isAssigned;
      if (isFree != null) _isFree = isFree;
    });
  }

  /// يبني حقل البحث النصي الذي يحدّث حالة الفلاتر أثناء الكتابة.
  /// Builds the search field that updates the filter state as the user types.
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppTheme.textWhite,
      ),
      decoration: InputDecoration(
        hintText: 'ابحث عن مرفق...',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textMuted,
        ),
        filled: true,
        fillColor: AppTheme.darkSurface.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppTheme.primaryBlue.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppTheme.textMuted,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  color: AppTheme.textMuted,
                ),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchTerm = null;
                  });
                },
              )
            : null,
      ),
      onChanged: (value) {
        setState(() {
          _searchTerm = value.isEmpty ? null : value;
        });
      },
    );
  }

  /// يبني قائمة منسدلة لتحديد نوع العقار الذي تنطبق عليه الفلاتر.
  /// Builds the property-type dropdown used to scope the filter results.
  Widget _buildPropertyTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _propertyTypeId != null
              ? AppTheme.primaryBlue.withValues(alpha: 0.5)
              : AppTheme.darkBorder.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: DropdownButton<String?>(
        value: _propertyTypeId,
        isExpanded: true,
        dropdownColor: AppTheme.darkCard,
        underline: const SizedBox.shrink(),
        hint: Text(
          'نوع العقار',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        icon: Icon(
          Icons.arrow_drop_down,
          color: AppTheme.textMuted,
        ),
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textWhite,
        ),
        items: const [
          DropdownMenuItem<String?>(value: null, child: Text('جميع الأنواع')),
          DropdownMenuItem<String?>(
            value: 'hotel',
            child: Text('فندق'),
          ),
          DropdownMenuItem<String?>(
            value: 'apartment',
            child: Text('شقة'),
          ),
          DropdownMenuItem<String?>(
            value: 'resort',
            child: Text('منتجع'),
          ),
          DropdownMenuItem<String?>(
            value: 'villa',
            child: Text('فيلا'),
          ),
          DropdownMenuItem<String?>(
            value: 'chalet',
            child: Text('شاليه'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _propertyTypeId = value;
          });
        },
      ),
    );
  }

  /// يرسل القيم الحالية إلى الصفحة الأم ثم يطوي اللوحة.
  /// Sends the current values to the parent page and collapses the panel.
  void _applyFilters() {
    widget.onFilterChanged(_searchTerm, _isAssigned, _isFree, _propertyTypeId);
    _toggleExpanded();
  }

  /// يمسح جميع الفلاتر ويعيدها إلى الحالة الافتراضية.
  /// Clears all filters and restores the default state.
  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchTerm = null;
      _isAssigned = null;
      _isFree = null;
      _propertyTypeId = null;
    });
    widget.onFilterChanged(null, null, null, null);
  }

  /// يحدد ما إذا كان هناك أي فلتر نشط حاليًا.
  /// Indicates whether any filter is currently active.
  bool _hasActiveFilters() {
    return _searchTerm != null ||
        _isAssigned != null ||
        _isFree != null ||
        _propertyTypeId != null;
  }

  /// يحسب عدد الفلاتر النشطة ليعرضه في الشارة.
  /// Counts the active filters so the badge can display it.
  int _getActiveFiltersCount() {
    int count = 0;
    if (_searchTerm != null && _searchTerm!.isNotEmpty) count++;
    if (_isAssigned != null) count++;
    if (_isFree != null) count++;
    if (_propertyTypeId != null) count++;
    return count;
  }
}
