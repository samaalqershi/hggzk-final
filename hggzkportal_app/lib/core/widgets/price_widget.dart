import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

/// يعرض السعر بمرونة عبر عدة أوضاع مثل السعر العادي أو المخفض أو المفصل.
/// Renders prices in multiple layouts such as normal, discounted, compact, or detailed views.
class PriceWidget extends StatelessWidget {
  /// السعر الحالي الذي تريد الواجهة عرضه.
  /// The current price value shown by the widget.
  final double price;

  /// السعر الأصلي عندما نحتاج لإظهار الخصم أو المقارنة.
  /// Original price used when a discount or comparison is needed.
  final double? originalPrice;

  /// رمز العملة المعروض بجانب السعر.
  /// Currency code shown alongside the price.
  final String currency;

  /// يحدد أسلوب العرض المناسب للسياق الحالي.
  /// Chooses the price layout that best fits the current context.
  final PriceDisplayType displayType;

  /// نمط نصي اختياري للسعر الأساسي.
  /// Optional text style for the main price.
  final TextStyle? priceStyle;

  /// نمط نصي اختياري للسعر الأصلي عندما يظهر بجانب السعر الحالي.
  /// Optional text style for the original price when shown.
  final TextStyle? originalPriceStyle;

  /// نمط نصي اختياري لرمز العملة أو النص المرافق.
  /// Optional text style for the currency label or accompanying text.
  final TextStyle? currencyStyle;

  /// فترة زمنية اختيارية مثل الليلة أو الشهر.
  /// Optional period label such as night or month.
  final String? period;

  /// يحدد ما إذا كان رمز العملة سيظهر أم لا.
  /// Controls whether the currency symbol is rendered.
  final bool showCurrencySymbol;

  /// محاذاة صف السعر داخل الحاوية.
  /// Row alignment used for the price layout.
  final MainAxisAlignment alignment;

  /// يفعّل عدًا بصريًا من الصفر إلى السعر النهائي.
  /// Enables a visual count-up animation toward the final price.
  final bool animate;

  /// Creates a price display that adapts to plain, discounted, and detailed views.
  /// ينشئ عرض سعر يتكيف مع الأوضاع العادية والمخفضة والمفصلة.
  const PriceWidget({
    super.key,
    required this.price,
    this.originalPrice,
    this.currency = 'YER',
    this.displayType = PriceDisplayType.normal,
    this.priceStyle,
    this.originalPriceStyle,
    this.currencyStyle,
    this.period,
    this.showCurrencySymbol = true,
    this.alignment = MainAxisAlignment.start,
    this.animate = false,
  });

  /// Chooses the requested layout variant and renders the price accordingly.
  /// يختار نمط العرض المطلوب ويظهر السعر بناءً عليه.
  @override
  Widget build(BuildContext context) {
    switch (displayType) {
      case PriceDisplayType.normal:
        return _buildNormalPrice(context);
      case PriceDisplayType.discount:
        return _buildDiscountPrice(context);
      case PriceDisplayType.compact:
        return _buildCompactPrice(context);
      case PriceDisplayType.detailed:
        return _buildDetailedPrice(context);
    }
  }

  /// Renders the common price row used across cards and details pages.
  /// يعرض صف السعر الشائع المستخدم في البطاقات وصفحات التفاصيل.
  Widget _buildNormalPrice(BuildContext context) {
    final Widget priceWidget = Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatPrice(price),
          style: priceStyle ?? AppTextStyles.heading1,
        ),
        if (showCurrencySymbol) ...[
          const SizedBox(width: AppDimensions.spaceXSmall),
          Text(
            currency,
            style: currencyStyle ??
                AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.normal,
                ),
          ),
        ],
        if (period != null) ...[
          const SizedBox(width: AppDimensions.spaceXSmall),
          Text(
            '/ $period',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ],
    );

    if (animate) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: price),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Row(
            mainAxisAlignment: alignment,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatPrice(value),
                style: priceStyle ?? AppTextStyles.heading1,
              ),
              if (showCurrencySymbol) ...[
                const SizedBox(width: AppDimensions.spaceXSmall),
                Text(
                  currency,
                  style: currencyStyle ??
                      AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                ),
              ],
            ],
          );
        },
      );
    }

    return priceWidget;
  }
  Widget _buildDiscountPrice(BuildContext context) {
    if (originalPrice == null || originalPrice == price) {
      return _buildNormalPrice(context);
    }

    final double discountPercentage =
        ((originalPrice! - price) / originalPrice! * 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: alignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatPrice(price),
              style: priceStyle ??
                  AppTextStyles.heading1.copyWith(
                    color: AppTheme.success,
                  ),
            ),
            if (showCurrencySymbol) ...[
              const SizedBox(width: AppDimensions.spaceXSmall),
              Text(
                currency,
                style: currencyStyle ??
                    AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.normal,
                      color: AppTheme.success,
                    ),
              ),
            ],
            const SizedBox(width: AppDimensions.spaceSmall),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSmall,
                vertical: AppDimensions.paddingXSmall,
              ),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusXs),
              ),
              child: Text(
                '${discountPercentage.toStringAsFixed(0)}% خصم',
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceXSmall),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatPrice(originalPrice!),
              style: originalPriceStyle ??
                  AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textMuted,
                    decoration: TextDecoration.lineThrough,
                  ),
            ),
            if (showCurrencySymbol) ...[
              const SizedBox(width: AppDimensions.spaceXSmall),
              Text(
                currency,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
  Widget _buildCompactPrice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: AppDimensions.paddingXSmall,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatPrice(price),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showCurrencySymbol) ...[
            const SizedBox(width: 2),
            Text(
              currency,
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildDetailedPrice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(AppDimensions.borderMedium),
        border: Border.all(
          color: AppTheme.darkBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (originalPrice != null && originalPrice != price) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'السعر الأصلي:',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                Text(
                  '${_formatPrice(originalPrice!)} $currency',
                  style: AppTextStyles.bodyMedium.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceXSmall),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                period != null ? 'السعر / $period:' : 'السعر:',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_formatPrice(price)} $currency',
                style: AppTextStyles.heading1.copyWith(
                  color: originalPrice != null && originalPrice != price
                      ? AppTheme.success
                      : AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  String _formatPrice(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
enum PriceDisplayType {
  normal,
  discount,
  compact,
  detailed,
}
