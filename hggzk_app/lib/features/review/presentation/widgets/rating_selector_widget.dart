import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Lets the user choose a star rating while keeping the visual state compact.
/// يتيح للمستخدم اختيار تقييم نجوم مع الحفاظ على واجهة مضغوطة.
class RatingSelectorWidget extends StatelessWidget {
  /// Currently selected rating value.
  /// قيمة التقييم المختارة حاليًا.
  final int rating;

  /// Notifies the parent when the user selects a different star count.
  /// يُبلغ الأب عندما يختار المستخدم عدد نجوم مختلفًا.
  final Function(int) onRatingChanged;

  /// Controls the size of each star icon.
  /// يتحكم في حجم أيقونة كل نجمة.
  final double starSize;

  /// Aligns the row inside its horizontal scroll container.
  /// يحدد محاذاة الصف داخل الحاوية الأفقية القابلة للتمرير.
  final MainAxisAlignment alignment;

  /// Builds the interactive star row used by review forms and cards.
  /// ينشئ صف النجوم التفاعلي المستخدم في نماذج المراجعة والبطاقات.
  const RatingSelectorWidget({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starSize = 28,
    this.alignment = MainAxisAlignment.start,
  });

  /// Renders the tappable stars and highlights the selected range.
  /// يرسم النجوم القابلة للنقر ويبرز النطاق المحدد.
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final starValue = index + 1;
          final isSelected = rating >= starValue;

          return GestureDetector(
            onTap: () => onRatingChanged(starValue),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingXs / 2,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color:
                      !isSelected ? AppTheme.darkCard.withOpacity(0.7) : null,
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : AppTheme.darkBorder.withOpacity(0.6),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.warning.withOpacity(0.35),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: starSize,
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
