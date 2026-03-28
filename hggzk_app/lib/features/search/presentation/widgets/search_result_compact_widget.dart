import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/search_result.dart';
import 'search_result_card_widget.dart';
import 'package:hggzk/core/enums/search_relaxation_level.dart';

/// Compact search-result list used when the screen needs dense cards and fast
/// scrolling instead of a full-width layout.
/// قائمة نتائج بحث مضغوطة تُستخدم عندما تحتاج الشاشة بطاقات أكثر كثافة
/// وتمريرًا أسرع بدل التخطيط العريض.
class SearchResultCompactWidget extends StatefulWidget {
  /// Search results to render in compact cards.
  /// نتائج البحث المطلوب عرضها كبطاقات مضغوطة.
  final List<SearchResult> results;

  /// Optional controller for synchronizing the surrounding scroll view.
  /// متحكم اختياري لمزامنة التمرير مع الحاوية المحيطة.
  final ScrollController? scrollController;

  /// Shows a footer loader while the next result page is being fetched.
  /// يعرض مؤشر تحميل سفليًا أثناء جلب الصفحة التالية من النتائج.
  final bool isLoadingMore;

  /// Requests the next result batch when the list reaches the end.
  /// يطلب الدفعة التالية من النتائج عند الوصول إلى نهاية القائمة.
  final VoidCallback? onLoadMore;

  /// Opens the selected result in its detail flow.
  /// يفتح النتيجة المختارة في مسار التفاصيل.
  final Function(SearchResult)? onItemTap;

  /// Toggles the favorite state for one result without leaving the list.
  /// يبدّل حالة المفضلة لعنصر واحد دون مغادرة القائمة.
  final Function(SearchResult)? onFavoriteToggle;

  /// Guides the card style when the result is a relaxed or premium match.
  /// يوجّه أسلوب البطاقة عندما تكون النتيجة مطابقة مريحة أو مميزة.
  final SearchRelaxationLevel? relaxationLevel;

  /// Builds the compact list with optional loading and selection callbacks.
  /// ينشئ القائمة المضغوطة مع callbacks اختيارية للتحميل والاختيار.
  const SearchResultCompactWidget({
    super.key,
    required this.results,
    this.scrollController,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.onItemTap,
    this.onFavoriteToggle,
    this.relaxationLevel,
  });

  /// Sets up the animated list state used for staggered compact cards.
  /// يهيئ حالة القائمة المتحركة المستخدمة لتدرج البطاقات المضغوطة.
  @override
  State<SearchResultCompactWidget> createState() =>
      _SearchResultCompactWidgetState();
}

/// Coordinates list entrance animations and incremental item controllers.
/// ينسق حركات ظهور القائمة ومتحكمات العناصر المتدرجة.
class _SearchResultCompactWidgetState extends State<SearchResultCompactWidget>
    with TickerProviderStateMixin {
  /// Drives the overall list entrance animation.
  /// يقود حركة ظهور القائمة ككل.
  late AnimationController _listAnimationController;

  /// Keeps one controller per visible result for staggered motion.
  /// يحتفظ بمتحكم لكل نتيجة مرئية حتى تتحرك العناصر بتتابع.
  final Map<int, AnimationController> _itemAnimations = {};

  /// Starts the list animation and prepares item controllers for every result.
  /// يبدأ حركة القائمة ويجهز متحكمات العناصر لكل نتيجة.
  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    // Stagger each card so the list feels intentionally layered.
    for (int i = 0; i < widget.results.length; i++) {
      _itemAnimations[i] = AnimationController(
        duration: Duration(milliseconds: 300 + (i * 50)),
        vsync: this,
      )..forward();
    }
  }

  /// Keeps the staggered animation controllers aligned with the current
  /// result list.
  /// يبقي متحكمات الحركة المتدرجة متزامنة مع قائمة النتائج الحالية.
  @override
  void didUpdateWidget(covariant SearchResultCompactWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Add or remove controllers so animations match the current list length.
    final oldLen = oldWidget.results.length;
    final newLen = widget.results.length;

    if (newLen > oldLen) {
      for (int i = oldLen; i < newLen; i++) {
        _itemAnimations[i] = AnimationController(
          duration: Duration(milliseconds: 300 + (i * 50)),
          vsync: this,
        )..forward();
      }
    } else if (newLen < oldLen) {
      for (int i = newLen; i < oldLen; i++) {
        final controller = _itemAnimations.remove(i);
        controller?.dispose();
      }
    }
  }

  /// Disposes the list and per-item controllers owned by the widget.
  /// يحرر متحكمات القائمة والعناصر المملوكة للعنصر.
  @override
  void dispose() {
    _listAnimationController.dispose();
    for (var controller in _itemAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Renders the compact cards, empty state, or loading footer as needed.
  /// يرسم البطاقات المضغوطة أو الحالة الفارغة أو مؤشر التحميل عند الحاجة.
  @override
  Widget build(BuildContext context) {
    if (widget.results.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return ListView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          itemCount: widget.results.length + (widget.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == widget.results.length) {
              return _buildLoadingIndicator();
            }

            final result = widget.results[index];
            var animationController = _itemAnimations[index];

            // Fallback: lazily create controller if missing for any reason
            animationController ??=
                _itemAnimations[index] = AnimationController(
              duration: Duration(milliseconds: 300 + (index * 50)),
              vsync: this,
            )..forward();

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animationController,
                curve: Curves.easeOutBack,
              )),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: animationController,
                  curve: Curves.easeIn,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SearchResultCardWidget(
                    result: result,
                    onTap: () => widget.onItemTap?.call(result),
                    onFavoriteToggle: widget.onFavoriteToggle != null
                        ? () => widget.onFavoriteToggle!(result)
                        : null,
                    displayType: CardDisplayType.compact,
                    relaxationLevel: widget.relaxationLevel,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Renders the empty state shown when no results are available.
  /// يرسم الحالة الفارغة التي تظهر عندما لا تتوفر نتائج.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Empty Icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryBlue.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 60,
                    color: AppTheme.textMuted.withOpacity(0.5),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.primaryGradient.createShader(bounds),
            child: Text(
              'لا توجد نتائج',
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'جرب تغيير معايير البحث',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// Renders the footer loading indicator while pagination is active.
  /// يرسم مؤشر التحميل السفلي أثناء تفعيل الترقيم.
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            // Custom Loading Animation
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const LoadingWidget(
                type: LoadingType.futuristic,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'جاري تحميل المزيد...',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
