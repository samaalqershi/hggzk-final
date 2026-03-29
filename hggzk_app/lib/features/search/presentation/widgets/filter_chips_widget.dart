import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:intl/intl.dart' as intl;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_manager.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';
import 'package:hggzk/core/services/local_data_service.dart';

/// العربية: يمثل العنصر `FilterChipsWidget`.
class FilterChipsWidget extends StatefulWidget {
  /// العربية: يخزن القيمة `filters`.
  final Map<String, dynamic> filters;

  /// العربية: يعالج `Function`.
  final Function(String) onRemoveFilter;

  /// العربية: يخزن القيمة `onClearAll`.
  final VoidCallback? onClearAll;

  /// العربية: ينشئ مثيلًا جديدًا من `FilterChipsWidget`.
  const FilterChipsWidget({
    super.key,
    required this.filters,
    required this.onRemoveFilter,
    this.onClearAll,
  });

  /// العربية: ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<FilterChipsWidget> createState() => _FilterChipsWidgetState();
}

/// العربية: يمثل الحالة الخاصة بـ `FilterChipsWidgetState`.
class _FilterChipsWidgetState extends State<FilterChipsWidget>
    with TickerProviderStateMixin {
  /// العربية: يخزن القيمة `slideController`.
  late AnimationController _slideController;

  /// العربية: يخزن القيمة `fadeController`.
  late AnimationController _fadeController;

  /// العربية: يخزن القيمة `chipAnimations`.
  final Map<String, AnimationController> _chipAnimations = {};

  // Local names cache
  late final LocalDataService _localDataService = sl<LocalDataService>();

  /// العربية: يخزن القيمة `propertyTypeIdToName`.
  Map<String, String> _propertyTypeIdToName = {};

  /// العربية: يخزن القيمة `unitTypeIdToName`.
  Map<String, String> _unitTypeIdToName = {};

  /// العربية: يهيئ الحالة الخاصة بهذا العنصر.
  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    // Create animation for each chip
    for (var key in widget.filters.keys) {
      _chipAnimations[key] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      )..forward();
    }

    // Load locally saved names for property and unit types
    _loadLocalNames();
  }

  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    for (var controller in _chipAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// العربية: يحمل local names.
  Future<void> _loadLocalNames() async {
    try {
      // Load property types names from local cache (saved on home)
      final propertyTypes = _localDataService.getPropertyTypes();
      final unitTypes = _localDataService.getUnitTypes();
      if (mounted) {
        setState(() {
          _propertyTypeIdToName = {
            for (final pt in propertyTypes) pt.id: pt.name,
          };
          _unitTypeIdToName = {
            for (final ut in unitTypes) ut.id: ut.name,
          };
        });
      }
    } catch (_) {
      // Ignore silently; widget will fallback to generic labels
    }
  }

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    final visibleEntries = widget.filters.entries
        .where((entry) => !_isHiddenFilter(entry.key))
        .toList();

    if (visibleEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutBack,
      )),
      child: FadeTransition(
        opacity: _fadeController,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingSmall,
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
            ),
            children: [
              if (visibleEntries.length > 1 && widget.onClearAll != null) ...[
                _buildClearAllChip(context),
                const SizedBox(width: AppDimensions.spacingSm),
              ],
              ...visibleEntries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(left: AppDimensions.spacingSm),
                  child: _buildFilterChip(
                    context,
                    entry.key,
                    entry.value,
                    () => _removeFilter(entry.key),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// العربية: يعالج `isHiddenFilter`.
  bool _isHiddenFilter(String key) => key == 'preferredCurrency';

  /// العربية: يبني clear all chip.
  Widget _buildClearAllChip(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _fadeController,
        curve: Curves.elasticOut,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.error.withOpacity(0.2),
              AppTheme.error.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onClearAll,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.clear_all_rounded,
                    size: 16,
                    color: AppTheme.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.tr('search.filters.clearAll'),
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// العربية: يبني filter chip.
  Widget _buildFilterChip(
    BuildContext context,
    String key,
    dynamic value,
    VoidCallback onDelete,
  ) {
    final String label = _getFilterLabel(context, key, value);
    final IconData icon = _getFilterIcon(key);
    final Color color = _getFilterColor(key);

    final controller = _chipAnimations[key];
    if (controller == null) return const SizedBox.shrink();

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (_isRequiredField(key, widget.filters)) {
                    _showRequiredFieldError(key);
                    return;
                  }
                  _animateRemoval(key, onDelete);
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: AppTextStyles.caption.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 12,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// العربية: يزيل filter.
  void _removeFilter(String key) {
    // منع حذف الحقول المطلوبة
    if (_isRequiredField(key, widget.filters)) {
      _showRequiredFieldError(key);
      return;
    }
    widget.onRemoveFilter(key);
  }

  /// العربية: يعالج `animateRemoval`.
  void _animateRemoval(String key, VoidCallback onComplete) {
    final controller = _chipAnimations[key];
    if (controller != null) {
      controller.reverse().then((_) {
        onComplete();
      });
    } else {
      onComplete();
    }
  }

  /// العربية: يعيد filter label.
  String _getFilterLabel(BuildContext context, String key, dynamic value) {
    switch (key) {
      case 'searchTerm':
        return value.toString();
      case 'city':
        return value.toString();
      case 'propertyTypeId':
        return _getPropertyTypeName(context, value);
      case 'unitTypeId':
        return _getUnitTypeName(context, value);
      case 'minPrice':
        return context.tr(
          'search.filters.priceFrom',
          params: {'price': _formatPrice(value)},
        );
      case 'maxPrice':
        return context.tr(
          'search.filters.priceTo',
          params: {'price': _formatPrice(value)},
        );
      case 'minStarRating':
        return context.tr(
          'search.filters.starsPlus',
          params: {'value': value},
        );
      case 'checkIn':
        return context.tr(
          'search.filters.checkIn',
          params: {'date': _formatDate(context, value as DateTime)},
        );
      case 'checkOut':
        return context.tr(
          'search.filters.checkOut',
          params: {'date': _formatDate(context, value as DateTime)},
        );
      case 'guestsCount':
        return context.tr(
          value == 1 ? 'search.filters.guestsOne' : 'search.filters.guestsMany',
          params: {'value': value},
        );
      case 'requiredAmenities':
        final List<String> amenities = value as List<String>;
        return context.tr(
          'search.filters.amenitiesCount',
          params: {'count': amenities.length},
        );
      case 'serviceIds':
        final List<String> services = value as List<String>;
        return context.tr(
          'search.filters.servicesCount',
          params: {'count': services.length},
        );
      case 'dynamicFieldFilters':
        final Map<dynamic, dynamic> dynamicFilters =
            Map<dynamic, dynamic>.from(value as Map);
        return context.tr(
          'search.filters.dynamicCount',
          params: {'count': dynamicFilters.length},
        );
      case 'sortBy':
        return _getSortByLabel(context, value);
      default:
        return value.toString();
    }
  }

  /// العربية: يعيد filter icon.
  IconData _getFilterIcon(String key) {
    switch (key) {
      case 'searchTerm':
        return Icons.search_rounded;
      case 'city':
        return Icons.location_on_rounded;
      case 'propertyTypeId':
        return Icons.home_rounded;
      case 'unitTypeId':
        return Icons.bed_rounded;
      case 'minPrice':
      case 'maxPrice':
        return Icons.attach_money_rounded;
      case 'minStarRating':
        return Icons.star_rounded;
      case 'checkIn':
      case 'checkOut':
        return Icons.calendar_today_rounded;
      case 'guestsCount':
        return Icons.people_rounded;
      case 'requiredAmenities':
        return Icons.apps_rounded;
      case 'serviceIds':
        return Icons.room_service_rounded;
      case 'dynamicFieldFilters':
        return Icons.tune_rounded;
      case 'sortBy':
        return Icons.sort_rounded;
      default:
        return Icons.filter_alt_rounded;
    }
  }

  /// العربية: يعيد filter color.
  Color _getFilterColor(String key) {
    switch (key) {
      case 'searchTerm':
        return AppTheme.primaryBlue;
      case 'city':
        return AppTheme.neonBlue;
      case 'propertyTypeId':
        return AppTheme.primaryPurple;
      case 'unitTypeId':
        return AppTheme.primaryCyan;
      case 'minPrice':
      case 'maxPrice':
        return AppTheme.success;
      case 'minStarRating':
        return AppTheme.warning;
      case 'checkIn':
      case 'checkOut':
        return AppTheme.primaryViolet;
      case 'guestsCount':
        return AppTheme.info;
      case 'requiredAmenities':
        return AppTheme.neonPurple;
      case 'serviceIds':
        return AppTheme.primaryCyan;
      case 'dynamicFieldFilters':
        return AppTheme.primaryPurple;
      default:
        return AppTheme.textMuted;
    }
  }

  /// العربية: يعيد property type name.
  String _getPropertyTypeName(BuildContext context, String typeId) {
    if (_propertyTypeIdToName.isNotEmpty) {
      return _propertyTypeIdToName[typeId] ??
          context.tr('search.filters.propertyType');
    }
    return context.tr('search.filters.propertyType');
  }

  /// العربية: يعيد unit type name.
  String _getUnitTypeName(BuildContext context, String typeId) {
    if (_unitTypeIdToName.isNotEmpty) {
      return _unitTypeIdToName[typeId] ?? context.tr('search.filters.unitType');
    }
    return context.tr('search.filters.unitType');
  }

  /// العربية: يعيد sort by label.
  String _getSortByLabel(BuildContext context, String sortBy) {
    switch (sortBy) {
      case 'price_asc':
        return context.tr('search.filters.sort.priceAsc');
      case 'price_desc':
        return context.tr('search.filters.sort.priceDesc');
      case 'rating':
        return context.tr('search.filters.sort.rating');
      case 'popularity':
        return context.tr('search.filters.sort.popularity');
      case 'newest':
        return context.tr('search.filters.sort.newest');
      case 'distance':
        return context.tr('search.filters.sort.distance');
      default:
        return context.tr('search.filters.sort.default');
    }
  }

  /// العربية: ينسق date.
  String _formatDate(BuildContext context, DateTime date) {
    final locale = LocaleManager.getCurrentLocale(context);
    return intl.DateFormat('d MMMM', locale.languageCode).format(date);
  }

  /// العربية: ينسق price.
  String _formatPrice(dynamic price) {
    final value = price is int ? price.toDouble() : price as double;
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  /// العربية: يعالج `isRequiredField`.
  bool _isRequiredField(String key, Map<String, dynamic> filters) {
    // الحقول الأساسية المطلوبة
    if (key == 'propertyTypeId' || key == 'unitTypeId') {
      return true;
    }

    // التحقق من الحقول الديناميكية المطلوبة
    if (key == 'checkIn' || key == 'checkOut') {
      // تحقق من وجود حقول ديناميكية مطلوبة
      return true;
    }

    return false;
  }

  /// العربية: يعرض required field error.
  void _showRequiredFieldError(String fieldKey) {
    String message = '';

    switch (fieldKey) {
      case 'propertyTypeId':
        message = context.tr('search.filters.requiredPropertyType');
        break;
      case 'unitTypeId':
        message = context.tr('search.filters.requiredUnitType');
        break;
      case 'checkIn':
        message = context.tr('search.filters.requiredCheckIn');
        break;
      case 'checkOut':
        message = context.tr('search.filters.requiredCheckOut');
        break;
      default:
        message = context.tr('common.required');
    }

    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: AppTheme.warning,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.darkCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
