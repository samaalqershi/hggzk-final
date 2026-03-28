// lib/features/admin_bookings/presentation/pages/bookings_list_page.dart

import 'package:hggzkportal/features/admin_bookings/domain/entities/booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:ui'; // 🎯 إضافة للـ blur effect
import 'package:flutter/services.dart'; // 🎯 إضافة للـ haptic feedback
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../bloc/bookings_list/bookings_list_bloc.dart';
import '../bloc/bookings_list/bookings_list_event.dart';
import '../bloc/bookings_list/bookings_list_state.dart';
import '../widgets/futuristic_booking_card.dart';
import '../widgets/futuristic_bookings_table.dart';
import '../widgets/booking_filters_widget.dart';
import '../widgets/booking_stats_cards.dart';
import '../widgets/booking_actions_dialog.dart';
import '../widgets/booking_confirmation_dialog.dart';

/// Arabic: الصفحة الرئيسية التي تعرض قائمة الحجوزات مع الفلاتر وعروض العرض المختلفة.
/// English: Main bookings page that exposes filters, list, grid, and table views.
class BookingsListPage extends StatefulWidget {
  /// Arabic: تاريخ البداية الافتراضي لنطاق التحميل الأولي أو الرابط العميق.
  /// English: Default start date for the initial load range or deep-link entry.
  final DateTime? initialStartDate;

  /// Arabic: تاريخ النهاية الافتراضي لنطاق التحميل الأولي.
  /// English: Default end date for the initial load range.
  final DateTime? initialEndDate;

  /// Arabic: ينشئ صفحة الحجوزات مع نطاق اختياري للتحميل الأول.
  /// English: Creates the bookings page with an optional initial load range.
  const BookingsListPage(
      {super.key, this.initialStartDate, this.initialEndDate});
  @override
  State<BookingsListPage> createState() => _BookingsListPageState();
}

/// Arabic: يدير حالة صفحة الحجوزات بما في ذلك التحميل، التمرير، والاختيار الجماعي.
/// English: Manages the bookings page state, including loading, scrolling, and bulk selection.
class _BookingsListPageState extends State<BookingsListPage>
    with TickerProviderStateMixin {
  /// Arabic: يتحكم في الحركة الافتتاحية لعناصر الصفحة.
  /// English: Drives the page entrance animation.
  late AnimationController _animationController;

  /// Arabic: يصنع نبضة بصرية للزر العائم المميز.
  /// English: Produces the pulse animation for the highlighted floating button.
  late AnimationController _pulseAnimationController;

  /// Arabic: ينسق التنقل بين أوضاع العرض داخل الصفحة.
  /// English: Coordinates switching among the page's display modes.
  late TabController _tabController;

  /// Arabic: يراقب التمرير داخل قائمة الحجوزات.
  /// English: Tracks scrolling within the bookings list.
  final ScrollController _scrollController = ScrollController();

  /// Arabic: يحدد ما إذا كانت الصفحة تعرض بطاقات شبكية أم لا.
  /// English: Tracks whether the page currently shows a grid of cards.
  bool _isGridView = false;

  /// Arabic: يحدد ما إذا كانت لوحة الفلاتر ظاهرة.
  /// English: Tracks whether the filter panel is visible.
  bool _showFilters = false;

  /// Arabic: يحتفظ بالفلاتر النشطة التي تم تطبيقها مؤخرًا.
  /// English: Stores the currently active filters applied in the view.
  BookingFilters? _activeFilters;

  /// Arabic: يحفظ آخر سبب إلغاء لكل حجز لإعادة استخدامه عند الحاجة.
  /// English: Remembers the latest cancellation reason for each booking when needed again.
  final Map<String, String> _lastCancellationReasons = {};

  /// Arabic: يهيئ المتحكمات والحركات ثم يحمّل بيانات الحجوزات الأولى.
  /// English: Initializes controllers and animations, then loads the initial bookings data.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 🎯 إضافة pulse animation controller
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
    _setupScrollListener();
  }

  /// Arabic: يطلب دفعة الحجوزات الأولى ضمن النطاق المحدد للتحميل.
  /// English: Requests the initial bookings batch within the configured load range.
  void _loadBookings() {
    // Default range (when not coming from a deep-link): from 2023-01-01 until tomorrow.
    // This avoids the common "no bookings" empty state when seeded/demo data is older.
    final start = widget.initialStartDate ?? DateTime(2023, 1, 1);
    final end =
        widget.initialEndDate ?? DateTime.now().add(const Duration(days: 1));

    // منع إرسال حدث مكرر إذا كانت نفس النطاقات مُحمَّلة بالفعل
    final bloc = context.read<BookingsListBloc>();
    final state = bloc.state;
    if (state is BookingsListLoaded) {
      final f = state.filters;
      if (f?.startDate == start && f?.endDate == end) {
        return; // لا تعيد التحميل بنفس النطاق
      }
    }

    bloc.add(LoadBookingsEvent(
      startDate: start,
      endDate: end,
      pageNumber: 1,
      pageSize: 50,
    ));
  }

  /// Arabic: يضيف مستمع التمرير لجلب الصفحة التالية عند الاقتراب من النهاية.
  /// English: Adds a scroll listener to fetch the next page near the list bottom.
  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // Load more when near bottom
        final state = context.read<BookingsListBloc>().state;
        if (state is BookingsListLoaded && state.bookings.hasNextPage) {
          final bloc = context.read<BookingsListBloc>();
          final nextPage =
              state.bookings.nextPageNumber ?? (state.bookings.pageNumber + 1);
          // منع الطلبات المتكررة السريعة
          bloc.add(
            ChangePageEvent(pageNumber: nextPage),
          );
        }
      }
    });
  }

  /// Arabic: يعيد تحميل الحجوزات عندما يسحب المستخدم القائمة للأسفل.
  /// English: Refreshes bookings when the user performs a pull-to-refresh gesture.
  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    context.read<BookingsListBloc>().add(const RefreshBookingsEvent());

    // انتظار اكتمال التحديث
    await context.read<BookingsListBloc>().stream.firstWhere(
          (state) =>
              state is BookingsListLoaded ||
              state is BookingsListError ||
              state is BookingOperationSuccess ||
              state is BookingOperationFailure,
        );
  }

  /// Arabic: يحرر المتحكمات قبل إزالة الصفحة من الشجرة.
  /// English: Disposes the controllers before the page leaves the tree.
  @override
  void dispose() {
    _animationController.dispose();
    _pulseAnimationController.dispose(); // 🎯 تنظيف
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Arabic: يبني الصفحة مع مراقبة الحالات التي تحتاج إلى تفاعل إضافي.
  /// English: Builds the page while watching for states that require additional interaction.
  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingsListBloc, BookingsListState>(
      listener: (context, state) async {
        if (state is BookingOperationFailure &&
            state.message == 'PAYMENTS_EXIST' &&
            state.bookingId != null) {
          final bookingId = state.bookingId!;
          await showDialog<void>(
            context: context,
            builder: (ctx) => BookingConfirmationDialog(
              type: BookingConfirmationType.cancel,
              bookingId: bookingId,
              customTitle: 'لا يمكن الإلغاء',
              customSubtitle:
                  'لا يمكن إلغاء حجز يحتوي على مدفوعات. هل تريد استرداد المدفوعات ثم إلغاء الحجز؟',
              customConfirmText: 'نعم، استرد ثم ألغِ',
              onConfirm: () {
                context.read<BookingsListBloc>().add(CancelBookingEvent(
                      bookingId: bookingId,
                      cancellationReason: _lastCancellationReasons[bookingId] ??
                          'إلغاء مع استرداد المدفوعات',
                      refundPayments: true,
                    ));
              },
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppTheme.primaryBlue,
              backgroundColor: AppTheme.darkCard,
              strokeWidth: 2.5,
              displacement: 60,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  _buildSliverAppBar(),
                  _buildStatsSection(),
                  _buildFilterSection(),
                  _buildBookingsList(),
                ],
              ),
            ),
            _buildOperationOverlay(),
          ],
        ),
        floatingActionButton:
            _buildEnhancedFloatingActionButton(), // 🎯 تحسين الزر العائم
      ),
    );
  }

  /// Arabic: ينشئ شريط العنوان المثبت مع أزرار العرض والتنقل والفلاتر.
  /// English: Builds the pinned app bar with view, navigation, and filter actions.
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.darkBackground,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          'الحجوزات',
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
          icon: _isGridView
              ? CupertinoIcons.list_bullet
              : CupertinoIcons.square_grid_2x2,
          onPressed: () => setState(() => _isGridView = !_isGridView),
        ),
        _buildActionButton(
          icon: CupertinoIcons.calendar,
          onPressed: () => context.push('/admin/bookings/calendar'),
        ),

        // 🎯 الزر الجديد - Timeline مع تصميم مميز
        _buildTimelineButton(),

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

  /// Arabic: يبني زر الخط الزمني بتأثير بصري نابض لتمييزه عن بقية الأزرار.
  /// English: Builds the timeline button with a pulsing visual treatment to stand out.
  Widget _buildTimelineButton() {
    return AnimatedBuilder(
      animation: _pulseAnimationController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            children: [
              // Background with gradient
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
                      _navigateToTimeline();
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

              // Pulse indicator
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

  /// Arabic: ينتقل إلى صفحة الخط الزمني بعد تشغيل انتقال قصير.
  /// English: Navigates to the timeline page after a short transition effect.
  void _navigateToTimeline() {
    // عرض loading animation
    _showNavigationAnimation();

    // التنقل بعد انتهاء الـ animation
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pop(context);
      context.push('/admin/bookings/timeline');
    });
  }

  /// Arabic: يعرض طبقة انتقالية ضبابية أثناء الانتقال إلى الخط الزمني.
  /// English: Shows a blurred transition overlay while navigating to the timeline.
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

  /// Arabic: يبني زر إجراء صغيرًا مناسبًا لشريط العنوان.
  /// English: Builds a compact action button that fits the app bar.
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

  /// Arabic: يختار الزر العائم المناسب بين الوصول السريع والإجراءات الجماعية.
  /// English: Chooses the appropriate floating button between quick access and bulk actions.
  Widget _buildEnhancedFloatingActionButton() {
    return BlocBuilder<BookingsListBloc, BookingsListState>(
      builder: (context, state) {
        // إذا كان هناك عناصر محددة، أظهر زر الإجراءات الجماعية
        if (state is BookingsListLoaded && state.selectedBookings.isNotEmpty) {
          return _buildBulkActionsFloatingButton(state);
        }

        // وإلا أظهر زر القائمة السريعة
        return _buildQuickAccessFloatingButton();
      },
    );
  }

  /// Arabic: يبني زر الوصول السريع الذي يفتح قائمة الاختصارات.
  /// English: Builds the quick-access button that opens the shortcuts menu.
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

  /// Arabic: يفتح لوحة سفلية تحتوي أهم اختصارات التنقل.
  /// English: Opens a bottom sheet with the most frequently used navigation shortcuts.
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
                // Handle bar
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

                // Title
                Text(
                  'إجراءات سريعة',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
                const SizedBox(height: 20),

                // Menu Items
                _buildQuickMenuItem(
                  icon: CupertinoIcons.chart_bar_alt_fill,
                  label: 'الخط الزمني',
                  subtitle: 'عرض الحجوزات على الخط الزمني التفاعلي',
                  gradient: [AppTheme.primaryPurple, AppTheme.primaryViolet],
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/admin/bookings/timeline');
                  },
                ),
                _buildQuickMenuItem(
                  icon: CupertinoIcons.calendar,
                  label: 'التقويم',
                  subtitle: 'عرض الحجوزات في التقويم الشهري',
                  gradient: [AppTheme.primaryBlue, AppTheme.primaryCyan],
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/admin/bookings/calendar');
                  },
                ),
                const SizedBox(height: 20),
                // Safe area for bottom padding
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Arabic: يبني عنصرًا واحدًا داخل قائمة الوصول السريع.
  /// English: Builds a single entry inside the quick access menu.
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

  /// Arabic: يبني زر الإجراءات الجماعية الذي يظهر عند تحديد أكثر من حجز.
  /// English: Builds the bulk-actions button shown when multiple bookings are selected.
  Widget _buildBulkActionsFloatingButton(BookingsListLoaded state) {
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
          '${state.selectedBookings.length} محدد',
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

  /// Arabic: يعرض بطاقات الإحصاءات المختصرة أعلى قائمة الحجوزات.
  /// English: Renders the compact statistics cards above the bookings list.
  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: BlocBuilder<BookingsListBloc, BookingsListState>(
        builder: (context, state) {
          if (state is! BookingsListLoaded) return const SizedBox.shrink();

          return AnimationLimiter(
            child: Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BookingStatsCards(
                bookings: state.bookings.items,
                stats: state.stats ?? {},
              ),
            ),
          );
        },
      ),
    );
  }

  /// Arabic: يفتح أو يغلق لوحة الفلاتر المتقدمة للحجوزات.
  /// English: Expands or collapses the advanced bookings filter panel.
  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _showFilters ? 180 : 0,
        child: _showFilters
            ? BookingFiltersWidget(
                initialFilters: _activeFilters,
                onFiltersChanged: (filters) {
                  setState(() => _activeFilters = filters);
                  context.read<BookingsListBloc>().add(
                        FilterBookingsEvent(
                          startDate: filters.startDate,
                          endDate: filters.endDate,
                          userId: filters.userId,
                          unitId: filters.unitId,
                          bookingSource: filters.bookingSource,
                        ),
                      );
                },
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  /// Arabic: يعرض محتوى القائمة أو حالات التحميل والخطأ والفراغ.
  /// English: Renders the list content or its loading, error, and empty states.
  Widget _buildBookingsList() {
    return BlocBuilder<BookingsListBloc, BookingsListState>(
      builder: (context, state) {
        if (state is BookingsListLoading) {
          // لا نظهر رسالة فارغة أثناء التحميل الأولي فقط، لتجنب الوميض
          return const SliverFillRemaining(
            child: LoadingWidget(
              type: LoadingType.futuristic,
              message: 'جاري تحميل الحجوزات...',
            ),
          );
        }

        if (state is BookingsListError) {
          return SliverFillRemaining(
            child: CustomErrorWidget(
              message: state.message,
              onRetry: _loadBookings,
            ),
          );
        }

        // إبقاء القائمة مرئية أثناء حالات العمليات (نجاح/فشل/جارية)
        BookingsListLoaded? displayState;
        if (state is BookingsListLoaded) {
          displayState = state;
        } else if (state is BookingOperationInProgress) {
          displayState = BookingsListLoaded(
            bookings: state.bookings,
            selectedBookings: state.selectedBookings,
          );
        } else if (state is BookingOperationSuccess) {
          displayState = BookingsListLoaded(
            bookings: state.bookings,
            selectedBookings: state.selectedBookings,
          );
        } else if (state is BookingOperationFailure) {
          displayState = BookingsListLoaded(
            bookings: state.bookings,
            selectedBookings: state.selectedBookings,
          );
        }

        if (displayState != null) {
          if (displayState.bookings.items.isEmpty) {
            return const SliverFillRemaining(
              child: EmptyWidget(
                message: 'لا توجد حجوزات حالياً',
              ),
            );
          }
          return _isGridView
              ? _buildGridView(displayState)
              : _buildTableView(displayState);
        }

        return const SliverFillRemaining(child: SizedBox.shrink());
      },
    );
  }

  /// Arabic: يعرض طبقة تغطية أثناء العمليات التي تحتاج إيقاف التفاعل مؤقتًا.
  /// English: Shows an overlay for operations that need temporary UI blocking.
  Widget _buildOperationOverlay() {
    return BlocBuilder<BookingsListBloc, BookingsListState>(
      builder: (context, state) {
        if (state is BookingOperationInProgress) {
          final overlayMessage = state.operation == 'refresh'
              ? 'جاري تحديث القائمة...'
              : 'جاري تنفيذ العملية...';
          return Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: AppTheme.darkBackground.withValues(alpha: 0.4),
                alignment: Alignment.center,
                child: LoadingWidget(
                  type: LoadingType.futuristic,
                  message: overlayMessage,
                ),
              ),
            ),
          );
        }
        if (state is BookingOperationFailure) {
          if (state.message == 'PAYMENTS_EXIST') {
            // سيتم عرض ديالوج مخصص عبر BlocListener، لا نعرض رسالة خطأ هنا
            return const SizedBox.shrink();
          }
          return Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: CustomErrorWidget(
              message: state.message,
              onRetry: () => context
                  .read<BookingsListBloc>()
                  .add(const RefreshBookingsEvent()),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Arabic: يعرض الحجوزات على هيئة شبكة بطاقات تفاعلية.
  /// English: Displays bookings as an interactive grid of cards.
  Widget _buildGridView(BookingsListLoaded state) {
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
            final booking = state.bookings.items[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: 2,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: FuturisticBookingCard(
                    booking: booking,
                    isSelected: state.selectedBookings.contains(booking),
                    onTap: () => _navigateToDetails(booking.id),
                    onLongPress: () => _toggleSelection(booking),
                    onConfirm: () => _showConfirmDialog(booking.id),
                    onCancel: () => _showCancelDialog(booking.id),
                    onCheckIn: () {
                      context
                          .read<BookingsListBloc>()
                          .add(CheckInBookingEvent(bookingId: booking.id));
                    },
                    onCheckOut: () {
                      context
                          .read<BookingsListBloc>()
                          .add(CheckOutBookingEvent(bookingId: booking.id));
                    },
                  ),
                ),
              ),
            );
          },
          childCount: state.bookings.items.length,
        ),
      ),
    );
  }

  /// Arabic: يعرض الحجوزات في جدول مناسب للعمليات السريعة.
  /// English: Displays bookings in a table layout suited for quick actions.
  Widget _buildTableView(BookingsListLoaded state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FuturisticBookingsTable(
          bookings: state.bookings.items,
          selectedBookings: state.selectedBookings,
          onBookingTap: _navigateToDetails,
          onSelectionChanged: (bookings) {
            context.read<BookingsListBloc>().add(
                  SelectMultipleBookingsEvent(
                    bookingIds: bookings.map((b) => b.id).toList(),
                  ),
                );
          },
          onConfirm: (bookingId) {
            _showConfirmDialog(bookingId);
          },
          onCancel: (bookingId) {
            _showCancelDialog(bookingId);
          },
          onCheckIn: (bookingId) {
            context
                .read<BookingsListBloc>()
                .add(CheckInBookingEvent(bookingId: bookingId));
          },
          onCheckOut: (bookingId) {
            context
                .read<BookingsListBloc>()
                .add(CheckOutBookingEvent(bookingId: bookingId));
          },
        ),
      ),
    );
  }

  /// Arabic: ينتقل إلى صفحة تفاصيل الحجز ثم ينعش القائمة إذا عادت نتيجة نجاح.
  /// English: Opens booking details and refreshes the list when a successful result returns.
  Future<void> _navigateToDetails(String bookingId) async {
    final result = await context.push('/admin/bookings/$bookingId');
    // تحديث القائمة فقط إذا تمت عمليات في صفحة التفاصيل
    if (result == true && mounted) {
      context.read<BookingsListBloc>().add(const RefreshBookingsEvent());
    }
  }

  /// Arabic: يبدّل تحديد الحجز لاستخدامه في الإجراءات الجماعية.
  /// English: Toggles a booking's selection for bulk actions.
  void _toggleSelection(Booking booking) {
    final bloc = context.read<BookingsListBloc>();
    final state = bloc.state;

    if (state is BookingsListLoaded) {
      if (state.selectedBookings.contains(booking)) {
        bloc.add(DeselectBookingEvent(bookingId: booking.id));
      } else {
        bloc.add(SelectBookingEvent(bookingId: booking.id));
      }
    }
  }

  /// Arabic: يفتح حوار تأكيد الحجز مع الحفاظ على مرجع الحجز الحالي.
  /// English: Opens the booking confirmation dialog while preserving the current reference.
  void _showConfirmDialog(String bookingId) {
    // final bloc = context.read<BookingsListBloc>();
    // final state = bloc.state;

    String? bookingReference = bookingId;

    showBookingConfirmationDialog(
      context: context,
      type: BookingConfirmationType.confirm,
      bookingId: bookingId,
      bookingReference: bookingReference,
      onConfirm: () {
        context
            .read<BookingsListBloc>()
            .add(ConfirmBookingEvent(bookingId: bookingId));
      },
    );
  }

  /// Arabic: يفتح حوار سبب الإلغاء ثم يرسل التأكيد النهائي عند الاختيار.
  /// English: Opens the cancellation-reason dialog and then sends the final confirmation.
  void _showCancelDialog(String bookingId) async {
    // First: Show reason selection dialog
    final result = await showDialog<String?>(
      context: context,
      fullscreenDialog: true,
      builder: (ctx) {
        return BookingActionsDialog(
          bookingId: bookingId,
          action: BookingAction.cancel,
        );
      },
    );

    // Second: If reason selected, show confirmation dialog
    if (result != null && result.isNotEmpty && mounted) {
      // احفظ السبب لإعادة الإرسال في حال ظهرت حاجة لاسترداد المدفوعات
      _lastCancellationReasons[bookingId] = result;
      // final bloc = context.read<BookingsListBloc>();
      // final state = bloc.state;

      String? bookingReference = bookingId;

      showBookingConfirmationDialog(
        context: context,
        type: BookingConfirmationType.cancel,
        bookingId: bookingId,
        bookingReference: bookingReference,
        onConfirm: () {
          context.read<BookingsListBloc>().add(
                CancelBookingEvent(
                  bookingId: bookingId,
                  cancellationReason: result,
                  refundPayments: false,
                ),
              );
        },
      );
    }
  }

  /// Arabic: يعرض لوحة سفلية للإجراءات الجماعية المتاحة للحجوزات المحددة.
  /// English: Shows a bottom sheet with the available bulk actions for selected bookings.
  void _showBulkActions() {
    // Show bottom sheet with bulk actions
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            // Bulk action buttons
            _buildBulkActionButton(
              icon: CupertinoIcons.checkmark_circle,
              label: 'تأكيد الكل',
              onTap: () {},
            ),
            _buildBulkActionButton(
              icon: CupertinoIcons.xmark_circle,
              label: 'إلغاء الكل',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  /// Arabic: يبني زرًا واحدًا داخل لوحة الإجراءات الجماعية.
  /// English: Builds a single action button inside the bulk actions panel.
  Widget _buildBulkActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
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
                Icon(icon, color: AppTheme.primaryBlue),
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
}
