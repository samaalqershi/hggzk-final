// lib/features/reference/presentation/widgets/city_selector_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/city.dart';
import '../bloc/reference_bloc.dart';
import '../bloc/reference_event.dart';
import '../bloc/reference_state.dart';

/// Dialog used to choose the active city reference for the app.
/// حوار اختيار المدينة المرجعية النشطة داخل التطبيق.
///
/// It loads cities from `ReferenceBloc`, restores the last selection, and
/// returns the chosen city to the caller.
/// يجلب المدن من `ReferenceBloc`، ويستعيد آخر اختيار محفوظ، ثم يعيد المدينة
/// المختارة إلى الجهة المستدعية.
class CitySelectorDialog extends StatelessWidget {
  /// Builds the reusable city picker shell.
  /// ينشئ الهيكل القابل لإعادة الاستخدام لمنتقي المدينة.
  const CitySelectorDialog({super.key});

  /// Opens the dialog and resolves with the selected city name.
  /// يفتح الحوار ويعيد اسم المدينة المختارة عند الإغلاق.
  static Future<String?> show(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (ctx) => BlocProvider(
        create: (_) => GetIt.instance<ReferenceBloc>()
          ..add(const LoadCitiesEvent())
          ..add(const LoadSelectedCityEvent()),
        child: const Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: CitySelectorDialog(),
        ),
      ),
    );
  }

  /// Renders the dialog surface with the glassmorphism frame.
  /// يرسم سطح الحوار بإطار زجاجي واضح.
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 600),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard,
            AppTheme.darkSurface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: const _DialogContent(),
        ),
      ),
    );
  }
}

/// Stateful dialog body that manages search, animation, and selection.
/// جسم حواري متغير يدير البحث والحركة والاختيار.
class _DialogContent extends StatefulWidget {
  /// Builds the interactive content of the city picker.
  /// ينشئ المحتوى التفاعلي لمنتقي المدينة.
  const _DialogContent();

  /// Builds the animation-backed state for the dialog body.
  /// ينشئ الحالة المدعومة بالحركة لجسم الحوار.
  @override
  State<_DialogContent> createState() => _DialogContentState();
}

/// Tracks the query text and entrance animations for the picker body.
/// يتتبع نص البحث وحركات الظهور لجسم المنتقي.
class _DialogContentState extends State<_DialogContent>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();

  /// Drives the entry animation for the dialog body.
  /// يقود حركة الظهور لجسم الحوار.
  late AnimationController _animationController;

  /// Fades the content in after the dialog mounts.
  /// يدرج المحتوى تدريجيًا بعد تركيب الحوار.
  late Animation<double> _fadeAnimation;

  /// Slides the content slightly upward for a softer entrance.
  /// يرفع المحتوى قليلًا للأعلى لظهور أكثر نعومة.
  late Animation<Offset> _slideAnimation;

  /// Keeps the active search text used to filter cities.
  /// يحتفظ بنص البحث النشط لتصفية المدن.
  String _searchQuery = '';

  /// Starts the entrance animation once the body is mounted.
  /// يبدأ حركة الظهور بعد تركيب الجسم.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  /// Releases the search controller and animation controller.
  /// يحرر متحكم البحث ومتحكم الحركة.
  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Builds the animated content body of the city picker.
  /// يبني جسم المحتوى المتحرك لمنتقي المدينة.
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildSearchField(),
              const SizedBox(height: 16),
              Expanded(
                child: _buildCitiesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the title row and close control.
  /// يبني صف العنوان وزر الإغلاق.
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.location_city_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppTheme.primaryGradient.createShader(bounds),
              child: Text(
                'اختر مدينتك',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              'حدد المدينة للحصول على أفضل النتائج',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.darkCard.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.darkBorder.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Icon(
              Icons.close_rounded,
              color: AppTheme.textMuted,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the in-dialog search field used for instant filtering.
  /// يبني حقل البحث داخل الحوار لتصفية فورية.
  Widget _buildSearchField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withOpacity(0.6),
            AppTheme.darkSurface.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textWhite,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن مدينة...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.primaryBlue.withOpacity(0.7),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          context.read<ReferenceBloc>().add(SearchCitiesEvent(query: value));
        },
      ),
    );
  }

  /// Builds the list of cities that match the current query.
  /// يبني قائمة المدن المطابقة للاستعلام الحالي.
  Widget _buildCitiesList() {
    return BlocBuilder<ReferenceBloc, ReferenceState>(
      builder: (context, state) {
        if (state is ReferenceLoading) {
          return _buildLoadingState();
        }

        if (state is CitiesLoaded) {
          final filteredCities = _searchQuery.isEmpty
              ? state.cities
              : state.cities
                  .where((city) =>
                      city.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      city.country
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                  .toList();

          if (filteredCities.isEmpty) {
            return _buildEmptyState();
          }

          return _buildCitiesGrid(
            cities: filteredCities,
            selectedCity: state.selectedCity,
          );
        }

        if (state is ReferenceError) {
          return _buildErrorState(state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Builds the placeholder shown while the city list loads.
  /// يبني العنصر الظاهر أثناء تحميل قائمة المدن.
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل المدن...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the feedback shown when no cities match the query.
  /// يبني رسالة الحالة الفارغة عند عدم وجود نتائج.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppTheme.textMuted.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج',
            style: AppTextStyles.h3.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب البحث بكلمات أخرى',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the fallback shown when loading cities fails.
  /// يبني البديل الظاهر عند فشل تحميل المدن.
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppTheme.error.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: AppTextStyles.h3.copyWith(
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ReferenceBloc>().add(const LoadCitiesEvent());
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the selectable city grid presented to the user.
  /// يبني شبكة المدن القابلة للاختيار.
  Widget _buildCitiesGrid({
    required List<City> cities,
    required String? selectedCity,
  }) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        final isSelected = city.name == selectedCity;

        return _CityCard(
          city: city,
          isSelected: isSelected,
          onTap: () async {
            HapticFeedback.lightImpact();

            // حفظ المدينة المختارة
            context.read<ReferenceBloc>().add(
                  SelectCityEvent(city: city),
                );

            // انتظار قليل للسماح بعرض الانيميشن
            await Future.delayed(const Duration(milliseconds: 200));

            if (context.mounted) {
              Navigator.of(context).pop(city.name);
            }
          },
          animationDelay: Duration(milliseconds: index * 50),
        );
      },
    );
  }
}

/// Animated tile used to present one selectable city.
/// بطاقة متحركة تعرض مدينة واحدة قابلة للاختيار.
class _CityCard extends StatefulWidget {
  /// City shown inside the tile.
  /// المدينة المعروضة داخل البطاقة.
  final City city;

  /// Highlights the tile when it matches the persisted selection.
  /// يبرز البطاقة عندما تطابق الاختيار المحفوظ.
  final bool isSelected;

  /// Invoked when the user picks this city.
  /// يُستدعى عند اختيار هذه المدينة.
  final VoidCallback onTap;

  /// Staggers the entrance animation so the grid feels layered.
  /// يؤخر الحركة قليلًا لجعل الشبكة تبدو متدرجة.
  final Duration animationDelay;

  /// Builds one animated city tile inside the selection grid.
  /// ينشئ بطاقة مدينة متحركة داخل شبكة الاختيار.
  const _CityCard({
    required this.city,
    required this.isSelected,
    required this.onTap,
    required this.animationDelay,
  });

  /// Builds the animation state for the selectable tile.
  /// ينشئ حالة الحركة للبطاقة القابلة للاختيار.
  @override
  State<_CityCard> createState() => _CityCardState();
}

/// Controls the card animation and press feedback.
/// يدير حركة البطاقة واستجابة الضغط.
class _CityCardState extends State<_CityCard>
    with SingleTickerProviderStateMixin {
  /// Drives the scale animation for the tile entrance.
  /// يقود حركة التدرج الخاصة بظهور البطاقة.
  late AnimationController _controller;

  /// Shrinks and expands the tile as it enters the grid.
  /// يغيّر حجم البطاقة أثناء ظهورها.
  late Animation<double> _scaleAnimation;

  /// Tracks the pressed state for subtle tap feedback.
  /// يتتبع حالة الضغط لإظهار تغذية راجعة خفيفة.
  bool _isPressed = false;

  /// Starts the entrance animation after the optional delay.
  /// يبدأ حركة الظهور بعد التأخير الاختياري.
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  /// Releases the animation controller owned by this tile.
  /// يحرر متحكم الحركة المملوك لهذه البطاقة.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Builds the tappable tile and its selection decoration.
  /// يبني البطاقة القابلة للنقر وزينة التحديد الخاصة بها.
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? AppTheme.primaryGradient
                : LinearGradient(
                    colors: [
                      AppTheme.darkCard.withOpacity(0.7),
                      AppTheme.darkCard.withOpacity(0.5),
                    ],
                  ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.primaryBlue
                  : AppTheme.darkBorder.withOpacity(0.3),
              width: widget.isSelected ? 1.5 : 0.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: widget.isSelected
                          ? Colors.white
                          : AppTheme.primaryBlue.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.city.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: widget.isSelected
                                  ? Colors.white
                                  : AppTheme.textWhite,
                              fontWeight: widget.isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.city.country,
                            style: AppTextStyles.caption.copyWith(
                              color: widget.isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : AppTheme.textMuted.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (widget.isSelected)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
