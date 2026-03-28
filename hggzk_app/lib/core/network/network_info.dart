import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:hggzk/core/services/connectivity_service.dart';

/// واجهة صغيرة تتيح لطبقات البيانات معرفة ما إذا كان الاتصال متاحًا.
/// Small abstraction that lets data layers check whether the device is online.
abstract class NetworkInfo {
  /// تعيد حالة الاتصال حتى تختار الطبقة العليا بين الشبكة أو الكاش.
  /// Reports connectivity so the caller can choose remote or cached data.
  Future<bool> get isConnected;
}

/// تطبيق يعتمد على فحص الإنترنت الفعلي ثم يتراجع إلى فحص أوسع عند الحاجة.
/// Default implementation that checks internet access and falls back when needed.
class NetworkInfoImpl implements NetworkInfo {
  /// أداة الفحص التي تتحقق من الاتصال الخارجي المباشر.
  /// Connectivity checker used for the primary online test.
  final InternetConnectionChecker connectionChecker;

  /// يحقن أداة فحص الاتصال بدل إنشاء الاعتماد داخل الكلاس.
  /// Receives the checker via dependency injection instead of constructing it internally.
  NetworkInfoImpl(this.connectionChecker);

  /// يفضّل نتيجة الفحص المباشر ثم يستخدم خدمة أوسع لتجنب السقوط الكاذب.
  /// Prefers the direct connectivity result and falls back to a broader app-level check.
  @override
  Future<bool> get isConnected async {
    try {
      return await connectionChecker.hasConnection;
    } catch (_) {
      // Fallback to app-level connectivity check to avoid DNS/IPv6 false negatives.
      try {
        return await ConnectivityService().checkConnection();
      } catch (_) {
        return false;
      }
    }
  }
}
