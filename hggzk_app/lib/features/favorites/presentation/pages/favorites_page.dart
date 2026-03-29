import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';
import '../widgets/favorite_property_card_widget.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';
import 'package:hggzk/core/services/local_storage_service.dart';
import '../../../../core/constants/storage_constants.dart';

/// Describes the `FavoritesPage` page widget.
/// العربية: يمثل عنصر الصفحة `FavoritesPage`.
class FavoritesPage extends StatefulWidget {
  /// Builds a new `FavoritesPage` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `FavoritesPage`.
  const FavoritesPage({super.key});

  /// Builds the state object for this widget.
  /// العربية: ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

/// Describes the state for `FavoritesPageState`.
/// العربية: يمثل الحالة الخاصة بـ `FavoritesPageState`.
class _FavoritesPageState extends State<FavoritesPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  /// Keeps the `fadeController` value.
  /// العربية: يخزن القيمة `fadeController`.
  late AnimationController _fadeController;

  /// Keeps the `glowController` value.
  /// العربية: يخزن القيمة `glowController`.
  late AnimationController _glowController;

  /// Keeps the `particleController` value.
  /// العربية: يخزن القيمة `particleController`.
  late AnimationController _particleController;

  /// Keeps the `filterController` value.
  /// العربية: يخزن القيمة `filterController`.
  late AnimationController _filterController;

  // Animations
  /// Keeps the `fadeAnimation` value.
  /// العربية: يخزن القيمة `fadeAnimation`.
  late Animation<double> _fadeAnimation;

  /// Keeps the `glowAnimation` value.
  /// العربية: يخزن القيمة `glowAnimation`.
  late Animation<double> _glowAnimation;

  /// Keeps the `particleAnimation` value.
  /// العربية: يخزن القيمة `particleAnimation`.
  late Animation<double> _particleAnimation;

  /// Keeps the `filterAnimation` value.
  /// العربية: يخزن القيمة `filterAnimation`.
  late Animation<double> _filterAnimation;

  // UI State
  final ScrollController _scrollController = ScrollController();

  /// Keeps the `particles` value.
  /// العربية: يخزن القيمة `particles`.
  final List<_MinimalParticle> _particles = [];

  /// Keeps the `selectedFilter` value.
  /// العربية: يخزن القيمة `selectedFilter`.
  String _selectedFilter = 'all';

  /// Keeps the `sortBy` value.
  /// العربية: يخزن القيمة `sortBy`.
  String _sortBy = 'recent';

  /// Indicates whether `isGridView` is enabled.
  /// العربية: يحدد ما إذا كانت القيمة `isGridView` مفعلة.
  bool _isGridView = false;

  // Search
  final TextEditingController _searchController = TextEditingController();

  /// Keeps the `searchQuery` value.
  /// العربية: يخزن القيمة `searchQuery`.
  String _searchQuery = '';

  /// Initializes the state for this widget.
  /// العربية: يهيئ الحالة الخاصة بهذا العنصر.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _loadFavorites();
  }

  /// Initializes the animations.
  /// العربية: يهيئ animations.
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _filterController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_particleController);

    _filterAnimation = CurvedAnimation(
      parent: _filterController,
      curve: Curves.easeOutQuart,
    );

    // Start animations
    _fadeController.forward();
    _filterController.forward();
  }

  /// Generates the particles.
  /// العربية: ينشئ particles.
  void _generateParticles() {
    for (int i = 0; i < 5; i++) {
      _particles.add(_MinimalParticle());
    }
  }

  /// Loads the favorites.
  /// العربية: يحمل favorites.
  void _loadFavorites() {
    context.read<FavoritesBloc>().add(const LoadFavoritesEvent());
  }

  /// Releases the resources used by this instance.
  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _fadeController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _filterController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Builds the widget tree for this component.
  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Premium animated background
          _buildPremiumBackground(),

          // Floating particles
          _buildFloatingParticles(),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Premium App Bar
                _buildPremiumAppBar(),

                // Search and Filters
                _buildSearchAndFilters(),

                // Content
                Expanded(
                  child: BlocBuilder<FavoritesBloc, FavoritesState>(
                    builder: (context, state) {
                      if (state is FavoritesLoading) {
                        return _buildLoadingState();
                      }

                      if (state is FavoritesError) {
                        return _buildErrorState(state.message);
                      }

                      if (state is FavoritesLoaded) {
                        if (state.favorites.isEmpty) {
                          return _buildEmptyState();
                        }

                        final filteredFavorites =
                            _filterAndSortFavorites(state.favorites);

                        if (filteredFavorites.isEmpty) {
                          return _buildNoResultsState();
                        }

                        return _buildFavoritesList(filteredFavorites);
                      }

                      return _buildInitialState();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the premium background.
  /// العربية: يبني premium background.
  Widget _buildPremiumBackground() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground.withOpacity(0.95),
                AppTheme.darkSurface.withOpacity(0.9),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _PremiumBackgroundPainter(
              animation: _particleAnimation.value,
              glowIntensity: _glowAnimation.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  /// Builds the floating particles.
  /// العربية: يبني floating particles.
  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            animation: _particleController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  /// Builds the premium app bar.
  /// العربية: يبني premium app bar.
  Widget _buildPremiumAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Title with gradient
          Expanded(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.8),
                      AppTheme.primaryPurple.withOpacity(0.8),
                    ],
                    stops: [
                      0.3 + 0.2 * _glowAnimation.value,
                      0.7 + 0.2 * _glowAnimation.value,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    context.tr('favorites.title'),
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),

          // View toggle
          _buildMinimalIconButton(
            icon: Icons.search_rounded,
            onTap: () {
              final normalized = _searchQuery.trim();
              context.push('/search',
                  extra: normalized.isEmpty
                      ? const <String, dynamic>{}
                      : <String, dynamic>{'searchTerm': normalized});
            },
          ),
          const SizedBox(width: 8),

          _buildMinimalIconButton(
            icon:
                _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
    );
  }

  /// Builds the minimal icon button.
  /// العربية: يبني minimal icon button.
  Widget _buildMinimalIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.03),
              Colors.white.withOpacity(0.01),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: AppTheme.textWhite.withOpacity(0.7),
        ),
      ),
    );
  }

  /// Builds the search and filters.
  /// العربية: يبني search and filters.
  Widget _buildSearchAndFilters() {
    return FadeTransition(
      opacity: _filterAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            // Search bar
            Container(
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkCard.withOpacity(0.5),
                    AppTheme.darkCard.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.darkBorder.withOpacity(0.08),
                  width: 0.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: TextField(
                    controller: _searchController,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textWhite.withOpacity(0.9),
                    ),
                    decoration: InputDecoration(
                      hintText: context.tr(
                        'favorites.searchHint',
                      ),
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textMuted.withOpacity(0.4),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: AppTheme.textMuted.withOpacity(0.4),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the favorites list.
  /// العربية: يبني favorites list.
  Widget _buildFavoritesList(List<dynamic> favorites) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          context.read<FavoritesBloc>().add(const RefreshFavoritesEvent());
        },
        color: AppTheme.primaryBlue,
        backgroundColor: AppTheme.darkCard,
        child: _isGridView
            ? GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  return FavoritePropertyCardWidget(
                    favorite: favorites[index],
                    isGridView: true,
                    animationDelay: Duration(milliseconds: index * 50),
                    onTap: () => _navigateToProperty(favorites[index]),
                    onRemove: () => _removeFromFavorites(favorites[index]),
                  );
                },
              )
            : ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  return FavoritePropertyCardWidget(
                    favorite: favorites[index],
                    isGridView: false,
                    animationDelay: Duration(milliseconds: index * 50),
                    onTap: () => _navigateToProperty(favorites[index]),
                    onRemove: () => _removeFromFavorites(favorites[index]),
                  );
                },
              ),
      ),
    );
  }

  /// Builds the loading state.
  /// العربية: يبني loading state.
  Widget _buildLoadingState() {
    return Center(
      child: LoadingWidget(
        type: LoadingType.futuristic,
        message: context.tr('common.loading'),
      ),
    );
  }

  /// Builds the empty state.
  /// العربية: يبني empty state.
  Widget _buildEmptyState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkCard.withOpacity(0.4),
                    AppTheme.darkCard.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.darkBorder.withOpacity(0.08),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.1),
                          AppTheme.primaryPurple.withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_outline_rounded,
                      size: 32,
                      color: AppTheme.primaryBlue.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr(
                      'favorites.emptyTitle',
                    ),
                    style: AppTextStyles.h3.copyWith(
                      color: AppTheme.textWhite.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr(
                      'favorites.emptySubtitle',
                    ),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textMuted.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.go('/properties');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryBlue,
                            AppTheme.primaryPurple
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        context.tr(
                          'favorites.browseProperties',
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the no results state.
  /// العربية: يبني no results state.
  Widget _buildNoResultsState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppTheme.textMuted.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr(
                'favorites.noResultsTitle',
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.tr(
                'favorites.noResultsSubtitle',
              ),
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the error state.
  /// العربية: يبني error state.
  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.error.withOpacity(0.08),
              AppTheme.error.withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.error.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppTheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.error.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _loadFavorites,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.error.withOpacity(0.7),
                      AppTheme.error.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.tr('common.retry'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the initial state.
  /// العربية: يبني initial state.
  Widget _buildInitialState() {
    return const SizedBox.shrink();
  }

  /// Processes `filterAndSortFavorites`.
  /// العربية: يعالج `filterAndSortFavorites`.
  List<dynamic> _filterAndSortFavorites(List<dynamic> favorites) {
    var filtered = favorites.where((favorite) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = (favorite.propertyName ?? '').toString().toLowerCase();
        final location =
            (favorite.propertyLocation ?? '').toString().toLowerCase();

        if (!title.contains(query) && !location.contains(query)) {
          return false;
        }
      }

      // Type filter
      if (_selectedFilter != 'all') {
        final typeName = (favorite.typeName ?? '').toString().toLowerCase();
        if (!typeName.contains(_selectedFilter.toLowerCase())) return false;
      }

      return true;
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'recent':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'price_low':
        filtered.sort((a, b) => (a.minPrice ?? 0).compareTo(b.minPrice ?? 0));
        break;
      case 'price_high':
        filtered.sort((a, b) => (b.minPrice ?? 0).compareTo(a.minPrice ?? 0));
        break;
      case 'name':
        filtered.sort(
            (a, b) => (a.propertyName ?? '').compareTo(b.propertyName ?? ''));
        break;
    }

    return filtered;
  }

  /// Navigates to the to property.
  /// العربية: ينتقل إلى to property.
  void _navigateToProperty(dynamic favorite) {
    HapticFeedback.lightImpact();
    context.push('/property/${favorite.propertyId}');
  }

  /// Removes the from favorites.
  /// العربية: يزيل from favorites.
  void _removeFromFavorites(dynamic favorite) {
    HapticFeedback.mediumImpact();
    final uid =
        (sl<LocalStorageService>().getData(StorageConstants.userId) ?? '')
            .toString();
    context.read<FavoritesBloc>().add(
          RemoveFromFavoritesEvent(
            propertyId: favorite.propertyId,
            userId: uid,
          ),
        );
  }
}

// Minimal Particle
/// Describes `MinimalParticle`.
/// العربية: يمثل `MinimalParticle`.
class _MinimalParticle {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double vx = (math.Random().nextDouble() - 0.5) * 0.0003;
  double vy = (math.Random().nextDouble() - 0.5) * 0.0003;
  double radius = math.Random().nextDouble() + 0.5;
  double opacity = math.Random().nextDouble() * 0.05 + 0.02;
  Color color = [
    AppTheme.primaryBlue,
    AppTheme.primaryPurple,
    AppTheme.primaryCyan,
  ][math.Random().nextInt(3)];

  /// Updates the required operation for `update`.
  /// العربية: يحدّث العملية المطلوبة لـ `update`.
  void update() {
    x += vx;
    y += vy;
    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;
  }
}

// Painters
/// Describes `PremiumBackgroundPainter`.
/// العربية: يمثل `PremiumBackgroundPainter`.
class _PremiumBackgroundPainter extends CustomPainter {
  /// Keeps the `animation` value.
  /// العربية: يخزن القيمة `animation`.
  final double animation;

  /// Keeps the `glowIntensity` value.
  /// العربية: يخزن القيمة `glowIntensity`.
  final double glowIntensity;

  /// Builds a new `PremiumBackgroundPainter` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `PremiumBackgroundPainter`.
  _PremiumBackgroundPainter({
    required this.animation,
    required this.glowIntensity,
  });

  /// Processes `paint`.
  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.15
      ..color = AppTheme.primaryBlue.withOpacity(0.015 * glowIntensity);

    const spacing = 50.0;
    final offset = animation * spacing;

    for (double x = -spacing + offset % spacing;
        x < size.width + spacing;
        x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  /// Processes `shouldRepaint`.
  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Describes `ParticlePainter`.
/// العربية: يمثل `ParticlePainter`.
class _ParticlePainter extends CustomPainter {
  /// Keeps the `particles` value.
  /// العربية: يخزن القيمة `particles`.
  final List<_MinimalParticle> particles;

  /// Keeps the `animation` value.
  /// العربية: يخزن القيمة `animation`.
  final double animation;

  /// Builds a new `ParticlePainter` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ParticlePainter`.
  _ParticlePainter({
    required this.particles,
    required this.animation,
  });

  /// Processes `paint`.
  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();

      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius,
        paint,
      );
    }
  }

  /// Processes `shouldRepaint`.
  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
