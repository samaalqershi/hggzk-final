import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/utils/image_utils.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/search_result.dart';

/// العربية: يمثل عنصر الصفحة `SearchResultsMapPage`.
class SearchResultsMapPage extends StatefulWidget {
  /// العربية: يخزن القيمة `results`.
  final List<SearchResult> results;

  /// العربية: يخزن القيمة `onBackToList`.
  final VoidCallback? onBackToList;

  /// العربية: ينشئ مثيلًا جديدًا من `SearchResultsMapPage`.
  const SearchResultsMapPage({
    super.key,
    required this.results,
    this.onBackToList,
  });

  /// العربية: ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<SearchResultsMapPage> createState() => _SearchResultsMapPageState();
}

/// العربية: يمثل الحالة الخاصة بـ `SearchResultsMapPageState`.
class _SearchResultsMapPageState extends State<SearchResultsMapPage>
    with SingleTickerProviderStateMixin {
  /// العربية: يخزن القيمة `mapController`.
  GoogleMapController? _mapController;

  /// العربية: يخزن القيمة `markers`.
  Set<Marker> _markers = {};

  /// العربية: يخزن القيمة `selectedMarkerId`.
  String? _selectedMarkerId;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  /// العربية: يخزن القيمة `animationController`.
  late AnimationController _animationController;

  /// العربية: يخزن القيمة `fadeAnimation`.
  late Animation<double> _fadeAnimation;

  static const LatLng _defaultLocation = LatLng(15.3694, 44.1910);

  // Minimal map style
  static const String _mapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#f5f5f5"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#616161"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#f5f5f5"}]
    },
    {
      "featureType": "poi",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#ffffff"}]
    }
  ]
  ''';

  /// العربية: يهيئ الحالة الخاصة بهذا العنصر.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
    _initializeMarkers();
  }

  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _mapController?.dispose();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// العربية: يهيئ markers.
  void _initializeMarkers() {
    _markers = widget.results.map((result) {
      return Marker(
        markerId: MarkerId(result.id),
        position: LatLng(result.latitude, result.longitude),
        onTap: () => _onMarkerTapped(result),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _selectedMarkerId == result.id
              ? BitmapDescriptor.hueBlue
              : BitmapDescriptor.hueRed,
        ),
      );
    }).toSet();
  }

  /// العربية: يعالج `onMarkerTapped`.
  void _onMarkerTapped(SearchResult result) {
    setState(() {
      _selectedMarkerId = result.id;
      _initializeMarkers();
    });

    final index = widget.results.indexWhere((r) => r.id == result.id);
    if (index != -1) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// العربية: يعالج `onPropertyCardTapped`.
  void _onPropertyCardTapped(SearchResult result) {
    setState(() {
      _selectedMarkerId = result.id;
      _initializeMarkers();
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(result.latitude, result.longitude),
        15,
      ),
    );
  }

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildMinimalTopBar(),
          _buildMinimalPropertyCards(),
          _buildMinimalMapControls(),
        ],
      ),
    );
  }

  /// العربية: يبني map.
  Widget _buildMap() {
    return GoogleMap(
      onMapCreated: (controller) {
        _mapController = controller;
        controller.setMapStyle(_mapStyle);
      },
      initialCameraPosition: CameraPosition(
        target: _calculateCenter(),
        zoom: 12,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
    );
  }

  /// العربية: يبني minimal top bar.
  Widget _buildMinimalTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkBackground.withOpacity(0.7),
              AppTheme.darkBackground.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildMinimalButton(
                  icon: Icons.arrow_back,
                  onPressed:
                      widget.onBackToList ?? () => Navigator.pop(context),
                ),
                const Spacer(),
                _buildMinimalButton(
                  icon: Icons.layers_outlined,
                  onPressed: _showMapTypeSelector,
                ),
                const SizedBox(width: 8),
                _buildMinimalButton(
                  icon: Icons.tune,
                  onPressed: _showFilterOptions,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// العربية: يبني minimal property cards.
  Widget _buildMinimalPropertyCards() {
    if (widget.results.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 16,
      left: 0,
      right: 0,
      height: 110,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            final result = widget.results[index];
            _onPropertyCardTapped(result);
          },
          itemCount: widget.results.length,
          itemBuilder: (context, index) {
            final result = widget.results[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _MinimalMapPropertyCard(
                result: result,
                isSelected: _selectedMarkerId == result.id,
                onTap: () => _onPropertyCardTapped(result),
              ),
            );
          },
        ),
      ),
    );
  }

  /// العربية: يبني minimal map controls.
  Widget _buildMinimalMapControls() {
    return Positioned(
      right: 12,
      bottom: 140,
      child: Column(
        children: [
          _buildMinimalButton(
            icon: Icons.add,
            onPressed: _zoomIn,
            size: 36,
          ),
          const SizedBox(height: 8),
          _buildMinimalButton(
            icon: Icons.remove,
            onPressed: _zoomOut,
            size: 36,
          ),
          const SizedBox(height: 12),
          _buildMinimalButton(
            icon: Icons.my_location,
            onPressed: _goToMyLocation,
            size: 36,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  /// العربية: يبني minimal button.
  Widget _buildMinimalButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 40,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppTheme.primaryBlue.withOpacity(0.9)
              : AppTheme.darkCard.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: isPrimary
                ? AppTheme.primaryBlue
                : AppTheme.darkBorder.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: AppTheme.textWhite,
        ),
      ),
    );
  }

  /// العربية: يعالج `calculateCenter`.
  LatLng _calculateCenter() {
    if (widget.results.isEmpty) return _defaultLocation;

    double sumLat = 0;
    double sumLng = 0;

    for (final result in widget.results) {
      sumLat += result.latitude;
      sumLng += result.longitude;
    }

    return LatLng(
      sumLat / widget.results.length,
      sumLng / widget.results.length,
    );
  }

  /// العربية: يعالج `zoomIn`.
  void _zoomIn() => _mapController?.animateCamera(CameraUpdate.zoomIn());

  /// العربية: يعالج `zoomOut`.
  void _zoomOut() => _mapController?.animateCamera(CameraUpdate.zoomOut());

  /// العربية: يعالج `goToMyLocation`.
  void _goToMyLocation() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_defaultLocation, 15),
    );
  }

  /// العربية: يعرض map type selector.
  void _showMapTypeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MinimalMapTypeSelector(
        onSelectType: (type) {
          Navigator.pop(context);
          // Handle map type change
        },
      ),
    );
  }

  /// العربية: يعرض filter options.
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MinimalMapFilterOptions(
        onApplyFilters: (filters) {
          Navigator.pop(context);
          // Apply filters
        },
      ),
    );
  }
}

// Minimal Map Property Card
/// العربية: يمثل `MinimalMapPropertyCard`.
class _MinimalMapPropertyCard extends StatelessWidget {
  /// العربية: يخزن القيمة `result`.
  final SearchResult result;

  /// العربية: يحدد ما إذا كانت القيمة `isSelected` مفعلة.
  final bool isSelected;

  /// العربية: يخزن القيمة `onTap`.
  final VoidCallback onTap;

  /// العربية: ينشئ مثيلًا جديدًا من `MinimalMapPropertyCard`.
  const _MinimalMapPropertyCard({
    required this.result,
    required this.isSelected,
    required this.onTap,
  });

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withOpacity(isSelected ? 0.9 : 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue.withOpacity(0.3)
                : AppTheme.darkBorder.withOpacity(0.1),
            width: isSelected ? 1 : 0.5,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Fixed width image with dynamic height
              SizedBox(
                width: 90,
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(12),
                      ),
                      image: (ImageUtils.resolveUrl(result.mainImageUrl ?? '')
                              .isEmpty)
                          ? null
                          : DecorationImage(
                              image: NetworkImage(
                                ImageUtils.resolveUrl(
                                    result.mainImageUrl ?? ''),
                              ),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(12),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                        if (result.isFeatured)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'مميز',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        result.name,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : AppTheme.textWhite,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 10,
                            color: AppTheme.textMuted.withOpacity(0.6),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              result.address,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppTheme.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 10,
                                  color: AppTheme.warning,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  result.averageRating.toStringAsFixed(1),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppTheme.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (result.minPrice != result.discountedPrice)
                                Text(
                                  '${result.minPrice.toStringAsFixed(0)}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: AppTheme.textMuted.withOpacity(0.5),
                                  ),
                                ),
                              Text(
                                '${result.discountedPrice.toStringAsFixed(0)} ${result.currency}',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Minimal Map Type Selector
/// العربية: يمثل `MinimalMapTypeSelector`.
class _MinimalMapTypeSelector extends StatelessWidget {
  /// العربية: يعالج `Function`.
  final Function(String) onSelectType;

  /// العربية: ينشئ مثيلًا جديدًا من `MinimalMapTypeSelector`.
  const _MinimalMapTypeSelector({required this.onSelectType});

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.darkBorder.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'نوع الخريطة',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildOption(
                'عادية', Icons.map_outlined, () => onSelectType('normal')),
            _buildOption('قمر صناعي', Icons.satellite_outlined,
                () => onSelectType('satellite')),
            _buildOption('تضاريس', Icons.terrain_outlined,
                () => onSelectType('terrain')),
            _buildOption(
                'هجين', Icons.layers_outlined, () => onSelectType('hybrid')),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// العربية: يبني option.
  Widget _buildOption(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      leading: Icon(icon, size: 20, color: AppTheme.primaryBlue),
      title: Text(
        title,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppTheme.textWhite,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: AppTheme.textMuted.withOpacity(0.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      visualDensity: VisualDensity.compact,
    );
  }
}

// Minimal Map Filter Options
/// العربية: يمثل `MinimalMapFilterOptions`.
class _MinimalMapFilterOptions extends StatefulWidget {
  /// العربية: يعالج `Function`.
  final Function(Map<String, dynamic>) onApplyFilters;

  /// العربية: ينشئ مثيلًا جديدًا من `MinimalMapFilterOptions`.
  const _MinimalMapFilterOptions({required this.onApplyFilters});

  /// العربية: ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<_MinimalMapFilterOptions> createState() =>
      _MinimalMapFilterOptionsState();
}

/// العربية: يمثل الحالة الخاصة بـ `MinimalMapFilterOptionsState`.
class _MinimalMapFilterOptionsState extends State<_MinimalMapFilterOptions> {
  /// العربية: يخزن القيمة `radiusKm`.
  double _radiusKm = 5.0;

  /// العربية: يخزن القيمة `showFeatured`.
  bool _showFeatured = false;

  /// العربية: يخزن القيمة `showAvailable`.
  bool _showAvailable = true;

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.darkBorder.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'فلاتر الخريطة',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Radius Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'نطاق البحث',
                        style: AppTextStyles.bodySmall,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_radiusKm.toStringAsFixed(1)} كم',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppTheme.primaryBlue,
                      inactiveTrackColor: AppTheme.primaryBlue.withOpacity(0.2),
                      thumbColor: AppTheme.primaryBlue,
                      overlayColor: AppTheme.primaryBlue.withOpacity(0.1),
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      trackHeight: 2,
                    ),
                    child: Slider(
                      value: _radiusKm,
                      min: 1,
                      max: 20,
                      onChanged: (value) => setState(() => _radiusKm = value),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Toggle Options
            _buildSwitch('العقارات المميزة فقط', _showFeatured,
                (v) => setState(() => _showFeatured = v)),
            _buildSwitch('المتاح فقط', _showAvailable,
                (v) => setState(() => _showAvailable = v)),

            const SizedBox(height: 20),

            // Apply Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onApplyFilters({
                    'radius': _radiusKm,
                    'featured': _showFeatured,
                    'available': _showAvailable,
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withOpacity(0.9),
                        AppTheme.primaryPurple.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'تطبيق',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// العربية: يبني switch.
  Widget _buildSwitch(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textLight,
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primaryBlue,
              activeTrackColor: AppTheme.primaryBlue.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
