import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';
import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../bloc/review_state.dart';
import '../widgets/review_card_widget.dart';

/// Shows the paginated review feed together with filter controls.
/// تعرض موجز المراجعات المقسم إلى صفحات مع أدوات الفلترة.
class ReviewsListPage extends StatefulWidget {
  /// Property whose reviews should be listed.
  /// العقار الذي يجب سرد مراجعاته.
  final String propertyId;

  /// Property name shown in the header.
  /// اسم العقار الظاهر في الترويسة.
  final String propertyName;

  /// Builds the page used to browse property reviews.
  /// ينشئ الصفحة المستخدمة لتصفح مراجعات العقار.
  const ReviewsListPage({
    super.key,
    required this.propertyId,
    required this.propertyName,
  });

  /// Creates the state object that manages filters and pagination.
  /// ينشئ كائن الحالة الذي يدير الفلاتر والترقيم.
  @override
  State<ReviewsListPage> createState() => _ReviewsListPageState();
}

/// Coordinates filtering, scrolling, and pagination for the review feed.
/// ينسق الفلترة والتمرير والترقيم لموجز المراجعات.
class _ReviewsListPageState extends State<ReviewsListPage> {
  final ScrollController _scrollController = ScrollController();

  /// Optional rating filter currently selected by the user.
  /// فلتر التقييم الاختياري المحدد حاليًا من المستخدم.
  int? _selectedRating;

  /// True when the feed should include only reviews with images.
  /// تكون صحيحة عندما يجب أن يحتوي الموجز على مراجعات بصور فقط.
  bool _withImagesOnly = false;

  /// Sort field applied to the review feed.
  /// حقل الترتيب المطبق على موجز المراجعات.
  String _sortBy = 'CreatedAt';

  /// Sort direction applied to the review feed.
  /// اتجاه الترتيب المطبق على موجز المراجعات.
  String _sortDirection = 'Desc';

  /// Hooks the scroll listener used for infinite pagination.
  /// يربط مستمع التمرير المستخدم للترقيم اللانهائي.
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  /// Releases the scroll controller owned by the page.
  /// يحرر متحكم التمرير المملوك للصفحة.
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Triggers pagination when the list approaches the bottom.
  /// يطلق الترقيم عندما تقترب القائمة من النهاية.
  void _onScroll() {
    if (_isBottom) {
      context.read<ReviewBloc>().add(const LoadMoreReviewsEvent());
    }
  }

  /// True when the user has scrolled close enough to request more reviews.
  /// تكون صحيحة عندما يقترب المستخدم من أسفل القائمة بما يكفي لطلب المزيد.
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  /// Renders the review feed with filters, loading states, and cards.
  /// يرسم موجز المراجعات مع الفلاتر وحالات التحميل والبطاقات.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ReviewBloc>()
        ..add(GetPropertyReviewsEvent(propertyId: widget.propertyId)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            _buildFuturisticBackground(),
            Column(
              children: [
                _buildFiltersSection(),
                const Divider(height: 1),
                Expanded(
                  child: BlocBuilder<ReviewBloc, ReviewState>(
                    builder: (context, state) {
                      if (state is ReviewLoading) {
                        return const Center(
                          child: LoadingWidget(
                            type: LoadingType.circular,
                          ),
                        );
                      }

                      if (state is ReviewError) {
                        return Center(
                          child: CustomErrorWidget(
                            message: state.message,
                            onRetry: () {
                              context.read<ReviewBloc>().add(
                                    GetPropertyReviewsEvent(
                                      propertyId: widget.propertyId,
                                    ),
                                  );
                            },
                          ),
                        );
                      }

                      if (state is ReviewsLoaded) {
                        if (state.reviews.items.isEmpty) {
                          return _buildEmptyState();
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<ReviewBloc>().add(
                                  RefreshReviewsEvent(
                                      propertyId: widget.propertyId),
                                );
                          },
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(
                                AppDimensions.paddingMedium),
                            itemCount: state.hasReachedMax
                                ? state.reviews.items.length
                                : state.reviews.items.length + 1,
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                              height: AppDimensions.spacingMd,
                            ),
                            itemBuilder: (context, index) {
                              if (index >= state.reviews.items.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                        AppDimensions.paddingMedium),
                                    child: LoadingWidget(
                                      type: LoadingType.dots,
                                    ),
                                  ),
                                );
                              }
                              return ReviewCardWidget(
                                review: state.reviews.items[index],
                                onLike: () {
                                  // Handle like
                                },
                              );
                            },
                          ),
                        );
                      }

                      if (state is ReviewLoadingMore) {
                        return ListView.separated(
                          controller: _scrollController,
                          padding:
                              const EdgeInsets.all(AppDimensions.paddingMedium),
                          itemCount: state.currentReviews.length + 1,
                          separatorBuilder: (context, index) => const SizedBox(
                            height: AppDimensions.spacingMd,
                          ),
                          itemBuilder: (context, index) {
                            if (index >= state.currentReviews.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      AppDimensions.paddingMedium),
                                  child: LoadingWidget(
                                    type: LoadingType.dots,
                                  ),
                                ),
                              );
                            }
                            return ReviewCardWidget(
                              review: state.currentReviews[index],
                              onLike: () {
                                // Handle like
                              },
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the futuristic background.
  /// العربية: يبني futuristic background.
  Widget _buildFuturisticBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.darkBackground,
            AppTheme.darkBackground2,
            AppTheme.darkBackground3,
          ],
        ),
      ),
    );
  }

  /// Builds the app bar.
  /// العربية: يبني app bar.
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.98),
              AppTheme.darkCard.withOpacity(0.9),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.primaryGradient.createShader(bounds),
            child: Text(
              context.tr(
                'reviews.pageTitle',
              ),
              style: AppTextStyles.h2.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.propertyName,
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppTheme.primaryBlue.withOpacity(0.25),
        ),
      ),
    );
  }

  /// Builds the filters section.
  /// العربية: يبني filters section.
  Widget _buildFiltersSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: context.tr(
                          'reviews.filter.all',
                        ),
                        isSelected: _selectedRating == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedRating = null;
                          });
                          _applyFilters();
                        },
                      ),
                      const SizedBox(width: AppDimensions.spacingSm),
                      ...List.generate(5, (index) {
                        final rating = 5 - index;
                        return Padding(
                          padding: const EdgeInsets.only(
                            right: AppDimensions.spacingSm,
                          ),
                          child: _buildFilterChip(
                            label: '$rating',
                            icon: Icons.star,
                            isSelected: _selectedRating == rating,
                            onSelected: (selected) {
                              setState(() {
                                _selectedRating = selected ? rating : null;
                              });
                              _applyFilters();
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterChip(
                        label: context.tr(
                          'reviews.filter.withImages',
                        ),
                        icon: Icons.photo_library_outlined,
                        isSelected: _withImagesOnly,
                        onSelected: (selected) {
                          setState(() {
                            _withImagesOnly = selected;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        final parts = value.split('-');
                        setState(() {
                          _sortBy = parts[0];
                          _sortDirection = parts[1];
                        });
                        _applyFilters();
                        HapticFeedback.lightImpact();
                      },
                      offset: const Offset(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusMd,
                        ),
                      ),
                      color: AppTheme.darkCard,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'CreatedAt-Desc',
                          child: Row(
                            children: [
                              const Icon(Icons.schedule, size: 18),
                              const SizedBox(width: 12),
                              Text(
                                context.tr(
                                  'reviews.sort.newest',
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'CreatedAt-Asc',
                          child: Row(
                            children: [
                              const Icon(Icons.history, size: 18),
                              const SizedBox(width: 12),
                              Text(
                                context.tr(
                                  'reviews.sort.oldest',
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Rating-Desc',
                          child: Row(
                            children: [
                              const Icon(Icons.trending_up, size: 18),
                              const SizedBox(width: 12),
                              Text(
                                context.tr(
                                  'reviews.sort.highestRated',
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Rating-Asc',
                          child: Row(
                            children: [
                              const Icon(Icons.trending_down, size: 18),
                              const SizedBox(width: 12),
                              Text(
                                context.tr(
                                  'reviews.sort.lowestRated',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingMedium,
                          vertical: AppDimensions.paddingSmall,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryPurple.withOpacity(0.2),
                              AppTheme.primaryBlue.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusSm,
                          ),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.sort,
                              size: 20,
                              color: AppTheme.primaryBlue,
                            ),
                            const SizedBox(
                              width: AppDimensions.spacingXs,
                            ),
                            Text(
                              _getSortLabel(),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppTheme.textWhite,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.primaryBlue,
                            ),
                          ],
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

  /// Builds the filter chip.
  /// العربية: يبني filter chip.
  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return GestureDetector(
      onTap: () {
        onSelected(!isSelected);
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: !isSelected ? AppTheme.darkCard.withOpacity(0.5) : null,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSm),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppTheme.textMuted,
              ),
              const SizedBox(width: AppDimensions.spacingXs),
            ],
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppTheme.textMuted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the empty state.
  /// العربية: يبني empty state.
  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppDimensions.paddingLarge),
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.9),
              AppTheme.darkCard.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppTheme.warning.withOpacity(0.25),
                    AppTheme.warning.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.star_outline,
                    size: 40,
                    color: AppTheme.warning.withOpacity(0.6),
                  ),
                  Icon(
                    Icons.rate_review_outlined,
                    size: 26,
                    color: AppTheme.warning,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: Text(
                context.tr(
                  'reviews.noneYet',
                ),
                style: AppTextStyles.h3.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              context.tr(
                'reviews.beFirst',
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Exposes the sort label.
  /// العربية: يعيد sort label.
  String _getSortLabel() {
    if (_sortBy == 'CreatedAt' && _sortDirection == 'Desc') {
      return context.tr(
        'reviews.sort.newest',
      );
    } else if (_sortBy == 'CreatedAt' && _sortDirection == 'Asc') {
      return context.tr(
        'reviews.sort.oldest',
      );
    } else if (_sortBy == 'Rating' && _sortDirection == 'Desc') {
      return context.tr(
        'reviews.sort.highestRated',
      );
    } else if (_sortBy == 'Rating' && _sortDirection == 'Asc') {
      return context.tr(
        'reviews.sort.lowestRated',
      );
    }
    return context.tr(
      'reviews.sort.default',
    );
  }

  /// Processes `applyFilters`.
  /// العربية: يعالج `applyFilters`.
  void _applyFilters() {
    context.read<ReviewBloc>().add(
          FilterReviewsEvent(
            rating: _selectedRating,
            withImagesOnly: _withImagesOnly,
            sortBy: _sortBy,
            sortDirection: _sortDirection,
          ),
        );
  }
}
