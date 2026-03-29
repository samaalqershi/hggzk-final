import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Displays the property's pinned location, address context, and map actions.
/// يعرض موقع العقار المثبّت وسياق العنوان وأفعال الخريطة.
class LocationMapWidget extends StatefulWidget {
  /// Latitude used to place the property marker.
  /// خط العرض المستخدم لوضع مؤشر العقار.
  final double latitude;

  /// Longitude used to place the property marker.
  /// خط الطول المستخدم لوضع مؤشر العقار.
  final double longitude;

  /// Property name shown in the map header and marker info window.
  /// اسم العقار الظاهر في ترويسة الخريطة ومربع معلومات المؤشر.
  final String propertyName;

  /// Address shown beside the map and inside the info window.
  /// العنوان الظاهر بجانب الخريطة وداخل نافذة المعلومات.
  final String address;

  /// Builds the location section for property details.
  /// ينشئ قسم الموقع لتفاصيل العقار.
  const LocationMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.propertyName,
    required this.address,
  });

  /// Creates the state object that drives map and pulse animations.
  /// ينشئ كائن الحالة الذي يقود حركات الخريطة والنبض.
  @override
  State<LocationMapWidget> createState() => _LocationMapWidgetState();
}

/// Controls the marker setup, map controller, and pulse effect.
/// يتحكم في إعداد المؤشر ومتحكم الخريطة وتأثير النبض.
class _LocationMapWidgetState extends State<LocationMapWidget>
    with SingleTickerProviderStateMixin {
  /// Controller for the embedded Google Map widget.
  /// متحكم عنصر Google Map المضمّن.
  GoogleMapController? _mapController;

  /// Marker set used to pin the property location.
  /// مجموعة المؤشرات المستخدمة لتثبيت موقع العقار.
  final Set<Marker> _markers = {};

  /// Repeats the pulsing marker background effect.
  /// يكرر تأثير خلفية المؤشر النابضة.
  late AnimationController _pulseController;

  /// Animation that scales the marker pulse.
  /// الحركة التي تغيّر حجم النبضة حول المؤشر.
  late Animation<double> _pulseAnimation;

  /// Prepares the marker and the pulse animation.
  /// يجهز المؤشر وحركة النبض.
  @override
  void initState() {
    super.initState();
    _initializeMarker();
    _initializeAnimations();
  }

  /// Sets up the repeating pulse animation behind the marker.
  /// يهيئ حركة النبض المتكررة خلف المؤشر.
  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  /// Adds the location marker for the current property coordinates.
  /// يضيف مؤشر الموقع لإحداثيات العقار الحالية.
  void _initializeMarker() {
    _markers.add(
      Marker(
        markerId: const MarkerId('property'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(
          title: widget.propertyName,
          snippet: widget.address,
        ),
      ),
    );
  }

  /// Releases the map controller and pulse animation.
  /// يحرر متحكم الخريطة وحركة النبض.
  @override
  void dispose() {
    _mapController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Renders the location section with the header, actions, and map view.
  /// يرسم قسم الموقع مع الترويسة والأفعال وعرض الخريطة.
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFuturisticLocationHeader(),
          const SizedBox(height: 16),
          _buildFuturisticActionButtons(),
          const SizedBox(height: 16),
          _buildFuturisticMap(),
        ],
      ),
    );
  }

  /// Builds the futuristic location header.
  /// العربية: يبني futuristic location header.
  Widget _buildFuturisticLocationHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.2),
            AppTheme.primaryCyan.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('property.map.location'),
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.address,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the futuristic action buttons.
  /// العربية: يبني futuristic action buttons.
  Widget _buildFuturisticActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.map,
              label: context.tr('property.map.fullscreen'),
              gradient: LinearGradient(
                colors: [AppTheme.success, AppTheme.neonGreen],
              ),
              onTap: _openFullScreenMap,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the action button.
  /// العربية: يبني action button.
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.mediumImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors[0].withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the futuristic map.
  /// العربية: يبني futuristic map.
  Widget _buildFuturisticMap() {
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.latitude, widget.longitude),
                zoom: 15,
                tilt: 45,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _setFuturisticMapStyle();
              },
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              mapType: MapType.normal,
            ),

            // Gradient overlay
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryBlue.withOpacity(0.1),
                        Colors.transparent,
                        Colors.transparent,
                        AppTheme.darkBackground.withOpacity(0.3),
                      ],
                      stops: const [0.0, 0.2, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sets the futuristic map style.
  /// العربية: يضبط futuristic map style.
  void _setFuturisticMapStyle() {
    const String mapStyle = '''
    [
      {
        "elementType": "geometry",
        "stylers": [{"color": "#1d2c4d"}]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#8ec3b9"}]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [{"color": "#1a3646"}]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [{"color": "#304a7d"}]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [{"color": "#023e8a"}]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#4e6d8c"}]
      },
      {
        "featureType": "poi",
        "elementType": "geometry",
        "stylers": [{"color": "#283d6a"}]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [{"color": "#1b4332"}]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [{"color": "#746855"}]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry.stroke",
        "stylers": [{"color": "#1f2835"}]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry.stroke",
        "stylers": [{"color": "#4b6878"}]
      },
      {
        "featureType": "transit.line",
        "elementType": "geometry",
        "stylers": [{"color": "#146474"}]
      },
      {
        "featureType": "transit.station",
        "elementType": "geometry",
        "stylers": [{"color": "#146474"}]
      }
    ]
    ''';

    _mapController?.setMapStyle(mapStyle);
  }

  /// Opens the full screen map.
  /// العربية: يفتح full screen map.
  void _openFullScreenMap() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMapView(
          latitude: widget.latitude,
          longitude: widget.longitude,
          propertyName: widget.propertyName,
          address: widget.address,
        ),
      ),
    );
  }
}

// Full screen map view
/// Describes the FullScreenMapView type used in the property feature.
/// العربية: يمثل `FullScreenMapView`.
class FullScreenMapView extends StatefulWidget {
  /// Keeps the latitude value available to this object.
  /// العربية: يخزن القيمة `latitude`.
  final double latitude;

  /// Keeps the longitude value available to this object.
  /// العربية: يخزن القيمة `longitude`.
  final double longitude;

  /// Keeps the propertyName value available to this object.
  /// العربية: يخزن القيمة `propertyName`.
  final String propertyName;

  /// Keeps the address value available to this object.
  /// العربية: يخزن القيمة `address`.
  final String address;

  /// Constructs the FullScreenMapView value used by this feature.
  /// العربية: ينشئ مثيلًا جديدًا من `FullScreenMapView`.
  const FullScreenMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.propertyName,
    required this.address,
  });

  /// Builds the state object for this widget used by this feature.
  /// العربية: ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<FullScreenMapView> createState() => _FullScreenMapViewState();
}

/// Describes the state for `FullScreenMapViewState`.
/// العربية: يمثل الحالة الخاصة بـ `FullScreenMapViewState`.
class _FullScreenMapViewState extends State<FullScreenMapView> {
  /// Keeps the mapController value available to this object.
  /// العربية: يخزن القيمة `mapController`.
  GoogleMapController? _mapController;

  /// Keeps the currentMapType value available to this object.
  /// العربية: يخزن القيمة `currentMapType`.
  MapType _currentMapType = MapType.normal;

  /// Keeps the markers value available to this object.
  /// العربية: يخزن القيمة `markers`.
  final Set<Marker> _markers = {};

  /// Keeps the circles value available to this object.
  /// العربية: يخزن القيمة `circles`.
  final Set<Circle> _circles = {};

  final List<MapType> _mapTypes = const [
    MapType.normal,
    MapType.satellite,
    MapType.terrain,
    MapType.hybrid,
  ];

  /// Initializes the state for this widget.
  /// العربية: يهيئ الحالة الخاصة بهذا العنصر.
  @override
  void initState() {
    super.initState();
    _initializeMapElements();
  }

  /// Initializes the map elements.
  /// العربية: يهيئ map elements.
  void _initializeMapElements() {
    _markers.add(
      Marker(
        markerId: const MarkerId('property'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(
          title: widget.propertyName,
          snippet: widget.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    _circles.add(
      Circle(
        circleId: const CircleId('property_area'),
        center: LatLng(widget.latitude, widget.longitude),
        radius: 500,
        fillColor: AppTheme.primaryBlue.withOpacity(0.1),
        strokeColor: AppTheme.primaryBlue.withOpacity(0.5),
        strokeWidth: 2,
      ),
    );
  }

  /// Builds the widget tree for this component.
  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.darkBackground.withOpacity(0.8),
                    AppTheme.darkBackground.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withOpacity(0.8),
                AppTheme.darkCard.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkCard.withOpacity(0.8),
                  AppTheme.darkCard.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: IconButton(
                  icon: Icon(
                    _mapTypeIcon(),
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _cycleMapType();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.latitude, widget.longitude),
              zoom: 16,
              tilt: 45,
            ),
            markers: _markers,
            circles: _circles,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_currentMapType == MapType.normal) {
                _setFuturisticMapStyle();
              } else {
                _mapController?.setMapStyle(null);
              }
            },
            mapType: _currentMapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
          ),

          // Custom controls
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                _buildMapControlButton(
                  icon: Icons.add,
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  icon: Icons.remove,
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                  },
                ),
                const SizedBox(height: 16),
                _buildMapControlButton(
                  icon: Icons.my_location,
                  onPressed: () {
                    // Center on user location
                    HapticFeedback.mediumImpact();
                  },
                ),
              ],
            ),
          ),

          // Bottom info card
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkCard.withOpacity(0.95),
                    AppTheme.darkCard.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.propertyName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppTheme.textWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.address,
                              style: AppTextStyles.caption.copyWith(
                                color: AppTheme.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }

  /// Builds the map control button.
  /// العربية: يبني map control button.
  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.9),
              AppTheme.darkCard.withOpacity(0.7),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowDark.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  /// Sets the futuristic map style.
  /// العربية: يضبط futuristic map style.
  void _setFuturisticMapStyle() {
    const String mapStyle = '''
    [
      {
        "elementType": "geometry",
        "stylers": [{"color": "#1d2c4d"}]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [{"color": "#8ec3b9"}]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [{"color": "#1a3646"}]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [{"color": "#304a7d"}]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [{"color": "#023e8a"}]
      }
    ]
    ''';

    _mapController?.setMapStyle(mapStyle);
  }

  // [ISSUE 1017] اضافة زر والية تغيير طريقة عرض الخريطة في صفحة كامل الخريطة في صفحة تفاصيل العقار
  /// Processes the cycleMapType flow and maps it into the property feature behavior.
  /// العربية: يعالج `cycleMapType`.
  void _cycleMapType() {
    final currentIndex = _mapTypes.indexOf(_currentMapType);
    final nextIndex = (currentIndex + 1) % _mapTypes.length;
    setState(() {
      _currentMapType = _mapTypes[nextIndex];
    });

    if (_currentMapType == MapType.normal) {
      _setFuturisticMapStyle();
    } else {
      _mapController?.setMapStyle(null);
    }
  }

  /// Maps the type icon.
  /// العربية: يحّول type icon.
  IconData _mapTypeIcon() {
    switch (_currentMapType) {
      case MapType.normal:
        return Icons.layers_outlined;
      case MapType.satellite:
        return Icons.satellite_outlined;
      case MapType.terrain:
        return Icons.terrain_outlined;
      case MapType.hybrid:
        return Icons.public_outlined;
      default:
        return Icons.map_outlined;
    }
  }
}
