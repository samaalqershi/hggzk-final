// lib/features/search/presentation/pages/ultra_refined_search_filters_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hggzk/features/search/domain/entities/search_result.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_state.dart';
import '../bloc/search_event.dart';
import 'package:hggzk/core/services/data_sync_service.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';
import 'package:hggzk/features/search/data/models/search_filter_model.dart';

/// Filters screen that lets the user refine search criteria before results are
/// requested.
/// شاشة الفلاتر التي تتيح للمستخدم تضييق معايير البحث قبل جلب النتائج.
class SearchFiltersPage extends StatefulWidget {
  /// Optional filter payload used to seed the screen.
  /// حمولة فلاتر اختيارية لتهيئة الشاشة.
  final Map<String, dynamic>? initialFilters;

  /// Builds the filters screen with an optional initial payload.
  /// ينشئ شاشة الفلاتر مع حمولة ابتدائية اختيارية.
  const SearchFiltersPage({
    super.key,
    this.initialFilters,
  });

  /// Builds the state object for this widget.
  /// ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<SearchFiltersPage> createState() => _SearchFiltersPageState();
}

/// Keeps the editable filter form, validation state, and preview flow in sync.
/// يبقي نموذج الفلاتر القابل للتعديل وحالة التحقق ومسار المعاينة متزامنة.
class _SearchFiltersPageState extends State<SearchFiltersPage>
    with TickerProviderStateMixin {
  /// Working filter map edited by the user.
  /// خريطة الفلاتر العملية التي يعدلها المستخدم.
  late Map<String, dynamic> _filters;
  final ScrollController _scrollController = ScrollController();

  /// Controls the visible search-term input.
  /// يتحكم بحقل عبارة البحث الظاهر.
  late TextEditingController _searchTermController;

  /// Keeps keyboard focus on the search-term field when needed.
  /// يبقي التركيز على حقل عبارة البحث عند الحاجة.
  late FocusNode _searchTermFocusNode;

  // Data services
  /// Loads supporting metadata such as property and unit types.
  /// يحمل البيانات المساندة مثل أنواع العقارات والوحدات.
  late DataSyncService _dataSyncService;

  // Data state
  /// Cached property types used to build local fallback filters.
  /// أنواع العقارات المخزنة المستخدمة لبناء فلاتر احتياطية محليًا.
  List<dynamic> _propertyTypes = [];

  /// Cached unit types used for dependent filter options.
  /// أنواع الوحدات المخزنة المستخدمة لخيارات الفلاتر التابعة.
  List<dynamic> _unitTypes = [];

  /// True while remote or local filter metadata is loading.
  /// تكون صحيحة أثناء تحميل بيانات الفلاتر من الشبكة أو محليًا.
  bool _isLoadingData = false;

  // Validation state
  /// True when the current form passes validation.
  /// تكون صحيحة عندما ينجح النموذج الحالي في التحقق.
  bool _isValidFilter = false;

  /// Current validation error message shown to the user.
  /// رسالة الخطأ الحالية المعروضة للمستخدم.
  String _validationError = '';

  /// Tracks which required dynamic fields are currently satisfied.
  /// يتتبع الحقول الديناميكية المطلوبة التي تحققت حاليًا.
  Map<String, bool> _requiredFieldsStatus = {};

  // Ultra Animation Controllers
  /// العربية: يخزن القيمة `entranceController`.
  late AnimationController _entranceController;

  /// العربية: يخزن القيمة `floatingController`.
  late AnimationController _floatingController;

  /// العربية: يخزن القيمة `glowController`.
  late AnimationController _glowController;

  /// العربية: يخزن القيمة `particleController`.
  late AnimationController _particleController;

  /// العربية: يخزن القيمة `waveController`.
  late AnimationController _waveController;

  // Animations
  /// العربية: يخزن القيمة `entranceAnimation`.
  late Animation<double> _entranceAnimation;

  /// العربية: يخزن القيمة `floatingAnimation`.
  late Animation<double> _floatingAnimation;

  /// العربية: يخزن القيمة `glowAnimation`.
  late Animation<double> _glowAnimation;

  /// العربية: يخزن القيمة `waveAnimation`.
  late Animation<double> _waveAnimation;

  // Active filters tracking
  /// العربية: يخزن القيمة `activeFilterCount`.
  int _activeFilterCount = 0;

  /// العربية: يخزن القيمة `previewDebounce`.
  Timer? _previewDebounce;

  // Floating particles
  /// العربية: يخزن القيمة `particles`.
  final List<_NanoParticle> _particles = [];

  /// العربية: يهيئ الحالة الخاصة بهذا العنصر.
  @override
  void initState() {
    super.initState();
    _filters = _normalizeVisibleFilters(widget.initialFilters ?? {});
    final initialSearchTerm =
        ((_filters['searchTerm'] as String?) ?? '').trim();
    if (initialSearchTerm.isEmpty) {
      _filters.remove('searchTerm');
    } else {
      _filters['searchTerm'] = initialSearchTerm;
    }
    _filters.remove('preferredCurrency');
    _searchTermController = TextEditingController(
      text: initialSearchTerm,
    );
    _searchTermFocusNode = FocusNode();

    _dataSyncService = sl<DataSyncService>();
    _initializeAnimations();
    _generateParticles();
    _calculateActiveFilters();
    _loadFilters();
    _loadLocalData();
    _validateFilters();
  }

  /// العربية: يهيئ animations.
  void _initializeAnimations() {
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _waveController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutExpo,
    );

    _floatingAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));

    _entranceController.forward();
  }

  /// العربية: ينشئ particles.
  void _generateParticles() {
    for (int i = 0; i < 15; i++) {
      _particles.add(_NanoParticle());
    }
  }

  /// العربية: يتحقق من صحة filters.
  bool _validateFilters() {
    setState(() {
      _validationError = '';
      _requiredFieldsStatus.clear();
      _isValidFilter = true;
    });
    setState(() {
      _isValidFilter = true;
      _validationError = '';
    });
    return true;
  }

  /// العربية: يحمل filters.
  void _loadFilters() {
    final bloc = context.read<SearchBloc>();
    final loadedState = _resolveLoadedFiltersState(bloc.state);
    final shouldRefresh = loadedState == null ||
        (loadedState.filters.dynamicFieldValues.isEmpty &&
            loadedState.filters.services.isEmpty &&
            loadedState.filters.amenities.isEmpty);

    if (shouldRefresh) {
      bloc.add(const GetSearchFiltersEvent());
    }
  }

  /// العربية: يحمل local data.
  void _loadLocalData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      if (!_dataSyncService.hasCachedData() ||
          !_dataSyncService.isDataValid()) {
        await _dataSyncService.syncAllData();
      }

      final propertyTypes = await _dataSyncService.getPropertyTypes();
      setState(() {
        _propertyTypes = propertyTypes;
      });

      if (_filters['propertyTypeId'] != null) {
        _loadUnitTypesForPropertyType(_filters['propertyTypeId']);
      }
    } catch (e) {
      print('Error loading local data: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  /// العربية: يحمل unit types for property type.
  void _loadUnitTypesForPropertyType(String propertyTypeId) async {
    try {
      final unitTypeModels =
          await _dataSyncService.getUnitTypes(propertyTypeId: propertyTypeId);
      final filterModels = unitTypeModels
          .map((m) => UnitTypeFilterModel(
                id: m.id,
                name: m.name,
                unitsCount: 0,
                propertyTypeId: m.propertyTypeId,
                isHasAdults: m.isHasAdults,
                isHasChildren: m.isHasChildren,
              ))
          .toList();
      setState(() {
        _unitTypes = filterModels;
      });
    } catch (e) {
      print('Error loading unit types: $e');
    }
  }

  /// العربية: يعالج `calculateActiveFilters`.
  void _calculateActiveFilters() {
    _activeFilterCount = 0;
    _filters.forEach((key, value) {
      if (key == 'preferredCurrency') {
        return;
      }
      if (value != null &&
          value != false &&
          (value is! List || value.isNotEmpty) &&
          (value is! Map || value.isNotEmpty)) {
        _activeFilterCount++;
      }
    });
    _validateFilters();
    _scheduleFacetPreview();
  }

  /// العربية: يعرض validation error.
  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.warning,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _validationError,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
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
      ),
    );
  }

  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _searchTermController.dispose();
    _searchTermFocusNode.dispose();
    _entranceController.dispose();
    _floatingController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    _previewDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          _buildUltraBackground(),
          _buildFloatingParticles(),
          SafeArea(
            child: AnimatedBuilder(
              animation: _entranceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    (1 - _entranceAnimation.value) * 50,
                  ),
                  child: Opacity(
                    opacity: _entranceAnimation.value,
                    child: Column(
                      children: [
                        _buildUltraHeader(),
                        Expanded(
                          child: _buildContent(),
                        ),
                        _buildUltraFooter(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// العربية: يبني ultra background.
  Widget _buildUltraBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveAnimation, _glowAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkSurface.withOpacity(0.95),
                AppTheme.darkCard.withOpacity(0.90),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _UltraWavePainter(
              waveAnimation: _waveAnimation.value,
              glowIntensity: _glowAnimation.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  /// العربية: يبني floating particles.
  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: _NanoParticlePainter(
            particles: _particles,
            animation: _particleController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  /// العربية: يبني ultra header.
  Widget _buildUltraHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildNanoButton(
            icon: Icons.close_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppTheme.primaryCyan,
                      AppTheme.primaryBlue,
                      AppTheme.primaryPurple,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ).createShader(bounds),
                  child: Text(
                    'تخصيص البحث',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_activeFilterCount > 0)
            _buildNanoTextButton(
              label: 'مسح',
              icon: Icons.clear_all_rounded,
              onTap: _resetFilters,
              color: AppTheme.error,
            ),
        ],
      ),
    );
  }

  /// العربية: يبني content.
  Widget _buildContent() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        SearchFilters? filters;
        final loadedFiltersState = _resolveLoadedFiltersState(state);

        if (state is SearchCombinedState) {
          final filtersState = state.filtersState;
          if (filtersState is SearchFiltersLoaded) {
            filters = filtersState.filters;
          }
        } else if (state is SearchFiltersLoaded) {
          filters = state.filters;
        }

        return AnimatedBuilder(
          animation: _floatingAnimation,
          builder: (context, child) {
            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: Offset(0, _floatingAnimation.value),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildSearchTermSection(),
                          const SizedBox(height: 12),
                          _buildCitiesSection(filters),
                          const SizedBox(height: 12),
                          _buildQuickFilters(),
                          const SizedBox(height: 16),
                          _buildFuturisticPropertyTypesSection(filters),
                          const SizedBox(height: 12),
                          _buildFuturisticUnitTypesSection(filters),
                          const SizedBox(height: 12),
                          _buildDateSection(loadedFiltersState),
                          const SizedBox(height: 12),
                          _buildGuestsSection(),
                          const SizedBox(height: 12),
                          _buildPriceSection(loadedFiltersState),
                          const SizedBox(height: 12),
                          _buildRatingSection(filters),
                          const SizedBox(height: 12),
                          _buildServicesSection(filters),
                          const SizedBox(height: 12),
                          _buildDynamicFieldValuesSection(filters),
                          const SizedBox(height: 12),
                          _buildAmenitiesSection(filters),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// العربية: يبني quick filters.
  Widget _buildQuickFilters() {
    final quickFilters = [
      {'label': 'الأكثر شعبية', 'icon': Icons.trending_up_rounded},
      {'label': 'الأفضل تقييماً', 'icon': Icons.star_rounded},
      {'label': 'الأرخص', 'icon': Icons.attach_money_rounded},
      {'label': 'قريب مني', 'icon': Icons.near_me_rounded},
    ];

    return Container(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickFilters.length,
        itemBuilder: (context, index) {
          final filter = quickFilters[index];
          final isSelected = false;

          return Padding(
            padding: EdgeInsets.only(
              right: index == 0 ? 0 : 8,
            ),
            child: _buildQuickFilterChip(
              label: filter['label'] as String,
              icon: filter['icon'] as IconData,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.lightImpact();
              },
            ),
          );
        },
      ),
    );
  }

  /// العربية: يبني cities section.
  Widget _buildCitiesSection(SearchFilters? filters) {
    final cities = filters?.cities ?? const <CityFilter>[];
    if (cities.isEmpty) return const SizedBox.shrink();

    final selectedCity = (_filters['city'] as String?)?.trim();

    return _NanoSection(
      title: 'المدينة',
      icon: Icons.location_city_outlined,
      child: _buildVerticalOptionsList(
        cities.map((city) {
          final isSelected = selectedCity == city.name;

          return _buildVerticalCountOption(
            label: city.name,
            count: city.propertiesCount,
            icon: Icons.location_on_outlined,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _filters.remove('city');
                } else {
                  _filters['city'] = city.name;
                }
                _calculateActiveFilters();
              });

              HapticFeedback.selectionClick();
            },
          );
        }).toList(),
      ),
    );
  }

  /// العربية: يبني search term section.
  Widget _buildSearchTermSection() {
    return _NanoSection(
      title: 'بحث عن عقار',
      icon: Icons.search_rounded,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.16),
            width: 0.6,
          ),
        ),
        child: TextField(
          controller: _searchTermController,
          focusNode: _searchTermFocusNode,
          textInputAction: TextInputAction.search,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (value) {
            final normalized = value.trim();
            setState(() {
              if (normalized.isEmpty) {
                _filters.remove('searchTerm');
              } else {
                _filters['searchTerm'] = normalized;
              }
              _calculateActiveFilters();
            });
          },
          onSubmitted: (_) {
            HapticFeedback.selectionClick();
            _searchTermFocusNode.unfocus();
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            hintText: 'ابحث بالاسم، الوصف، أو المدينة...',
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted.withOpacity(0.7),
            ),
            prefixIcon: Icon(
              Icons.manage_search_rounded,
              size: 18,
              color: AppTheme.primaryBlue.withOpacity(0.85),
            ),
            suffixIcon: _searchTermController.text.trim().isEmpty
                ? null
                : IconButton(
                    tooltip: 'مسح',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _searchTermController.clear();
                        _filters.remove('searchTerm');
                        _calculateActiveFilters();
                      });
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      size: 17,
                      color: AppTheme.textMuted.withOpacity(0.7),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// العربية: يبني quick filter chip.
  Widget _buildQuickFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: !isSelected ? AppTheme.darkCard.withOpacity(0.5) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppTheme.darkBorder.withOpacity(0.2),
            width: 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? Colors.white
                  : AppTheme.textMuted.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected
                    ? Colors.white
                    : AppTheme.textLight.withOpacity(0.8),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// العربية: يبني date section.
  Widget _buildDateSection(SearchFiltersLoaded? loadedState) {
    return _NanoSection(
      title: 'التواريخ',
      icon: Icons.calendar_today_rounded,
      headerSuffix: _buildSectionCountBadge(
        matchingResultsCount: loadedState?.matchingResultsCount,
        isLoading: loadedState?.isPreviewLoading ?? false,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'من',
                  date: _filters['checkIn'],
                  onTap: () => _selectDate('checkIn'),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.primaryBlue.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDateField(
                  label: 'إلى',
                  date: _filters['checkOut'],
                  onTap: () => _selectDate('checkOut'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildSectionCountSummary(
            matchingResultsCount: loadedState?.matchingResultsCount,
            isLoading: loadedState?.isPreviewLoading ?? false,
            label: 'مطابق للتواريخ الحالية',
            icon: Icons.event_available_rounded,
          ),
        ],
      ),
    );
  }

  /// العربية: يبني date field.
  Widget _buildDateField({
    required String label,
    DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: date != null
              ? AppTheme.primaryBlue.withOpacity(0.08)
              : AppTheme.darkCard.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: date != null
                ? AppTheme.primaryBlue.withOpacity(0.2)
                : AppTheme.darkBorder.withOpacity(0.15),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? _formatDate(date) : 'اختر',
              style: AppTextStyles.bodySmall.copyWith(
                color: date != null
                    ? AppTheme.textWhite
                    : AppTheme.textMuted.withOpacity(0.5),
                fontWeight: date != null ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// العربية: يبني guests section.
  Widget _buildGuestsSection() {
    final guestsCount = _filters['guestsCount'] ?? 1;

    return _NanoSection(
      title: 'الضيوف',
      icon: Icons.people_outline_rounded,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.4),
              AppTheme.darkCard.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.15),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$guestsCount ${guestsCount == 1 ? 'ضيف' : 'ضيوف'}',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textWhite,
              ),
            ),
            Row(
              children: [
                _buildNanoCounterButton(
                  icon: Icons.remove,
                  enabled: guestsCount > 1,
                  onTap: () {
                    setState(() {
                      _filters['guestsCount'] = guestsCount - 1;
                      _calculateActiveFilters();
                    });
                  },
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    guestsCount.toString(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildNanoCounterButton(
                  icon: Icons.add,
                  enabled: true,
                  onTap: () {
                    setState(() {
                      _filters['guestsCount'] = guestsCount + 1;
                      _calculateActiveFilters();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// العربية: يبني futuristic property types section.
  Widget _buildFuturisticPropertyTypesSection(SearchFilters? filters) {
    final liveTypes = filters?.propertyTypes ?? const [];
    final types = liveTypes.isNotEmpty ? liveTypes : _propertyTypes;
    if (types.isEmpty) return const SizedBox.shrink();

    final isRequired = _requiredFieldsStatus['propertyTypeId'] == false;

    return _NanoSection(
      title: 'نوع العقار',
      icon: Icons.home_outlined,
      isRequired: true,
      hasError: isRequired,
      child: _buildVerticalOptionsList(
        types.map((type) {
          final isSelected = _filters['propertyTypeId'] == type.id;

          return _buildVerticalCountOption(
            label: type.name,
            count: _lookupPropertyTypeCount(type.id, filters, type),
            icon: Icons.apartment_rounded,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _filters.remove('propertyTypeId');
                  _filters.remove('unitTypeId');
                  _unitTypes = [];
                } else {
                  if (_filters['propertyTypeId'] != type.id) {
                    _filters.remove('unitTypeId');
                    _unitTypes = [];
                  }
                  _filters['propertyTypeId'] = type.id;
                }
                _calculateActiveFilters();
              });

              if (!isSelected) {
                _loadUnitTypesForPropertyType(type.id.toString());
              }

              HapticFeedback.selectionClick();
            },
          );
        }).toList(),
      ),
    );
  }

  /// العربية: يبني futuristic unit types section.
  Widget _buildFuturisticUnitTypesSection(SearchFilters? filters) {
    final selectedPropertyTypeId = _filters['propertyTypeId'];
    if (selectedPropertyTypeId == null) return const SizedBox.shrink();

    final liveUnitTypes = filters?.unitTypes ?? const [];
    final allUnitTypes = liveUnitTypes.isNotEmpty ? liveUnitTypes : _unitTypes;
    if (allUnitTypes.isEmpty) return const SizedBox.shrink();

    final unitTypes = allUnitTypes
        .where((u) => u.propertyTypeId == selectedPropertyTypeId)
        .toList();
    if (unitTypes.isEmpty) return const SizedBox.shrink();

    final isRequired = _requiredFieldsStatus['unitTypeId'] == false;

    return _NanoSection(
      title: 'نوع الوحدة',
      icon: Icons.bed_outlined,
      isRequired: true,
      hasError: isRequired,
      child: _buildVerticalOptionsList(
        unitTypes.map((unit) {
          final isSelected = _filters['unitTypeId'] == unit.id;

          return _buildVerticalCountOption(
            label: unit.name,
            count: _lookupUnitTypeCount(unit.id, filters, unit),
            icon: Icons.meeting_room_rounded,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _filters.remove('unitTypeId');
                } else {
                  _filters['unitTypeId'] = unit.id;
                }
                _calculateActiveFilters();
              });

              HapticFeedback.selectionClick();
            },
          );
        }).toList(),
      ),
    );
  }

  /// العربية: يبني price section.
  Widget _buildPriceSection(SearchFiltersLoaded? loadedState) {
    final double minPrice = (_filters['minPrice'] as num?)?.toDouble() ?? 0.0;
    final double maxPrice =
        (_filters['maxPrice'] as num?)?.toDouble() ?? 1000000.0;
    const String selectedCurrency = 'YER';

    return _NanoSection(
      title: 'السعر',
      icon: Icons.payments_outlined,
      headerSuffix: _buildSectionCountBadge(
        matchingResultsCount: loadedState?.matchingResultsCount,
        isLoading: loadedState?.isPreviewLoading ?? false,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPriceField(
                  label: 'من',
                  value: minPrice,
                  currency: selectedCurrency,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: AppTheme.textMuted.withOpacity(0.3),
                ),
              ),
              Expanded(
                child: _buildPriceField(
                  label: 'إلى',
                  value: maxPrice,
                  currency: selectedCurrency,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildUltraPriceSlider(minPrice, maxPrice),
          const SizedBox(height: 10),
          _buildSectionCountSummary(
            matchingResultsCount: loadedState?.matchingResultsCount,
            isLoading: loadedState?.isPreviewLoading ?? false,
            label: 'مطابق لنطاق السعر الحالي',
            icon: Icons.price_change_outlined,
          ),
        ],
      ),
    );
  }

  /// العربية: يبني section count badge.
  Widget _buildSectionCountBadge({
    required int? matchingResultsCount,
    required bool isLoading,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.18),
          width: 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.8,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryBlue,
                ),
              ),
            )
          else
            Icon(
              Icons.analytics_outlined,
              size: 13,
              color: AppTheme.primaryBlue,
            ),
          const SizedBox(width: 6),
          Text(
            isLoading ? '...' : '${matchingResultsCount ?? 0}',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// العربية: يبني section count summary.
  Widget _buildSectionCountSummary({
    required int? matchingResultsCount,
    required bool isLoading,
    required String label,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withOpacity(0.42),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.14),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: isLoading
                ? CircularProgressIndicator(
                    strokeWidth: 1.8,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryBlue,
                    ),
                  )
                : Icon(
                    icon,
                    size: 16,
                    color: AppTheme.primaryBlue.withOpacity(0.9),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isLoading
                  ? 'يتم تحديث العداد...'
                  : '$label: ${matchingResultsCount ?? 0}',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// العربية: يبني price field.
  Widget _buildPriceField({
    required String label,
    required double value,
    String currency = 'YER',
  }) {
    const currencySymbols = {
      'YER': 'ر.ي',
      'USD': '\$',
      'SAR': 'ر.س',
      'EUR': '€',
      'GBP': '£',
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value.toStringAsFixed(0),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textWhite,
                  ),
                ),
              ),
              Text(
                currencySymbols[currency] ?? currency,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// العربية: يبني ultra price slider.
  Widget _buildUltraPriceSlider(double min, double max) {
    return Container(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.darkCard.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                height: 4,
                margin: EdgeInsets.only(
                  left: 20,
                  right: MediaQuery.of(context).size.width * 0.3,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue
                          .withOpacity(0.3 * _glowAnimation.value),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              );
            },
          ),
          RangeSlider(
            min: 0.0,
            max: 1000000.0,
            values: RangeValues(min, max),
            onChanged: (RangeValues values) {
              setState(() {
                _filters['minPrice'] = values.start;
                _filters['maxPrice'] = values.end;
                _calculateActiveFilters();
              });
            },
            activeColor: AppTheme.primaryBlue,
            inactiveColor: AppTheme.darkCard.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  /// العربية: يبني rating section.
  Widget _buildRatingSection(SearchFilters? filters) {
    final selectedRating = _filters['minStarRating'] ?? 0;
    final options = (filters?.starRatingOptions ?? const <StarRatingOption>[])
        .where((option) => option.value > 0)
        .toList();
    final ratings = options.isNotEmpty
        ? options
        : List.generate(
            5,
            (index) => StarRatingOption(
              value: index + 1,
              propertiesCount: 0,
            ),
          );

    return _NanoSection(
      title: 'التقييم',
      icon: Icons.star_outline_rounded,
      child: _buildVerticalOptionsList(
        ratings.map((option) {
          final rating = option.value;
          final isSelected = selectedRating == rating;

          return _buildVerticalCountOption(
            label: '$rating نجوم فأكثر',
            count: option.propertiesCount,
            icon: Icons.star_rounded,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _filters.remove('minStarRating');
                } else {
                  _filters['minStarRating'] = rating;
                }
                _calculateActiveFilters();
              });
              HapticFeedback.selectionClick();
            },
          );
        }).toList(),
      ),
    );
  }

  /// العربية: يعالج `lookupPropertyTypeCount`.
  int _lookupPropertyTypeCount(
    String typeId,
    SearchFilters? filters,
    dynamic fallbackType,
  ) {
    final liveMatch = filters?.propertyTypes.where((type) => type.id == typeId);
    if (liveMatch != null && liveMatch.isNotEmpty) {
      return liveMatch.first.propertiesCount;
    }

    try {
      return fallbackType.propertiesCount as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// العربية: يعالج `lookupUnitTypeCount`.
  int _lookupUnitTypeCount(
    String unitTypeId,
    SearchFilters? filters,
    dynamic fallbackType,
  ) {
    final liveMatch = filters?.unitTypes.where((type) => type.id == unitTypeId);
    if (liveMatch != null && liveMatch.isNotEmpty) {
      return liveMatch.first.unitsCount;
    }

    try {
      return fallbackType.unitsCount as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// العربية: يبني amenities section.
  Widget _buildAmenitiesSection(SearchFilters? filters) {
    final allAmenities = filters?.amenities ?? [];
    if (allAmenities.isEmpty) return const SizedBox.shrink();

    final selectedPropertyTypeId = _filters['propertyTypeId'] as String?;

    final amenities = selectedPropertyTypeId == null
        ? allAmenities
        : allAmenities.where((a) {
            // إذا كانت القائمة فارغة فهذا يعني أنه لا يوجد ربط صريح بالممتلكات
            // في هذه الحالة نخفي المرفق عند اختيار نوع عقار محدد
            if (a.propertyTypeIds.isEmpty) {
              return false;
            }

            // نعرض المرفق فقط إذا كان مرتبطًا صراحةً بنوع العقار المحدد
            return a.propertyTypeIds.contains(selectedPropertyTypeId);
          }).toList();

    if (amenities.isEmpty) return const SizedBox.shrink();

    final selectedAmenities =
        List<String>.from(_filters['requiredAmenities'] ?? []);

    return _NanoSection(
      title: 'المرافق',
      icon: Icons.widgets_outlined,
      child: _buildVerticalOptionsList(
        amenities.map((amenity) {
          final isSelected = selectedAmenities.contains(amenity.id);

          return _buildVerticalCountOption(
            label: amenity.name,
            count: amenity.propertiesCount,
            icon: _getAmenityIcon(amenity.name),
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedAmenities.remove(amenity.id);
                } else {
                  selectedAmenities.add(amenity.id);
                }
                _filters['requiredAmenities'] = selectedAmenities;
                _calculateActiveFilters();
              });
              HapticFeedback.selectionClick();
            },
          );
        }).toList(),
      ),
    );
  }

  /// العربية: يبني services section.
  Widget _buildServicesSection(SearchFilters? filters) {
    final services = filters?.services ?? const <ServiceFilter>[];
    if (services.isEmpty) return const SizedBox.shrink();

    final selectedServices = List<String>.from(_filters['serviceIds'] ?? []);

    return _NanoSection(
      title: 'الخدمات',
      icon: Icons.room_service_outlined,
      child: _buildVerticalOptionsList(
        services.map((service) {
          final isSelected = selectedServices.contains(service.id);

          return _buildVerticalCountOption(
            label: service.name,
            count: service.propertiesCount,
            icon: Icons.room_service_outlined,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedServices.remove(service.id);
                } else {
                  selectedServices.add(service.id);
                }

                if (selectedServices.isEmpty) {
                  _filters.remove('serviceIds');
                } else {
                  _filters['serviceIds'] = selectedServices;
                }

                _calculateActiveFilters();
              });
              HapticFeedback.selectionClick();
            },
          );
        }).toList(),
      ),
    );
  }

  /// العربية: يبني dynamic field values section.
  Widget _buildDynamicFieldValuesSection(SearchFilters? filters) {
    final dynamicValues =
        filters?.dynamicFieldValues ?? const <DynamicFieldValueFilter>[];
    if (dynamicValues.isEmpty) return const SizedBox.shrink();

    final grouped = <String, List<DynamicFieldValueFilter>>{};
    for (final item in dynamicValues) {
      grouped.putIfAbsent(item.fieldName, () => []).add(item);
    }

    final selectedDynamicFilters =
        Map<String, dynamic>.from(_filters['dynamicFieldFilters'] ?? {});

    return _NanoSection(
      title: 'الخصائص الإضافية',
      icon: Icons.tune_rounded,
      child: Column(
        children: grouped.entries.map((entry) {
          final fieldName = entry.key;
          final options = entry.value;
          final fieldLabel = _resolveDynamicFieldLabel(options, fieldName);
          final selectedValue = selectedDynamicFilters[fieldName]?.toString();

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fieldLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _buildVerticalOptionsList(
                  options.map((option) {
                    final isSelected = selectedValue == option.value;

                    return _buildVerticalCountOption(
                      label: option.value,
                      count: option.count,
                      icon: Icons.label_outline_rounded,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          final updated =
                              Map<String, dynamic>.from(selectedDynamicFilters);

                          if (isSelected) {
                            updated.remove(fieldName);
                          } else {
                            updated[fieldName] = option.value;
                          }

                          if (updated.isEmpty) {
                            _filters.remove('dynamicFieldFilters');
                          } else {
                            _filters['dynamicFieldFilters'] = updated;
                          }

                          _calculateActiveFilters();
                        });
                        HapticFeedback.selectionClick();
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// العربية: يبني vertical options list.
  Widget _buildVerticalOptionsList(List<Widget> children) {
    return Column(
      children: [
        for (int index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(height: 10),
          children[index],
        ],
      ],
    );
  }

  /// العربية: يبني vertical count option.
  Widget _buildVerticalCountOption({
    required String label,
    required int count,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.26),
                    AppTheme.primaryCyan.withOpacity(0.18),
                  ],
                )
              : null,
          color: !isSelected ? AppTheme.darkCard.withOpacity(0.32) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue.withOpacity(0.45)
                : AppTheme.darkBorder.withOpacity(0.18),
            width: isSelected ? 1 : 0.6,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.18),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryBlue.withOpacity(0.18)
                    : AppTheme.darkSurface.withOpacity(0.55),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isSelected ? Icons.check_rounded : icon,
                size: 19,
                color: isSelected
                    ? AppTheme.primaryCyan
                    : AppTheme.textMuted.withOpacity(0.8),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(minWidth: 40),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryBlue.withOpacity(0.16)
                    : AppTheme.darkSurface.withOpacity(0.7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected
                      ? AppTheme.primaryCyan
                      : AppTheme.textMuted.withOpacity(0.8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// العربية: يحدد dynamic field label.
  String _resolveDynamicFieldLabel(
    List<DynamicFieldValueFilter> options,
    String fallbackFieldName,
  ) {
    for (final option in options) {
      final displayName = option.displayName.trim();
      if (displayName.isNotEmpty) {
        return displayName;
      }
    }

    return _humanizeDynamicFieldName(fallbackFieldName);
  }

  /// العربية: يعالج `humanizeDynamicFieldName`.
  String _humanizeDynamicFieldName(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return 'حقل إضافي';
    }

    final withSpaces = normalized.replaceAll(RegExp(r'[_-]+'), ' ');
    final collapsed = withSpaces.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (collapsed.isEmpty) {
      return normalized;
    }

    return collapsed;
  }

  /// العربية: يبني ultra footer.
  Widget _buildUltraFooter() {
    final filtersState =
        _resolveLoadedFiltersState(context.watch<SearchBloc>().state);
    final matchingResultsCount = filtersState?.matchingResultsCount;
    final isPreviewLoading = filtersState?.isPreviewLoading ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppTheme.darkSurface.withOpacity(0.8),
            AppTheme.darkSurface.withOpacity(0.95),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (matchingResultsCount != null || isPreviewLoading)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.18),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: isPreviewLoading
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryBlue,
                            ),
                          )
                        : Icon(
                            Icons.analytics_outlined,
                            size: 18,
                            color: AppTheme.primaryBlue,
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isPreviewLoading
                          ? 'يتم تحديث العدادات والنتائج...'
                          : 'النتائج المطابقة الآن: ${matchingResultsCount ?? 0}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!_isValidFilter && _validationError.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: AppTheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _validationError,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Row(
                children: [
                  if (_activeFilterCount > 0)
                    Expanded(
                      child: GestureDetector(
                        onTap: _resetFilters,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.error.withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'مسح الكل',
                              style: AppTextStyles.buttonMedium.copyWith(
                                color: AppTheme.error,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_activeFilterCount > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _isValidFilter
                          ? () {
                              HapticFeedback.mediumImpact();
                              final sanitized = _buildSanitizedFilters();
                              Navigator.pop(context, sanitized);
                            }
                          : () {
                              HapticFeedback.heavyImpact();
                              _showValidationError();
                            },
                      child: AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Container(
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: _isValidFilter
                                  ? AppTheme.primaryGradient
                                  : LinearGradient(
                                      colors: [
                                        AppTheme.textMuted.withOpacity(0.3),
                                        AppTheme.textMuted.withOpacity(0.2),
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _isValidFilter
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryBlue.withOpacity(
                                            0.3 + (0.2 * _glowAnimation.value)),
                                        blurRadius: 15,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isValidFilter
                                        ? Icons.check_rounded
                                        : Icons.lock_outline_rounded,
                                    size: 16,
                                    color: _isValidFilter
                                        ? Colors.white
                                        : AppTheme.textMuted.withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isValidFilter
                                        ? (_activeFilterCount > 0
                                            ? 'عرض ${matchingResultsCount ?? 0} نتيجة'
                                            : 'تطبيق الفلاتر')
                                        : 'أكمل الحقول المطلوبة',
                                    style: AppTextStyles.buttonMedium.copyWith(
                                      color: _isValidFilter
                                          ? Colors.white
                                          : AppTheme.textMuted.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// العربية: يبني nano button.
  Widget _buildNanoButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.darkBorder.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppTheme.textLight,
        ),
      ),
    );
  }

  /// العربية: يبني nano text button.
  Widget _buildNanoTextButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 0.5,
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
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// العربية: يبني nano counter button.
  Widget _buildNanoCounterButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.primaryBlue.withOpacity(0.1)
              : AppTheme.darkCard.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? AppTheme.primaryBlue.withOpacity(0.2)
                : AppTheme.darkBorder.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? AppTheme.primaryBlue
              : AppTheme.textMuted.withOpacity(0.3),
        ),
      ),
    );
  }

  /// العربية: يعالج `resetFilters`.
  void _resetFilters() {
    setState(() {
      _filters.clear();
      _searchTermController.clear();
      _searchTermFocusNode.unfocus();
      _activeFilterCount = 0;
      _unitTypes = [];
      _validateFilters();
    });
    _scheduleFacetPreview();
    HapticFeedback.mediumImpact();
  }

  /// العربية: يختار date.
  Future<void> _selectDate(String field) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filters[field] ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryBlue,
              surface: AppTheme.darkCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _filters[field] = picked;
        _calculateActiveFilters();
      });
    }
  }

  /// العربية: ينسق date.
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  /// العربية: يعيد amenity icon.
  IconData _getAmenityIcon(String amenity) {
    final icons = {
      'واي فاي': Icons.wifi_rounded,
      'موقف': Icons.local_parking_rounded,
      'مسبح': Icons.pool_rounded,
    };
    return icons[amenity] ?? Icons.check_circle_outline_rounded;
  }

  /// العربية: يعالج `scheduleFacetPreview`.
  void _scheduleFacetPreview() {
    _previewDebounce?.cancel();
    final sanitizedFilters = _buildSanitizedFilters();

    _previewDebounce = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      context
          .read<SearchBloc>()
          .add(PreviewSearchFacetsEvent(filters: sanitizedFilters));
    });
  }

  /// العربية: يبني sanitized filters.
  Map<String, dynamic> _buildSanitizedFilters() {
    final sanitized = _normalizeVisibleFilters(_filters);

    final normalizedSearchTerm =
        (sanitized['searchTerm'] as String?)?.trim() ?? '';
    if (normalizedSearchTerm.isEmpty) {
      sanitized.remove('searchTerm');
    } else {
      sanitized['searchTerm'] = normalizedSearchTerm;
    }

    final normalizedCity = (sanitized['city'] as String?)?.trim() ?? '';
    if (normalizedCity.isEmpty) {
      sanitized.remove('city');
    } else {
      sanitized['city'] = normalizedCity;
    }

    final dynamicFieldFilters = sanitized['dynamicFieldFilters'];
    if (dynamicFieldFilters is Map) {
      final normalizedDynamicFilters = <String, dynamic>{};
      dynamicFieldFilters.forEach((key, value) {
        if (value == null) return;
        final normalizedValue = value.toString().trim();
        if (normalizedValue.isEmpty) return;
        normalizedDynamicFilters[key.toString()] = normalizedValue;
      });

      if (normalizedDynamicFilters.isEmpty) {
        sanitized.remove('dynamicFieldFilters');
      } else {
        sanitized['dynamicFieldFilters'] = normalizedDynamicFilters;
      }
    }

    final unitTypeId = sanitized['unitTypeId'] as String?;
    if (unitTypeId != null) {
      try {
        final matching = _unitTypes.where((u) => u.id == unitTypeId);
        if (matching.isNotEmpty) {
          final ut = matching.first;
          final bool hasAdults = (ut.isHasAdults == true);
          final bool hasChildren = (ut.isHasChildren == true);
          if (!hasAdults && !hasChildren) {
            sanitized.remove('guestsCount');
            sanitized.remove('adults');
            sanitized.remove('children');
          }
        }
      } catch (_) {}
    }

    if ((sanitized['requiredAmenities'] as List?)?.isEmpty ?? false) {
      sanitized.remove('requiredAmenities');
    }

    if ((sanitized['serviceIds'] as List?)?.isEmpty ?? false) {
      sanitized.remove('serviceIds');
    }

    sanitized['preferredCurrency'] ??= 'YER';

    return sanitized;
  }

  /// العربية: يعالج `normalizeVisibleFilters`.
  Map<String, dynamic> _normalizeVisibleFilters(Map<String, dynamic> source) {
    final sanitized = Map<String, dynamic>.from(source);

    final normalizedSearchTerm =
        (sanitized['searchTerm'] as String?)?.trim() ?? '';
    if (normalizedSearchTerm.isEmpty) {
      sanitized.remove('searchTerm');
    } else {
      sanitized['searchTerm'] = normalizedSearchTerm;
    }

    final normalizedCity = (sanitized['city'] as String?)?.trim() ?? '';
    if (normalizedCity.isEmpty) {
      sanitized.remove('city');
    } else {
      sanitized['city'] = normalizedCity;
    }

    final guestsCount = sanitized['guestsCount'];
    final adults = sanitized['adults'];
    final children = sanitized['children'];
    if (guestsCount is int) {
      sanitized.remove('adults');
      sanitized.remove('children');
    } else if (adults is int || children is int) {
      final derivedGuests = (adults as int? ?? 0) + (children as int? ?? 0);
      if (derivedGuests > 0) {
        sanitized['guestsCount'] = derivedGuests;
      }
      sanitized.remove('adults');
      sanitized.remove('children');
    } else {
      sanitized.remove('adults');
      sanitized.remove('children');
    }

    if (sanitized['propertyTypeId'] == null) {
      sanitized.remove('unitTypeId');
    }

    if ((sanitized['requiredAmenities'] as List?)?.isEmpty ?? false) {
      sanitized.remove('requiredAmenities');
    }

    if ((sanitized['serviceIds'] as List?)?.isEmpty ?? false) {
      sanitized.remove('serviceIds');
    }

    if ((sanitized['dynamicFieldFilters'] as Map?)?.isEmpty ?? false) {
      sanitized.remove('dynamicFieldFilters');
    }

    sanitized.remove('latitude');
    sanitized.remove('longitude');
    sanitized.remove('radiusKm');

    return sanitized;
  }

  /// العربية: يحدد loaded filters state.
  SearchFiltersLoaded? _resolveLoadedFiltersState(SearchState state) {
    if (state is SearchCombinedState &&
        state.filtersState is SearchFiltersLoaded) {
      return state.filtersState as SearchFiltersLoaded;
    }

    if (state is SearchFiltersLoaded) {
      return state;
    }

    return null;
  }
}

// Nano Section Widget with validation support
/// العربية: يمثل `NanoSection`.
class _NanoSection extends StatelessWidget {
  /// العربية: يخزن القيمة `title`.
  final String title;

  /// العربية: يخزن القيمة `icon`.
  final IconData icon;

  /// العربية: يخزن القيمة `child`.
  final Widget child;

  /// العربية: يحدد ما إذا كانت القيمة `isRequired` مفعلة.
  final bool isRequired;

  /// العربية: يحدد ما إذا كانت القيمة `hasError` مفعلة.
  final bool hasError;

  /// العربية: يخزن القيمة `headerSuffix`.
  final Widget? headerSuffix;

  /// العربية: ينشئ مثيلًا جديدًا من `NanoSection`.
  const _NanoSection({
    required this.title,
    required this.icon,
    required this.child,
    this.isRequired = false,
    this.hasError = false,
    this.headerSuffix,
  });

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError
              ? AppTheme.error.withOpacity(0.3)
              : AppTheme.darkBorder.withOpacity(0.1),
          width: hasError ? 1.5 : 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: hasError
                            ? LinearGradient(
                                colors: [
                                  AppTheme.error.withOpacity(0.8),
                                  AppTheme.error.withOpacity(0.6),
                                ],
                              )
                            : AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        hasError ? Icons.warning_amber_rounded : icon,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: hasError ? AppTheme.error : AppTheme.textWhite,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 4),
                      Text(
                        '*',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (headerSuffix != null) headerSuffix!,
                  ],
                ),
                const SizedBox(height: 12),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Painters
/// العربية: يمثل `UltraWavePainter`.
class _UltraWavePainter extends CustomPainter {
  /// العربية: يخزن القيمة `waveAnimation`.
  final double waveAnimation;

  /// العربية: يخزن القيمة `glowIntensity`.
  final double glowIntensity;

  /// العربية: ينشئ مثيلًا جديدًا من `UltraWavePainter`.
  _UltraWavePainter({
    required this.waveAnimation,
    required this.glowIntensity,
  });

  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final offset = i * 0.3;
      final path = Path();

      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x++) {
        final y = size.height * 0.9 +
            math.sin((x / size.width * 2 * math.pi) +
                    (waveAnimation * 2 * math.pi) +
                    (offset * math.pi)) *
                10;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();

      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryBlue.withOpacity(0.02 * glowIntensity),
          AppTheme.primaryPurple.withOpacity(0.01 * glowIntensity),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(path, paint);
    }
  }

  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// العربية: يمثل `NanoParticle`.
class _NanoParticle {
  /// العربية: يخزن القيمة `opacity`.
  late double x, y, vx, vy, radius, opacity;

  /// العربية: ينشئ مثيلًا جديدًا من `NanoParticle`.
  _NanoParticle() {
    reset();
  }

  /// العربية: يعالج `reset`.
  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    vx = (math.Random().nextDouble() - 0.5) * 0.001;
    vy = (math.Random().nextDouble() - 0.5) * 0.001;
    radius = math.Random().nextDouble() * 1.5 + 0.5;
    opacity = math.Random().nextDouble() * 0.3 + 0.1;
  }

  /// العربية: يحدّث العملية المطلوبة لـ `update`.
  void update() {
    x += vx;
    y += vy;
    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;
  }
}

/// العربية: يمثل `NanoParticlePainter`.
class _NanoParticlePainter extends CustomPainter {
  /// العربية: يخزن القيمة `particles`.
  final List<_NanoParticle> particles;

  /// العربية: يخزن القيمة `animation`.
  final double animation;

  /// العربية: ينشئ مثيلًا جديدًا من `NanoParticlePainter`.
  _NanoParticlePainter({
    required this.particles,
    required this.animation,
  });

  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      particle.update();

      paint.color = AppTheme.primaryBlue.withOpacity(particle.opacity);

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius,
        paint,
      );
    }
  }

  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
