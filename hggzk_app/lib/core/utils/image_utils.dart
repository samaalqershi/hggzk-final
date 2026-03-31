import '../constants/api_constants.dart';

/// يحول قيمة الصورة المخزنة إلى رابط صالح للعرض في الشبكة.
/// Resolves stored image values into displayable network URLs.
class ImageUtils {
  /// يعيد الرابط كما هو إذا كان كاملًا، أو يركب المسار على `imageBaseUrl`.
  /// Returns full URLs as-is or joins relative paths with `imageBaseUrl`.
  static String resolveUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = _normalizeUploadsPath(url.trim());
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return trimmed;
    }
    // Ensure single slash between base and path
    final base = ApiConstants.imageBaseUrl.endsWith('/')
        ? ApiConstants.imageBaseUrl
            .substring(0, ApiConstants.imageBaseUrl.length - 1)
        : ApiConstants.imageBaseUrl;
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$path';
  }

  static String _normalizeUploadsPath(String value) {
    final normalizedSlashes = value.replaceAll('\\', '/');
    final uploadsMarker = '/Uploads/';
    final uploadsIndex = normalizedSlashes.indexOf(uploadsMarker);
    if (uploadsIndex != -1) {
      final relativePath =
          normalizedSlashes.substring(uploadsIndex + uploadsMarker.length);
      return '/uploads/$relativePath';
    }

    if (normalizedSlashes.startsWith('Uploads/')) {
      return '/uploads/${normalizedSlashes.substring('Uploads/'.length)}';
    }

    return normalizedSlashes;
  }
}
