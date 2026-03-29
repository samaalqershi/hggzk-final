import '../../domain/entities/city.dart';

/// Transport model that adapts the city entity to the API payload shape.
///
/// نموذج نقل يكيّف كيان المدينة مع شكل الحمولة المتوقع من الـ API.
class CityModel extends City {
  /// Creates a model instance ready for JSON exchange with the backend.
  ///
  /// ينشئ نموذجًا جاهزًا لتبادل JSON مع الخادم.
  const CityModel({
    required super.name,
    super.nameEn,
    required super.country,
    super.countryEn,
    required super.images,
    super.createdAt,
    super.updatedAt,
    super.propertiesCount,
    super.isActive = null,
    super.metadata,
  });

  /// Builds a model from backend JSON while discarding unsupported image paths.
  ///
  /// ينشئ النموذج من JSON الخادم مع إسقاط مسارات الصور غير الصالحة.
  factory CityModel.fromJson(Map<String, dynamic> json) {
    List<String> rawImages = [];
    if (json['images'] != null) {
      try {
        rawImages = List<String>.from(json['images']);
      } catch (_) {}
    }
    final sanitized = rawImages.where((u) {
      final val = u.trim();
      if (val.isEmpty) return false;
      final lower = val.toLowerCase();
      // Preserve only paths that the admin portal can render or upload again.
      if (lower.startsWith('http://') || lower.startsWith('https://'))
        return true;
      if (lower.startsWith('/uploads') || lower.startsWith('uploads/'))
        return true;
      // Accept the backend's public media folders as reusable gallery sources.
      if (lower.startsWith('/images') || lower.startsWith('images/'))
        return true;
      // Reject local-device paths because they are not portable outside Android.
      if (lower.startsWith('/data/') ||
          lower.startsWith('file://') ||
          lower.startsWith('content://')) return false;
      // Skip anything else so the UI never receives a broken or private URL.
      return false;
    }).toList(growable: false);

    return CityModel(
      name: json['name'] ?? '',
      nameEn: json['nameEn'],
      country: json['country'] ?? '',
      countryEn: json['countryEn'],
      images: sanitized,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      propertiesCount: json['propertiesCount'],
      isActive: json['isActive'] ?? true,
      metadata: json['metadata'],
    );
  }

  /// Serializes the model back into the API contract used by the backend.
  ///
  /// يحول النموذج إلى الصيغة التي يعتمدها الخادم.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nameEn': nameEn,
      'country': country,
      'countryEn': countryEn,
      'images': images,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'propertiesCount': propertiesCount,
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  /// Wraps a domain entity into the transport model without changing values.
  ///
  /// يغلّف الكيان المعماري داخل نموذج النقل من دون تغيير القيم.
  factory CityModel.fromEntity(City city) {
    return CityModel(
      name: city.name,
      nameEn: city.nameEn,
      country: city.country,
      countryEn: city.countryEn,
      images: city.images,
      createdAt: city.createdAt,
      updatedAt: city.updatedAt,
      propertiesCount: city.propertiesCount,
      isActive: city.isActive,
      metadata: city.metadata,
    );
  }
}
