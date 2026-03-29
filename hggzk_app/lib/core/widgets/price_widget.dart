import 'package:flutter/material.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

/// يعرض السعر بصيغ متعددة تناسب البطاقات الموجزة أو العروض التفصيلية.
/// Renders prices in multiple layouts for compact cards or detailed views.
class PriceWidget extends StatelessWidget {
  /// السعر الحالي المعروض للمستخدم.
  /// Current price shown to the user.
  final double price;

  /// السعر الأصلي عندما نحتاج إظهار خصم أو مقارنة.
  /// Original price used for discounts or comparison.
  final double? originalPrice;

  /// رمز العملة الذي يظهر بجانب الرقم.
  /// Currency code or symbol displayed beside the value.
  final String currency;

  /// النمط البصري المستخدم لعرض السعر.
  /// Visual style used to present the price.
  final PriceDisplayType displayType;

  /// نمط النص للسعر الحالي عندما يحتاج المستدعي تخصيصًا.
  /// Text style for the current price when the caller needs customization.
  final TextStyle? priceStyle;

  /// نمط النص للسعر الأصلي في حالة وجود خصم.
  /// Text style for the original price when a discount exists.
  final TextStyle? originalPriceStyle;

  /// نمط العملة بجانب السعر إن احتاجت الواجهة ضبطًا أدق.
  /// Text style for the currency label when fine control is needed.
  final TextStyle? currencyStyle;

  /// الفترة التي يخصها السعر مثل الليلة أو الشهر.
  /// Period that the price applies to, such as per night or per month.
  final String? period;

  /// يحدد ما إذا كان رمز العملة يجب أن يظهر بجانب الرقم.
  /// Controls whether the currency label should appear next to the value.
  final bool showCurrencySymbol;

  /// محاذاة صف السعر وما يجاوره.
  /// Alignment for the price row and its companions.
  final MainAxisAlignment alignment;

  /// يحدد ما إذا كان السعر ينتقل بعدّاد متحرك بدل الظهور الفوري.
  /// Controls whether the price animates into view instead of appearing instantly.
  final bool animate;

  /// ينشئ عنصر السعر مع إعدادات العرض التي تحتاجها الواجهة.
  /// Creates the price widget with the presentation options the screen needs.
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

  /// يختار شكل عرض السعر المناسب وفق النمط المحدد.
  /// Chooses the appropriate price layout based on the selected display type.
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

  /// يعرض السعر بصيغة بسيطة تناسب البطاقات أو العناوين القصيرة.
  /// Shows a simple price layout for cards or short headings.
  Widget _buildNormalPrice(BuildContext context) {
    final Widget priceWidget = Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatPrice(price),
          style: priceStyle ?? AppTextStyles.h1,
        ),
        if (showCurrencySymbol) ...[
          const SizedBox(width: AppDimensions.spacingXs),
          Text(
            currency,
            style: currencyStyle ??
                AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.normal,
                ),
          ),
        ],
        if (period != null) ...[
          const SizedBox(width: AppDimensions.spacingXs),
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
                style: priceStyle ?? AppTextStyles.h1,
              ),
              if (showCurrencySymbol) ...[
                const SizedBox(width: AppDimensions.spacingXs),
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

  /// يعرض السعر الحالي مع السعر الأصلي وشارة الخصم.
  /// Shows the current price with the original price and a discount badge.
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
                  AppTextStyles.h1.copyWith(
                    color: AppTheme.success,
                  ),
            ),
            if (showCurrencySymbol) ...[
              const SizedBox(width: AppDimensions.spacingXs),
              Text(
                currency,
                style: currencyStyle ??
                    AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.normal,
                      color: AppTheme.success,
                    ),
              ),
            ],
            const SizedBox(width: AppDimensions.spacingSm),
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
                context.tr(
                  'core.price.discountBadge',
                  params: {'percent': discountPercentage.toStringAsFixed(0)},
                ),
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXs),
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
              const SizedBox(width: AppDimensions.spacingXs),
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

  /// يعرض السعر في شارة صغيرة مناسبة للأماكن الضيقة.
  /// Renders the price inside a compact badge for tight spaces.
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

  /// يعرض السعر داخل بطاقة تفصيلية تناسب صفحة العقار أو الحجز.
  /// Renders the price inside a detailed card for property or booking pages.
  Widget _buildDetailedPrice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
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
                  context.tr('core.price.original'),
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
            const SizedBox(height: AppDimensions.spacingXs),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                period != null
                    ? context.tr(
                        'core.price.perPeriod',
                        params: {'period': period},
                      )
                    : context.tr('core.price.current'),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_formatPrice(price)} $currency',
                style: AppTextStyles.h1.copyWith(
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

  /// يحول الرقم إلى صيغة مختصرة مثل K أو M عندما يصبح كبيرًا.
  /// Converts large numbers into compact K or M notation.
  String _formatPrice(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

/// يحدد صيغ عرض السعر المتاحة حتى تبقى الواجهات متسقة وآمنة نوعيًا.
/// Enumerates the available price presentation modes.
enum PriceDisplayType {
  normal,
  discount,
  compact,
  detailed,
}
