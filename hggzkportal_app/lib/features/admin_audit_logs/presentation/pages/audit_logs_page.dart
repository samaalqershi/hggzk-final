// lib/features/admin_audit_logs/presentation/pages/audit_logs_page.dart

import 'package:hggzkportal/features/admin_audit_logs/domain/entities/audit_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../bloc/audit_logs_bloc.dart';
import '../bloc/audit_logs_event.dart';
import '../bloc/audit_logs_state.dart';
import '../widgets/futuristic_audit_log_card.dart';
import '../widgets/futuristic_audit_logs_table.dart';
import '../widgets/audit_log_filters_widget.dart';
import '../widgets/audit_log_timeline_widget.dart';
import '../widgets/audit_log_stats_card.dart';
import '../widgets/audit_log_details_dialog.dart';

/// Arabic: صفحة سجلات التدقيق التي تعرض الأحداث، الفلاتر، الإحصاءات، وطريقة العرض الزمنية أو الجدولية.
/// English: Audit logs page that presents events, filters, statistics, and either a timeline or table view.
class AuditLogsPage extends StatefulWidget {
  /// Arabic: ينشئ صفحة سجلات التدقيق بدون معاملات لأن البيانات تُحمّل من طبقة الـ bloc.
  /// English: Creates the audit logs page; data is loaded through the bloc layer.
  const AuditLogsPage({super.key});

  @override

  /// Arabic: ينشئ حالة الصفحة المسؤولة عن التمرير، التحميل التدريجي، والتحكم بالعرض.
  /// English: Creates the page state that manages scrolling, incremental loading, and view toggles.
  State<AuditLogsPage> createState() => _AuditLogsPageState();
}

/// Arabic: حالة صفحة سجلات التدقيق التي تدير التحميل التدريجي، الفلاتر، والتحول بين العروض.
/// English: State for the audit logs page, handling pagination, filters, and view switching.
class _AuditLogsPageState extends State<AuditLogsPage>
    with TickerProviderStateMixin {
  /// Arabic: أقل فترة انتظار بين محاولات جلب المزيد حتى لا تتكرر الطلبات بسرعة.
  /// English: Minimum delay between load-more attempts to prevent repeated rapid requests.
  static const Duration _loadMoreTriggerDebounce = Duration(milliseconds: 450);

  /// Arabic: المسافة المتبقية قبل نهاية القائمة التي عندها نبدأ بطلب الصفحة التالية.
  /// English: Remaining scroll distance that triggers the next page load.
  static const double _loadMoreThreshold = 220;

  /// Arabic: يتحكم في حركة الظهور الأولية وعناصر الشعار داخل الصفحة.
  /// English: Controls the initial entrance animation and decorative page motion.
  late AnimationController _animationController;

  /// Arabic: يدير نبض الإضاءة في زر التصدير والعناصر التفاعلية.
  /// English: Drives the pulsing light effect used by the export button and related accents.
  late AnimationController _pulseAnimationController;

  /// Arabic: يدير التبويبات أو الأوضاع الثلاثة الخاصة بعرض السجل.
  /// English: Manages the three tabs or view modes used for audit log presentation.
  late TabController _tabController;

  /// Arabic: يتابع موضع التمرير لتفعيل الجلب الإضافي عند الاقتراب من نهاية القائمة.
  /// English: Tracks scroll position to trigger loading more items near the end of the list.
  final ScrollController _scrollController = ScrollController();

  /// Arabic: يحدد آخر وقت تم فيه تشغيل جلب المزيد حتى يُطبق التأخير القصير.
  /// English: Stores the last time load-more was triggered so the debounce window can be enforced.
  DateTime? _lastLoadMoreTriggerAt;

  /// Arabic: يحدد ما إذا كان العرض الحالي شبكة بطاقات بدل الجدول.
  /// English: Indicates whether the current presentation uses a grid instead of a table.
  bool _isGridView = false;

  /// Arabic: يتحكم في إظهار قسم الفلاتر أو إخفائه.
  /// English: Controls whether the filter section is expanded or collapsed.
  bool _showFilters = false;

  /// Arabic: يتحكم في إظهار المخطط الزمني بدل القائمة العادية.
  /// English: Controls whether the timeline view is shown instead of the standard list.
  bool _showTimeline = false;

  /// Arabic: يحفظ الفلاتر النشطة كي تبقى الواجهة متزامنة مع نتائج البحث.
  /// English: Keeps the active filters so the UI stays in sync with the filtered results.
  AuditLogFilters? _activeFilters;

  @override

  /// Arabic: يهيئ الأنيميشنات، يشغل التحميل الأولي، ويثبت مستمع التمرير.
  /// English: Initializes animations, loads the initial data set, and attaches the scroll listener.
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
    _loadAuditLogs();
    _setupScrollListener();
  }

  /// Arabic: يطلب أول دفعة من سجلات التدقيق لآخر ثلاثين يومًا.
  /// English: Requests the first batch of audit logs for the last thirty days.
  void _loadAuditLogs() {
    context.read<AuditLogsBloc>().add(
          LoadAuditLogsEvent(
            query: AuditLogsQuery(
              pageNumber: 1,
              pageSize: 20,
              from: DateTime.now().subtract(const Duration(days: 30)),
              to: DateTime.now(),
            ),
          ),
        );
  }

  /// Arabic: يربط مستمعًا على التمرير لتفعيل تحميل المزيد تلقائيًا عند الحاجة.
  /// English: Attaches a scroll listener that automatically attempts to load more items when needed.
  void _setupScrollListener() {
    _scrollController.addListener(() {
      _tryLoadMoreIfNeeded();
    });
  }

  /// Arabic: يعيد محاولة الجلب التدريجي عندما تصل الحالة إلى مؤشرات تدل أن التحميل التالي متاح.
  /// English: Re-attempts incremental loading when the state indicates another page may be available.
  void _onAuditLogsStateChanged(AuditLogsState state) {
    if (state is! AuditLogsLoaded) return;
    if (state.hasReachedMax || state.isLoadingMore) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tryLoadMoreIfNeeded(skipDebounce: true);
    });
  }

  /// Arabic: يفحص قرب التمرير من النهاية ثم يطلق حدث الجلب التدريجي مع حماية من التكرار.
  /// English: Checks whether the scroll is close to the end and dispatches load-more with debounce protection.
  void _tryLoadMoreIfNeeded({bool skipDebounce = false}) {
    if (!_scrollController.hasClients) return;

    final state = context.read<AuditLogsBloc>().state;
    if (state is! AuditLogsLoaded) return;
    if (state.hasReachedMax || state.isLoadingMore) return;

    final position = _scrollController.position;
    final reachedLoadThreshold =
        position.pixels >= position.maxScrollExtent - _loadMoreThreshold;
    if (!reachedLoadThreshold) return;

    final now = DateTime.now();
    if (!skipDebounce &&
        _lastLoadMoreTriggerAt != null &&
        now.difference(_lastLoadMoreTriggerAt!) < _loadMoreTriggerDebounce) {
      return;
    }

    _lastLoadMoreTriggerAt = now;
    context.read<AuditLogsBloc>().add(const LoadMoreAuditLogsEvent());
  }

  @override

  /// Arabic: يحرر المتحكمات حتى لا تبقى موارد الرسوم والتمرير والتبويبات معلقة.
  /// English: Disposes controllers so animation, scroll, and tab resources are released.
  void dispose() {
    _animationController.dispose();
    _pulseAnimationController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override

  /// Arabic: يبني الصفحة كاملة مع الاستماع لحالات السجل وإظهار العرض المناسب.
  /// English: Builds the full page while listening to audit log state and showing the appropriate view.
  Widget build(BuildContext context) {
    return BlocListener<AuditLogsBloc, AuditLogsState>(
      listenWhen: (previous, current) {
        if (current is! AuditLogsLoaded) return false;
        if (previous is! AuditLogsLoaded) return true;

        return previous.isLoadingMore != current.isLoadingMore ||
            previous.auditLogs.length != current.auditLogs.length;
      },
      listener: (context, state) => _onAuditLogsStateChanged(state),
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _buildSliverAppBar(),
            _buildStatsSection(),
            _buildFilterSection(),
            if (_showTimeline) _buildTimelineSection() else _buildLogsList(),
          ],
        ),
      ),
    );
  }

  /// Arabic: يبني شريطًا علويًا متموجًا يحتوي العنوان وأزرار التحكم بالعرض والتصدير.
  /// English: Builds the themed sliver app bar containing the title, view controls, and export action.
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.darkBackground,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          'سجل الأنشطة',
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
        _buildActionButton(
          icon: _showTimeline ? CupertinoIcons.list_dash : CupertinoIcons.time,
          onPressed: () => setState(() => _showTimeline = !_showTimeline),
          isActive: _showTimeline,
        ),
        _buildActionButton(
          icon: _showFilters
              ? CupertinoIcons.xmark
              : CupertinoIcons.slider_horizontal_3,
          onPressed: () => setState(() => _showFilters = !_showFilters),
        ),
        _buildExportButton(),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Arabic: يبني زر إجراء دائريًا يمكن أن يكون في حالة نشطة أو عادية.
  /// English: Builds a circular action button that can render in active or normal state.
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primaryPurple.withValues(alpha: 0.2)
            : AppTheme.darkCard.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppTheme.primaryPurple.withValues(alpha: 0.5)
              : AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: isActive ? AppTheme.primaryPurple : AppTheme.textWhite,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  /// Arabic: يبني زر التصدير المتوهج الذي يرسل السجلات الحالية إلى ملف أو إجراء تصدير.
  /// English: Builds the glowing export button that dispatches the current audit logs to an export flow.
  Widget _buildExportButton() {
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
                      AppTheme.success.withValues(alpha: 0.2),
                      AppTheme.neonGreen.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.success.withValues(
                      alpha: 0.3 + (_pulseAnimationController.value * 0.2),
                    ),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.success.withValues(
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
                    onTap: _handleExport,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        CupertinoIcons.square_arrow_down,
                        color: AppTheme.success,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Arabic: يبني قسم الإحصاءات أعلى القائمة ليعرض صورة سريعة عن السجل.
  /// English: Builds the statistics section above the list to provide a quick snapshot of the logs.
  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: BlocBuilder<AuditLogsBloc, AuditLogsState>(
        builder: (context, state) {
          if (state is! AuditLogsLoaded) return const SizedBox.shrink();

          return AnimationLimiter(
            child: Container(
              height: 130,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AuditLogStatsCard(
                auditLogs: state.auditLogs,
                totalCount: state.totalCount,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Arabic: يبني قسم الفلاتر القابل للطي ويحدّث الاستعلام عند تغيير أي فلتر.
  /// English: Builds the collapsible filter section and updates the query whenever filters change.
  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _showFilters ? 180 : 0,
        child: _showFilters
            ? AuditLogFiltersWidget(
                initialFilters: _activeFilters,
                onFiltersChanged: (filters) {
                  setState(() => _activeFilters = filters);
                  context.read<AuditLogsBloc>().add(
                        FilterAuditLogsEvent(
                          userId: filters.userId,
                          from: filters.startDate,
                          to: filters.endDate,
                          operationType: filters.operationType,
                          searchTerm: filters.searchTerm,
                        ),
                      );
                },
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  /// Arabic: يبني عرض المخطط الزمني عندما يختار المستخدم رؤية السجل كسرد متسلسل.
  /// English: Builds the timeline view when the user chooses a chronological representation.
  Widget _buildTimelineSection() {
    return SliverToBoxAdapter(
      child: BlocBuilder<AuditLogsBloc, AuditLogsState>(
        builder: (context, state) {
          if (state is AuditLogsLoading) {
            return const SizedBox(
              height: 400,
              child: LoadingWidget(
                type: LoadingType.futuristic,
                message: 'جاري تحميل السجل...',
              ),
            );
          }

          if (state is AuditLogsError) {
            return SizedBox(
              height: 400,
              child: CustomErrorWidget(
                message: state.message,
                onRetry: _loadAuditLogs,
              ),
            );
          }

          if (state is AuditLogsLoaded) {
            if (state.auditLogs.isEmpty) {
              return const SizedBox(
                height: 400,
                child: EmptyWidget(
                  message: 'لا توجد سجلات حالياً',
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: AuditLogTimelineWidget(
                auditLogs: state.auditLogs,
                onLogTap: (log) => _showLogDetails(log),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Arabic: يقرر أي نمط عرض يجب إظهاره: مخطط زمني أو قائمة السجلات.
  /// English: Chooses whether the page should display a timeline or the standard logs list.
  Widget _buildLogsList() {
    return BlocBuilder<AuditLogsBloc, AuditLogsState>(
      builder: (context, state) {
        if (state is AuditLogsLoading) {
          return const SliverFillRemaining(
            child: LoadingWidget(
              type: LoadingType.futuristic,
              message: 'جاري تحميل السجلات...',
            ),
          );
        }

        if (state is AuditLogsError) {
          return SliverFillRemaining(
            child: CustomErrorWidget(
              message: state.message,
              onRetry: _loadAuditLogs,
            ),
          );
        }

        if (state is AuditLogsLoaded) {
          if (state.auditLogs.isEmpty) {
            return const SliverFillRemaining(
              child: EmptyWidget(
                message: 'لا توجد سجلات حالياً',
              ),
            );
          }

          return _isGridView ? _buildGridView(state) : _buildTableView(state);
        }

        return const SliverFillRemaining(child: SizedBox.shrink());
      },
    );
  }

  /// Arabic: يبني عرض الشبكة لسجلات التدقيق عندما تكون معاينة البطاقات أفضل.
  /// English: Builds the grid presentation for audit logs when card-style browsing is preferred.
  Widget _buildGridView(AuditLogsLoaded state) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1, // 🎯 تم تعديل النسبة لتناسب المحتوى بشكل أفضل
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final log = state.auditLogs[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: 2,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: FuturisticAuditLogCard(
                    auditLog: log,
                    onTap: () => _showLogDetails(log),
                    isGridView: true, // 🎯 تمرير معامل العرض الشبكي
                  ),
                ),
              ),
            );
          },
          childCount: state.auditLogs.length,
        ),
      ),
    );
  }

  /// Arabic: يبني عرض الجدول عندما تكون الكثافة المعلوماتية أهم من البطاقات.
  /// English: Builds the table presentation when information density is more useful than cards.
  Widget _buildTableView(AuditLogsLoaded state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FuturisticAuditLogsTable(
          auditLogs: state.auditLogs,
          onLogTap: (log) => _showLogDetails(log),
        ),
      ),
    );
  }

  /// Arabic: يفتح نافذة تفاصيل السجل المختار ليعرض البيانات الكاملة.
  /// English: Opens the selected log details dialog so the full record can be reviewed.
  void _showLogDetails(AuditLog log) {
    showDialog(
      fullscreenDialog: true,
      context: context,
      builder: (context) => AuditLogDetailsDialog(auditLog: log),
    );
  }

  /// Arabic: يرسل حدث التصدير اعتمادًا على الاستعلام الحالي عندما تكون البيانات جاهزة.
  /// English: Dispatches the export event using the current query when data is available.
  void _handleExport() {
    final state = context.read<AuditLogsBloc>().state;
    if (state is AuditLogsLoaded) {
      context.read<AuditLogsBloc>().add(
            ExportAuditLogsEvent(query: state.currentQuery),
          );
    }
  }
}
