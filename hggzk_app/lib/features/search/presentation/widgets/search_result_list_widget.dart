import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/search_result.dart';
import 'search_result_card_widget.dart';
import 'package:hggzk/core/enums/search_relaxation_level.dart';

/// Full-width result list used when the screen prefers a spacious layout over
/// compact cards.
/// قائمة نتائج بعرض كامل تُستخدم عندما تفضل الشاشة تخطيطًا أوسع بدل البطاقات
/// المضغوطة.
class SearchResultListWidget extends StatefulWidget {
  /// Search results rendered in the full-width list layout.
  /// نتائج البحث المعروضة في تخطيط القائمة بعرض كامل.
  final List<SearchResult> results;

  /// Optional controller used to sync pagination with a parent scroll view.
  /// متحكم اختياري لمزامنة الترقيم مع عرض تمرير خارجي.
  final ScrollController? scrollController;

  /// Shows a loading footer while the next page is being fetched.
  /// يعرض تذييل تحميل أثناء جلب الصفحة التالية.
  final bool isLoadingMore;

  /// Requests the next page when the list reaches the end.
  /// يطلب الصفحة التالية عند الوصول إلى نهاية القائمة.
  final VoidCallback? onLoadMore;

  /// Opens the tapped result in the property detail flow.
  /// يفتح النتيجة المختارة في مسار تفاصيل العقار.
  final Function(SearchResult)? onItemTap;

  /// Updates the favorite state for the tapped result.
  /// يحدّث حالة المفضلة للنتيجة المختارة.
  final Function(SearchResult)? onFavoriteToggle;

  /// Adjusts the card style when the backend relaxed the match criteria.
  /// يضبط أسلوب البطاقة عندما يخفف الخادم معايير المطابقة.
  final SearchRelaxationLevel? relaxationLevel;

  /// Builds the list layout with optional pagination and item actions.
  /// ينشئ تخطيط القائمة مع إجراءات اختيارية للتصفح الصفحي والعناصر.
  const SearchResultListWidget({
    super.key,
    required this.results,
    this.scrollController,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.onItemTap,
    this.onFavoriteToggle,
    this.relaxationLevel,
  });

  /// Creates the animated state used to stagger list entries.
  /// يهيئ حالة الحركة المستخدمة لتدرج عناصر القائمة.
  @override
  State<SearchResultListWidget> createState() => _SearchResultListWidgetState();
}

/// Keeps the full-width result list aligned with the current search payload.
/// يبقي قائمة النتائج بعرض كامل متناسقة مع حمولة البحث الحالية.
class _SearchResultListWidgetState extends State<SearchResultListWidget>
    with TickerProviderStateMixin {
  /// Drives the list entrance animation.
  /// يقود حركة ظهور القائمة.
  late AnimationController _listAnimationController;

  /// Keeps a controller per result so rows can appear sequentially.
  /// يحتفظ بمتحكم لكل نتيجة كي تظهر الصفوف بالتتابع.
  final Map<int, AnimationController> _itemAnimations = {};

  /// Starts the entry animation and prepares per-row controllers.
  /// يبدأ حركة الظهور ويجهز المتحكمات الخاصة بكل صف.
  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    // Stagger row appearance to keep the list visually ordered.
    for (int i = 0; i < widget.results.length; i++) {
      _itemAnimations[i] = AnimationController(
        duration: Duration(milliseconds: 300 + (i * 50)),
        vsync: this,
      )..forward();
    }
  }

  /// Reconciles the animation controllers whenever the result count changes.
  /// يطابق متحكمات الحركة عند تغيّر عدد النتائج.
  @override
  void didUpdateWidget(covariant SearchResultListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Match controller count to the latest result list.
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

  /// Disposes the list and item controllers owned by the widget.
  /// يحرر متحكمات القائمة والعناصر المملوكة للعنصر.
  @override
  void dispose() {
    _listAnimationController.dispose();
    for (var controller in _itemAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Renders the full-width cards, empty state, or loading footer.
  /// يرسم البطاقات بعرض كامل أو الحالة الفارغة أو تذييل التحميل.
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
                    displayType: CardDisplayType.list,
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

  /// العربية: يبني empty state.
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
              context.tr('search.results.none'),
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            context.tr('search.results.tryDifferent'),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// العربية: يبني loading indicator.
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
              context.tr('search.results.loadingMore'),
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
