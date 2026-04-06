import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hggzkportal/core/theme/app_text_styles.dart';
import 'package:hggzkportal/core/theme/app_theme.dart';
import 'package:hggzkportal/features/admin_nearby_places/domain/entities/nearby_place.dart';
import 'package:hggzkportal/features/admin_nearby_places/presentation/bloc/nearby_places_bloc.dart';
import 'package:hggzkportal/features/admin_nearby_places/presentation/bloc/nearby_places_event.dart';
import 'package:hggzkportal/features/admin_nearby_places/presentation/bloc/nearby_places_state.dart';
import 'package:hggzkportal/services/message_service.dart';

class AdminNearbyPlacesPage extends StatefulWidget {
  final String? initialPropertyId;
  final String? initialPropertyName;

  const AdminNearbyPlacesPage({
    super.key,
    this.initialPropertyId,
    this.initialPropertyName,
  });

  @override
  State<AdminNearbyPlacesPage> createState() => _AdminNearbyPlacesPageState();
}

class _AdminNearbyPlacesPageState extends State<AdminNearbyPlacesPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _backgroundAnimationController;
  late AnimationController _glowController;
  late AnimationController _contentAnimationController;

  late Animation<double> _backgroundRotation;
  late Animation<double> _glowAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  String? _selectedPropertyId;
  String? _selectedPropertyName;
  bool? _activeFilter;
  bool _showFilters = true;

  NearbyPlacesLoaded? _lastLoadedState;

  @override
  void initState() {
    super.initState();
    _selectedPropertyId = widget.initialPropertyId;
    _selectedPropertyName = widget.initialPropertyName;
    _initializeAnimations();
    _reloadPlaces();
  }

  void _initializeAnimations() {
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(
      CurvedAnimation(
        parent: _backgroundAnimationController,
        curve: Curves.linear,
      ),
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeOutQuart,
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _contentAnimationController.forward();
      }
    });
  }

  void _reloadPlaces() {
    context.read<NearbyPlacesBloc>().add(
          LoadNearbyPlacesEvent(
            propertyId: _selectedPropertyId,
            searchTerm: _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
            isActive: _activeFilter,
          ),
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _backgroundAnimationController.dispose();
    _glowController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NearbyPlacesBloc, NearbyPlacesState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        if (state is NearbyPlacesLoaded) {
          _lastLoadedState = state;
        }

        final effectiveState =
            state is NearbyPlacesLoaded ? state : _lastLoadedState;
        final showOperationOverlay = state is NearbyPlacesOperationInProgress;
        final showInitialLoader =
            state is NearbyPlacesLoading && effectiveState == null;

        return Scaffold(
          backgroundColor: AppTheme.darkBackground,
          body: Stack(
            children: [
              _buildAnimatedBackground(),
              RefreshIndicator(
                onRefresh: () async => _reloadPlaces(),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    _buildSliverAppBar(),
                    SliverToBoxAdapter(
                        child: _buildStatsSection(effectiveState)),
                    SliverToBoxAdapter(child: _buildSearchBar()),
                    SliverToBoxAdapter(child: _buildFiltersSection()),
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _contentFadeAnimation,
                        child: SlideTransition(
                          position: _contentSlideAnimation,
                          child: _buildContent(
                            state: state,
                            effectiveState: effectiveState,
                            showInitialLoader: showInitialLoader,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
              if (showOperationOverlay) _buildOperationOverlay(),
            ],
          ),
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, NearbyPlacesState state) {
    if (state is NearbyPlacesOperationSuccess) {
      MessageService.showSuccess(state.message);
      return;
    }

    if (state is NearbyPlacesError) {
      MessageService.showError(state.message);
    }
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 128,
      floating: true,
      pinned: true,
      centerTitle: false,
      backgroundColor: AppTheme.darkBackground,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.location_solid,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'إدارة الأماكن القريبة',
                style: AppTextStyles.heading1.copyWith(
                  color: AppTheme.textWhite,
                  shadows: [
                    Shadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryBlue.withValues(alpha: 0.12),
                AppTheme.darkBackground,
              ],
            ),
          ),
        ),
      ),
      actions: [
        _buildAppBarIconAction(
          icon: Icons.filter_list_rounded,
          onPressed: () => setState(() => _showFilters = !_showFilters),
        ),
        _buildAppBarIconAction(
          icon: Icons.refresh_rounded,
          onPressed: _reloadPlaces,
        ),
        _buildAppBarIconAction(
          icon: Icons.add_location_alt_rounded,
          onPressed: _openCreateFormPage,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildAppBarIconAction({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      icon: Icon(icon, color: AppTheme.textWhite, size: 20),
      splashRadius: 20,
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_backgroundRotation, _glowAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2.withValues(alpha: 0.8),
                AppTheme.darkBackground3.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _NearbyPlacesBackgroundPainter(
              rotation: _backgroundRotation.value,
              glowIntensity: _glowAnimation.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildStatsSection(NearbyPlacesLoaded? state) {
    final places = state?.places ?? const <NearbyPlace>[];
    final total = places.length;
    final active = places.where((place) => place.isActive).length;
    final hidden = total - active;
    final mapped = places
        .where((place) => place.latitude != null && place.longitude != null)
        .length;

    return SizedBox(
      height: 118,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            title: 'إجمالي الأماكن',
            value: '$total',
            icon: Icons.place_rounded,
            color: AppTheme.primaryBlue,
          ),
          _buildStatCard(
            title: 'أماكن نشطة',
            value: '$active',
            icon: Icons.check_circle_rounded,
            color: AppTheme.success,
          ),
          _buildStatCard(
            title: 'أماكن مخفية',
            value: '$hidden',
            icon: Icons.visibility_off_rounded,
            color: AppTheme.warning,
          ),
          _buildStatCard(
            title: 'مرتبطة بالخريطة',
            value: '$mapped',
            icon: Icons.map_rounded,
            color: AppTheme.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 190,
      margin: const EdgeInsetsDirectional.only(end: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.18),
            AppTheme.darkCard.withValues(alpha: 0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            Icons.search_rounded,
            color: AppTheme.primaryBlue.withValues(alpha: 0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _reloadPlaces(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
              ),
              decoration: InputDecoration(
                hintText: 'البحث عن مكان قريب...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textMuted.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() {});
                _reloadPlaces();
              },
              icon: Icon(
                Icons.clear_rounded,
                color: AppTheme.textMuted,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showFilters ? 124 : 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withValues(alpha: 0.5),
                AppTheme.darkCard.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.darkBorder.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildPropertyFilterChip()),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildStatusChip(
                    label: 'الكل',
                    selected: _activeFilter == null,
                    onTap: () {
                      setState(() => _activeFilter = null);
                      _reloadPlaces();
                    },
                  ),
                  _buildStatusChip(
                    label: 'نشطة فقط',
                    selected: _activeFilter == true,
                    onTap: () {
                      setState(() => _activeFilter = true);
                      _reloadPlaces();
                    },
                  ),
                  _buildStatusChip(
                    label: 'مخفية فقط',
                    selected: _activeFilter == false,
                    onTap: () {
                      setState(() => _activeFilter = false);
                      _reloadPlaces();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyFilterChip() {
    final isSelected =
        _selectedPropertyId != null && _selectedPropertyId!.trim().isNotEmpty;

    return InkWell(
      onTap: _pickProperty,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [
                    AppTheme.primaryBlue.withValues(alpha: 0.24),
                    AppTheme.primaryPurple.withValues(alpha: 0.16),
                  ]
                : [
                    AppTheme.darkSurface.withValues(alpha: 0.45),
                    AppTheme.darkSurface.withValues(alpha: 0.32),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue.withValues(alpha: 0.45)
                : AppTheme.darkBorder.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.home_work_outlined,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.textMuted,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedPropertyName ?? 'اختر العقار للتصفية',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedPropertyId = null;
                    _selectedPropertyName = null;
                  });
                  context.read<NearbyPlacesBloc>().add(
                        const SelectPropertyForNearbyPlacesEvent(),
                      );
                },
                child: Icon(
                  Icons.clear_rounded,
                  color: AppTheme.textMuted,
                  size: 18,
                ),
              ),
            ] else ...[
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryBlue.withValues(alpha: 0.18)
              : AppTheme.darkSurface.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppTheme.primaryBlue.withValues(alpha: 0.42)
                : AppTheme.darkBorder.withValues(alpha: 0.24),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: selected ? AppTheme.textWhite : AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildContent({
    required NearbyPlacesState state,
    required NearbyPlacesLoaded? effectiveState,
    required bool showInitialLoader,
  }) {
    if (showInitialLoader) {
      return SizedBox(
        height: 420,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
      );
    }

    if (state is NearbyPlacesError && effectiveState == null) {
      return _buildErrorState(state.message);
    }

    final places = effectiveState?.places ?? const <NearbyPlace>[];
    if (places.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: places
            .map(
              (place) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _NearbyPlaceCard(
                  place: place,
                  onEdit: () => _openEditFormPage(place),
                  onDelete: () => _confirmDelete(place),
                  onStatusToggle: () => context.read<NearbyPlacesBloc>().add(
                        ToggleNearbyPlaceStatusEvent(place.id),
                      ),
                  resolveIcon: _resolveIcon,
                  formatDistance: _formatDistance,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 420,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withValues(alpha: 0.76),
              AppTheme.darkCard.withValues(alpha: 0.56),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.darkBorder.withValues(alpha: 0.24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.place_outlined,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'لا توجد أماكن قريبة مطابقة',
              style: AppTextStyles.heading3.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _selectedPropertyName != null
                  ? 'لا توجد بيانات للعقار المحدد حاليًا. يمكنك إضافة مكان قريب جديد مباشرة.'
                  : 'ابدأ باختيار عقار أو إضافة مكان قريب جديد لإظهار البيانات هنا.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _openCreateFormPage,
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('إضافة مكان قريب'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      height: 420,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.error.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 52, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(
              'تعذر تحميل الأماكن القريبة',
              style: AppTextStyles.heading3.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _reloadPlaces,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black.withValues(alpha: 0.16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppTheme.darkBorder.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'جاري تنفيذ العملية...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickProperty() async {
    final property = await context.push(
      '/helpers/search/properties',
      extra: {
        'onPropertySelected': (dynamic property) {
          if (mounted) {
            setState(() {
              _selectedPropertyId = property.id;
              _selectedPropertyName = property.name;
            });
            context.read<NearbyPlacesBloc>().add(
                  SelectPropertyForNearbyPlacesEvent(
                    propertyId: property.id,
                    propertyName: property.name,
                  ),
                );
          }
        }
      },
    );

    if (property is Map<String, dynamic>) {
      setState(() {
        _selectedPropertyId = property['id']?.toString();
        _selectedPropertyName = property['name']?.toString();
      });
      _reloadPlaces();
    }
  }

  Future<void> _openCreateFormPage() async {
    if (_selectedPropertyId == null || _selectedPropertyId!.isEmpty) {
      MessageService.showWarning('اختر العقار أولاً قبل إضافة مكان قريب');
      return;
    }

    final result = await context.push<Map<String, dynamic>>(
      '/admin/nearby-places/form',
      extra: {
        'propertyId': _selectedPropertyId,
        'propertyName': _selectedPropertyName ?? 'العقار المحدد',
      },
    );

    if (result != null && mounted) {
      context.read<NearbyPlacesBloc>().add(CreateNearbyPlaceEvent(result));
    }
  }

  Future<void> _openEditFormPage(NearbyPlace place) async {
    final result = await context.push<Map<String, dynamic>>(
      '/admin/nearby-places/form',
      extra: {
        'propertyId': place.propertyId,
        'propertyName': place.propertyName,
        'nearbyPlace': place,
      },
    );

    if (result != null && mounted) {
      context
          .read<NearbyPlacesBloc>()
          .add(UpdateNearbyPlaceEvent(place.id, result));
    }
  }

  Future<void> _confirmDelete(NearbyPlace place) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.darkCard,
          title: Text(
            'حذف المكان القريب',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'هل تريد حذف "${place.name}" نهائيًا؟',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
              ),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      context.read<NearbyPlacesBloc>().add(DeleteNearbyPlaceEvent(place.id));
    }
  }

  IconData _resolveIcon(NearbyPlace place) {
    final key = '${place.icon} ${place.category}'.toLowerCase();
    if (key.contains('hospital') ||
        key.contains('medical') ||
        key.contains('مستشفى')) {
      return Icons.local_hospital_rounded;
    }
    if (key.contains('restaurant') || key.contains('مطعم')) {
      return Icons.restaurant_rounded;
    }
    if (key.contains('mall') || key.contains('market') || key.contains('سوق')) {
      return Icons.shopping_bag_rounded;
    }
    if (key.contains('mosque') ||
        key.contains('جامع') ||
        key.contains('مسجد')) {
      return Icons.mosque_rounded;
    }
    if (key.contains('school') ||
        key.contains('university') ||
        key.contains('جامعة') ||
        key.contains('مدرسة')) {
      return Icons.school_rounded;
    }
    if (key.contains('beach') || key.contains('corniche')) {
      return Icons.waves_rounded;
    }
    return Icons.place_rounded;
  }

  String _formatDistance(int meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(meters % 1000 == 0 ? 0 : 1)} كم';
    }
    return '$meters م';
  }
}

class _NearbyPlacesBackgroundPainter extends CustomPainter {
  final double rotation;
  final double glowIntensity;

  const _NearbyPlacesBackgroundPainter({
    required this.rotation,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    final primaryPaint = Paint()
      ..color = AppTheme.primaryBlue.withValues(alpha: 0.07 * glowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    final secondaryPaint = Paint()
      ..color = AppTheme.primaryPurple.withValues(alpha: 0.05 * glowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.18),
      180,
      primaryPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.16, size.height * 0.74),
      210,
      secondaryPaint,
    );

    final linePaint = Paint()
      ..color = AppTheme.primaryBlue.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (var i = 0; i < 7; i++) {
      final dy = size.height * (0.14 + (i * 0.12));
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), linePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NearbyPlacesBackgroundPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.glowIntensity != glowIntensity;
  }
}

class _NearbyPlaceCard extends StatefulWidget {
  final NearbyPlace place;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStatusToggle;
  final IconData Function(NearbyPlace place) resolveIcon;
  final String Function(int meters) formatDistance;

  const _NearbyPlaceCard({
    required this.place,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusToggle,
    required this.resolveIcon,
    required this.formatDistance,
  });

  @override
  State<_NearbyPlaceCard> createState() => _NearbyPlaceCardState();
}

class _NearbyPlaceCardState extends State<_NearbyPlaceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final hasCoordinates = place.latitude != null && place.longitude != null;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _hoverAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isHovered
                      ? [
                          AppTheme.primaryBlue.withValues(alpha: 0.1),
                          AppTheme.primaryPurple.withValues(alpha: 0.05),
                        ]
                      : [
                          AppTheme.darkCard.withValues(alpha: 0.7),
                          AppTheme.darkCard.withValues(alpha: 0.5),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered
                      ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                      : AppTheme.darkBorder.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? AppTheme.primaryBlue.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.1),
                    blurRadius: _isHovered ? 20 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    widget.resolveIcon(place),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place.name,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: AppTheme.textWhite,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        place.propertyName,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppTheme.textMuted,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                _buildStatusBadge(place.isActive),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _buildInlineStat(
                                  icon: Icons.category_rounded,
                                  value: place.category,
                                  color: AppTheme.primaryBlue,
                                ),
                                _buildInlineStat(
                                  icon: Icons.social_distance_rounded,
                                  value: widget
                                      .formatDistance(place.distanceInMeters),
                                  color: AppTheme.warning,
                                ),
                                if (place.walkingMinutes != null)
                                  _buildInlineStat(
                                    icon: Icons.directions_walk_rounded,
                                    value: '${place.walkingMinutes} د مشي',
                                    color: AppTheme.success,
                                  ),
                                if (place.drivingMinutes != null)
                                  _buildInlineStat(
                                    icon: Icons.directions_car_rounded,
                                    value: '${place.drivingMinutes} د قيادة',
                                    color: AppTheme.primaryPurple,
                                  ),
                                _buildInlineStat(
                                  icon: hasCoordinates
                                      ? Icons.map_rounded
                                      : Icons.location_off_rounded,
                                  value: hasCoordinates
                                      ? 'مرتبط بالخريطة'
                                      : 'بدون إحداثيات',
                                  color: hasCoordinates
                                      ? AppTheme.primaryBlue
                                      : AppTheme.textMuted,
                                ),
                              ],
                            ),
                            if ((place.description ?? '')
                                .trim()
                                .isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.darkBackground
                                      .withValues(alpha: 0.28),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.darkBorder
                                        .withValues(alpha: 0.18),
                                  ),
                                ),
                                child: Text(
                                  place.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppTheme.textLight,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'الظهور',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Switch(
                                      value: place.isActive,
                                      onChanged: (_) => widget.onStatusToggle(),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                if (_isHovered) ...[
                                  _buildActionIcon(
                                    Icons.edit_rounded,
                                    widget.onEdit,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildActionIcon(
                                    Icons.delete_rounded,
                                    widget.onDelete,
                                    color: AppTheme.error,
                                  ),
                                ] else ...[
                                  _buildActionTextButton(
                                    label: 'تعديل',
                                    icon: Icons.edit_rounded,
                                    onTap: widget.onEdit,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildActionTextButton(
                                    label: 'حذف',
                                    icon: Icons.delete_outline_rounded,
                                    onTap: widget.onDelete,
                                    color: AppTheme.error,
                                  ),
                                ],
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
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    final color = isActive ? AppTheme.success : AppTheme.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Text(
        isActive ? 'نشط' : 'مخفي',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildInlineStat({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(
    IconData icon,
    VoidCallback onTap, {
    Color? color,
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
          color: AppTheme.darkBackground.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (color ?? AppTheme.primaryBlue).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color ?? AppTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildActionTextButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final actionColor = color ?? AppTheme.primaryBlue;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.darkBackground.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: actionColor.withValues(alpha: 0.24),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: actionColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: actionColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
