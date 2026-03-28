// lib/features/admin_amenities/presentation/pages/amenities_management_page.dart

import 'package:hggzkportal/features/admin_amenities/domain/entities/amenity.dart';
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
import '../bloc/amenities_bloc.dart';
import '../bloc/amenities_event.dart';
import '../bloc/amenities_state.dart';
import '../widgets/futuristic_amenity_card.dart';
import '../widgets/futuristic_amenities_table.dart';
import '../widgets/amenity_filters_widget.dart';
import '../widgets/assign_amenity_dialog.dart';
import 'package:hggzkportal/features/admin_units/presentation/widgets/unit_stats_card.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../injection_container.dart' as di;

/// Arabic: صفحة إدارة المرافق التي تعرض القائمة، الفلاتر، الإحصاءات، وإجراءات الحذف أو الإسناد.
/// English: Admin amenities page that presents the list, filters, statistics, and destructive or assignment actions.
class AmenitiesManagementPage extends StatefulWidget {
  /// Arabic: ينشئ صفحة إدارة المرافق بدون أي معاملات إضافية لأن الحالة تُدار داخليًا.
  /// English: Creates the amenities management page; all runtime state is handled internally.
  const AmenitiesManagementPage({super.key});

  /// Arabic: ينشئ الحالة التي تدير التحميل، التبويبات، والفلاتر داخل الصفحة.
  /// English: Creates the state object that manages loading, tabs, and filters inside the page.
  @override
  State<AmenitiesManagementPage> createState() =>
      _AmenitiesManagementPageState();
}

/// Arabic: تدير هذه الحالة جلب المرافق، تبديل طرق العرض، وتنفيذ التفاعلات الإدارية.
/// English: Manages amenity loading, view switching, and administrative interactions for the page.
class _AmenitiesManagementPageState extends State<AmenitiesManagementPage>
    with TickerProviderStateMixin {
  /// Arabic: يتحكم في حركة الدخول والانتقالات الافتتاحية داخل الصفحة.
  /// English: Controls the page entrance and initial transition animations.
  late AnimationController _animationController;

  /// Arabic: يتحكم في نبضات التوهج الخلفي المستخدمة للهوية البصرية.
  /// English: Controls the background glow pulse used for the visual theme.
  late AnimationController _pulseAnimationController;

  /// Arabic: يدير التبويبات الثلاثة التي تفصل طرق العرض داخل الصفحة.
  /// English: Manages the three tabs that separate page view modes.
  late TabController _tabController;

  /// Arabic: يتابع التمرير لتفعيل التحميل المسبق عند الاقتراب من نهاية القائمة.
  /// English: Tracks scrolling to trigger prefetch or pagination near the list end.
  final ScrollController _scrollController = ScrollController();

  /// Arabic: يحدد ما إذا كانت الصفحة تعرض شبكة بطاقات بدل الجدول.
  /// English: Indicates whether the page is currently showing a grid instead of a table.
  bool _isGridView = false;

  /// Arabic: يتحكم في إظهار قسم الفلاتر أو إخفائه.
  /// English: Controls whether the filter section is expanded or collapsed.
  bool _showFilters = false;

  /// Arabic: يحتفظ بالمرافق المحددة لتنفيذ عمليات جماعية أو سريعة لاحقًا.
  /// English: Stores selected amenities for later bulk or quick actions.
  final List<Amenity> _selectedAmenities = [];

  /// Arabic: يحدد ما إذا كان المستخدم الحالي يملك صلاحية الإدارة الكاملة.
  /// English: Indicates whether the current user has full admin privileges.
  bool _isAdmin = false;

  /// Arabic: يهيئ متحكمات الحركة، يقرأ صلاحيات الدور، ويبدأ أول تحميل للبيانات.
  /// English: Initializes animation controllers, reads role permissions, and starts the first data load.
  @override
  void initState() {
    super.initState();

    _loadRoleContext();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _tabController = TabController(length: 3, vsync: this);

    _loadAmenities();

    _setupScrollListener();
  }

  /// Arabic: يقرأ دور الحساب من التخزين المحلي لتفعيل عناصر الإدارة الحساسة فقط عند السماح.
  /// English: Reads the stored account role so admin-only controls appear only when allowed.
  void _loadRoleContext() {
    try {
      final storage = di.sl<LocalStorageService>();
      final role =
          storage.getData(StorageConstants.accountRole)?.toString() ?? '';
      _isAdmin = role.toLowerCase() == 'admin';
    } catch (_) {
      _isAdmin = false;
    }
  }

  /// Arabic: يطلب أول صفحة من المرافق عند فتح الشاشة أو تحديثها.
  /// English: Requests the first amenities page when the screen opens or refreshes.
  void _loadAmenities() {
    context.read<AmenitiesBloc>().add(
          const LoadAmenitiesEvent(
            pageNumber: 1,
            pageSize: 20,
          ),
        );
  }

  /// Arabic: يراقب التمرير الجانبي والطولي لتفعيل الجلب التالي عند الوصول إلى آخر القائمة.
  /// English: Watches scrolling to trigger the next page when the user reaches the end.
  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final state = context.read<AmenitiesBloc>().state;
        if (state is AmenitiesLoaded && state.amenities.hasNextPage) {
          final nextPage = state.amenities.nextPageNumber;
          if (nextPage != null) {
            context.read<AmenitiesBloc>().add(
                  ChangePageEvent(
                    pageNumber: nextPage,
                  ),
                );
          }
        }
      }
    });
  }

  /// Arabic: يحرر متحكمات الحركة والتمرير والتبويب عند إزالة الصفحة من الشجرة.
  /// English: Disposes animation, scroll, and tab controllers when the page leaves the tree.
  @override
  void dispose() {
    _animationController.dispose();
    _pulseAnimationController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Arabic: يبني صفحة الإدارة كاملة مع الإحصاءات، الفلاتر، والقائمة أو الجدول الحالي.
  /// English: Builds the full management page with stats, filters, and the active list or table view.
  @override
  Widget build(BuildContext context) {
    return BlocListener<AmenitiesBloc, AmenitiesState>(
      listener: (context, state) {
        if (state is AmenityOperationInProgress &&
            state.operation == 'delete') {
          _showDeletingDialog();
        } else if (state is AmenityOperationSuccess) {
          _dismissDeletingDialog();
          _showSnack('تم حذف المرفق بنجاح', AppTheme.success);
        } else if (state is AmenityOperationFailure) {
          _dismissDeletingDialog();
          final msg = state.message.contains('لا يمكن حذف')
              ? state.message
              : 'فشل الحذف: ${state.message}';
          _showSnack(msg, AppTheme.error);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<AmenitiesBloc>().add(const RefreshAmenitiesEvent());
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
              _buildAmenitiesList(),
            ],
          ),
        ),
      ),
    );
  }

  /// Arabic: يحدد حالة الحذف الحالية حتى لا تتكرر نافذة التقدم.
  /// English: Tracks whether a delete flow is already active to avoid duplicate progress dialogs.
  bool _isDeleting = false;

  /// Arabic: يعرض حوارًا غير قابل للإغلاق أثناء تنفيذ الحذف.
  /// English: Shows a non-dismissible progress dialog while delete is in progress.
  void _showDeletingDialog() {
    if (_isDeleting) return;
    _isDeleting = true;
    showDialog(
      fullscreenDialog: true,
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        elevation: 0,
        child: Center(
          child: LoadingWidget(
              type: LoadingType.futuristic, message: 'جاري حذف المرفق...'),
        ),
      ),
    );
  }

  /// Arabic: يغلق حوار الحذف ويعيد الحالة الداخلية إلى الوضع الطبيعي.
  /// English: Dismisses the delete dialog and resets the local guard flag.
  void _dismissDeletingDialog() {
    if (_isDeleting) {
      _isDeleting = false;
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  /// Arabic: يعرض رسالة عائمة قصيرة برسالة ولون مناسبين لنتيجة العملية.
  /// English: Shows a floating snackbar with a message and color tailored to the operation result.
  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Arabic: يبني شريط التطبيق المتموج الذي يضم العنوان وأزرار تبديل العرض والفلاتر.
  /// English: Builds the decorative sliver app bar that contains the title, view toggle, and filter actions.
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.darkBackground,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          'المرافق',
          style: AppTextStyles.heading1.copyWith(
            color: AppTheme.textWhite,
            shadows: [
              Shadow(
                color: AppTheme.primaryPurple.withValues(alpha: 0.3),
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
                AppTheme.primaryPurple.withValues(alpha: 0.1),
                AppTheme.darkBackground,
              ],
            ),
          ),
        ),
      ),
      actions: [
        _buildActionButton(
          icon: _isGridView
              ? CupertinoIcons.list_bullet
              : CupertinoIcons.square_grid_2x2,
          onPressed: () => setState(() => _isGridView = !_isGridView),
        ),
        if (_isAdmin) ...[
          _buildActionButton(
            icon: CupertinoIcons.add,
            onPressed: () {
              // Navigator.pop(context);
              context.push('/admin/amenities/create');
            },
          ),
          _buildAnalyticsButton(),
        ],
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

  /// Arabic: يبني زر التحليلات الذي يظهر فقط للمستخدم الإداري.
  /// English: Builds the analytics action button shown only for admin users.
  Widget _buildAnalyticsButton() {
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
                      HapticFeedback.lightImpact();
                      _navigateToAnalytics();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        CupertinoIcons.chart_bar_alt_fill,
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

  /// Arabic: ينتقل إلى شاشة التحليلات بعد إظهار نبضة مرئية قصيرة.
  /// English: Navigates to analytics after playing a brief visual feedback animation.
  void _navigateToAnalytics() {
    _showNavigationAnimation();
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pop(context);
      context.push('/admin/amenities/analytics');
    });
  }

  /// Arabic: يشغّل تأثيرًا بصريًا قصيرًا قبل الانتقال حتى يبدو التفاعل مقصودًا.
  /// English: Plays a short visual feedback animation so the transition feels deliberate.
  void _showNavigationAnimation() {
    showDialog(
      fullscreenDialog: true,
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: AppTheme.darkBackground.withValues(alpha: 0.3),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryPurple.withValues(alpha: 0.3),
                          AppTheme.primaryViolet.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const CupertinoActivityIndicator(
                      color: Colors.white,
                      radius: 16,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Arabic: يبني زرًا دائريًا متدرجًا يستخدم في الشريط العلوي.
  /// English: Builds a circular gradient action button used in the top bar.
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

  /// Arabic: يبني قسم الإحصاءات فوق قائمة المرافق لعرض مؤشرات الحالة السريعة.
  /// English: Builds the statistics section above the amenities list for quick status indicators.
  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: BlocBuilder<AmenitiesBloc, AmenitiesState>(
        builder: (context, state) {
          if (state is! AmenitiesLoaded || state.stats == null) {
            return const SizedBox.shrink();
          }

          return AnimationLimiter(
            child: Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStatsCards(state.stats!),
            ),
          );
        },
      ),
    );
  }

  /// Arabic: يبني البطاقات الإحصائية الفردية التي تُظهر الأرقام الرئيسية.
  /// English: Builds the individual statistics cards that surface the main counts.
  Widget _buildStatsCards(AmenityStats stats) {
    return AnimationLimiter(
      child: Row(
        children: [
          Expanded(
            child: AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: UnitStatsCard(
                    title: 'إجمالي المرافق',
                    value: stats.totalAmenities.toString(),
                    icon: Icons.category_rounded,
                    color: AppTheme.primaryBlue,
                    trend: '+0%',
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
                    title: 'المرافق النشطة',
                    value: stats.activeAmenities.toString(),
                    icon: Icons.check_circle_rounded,
                    color: AppTheme.success,
                    trend: '${stats.activeAmenities}',
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
                    title: 'إجمالي الإسنادات',
                    value: stats.totalAssignments.toString(),
                    icon: Icons.link_rounded,
                    color: AppTheme.warning,
                    trend: '${stats.totalAssignments}',
                    isPositive: true,
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
                    title: 'الإيرادات',
                    value: '\$${stats.totalRevenue.toStringAsFixed(0)}',
                    icon: Icons.attach_money_rounded,
                    color: AppTheme.primaryPurple,
                    trend: '+0%',
                    isPositive: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Arabic: يبني قسم الفلاتر القابل للطي لتحسين البحث والتصفية.
  /// English: Builds the collapsible filter section that helps refine the list.
  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _showFilters ? null : 0,
        child: _showFilters
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AmenityFiltersWidget(
                  onFilterChanged:
                      (searchTerm, isAssigned, isFree, propertyTypeId) {
                    context.read<AmenitiesBloc>().add(
                          ApplyFiltersEvent(
                            searchTerm: searchTerm,
                            isAssigned: isAssigned,
                            isFree: isFree,
                            propertyTypeId: propertyTypeId,
                          ),
                        );
                  },
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  /// Arabic: يقرر أي نمط عرض يجب استخدامه بحسب حالة تحميل البيانات وخيارات المستخدم.
  /// English: Chooses which list presentation mode to use based on data state and user preference.
  Widget _buildAmenitiesList() {
    return BlocBuilder<AmenitiesBloc, AmenitiesState>(
      builder: (context, state) {
        if (state is AmenitiesLoading) {
          return const SliverFillRemaining(
            child: LoadingWidget(
              type: LoadingType.futuristic,
              message: 'جاري تحميل المرافق...',
            ),
          );
        }

        if (state is AmenitiesError) {
          return SliverFillRemaining(
            child: CustomErrorWidget(
              message: state.message,
              onRetry: _loadAmenities,
            ),
          );
        }

        if (state is AmenitiesLoaded) {
          if (state.amenities.items.isEmpty) {
            return SliverFillRemaining(
              child: EmptyWidget(
                message: 'لا توجد مرافق حالياً',
                actionWidget: ElevatedButton.icon(
                  onPressed: _isAdmin
                      ? () => context.push('/admin/amenities/create')
                      : null,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة مرفق جديد'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
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

  /// Arabic: يبني عرض الشبكة عندما يفضّل المستخدم البطاقات بدل الجدول.
  /// English: Builds the grid layout when the user prefers cards instead of a table.
  Widget _buildGridView(AmenitiesLoaded state) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final amenity = state.amenities.items[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: 2,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: FuturisticAmenityCard(
                    amenity: amenity,
                    onTap: () => _navigateToDetails(amenity.id),
                    onLongPress: () => _toggleSelection(amenity),
                    onEdit: _isAdmin
                        ? () => _navigateToEditAmenity(amenity.id)
                        : null,
                    onDelete: _isAdmin
                        ? () => _showDeleteConfirmation(amenity)
                        : null,
                  ),
                ),
              ),
            );
          },
          childCount: state.amenities.items.length,
        ),
      ),
    );
  }

  /// Arabic: يبني عرض الجدول عندما تكون قراءة الكثافة الأعلى أفضل.
  /// English: Builds the table layout when a denser presentation is more useful.
  Widget _buildTableView(AmenitiesLoaded state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FuturisticAmenitiesTable(
          amenities: state.amenities.items,
          onAmenitySelected: (amenity) => _navigateToDetails(amenity.id),
          onEditAmenity:
              _isAdmin ? (amenity) => _navigateToEditAmenity(amenity.id) : null,
          onDeleteAmenity:
              _isAdmin ? (amenity) => _showDeleteConfirmation(amenity) : null,
          onAssignAmenity: (amenity) => _showAssignAmenityDialog(amenity),
        ),
      ),
    );
  }

  /// Arabic: ينتقل إلى شاشة تفاصيل المرفق المحدد.
  /// English: Navigates to the selected amenity details screen.
  void _navigateToDetails(String amenityId) {
    context.push('/admin/amenities/$amenityId');
  }

  /// Arabic: ينتقل إلى شاشة تعديل المرفق مع السماح بإعادة التحميل عند الرجوع.
  /// English: Navigates to the edit screen and allows the list to refresh when returning.
  Future<void> _navigateToEditAmenity(String amenityId) async {
    final result = await context.push('/admin/amenities/$amenityId/edit');
    if (result is Map && result['refresh'] == true) {
      _loadAmenities();
    }
  }

  /// Arabic: يبدّل حالة تحديد المرفق داخل القائمة الداخلية للاختيارات الجماعية.
  /// English: Toggles an amenity in the local selection list used for bulk actions.
  void _toggleSelection(Amenity amenity) {
    setState(() {
      if (_selectedAmenities.contains(amenity)) {
        _selectedAmenities.remove(amenity);
      } else {
        _selectedAmenities.add(amenity);
      }
    });
  }

  /// Arabic: يعرض تأكيدًا قبل تنفيذ حذف المرفق حتى لا يتم الحذف بالخطأ.
  /// English: Shows a confirmation dialog before deleting an amenity to prevent accidental removal.
  void _showDeleteConfirmation(Amenity amenity) {
    showDialog(
      fullscreenDialog: true,
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogCtx) => BackdropFilter(
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
                  'حذف المرفق؟',
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
                        onPressed: () => Navigator.pop(dialogCtx),
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
                          Navigator.pop(dialogCtx);
                          _showDeletingDialog();
                          context.read<AmenitiesBloc>().add(
                                DeleteAmenityEvent(amenityId: amenity.id),
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

  /// Arabic: يعرض حوار إسناد المرفق إلى نوع وحدة أو عقار محدد.
  /// English: Shows the dialog used to assign the amenity to a specific unit or property type.
  void _showAssignAmenityDialog(Amenity amenity) {
    AssignAmenityDialog.show(
      context: context,
      amenity: amenity,
      onAssign: ({
        required String amenityId,
        required String propertyId,
        required bool isAvailable,
        double? extraCost,
        String? description,
      }) async {
        context.read<AmenitiesBloc>().add(
              AssignAmenityToPropertyEvent(
                amenityId: amenityId,
                propertyId: propertyId,
                isAvailable: isAvailable,
                extraCost: extraCost,
                description: description,
              ),
            );
      },
      onSuccess: () {
        context.read<AmenitiesBloc>().add(const RefreshAmenitiesEvent());
      },
      onError: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }
}

// Delete Confirmation Dialog
