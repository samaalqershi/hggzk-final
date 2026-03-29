import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hggzk/features/property/domain/entities/property_detail.dart';
import '../../../../core/localization/app_localizations.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';
import 'package:hggzk/core/services/filter_storage_service.dart';
import '../bloc/property_bloc.dart';
import '../bloc/property_event.dart';
import '../bloc/property_state.dart';
import '../widgets/property_header_widget.dart';
import '../widgets/property_images_grid_widget.dart';
import '../widgets/property_info_widget.dart';
import '../widgets/amenities_grid_widget.dart';
import '../widgets/reviews_summary_widget.dart';
import '../widgets/policies_widget.dart';
import '../widgets/location_map_widget.dart';
import 'package:hggzk/core/services/local_storage_service.dart';
import '../../../../core/constants/storage_constants.dart';

/// Describes the `PropertyDetailsPage` page widget.
/// العربية: يمثل عنصر الصفحة `PropertyDetailsPage`.
class PropertyDetailsPage extends StatefulWidget {
  /// Keeps the propertyId value available to this object.
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// Keeps the userId value available to this object.
  /// العربية: يخزن القيمة `userId`.
  final String? userId;

  /// Keeps the unitId value available to this object.
  /// العربية: يخزن القيمة `unitId`.
  final String? unitId;

  /// Keeps the checkInDate value available to this object.
  /// العربية: يخزن القيمة `checkInDate`.
  final DateTime? checkInDate;

  /// Keeps the checkOutDate value available to this object.
  /// العربية: يخزن القيمة `checkOutDate`.
  final DateTime? checkOutDate;

  /// Keeps the adults value available to this object.
  /// العربية: يخزن القيمة `adults`.
  final int? adults;

  /// Keeps the children value available to this object.
  /// العربية: يخزن القيمة `children`.
  final int? children;

  /// Keeps the guestsCount value available to this object.
  /// العربية: يخزن القيمة `guestsCount`.
  final int? guestsCount;

  /// Keeps the unitTypeId value available to this object.
  /// العربية: يخزن القيمة `unitTypeId`.
  final String? unitTypeId;

  /// Constructs the PropertyDetailsPage value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `PropertyDetailsPage`.
  const PropertyDetailsPage({
    super.key,
    required this.propertyId,
    this.userId,
    this.unitId,
    this.checkInDate,
    this.checkOutDate,
    this.adults,
    this.children,
    this.guestsCount,
    this.unitTypeId,
  });

  /// Builds the state object for this widget used by this feature.
  /// العربية: ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

/// Describes the state for `PropertyDetailsPageState`.
/// العربية: يمثل الحالة الخاصة بـ `PropertyDetailsPageState`.
class _PropertyDetailsPageState extends State<PropertyDetailsPage>
    with TickerProviderStateMixin {
  /// Keeps the tabController value available to this object.
  /// العربية: يخزن القيمة `tabController`.
  late TabController _tabController;

  /// Keeps the fadeController value available to this object.
  /// العربية: يخزن القيمة `fadeController`.
  late AnimationController _fadeController;

  /// Keeps the slideController value available to this object.
  /// العربية: يخزن القيمة `slideController`.
  late AnimationController _slideController;

  /// Keeps the floatingHeaderController value available to this object.
  /// العربية: يخزن القيمة `floatingHeaderController`.
  late AnimationController _floatingHeaderController;

  /// Keeps the particleController value available to this object.
  /// العربية: يخزن القيمة `particleController`.
  late AnimationController _particleController;

  final ScrollController _scrollController = ScrollController();

  /// Keeps the showFloatingHeader value available to this object.
  /// العربية: يخزن القيمة `showFloatingHeader`.
  bool _showFloatingHeader = false;

  /// Keeps the scrollOffset value available to this object.
  /// العربية: يخزن القيمة `scrollOffset`.
  double _scrollOffset = 0;

  /// Keeps the currentTabIndex value available to this object.
  /// العربية: يخزن القيمة `currentTabIndex`.
  int _currentTabIndex = 0;

  /// Keeps the fadeAnimation value available to this object.
  /// العربية: يخزن القيمة `fadeAnimation`.
  late Animation<double> _fadeAnimation;

  /// Keeps the slideAnimation value available to this object.
  /// العربية: يخزن القيمة `slideAnimation`.
  late Animation<Offset> _slideAnimation;

  /// Keeps the scaleAnimation value available to this object.
  /// العربية: يخزن القيمة `scaleAnimation`.
  late Animation<double> _scaleAnimation;

  /// Keeps the particles value available to this object.
  /// العربية: يخزن القيمة `particles`.
  final List<_AnimatedParticle> _particles = [];

  // إنشاء Bloc instance واحد فقط ويبقى طوال حياة الصفحة
  /// Keeps the propertyBloc value available to this object.
  /// العربية: يخزن القيمة `propertyBloc`.
  late PropertyBloc _propertyBloc;

  /// Processes the toDate flow and maps it into the property feature behavior.
  /// العربية: يعالج `toDate`.
  DateTime? _toDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Processes the toInt flow and maps it into the property feature behavior.
  /// العربية: يعالج `toInt`.
  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Resolves the booking selections.
  /// العربية: يحدد booking selections.
  Map<String, dynamic> _resolveBookingSelections() {
    final saved = sl<FilterStorageService>().getHomeSelections();
    final checkIn = widget.checkInDate ?? _toDate(saved['checkIn']);
    final checkOut = widget.checkOutDate ?? _toDate(saved['checkOut']);
    final adults = widget.adults ?? _toInt(saved['adults']) ?? 1;
    final children = widget.children ?? _toInt(saved['children']) ?? 0;
    final guests = widget.guestsCount ??
        ((adults + children) <= 0 ? 1 : (adults + children));
    final unitTypeId = widget.unitTypeId ?? saved['unitTypeId']?.toString();

    return {
      'checkIn': checkIn,
      'checkOut': checkOut,
      'adults': adults,
      'children': children,
      'guestsCount': guests,
      'unitTypeId': unitTypeId,
    };
  }

  /// Dispatches the property load.
  /// العربية: يرسل property load.
  void _dispatchPropertyLoad() {
    _propertyBloc.add(GetPropertyDetailsEvent(
      propertyId: widget.propertyId,
      userId: (sl<LocalStorageService>().getData(StorageConstants.userId) ??
              widget.userId)
          ?.toString(),
      userRole: sl<LocalStorageService>()
          .getData(StorageConstants.accountRole)
          ?.toString(),
      checkInDate: widget.checkInDate,
      checkOutDate: widget.checkOutDate,
      adults: widget.adults,
      children: widget.children,
      guestsCount: widget.guestsCount,
      unitTypeId: widget.unitTypeId,
    ));
  }

  /// Initializes the state for this widget.
  /// العربية: يهيئ الحالة الخاصة بهذا العنصر.
  @override
  void initState() {
    super.initState();

    // إنشاء Bloc instance واحد فقط
    _propertyBloc = sl<PropertyBloc>();
    _dispatchPropertyLoad();
    _propertyBloc.add(UpdateViewCountEvent(propertyId: widget.propertyId));

    _initializeAnimations();
    _generateParticles();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);

    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

    _startAnimations();
  }

  /// Initializes the animations.
  /// العربية: يهيئ animations.
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _floatingHeaderController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.elasticOut,
    ));
  }

  /// Generates the particles.
  /// العربية: ينشئ particles.
  void _generateParticles() {
    for (int i = 0; i < 5; i++) {
      _particles.add(_AnimatedParticle());
    }
  }

  /// Starts the animations.
  /// العربية: يبدأ animations.
  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  /// Releases the resources used by this instance.
  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _propertyBloc.close(); // إغلاق الـ Bloc عند dispose
    _tabController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _floatingHeaderController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  /// Processes the onScroll flow and maps it into the property feature behavior.
  /// العربية: يعالج `onScroll`.
  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      final shouldShow = _scrollOffset > 200;

      if (shouldShow != _showFloatingHeader) {
        _showFloatingHeader = shouldShow;
        if (_showFloatingHeader) {
          _floatingHeaderController.forward();
        } else {
          _floatingHeaderController.reverse();
        }
      }
    });
  }

  /// Builds the futuristic bottom bar from state.
  /// العربية: يبني futuristic bottom bar from state.
  Widget _buildFuturisticBottomBarFromState(
      BuildContext context, PropertyState state) {
    final detailsState = state is PropertyWithDetails
        ? PropertyDetailsLoaded(
            property: state.property,
            isFavorite: state.isFavorite,
            selectedImageIndex: state.selectedImageIndex,
            selectedUnitId: state.selectedUnitId,
          )
        : state as PropertyDetailsLoaded;
    final units = state is PropertyWithDetails
        ? state.units
        : detailsState.property.units;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkCard.withOpacity(0.95),
              AppTheme.darkSurface,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: _buildBookNowButton(context, state, units),
      ),
    );
  }

  /// Builds the widget tree for this component.
  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<PropertyBloc>.value(
      value:
          _propertyBloc, // استخدام الـ instance الموجود بدلاً من إنشاء واحد جديد
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        bottomNavigationBar: BlocBuilder<PropertyBloc, PropertyState>(
          buildWhen: (previous, current) => current is! PropertyFavoriteUpdated,
          builder: (context, state) {
            if (state is PropertyDetailsLoaded ||
                state is PropertyWithDetails) {
              return _buildFuturisticBottomBarFromState(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            _buildParticles(),
            BlocBuilder<PropertyBloc, PropertyState>(
              buildWhen: (previous, current) =>
                  current is! PropertyFavoriteUpdated,
              builder: (context, state) {
                if (state is PropertyLoading) {
                  return _buildFuturisticLoader();
                }

                if (state is PropertyError) {
                  return _buildFuturisticError(context, state);
                }

                if (state is PropertyDetailsLoaded) {
                  return Stack(
                    children: [
                      CustomScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          _buildFuturisticSliverAppBar(context, state),
                          SliverToBoxAdapter(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 0),
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: Transform.scale(
                                    scale: _scaleAnimation.value,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        PropertyHeaderWidget(
                                          property: state.property,
                                          isFavorite: state.isFavorite,
                                          isFavoritePending:
                                              state.isFavoritePending,
                                          onFavoriteToggle: () =>
                                              _toggleFavorite(context, state),
                                          onShare: () => _shareProperty(state),
                                        ),
                                        _buildFuturisticTabBar(),
                                        _buildFuturisticTabContentFromState(
                                            state),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_showFloatingHeader)
                        _buildFuturisticFloatingHeader(context, state),
                    ],
                  );
                }

                if (state is PropertyWithDetails) {
                  final detailsState = PropertyDetailsLoaded(
                    property: state.property,
                    isFavorite: state.isFavorite,
                    selectedImageIndex: state.selectedImageIndex,
                    selectedUnitId: state.selectedUnitId,
                    isFavoritePending: state.isFavoritePending,
                    queuedFavoriteTarget: state.queuedFavoriteTarget,
                    availability: state.availability,
                  );
                  return Stack(
                    children: [
                      CustomScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          _buildFuturisticSliverAppBar(context, detailsState),
                          SliverToBoxAdapter(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 0),
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: Transform.scale(
                                    scale: _scaleAnimation.value,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        PropertyHeaderWidget(
                                          property: detailsState.property,
                                          isFavorite: detailsState.isFavorite,
                                          isFavoritePending:
                                              detailsState.isFavoritePending,
                                          onFavoriteToggle: () =>
                                              _toggleFavorite(
                                                  context, detailsState),
                                          onShare: () =>
                                              _shareProperty(detailsState),
                                        ),
                                        _buildFuturisticTabBar(),
                                        _buildFuturisticTabContentFromState(
                                            state),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_showFloatingHeader)
                        _buildFuturisticFloatingHeader(context, detailsState),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the animated background.
  /// العربية: يبني animated background.
  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.darkBackground,
            AppTheme.darkSurface,
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.7, -0.9),
            radius: 1.3,
            colors: [
              AppTheme.primaryBlue.withOpacity(0.18),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the particles.
  /// العربية: يبني particles.
  Widget _buildParticles() {
    // تم تبسيط الخلفية بإزالة الطبقة المتحركة لإعطاء إحساس أكثر هدوءًا ورقيًا
    return const SizedBox.shrink();
  }

  /// Builds the futuristic loader.
  /// العربية: يبني futuristic loader.
  Widget _buildFuturisticLoader() {
    return Center(
      child: LoadingWidget(
        type: LoadingType.futuristic,
        message: context.tr(
          'property.loadingDetails',
        ),
      ),
    );
  }

  /// Builds the futuristic error.
  /// العربية: يبني futuristic error.
  Widget _buildFuturisticError(BuildContext context, PropertyError state) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.8),
              AppTheme.darkCard.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppTheme.error.withOpacity(0.2),
                    AppTheme.error.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 32,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('property.errorTitle'),
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppTheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildGlowingButton(
              onPressed: () {
                _dispatchPropertyLoad();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 16),
                  SizedBox(width: 6),
                  Text(
                    context.tr('property.retry'),
                    style: AppTextStyles.buttonMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the futuristic sliver app bar.
  /// العربية: يبني futuristic sliver app bar.
  Widget _buildFuturisticSliverAppBar(
      BuildContext context, PropertyDetailsLoaded state) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: (AppTheme.isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent),
      leading: _buildGlassBackButton(context),
      actions: const [],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.biggest.height;
          const minHeight = kToolbarHeight + 16;
          final t =
              ((maxHeight - minHeight) / (320 - minHeight)).clamp(0.0, 1.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'property_${state.property.id}',
                child: PropertyImagesGridWidget(
                  images: state.property.images,
                  onImageTap: (index) => _openGallery(context, state, index),
                ),
              ),
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1 * t),
                        Colors.black.withOpacity(0.65),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds the glass back button.
  /// العربية: يبني glass back button.
  Widget _buildGlassBackButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkCard.withOpacity(0.6),
                  AppTheme.darkCard.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 16),
              color: AppTheme.textWhite,
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the futuristic tab bar.
  /// العربية: يبني futuristic tab bar.
  Widget _buildFuturisticTabBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.9),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        physics: const BouncingScrollPhysics(),
        labelColor: AppTheme.textWhite,
        unselectedLabelColor: AppTheme.textMuted,
        indicatorColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2,
        labelStyle: AppTextStyles.bodySmall,
        unselectedLabelStyle: AppTextStyles.caption,
        overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.02)),
        tabs: [
          _buildFuturisticTab(
            context.tr('property.tabs.overview'),
            Icons.info_outline,
            0,
          ),
          _buildFuturisticTab(
            context.tr('property.tabs.amenities'),
            Icons.star_border,
            1,
          ),
          _buildFuturisticTab(
            context.tr('property.tabs.reviews'),
            Icons.rate_review,
            2,
          ),
          _buildFuturisticTab(
            context.tr('property.tabs.location'),
            Icons.location_on,
            3,
          ),
        ],
      ),
    );
  }

  /// Builds the futuristic tab.
  /// العربية: يبني futuristic tab.
  Widget _buildFuturisticTab(String label, IconData icon, int index) {
    final isSelected = _currentTabIndex == index;

    return Tab(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : AppTheme.darkSurface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppTheme.darkBorder.withOpacity(0.5),
            width: 0.7,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? Colors.white
                  : AppTheme.textMuted.withOpacity(0.9),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? Colors.white : AppTheme.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the futuristic tab content from state.
  /// العربية: يبني futuristic tab content from state.
  Widget _buildFuturisticTabContentFromState(PropertyState state) {
    final detailsState = state is PropertyWithDetails
        ? PropertyDetailsLoaded(
            property: state.property,
            isFavorite: state.isFavorite,
            selectedImageIndex: state.selectedImageIndex,
            selectedUnitId: state.selectedUnitId,
            availability: state.availability,
          )
        : state as PropertyDetailsLoaded;

    // لا AnimatedContainer حول TabBarView لتجنب إعادة حساب layout
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildOverviewTab(detailsState),
          _buildAmenitiesTab(detailsState),
          _buildReviewsTab(detailsState),
          _buildLocationTab(detailsState),
        ],
      ),
    );
  }

  /// Builds the overview tab.
  /// العربية: يبني overview tab.
  Widget _buildOverviewTab(PropertyDetailsLoaded state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGlassContainer(
            child: PropertyInfoWidget(property: state.property),
          ),
          const SizedBox(height: 12),
          if (state.property.services.isNotEmpty) ...[
            _buildSectionTitle(
              context.tr(
                'property.sections.availableServices',
              ),
              Icons.room_service,
            ),
            const SizedBox(height: 10),
            _buildServicesGrid(state),
            const SizedBox(height: 12),
          ],
          if (state.property.policies.isNotEmpty) ...[
            _buildSectionTitle(
              context.tr(
                'property.sections.policies',
              ),
              Icons.policy,
            ),
            const SizedBox(height: 10),
            _buildGlassContainer(
              child: PoliciesWidget(policies: state.property.policies),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the amenities tab.
  /// العربية: يبني amenities tab.
  Widget _buildAmenitiesTab(PropertyDetailsLoaded state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(12),
      child: _buildGlassContainer(
        child: AmenitiesGridWidget(amenities: state.property.amenities),
      ),
    );
  }

  /// Builds the reviews tab.
  /// العربية: يبني reviews tab.
  Widget _buildReviewsTab(PropertyDetailsLoaded state) {
    return ReviewsSummaryWidget(
      propertyId: state.property.id,
      reviewsCount: state.property.reviewsCount,
      averageRating: state.property.averageRating,
      onViewAll: () => _navigateToReviews(context, state),
    );
  }

  /// Builds the location tab.
  /// العربية: يبني location tab.
  Widget _buildLocationTab(PropertyDetailsLoaded state) {
    return LocationMapWidget(
      latitude: state.property.latitude,
      longitude: state.property.longitude,
      propertyName: state.property.name,
      address: state.property.address,
    );
  }

  /// Builds the glass container.
  /// العربية: يبني glass container.
  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withOpacity(0.6),
                AppTheme.darkCard.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  //################### الخدمات
// تحديث دالة بناء الخدمات في Flutter

  /// Builds the services grid.
  /// العربية: يبني services grid.
  Widget _buildServicesGrid(PropertyDetailsLoaded state) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: state.property.services.map((service) {
        // الحصول على اللون بناءً على اسم الخدمة
        final serviceColor = _getServiceColorFromName(service.name);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                serviceColor.withOpacity(0.2),
                serviceColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: serviceColor.withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getServiceIcon(service),
                size: 12,
                color: serviceColor.withOpacity(0.8),
              ),
              const SizedBox(width: 6),
              Text(
                service.name,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textWhite.withOpacity(0.9),
                ),
              ),
              if (service.price > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: serviceColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${service.price.toStringAsFixed(0)} ${service.currency}',
                    style: AppTextStyles.caption.copyWith(
                      color: serviceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Exposes the service color from name.
  /// العربية: يعيد service color from name.
  Color _getServiceColorFromName(String serviceName) {
    // توليد hash ثابت من اسم الخدمة
    int hash = serviceName.hashCode;

    // قائمة الألوان المتاحة
    final colors = [
      AppTheme.primaryBlue,
      AppTheme.primaryPurple,
      AppTheme.primaryCyan,
      AppTheme.primaryViolet,
      AppTheme.success,
      AppTheme.warning,
      AppTheme.info,
    ];

    // اختيار لون بناءً على hash
    return colors[hash.abs() % colors.length];
  }

// دالة للحصول على أيقونة الخدمة الديناميكية
  /// Exposes the service icon.
  /// العربية: يعيد service icon.
  IconData _getServiceIcon(PropertyService service) {
    // إذا كانت الخدمة تحتوي على أيقونة محددة من الخادم
    if (service.icon.isNotEmpty) {
      return _getIconFromServiceName(service.icon);
    }

    // وإلا استخدم الأيقونة الافتراضية بناءً على الاسم
    final name = service.name.toLowerCase();
    if (name.contains('تنظيف') || name.contains('cleaning'))
      return Icons.cleaning_services;
    if (name.contains('غسيل') || name.contains('laundry'))
      return Icons.local_laundry_service;
    if (name.contains('طعام') || name.contains('food')) return Icons.restaurant;
    if (name.contains('إفطار') || name.contains('breakfast'))
      return Icons.breakfast_dining;
    if (name.contains('غداء') || name.contains('lunch'))
      return Icons.lunch_dining;
    if (name.contains('عشاء') || name.contains('dinner'))
      return Icons.dinner_dining;
    if (name.contains('نقل') || name.contains('transport'))
      return Icons.airport_shuttle;
    if (name.contains('تاكسي') || name.contains('taxi'))
      return Icons.local_taxi;
    if (name.contains('واي فاي') || name.contains('wifi')) return Icons.wifi;
    if (name.contains('سبا') || name.contains('spa')) return Icons.spa;
    if (name.contains('جيم') || name.contains('gym'))
      return Icons.fitness_center;
    if (name.contains('مسبح') || name.contains('pool')) return Icons.pool;

    return Icons.check_circle;
  }

// دالة لتحويل اسم الأيقونة من السلسلة النصية إلى IconData
  /// Exposes the icon from service name.
  /// العربية: يعيد icon from service name.
  IconData _getIconFromServiceName(String iconName) {
    // خريطة شاملة لتحويل أسماء أيقونات الخدمات إلى Material Icons
    final iconMap = <String, IconData>{
      // خدمات التنظيف
      'cleaning_services': Icons.cleaning_services,
      'dry_cleaning': Icons.dry_cleaning,
      'local_laundry_service': Icons.local_laundry_service,
      'iron': Icons.iron,
      'wash': Icons.wash,
      'soap': Icons.soap,
      'plumbing': Icons.plumbing,

      // خدمات الطعام والضيافة
      'room_service': Icons.room_service,
      'restaurant': Icons.restaurant,
      'local_cafe': Icons.local_cafe,
      'local_bar': Icons.local_bar,
      'breakfast_dining': Icons.breakfast_dining,
      'lunch_dining': Icons.lunch_dining,
      'dinner_dining': Icons.dinner_dining,
      'delivery_dining': Icons.delivery_dining,
      'takeout_dining': Icons.takeout_dining,
      'ramen_dining': Icons.ramen_dining,
      'icecream': Icons.icecream,
      'cake': Icons.cake,
      'local_pizza': Icons.local_pizza,
      'fastfood': Icons.fastfood,

      // خدمات النقل
      'airport_shuttle': Icons.airport_shuttle,
      'local_taxi': Icons.local_taxi,
      'car_rental': Icons.car_rental,
      'car_repair': Icons.car_repair,
      'directions_car': Icons.directions_car,
      'directions_bus': Icons.directions_bus,
      'directions_boat': Icons.directions_boat,
      'directions_bike': Icons.directions_bike,
      'electric_bike': Icons.electric_bike,
      'electric_scooter': Icons.electric_scooter,
      'local_shipping': Icons.local_shipping,
      'local_parking': Icons.local_parking,

      // خدمات الاتصالات
      'wifi': Icons.wifi,
      'wifi_calling': Icons.wifi_calling,
      'router': Icons.router,
      'phone_in_talk': Icons.phone_in_talk,
      'phone_callback': Icons.phone_callback,
      'support_agent': Icons.support_agent,
      'headset_mic': Icons.headset_mic,
      'mail': Icons.mail,
      'markunread_mailbox': Icons.markunread_mailbox,
      'print': Icons.print,
      'scanner': Icons.scanner,
      'fax': Icons.fax,

      // خدمات الترفيه
      'spa': Icons.spa,
      'hot_tub': Icons.hot_tub,
      'pool': Icons.pool,
      'fitness_center': Icons.fitness_center,
      'sports_tennis': Icons.sports_tennis,
      'sports_golf': Icons.sports_golf,
      'sports_soccer': Icons.sports_soccer,
      'sports_basketball': Icons.sports_basketball,
      'casino': Icons.casino,
      'theater_comedy': Icons.theater_comedy,
      'movie': Icons.movie,
      'music_note': Icons.music_note,
      'nightlife': Icons.nightlife,
      'celebration': Icons.celebration,

      // خدمات الأعمال
      'business_center': Icons.business_center,
      'meeting_room': Icons.meeting_room,
      'co_present': Icons.co_present,
      'groups': Icons.groups,
      'event': Icons.event,
      'event_available': Icons.event_available,
      'event_seat': Icons.event_seat,
      'mic': Icons.mic,
      'videocam': Icons.videocam,
      'desktop_windows': Icons.desktop_windows,
      'laptop': Icons.laptop,

      // خدمات صحية
      'medical_services': Icons.medical_services,
      'local_hospital': Icons.local_hospital,
      'local_pharmacy': Icons.local_pharmacy,
      'emergency': Icons.emergency,
      'vaccines': Icons.vaccines,
      'healing': Icons.healing,
      'monitor_heart': Icons.monitor_heart,
      'health_and_safety': Icons.health_and_safety,
      'masks': Icons.masks,
      'sanitizer': Icons.sanitizer,
      'psychology': Icons.psychology,
      'self_improvement': Icons.self_improvement,

      // خدمات التسوق
      'shopping_cart': Icons.shopping_cart,
      'shopping_bag': Icons.shopping_bag,
      'local_mall': Icons.local_mall,
      'local_grocery_store': Icons.local_grocery_store,
      'local_convenience_store': Icons.local_convenience_store,
      'store': Icons.store,
      'storefront': Icons.storefront,
      'local_offer': Icons.local_offer,
      'loyalty': Icons.loyalty,
      'card_giftcard': Icons.card_giftcard,

      // خدمات العائلة
      'child_care': Icons.child_care,
      'baby_changing_station': Icons.baby_changing_station,
      'child_friendly': Icons.child_friendly,
      'toys': Icons.toys,
      'stroller': Icons.stroller,
      'family_restroom': Icons.family_restroom,
      'escalator_warning': Icons.escalator_warning,
      'pregnant_woman': Icons.pregnant_woman,

      // حيوانات أليفة
      'pets': Icons.pets,

      // خدمات الأمان
      'security': Icons.security,
      'local_police': Icons.local_police,
      'shield': Icons.shield,
      'verified_user': Icons.verified_user,
      'lock': Icons.lock,
      'key': Icons.key,
      'doorbell': Icons.doorbell,
      'camera_alt': Icons.camera_alt,

      // خدمات مالية
      'local_atm': Icons.local_atm,
      'account_balance': Icons.account_balance,
      'currency_exchange': Icons.currency_exchange,
      'payment': Icons.payment,
      'credit_card': Icons.credit_card,
      'account_balance_wallet': Icons.account_balance_wallet,
      'savings': Icons.savings,

      // خدمات أخرى
      'handshake': Icons.handshake,
      'luggage': Icons.luggage,
      'umbrella': Icons.beach_access,
      'translate': Icons.translate,
      'tour': Icons.tour,
      'map': Icons.map,
      'info': Icons.info,
    };

    return iconMap[iconName] ?? Icons.check_circle;
  }

  //################### الخدمات
  /// Builds the section title.
  /// العربية: يبني section title.
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 8),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the futuristic floating header.
  /// العربية: يبني futuristic floating header.
  Widget _buildFuturisticFloatingHeader(
      BuildContext context, PropertyDetailsLoaded state) {
    return AnimatedBuilder(
      animation: _floatingHeaderController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -90 * (1 - _floatingHeaderController.value)),
          child: Opacity(
            opacity: _floatingHeaderController.value.clamp(0.0, 1.0).toDouble(),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withOpacity(0.96),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: SafeArea(
                    child: Container(
                      height: 58,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          _buildGlassBackButton(context),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.property.name,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textWhite,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 11,
                                      color: AppTheme.primaryBlue,
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        state.property.address,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppTheme.textMuted,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
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
            ),
          ),
        );
      },
    );
  }

  /// Builds the glowing button.
  /// العربية: يبني glowing button.
  Widget _buildGlowingButton({
    required VoidCallback? onPressed, // تغيير من VoidCallback إلى VoidCallback?
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed, // سيقبل null الآن
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Toggles the favorite.
  /// العربية: يبدل favorite.
  void _toggleFavorite(BuildContext context, PropertyDetailsLoaded state) {
    final uid = (sl<LocalStorageService>().getData(StorageConstants.userId) ??
            widget.userId ??
            '')
        .toString();
    _propertyBloc.add(
      ToggleFavoriteEvent(
        propertyId: state.property.id,
        userId: uid,
        isFavorite: state.isFavorite,
      ),
    );

    HapticFeedback.lightImpact();
  }

  /// Shares the property.
  /// العربية: يشارك property.
  void _shareProperty(PropertyDetailsLoaded state) {
    HapticFeedback.mediumImpact();
  }

  /// Opens the gallery.
  /// العربية: يفتح gallery.
  void _openGallery(
      BuildContext context, PropertyDetailsLoaded state, int index) {
    context.push(
      '/property/${state.property.id}/gallery',
      extra: {
        'images': state.property.images,
        'initialIndex': index,
      },
    );
  }

  /// Navigates to the to reviews.
  /// العربية: ينتقل إلى to reviews.
  void _navigateToReviews(BuildContext context, PropertyDetailsLoaded state) {
    context.push(
      '/property/${state.property.id}/reviews',
      extra: state.property.name,
    );
  }

  /// Builds the book now button.
  /// العربية: يبني book now button.
  Widget _buildBookNowButton(
      BuildContext context, PropertyState state, List<dynamic> units) {
    final property = state is PropertyWithDetails
        ? state.property
        : (state as PropertyDetailsLoaded).property;

    return _buildGlowingButton(
      onPressed: () {
        final selections = _resolveBookingSelections();
        context.push('/property/${property.id}/units', extra: {
          'propertyName': property.name,
          'checkInDate': selections['checkIn'],
          'checkOutDate': selections['checkOut'],
          'guestsCount': selections['guestsCount'],
          'unitTypeId': selections['unitTypeId'],
          'units': units,
          'propertyServices': property.services,
          'propertyPolicies': property.policies,
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            context.tr('property.bookNow'),
            style: AppTextStyles.buttonMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// كلاسات الـ Painters بدون تغيير ولكن بأحجام أصغر
/// Describes the AnimatedParticle type used in the property feature.
/// العربية: يمثل `AnimatedParticle`.
class _AnimatedParticle {
  /// Keeps the x value available to this object.
  /// العربية: يخزن القيمة `x`.
  late double x;

  /// Keeps the y value available to this object.
  /// العربية: يخزن القيمة `y`.
  late double y;

  /// Keeps the vx value available to this object.
  /// العربية: يخزن القيمة `vx`.
  late double vx;

  /// Keeps the vy value available to this object.
  /// العربية: يخزن القيمة `vy`.
  late double vy;

  /// Keeps the radius value available to this object.
  /// العربية: يخزن القيمة `radius`.
  late double radius;

  /// Keeps the opacity value available to this object.
  /// العربية: يخزن القيمة `opacity`.
  late double opacity;

  /// Keeps the color value available to this object.
  /// العربية: يخزن القيمة `color`.
  late Color color;

  /// Constructs the AnimatedParticle value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `AnimatedParticle`.
  _AnimatedParticle() {
    reset();
  }

  /// Processes the reset flow and maps it into the property feature behavior.
  /// العربية: يعالج `reset`.
  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    vx = (math.Random().nextDouble() - 0.5) * 0.0005;
    vy = (math.Random().nextDouble() - 0.5) * 0.0005;
    radius = math.Random().nextDouble() * 1.5 + 0.5;
    opacity = math.Random().nextDouble() * 0.2 + 0.05;

    final colors = [
      AppTheme.primaryBlue,
      AppTheme.primaryPurple,
      AppTheme.primaryCyan,
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }

  /// Updates the required operation for `update`.
  /// العربية: يحدّث العملية المطلوبة لـ `update`.
  void update() {
    x += vx;
    y += vy;

    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;
  }
}

/// Describes the ParticlePainter type used in the property feature.
/// العربية: يمثل `ParticlePainter`.
class _ParticlePainter extends CustomPainter {
  /// Keeps the particles value available to this object.
  /// العربية: يخزن القيمة `particles`.
  final List<_AnimatedParticle> particles;

  /// Keeps the animationValue value available to this object.
  /// العربية: يخزن القيمة `animationValue`.
  final double animationValue;

  /// Constructs the ParticlePainter value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `ParticlePainter`.
  _ParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  /// Processes the paint flow and maps it into the property feature behavior.
  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();

      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius,
        paint,
      );
    }
  }

  /// Processes the shouldRepaint flow and maps it into the property feature behavior.
  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Describes the MiniDNALoaderPainter type used in the property feature.
/// العربية: يمثل `MiniDNALoaderPainter`.
class _MiniDNALoaderPainter extends CustomPainter {
  /// Keeps the animationValue value available to this object.
  /// العربية: يخزن القيمة `animationValue`.
  final double animationValue;

  /// Keeps the color value available to this object.
  /// العربية: يخزن القيمة `color`.
  final Color color;

  /// Constructs the MiniDNALoaderPainter value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `MiniDNALoaderPainter`.
  _MiniDNALoaderPainter({
    required this.animationValue,
    required this.color,
  });

  /// Processes the paint flow and maps it into the property feature behavior.
  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    const pointCount = 8;
    final waveHeight = size.height / 3;
    final dx = size.width / (pointCount - 1);

    for (int j = 0; j < 2; j++) {
      final path = Path();
      final paint = Paint()
        ..color = color.withOpacity(0.6 - (j * 0.2))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < pointCount; i++) {
        final x = i * dx;
        final angle =
            (i / pointCount) * 2 * math.pi + (animationValue * 2 * math.pi);
        final y =
            size.height / 2 + math.sin(angle + (j * math.pi)) * waveHeight;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);

      // رسم النقاط
      for (int i = 0; i < pointCount; i++) {
        final x = i * dx;
        final angle =
            (i / pointCount) * 2 * math.pi + (animationValue * 2 * math.pi);
        final y =
            size.height / 2 + math.sin(angle + (j * math.pi)) * waveHeight;

        canvas.drawCircle(
          Offset(x, y),
          2,
          Paint()
            ..color = color.withOpacity(0.8)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  /// Processes the shouldRepaint flow and maps it into the property feature behavior.
  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
