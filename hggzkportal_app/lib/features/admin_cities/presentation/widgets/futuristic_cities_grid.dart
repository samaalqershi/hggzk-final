// lib/features/admin_cities/presentation/widgets/futuristic_cities_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../domain/entities/city.dart';
import 'futuristic_city_card.dart';

/// Responsive grid/list wrapper that animates city cards into view.
///
/// غلاف شبكي/قائمة متجاوب يعرض بطاقات المدن مع الحركة.
class FuturisticCitiesGrid extends StatelessWidget {
  /// City records to render in the current layout mode.
  ///
  /// سجلات المدن المطلوب عرضها في وضع التخطيط الحالي.
  final List<City> cities;

  /// Switches between the grid presentation and the dense list view.
  ///
  /// يبدل بين عرض الشبكة وعرض القائمة الكثيفة.
  final bool isGridView;

  /// Opens the detail experience for a tapped city.
  ///
  /// يفتح تجربة التفاصيل للمدينة المحددة.
  final Function(City) onCityTap;

  /// Launches the edit form for the selected city.
  ///
  /// يفتح نموذج التعديل للمدينة المحددة.
  final Function(City) onCityEdit;

  /// Triggers the city deletion flow for the selected city.
  ///
  /// يطلق مسار حذف المدينة المحددة.
  final Function(City) onCityDelete;

  /// Builds the animated city collection for the dashboard.
  ///
  /// ينشئ مجموعة المدن المتحركة للوحة التحكم.
  const FuturisticCitiesGrid({
    super.key,
    required this.cities,
    required this.isGridView,
    required this.onCityTap,
    required this.onCityEdit,
    required this.onCityDelete,
  });

  /// يبني عرض الشبكة أو القائمة مع أنيميشن دخول متدرج للمدن.
  /// Builds either the grid or list view with staggered entrance animations.
  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: _getAspectRatio(context),
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final city = cities[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: _getCrossAxisCount(context),
              child: ScaleAnimation(
                scale: 0.95,
                child: FadeInAnimation(
                  child: FuturisticCityCard(
                    city: city,
                    onTap: () => onCityTap(city),
                    onEdit: () => onCityEdit(city),
                    onDelete: () => onCityDelete(city),
                  ),
                ),
              ),
            );
          },
          childCount: cities.length,
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final city = cities[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FuturisticCityCard(
                      city: city,
                      isCompact: true,
                      onTap: () => onCityTap(city),
                      onEdit: () => onCityEdit(city),
                      onDelete: () => onCityDelete(city),
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: cities.length,
        ),
      );
    }
  }

  /// يحدد عدد الأعمدة المناسب بحسب عرض الشاشة.
  /// Determines the appropriate column count based on screen width.
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 1;
    if (width < 600) return 2;
    if (width < 900) return 3;
    return 4;
  }

  /// يحدد نسبة العرض إلى الارتفاع لبطاقات الشبكة بحسب حجم الشاشة.
  /// Determines the grid card aspect ratio based on screen size.
  double _getAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return 1.5;
    if (width < 600) return 1.2;
    return 1.0;
  }
}
