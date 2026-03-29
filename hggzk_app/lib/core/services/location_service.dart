import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:hggzk/core/localization/locale_manager.dart';

/// طبقة موقع موحدة تعزل `geolocator` و`geocoding` عن بقية التطبيق.
/// Unified location façade that keeps `geolocator` and `geocoding` isolated.
class LocationService {
  /// إعدادات دقيقة نستخدمها عندما تحتاج الصفحة إلى موقع مناسب للحجز أو الخريطة.
  /// High-accuracy settings used for booking and map-oriented flows.
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  /// يتحقق من أن خدمات الموقع نفسها مفعلة على الجهاز قبل طلب أي بيانات.
  /// Checks whether location services are enabled before requesting data.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// يطلب إذن الموقع ويحوّل النتيجة إلى حالة داخلية موحدة يفهمها التطبيق.
  /// Requests location permission and maps it to the app's internal status enum.
  Future<LocationPermissionStatus> requestLocationPermission() async {
    final status = await permission_handler.Permission.location.request();

    switch (status) {
      case permission_handler.PermissionStatus.granted:
        return LocationPermissionStatus.granted;
      case permission_handler.PermissionStatus.denied:
        return LocationPermissionStatus.denied;
      case permission_handler.PermissionStatus.permanentlyDenied:
        return LocationPermissionStatus.permanentlyDenied;
      case permission_handler.PermissionStatus.restricted:
        return LocationPermissionStatus.restricted;
      default:
        return LocationPermissionStatus.unknown;
    }
  }

  /// يقرأ حالة الإذن الحالية دون فتح حوار جديد للمستخدم.
  /// Reads the current permission state without prompting the user.
  Future<LocationPermissionStatus> checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();

    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.permanentlyDenied;
      default:
        return LocationPermissionStatus.unknown;
    }
  }

  /// يجلب الموقع الحالي مع حماية واضحة من الخدمة المعطلة أو الإذن المرفوض.
  /// Fetches the current location while guarding against disabled services and denied permissions.
  Future<LocationData> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceException(
          await _tr('core.location.serviceDisabled'),
          LocationErrorType.serviceDisabled,
        );
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationServiceException(
            await _tr('core.location.permissionDenied'),
            LocationErrorType.permissionDenied,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationServiceException(
          await _tr('core.location.permissionDeniedForever'),
          LocationErrorType.permissionDeniedForever,
        );
      }

      // Get position using settings
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: _locationSettings.accuracy,
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        speedAccuracy: position.speedAccuracy,
        heading: position.heading,
        timestamp: position.timestamp,
      );
    } catch (e) {
      if (e is LocationServiceException) {
        rethrow;
      }
      throw LocationServiceException(
        await _tr('core.location.unknownError'),
        LocationErrorType.unknown,
      );
    }
  }

  /// يعيد آخر موقع معروف عندما يكون النظام قد خزنه مسبقًا.
  /// Returns the last known position when the platform has one cached.
  Future<LocationData?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        return LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          altitude: position.altitude,
          speed: position.speed,
          speedAccuracy: position.speedAccuracy,
          heading: position.heading,
          timestamp: position.timestamp,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String> _tr(
    String key, {
    String? fallback,
    Map<String, Object?> params = const {},
  }) {
    return AppLocalizations.translate(
      key,
      locale: LocaleManager.getCurrentLocale(),
      params: params,
    );
  }

  /// يحسب المسافة الخطية بين نقطتين لاستخدامها في التقدير أو الترتيب.
  /// Computes the straight-line distance between two coordinates.
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// يحول الإحداثيات إلى عنوان يمكن عرضه للمستخدم أو حفظه لاحقًا.
  /// Reverse-geocodes coordinates into a human-readable address.
  Future<AddressData?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
        localeIdentifier: 'ar',
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return AddressData(
          street: placemark.street,
          subLocality: placemark.subLocality,
          locality: placemark.locality,
          administrativeArea: placemark.administrativeArea,
          country: placemark.country,
          postalCode: placemark.postalCode,
          formattedAddress: _formatAddress(placemark),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// يحول العنوان النصي إلى إحداثيات قابلة للاستخدام على الخريطة.
  /// Geocodes a textual address back into coordinates.
  Future<LocationData?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return LocationData(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// يفتح تدفق الموقع المستمر عندما تحتاج الواجهة تحديثًا حيًا.
  /// Opens a continuous location stream for live updates.
  Stream<LocationData> getLocationStream({
    int distanceFilter = 10,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    ).map((position) => LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          altitude: position.altitude,
          speed: position.speed,
          speedAccuracy: position.speedAccuracy,
          heading: position.heading,
          timestamp: position.timestamp,
        ));
  }

  /// يفتح إعدادات الموقع عندما يحتاج المستخدم إلى إصلاح الصلاحيات يدويًا.
  /// Opens system location settings when the user needs to fix permissions manually.
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  // Open app settings
  /// يفتح إعدادات التطبيق عندما يحتاج المستخدم إلى تعديل الأذونات يدويًا.
  /// Opens the app settings when the user needs to adjust permissions manually.
  Future<bool> openAppSettings() async {
    return await permission_handler.openAppSettings();
  }

  // Format address helper
  /// يجمع أجزاء العنوان في صيغة قصيرة ومقروءة.
  /// Combines address parts into a short, readable string.
  String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      parts.add(placemark.street!);
    }
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      parts.add(placemark.subLocality!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null &&
        placemark.administrativeArea!.isNotEmpty) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      parts.add(placemark.country!);
    }
    return parts.join('، ');
  }
}

// Data classes
/// يمثل لقطة موقع واحدة تعيدها المنصة وتستخدمها طبقات التطبيق المختلفة.
/// Represents a single location snapshot shared across the app.
class LocationData {
  /// خط العرض الحالي للموقع.
  /// Current latitude of the location.
  final double latitude;

  /// خط الطول الحالي للموقع.
  /// Current longitude of the location.
  final double longitude;

  /// دقة القياس التي أبلغت عنها المنصة.
  /// Accuracy reported by the platform.
  final double? accuracy;

  /// الارتفاع عن مستوى البحر إذا كان متاحًا.
  /// Altitude above sea level when available.
  final double? altitude;

  /// سرعة الحركة الحالية إذا كانت المنصة قادرة على توفيرها.
  /// Current speed when the platform can provide it.
  final double? speed;

  /// دقة قراءة السرعة.
  /// Accuracy of the speed reading.
  final double? speedAccuracy;

  /// اتجاه الحركة الحالي.
  /// Current heading of motion.
  final double? heading;

  /// وقت التقاط هذه القراءة.
  /// Timestamp when the reading was captured.
  final DateTime? timestamp;

  /// ينشئ بنية الموقع الموحدة المستخدمة داخل التطبيق.
  /// Creates the unified location model used throughout the app.
  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.speedAccuracy,
    this.heading,
    this.timestamp,
  });

  /// يحول بيانات الموقع إلى JSON لإمكانية التخزين أو الإرسال.
  /// Converts location data to JSON for storage or transport.
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'altitude': altitude,
        'speed': speed,
        'speedAccuracy': speedAccuracy,
        'heading': heading,
        'timestamp': timestamp?.toIso8601String(),
      };
}

/// يمثل عنوانًا مفككًا إلى أجزائه ليسهل عرضه أو تخزينه.
/// Represents a decomposed address that is easy to display or store.
class AddressData {
  /// اسم الشارع إن كان معروفًا.
  /// Street name when available.
  final String? street;

  /// المنطقة الفرعية أو الحي.
  /// Sub-locality or neighborhood.
  final String? subLocality;

  /// المدينة أو المركز العمراني الأقرب.
  /// Locality or nearest city.
  final String? locality;

  /// المنطقة الإدارية أو المحافظة.
  /// Administrative area or governorate.
  final String? administrativeArea;

  /// الدولة المرتبطة بالعنوان.
  /// Country of the address.
  final String? country;

  /// الرمز البريدي عندما يكون متاحًا.
  /// Postal code when available.
  final String? postalCode;

  /// العنوان النهائي المنسق للعرض.
  /// Final formatted address for display.
  final String formattedAddress;

  /// ينشئ بنية العنوان الناتجة عن عملية الجيوكود.
  /// Creates the address model returned by geocoding.
  AddressData({
    this.street,
    this.subLocality,
    this.locality,
    this.administrativeArea,
    this.country,
    this.postalCode,
    required this.formattedAddress,
  });
}

// Enums
/// يحدد حالات إذن الموقع التي يفهمها التطبيق.
/// Enumerates the location-permission states the app understands.
enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  unknown,
}

/// يحدد أنواع أخطاء الموقع التي نعرضها للواجهة.
/// Enumerates the location error categories shown to the UI.
enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unknown,
}

// Exception
/// يمثل الخطأ المتخصص الذي نرميه عندما يفشل الوصول إلى الموقع.
/// Specialized exception thrown when location access fails.
class LocationServiceException implements Exception {
  /// رسالة الخطأ التي تظهر للمستخدم أو السجل.
  /// Error message shown to the user or logs.
  final String message;

  /// فئة الخطأ حتى تعرف الواجهة كيف تتعامل معه.
  /// Error category so the UI knows how to react.
  final LocationErrorType type;

  /// ينشئ استثناء الموقع مع رسالته ونوعه.
  /// Creates the location exception with its message and type.
  LocationServiceException(this.message, this.type);

  /// يعيد الرسالة كما هي لتناسب السجلات والرسائل المباشرة.
  /// Returns the message as-is for logs and direct display.
  @override
  String toString() => message;
}
