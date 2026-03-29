// lib/features/search/presentation/pages/search_page.dart (محسّنة ومُحدثة)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hggzk/core/widgets/error_widget.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/search_input_widget.dart';
import '../widgets/filter_chips_widget.dart';
import '../widgets/search_result_list_widget.dart';
import '../widgets/search_result_compact_widget.dart';
import 'search_filters_page.dart';
import 'search_results_map_page.dart';
import '../../domain/entities/search_navigation_params.dart';
import '../../domain/entities/search_result.dart';

/// Primary property search screen that combines query input, filters, and
/// result presentation.
/// شاشة البحث الرئيسية التي تجمع حقل البحث والفلاتر وعرض النتائج.
class SearchPage extends StatefulWidget {
  /// Optional navigation payload used to seed the first search.
  /// حمولة تنقل اختيارية لتهيئة البحث الأول.
  final SearchNavigationParams? initialParams;

  /// Builds the search screen with an optional initial payload.
  /// ينشئ شاشة البحث مع حمولة ابتدائية اختيارية.
  const SearchPage({super.key, this.initialParams});

  /// Builds the state object for this widget.
  /// ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<SearchPage> createState() => _SearchPageState();
}

/// Manages the animated background, current filters, and the active search
/// result snapshot.
/// يدير الخلفية المتحركة والفلاتر الحالية ولقطة نتائج البحث النشطة.
class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  /// Last filter payload that was applied to the search bloc.
  /// آخر حمولة فلاتر طُبقت على bloc البحث.
  Map<String, dynamic> _lastFilters = {};
  final ScrollController _scrollController = ScrollController();

  // Enhanced Animation Controllers
  /// Drives the page entrance fade.
  /// يقود تلاشي دخول الصفحة.
  late AnimationController _fadeController;

  /// Moves the content into view from below.
  /// يحرك المحتوى إلى الداخل من الأسفل.
  late AnimationController _slideController;

  /// Adds a subtle scale-in effect to the page shell.
  /// يضيف تأثير تكبير خفيف لغلاف الصفحة.
  late AnimationController _scaleController;

  /// Animates the soft glow layers.
  /// يحرك طبقات التوهج الناعم.
  late AnimationController _glowController;

  /// Animates the background particles.
  /// يحرك جسيمات الخلفية.
  late AnimationController _particleController;

  /// Drives the ripple motion behind filters and cards.
  /// يقود حركة التموج خلف الفلاتر والبطاقات.
  late AnimationController _rippleController;

  /// Smooths the morphing visual accents.
  /// ينسّق الزخارف المرنة المتحركة.
  late AnimationController _morphController;

  /// Drives the parallax offset used by layered elements.
  /// يقود إزاحة المنظر المستخدم للعناصر المتعددة الطبقات.
  late AnimationController _parallaxController;

  // Enhanced Animations
  /// Fade curve applied to the full page.
  /// منحنى التلاشي المطبق على الصفحة بالكامل.
  late Animation<double> _fadeAnimation;

  /// Slide offset used by the main content column.
  /// إزاحة الانزلاق المستخدمة لعمود المحتوى الرئيسي.
  late Animation<Offset> _slideAnimation;

  /// Scale curve used by the page shell.
  /// منحنى التكبير المستخدم لغلاف الصفحة.
  late Animation<double> _scaleAnimation;

  /// Glow intensity used by decorative highlights.
  /// شدة التوهج المستخدمة في اللمعات الزخرفية.
  late Animation<double> _glowAnimation;

  /// Ripple progress for background waves.
  /// تقدم التموج لموجات الخلفية.
  late Animation<double> _rippleAnimation;

  /// Morph value used by animated accents.
  /// قيمة التشكل المستخدمة في الزخارف المتحركة.
  late Animation<double> _morphAnimation;

  /// Parallax value for layered motion.
  /// قيمة المنظر للحركة الطبقية.
  late Animation<double> _parallaxAnimation;

  // Ultra Particles System
  /// Background particles used for atmosphere.
  /// جسيمات الخلفية المستخدمة لإضفاء الجو.
  final List<_UltraParticle> _particles = [];

  /// Floating orbs used in the animated background.
  /// الكرات الطافية المستخدمة في الخلفية المتحركة.
  final List<_FloatingOrb> _orbs = [];

  // View State
  /// Current vertical scroll offset.
  /// إزاحة التمرير العمودية الحالية.
  double _scrollOffset = 0;

  /// Last successful result snapshot shown to the user.
  /// آخر لقطة نجاح معروضة للمستخدم.
  SearchSuccess? _lastSuccess;

  /// Visible search text mirrored from the composer.
  /// نص البحث الظاهر المنعكس من المحرر.
  String _searchInputValue = '';

  /// Initializes the page animation stack and restores the search context.
  /// يهيئ حزمة الحركة ويستعيد سياق البحث.
  @override
  void initState() {
    super.initState();
    _initializeUltraAnimations();
    _generateUltraParticles();
    _setupScrollListener();
    context.read<SearchBloc>().add(const GetSearchFiltersEvent());
    _applyInitialParams();
  }

  /// Initializes the page animation stack.
  /// يهيئ حزمة حركات الصفحة.
  void _initializeUltraAnimations() {
    // Fade Animation with curve
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutExpo,
    ));

    // Slide with elastic curve
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    // Scale with bounce
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.bounceOut,
    ));

    // Continuous glow
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Ripple effect
    _rippleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rippleController);

    // Morph animation
    _morphController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _morphAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOut,
    ));

    // Parallax effect
    _parallaxController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    _parallaxAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(_parallaxController);

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    // Start all animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  /// العربية: ينشئ ultra particles.
  void _generateUltraParticles() {
    // Generate particles
    for (int i = 0; i < 30; i++) {
      _particles.add(_UltraParticle());
    }

    // Generate floating orbs
    for (int i = 0; i < 5; i++) {
      _orbs.add(_FloatingOrb());
    }
  }

  /// العربية: يضبط up scroll listener.
  void _setupScrollListener() {
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
      _onScroll();
    });
  }

  /// العربية: يعالج `applyInitialParams`.
  void _applyInitialParams() {
    if (widget.initialParams != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final params = widget.initialParams!;
        final initialFilters = _sanitizeSearchFilters(<String, dynamic>{
          'propertyTypeId': params.propertyTypeId,
          'unitTypeId': params.unitTypeId,
          'city': params.city,
          'searchTerm': params.searchTerm,
          'checkIn': params.checkIn,
          'checkOut': params.checkOut,
          'adults': params.adults,
          'children': params.children,
          'guestsCount': params.guestsCount,
        }..removeWhere((key, value) => value == null));

        context
            .read<SearchBloc>()
            .add(UpdateSearchFiltersEvent(filters: initialFilters));
        if (initialFilters.isNotEmpty) {
          _lastFilters = initialFilters;
          _searchInputValue = (initialFilters['searchTerm'] as String?) ?? '';
          _performSearch(initialFilters);
        }
      });
    }
  }

  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _rippleController.dispose();
    _morphController.dispose();
    _parallaxController.dispose();
    super.dispose();
  }

  /// العربية: يعالج `onScroll`.
  void _onScroll() {
    if (_isBottom) {
      context.read<SearchBloc>().add(const LoadMoreSearchResultsEvent());
    }
  }

  /// العربية: يعيد القيمة `isBottom`.
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Ultra-futuristic animated background
          _buildUltraAnimatedBackground(),

          // Floating particles system
          _buildUltraParticles(),

          // Floating orbs
          _buildFloatingOrbs(),

          // Main content with glass effect
          SafeArea(
            child: Column(
              children: [
                _buildUltraFuturisticHeader(),
                Expanded(
                  child: BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      if (state is SearchCombinedState) {
                        final nested = state.searchResultsState;
                        if (nested is SearchSuccess) {
                          _lastSuccess = nested;
                          return _buildUltraResultsView(nested);
                        }
                        if (nested == null || nested is SearchInitial) {
                          if (_lastSuccess != null) {
                            return _buildUltraResultsView(_lastSuccess!);
                          }
                          return _buildUltraInitialView();
                        }
                        if (nested is SearchLoading) {
                          return _buildUltraLoadingView();
                        }
                        if (nested is SearchError) {
                          return _buildUltraErrorView(nested.message);
                        }
                        if (nested is SearchLoadingMore) {
                          if (_lastSuccess != null) {
                            return _buildUltraResultsView(
                              _lastSuccess!,
                              isLoadingMore: true,
                            );
                          }
                          return _buildUltraResultsView(
                            SearchSuccess(
                              searchResults: nested.currentResults,
                              currentFilters: _lastFilters,
                            ),
                            isLoadingMore: true,
                          );
                        }
                        return const SizedBox.shrink();
                      }
                      // Legacy state handling
                      if (state is SearchInitial) {
                        if (_lastSuccess != null) {
                          return _buildUltraResultsView(_lastSuccess!);
                        }
                        return _buildUltraInitialView();
                      } else if (state is SearchLoading) {
                        return _buildUltraLoadingView();
                      } else if (state is SearchSuccess) {
                        _lastSuccess = state;
                        return _buildUltraResultsView(state);
                      } else if (state is SearchLoadingMore) {
                        if (_lastSuccess != null) {
                          return _buildUltraResultsView(
                            _lastSuccess!,
                            isLoadingMore: true,
                          );
                        }
                        return _buildUltraResultsView(
                          SearchSuccess(
                            searchResults: state.currentResults,
                            currentFilters: _lastFilters,
                          ),
                          isLoadingMore: true,
                        );
                      } else if (state is SearchError) {
                        return _buildUltraErrorView(state.message);
                      }
                      return const SizedBox.shrink();
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

  /// العربية: يبني ultra animated background.
  Widget _buildUltraAnimatedBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _morphAnimation,
        _parallaxAnimation,
        _rippleAnimation,
      ]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2,
                AppTheme.darkBackground3,
                AppTheme.darkBackground3,
              ],
            ),
          ),
          child: CustomPaint(
            painter: _UltraFuturisticBackgroundPainter(
              morph: _morphAnimation.value,
              parallax: _parallaxAnimation.value,
              ripple: _rippleAnimation.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  /// العربية: يبني ultra particles.
  Widget _buildUltraParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: _UltraParticlePainter(
            particles: _particles,
            animationValue: _particleController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  /// العربية: يبني floating orbs.
  Widget _buildFloatingOrbs() {
    return AnimatedBuilder(
      animation: _morphController,
      builder: (context, child) {
        return CustomPaint(
          painter: _FloatingOrbPainter(
            orbs: _orbs,
            animationValue: _morphController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  /// العربية: يبني ultra futuristic header.
  Widget _buildUltraFuturisticHeader() {
    final headerOpacity = 1.0 - (_scrollOffset / 150).clamp(0.0, 0.4);
    final headerBlur = (_scrollOffset / 10).clamp(0.0, 20.0);

    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _rippleAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.darkCard.withOpacity(0.9 * headerOpacity),
                AppTheme.darkCard.withOpacity(0.6 * headerOpacity),
                AppTheme.darkCard.withOpacity(0.0),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue
                    .withOpacity(_glowAnimation.value * 0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: headerBlur, sigmaY: headerBlur),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildUltraSearchBar(),
                    _buildUltraActiveFilters(),
                    _buildUltraResultsBar(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// العربية: يبني ultra search bar.
  Widget _buildUltraSearchBar() {
    return BlocSelector<SearchBloc, SearchState, List<String>>(
      selector: (state) {
        if (state is SearchCombinedState &&
            state.suggestionsState is SearchSuggestionsLoaded) {
          return (state.suggestionsState as SearchSuggestionsLoaded)
              .suggestions;
        }
        if (state is SearchSuggestionsLoaded) {
          return state.suggestions;
        }
        return const <String>[];
      },
      builder: (context, suggestions) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth.isFinite
                      ? constraints.maxWidth
                      : MediaQuery.of(context).size.width;

                  return SizedBox(
                    width: maxWidth,
                    child: Row(
                      children: [
                        // Ultra-modern back button
                        _buildNeonGlowButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          size: 36,
                        ),

                        const SizedBox(width: 10),

                        // Search field (expanded)
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.darkCard.withOpacity(0.6),
                                  AppTheme.darkCard.withOpacity(0.4),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.primaryBlue.withOpacity(0.2),
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color: AppTheme.neonBlue.withOpacity(0.1),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: SearchInputWidget(
                              initialValue: _searchInputValue,
                              onChanged: (query) {
                                _searchInputValue = query;
                                final trimmed = query.trim();
                                if (trimmed.length >= 2) {
                                  context.read<SearchBloc>().add(
                                        GetSearchSuggestionsEvent(
                                          query: trimmed,
                                          limit: 8,
                                        ),
                                      );
                                } else {
                                  context.read<SearchBloc>().add(
                                        const ClearSearchSuggestionsEvent(),
                                      );
                                }
                              },
                              onSubmitted: (query) {
                                HapticFeedback.mediumImpact();
                                _performSearchByText(query);
                              },
                              onSuggestionSelected: (query) {
                                HapticFeedback.selectionClick();
                                _performSearchByText(query);
                              },
                              onClear: () {
                                _searchInputValue = '';
                                context.read<SearchBloc>().add(
                                      const ClearSearchSuggestionsEvent(),
                                    );
                                final updatedFilters =
                                    Map<String, dynamic>.from(_lastFilters)
                                      ..remove('searchTerm');
                                _lastFilters = updatedFilters;
                                context.read<SearchBloc>().add(
                                      UpdateSearchFiltersEvent(
                                          filters: updatedFilters),
                                    );
                                _performSearch(updatedFilters);
                              },
                              suggestions: suggestions,
                              autofocus: false,
                              showSuggestions: true,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Ultra filter button
                        _buildUltraFilterButton(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// العربية: يبني neon glow button.
  Widget _buildNeonGlowButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 40,
    Color? color,
  }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: onPressed,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  (color ?? AppTheme.primaryBlue)
                      .withOpacity(_glowAnimation.value * 0.3),
                  Colors.transparent,
                ],
                radius: 1.5,
              ),
              shape: BoxShape.circle,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkCard.withOpacity(0.7),
                    AppTheme.darkCard.withOpacity(0.4),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: (color ?? AppTheme.primaryBlue).withOpacity(0.3),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (color ?? AppTheme.primaryBlue)
                        .withOpacity(0.2 * _glowAnimation.value),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color ?? AppTheme.textWhite,
                size: size * 0.5,
              ),
            ),
          ),
        );
      },
    );
  }

  /// العربية: يبني ultra filter button.
  Widget _buildUltraFilterButton() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        bool hasFilters = false;
        if (state is SearchCombinedState &&
            state.searchResultsState is SearchSuccess) {
          hasFilters = (state.searchResultsState as SearchSuccess)
              .currentFilters
              .isNotEmpty;
        } else if (state is SearchSuccess) {
          hasFilters = state.currentFilters.isNotEmpty;
        }

        return AnimatedBuilder(
          animation: _rippleAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                // Ripple effect when has filters
                if (hasFilters)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.neonPurple
                              .withOpacity(0.3 * (1 - _rippleAnimation.value)),
                          width: 2 * _rippleAnimation.value,
                        ),
                      ),
                    ),
                  ),

                _buildNeonGlowButton(
                  icon: Icons.tune_rounded,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _openFilters();
                  },
                  color: hasFilters ? AppTheme.neonPurple : null,
                  size: 36,
                ),

                // Notification dot
                if (hasFilters)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.neonPurple,
                                  AppTheme.neonBlue,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.neonPurple,
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  /// العربية: يبني ultra active filters.
  Widget _buildUltraActiveFilters() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        Map<String, dynamic> currentFilters = {};
        if (state is SearchCombinedState &&
            state.searchResultsState is SearchSuccess) {
          currentFilters =
              (state.searchResultsState as SearchSuccess).currentFilters;
        } else if (state is SearchSuccess) {
          currentFilters = state.currentFilters;
        }

        if (currentFilters.isEmpty) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: 47,
          margin: const EdgeInsets.only(bottom: 8),
          child: FilterChipsWidget(
            filters: currentFilters,
            onRemoveFilter: (key) {
              // منع حذف الحقول المطلوبة
              if (_isRequiredField(key, currentFilters)) {
                _showRequiredFieldError(key);
                return;
              }

              HapticFeedback.lightImpact();
              final updatedFilters = Map<String, dynamic>.from(
                currentFilters,
              )..remove(key);

              // إذا تم حذف نوع العقار، احذف نوع الوحدة المرتبطة به
              if (key == 'propertyTypeId') {
                updatedFilters.remove('unitTypeId');
              }

              // إذا تم حذف نوع الوحدة
              if (key == 'unitTypeId') {}

              context.read<SearchBloc>().add(
                    UpdateSearchFiltersEvent(filters: updatedFilters),
                  );

              _performSearch(updatedFilters);
            },
            onClearAll: () {
              HapticFeedback.mediumImpact();

              // احتفظ بالحقول المطلوبة عند مسح الكل
              final requiredFields = _extractRequiredFields(currentFilters);

              if (requiredFields.isNotEmpty) {
                context.read<SearchBloc>().add(
                      UpdateSearchFiltersEvent(filters: requiredFields),
                    );
                _performSearch(requiredFields);
              } else {
                context.read<SearchBloc>().add(const ClearSearchEvent());
              }
            },
          ),
        );
      },
    );
  }

  /// العربية: يبني ultra results bar.
  Widget _buildUltraResultsBar() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        SearchSuccess? s;
        if (state is SearchCombinedState &&
            state.searchResultsState is SearchSuccess) {
          s = state.searchResultsState as SearchSuccess;
        } else if (state is SearchSuccess) {
          s = state;
        }

        if (s == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Results count with animation
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryBlue.withOpacity(0.15),
                            AppTheme.primaryPurple.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppTheme.neonBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${s?.searchResults.totalCount ?? 0}',
                            style: AppTextStyles.overline.copyWith(
                              color: AppTheme.neonBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.tr('search.resultsLabel'),
                            style: AppTextStyles.overline.copyWith(
                              color: AppTheme.textMuted.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Sort and view options
              Row(
                children: [
                  // View mode toggle
                  _buildUltraViewModeToggle(s.viewMode),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// العربية: يبني ultra view mode toggle.
  Widget _buildUltraViewModeToggle(ViewMode currentMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.7),
            AppTheme.darkCard.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewModeButton(
            icon: Icons.view_list_rounded,
            isSelected: currentMode == ViewMode.list,
            onTap: () => _changeViewMode(ViewMode.list),
          ),
          Container(
            width: 0.5,
            height: 16,
            color: AppTheme.darkBorder.withOpacity(0.2),
          ),
          _buildViewModeButton(
            icon: Icons.view_compact_rounded,
            isSelected: currentMode == ViewMode.grid,
            onTap: () => _changeViewMode(ViewMode.grid),
          ),
          Container(
            width: 0.5,
            height: 16,
            color: AppTheme.darkBorder.withOpacity(0.2),
          ),
          _buildViewModeButton(
            icon: Icons.map_rounded,
            isSelected: currentMode == ViewMode.map,
            onTap: () => _changeViewMode(ViewMode.map),
          ),
        ],
      ),
    );
  }

  /// العربية: يبني view mode button.
  Widget _buildViewModeButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isSelected
                ? AppTheme.textWhite
                : AppTheme.textMuted.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  /// العربية: يعالج `changeViewMode`.
  void _changeViewMode(ViewMode mode) {
    context.read<SearchBloc>().add(ToggleViewModeEvent(mode: mode));
  }

  /// العربية: يبني ultra initial view.
  Widget _buildUltraInitialView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUltraRecentSearches(),
              const SizedBox(height: 24),
              _buildUltraSearchCategories(),
              const SizedBox(height: 24),
              _buildUltraTrendingProperties(),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Continue with remaining methods)
  /// العربية: يبني ultra recent searches.
  Widget _buildUltraRecentSearches() {
    // Implementation
    return const SizedBox();
  }

  /// العربية: يبني ultra search categories.
  Widget _buildUltraSearchCategories() {
    // Implementation
    return const SizedBox();
  }

  /// العربية: يبني ultra trending properties.
  Widget _buildUltraTrendingProperties() {
    // Implementation
    return const SizedBox();
  }

  /// العربية: يبني ultra loading view.
  Widget _buildUltraLoadingView() {
    return Center(
      child: LoadingWidget(
        type: LoadingType.futuristic,
        message: context.tr('search.loading'),
      ),
    );
  }

  /// العربية: يبني ultra results view.
  Widget _buildUltraResultsView(
    SearchSuccess state, {
    bool isLoadingMore = false,
  }) {
    if (state.viewMode == ViewMode.map) {
      return SearchResultsMapPage(
        results: state.searchResults.items,
        onBackToList: () {
          context.read<SearchBloc>().add(const ToggleViewModeEvent());
        },
      );
    }

    if (state.searchResults.items.isEmpty) {
      return _buildUltraEmptyResults();
    }

    // ✅ استخراج معلومات التخفيف
    final hasRelaxation = state.relaxationInfo?.wasRelaxed ?? false;
    print('🔍 [SearchPage] hasRelaxation: $hasRelaxation');
    if (state.relaxationInfo != null) {
      print(
          '🔍 [SearchPage] relaxationInfo.level: ${state.relaxationInfo!.relaxationLevel}');
      print(
          '🔍 [SearchPage] relaxationInfo.userMessage: ${state.relaxationInfo!.userMessage}');
    }

    return Column(
      children: [
        // ✅ قائمة النتائج
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              _performSearch(state.currentFilters);
            },
            color: AppTheme.neonBlue,
            backgroundColor: AppTheme.darkCard,
            child: state.viewMode == ViewMode.list
                ? SearchResultListWidget(
                    results: state.searchResults.items,
                    scrollController: _scrollController,
                    isLoadingMore: isLoadingMore,
                    relaxationLevel: state.relaxationInfo?.relaxationLevel,
                    onItemTap: (result) {
                      HapticFeedback.lightImpact();
                      context.push(
                        '/property/${result.id}',
                        extra: _buildPropertyNavigationExtra(
                            result, state.currentFilters),
                      );
                    },
                  )
                : SearchResultCompactWidget(
                    results: state.searchResults.items,
                    scrollController: _scrollController,
                    isLoadingMore: isLoadingMore,
                    relaxationLevel: state.relaxationInfo?.relaxationLevel,
                    onItemTap: (result) {
                      HapticFeedback.lightImpact();
                      context.push(
                        '/property/${result.id}',
                        extra: _buildPropertyNavigationExtra(
                            result, state.currentFilters),
                      );
                    },
                  ),
          ),
        ),

        // ✅ عرض الاقتراحات في الأسفل
        // if (hasRelaxation && state.relaxationInfo?.hasSuggestions == true)
        //   SuggestedActionsWidget(
        //     suggestions: state.relaxationInfo!.suggestedActions,
        //     onActionTap: (suggestion) {
        //       HapticFeedback.lightImpact();
        //     },
        //   ),
      ],
    );
  }

  /// العربية: يبني ultra empty results.
  Widget _buildUltraEmptyResults() {
    return CustomErrorWidget(
      type: ErrorType.notFound,
      message: context.tr('search.tryDifferentCriteria'),
      onRetry: () {
        HapticFeedback.mediumImpact();
        context.read<SearchBloc>().add(const ClearSearchEvent());
      },
    );
  }

  /// العربية: يبني property navigation extra.
  Map<String, dynamic> _buildPropertyNavigationExtra(
    SearchResult result,
    Map<String, dynamic> filters,
  ) {
    DateTime? asDate(dynamic value) {
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

    int? asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    String? asString(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    final dynamicRaw = filters['dynamicFieldValues'];
    final dynamicValues = dynamicRaw is Map
        ? dynamicRaw.map((key, value) => MapEntry(key.toString(), value))
        : const <String, dynamic>{};

    final checkIn =
        asDate(filters['checkIn']) ?? asDate(dynamicValues['checkIn']);
    final checkOut =
        asDate(filters['checkOut']) ?? asDate(dynamicValues['checkOut']);
    final adults = asInt(filters['adults']) ?? asInt(dynamicValues['adults']);
    final children =
        asInt(filters['children']) ?? asInt(dynamicValues['children']);
    final guestsCount = asInt(filters['guestsCount']);
    final unitTypeId = asString(filters['unitTypeId']) ??
        asString(dynamicValues['unitTypeId']);

    return {
      if (result.unitId != null && result.unitId!.trim().isNotEmpty)
        'unitId': result.unitId,
      if (checkIn != null) 'checkInDate': checkIn,
      if (checkOut != null) 'checkOutDate': checkOut,
      if (adults != null) 'adults': adults,
      if (children != null) 'children': children,
      if (guestsCount != null) 'guestsCount': guestsCount,
      if (unitTypeId != null) 'unitTypeId': unitTypeId,
    };
  }

  /// العربية: يبني ultra error view.
  Widget _buildUltraErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppTheme.error.withOpacity(0.7),
                  AppTheme.error.withOpacity(0.5),
                ],
              ),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('search.errorTitle'),
            style: AppTextStyles.h3.copyWith(
              color: AppTheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.read<SearchBloc>().add(const SearchPropertiesEvent());
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              context.tr('search.retry'),
            ),
          ),
        ],
      ),
    );
  }

  /// العربية: يفتح filters.
  void _openFilters() async {
    final filters = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => SearchFiltersPage(
          initialFilters: _lastFilters.isEmpty ? null : _lastFilters,
        ),
        fullscreenDialog: true,
      ),
    );

    if (!mounted) return;

    if (filters != null) {
      final sanitizedFilters = _sanitizeSearchFilters(filters);
      context.read<SearchBloc>().add(
            UpdateSearchFiltersEvent(filters: sanitizedFilters),
          );
      _lastFilters = sanitizedFilters;
      _searchInputValue = (sanitizedFilters['searchTerm'] as String?) ?? '';
      _performSearch(sanitizedFilters);
    }
  }

  /// العربية: يعالج `performSearchByText`.
  void _performSearchByText(String rawQuery) {
    final normalizedQuery = rawQuery.trim();
    _searchInputValue = normalizedQuery;

    final updatedFilters = Map<String, dynamic>.from(_lastFilters);
    if (normalizedQuery.isEmpty) {
      updatedFilters.remove('searchTerm');
    } else {
      updatedFilters['searchTerm'] = normalizedQuery;
    }
    final sanitizedFilters = _sanitizeSearchFilters(updatedFilters);

    context.read<SearchBloc>().add(
          UpdateSearchFiltersEvent(filters: sanitizedFilters),
        );
    _performSearch(sanitizedFilters);
    context.read<SearchBloc>().add(const ClearSearchSuggestionsEvent());
  }

  /// العربية: يعالج `performSearch`.
  void _performSearch(Map<String, dynamic> filters) {
    final sanitizedFilters = _sanitizeSearchFilters(filters);
    _lastFilters = Map<String, dynamic>.from(sanitizedFilters);
    final String? searchTerm = sanitizedFilters['searchTerm'] as String?;
    _searchInputValue = searchTerm ?? '';
    final String? city = sanitizedFilters['city'] as String?;
    final String? propertyTypeId =
        sanitizedFilters['propertyTypeId'] as String?;
    final double? minPrice = (sanitizedFilters['minPrice'] is num)
        ? (sanitizedFilters['minPrice'] as num).toDouble()
        : null;
    final double? maxPrice = (sanitizedFilters['maxPrice'] is num)
        ? (sanitizedFilters['maxPrice'] as num).toDouble()
        : null;
    final int? minStarRating = sanitizedFilters['minStarRating'] is int
        ? sanitizedFilters['minStarRating'] as int
        : int.tryParse(sanitizedFilters['minStarRating']?.toString() ?? '');
    final List<String>? requiredAmenities =
        sanitizedFilters['requiredAmenities'] != null
            ? List<String>.from(sanitizedFilters['requiredAmenities'])
            : null;
    final String? unitTypeId = sanitizedFilters['unitTypeId'] as String?;
    final List<String>? serviceIds = sanitizedFilters['serviceIds'] != null
        ? List<String>.from(sanitizedFilters['serviceIds'])
        : null;
    final DateTime? checkIn = sanitizedFilters['checkIn'] as DateTime?;
    final DateTime? checkOut = sanitizedFilters['checkOut'] as DateTime?;
    final int? adults = sanitizedFilters['adults'] as int?;
    final int? children = sanitizedFilters['children'] as int?;
    final int? guestsCount = sanitizedFilters['guestsCount'] as int?;
    final Map<String, dynamic>? dynamicFieldFilters =
        sanitizedFilters['dynamicFieldFilters'] != null
            ? Map<String, dynamic>.from(
                sanitizedFilters['dynamicFieldFilters'] as Map)
            : null;
    final double? latitude = (sanitizedFilters['latitude'] is num)
        ? (sanitizedFilters['latitude'] as num).toDouble()
        : null;
    final double? longitude = (sanitizedFilters['longitude'] is num)
        ? (sanitizedFilters['longitude'] as num).toDouble()
        : null;
    final double? radiusKm = (sanitizedFilters['radiusKm'] is num)
        ? (sanitizedFilters['radiusKm'] as num).toDouble()
        : null;
    final String? preferredCurrency =
        sanitizedFilters['preferredCurrency'] as String?;
    final String? sortBy = sanitizedFilters['sortBy'] as String?;

    context.read<SearchBloc>().add(
          UpdateSearchFiltersEvent(filters: _lastFilters),
        );

    context.read<SearchBloc>().add(
          SearchPropertiesEvent(
            searchTerm: searchTerm,
            city: city,
            propertyTypeId: propertyTypeId,
            minPrice: minPrice,
            maxPrice: maxPrice,
            minStarRating: minStarRating,
            requiredAmenities: requiredAmenities,
            unitTypeId: unitTypeId,
            serviceIds: serviceIds,
            checkIn: checkIn,
            checkOut: checkOut,
            adults: adults,
            children: children,
            guestsCount: guestsCount,
            dynamicFieldFilters: dynamicFieldFilters,
            latitude: latitude,
            longitude: longitude,
            radiusKm: radiusKm,
            preferredCurrency: preferredCurrency,
            sortBy: sortBy,
          ),
        );
  }

  /// العربية: يعالج `sanitizeSearchFilters`.
  Map<String, dynamic> _sanitizeSearchFilters(Map<String, dynamic> filters) {
    final sanitized = Map<String, dynamic>.from(filters);

    final searchTerm = sanitized['searchTerm']?.toString().trim() ?? '';
    if (searchTerm.isEmpty) {
      sanitized.remove('searchTerm');
    } else {
      sanitized['searchTerm'] = searchTerm;
    }

    final city = sanitized['city']?.toString().trim() ?? '';
    if (city.isEmpty) {
      sanitized.remove('city');
    } else {
      sanitized['city'] = city;
    }

    if (sanitized['propertyTypeId'] == null) {
      sanitized.remove('unitTypeId');
    }

    final guestsCount = sanitized['guestsCount'] as int?;
    final adults = sanitized['adults'] as int?;
    final children = sanitized['children'] as int?;
    if (guestsCount != null) {
      sanitized.remove('adults');
      sanitized.remove('children');
    } else if (adults != null || children != null) {
      final derivedGuests = (adults ?? 0) + (children ?? 0);
      if (derivedGuests > 0) {
        sanitized['guestsCount'] = derivedGuests;
      }
      sanitized.remove('adults');
      sanitized.remove('children');
    }

    if ((sanitized['requiredAmenities'] as List?)?.isEmpty ?? false) {
      sanitized.remove('requiredAmenities');
    }

    if ((sanitized['serviceIds'] as List?)?.isEmpty ?? false) {
      sanitized.remove('serviceIds');
    }

    if ((sanitized['dynamicFieldFilters'] as Map?)?.isEmpty ?? false) {
      sanitized.remove('dynamicFieldFilters');
    }

    // The current filter UI does not expose distance controls, so we must not
    // keep stale location filters hidden in the outgoing search payload.
    sanitized.remove('latitude');
    sanitized.remove('longitude');
    sanitized.remove('radiusKm');

    return sanitized;
  }

  /// العربية: يعالج `isRequiredField`.
  bool _isRequiredField(String key, Map<String, dynamic> filters) {
    // الحقول الأساسية المطلوبة
    if (key == 'propertyTypeId' || key == 'unitTypeId') {
      return true;
    }
    return false;
  }

  /// العربية: يعالج `extractRequiredFields`.
  Map<String, dynamic> _extractRequiredFields(Map<String, dynamic> filters) {
    final required = <String, dynamic>{};

    // احتفظ بنوع العقار ونوع الوحدة
    if (filters.containsKey('propertyTypeId')) {
      required['propertyTypeId'] = filters['propertyTypeId'];
    }

    if (filters.containsKey('unitTypeId')) {
      required['unitTypeId'] = filters['unitTypeId'];
    }

    return required;
  }

  /// العربية: يعرض required field error.
  void _showRequiredFieldError(String fieldKey) {
    String message = '';

    switch (fieldKey) {
      case 'propertyTypeId':
        message = context.tr('search.filters.propertyTypeRequired');
        break;
      case 'unitTypeId':
        message = context.tr('search.filters.unitTypeRequired');
        break;
      case 'checkIn':
        message = context.tr('search.filters.checkInRequired');
        break;
      case 'checkOut':
        message = context.tr('search.filters.checkOutRequired');
        break;
      default:
        message = context.tr('search.filters.requiredField');
    }

    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: AppTheme.warning,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.darkCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Painter Classes
// Ultra Futuristic Background Painter
/// العربية: يمثل `UltraFuturisticBackgroundPainter`.
class _UltraFuturisticBackgroundPainter extends CustomPainter {
  /// العربية: يخزن القيمة `morph`.
  final double morph;

  /// العربية: يخزن القيمة `parallax`.
  final double parallax;

  /// العربية: يخزن القيمة `ripple`.
  final double ripple;

  /// العربية: ينشئ مثيلًا جديدًا من `UltraFuturisticBackgroundPainter`.
  _UltraFuturisticBackgroundPainter({
    required this.morph,
    required this.parallax,
    required this.ripple,
  });

  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    // Implementation
  }

  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Ultra Particle Model
/// العربية: يمثل `UltraParticle`.
class _UltraParticle {
  /// العربية: يخزن القيمة `vy`.
  late double x, y, vx, vy;

  /// العربية: يخزن القيمة `glowRadius`.
  late double radius, opacity, glowRadius;

  /// العربية: يخزن القيمة `color`.
  late Color color;

  /// العربية: ينشئ مثيلًا جديدًا من `UltraParticle`.
  _UltraParticle() {
    reset();
  }

  /// العربية: يعالج `reset`.
  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    vx = (math.Random().nextDouble() - 0.5) * 0.001;
    vy = (math.Random().nextDouble() - 0.5) * 0.001;
    radius = math.Random().nextDouble() * 1.5 + 0.5;
    opacity = math.Random().nextDouble() * 0.3 + 0.1;
    glowRadius = math.Random().nextDouble() * 8 + 4;

    final colors = [
      AppTheme.neonBlue,
      AppTheme.neonPurple,
      AppTheme.neonGreen,
      AppTheme.primaryCyan,
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }

  /// العربية: يحدّث العملية المطلوبة لـ `update`.
  void update() {
    x += vx;
    y += vy;
    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;
  }
}

// Ultra Particle Painter
/// العربية: يمثل `UltraParticlePainter`.
class _UltraParticlePainter extends CustomPainter {
  /// العربية: يخزن القيمة `particles`.
  final List<_UltraParticle> particles;

  /// العربية: يخزن القيمة `animationValue`.
  final double animationValue;

  /// العربية: ينشئ مثيلًا جديدًا من `UltraParticlePainter`.
  _UltraParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();

      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.5)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          particle.glowRadius,
        );

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.radius,
        paint,
      );
    }
  }

  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Floating Orb Model
/// العربية: يمثل `FloatingOrb`.
class _FloatingOrb {
  /// العربية: يخزن القيمة `radius`.
  late double x, y, radius;

  /// العربية: يخزن القيمة `color`.
  late Color color;

  /// العربية: ينشئ مثيلًا جديدًا من `FloatingOrb`.
  _FloatingOrb() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    radius = math.Random().nextDouble() * 30 + 20;

    final colors = [
      AppTheme.primaryBlue,
      AppTheme.primaryPurple,
      AppTheme.primaryViolet,
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }
}

// Floating Orb Painter
/// العربية: يمثل `FloatingOrbPainter`.
class _FloatingOrbPainter extends CustomPainter {
  /// العربية: يخزن القيمة `orbs`.
  final List<_FloatingOrb> orbs;

  /// العربية: يخزن القيمة `animationValue`.
  final double animationValue;

  /// العربية: ينشئ مثيلًا جديدًا من `FloatingOrbPainter`.
  _FloatingOrbPainter({
    required this.orbs,
    required this.animationValue,
  });

  /// العربية: يعالج `paint`.
  @override
  void paint(Canvas canvas, Size size) {
    for (var orb in orbs) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            orb.color.withOpacity(0.1 * animationValue),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(orb.x * size.width, orb.y * size.height),
          radius: orb.radius * (1 + animationValue * 0.3),
        ));

      canvas.drawCircle(
        Offset(orb.x * size.width, orb.y * size.height),
        orb.radius * (1 + animationValue * 0.3),
        paint,
      );
    }
  }

  /// العربية: يعالج `shouldRepaint`.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
