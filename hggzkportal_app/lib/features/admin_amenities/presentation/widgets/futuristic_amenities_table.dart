import 'package:hggzkportal/features/admin_amenities/presentation/utils/amenity_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/amenity_identity_card_tooltip.dart';
import '../../domain/entities/amenity.dart';

/// يعرض جدولًا متقدمًا لإدارة المرافق مع فرز وتصفية وحركات واجهة غنية.
class FuturisticAmenitiesTable extends StatefulWidget {
  /// قائمة المرافق المعروضة في الجدول.
  final List<Amenity> amenities;

  /// يستدعى عندما يختار المستخدم مرفقًا من الصفوف.
  final Function(Amenity) onAmenitySelected;

  /// يستدعى لبدء تعديل مرفق محدد إذا كان التعديل متاحًا.
  final Function(Amenity)? onEditAmenity;

  /// يستدعى لبدء حذف مرفق محدد إذا كان الحذف متاحًا.
  final Function(Amenity)? onDeleteAmenity;

  /// يستدعى لإسناد المرفق إلى عقار أو وحدة مرتبطة.
  final Function(Amenity)? onAssignAmenity;

  /// يستدعى عند الحاجة إلى تحميل المزيد من المرافق.
  final VoidCallback? onLoadMore;

  /// يحدد هل وصلنا إلى نهاية قائمة التحميل.
  final bool hasReachedMax;

  /// يحدد هل ما زال تحميل المزيد جاريًا.
  final bool isLoadingMore;

  /// متحكم التمرير الخارجي عند الحاجة إلى ربط الجدول بمسار تمرير الصفحة.
  final ScrollController? controller;

  /// يبني الجدول مع نقاط الربط الخاصة بالتحديد والتحرير والحذف والإسناد.
  const FuturisticAmenitiesTable({
    super.key,
    required this.amenities,
    required this.onAmenitySelected,
    this.onEditAmenity,
    this.onDeleteAmenity,
    this.onAssignAmenity,
    this.onLoadMore,
    this.hasReachedMax = true,
    this.isLoadingMore = false,
    this.controller,
  });

  /// ينشئ حالة الجدول المسؤولة عن الحركة والترتيب والتحميل الإضافي.
  @override
  State<FuturisticAmenitiesTable> createState() =>
      _FuturisticAmenitiesTableState();
}

/// تدير هذه الحالة الترتيب والـ shimmer والـ hover والتفاعل مع الصفوف.
class _FuturisticAmenitiesTableState extends State<FuturisticAmenitiesTable>
    with TickerProviderStateMixin {
  // Animation Controllers
  /// متحكم التلاشي العام للجدول.
  late AnimationController _fadeAnimationController;

  /// متحكم حركة اللمعان المستمر.
  late AnimationController _shimmerController;

  /// متحكم النبض البصري الخفيف.
  late AnimationController _pulseController;

  /// منحنى الشفافية المستخدم عند ظهور الجدول.
  late Animation<double> _fadeAnimation;

  // State
  /// الصف الذي يمر عليه المؤشر حاليًا.
  int? _hoveredIndex;

  /// حقل الفرز الحالي.
  String _sortBy = 'name';

  /// اتجاه الفرز الحالي.
  bool _isAscending = true;

  /// متحكم التمرير الداخلي المستخدم عند الحاجة إلى مزامنة الحركة.
  late final ScrollController _scrollController;

  /// يحدد هل هذه الحالة هي مالك متحكم التمرير.
  bool _ownsController = false;

  /// مفاتيح الصفوف التي يستخدمها عرض التلميحات.
  final Map<String, GlobalKey> _amenityRowKeys = {};

  // Responsive breakpoints (match units table)
  /// نقطة الفصل بين عرض الجوال والتابلت.
  static const double _mobileBreakpoint = 600;

  /// نقطة الفصل العليا قبل اعتبار الشاشة مكتبية.
  static const double _tabletBreakpoint = 1024;

  /// فلتر الحالة النشطة.
  /// null = الكل، true = نشط، false = معطل.
  bool? _activeFilter;

  /// فلتر المرافق ذات الكلفة الإضافية.
  /// null = الكل، true = مدفوع، false = مجاني.
  bool? _paidFilter;

  Widget _buildSecondaryText(
    String? value, {
    int maxLines = 1,
    TextStyle? style,
  }) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        value,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style ??
            AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted.withValues(alpha: 0.85),
            ),
      ),
    );
  }

  /// قائمة المرافق بعد تطبيق الفلاتر الحالية.
  late List<Amenity> _filteredAmenities;

  /// يجهز الأنيميشن والمتصفحات الداخلية عند إنشاء الجدول.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeControllers();
  }

  /// يضبط حركات الظهور واللمعان والنبض.
  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimationController.forward();
  }

  /// ينشئ متحكم التمرير الداخلي عندما لا يأتي من الخارج.
  void _initializeControllers() {
    // Do not attach internal scroll to avoid nested scrolling; use page scroll only
    _scrollController = ScrollController();
    _ownsController = true;
  }

  /// يحرر المتحكمات التابعة للجدول عند إزالته.
  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    if (_ownsController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  /// يعيد مفتاح الصف الخاص بالمرفق ليسهل ربط التلميح به.
  GlobalKey _getAmenityRowKey(String amenityId, {String scope = 'default'}) {
    final cacheKey = scope.isEmpty ? amenityId : '$amenityId-$scope';
    return _amenityRowKeys.putIfAbsent(cacheKey, () => GlobalKey());
  }

  /// يعرض بطاقة تعريف المرفق فوق الصف المرتبط به.
  void _showAmenityTooltip(Amenity amenity, {String scope = 'default'}) {
    final targetKey = _getAmenityRowKey(amenity.id, scope: scope);
    AmenityIdentityCardTooltip.show(
      context: context,
      targetKey: targetKey,
      amenityId: amenity.id,
      name: amenity.nameEn?.trim().isNotEmpty == true
          ? '${amenity.name} / ${amenity.nameEn}'
          : amenity.name,
      description: amenity.descriptionEn?.trim().isNotEmpty == true
          ? '${amenity.description}\n${amenity.descriptionEn}'
          : amenity.description,
      icon: amenity.icon,
      isAvailable: amenity.isActive ?? true,
      extraCost: amenity.averageExtraCost,
      currency: null,
      propertiesCount: amenity.propertiesCount,
      category: null,
    );
  }

  /// يعيد المرافق بعد تطبيق الفرز الحالي على البيانات الأصلية.
  List<Amenity> get _sortedAmenities {
    final sorted = List<Amenity>.from(widget.amenities);

    sorted.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'properties':
          comparison =
              (a.propertiesCount ?? 0).compareTo(b.propertiesCount ?? 0);
          break;
        case 'cost':
          comparison =
              (a.averageExtraCost ?? 0).compareTo(b.averageExtraCost ?? 0);
          break;
        case 'status':
          comparison = (a.isActive == true ? 1 : 0)
              .compareTo(b.isActive == true ? 1 : 0);
          break;
        default:
          comparison = 0;
      }
      return _isAscending ? comparison : -comparison;
    });

    return sorted;
  }

  /// يبني الجدول المناسب للحجم الحالي للشاشة مع تطبيق الفلاتر والفرز.
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < _mobileBreakpoint;
    final isTablet =
        size.width >= _mobileBreakpoint && size.width < _tabletBreakpoint;

    // derive filtered list
    _filteredAmenities = widget.amenities.where((a) {
      if (_activeFilter != null) {
        if ((a.isActive == true) != _activeFilter) return false;
      }
      if (_paidFilter != null) {
        final hasCost = (a.averageExtraCost ?? 0) > 0;
        if (hasCost != _paidFilter) return false;
      }
      return true;
    }).toList();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (isMobile) return _buildMobileView();
          if (isTablet) return _buildTabletView();
          return _buildDesktopView();
        },
      ),
    );
  }

  // ================= Units-like Table: Mobile/Tablet/Desktop =================
  /// يبني العرض المحمول للجدول مع قائمة بطاقات عمودية.
  Widget _buildMobileView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMobileFilterBar(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: _sortedAmenitiesForDisplay.length,
            itemBuilder: (context, index) {
              final amenity = _sortedAmenitiesForDisplay[index];
              return _buildMobileAmenityRowCard(amenity, index);
            },
          ),
          if (widget.isLoadingMore) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  /// يبني عرض التابلت مع رأس جدولي وحركة خفيفة.
  Widget _buildTabletView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.glassLight.withValues(alpha: 0.05),
              AppTheme.glassDark.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.darkBorder.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTabletHeader(),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _sortedAmenitiesForDisplay.length,
                      itemBuilder: (context, index) {
                        final amenity = _sortedAmenitiesForDisplay[index];
                        return _buildTabletRow(amenity, index);
                      },
                    ),
                  ),
                ),
                if (widget.isLoadingMore) _buildLoadingIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// يبني العرض المكتبي الكامل للجدول.
  Widget _buildDesktopView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.glassLight.withValues(alpha: 0.05),
              AppTheme.glassDark.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.darkBorder.withValues(alpha: 0.3),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDesktopHeader(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sortedAmenitiesForDisplay.length,
                  itemBuilder: (context, index) => _buildDesktopRow(
                      _sortedAmenitiesForDisplay[index], index),
                ),
                if (widget.isLoadingMore) _buildLoadingIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== Header & Rows (units style) =====
  /// يبني صف العناوين للعرض المكتبي.
  Widget _buildDesktopHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.1),
            AppTheme.primaryPurple.withValues(alpha: 0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('المرفق', flex: 3),
          _buildHeaderCell('العقارات', flex: 1),
          _buildHeaderCell('التكلفة', flex: 1),
          _buildHeaderCell('الحالة', flex: 1),
          _buildHeaderCell('الإجراءات', flex: 2),
        ],
      ),
    );
  }

  /// يبني رأس التابلت مع شريط التصفية.
  Widget _buildTabletHeader() {
    return Column(
      children: [
        _buildTabletFilterBar(),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryBlue.withValues(alpha: 0.1),
                AppTheme.primaryPurple.withValues(alpha: 0.05),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              _buildHeaderCell('المرفق', flex: 3),
              _buildHeaderCell('العقارات', flex: 2),
              _buildHeaderCell('التكلفة', flex: 2),
              _buildHeaderCell('الحالة', flex: 1),
              _buildHeaderCell('الإجراءات', flex: 2),
            ],
          ),
        ),
      ],
    );
  }

  /// يبني خلية عنوان قابلة للتوسيع داخل الرأس.
  Widget _buildHeaderCell(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.primaryBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// يعيد المرافق بعد الفرز ثم بعد تطبيق الفلاتر الحالية.
  List<Amenity> get _sortedAmenitiesForDisplay =>
      _sortedAmenities.where((a) => _filteredAmenities.contains(a)).toList();

  /// يبني صفًا مكتبيًا واحدًا للمرفق.
  Widget _buildDesktopRow(Amenity amenity, int index) {
    final isEven = index % 2 == 0;
    final isHovered = _hoveredIndex == index;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        key: _getAmenityRowKey(amenity.id, scope: 'desktop'),
        onTap: () {
          HapticFeedback.lightImpact();
          _showAmenityTooltip(amenity, scope: 'desktop');
          // عرض التفاصيل فقط بدون الانتقال إلى صفحة جديدة
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showAmenityTooltip(amenity, scope: 'desktop');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isHovered
                ? LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.08),
                      AppTheme.primaryPurple.withValues(alpha: 0.04),
                    ],
                  )
                : null,
            color: !isHovered
                ? isEven
                    ? AppTheme.darkCard.withValues(alpha: 0.03)
                    : Colors.transparent
                : null,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.darkBorder.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Amenity info (icon + name + desc)
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getAmenityIcon(amenity.icon),
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            amenity.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppTheme.textWhite,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          _buildSecondaryText(amenity.nameEn),
                          Text(
                            amenity.description,
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          _buildSecondaryText(amenity.descriptionEn),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Properties count
              Expanded(
                flex: 1,
                child: Text(
                  '${amenity.propertiesCount ?? 0}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textLight,
                  ),
                ),
              ),

              // Cost
              Expanded(
                flex: 1,
                child: Text(
                  (amenity.averageExtraCost != null &&
                          amenity.averageExtraCost! > 0)
                      ? '\$${amenity.averageExtraCost!.toStringAsFixed(0)}'
                      : 'مجاني',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: (amenity.averageExtraCost != null &&
                            amenity.averageExtraCost! > 0)
                        ? AppTheme.primaryBlue
                        : AppTheme.textMuted,
                    fontWeight: (amenity.averageExtraCost != null &&
                            amenity.averageExtraCost! > 0)
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),

              // Status
              Expanded(
                flex: 1,
                child: _buildStatusBadge(amenity),
              ),

              // Actions
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: Icons.visibility_rounded,
                      color: AppTheme.primaryBlue,
                      onTap: () =>
                          _showAmenityTooltip(amenity, scope: 'desktop-action'),
                    ),
                    if (widget.onEditAmenity != null) ...[
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.edit,
                        color: AppTheme.primaryBlue,
                        onTap: () => widget.onEditAmenity!(amenity),
                      ),
                    ],
                    if (widget.onAssignAmenity != null) ...[
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.assignment_rounded,
                        color: AppTheme.primaryPurple,
                        onTap: () => widget.onAssignAmenity!(amenity),
                      ),
                    ],
                    if (widget.onDeleteAmenity != null) ...[
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.delete,
                        color: AppTheme.error,
                        onTap: () => widget.onDeleteAmenity!(amenity),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// يعيد العرض الخاص بالتابلت اعتمادًا على صف الجدول المكتبي.
  Widget _buildTabletRow(Amenity amenity, int index) {
    // For tablet, reuse desktop row (width handled by SizedBox in tablet view)
    return _buildDesktopRow(amenity, index);
  }

  // ===== Mobile components =====
  /// يبني شريط الفلاتر السريع في العرض المحمول.
  Widget _buildMobileFilterBar() {
    final totalActive =
        widget.amenities.where((a) => a.isActive == true).length;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.9),
            AppTheme.darkCard.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('الكل (${widget.amenities.length})', null, null),
            const SizedBox(width: 8),
            _buildFilterChip('نشط ($totalActive)', true, null),
            const SizedBox(width: 8),
            _buildFilterChip('معطل', false, null),
            const SizedBox(width: 8),
            _buildFilterChip('مدفوع', null, true),
            const SizedBox(width: 8),
            _buildFilterChip('مجاني', null, false),
          ],
        ),
      ),
    );
  }

  /// يعيد نفس شريط الفلاتر للتابلت ليوحد السلوك بين الشاشات.
  Widget _buildTabletFilterBar() {
    return _buildMobileFilterBar();
  }

  /// يبني شارة تفاعلية لتصفية القائمة حسب الحالة أو التكلفة.
  Widget _buildFilterChip(String label, bool? activeFilter, bool? paidFilter) {
    final isSelected =
        (_activeFilter == activeFilter) && (_paidFilter == paidFilter);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _activeFilter = activeFilter;
          _paidFilter = paidFilter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.3),
                    AppTheme.primaryPurple.withValues(alpha: 0.2),
                  ],
                )
              : null,
          color:
              !isSelected ? AppTheme.darkSurface.withValues(alpha: 0.5) : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                : AppTheme.darkBorder.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// يبني بطاقة مرفق مضغوطة للعرض المحمول مع أفعال سريعة.
  Widget _buildMobileAmenityRowCard(Amenity amenity, int index) {
    final isHovered = _hoveredIndex == index;
    return GestureDetector(
      key: _getAmenityRowKey(amenity.id, scope: 'mobile'),
      onTap: () {
        HapticFeedback.lightImpact();
        _showAmenityTooltip(amenity, scope: 'mobile');
        // عرض التفاصيل فقط بدون الانتقال إلى صفحة جديدة
      },
      onTapDown: (_) => setState(() => _hoveredIndex = index),
      onTapUp: (_) => setState(() => _hoveredIndex = null),
      onTapCancel: () => setState(() => _hoveredIndex = null),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showAmenityTooltip(amenity, scope: 'mobile');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        transform: Matrix4.identity()..scale(isHovered ? 0.98 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withValues(alpha: 0.9),
              AppTheme.darkCard.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered
                ? AppTheme.primaryBlue.withValues(alpha: 0.4)
                : AppTheme.darkBorder.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getAmenityIcon(amenity.icon),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              amenity.name,
                              style: AppTextStyles.heading3.copyWith(
                                fontSize: 16,
                                color: AppTheme.textWhite,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            _buildSecondaryText(amenity.nameEn),
                            const SizedBox(height: 2),
                            Text(
                              amenity.description,
                              style: AppTextStyles.caption.copyWith(
                                color: AppTheme.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            _buildSecondaryText(amenity.descriptionEn),
                          ],
                        ),
                      ),
                      _buildStatusBadge(amenity),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.business_rounded,
                                size: 16,
                                color: AppTheme.primaryBlue,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${amenity.propertiesCount ?? 0}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'عقار',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppTheme.primaryBlue
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                (amenity.averageExtraCost ?? 0) > 0
                                    ? Icons.attach_money_rounded
                                    : Icons.money_off_rounded,
                                size: 16,
                                color: (amenity.averageExtraCost ?? 0) > 0
                                    ? AppTheme.success
                                    : AppTheme.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                (amenity.averageExtraCost ?? 0) > 0
                                    ? amenity.averageExtraCost!
                                        .toStringAsFixed(0)
                                    : 'مجاني',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: (amenity.averageExtraCost ?? 0) > 0
                                      ? AppTheme.success
                                      : AppTheme.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionTextButton(
                          label: 'عرض التفاصيل',
                          icon: Icons.visibility_rounded,
                          color: AppTheme.primaryBlue,
                          onTap: () => _showAmenityTooltip(amenity,
                              scope: 'tablet-action'),
                        ),
                      ),
                      if (widget.onEditAmenity != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActionTextButton(
                            label: 'تعديل',
                            icon: Icons.edit_rounded,
                            color: AppTheme.primaryPurple,
                            onTap: () => widget.onEditAmenity!(amenity),
                          ),
                        ),
                      ],
                      if (widget.onDeleteAmenity != null) ...[
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.delete_rounded,
                          color: AppTheme.error,
                          onTap: () => widget.onDeleteAmenity!(amenity),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// يبني مؤشر الحالة التفاعلي الذي يوضح النشاط الحالي للمرفق.
  Widget _buildStatusWidget(Amenity amenity) {
    final isActive = amenity.isActive == true;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Toggle status functionality
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [
                    AppTheme.success.withValues(alpha: 0.2),
                    AppTheme.neonGreen.withValues(alpha: 0.1),
                  ]
                : [
                    AppTheme.textMuted.withValues(alpha: 0.2),
                    AppTheme.textMuted.withValues(alpha: 0.1),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppTheme.success.withValues(alpha: 0.5)
                : AppTheme.textMuted.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.success.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.success : AppTheme.textMuted,
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppTheme.success.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isActive ? 'نشط' : 'معطل',
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppTheme.success : AppTheme.textMuted,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Compatibility badge API used by the units-like table rows
  /// يوفر نفس واجهة الشارة القديمة مع إعادة استخدام ويدجت الحالة.
  Widget _buildStatusBadge(Amenity amenity) {
    return _buildStatusWidget(amenity);
  }

  // Reusable actions/buttons for table rows
  /// يبني زر إجراء أيقوني صغير داخل صف الجدول.
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withValues(alpha: 0.1),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }

  /// يبني زر إجراء نصي أكبر يناسب العرض المحمول أو التابلت.
  Widget _buildActionTextButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
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
      ),
    );
  }

  /// يبني مؤشر تحميل سفلي عند جلب المزيد من المرافق.
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'جاري التحميل...',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// يحول اسم الأيقونة النصي إلى أيقونة Material مناسبة للمرفق.
  IconData _getAmenityIcon(String iconName) {
    return AmenityIcons.getIconByName(iconName)?.icon ?? Icons.star_rounded;
  }
}
