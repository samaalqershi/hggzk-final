import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../services/connectivity_service.dart';

/// Abstraction that answers the one question most repositories need before hitting the API.
/// تجريد يجيب عن السؤال الذي تحتاجه أغلب المستودعات قبل الاتصال بالخادم: هل الإنترنت متاح؟
abstract class NetworkInfo {
  /// Returns `true` when the app can reach the network, otherwise `false`.
  /// يعيد `true` عندما يستطيع التطبيق الوصول إلى الشبكة و`false` في الحالة المعاكسة.
  Future<bool> get isConnected;
}

/// Concrete implementation that combines the package checker with the app-level fallback.
/// تنفيذ فعلي يجمع بين فحص الحزمة والتحقق الاحتياطي على مستوى التطبيق.
class NetworkInfoImpl implements NetworkInfo {
  /// Low-level checker used for the primary connectivity signal.
  /// أداة الفحص منخفضة المستوى المستخدمة كإشارة أولى للاتصال.
  final InternetConnectionChecker connectionChecker;

  /// يربط تنفيذ التحقق الشبكي بكاشف الاتصال الأساسي المستخدم في المشروع.
  /// Binds the network-info implementation to the primary connection checker
  /// used by the project.
  NetworkInfoImpl(this.connectionChecker);

  /// يتحقق من توفر الاتصال الفعلي، مع الرجوع لخدمة احتياطية إذا تعثر الفحص
  /// الأساسي.
  /// Checks whether connectivity is actually available, with a fallback
  /// service if the primary probe fails.
  @override
  Future<bool> get isConnected async {
    try {
      return await connectionChecker.hasConnection;
    } catch (_) {
      // Fallback to app-level connectivity check to avoid IPv6 DNS issues
      try {
        return await ConnectivityService().checkConnection();
      } catch (_) {
        return false;
      }
    }
  }
}
