import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'rating_selector_widget.dart';

/// Collects a structured property review with ratings, text, and media.
/// يجمع مراجعة منظمة للعقار تشمل التقييمات والنص والصور.
///
/// The widget keeps the review payload aligned with the bloc contract so the
/// screen can submit a complete review without guessing default values.
/// يطابق هذا العنصر حمولة المراجعة مع عقد الـ bloc حتى ترسل الشاشة مراجعة
/// مكتملة من دون افتراض قيم افتراضية.
class ReviewFormWidget extends StatefulWidget {
  /// Receives the final ratings, comment text, and optional image paths.
  /// يستقبل التقييمات النهائية، ونص التعليق، ومسارات الصور الاختيارية.
  final Function(Map<String, int> ratings, String comment, List<String>? images)
      onSubmit;

  /// Builds the review form shown on the write-review screen.
  /// ينشئ نموذج التقييم الظاهر في شاشة كتابة المراجعة.
  const ReviewFormWidget({
    super.key,
    required this.onSubmit,
  });

  /// Builds the interactive state that tracks ratings and comment changes.
  /// ينشئ الحالة التفاعلية التي تتابع تغيّر التقييمات والتعليق.
  @override
  State<ReviewFormWidget> createState() => _ReviewFormWidgetState();
}

/// Maintains the draft review data and the animated summary card.
/// يحفظ بيانات المراجعة قيد التحرير وبطاقة الملخص المتحركة.
class _ReviewFormWidgetState extends State<ReviewFormWidget>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final Map<String, int> _ratings = {
    'cleanliness': 0,
    'service': 0,
    'location': 0,
    'value': 0,
  };

  /// Tracks whether the reviewer recommends the property overall.
  /// يحدد ما إذا كان المراجع يوصي بالعقار بشكل عام.
  bool _isRecommended = true;

  /// Drives the subtle glow around the summary banner.
  /// يقود التوهج الخفيف حول شريط الملخص.
  late AnimationController _glowController;

  /// Softens the highlight pulse used in the summary banner.
  /// يضبط نبضة التوهج الظاهرة في شريط الملخص.
  late Animation<double> _glowAnimation;

  /// Hooks the comment listener and starts the repeating glow animation.
  /// يربط مستمع التعليق ويبدأ حركة التوهج المتكررة.
  @override
  void initState() {
    super.initState();
    _commentController.addListener(_onCommentChanged);
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
  }

  /// Releases the text controller and animation resources.
  /// يحرر متحكم النص وموارد الحركة.
  @override
  void dispose() {
    _commentController.removeListener(_onCommentChanged);
    _commentController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  /// Refreshes the form so helper text and submit state stay accurate.
  /// يحدّث النموذج ليبقى النص المساعد وحالة الإرسال دقيقين.
  void _onCommentChanged() {
    if (!mounted) return;
    setState(() {});
  }

  /// Builds the form shell and its logical review sections.
  /// يبني هيكل النموذج وأقسام المراجعة المنطقية.
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallExperience(),
            const Divider(height: 1),
            _buildRatingSection(),
            const Divider(height: 1),
            _buildCommentSection(),
            const Divider(height: 1),
            _buildRecommendationSection(),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// Builds the summary block that seeds the detailed rating controls.
  /// يبني كتلة الملخص التي تهيئ عناصر التقييم التفصيلية.
  Widget _buildOverallExperience() {
    final overallRating = _getOverallRating();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.warning.withOpacity(0.16),
              AppTheme.warning.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
          border: Border.all(
            color: AppTheme.warning.withOpacity(0.3),
            width: 0.7,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.warning,
                          AppTheme.warning.withOpacity(0.6),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        overallRating > 0 ? overallRating.toString() : '-',
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(
                            'reviews.overallExperience',
                          ),
                          style: AppTextStyles.h2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(
                          context.tr('reviews.overallHint'),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingSm),
                        RatingSelectorWidget(
                          rating: overallRating,
                          starSize: 28,
                          alignment: MainAxisAlignment.start,
                          onRatingChanged: (value) {
                            setState(() {
                              _ratings['cleanliness'] = value;
                              _ratings['service'] = value;
                              _ratings['location'] = value;
                              _ratings['value'] = value;
                            });
                          },
                        ),
                      ],
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

  /// Builds the category-by-category rating controls.
  /// يبني عناصر التقييم حسب كل فئة.
  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(
              'reviews.rateAspects',
            ),
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _buildRatingItem(
            context.tr('reviews.cleanliness'),
            'cleanliness',
            Icons.cleaning_services_outlined,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          _buildRatingItem(
            context.tr('reviews.service'),
            'service',
            Icons.room_service_outlined,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          _buildRatingItem(
            context.tr('reviews.location'),
            'location',
            Icons.location_on_outlined,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          _buildRatingItem(
            context.tr('reviews.value'),
            'value',
            Icons.attach_money_outlined,
          ),
        ],
      ),
    );
  }

  /// Builds one detailed rating control and its progress indicator.
  /// يبني عنصر تقييم مفصلًا مع مؤشر التقدم الخاص به.
  Widget _buildRatingItem(String label, String key, IconData icon) {
    final rating = _ratings[key]!;
    final progress = rating / 5;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withOpacity(0.9),
            AppTheme.darkCard.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.6),
          width: 0.7,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            rating > 0 ? rating.toString() : '-',
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Stack(
                        children: [
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.darkBorder.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0, 1),
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _getCategoryColor(key),
                                    _getCategoryColor(key).withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      RatingSelectorWidget(
                        rating: rating,
                        starSize: 20,
                        alignment: MainAxisAlignment.start,
                        onRatingChanged: (newRating) {
                          setState(() {
                            _ratings[key] = newRating;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the free-text review area and its validation rules.
  /// يبني مساحة التعليق النصي وقواعد التحقق الخاصة بها.
  Widget _buildCommentSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(
              'reviews.commentSectionTitle',
            ),
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          TextFormField(
            controller: _commentController,
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: context.tr(
                'reviews.commentHint',
              ),
              filled: true,
              fillColor: AppTheme.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusMd,
                ),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusMd,
                ),
                borderSide: BorderSide(
                  color: AppTheme.primaryBlue,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.tr(
                  'reviews.commentRequired',
                );
              }
              if (value.length < 10) {
                return context.tr(
                  'reviews.commentMinLength',
                );
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Builds the yes-or-no recommendation toggle.
  /// يبني مفتاح التوصية بنعم أو لا.
  Widget _buildRecommendationSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.tr(
                'reviews.recommendThisPlace',
              ),
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Switch(
            value: _isRecommended,
            onChanged: (value) {
              setState(() {
                _isRecommended = value;
              });
            },
            activeColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  /// Builds the submit action and its readiness styling.
  /// يبني فعل الإرسال وأسلوب الجاهزية الخاص به.
  Widget _buildSubmitButton() {
    final canSubmit = _canSubmit();

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, _) {
          final baseGradient = AppTheme.primaryGradient;
          final shadowColor = baseGradient.colors.first
              .withOpacity(0.25 + (_glowAnimation.value * 0.2));

          return Opacity(
            opacity: canSubmit ? 1.0 : 0.6,
            child: Container(
              decoration: BoxDecoration(
                gradient: baseGradient,
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusMd,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 14 + (_glowAnimation.value * 6),
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusMd,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusMd,
                  ),
                  onTap: canSubmit ? _submitReview : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingMedium,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.send_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: AppDimensions.spacingSm),
                        Text(
                          context.tr(
                            'reviews.submitReview',
                          ),
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Exposes whether the form contains enough data to submit a review.
  /// يعيد ما إذا كان النموذج يحتوي على بيانات كافية للإرسال.
  bool _canSubmit() {
    return _ratings.values.every((rating) => rating > 0) &&
        _commentController.text.isNotEmpty;
  }

  /// Averages the category ratings into the summary score shown at the top.
  /// يحسب متوسط تقييمات الفئات ليظهر كدرجة عامة في الأعلى.
  int _getOverallRating() {
    final total = _ratings.values.fold(0, (sum, rating) => sum + rating);
    if (total == 0) return 0;
    return (total / _ratings.length).round();
  }

  /// Sends the collected review payload to the parent screen.
  /// يرسل حمولة المراجعة المجمعة إلى الشاشة الأب.
  void _submitReview() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _ratings,
        _commentController.text,
        null,
      );
    }
  }

  /// Maps each category key to its accent color in the UI.
  /// يربط كل مفتاح فئة بلونه البارز داخل الواجهة.
  Color _getCategoryColor(String key) {
    switch (key) {
      case 'cleanliness':
        return AppTheme.primaryBlue;
      case 'service':
        return AppTheme.success;
      case 'location':
        return AppTheme.info;
      case 'value':
        return AppTheme.warning;
      default:
        return AppTheme.primaryBlue;
    }
  }
}
