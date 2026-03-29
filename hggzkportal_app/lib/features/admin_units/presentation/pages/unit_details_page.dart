// lib/features/admin_units/presentation/pages/unit_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../bloc/unit_details/unit_details_bloc.dart';
import '../../domain/entities/unit.dart';
import '../../domain/entities/unit_analytics.dart';
import '../../domain/entities/unit_field_value.dart';
import '../widgets/unit_image_gallery.dart';
// ✅ إضافة imports لصفحة إدارة الأسعار والإتاحة
import '../../../admin_daily_schedule/presentation/pages/daily_schedule_page.dart';
import '../../../admin_daily_schedule/presentation/bloc/daily_schedule_barrel.dart';
import '../../../../injection_container.dart';

/// يمثل هذا الكلاس UnitDetailsPage البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitDetailsPage in the admin unit workflow.
class UnitDetailsPage extends StatefulWidget {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String unitId;

  /// ينشئ هذا المُنشئ مثيلاً من UnitDetailsPage.
  /// This constructor creates an instance of UnitDetailsPage.
  const UnitDetailsPage({
    super.key,
    required this.unitId,
  });

  /// ينشئ هذا الأسلوب كائن الحالة الخاص بهذه الصفحة.
  /// This method performs the createState operation in the admin unit workflow.
  @override
  State<UnitDetailsPage> createState() => _UnitDetailsPageState();
}

/// يمثل هذا الكلاس _UnitDetailsPageState البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _UnitDetailsPageState in the admin unit workflow.
class _UnitDetailsPageState extends State<UnitDetailsPage>
    with SingleTickerProviderStateMixin {
  // Animation Controller - واحد فقط للحركات الأساسية
  /// يحتفظ هذا الحقل بقيمة _animationController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _animationController value used by the admin unit workflow.
  late AnimationController _animationController;

  // Scroll Controller
  final ScrollController _scrollController = ScrollController();

  /// يحتفظ هذا الحقل بقيمة _scrollOffset التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _scrollOffset value used by the admin unit workflow.
  double _scrollOffset = 0;

  // Tab Controller
  /// يحتفظ هذا الحقل بقيمة _selectedTabIndex التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _selectedTabIndex value used by the admin unit workflow.
  int _selectedTabIndex = 0;

  /// ينفذ هذا الأسلوب عملية initState ضمن مسار إدارة الوحدات.
  /// This method performs the initState operation in the admin unit workflow.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    /// ينفذ هذا الأسلوب عملية _setupScrollListener ضمن مسار إدارة الوحدات.
    /// This method performs the _setupScrollListener operation in the admin unit workflow.
    _setupScrollListener();

    /// ينفذ هذا الأسلوب عملية _loadUnitDetails ضمن مسار إدارة الوحدات.
    /// This method performs the _loadUnitDetails operation in the admin unit workflow.
    _loadUnitDetails();
  }

  /// ينفذ هذا الأسلوب عملية _setupScrollListener ضمن مسار إدارة الوحدات.
  /// This method performs the _setupScrollListener operation in the admin unit workflow.
  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (mounted) {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      }
    });
  }

  /// ينفذ هذا الأسلوب عملية _loadUnitDetails ضمن مسار إدارة الوحدات.
  /// This method performs the _loadUnitDetails operation in the admin unit workflow.
  void _loadUnitDetails() {
    context.read<UnitDetailsBloc>().add(
          LoadUnitDetailsEvent(unitId: widget.unitId),
        );
  }

  /// ينفذ هذا الأسلوب عملية dispose ضمن مسار إدارة الوحدات.
  /// This method performs the dispose operation in the admin unit workflow.
  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: BlocConsumer<UnitDetailsBloc, UnitDetailsState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          if (state is UnitDetailsLoaded) {
            return _buildLoadedContent(state.unit, state.analytics);
          } else if (state is UnitDetailsLoading) {
            return _buildLoadingState();
          } else if (state is UnitDetailsError) {
            return _buildErrorState(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildLoadedContent ضمن مسار إدارة الوحدات.
  /// This method performs the _buildLoadedContent operation in the admin unit workflow.
  Widget _buildLoadedContent(Unit unit, UnitAnalytics? analytics) {
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Hero Header
            _buildSliverHeader(unit),

            // Unit Info
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _animationController,
                child: _buildContent(unit, analytics),
              ),
            ),
          ],
        ),

        // Floating Header (appears on scroll)
        if (_scrollOffset > 300) _buildFloatingHeader(unit),

        // Floating Actions
        _buildFloatingActions(unit),
      ],
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildSliverHeader ضمن مسار إدارة الوحدات.
  /// This method performs the _buildSliverHeader operation in the admin unit workflow.
  Widget _buildSliverHeader(Unit unit) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: false,
      leadingWidth: 40,
      toolbarHeight: 40,
      backgroundColor: Colors.transparent,
      leading: _buildBackButton(),
      actions: [
        _buildActionButton(
          icon: Icons.share,
          onTap: () => _shareUnit(unit),
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            if (unit.images?.isNotEmpty ?? false)
              Hero(
                tag: 'unit-${unit.id}',
                child: CachedImageWidget(
                  imageUrl: unit.images!.first,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.3),
                      AppTheme.primaryPurple.withValues(alpha: 0.2),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    CupertinoIcons.photo,
                    size: 60,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.4, 0.6, 1.0],
                ),
              ),
            ),

            // Unit Info
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildHeaderInfo(unit),
            ),
          ],
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildHeaderInfo ضمن مسار إدارة الوحدات.
  /// This method performs the _buildHeaderInfo operation in the admin unit workflow.
  Widget _buildHeaderInfo(Unit unit) {
    final secondaryLocation = [
      if ((unit.propertyNameEn ?? '').trim().isNotEmpty) unit.propertyNameEn!,
      if ((unit.unitTypeNameEn ?? '').trim().isNotEmpty) unit.unitTypeNameEn!,
    ].join(' • ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Unit Name
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unit.name,
              style: AppTextStyles.heading1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            if ((unit.nameEn ?? '').trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  unit.nameEn!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Property Name
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              CupertinoIcons.building_2_fill,
              size: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${unit.propertyName} • ${unit.unitTypeName}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  if (secondaryLocation.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        secondaryLocation,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Price & Status - Commented out: basePrice and isAvailable removed
        /*
        Row(
          children: [
            _buildPriceTag(unit.basePrice, unit.pricingMethod),
            const SizedBox(width: 12),
            _buildStatusBadge(unit.isAvailable),
          ],
        ),
        */
      ],
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildContent ضمن مسار إدارة الوحدات.
  /// This method performs the _buildContent operation in the admin unit workflow.
  Widget _buildContent(Unit unit, UnitAnalytics? analytics) {
    return Column(
      children: [
        // Stats Cards
        _buildStatsSection(unit, analytics),

        // Tab Bar
        _buildTabBar(),

        // Tab Content
        _buildTabContent(unit),

        const SizedBox(height: 100),
      ],
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildStatsSection ضمن مسار إدارة الوحدات.
  /// This method performs the _buildStatsSection operation in the admin unit workflow.
  Widget _buildStatsSection(Unit unit, UnitAnalytics? analytics) {
    final avgRating = analytics?.averageRating;
    final ratingText = avgRating == null ? '-' : avgRating.toStringAsFixed(1);

    final occupancy = analytics?.occupancyRate;
    final occupancyText =
        occupancy == null ? '-' : '${(occupancy * 100).toStringAsFixed(0)}%';

    return Container(
      margin: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _buildStatCard(
                icon: CupertinoIcons.eye,
                label: 'المشاهدات',
                value: unit.viewCount.toString(),
                color: AppTheme.primaryBlue,
              ),
              _buildStatCard(
                icon: CupertinoIcons.calendar,
                label: 'الحجوزات',
                value: unit.bookingCount.toString(),
                color: AppTheme.primaryPurple,
              ),
              _buildStatCard(
                icon: CupertinoIcons.chart_bar,
                label: 'الإشغال',
                value: occupancyText,
                color: AppTheme.warning,
              ),
              _buildStatCard(
                icon: CupertinoIcons.star_fill,
                label: 'التقييم',
                value: ratingText,
                color: AppTheme.warning,
              ),
              _buildStatCard(
                icon: CupertinoIcons.person_2,
                label: 'السعة',
                value: _getCapacityStatValue(unit),
                color: AppTheme.primaryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildStatCard ضمن مسار إدارة الوحدات.
  /// This method performs the _buildStatCard operation in the admin unit workflow.
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // مهم: لجعل Column تأخذ أقل مساحة ممكنة
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 14,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildTabBar ضمن مسار إدارة الوحدات.
  /// This method performs the _buildTabBar operation in the admin unit workflow.
  Widget _buildTabBar() {
    final tabs = ['معلومات', 'الصور', 'المميزات', 'التوفر'];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTabIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : AppTheme.textMuted,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildTabContent ضمن مسار إدارة الوحدات.
  /// This method performs the _buildTabContent operation in the admin unit workflow.
  Widget _buildTabContent(Unit unit) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _getTabContent(unit),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _getTabContent ضمن مسار إدارة الوحدات.
  /// This method performs the _getTabContent operation in the admin unit workflow.
  Widget _getTabContent(Unit unit) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildInfoTab(unit);
      case 1:
        return _buildGalleryTab(unit);
      case 2:
        return _buildFeaturesTab(unit);
      case 3:
        return _buildAvailabilityTab(unit);
      default:
        return _buildInfoTab(unit);
    }
  }

  /// ينفذ هذا الأسلوب عملية _buildInfoTab ضمن مسار إدارة الوحدات.
  /// This method performs the _buildInfoTab operation in the admin unit workflow.
  Widget _buildInfoTab(Unit unit) {
    return Container(
      key: const ValueKey('info'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('معلومات عامة'),
          const SizedBox(height: 16),
          _buildInfoRow('الكود', unit.name, secondaryValue: unit.nameEn),
          _buildInfoRow('النوع', unit.unitTypeName,
              secondaryValue: unit.unitTypeNameEn),
          _buildInfoRow('العقار', unit.propertyName,
              secondaryValue: unit.propertyNameEn),
          _buildInfoRow('السعة', _getCapacityInfoText(unit)),
          // الحقول الأساسية (Primary Filters)
          if (unit.dynamicFields.isNotEmpty || unit.fieldValues.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionTitle('المعلومات الأساسية'),
            const SizedBox(height: 12),
            _buildAllDynamicFields(unit),
          ],
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildGalleryTab ضمن مسار إدارة الوحدات.
  /// This method performs the _buildGalleryTab operation in the admin unit workflow.
  Widget _buildGalleryTab(Unit unit) {
    return SizedBox(
      key: const ValueKey('gallery'),
      height: 400,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: UnitImageGallery(
          unitId: widget.unitId,
          isReadOnly: true,
          maxImages: 20,
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _getCapacityStatValue ضمن مسار إدارة الوحدات.
  /// This method performs the _getCapacityStatValue operation in the admin unit workflow.
  String _getCapacityStatValue(Unit unit) {
    final detailedCapacity =
        (unit.adultsCapacity ?? 0) + (unit.childrenCapacity ?? 0);
    if (detailedCapacity > 0) {
      return detailedCapacity.toString();
    }

    return unit.maxCapacity.toString();
  }

  /// ينفذ هذا الأسلوب عملية _getCapacityInfoText ضمن مسار إدارة الوحدات.
  /// This method performs the _getCapacityInfoText operation in the admin unit workflow.
  String _getCapacityInfoText(Unit unit) {
    final parts = <String>[];

    if (unit.adultsCapacity != null) {
      parts.add('البالغين: ${unit.adultsCapacity}');
    }

    if (unit.childrenCapacity != null) {
      parts.add('الأطفال: ${unit.childrenCapacity}');
    }

    if (parts.isNotEmpty) {
      return parts.join(' • ');
    }

    return '${unit.maxCapacity} أشخاص';
  }

  /// ينفذ هذا الأسلوب عملية _buildFeaturesTab ضمن مسار إدارة الوحدات.
  /// This method performs the _buildFeaturesTab operation in the admin unit workflow.
  Widget _buildFeaturesTab(Unit unit) {
    final primaryFeatures = unit.featuresList;
    final secondaryFeatures = _splitFeatures(unit.customFeaturesEn);

    return Container(
      key: const ValueKey('features'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: primaryFeatures.isEmpty && secondaryFeatures.isEmpty
          ? Center(
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.sparkles,
                    size: 48,
                    color: AppTheme.textMuted.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد مميزات مضافة',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (primaryFeatures.isNotEmpty)
                  _buildFeaturesWrap(
                    primaryFeatures,
                    textColor: AppTheme.textWhite,
                    accentColor: AppTheme.primaryBlue,
                  ),
                if (secondaryFeatures.isNotEmpty) ...[
                  if (primaryFeatures.isNotEmpty) const SizedBox(height: 16),
                  Text(
                    'English',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFeaturesWrap(
                    secondaryFeatures,
                    textColor: Colors.white.withValues(alpha: 0.85),
                    accentColor: AppTheme.primaryPurple,
                  ),
                ],
              ],
            ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildAvailabilityTab ضمن مسار إدارة الوحدات.
  /// This method performs the _buildAvailabilityTab operation in the admin unit workflow.
  Widget _buildAvailabilityTab(Unit unit) {
    return Container(
      key: const ValueKey('availability'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ أيقونة تقويم جذابة
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.calendar_today,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // ✅ عنوان واضح
          Text(
            'إدارة الأسعار والإتاحة',
            style: AppTextStyles.displaySmall.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // ✅ وصف
          Text(
            'قم بإدارة الأسعار اليومية والإتاحة من خلال التقويم الموحد',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 32),

          // ✅ زر الانتقال إلى صفحة إدارة الأسعار
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // الانتقال إلى صفحة إدارة الجدول اليومي
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => sl<DailyScheduleBloc>(),
                      child: DailySchedulePage(
                        initialUnitId: unit.id,
                        initialUnitName: unit.name,
                      ),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.calendar_badge_plus,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'فتح التقويم',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildSectionTitle ضمن مسار إدارة الوحدات.
  /// This method performs the _buildSectionTitle operation in the admin unit workflow.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppTheme.primaryBlue,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildInfoRow ضمن مسار إدارة الوحدات.
  /// This method performs the _buildInfoRow operation in the admin unit workflow.
  Widget _buildInfoRow(
    String label,
    String value, {
    String? secondaryLabel,
    String? secondaryValue,
  }) {
    final normalizedSecondaryLabel =
        _normalizeSecondaryValue(secondaryLabel, label);
    final normalizedSecondary = _normalizeSecondaryValue(secondaryValue, value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                if (normalizedSecondaryLabel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      normalizedSecondaryLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (normalizedSecondary != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      normalizedSecondary,
                      textAlign: TextAlign.end,
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildDynamicFields ضمن مسار إدارة الوحدات.
  /// This method performs the _buildDynamicFields operation in the admin unit workflow.
  Widget _buildDynamicFields(List<FieldGroupWithValues> fieldGroups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fieldGroups.map((group) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.displayName,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_normalizeSecondaryValue(
                      group.displayNameEn, group.displayName) !=
                  null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _normalizeSecondaryValue(
                      group.displayNameEn,
                      group.displayName,
                    )!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              ...group.fieldValues.map((field) {
                final value = field.fieldValue;
                return _buildInfoRow(
                  field.displayName ?? field.fieldName ?? '',
                  _formatFieldValue(value, field.fieldTypeId ?? 'text'),
                  secondaryLabel: field.displayNameEn,
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  // جمع الحقول من المصدرين وعرض غير المكررات
  /// ينفذ هذا الأسلوب عملية _buildAllDynamicFields ضمن مسار إدارة الوحدات.
  /// This method performs the _buildAllDynamicFields operation in the admin unit workflow.
  Widget _buildAllDynamicFields(Unit unit) {
    final grouped = unit.dynamicFields;
    final groupedFieldIds = <String>{
      for (final g in grouped)
        for (final f in g.fieldValues) f.fieldId,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (grouped.isNotEmpty) _buildDynamicFields(grouped),
        ...unit.fieldValues
            .where((fv) => !groupedFieldIds.contains(fv.fieldId))
            .map((fv) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildInfoRow(
                    fv.displayName ?? fv.fieldName ?? 'حقل',
                    _formatFieldValue(fv.fieldValue, fv.fieldTypeId ?? 'text'),
                    secondaryLabel: fv.displayNameEn,
                  ),
                )),
      ],
    );
  }

  // منسق بسيط للقيم مثل الكارد
  /// ينفذ هذا الأسلوب عملية _formatFieldValue ضمن مسار إدارة الوحدات.
  /// This method performs the _formatFieldValue operation in the admin unit workflow.
  String _formatFieldValue(dynamic value, String fieldType) {
    if (value == null || value.toString().isEmpty) return 'غير محدد';
    switch (fieldType) {
      case 'boolean':
        final v = value.toString().toLowerCase();
        return (v == 'true' || v == '1' || v == 'yes') ? 'نعم' : 'لا';
      case 'currency':
        final num? n = value is num ? value : num.tryParse(value.toString());
        return n != null ? '${n.toStringAsFixed(0)} ريال' : '$value ريال';
      case 'date':
        try {
          final d =
              value is DateTime ? value : DateTime.parse(value.toString());
          return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        } catch (_) {
          return value.toString();
        }
      case 'number':
        if (value is num) return value.toString();
        return value.toString();
      case 'multiselect':
        if (value is List) return value.join(', ');
        return value.toString();
      default:
        return value.toString();
    }
  }

  /// ينفذ هذا الأسلوب عملية _buildFloatingHeader ضمن مسار إدارة الوحدات.
  /// This method performs the _buildFloatingHeader operation in the admin unit workflow.
  Widget _buildFloatingHeader(Unit unit) {
    final floatingSecondary = [
      if ((unit.nameEn ?? '').trim().isNotEmpty) unit.nameEn!,
      if ((unit.propertyNameEn ?? '').trim().isNotEmpty) unit.propertyNameEn!,
    ].join(' • ');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildActionButton(
                    icon: Icons.arrow_back,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.pop();
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          unit.propertyName,
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                        if (floatingSecondary.isNotEmpty)
                          Text(
                            floatingSecondary,
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.textMuted.withValues(alpha: 0.75),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // _buildPriceTag(unit.basePrice, unit.pricingMethod), // Commented out: basePrice removed
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> _splitFeatures(String? rawFeatures) {
    if (rawFeatures == null || rawFeatures.trim().isEmpty) {
      return const [];
    }

    return rawFeatures
        .split(',')
        .map((feature) => feature.trim())
        .where((feature) => feature.isNotEmpty)
        .toList();
  }

  Widget _buildFeaturesWrap(
    List<String> features, {
    required Color textColor,
    required Color accentColor,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: features.map((feature) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getFeatureIcon(feature),
                size: 16,
                color: accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                feature,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String? _normalizeSecondaryValue(
      String? secondaryValue, String primaryValue) {
    final normalized = secondaryValue?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    if (normalized == primaryValue.trim()) {
      return null;
    }

    return normalized;
  }

  /// ينفذ هذا الأسلوب عملية _buildFloatingActions ضمن مسار إدارة الوحدات.
  /// This method performs the _buildFloatingActions operation in the admin unit workflow.
  Widget _buildFloatingActions(Unit unit) {
    return Positioned(
      bottom: 32,
      right: 20,
      child: Column(
        children: [
          _buildFloatingButton(
            icon: CupertinoIcons.pencil,
            color: AppTheme.primaryBlue,
            onTap: () => _navigateToEdit(unit),
          ),
          const SizedBox(height: 12),
          _buildFloatingButton(
            icon: CupertinoIcons.trash,
            color: AppTheme.error,
            onTap: () => _showDeleteConfirmation(unit),
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildFloatingButton ضمن مسار إدارة الوحدات.
  /// This method performs the _buildFloatingButton operation in the admin unit workflow.
  Widget _buildFloatingButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildBackButton ضمن مسار إدارة الوحدات.
  /// This method performs the _buildBackButton operation in the admin unit workflow.
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.pop();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Icon(
          CupertinoIcons.chevron_back,
          color: AppTheme.textWhite,
          size: 20,
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildActionButton ضمن مسار إدارة الوحدات.
  /// This method performs the _buildActionButton operation in the admin unit workflow.
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: AppTheme.textWhite,
          size: 18,
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildLoadingState ضمن مسار إدارة الوحدات.
  /// This method performs the _buildLoadingState operation in the admin unit workflow.
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(
            color: AppTheme.primaryBlue,
            radius: 12,
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل البيانات...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildErrorState ضمن مسار إدارة الوحدات.
  /// This method performs the _buildErrorState operation in the admin unit workflow.
  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.error.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: AppTheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: AppTextStyles.heading3.copyWith(
                color: AppTheme.textWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _loadUnitDetails();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'إعادة المحاولة',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  /// ينفذ هذا الأسلوب عملية _getFeatureIcon ضمن مسار إدارة الوحدات.
  /// This method performs the _getFeatureIcon operation in the admin unit workflow.
  IconData _getFeatureIcon(String feature) {
    final featureLower = feature.toLowerCase();
    if (featureLower.contains('واي فاي') || featureLower.contains('wifi')) {
      return CupertinoIcons.wifi;
    } else if (featureLower.contains('تكييف') || featureLower.contains('ac')) {
      return CupertinoIcons.snow;
    } else if (featureLower.contains('مطبخ')) {
      return CupertinoIcons.flame;
    } else if (featureLower.contains('موقف')) {
      return CupertinoIcons.car;
    } else if (featureLower.contains('مسبح')) {
      return CupertinoIcons.drop;
    } else {
      return CupertinoIcons.checkmark_circle;
    }
  }

  /// ينفذ هذا الأسلوب عملية _handleStateChanges ضمن مسار إدارة الوحدات.
  /// This method performs the _handleStateChanges operation in the admin unit workflow.
  void _handleStateChanges(BuildContext context, UnitDetailsState state) {
    if (state is UnitDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حذف الوحدة بنجاح'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      context.pop();
    } else if (state is UnitDetailsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  /// ينفذ هذا الأسلوب عملية _navigateToEdit ضمن مسار إدارة الوحدات.
  /// This method performs the _navigateToEdit operation in the admin unit workflow.
  void _navigateToEdit(Unit unit) {
    context.push('/admin/units/${unit.id}/edit');
  }

  /// ينفذ هذا الأسلوب عملية _shareUnit ضمن مسار إدارة الوحدات.
  /// This method performs the _shareUnit operation in the admin unit workflow.
  void _shareUnit(Unit unit) {
    // Implement share functionality
  }

  /// ينفذ هذا الأسلوب عملية _showDeleteConfirmation ضمن مسار إدارة الوحدات.
  /// This method performs the _showDeleteConfirmation operation in the admin unit workflow.
  void _showDeleteConfirmation(Unit unit) {
    HapticFeedback.mediumImpact();
    showDialog(
      fullscreenDialog: true,
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.error.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.error.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.error.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppTheme.error,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'حذف الوحدة؟',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'لا يمكن التراجع عن هذا الإجراء',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<UnitDetailsBloc>().add(
                                DeleteUnitDetailsEvent(unitId: unit.id),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'حذف',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
