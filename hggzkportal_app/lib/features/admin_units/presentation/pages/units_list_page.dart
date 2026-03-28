// lib/features/admin_units/presentation/pages/units_list_page.dart

import 'package:hggzkportal/features/admin_units/domain/entities/unit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../bloc/units_list/units_list_bloc.dart';
import '../widgets/futuristic_unit_card.dart';
import '../widgets/futuristic_units_table.dart';
import '../widgets/unit_stats_card.dart';
import 'package:hggzkportal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hggzkportal/features/auth/presentation/bloc/auth_state.dart';
import 'package:hggzkportal/features/auth/domain/entities/user.dart' as domain;
import 'package:hggzkportal/features/admin_properties/domain/entities/property.dart';
import 'package:hggzkportal/features/admin_daily_schedule/presentation/widgets/real_property_selector_card.dart';

// Unit Filters Model
/// يمثل هذا الكلاس UnitFilters البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitFilters in the admin unit workflow.
class UnitFilters {
  /// This field keeps the propertyId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة propertyId التي يعتمد عليها مسار إدارة الوحدات.
  final String? propertyId;

  /// يحتفظ هذا الحقل بقيمة unitTypeId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the unitTypeId value used by the admin unit workflow.
  final String? unitTypeId;
  // final bool? isAvailable; // Commented out: isAvailable removed
  /// يحتفظ هذا الحقل بقيمة minPrice التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the minPrice value used by the admin unit workflow.
  final int? minPrice;

  /// يحتفظ هذا الحقل بقيمة maxPrice التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the maxPrice value used by the admin unit workflow.
  final int? maxPrice;

  /// يحتفظ هذا الحقل بقيمة pricingMethod التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the pricingMethod value used by the admin unit workflow.
  final String? pricingMethod;

  /// ينشئ هذا المُنشئ مثيلاً من UnitFilters.
  /// This constructor creates an instance of UnitFilters.
  const UnitFilters({
    this.propertyId,
    this.unitTypeId,
    // this.isAvailable, // Commented out: isAvailable removed
    this.minPrice,
    this.maxPrice,
    this.pricingMethod,
  });

  /// ينفذ هذا الأسلوب عملية toMap ضمن مسار إدارة الوحدات.
  /// This method performs the toMap operation in the admin unit workflow.
  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'unitTypeId': unitTypeId,
      // 'isAvailable': isAvailable, // Commented out: isAvailable removed
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'pricingMethod': pricingMethod,
    };
  }
}

/// يمثل هذا الكلاس UnitsListPage البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitsListPage in the admin unit workflow.
class UnitsListPage extends StatefulWidget {
  /// This constructor creates a new UnitsListPage instance.
  /// ينشئ مثيلًا جديدًا من UnitsListPage.
  const UnitsListPage({super.key});

  /// ينشئ هذا الأسلوب كائن الحالة الخاص بهذه الصفحة.
  /// This method performs the createState operation in the admin unit workflow.
  @override
  State<UnitsListPage> createState() => _UnitsListPageState();
}

/// يمثل هذا الكلاس _UnitsListPageState البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _UnitsListPageState in the admin unit workflow.
class _UnitsListPageState extends State<UnitsListPage>
    with TickerProviderStateMixin {
  /// يحتفظ هذا الحقل بقيمة _animationController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _animationController value used by the admin unit workflow.
  late AnimationController _animationController;

  /// يحتفظ هذا الحقل بقيمة _pulseAnimationController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _pulseAnimationController value used by the admin unit workflow.
  late AnimationController _pulseAnimationController;

  /// يحتفظ هذا الحقل بقيمة _tabController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _tabController value used by the admin unit workflow.
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  /// يحتفظ هذا الحقل بقيمة _isGridView التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _isGridView value used by the admin unit workflow.
  bool _isGridView = false;

  /// يحتفظ هذا الحقل بقيمة _showFilters التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _showFilters value used by the admin unit workflow.
  bool _showFilters = false;

  /// يحتفظ هذا الحقل بقيمة _isDeleting التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _isDeleting value used by the admin unit workflow.
  bool _isDeleting = false;

  /// يحتفظ هذا الحقل بقيمة _selectedPropertyId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _selectedPropertyId value used by the admin unit workflow.
  String? _selectedPropertyId;

  /// يحتفظ هذا الحقل بقيمة _selectedPropertyName التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _selectedPropertyName value used by the admin unit workflow.
  String? _selectedPropertyName;

  /// ينفذ هذا الأسلوب عملية _showDeletingDialog ضمن مسار إدارة الوحدات.
  /// This method performs the _showDeletingDialog operation in the admin unit workflow.
  void _showDeletingDialog() {
    if (_isDeleting) return;
    _isDeleting = true;

    /// ينفذ هذا الأسلوب عملية showDialog ضمن مسار إدارة الوحدات.
    /// This method performs the showDialog operation in the admin unit workflow.
    showDialog(
      fullscreenDialog: true,
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        elevation: 0,
        child: Center(
          child: LoadingWidget(
            type: LoadingType.futuristic,
            message: 'جاري حذف الوحدة...',
          ),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _dismissDeletingDialog ضمن مسار إدارة الوحدات.
  /// This method performs the _dismissDeletingDialog operation in the admin unit workflow.
  void _dismissDeletingDialog() {
    if (_isDeleting) {
      _isDeleting = false;
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  /// ينفذ هذا الأسلوب عملية initState ضمن مسار إدارة الوحدات.
  /// This method performs the initState operation in the admin unit workflow.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _tabController = TabController(length: 3, vsync: this);
    _loadUnits();
    _setupScrollListener();
  }

  /// ينفذ هذا الأسلوب عملية _loadUnits ضمن مسار إدارة الوحدات.
  /// This method performs the _loadUnits operation in the admin unit workflow.
  void _loadUnits() {
    final authState = context.read<AuthBloc>().state;
    domain.User? user;
    if (authState is AuthAuthenticated) user = authState.user;
    if (authState is AuthLoginSuccess) user = authState.user;
    if (authState is AuthProfileUpdateSuccess) user = authState.user;

    if (user != null &&
        user.isOwner &&
        (user.propertyId != null && user.propertyId!.isNotEmpty)) {
      // Default to owner's property
      context.read<UnitsListBloc>().add(
            FilterUnitsEvent(
              filters: {
                'propertyId': user.propertyId,
                'pageNumber': 1,
                'pageSize': 20,
              },
            ),
          );
    } else {
      context.read<UnitsListBloc>().add(
            const LoadUnitsEvent(
              pageNumber: 1,
              pageSize: 20,
            ),
          );
    }
  }

  /// ينفذ هذا الأسلوب عملية _setupScrollListener ضمن مسار إدارة الوحدات.
  /// This method performs the _setupScrollListener operation in the admin unit workflow.
  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final state = context.read<UnitsListBloc>().state;
        if (state is UnitsListLoaded && state.hasMore) {
          context.read<UnitsListBloc>().add(
                LoadMoreUnitsEvent(
                  pageNumber: state.currentPage + 1,
                ),
              );
        }
      }
    });
  }

  /// ينفذ هذا الأسلوب عملية dispose ضمن مسار إدارة الوحدات.
  /// This method performs the dispose operation in the admin unit workflow.
  @override
  void dispose() {
    _animationController.dispose();
    _pulseAnimationController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    return BlocListener<UnitsListBloc, UnitsListState>(
      listener: (context, state) {
        if (state is UnitsListError && _isDeleting) {
          _dismissDeletingDialog();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل الحذف: ${state.message}'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is UnitsListLoaded && _isDeleting) {
          _dismissDeletingDialog();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم حذف الوحدة بنجاح'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Stack(
          children: [
            // المحتوى الأساسي
            RefreshIndicator(
              onRefresh: () async {
                context.read<UnitsListBloc>().add(RefreshUnitsEvent());
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  _buildSliverAppBar(),
                  _buildStatsSection(),
                  _buildFilterSection(),
                  _buildUnitsList(),
                ],
              ),
            ),

            // LoadingWidget العائم - يظهر فوق كل شيء عند الفلترة
            BlocBuilder<UnitsListBloc, UnitsListState>(
              builder: (context, state) {
                if (state is UnitsListLoading && _showFilters) {
                  return Positioned.fill(
                    child: Container(
                      color: AppTheme.darkBackground.withValues(alpha: 0.8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: const Center(
                          child: LoadingWidget(
                            type: LoadingType.futuristic,
                            message: 'جاري تطبيق الفلاتر...',
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        floatingActionButton: _buildEnhancedFloatingActionButton(),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildSliverAppBar ضمن مسار إدارة الوحدات.
  /// This method performs the _buildSliverAppBar operation in the admin unit workflow.
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.darkBackground,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          'الوحدات',
          style: AppTextStyles.heading1.copyWith(
            color: AppTheme.textWhite,
            shadows: [
              Shadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryBlue.withValues(alpha: 0.1),
                AppTheme.darkBackground,
              ],
            ),
          ),
        ),
      ),
      actions: [
        _buildActionButton(
          icon: CupertinoIcons.add,
          onPressed: () async {
            await context.push('/admin/units/create');
            if (!mounted) return;
            context.read<UnitsListBloc>().add(RefreshUnitsEvent());
          },
        ),
        _buildGridViewButton(),
        _buildActionButton(
          icon: _showFilters
              ? CupertinoIcons.xmark
              : CupertinoIcons.slider_horizontal_3,
          onPressed: () => setState(() => _showFilters = !_showFilters),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildGridViewButton ضمن مسار إدارة الوحدات.
  /// This method performs the _buildGridViewButton operation in the admin unit workflow.
  Widget _buildGridViewButton() {
    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPurple.withValues(alpha: 0.2),
                      AppTheme.primaryViolet.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(
                      alpha: 0.3 + (_pulseAnimationController.value * 0.2),
                    ),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withValues(
                        alpha: 0.1 * _pulseAnimationController.value,
                      ),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() => _isGridView = !_isGridView);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _isGridView
                            ? CupertinoIcons.list_bullet
                            : CupertinoIcons.square_grid_2x2,
                        color: AppTheme.primaryPurple,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.neonPurple,
                        AppTheme.primaryViolet,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonPurple.withValues(
                          alpha: 0.6 * _pulseAnimationController.value,
                        ),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildActionButton ضمن مسار إدارة الوحدات.
  /// This method performs the _buildActionButton operation in the admin unit workflow.
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: AppTheme.textWhite,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildEnhancedFloatingActionButton ضمن مسار إدارة الوحدات.
  /// This method performs the _buildEnhancedFloatingActionButton operation in the admin unit workflow.
  Widget _buildEnhancedFloatingActionButton() {
    return BlocBuilder<UnitsListBloc, UnitsListState>(
      builder: (context, state) {
        if (state is UnitsListLoaded && state.selectedUnits.isNotEmpty) {
          return _buildBulkActionsFloatingButton(state);
        }
        return _buildQuickAccessFloatingButton();
      },
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildQuickAccessFloatingButton ضمن مسار إدارة الوحدات.
  /// This method performs the _buildQuickAccessFloatingButton operation in the admin unit workflow.
  Widget _buildQuickAccessFloatingButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _showQuickAccessMenu,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          CupertinoIcons.square_grid_2x2_fill,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _showQuickAccessMenu ضمن مسار إدارة الوحدات.
  /// This method performs the _showQuickAccessMenu operation in the admin unit workflow.
  void _showQuickAccessMenu() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: AppTheme.darkBorder.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.darkBorder.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'إجراءات سريعة',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
                const SizedBox(height: 20),
                _buildQuickMenuItem(
                  icon: CupertinoIcons.chart_bar_alt_fill,
                  label: 'التحليلات',
                  subtitle: 'عرض إحصائيات وتقارير الوحدات',
                  gradient: [AppTheme.primaryPurple, AppTheme.primaryViolet],
                  onTap: () {
                    // Navigator.pop(context);
                    // context.push('/admin/units/analytics');
                  },
                ),
                // _buildQuickMenuItem(
                //   icon: CupertinoIcons.map,
                //   label: 'الخريطة',
                //   subtitle: 'عرض الوحدات على الخريطة التفاعلية',
                //   gradient: [AppTheme.primaryBlue, AppTheme.primaryCyan],
                //   onTap: () {
                //     Navigator.pop(context);
                //     context.push('/admin/units/map');
                //   },
                // ),
                _buildQuickMenuItem(
                  icon: CupertinoIcons.chart_pie_fill,
                  label: 'التقارير',
                  subtitle: 'تقارير مفصلة عن أداء الوحدات',
                  gradient: [AppTheme.success, AppTheme.neonGreen],
                  onTap: () {
                    // Navigator.pop(context);
                    // context.push('/admin/units/reports');
                  },
                ),
                _buildQuickMenuItem(
                  icon: CupertinoIcons.plus_circle_fill,
                  label: 'وحدة جديدة',
                  subtitle: 'إضافة وحدة جديدة للنظام',
                  gradient: [AppTheme.warning, AppTheme.neonPurple],
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/admin/units/create');
                  },
                ),
                // _buildQuickMenuItem(
                //   icon: CupertinoIcons.arrow_up_arrow_down,
                //   label: 'استيراد/تصدير',
                //   subtitle: 'استيراد أو تصدير بيانات الوحدات',
                //   gradient: [AppTheme.primaryViolet, AppTheme.primaryPurple],
                //   onTap: () {
                //     Navigator.pop(context);
                //     context.push('/admin/units/import-export');
                //   },
                // ),
                const SizedBox(height: 20),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildQuickMenuItem ضمن مسار إدارة الوحدات.
  /// This method performs the _buildQuickMenuItem operation in the admin unit workflow.
  Widget _buildQuickMenuItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient.map((c) => c.withValues(alpha: 0.05)).toList(),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient.first.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_forward,
                  color: AppTheme.textMuted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildBulkActionsFloatingButton ضمن مسار إدارة الوحدات.
  /// This method performs the _buildBulkActionsFloatingButton operation in the admin unit workflow.
  Widget _buildBulkActionsFloatingButton(UnitsListLoaded state) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _showBulkActions,
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: Text(
          '${state.selectedUnits.length} محدد',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: const Icon(
          CupertinoIcons.checkmark_circle_fill,
          color: Colors.white,
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildStatsSection ضمن مسار إدارة الوحدات.
  /// This method performs the _buildStatsSection operation in the admin unit workflow.
  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: BlocBuilder<UnitsListBloc, UnitsListState>(
        builder: (context, state) {
          if (state is! UnitsListLoaded) return const SizedBox.shrink();
          return AnimationLimiter(
            child: Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStatsCards(state),
            ),
          );
        },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildStatsCards ضمن مسار إدارة الوحدات.
  /// This method performs the _buildStatsCards operation in the admin unit workflow.
  Widget _buildStatsCards(UnitsListLoaded state) {
    // Prefer backend-provided stats when available
    final totalUnits = state.stats != null && state.stats!['totalUnits'] != null
        ? int.tryParse('${state.stats!['totalUnits']}') ?? state.totalCount
        : state.totalCount;
    // Commented out: isAvailable removed
    /*
    final availableUnits = state.stats != null && state.stats!['availableUnits'] != null
        ? int.tryParse('${state.stats!['availableUnits']}') ?? 0
        : state.units.where((u) => u.isAvailable).length;
    final occupiedUnits = state.stats != null && state.stats!['occupiedUnits'] != null
        ? int.tryParse('${state.stats!['occupiedUnits']}') ?? (totalUnits - availableUnits)
        : (totalUnits - availableUnits);
    final occupancyRate = totalUnits > 0
        ? ((occupiedUnits / totalUnits) * 100).toStringAsFixed(0)
        : '0';
    */
    final availableUnits =
        state.stats != null && state.stats!['availableUnits'] != null
            ? int.tryParse('${state.stats!['availableUnits']}') ?? 0
            : 0;
    final occupiedUnits =
        state.stats != null && state.stats!['occupiedUnits'] != null
            ? int.tryParse('${state.stats!['occupiedUnits']}') ?? 0
            : 0;
    final occupancyRate = totalUnits > 0 && (availableUnits + occupiedUnits) > 0
        ? ((occupiedUnits / totalUnits) * 100).toStringAsFixed(0)
        : '0';

    return Row(
      children: [
        Expanded(
          child: AnimationConfiguration.staggeredList(
            position: 0,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: UnitStatsCard(
                  title: 'إجمالي الوحدات',
                  value: totalUnits.toString(),
                  icon: Icons.home_work_rounded,
                  color: AppTheme.primaryBlue,
                  trend: '+15%',
                  isPositive: true,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnimationConfiguration.staggeredList(
            position: 1,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: UnitStatsCard(
                  title: 'وحدات متاحة',
                  value: availableUnits.toString(),
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.success,
                  trend: '$availableUnits',
                  isPositive: true,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnimationConfiguration.staggeredList(
            position: 2,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: UnitStatsCard(
                  title: 'وحدات محجوزة',
                  value: occupiedUnits.toString(),
                  icon: Icons.event_busy_rounded,
                  color: AppTheme.warning,
                  trend: '$occupiedUnits',
                  isPositive: false,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnimationConfiguration.staggeredList(
            position: 3,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: UnitStatsCard(
                  title: 'معدل الإشغال',
                  value: '$occupancyRate%',
                  icon: Icons.analytics_rounded,
                  color: AppTheme.primaryPurple,
                  trend: '+5%',
                  isPositive: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildFilterSection ضمن مسار إدارة الوحدات.
  /// This method performs the _buildFilterSection operation in the admin unit workflow.
  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        constraints: BoxConstraints(
          minHeight: _showFilters ? 80 : 0,
          maxHeight:
              _showFilters ? MediaQuery.of(context).size.height * 0.5 : 0,
        ),
        child: _showFilters
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.darkCard.withValues(alpha: 0.3),
                      AppTheme.darkCard.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: RealPropertySelectorCard(
                          selectedPropertyId: _selectedPropertyId,
                          selectedPropertyName: _selectedPropertyName,
                          isCompact: true,
                          onPropertySelected: (Property property) {
                            // Ensure owner scope is enforced client-side as well
                            final authState = context.read<AuthBloc>().state;
                            domain.User? user;
                            if (authState is AuthAuthenticated)
                              user = authState.user;
                            if (authState is AuthLoginSuccess)
                              user = authState.user;
                            if (authState is AuthProfileUpdateSuccess)
                              user = authState.user;

                            final enforcedPropertyId = (user != null &&
                                    user.isOwner &&
                                    (user.propertyId != null &&
                                        user.propertyId!.isNotEmpty))
                                ? user.propertyId!
                                : property.id;

                            setState(() {
                              _selectedPropertyId = enforcedPropertyId;
                              _selectedPropertyName = property.name;
                            });

                            context.read<UnitsListBloc>().add(
                                  FilterUnitsEvent(
                                    filters: {
                                      'propertyId': enforcedPropertyId,
                                    },
                                  ),
                                );
                          },
                        ),
                      ),
                    ),

                    // شريط تحميل صغير في أعلى الفلاتر
                    BlocBuilder<UnitsListBloc, UnitsListState>(
                      builder: (context, state) {
                        if (state is UnitsListLoading) {
                          return Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildUnitsList ضمن مسار إدارة الوحدات.
  /// This method performs the _buildUnitsList operation in the admin unit workflow.
  Widget _buildUnitsList() {
    return BlocBuilder<UnitsListBloc, UnitsListState>(
      builder: (context, state) {
        // إذا كان هناك تحميل والفلاتر مفتوحة، لا نظهر LoadingWidget هنا
        // لأنه سيظهر في الـ Stack فوق كل شيء
        if (state is UnitsListLoading && _showFilters) {
          // نعرض container فارغ بدلاً من LoadingWidget
          return SliverToBoxAdapter(
            child: Container(
              height: 200,
              // يمكن أن يكون فارغاً أو نضع placeholder
            ),
          );
        }

        // التحميل العادي (بدون فلاتر)
        if (state is UnitsListLoading && !_showFilters) {
          return const SliverFillRemaining(
            child: LoadingWidget(
              type: LoadingType.futuristic,
              message: 'جاري تحميل الوحدات...',
            ),
          );
        }

        if (state is UnitsListError) {
          return SliverFillRemaining(
            child: CustomErrorWidget(
              message: state.message,
              onRetry: _loadUnits,
            ),
          );
        }

        if (state is UnitsListLoaded) {
          if (state.units.isEmpty) {
            return SliverFillRemaining(
              child: EmptyWidget(
                message: 'لا توجد وحدات حالياً',
                actionWidget: ElevatedButton.icon(
                  onPressed: () => context.push('/admin/units/create'),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة وحدة جديدة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            );
          }

          return _isGridView ? _buildGridView(state) : _buildTableView(state);
        }

        return const SliverFillRemaining(child: SizedBox.shrink());
      },
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildGridView ضمن مسار إدارة الوحدات.
  /// This method performs the _buildGridView operation in the admin unit workflow.
  Widget _buildGridView(UnitsListLoaded state) {
    final width = MediaQuery.of(context).size.width;
    // Responsive columns and aspect ratio
    int crossAxisCount;
    double childAspectRatio;
    if (width < 700) {
      crossAxisCount = 1;
      childAspectRatio = 0.9; // provide more height to avoid overflow
    } else if (width < 1100) {
      crossAxisCount = 2;
      childAspectRatio = 0.9;
    } else {
      crossAxisCount = 3;
      childAspectRatio = 0.95;
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final unit = state.units[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: 2,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: FuturisticUnitCard(
                    unit: unit,
                    isSelected: state.selectedUnits.contains(unit),
                    onTap: () => _navigateToDetails(unit.id),
                    onEdit: () => _navigateToEditUnit(unit.id),
                    onDelete: () => _showDeleteConfirmation(unit),
                    index: index,
                  ),
                ),
              ),
            );
          },
          childCount: state.units.length,
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildTableView ضمن مسار إدارة الوحدات.
  /// This method performs the _buildTableView operation in the admin unit workflow.
  Widget _buildTableView(UnitsListLoaded state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FuturisticUnitsTable(
          units: state.units,
          onUnitSelected: (unit) => _navigateToDetails(unit.id),
          onEditUnit: (unit) => _navigateToEditUnit(unit.id),
          onDeleteUnit: (unit) => _showDeleteConfirmation(unit),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _navigateToDetails ضمن مسار إدارة الوحدات.
  /// This method performs the _navigateToDetails operation in the admin unit workflow.
  void _navigateToDetails(String unitId) {
    context.push('/admin/units/$unitId');
  }

  /// ينفذ هذا الأسلوب عملية _navigateToEditUnit ضمن مسار إدارة الوحدات.
  /// This method performs the _navigateToEditUnit operation in the admin unit workflow.
  void _navigateToEditUnit(String unitId) {
    context.push('/admin/units/$unitId/edit');
  }

  /// ينفذ هذا الأسلوب عملية _showBulkActions ضمن مسار إدارة الوحدات.
  /// This method performs the _showBulkActions operation in the admin unit workflow.
  void _showBulkActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.darkBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildBulkActionButton(
              icon: CupertinoIcons.checkmark_circle,
              label: 'تفعيل الكل',
              onTap: () {
                final state = context.read<UnitsListBloc>().state;
                if (state is UnitsListLoaded) {
                  context.read<UnitsListBloc>().add(
                        BulkActivateUnitsEvent(
                          unitIds:
                              state.selectedUnits.map((u) => u.id).toList(),
                        ),
                      );
                }
                Navigator.pop(sheetContext);
              },
            ),
            _buildBulkActionButton(
              icon: CupertinoIcons.xmark_circle,
              label: 'تعطيل الكل',
              onTap: () {
                final state = context.read<UnitsListBloc>().state;
                if (state is UnitsListLoaded) {
                  context.read<UnitsListBloc>().add(
                        BulkDeactivateUnitsEvent(
                          unitIds:
                              state.selectedUnits.map((u) => u.id).toList(),
                        ),
                      );
                }
                Navigator.pop(sheetContext);
              },
            ),
            _buildBulkActionButton(
              icon: CupertinoIcons.trash,
              label: 'حذف الكل',
              color: AppTheme.error,
              onTap: () {
                Navigator.pop(sheetContext);
                _showBulkDeleteConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildBulkActionButton ضمن مسار إدارة الوحدات.
  /// This method performs the _buildBulkActionButton operation in the admin unit workflow.
  Widget _buildBulkActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (color ?? AppTheme.primaryBlue).withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: color ?? AppTheme.primaryBlue),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _showDeleteConfirmation ضمن مسار إدارة الوحدات.
  /// This method performs the _showDeleteConfirmation operation in the admin unit workflow.
  void _showDeleteConfirmation(Unit unit) {
    HapticFeedback.mediumImpact();
    showDialog(
      fullscreenDialog: true,
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => BackdropFilter(
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
                        onPressed: () => Navigator.pop(dialogContext),
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
                          Navigator.pop(dialogContext);
                          _showDeletingDialog();
                          context
                              .read<UnitsListBloc>()
                              .add(DeleteUnitEvent(unitId: unit.id));
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

  /// ينفذ هذا الأسلوب عملية _showBulkDeleteConfirmation ضمن مسار إدارة الوحدات.
  /// This method performs the _showBulkDeleteConfirmation operation in the admin unit workflow.
  void _showBulkDeleteConfirmation() {
    showDialog(
      fullscreenDialog: true,
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppTheme.error.withValues(alpha: 0.3),
          ),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: AppTheme.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'تأكيد الحذف',
              style: AppTextStyles.heading3.copyWith(
                color: AppTheme.textWhite,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف جميع الوحدات المحددة؟\nلا يمكن التراجع عن هذا الإجراء.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'إلغاء',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.error,
                  AppTheme.error.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final state = context.read<UnitsListBloc>().state;
                  if (state is UnitsListLoaded) {
                    context.read<UnitsListBloc>().add(
                          BulkDeleteUnitsEvent(
                            unitIds:
                                state.selectedUnits.map((u) => u.id).toList(),
                          ),
                        );
                  }
                  Navigator.pop(dialogContext);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    'حذف',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Delete Confirmation Dialog
