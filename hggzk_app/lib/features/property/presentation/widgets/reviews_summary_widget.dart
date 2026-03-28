import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';
import '../../../review/presentation/bloc/review_bloc.dart';
import '../../../review/presentation/bloc/review_event.dart';
import '../../../review/presentation/bloc/review_state.dart';
import '../../../review/domain/entities/review.dart';

/// Describes the ReviewsSummaryWidget widget used in the property feature.
/// العربية: يمثل العنصر `ReviewsSummaryWidget`.
class ReviewsSummaryWidget extends StatefulWidget {
  /// Keeps the propertyId value available to this object.
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// Keeps the reviewsCount value available to this object.
  /// العربية: يخزن القيمة `reviewsCount`.
  final int reviewsCount;

  /// Keeps the averageRating value available to this object.
  /// العربية: يخزن القيمة `averageRating`.
  final double averageRating;

  /// Keeps the onViewAll value available to this object.
  /// العربية: يخزن القيمة `onViewAll`.
  final VoidCallback onViewAll;

  /// Constructs the ReviewsSummaryWidget value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `ReviewsSummaryWidget`.
  const ReviewsSummaryWidget({
    super.key,
    required this.propertyId,
    required this.reviewsCount,
    required this.averageRating,
    required this.onViewAll,
  });

  /// Builds the state object for this widget used by this feature.
  /// العربية: ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<ReviewsSummaryWidget> createState() => _ReviewsSummaryWidgetState();
}

/// Describes the state for `ReviewsSummaryWidgetState`.
/// العربية: يمثل الحالة الخاصة بـ `ReviewsSummaryWidgetState`.
class _ReviewsSummaryWidgetState extends State<ReviewsSummaryWidget>
    with TickerProviderStateMixin {
  /// Keeps the chartController value available to this object.
  /// العربية: يخزن القيمة `chartController`.
  late AnimationController _chartController;

  /// Keeps the pulseController value available to this object.
  /// العربية: يخزن القيمة `pulseController`.
  late AnimationController _pulseController;

  /// Keeps the starController value available to this object.
  /// العربية: يخزن القيمة `starController`.
  late AnimationController _starController;

  /// Keeps the glowController value available to this object.
  /// العربية: يخزن القيمة `glowController`.
  late AnimationController _glowController;

  /// Keeps the chartAnimation value available to this object.
  /// العربية: يخزن القيمة `chartAnimation`.
  late Animation<double> _chartAnimation;

  /// Keeps the pulseAnimation value available to this object.
  /// العربية: يخزن القيمة `pulseAnimation`.
  late Animation<double> _pulseAnimation;

  /// Keeps the starAnimation value available to this object.
  /// العربية: يخزن القيمة `starAnimation`.
  late Animation<double> _starAnimation;

  /// Keeps the stars value available to this object.
  /// العربية: يخزن القيمة `stars`.
  final List<_AnimatedStar> _stars = [];

  /// Initializes the state for this widget.
  /// العربية: يهيئ الحالة الخاصة بهذا العنصر.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateStars();
    _startAnimations();
  }

  /// Initializes the animations.
  /// العربية: يهيئ animations.
  void _initializeAnimations() {
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _starController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _starAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_starController);
  }

  /// Generates the stars.
  /// العربية: ينشئ stars.
  void _generateStars() {
    for (int i = 0; i < 10; i++) {
      _stars.add(_AnimatedStar());
    }
  }

  /// Starts the animations.
  /// العربية: يبدأ animations.
  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _chartController.forward();
      }
    });
  }

  /// Releases the resources used by this instance.
  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _chartController.dispose();
    _pulseController.dispose();
    _starController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  /// Builds the widget tree for this component.
  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ReviewBloc>()
        ..add(GetPropertyReviewsSummaryEvent(propertyId: widget.propertyId)),
      child: BlocBuilder<ReviewBloc, ReviewState>(
        builder: (context, state) {
          if (state is ReviewLoading || state is ReviewInitial) {
            return SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                ),
              ),
            );
          }

          if (state is ReviewError) {
            return _buildErrorState(state.message);
          }

          if (state is ReviewsSummaryLoaded) {
            final summary = state.summary;
            if (summary.totalReviews == 0) {
              return _buildEmptyState();
            }
            return _buildContent(summary);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Builds the content.
  /// العربية: يبني content.
  Widget _buildContent(ReviewsSummary summary) {
    return Stack(
      children: [
        _buildAnimatedBackground(),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFuturisticRatingSummary(summary),
              const SizedBox(height: 16),
              _buildFuturisticRatingBars(summary),
              const SizedBox(height: 16),
              _buildFuturisticRecentReviews(summary),
              const SizedBox(height: 12),
              _buildViewAllButton(),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the error state.
  /// العربية: يبني error state.
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Builds the animated background.
  /// العربية: يبني animated background.
  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _starAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _StarBackgroundPainter(
              stars: _stars,
              animationValue: _starAnimation.value,
            ),
          );
        },
      ),
    );
  }

  /// Builds the empty state.
  /// العربية: يبني empty state.
  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppTheme.warning.withOpacity(0.2),
                    AppTheme.warning.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _starAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _starAnimation.value,
                        child: Icon(
                          Icons.star_outline,
                          size: 48,
                          color: AppTheme.warning.withOpacity(0.5),
                        ),
                      );
                    },
                  ),
                  Icon(
                    Icons.rate_review_outlined,
                    size: 28,
                    color: AppTheme.warning,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppTheme.warning, AppTheme.warning.withOpacity(0.7)],
              ).createShader(bounds),
              child: Text(
                'لا توجد تقييمات بعد',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'كن أول من يقيم هذا العقار',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            _buildGlowingButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
              },
              gradient: LinearGradient(
                colors: [AppTheme.warning, AppTheme.warning.withOpacity(0.7)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'اكتب أول تقييم',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the futuristic rating summary.
  /// العربية: يبني futuristic rating summary.
  Widget _buildFuturisticRatingSummary(ReviewsSummary summary) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.warning.withOpacity(0.15),
                  AppTheme.warning.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.warning.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Row(
                  children: [
                    _buildRatingCircle(summary),
                    const SizedBox(width: 16),
                    Expanded(child: _buildRatingCategories(summary)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the rating circle.
  /// العربية: يبني rating circle.
  Widget _buildRatingCircle(ReviewsSummary summary) {
    final ratingColor = _getRatingColor(summary.averageRating);
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            ratingColor,
            ratingColor.withOpacity(0.5),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ratingColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _starAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: _CircleStarsPainter(
                  rotation: _starAnimation.value,
                  color: Colors.white.withOpacity(0.2),
                ),
                size: const Size(90, 90),
              );
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white.withOpacity(0.9)],
                ).createShader(bounds),
                child: Text(
                  summary.averageRating.toStringAsFixed(1),
                  style: AppTextStyles.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Icon(
                    index < widget.averageRating.round()
                        ? Icons.star
                        : Icons.star_outline,
                    size: 10,
                    color: Colors.white,
                  );
                }),
              ),
              const SizedBox(height: 2),
              Text(
                '${summary.totalReviews} تقييم',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the rating categories.
  /// العربية: يبني rating categories.
  Widget _buildRatingCategories(ReviewsSummary summary) {
    final sampleReviews = _getSampleReviews(summary);

    if (sampleReviews.isEmpty) {
      return const SizedBox.shrink();
    }

    final cleanlinessAvg =
        _calculateAverage(sampleReviews, (r) => r.cleanliness.toDouble());
    final serviceAvg =
        _calculateAverage(sampleReviews, (r) => r.service.toDouble());
    final locationAvg =
        _calculateAverage(sampleReviews, (r) => r.location.toDouble());
    final valueAvg =
        _calculateAverage(sampleReviews, (r) => r.value.toDouble());

    final categories = [
      {
        'label': 'النظافة',
        'rating': cleanlinessAvg,
        'icon': Icons.cleaning_services,
      },
      {
        'label': 'الخدمة',
        'rating': serviceAvg,
        'icon': Icons.room_service,
      },
      {
        'label': 'الموقع',
        'rating': locationAvg,
        'icon': Icons.location_on,
      },
      {
        'label': 'القيمة',
        'rating': valueAvg,
        'icon': Icons.attach_money,
      },
    ];

    return Column(
      children: categories.map((category) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildFuturisticRatingCategory(
            category['label'] as String,
            (category['rating'] as double).clamp(0, 5),
            category['icon'] as IconData,
          ),
        );
      }).toList(),
    );
  }

  /// Builds the futuristic rating category.
  /// العربية: يبني futuristic rating category.
  Widget _buildFuturisticRatingCategory(
      String label, double rating, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 12,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 45,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return Container(
                    height: 6,
                    width: (MediaQuery.of(context).size.width - 180) *
                        (rating / 5) *
                        _chartAnimation.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getRatingColor(rating),
                          _getRatingColor(rating).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Builds the futuristic rating bars.
  /// العربية: يبني futuristic rating bars.
  Widget _buildFuturisticRatingBars(ReviewsSummary summary) {
    final ratingDistribution = List.generate(5, (index) {
      final stars = 5 - index;
      final count = summary.ratingDistribution[stars] ?? 0;
      final percentage = (summary.ratingPercentages[stars] ?? 0) / 100.0;
      return {
        'stars': stars,
        'count': count,
        'percentage': percentage,
      };
    });

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.6),
            AppTheme.darkCard.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'توزيع التقييمات',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...ratingDistribution.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;

            return AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildRatingBar(
                    data['stars'] as int,
                    data['count'] as int,
                    data['percentage'] as double,
                    index * 50,
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  /// Builds the rating bar.
  /// العربية: يبني rating bar.
  Widget _buildRatingBar(int stars, int count, double percentage, int delay) {
    return Row(
      children: [
        SizedBox(
          width: 35,
          child: Row(
            children: [
              Text(
                stars.toString(),
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.star,
                size: 10,
                color: AppTheme.warning,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  final width = (MediaQuery.of(context).size.width - 120) *
                      percentage *
                      _chartAnimation.value;
                  final barColor = _getRatingColor(stars.toDouble());

                  return Container(
                    height: 8,
                    width: width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          barColor,
                          barColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            count.toString(),
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  /// Builds the futuristic recent reviews.
  /// العربية: يبني futuristic recent reviews.
  Widget _buildFuturisticRecentReviews(ReviewsSummary summary) {
    final recentReviews = summary.latestReviews;

    if (recentReviews.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.message,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'أحدث التقييمات',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...recentReviews.map(
          (review) => _buildFuturisticMiniReviewCard(
            userName: review.userName,
            rating: review.rating,
            date: _formatReviewDate(review.createdAt),
            comment: review.comment,
            avatar: review.userName.isNotEmpty
                ? review.userName[0].toUpperCase()
                : '?',
          ),
        ),
      ],
    );
  }

  /// Builds the futuristic mini review card.
  /// العربية: يبني futuristic mini review card.
  Widget _buildFuturisticMiniReviewCard({
    required String userName,
    required double rating,
    required String date,
    required String comment,
    required String avatar,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    avatar,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      date,
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getRatingColor(rating),
                      _getRatingColor(rating).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      rating.toStringAsFixed(1),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textLight,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Builds the view all button.
  /// العربية: يبني view all button.
  Widget _buildViewAllButton() {
    return Center(
      child: _buildGlowingButton(
        onPressed: widget.onViewAll,
        gradient: AppTheme.primaryGradient,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'عرض جميع التقييمات',
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.reviewsCount.toString(),
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward,
              size: 14,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the glowing button.
  /// العربية: يبني glowing button.
  Widget _buildGlowingButton({
    required VoidCallback onPressed,
    required Widget child,
    required Gradient gradient,
  }) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: gradient.colors[0]
                    .withOpacity(0.25 + _glowController.value * 0.15),
                blurRadius: 15 + _glowController.value * 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                onPressed();
                HapticFeedback.mediumImpact();
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Exposes the rating color.
  /// العربية: يعيد rating color.
  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return AppTheme.success;
    if (rating >= 3.5) return AppTheme.warning;
    if (rating >= 2.5) return Colors.orange;
    return AppTheme.error;
  }

  /// Exposes the sample reviews.
  /// العربية: يعيد sample reviews.
  List<Review> _getSampleReviews(ReviewsSummary summary) {
    final Map<String, Review> byId = {};

    for (final review in summary.latestReviews) {
      byId[review.id] = review;
    }

    for (final review in summary.topReviews) {
      byId[review.id] = review;
    }

    return byId.values.toList();
  }

  /// Processes the calculateAverage flow and maps it into the property feature behavior.
  /// العربية: يعالج `calculateAverage`.
  double _calculateAverage(
    List<Review> reviews,
    double Function(Review) selector,
  ) {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<double>(0, (sum, r) => sum + selector(r));
    return total / reviews.length;
  }

  /// Formats the review date.
  /// العربية: ينسق review date.
  String _formatReviewDate(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);

    if (diff.inDays >= 1 && diff.inDays <= 7) {
      return 'قبل ${diff.inDays} يوم';
    }

    if (diff.inHours >= 1 && diff.inDays < 1) {
      return 'قبل ${diff.inHours} ساعة';
    }

    if (diff.inMinutes >= 1 && diff.inHours < 1) {
      return 'قبل ${diff.inMinutes} دقيقة';
    }

    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}/$month/$day';
  }
}

// باقي الكلاسات بأحجام أصغر
/// Describes the AnimatedStar type used in the property feature.
/// العربية: يمثل `AnimatedStar`.
class _AnimatedStar {
  /// Keeps the x value available to this object.
  /// العربية: يخزن القيمة `x`.
  late double x;

  /// Keeps the y value available to this object.
  /// العربية: يخزن القيمة `y`.
  late double y;

  /// Keeps the size value available to this object.
  /// العربية: يخزن القيمة `size`.
  late double size;

  /// Keeps the speed value available to this object.
  /// العربية: يخزن القيمة `speed`.
  late double speed;

  /// Keeps the opacity value available to this object.
  /// العربية: يخزن القيمة `opacity`.
  late double opacity;

  /// Constructs the AnimatedStar value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `AnimatedStar`.
  _AnimatedStar() {
    reset();
  }

  /// Processes the reset flow and maps it into the property feature behavior.
  /// العربية: يعالج `reset`.
  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    size = math.Random().nextDouble() * 2 + 0.5;
    speed = math.Random().nextDouble() * 0.0005 + 0.0002;
    opacity = math.Random().nextDouble() * 0.2 + 0.05;
  }

  /// Updates the required operation for `update`.
  /// العربية: يحدّث العملية المطلوبة لـ `update`.
  void update() {
    y -= speed;
    if (y < 0) {
      y = 1.0;
      x = math.Random().nextDouble();
    }
  }
}

/// Describes the StarBackgroundPainter type used in the property feature.
/// العربية: يمثل `StarBackgroundPainter`.
class _StarBackgroundPainter extends CustomPainter {
  /// Keeps the stars value available to this object.
  /// العربية: يخزن القيمة `stars`.
  final List<_AnimatedStar> stars;

  /// Keeps the animationValue value available to this object.
  /// العربية: يخزن القيمة `animationValue`.
  final double animationValue;

  /// Constructs the StarBackgroundPainter value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `StarBackgroundPainter`.
  _StarBackgroundPainter({
    required this.stars,
    required this.animationValue,
  });

  /// Processes the paint flow and maps it into the property feature behavior.
  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      star.update();

      final paint = Paint()
        ..color = AppTheme.warning.withOpacity(star.opacity)
        ..style = PaintingStyle.fill;

      _drawStar(
        canvas,
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  /// Processes the drawStar flow and maps it into the property feature behavior.
  /// العربية: يعالج `drawStar`.
  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const spikes = 5;
    const step = math.pi / spikes;

    for (int i = 0; i < spikes * 2; i++) {
      final r = i.isEven ? radius : radius / 2;
      final angle = i * step;
      final x = center.dx + r * math.cos(angle - math.pi / 2);
      final y = center.dy + r * math.sin(angle - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  /// Processes the shouldRepaint flow and maps it into the property feature behavior.
  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Describes the CircleStarsPainter type used in the property feature.
/// العربية: يمثل `CircleStarsPainter`.
class _CircleStarsPainter extends CustomPainter {
  /// Keeps the rotation value available to this object.
  /// العربية: يخزن القيمة `rotation`.
  final double rotation;

  /// Keeps the color value available to this object.
  /// العربية: يخزن القيمة `color`.
  final Color color;

  /// Constructs the CircleStarsPainter value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `CircleStarsPainter`.
  _CircleStarsPainter({
    required this.rotation,
    required this.color,
  });

  /// Processes the paint flow and maps it into the property feature behavior.
  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 72) * math.pi / 180 + rotation;
      final starCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      _drawStar(canvas, starCenter, 6, Paint()..color = color);
    }
  }

  /// Processes the drawStar flow and maps it into the property feature behavior.
  /// العربية: يعالج `drawStar`.
  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const spikes = 5;
    const step = math.pi / spikes;

    for (int i = 0; i < spikes * 2; i++) {
      final r = i.isEven ? radius : radius / 2;
      final angle = i * step;
      final x = center.dx + r * math.cos(angle - math.pi / 2);
      final y = center.dy + r * math.sin(angle - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  /// Processes the shouldRepaint flow and maps it into the property feature behavior.
  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
