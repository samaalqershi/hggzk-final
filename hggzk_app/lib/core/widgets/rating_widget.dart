import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

/// يعرض تقييم النجوم في العرض الثابت أو التفاعلي حسب السياق.
/// Renders a star rating in either read-only or interactive mode.
class RatingWidget extends StatelessWidget {
  /// قيمة التقييم الحالية التي تحدد عدد النجوم المضيئة.
  /// Current rating value used to determine the filled stars.
  final double rating;

  /// عدد المراجعات الذي يعرض مع التقييم عندما يكون متاحًا.
  /// Review count shown next to the rating when available.
  final int? reviewCount;

  /// حجم النجمة المستخدم في القراءة أو التفاعل.
  /// Star size used for both display and interaction.
  final double starSize;

  /// يتحكم في إظهار القيمة الرقمية بجانب النجوم.
  /// Controls whether the numeric rating label is shown.
  final bool showLabel;

  /// يحدد ما إذا كان المستخدم يستطيع النقر لتغيير التقييم.
  /// Controls whether the user can tap to change the rating.
  final bool interactive;

  /// يستقبل التغيير الناتج عن النقر في الوضع التفاعلي.
  /// Receives changes from the interactive mode when a star is tapped.
  final Function(double)? onRatingChanged;

  /// لون النجوم الممتلئة عندما لا يراد استخدام لون الثيم الافتراضي.
  /// Color for filled stars when the default theme color should be overridden.
  final Color? activeColor;

  /// لون النجوم الفارغة أو غير النشطة.
  /// Color for empty or inactive stars.
  final Color? inactiveColor;

  /// محاذاة صف النجوم وما يجاورها من ملصقات.
  /// Alignment for the row that holds stars and labels.
  final MainAxisAlignment alignment;

  /// يتحكم في إظهار عدد المراجعات بجانب التقييم.
  /// Controls whether the review count appears next to the rating.
  final bool showReviewCount;

  /// ينشئ مكوّن التقييم بما يناسب العرض الثابت أو إدخال المستخدم.
  /// Creates the rating widget for read-only or interactive usage.
  const RatingWidget({
    super.key,
    required this.rating,
    this.reviewCount,
    this.starSize = 20,
    this.showLabel = true,
    this.interactive = false,
    this.onRatingChanged,
    this.activeColor,
    this.inactiveColor,
    this.alignment = MainAxisAlignment.start,
    this.showReviewCount = true,
  });

  /// يبني النجوم والملصق وعدد المراجعات حسب إعدادات العرض.
  /// Builds the stars, label, and review count according to the display settings.
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (interactive) _buildInteractiveStars() else _buildStaticStars(),
        if (showLabel) ...[
          const SizedBox(width: AppDimensions.spacingXs),
          _buildRatingLabel(),
        ],
        if (showReviewCount && reviewCount != null) ...[
          const SizedBox(width: AppDimensions.spacingXs),
          _buildReviewCount(),
        ],
      ],
    );
  }

  /// يعرض النجوم كما هي عندما يكون التقييم للقراءة فقط.
  /// Renders the stars as a non-interactive read-only row.
  Widget _buildStaticStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return _buildStar(index);
      }),
    );
  }

  /// يضع طبقة نقر فوق النجوم عندما يحتاج المستخدم إلى إدخال تقييم.
  /// Wraps the stars with tap handling when the user should provide a rating.
  Widget _buildInteractiveStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            if (onRatingChanged != null) {
              onRatingChanged!(index + 1.0);
            }
          },
          child: _buildStar(index),
        );
      }),
    );
  }

  /// يختار شكل النجمة ولونها وفقًا للقيمة الحالية.
  /// Chooses the star shape and color based on the current rating.
  Widget _buildStar(int index) {
    final double starValue = index + 1.0;
    final bool isFilled = rating >= starValue;
    final bool isHalfFilled = rating > index && rating < starValue;

    IconData iconData;
    Color color;

    if (isFilled) {
      iconData = Icons.star_rounded;
      color = activeColor ?? AppTheme.warning;
    } else if (isHalfFilled) {
      iconData = Icons.star_half_rounded;
      color = activeColor ?? AppTheme.warning;
    } else {
      iconData = Icons.star_outline_rounded;
      color = inactiveColor ?? AppTheme.darkBorder;
    }

    return Icon(
      iconData,
      size: starSize,
      color: color,
    );
  }

  /// يعرض القيمة الرقمية داخل كبسولة صغيرة لتسهيل القراءة السريعة.
  /// Displays the numeric rating inside a small label for quick scanning.
  Widget _buildRatingLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: AppDimensions.paddingXSmall,
      ),
      decoration: BoxDecoration(
        color: _getRatingColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXs),
      ),
      child: Text(
        rating.toStringAsFixed(1),
        style: AppTextStyles.ratingMedium.copyWith(
          color: _getRatingColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// يعرض عدد المراجعات عندما يكون جزءًا من سياق الواجهة.
  /// Shows the review count when the screen wants to surface it.
  Widget _buildReviewCount() {
    return Text(
      '($reviewCount)',
      style: AppTextStyles.caption.copyWith(
        color: AppTheme.textMuted,
      ),
    );
  }

  /// يختار لون الملصق بناءً على قوة التقييم الحالي.
  /// Chooses the label color from the current rating band.
  Color _getRatingColor() {
    if (rating >= 4.5) {
      return AppTheme.success;
    } else if (rating >= 3.5) {
      return AppTheme.warning;
    } else if (rating >= 2.5) {
      return AppTheme.warning;
    } else {
      return AppTheme.error;
    }
  }
}

/// عنصر إدخال يسمح للمستخدم باختيار تقييم نجمي من 1 إلى 5.
/// Interactive star input that lets the user choose a 1-to-5 rating.
class RatingStarsInput extends StatefulWidget {
  /// القيمة الابتدائية التي يظهر بها الإدخال قبل أي تفاعل.
  /// Initial value shown before the user starts tapping.
  final double initialRating;

  /// يستقبل القيمة النهائية بعد أن يختار المستخدم النجوم.
  /// Receives the final value when the user selects stars.
  final Function(double) onRatingChanged;

  /// حجم النجوم في وضع الإدخال.
  /// Star size used in the input mode.
  final double starSize;

  /// لون النجوم الممتلئة أثناء التفاعل.
  /// Color for filled stars while the user interacts.
  final Color? activeColor;

  /// لون النجوم غير المختارة.
  /// Color for stars that remain unselected.
  final Color? inactiveColor;

  /// يسمح باختيار أنصاف النجوم عندما تكون الواجهة تحتاج دقة أعلى.
  /// Allows half-star selection when finer input is needed.
  final bool allowHalfRating;

  /// ينشئ عنصر الإدخال مع القيمة الابتدائية ومعالج التغيير.
  /// Creates the input widget with an initial value and change handler.
  const RatingStarsInput({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.starSize = 32,
    this.activeColor,
    this.inactiveColor,
    this.allowHalfRating = false,
  });

  /// ينشئ كائن الحالة الذي يحتفظ بالقيمة المختارة أثناء التفاعل.
  /// Creates the state object that keeps the selected value while the user taps.
  @override
  State<RatingStarsInput> createState() => _RatingStarsInputState();
}

/// يحتفظ بالقيمة المختارة ويحوّل نقرات المستخدم إلى تقييم فعلي.
/// State holder that converts taps into a concrete rating value.
class _RatingStarsInputState extends State<RatingStarsInput> {
  /// آخر قيمة اختارها المستخدم داخل هذا الإدخال.
  /// Latest rating selected by the user in this input.
  late double _currentRating;

  /// يبدأ الحالة بالقيمة الابتدائية التي مررها المستدعي.
  /// Initializes the state from the rating passed by the caller.
  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  /// يبني صف النجوم التفاعلي ويترجم مكان النقر إلى قيمة عددية.
  /// Builds the interactive star row and turns taps into a selected value.
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTapDown: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPosition = box.globalToLocal(details.globalPosition);
            final starWidth = widget.starSize;
            final starIndex = localPosition.dx / starWidth;

            setState(() {
              if (widget.allowHalfRating) {
                _currentRating = (starIndex * 2).round() / 2;
              } else {
                _currentRating = starIndex.ceil().toDouble();
              }
              _currentRating = _currentRating.clamp(0.5, 5.0);
            });

            widget.onRatingChanged(_currentRating);
          },
          child: Icon(
            _getIconForIndex(index),
            size: widget.starSize,
            color: _getColorForIndex(index),
          ),
        );
      }),
    );
  }

  /// Exposes the icon for index so callers can read it without depending on implementation details.
  /// العربية: يعيد icon for index.
  IconData _getIconForIndex(int index) {
    final double starValue = index + 1.0;

    if (_currentRating >= starValue) {
      return Icons.star_rounded;
    } else if (_currentRating > index && _currentRating < starValue) {
      return Icons.star_half_rounded;
    } else {
      return Icons.star_outline_rounded;
    }
  }

  /// Exposes the color for index so callers can read it without depending on implementation details.
  /// العربية: يعيد color for index.
  Color _getColorForIndex(int index) {
    final double starValue = index + 1.0;

    if (_currentRating >= starValue) {
      return widget.activeColor ?? AppTheme.warning;
    } else {
      return widget.inactiveColor ?? AppTheme.darkBorder;
    }
  }
}
