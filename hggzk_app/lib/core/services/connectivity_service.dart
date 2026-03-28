import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// يراقب الشبكة ويقدّم حالة اتصال موحدة يعتمد عليها التطبيق كله.
/// Watches network reachability and exposes one shared connection state.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  /// يعيد المثيل الوحيد حتى تبقى مراقبة الاتصال مركزية في كل الشاشات.
  /// Returns the singleton so connectivity tracking stays centralized.
  factory ConnectivityService() => _instance;

  /// ينشئ الحالة الداخلية للمثيل الوحيد المسؤول عن مراقبة الاتصال.
  /// Creates the internal state for the singleton connectivity watcher.
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  /// Caches the last verified online/offline result so screens can read it instantly
  /// without forcing another network probe.
  /// Latest confirmed connection state for immediate reads.
  bool _isConnected = false;

  /// مؤقت الفحص الدوري الذي يبقي الحالة محدثة حتى لو لم يتحرك المستخدم.
  /// Periodic checker that keeps the state fresh even when the user is idle.
  Timer? _connectionCheckTimer;

  /// يبث تغييرات الاتصال لتستطيع الشاشات الاشتراك بها.
  /// Broadcast stream used by UI layers that need live connectivity updates.
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  /// يعيد الحالة المخزنة حاليًا دون إجبار المستخدم على انتظار فحص جديد.
  /// Returns the current cached connectivity state without forcing a new probe.
  bool get isConnected => _isConnected;

  /// يبدأ المراقبة الفعلية ويجلب أول حالة اتصال قبل أي اعتماد عليها.
  /// Starts connectivity monitoring and captures the initial network state first.
  Future<void> initialize() async {
    // التحقق من الحالة الأولية
    await _checkConnectionStatus();

    // الاستماع لتغييرات الاتصال
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _handleConnectivityChange(
          results.isNotEmpty ? results.first : ConnectivityResult.none);
    });

    // بدء فحص دوري للاتصال كل 30 ثانية
    _startPeriodicConnectionCheck();
  }

  /// يتحقق من الوصول الفعلي للإنترنت ويحدّث الحالة المشتركة عند تغيرها.
  /// Probes real internet reachability and updates the shared state when it changes.
  Future<bool> checkConnection() async {
    try {
      // التحقق من الاتصال بالإنترنت
      final result = await InternetAddress.lookup('google.com');
      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      if (_isConnected != isConnected) {
        _isConnected = isConnected;
        _connectionStatusController.add(isConnected);
      }

      return isConnected;
    } on SocketException catch (_) {
      if (_isConnected) {
        _isConnected = false;
        _connectionStatusController.add(false);
      }
      return false;
    } catch (e) {
      print('Error checking connection: $e');
      return false;
    }
  }

  /// يعيد نوع الاتصال الحالي ليستفيد منه العرض أو التشخيص.
  /// Returns the current transport type for UI or diagnostics.
  Future<ConnectivityResult> getConnectionType() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.isNotEmpty ? results.first : ConnectivityResult.none;
    } catch (e) {
      print('Error getting connection type: $e');
      return ConnectivityResult.none;
    }
  }

  /// يقدّر جودة الاتصال بناءً على زمن استجابة تقريبي.
  /// Estimates connection quality using an approximate response-time probe.
  Future<ConnectionQuality> checkConnectionQuality() async {
    try {
      final stopwatch = Stopwatch()..start();

      // محاولة الاتصال بخادم سريع
      final result = await InternetAddress.lookup('8.8.8.8');
      stopwatch.stop();

      final responseTime = stopwatch.elapsedMilliseconds;

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (responseTime < 100) {
          return ConnectionQuality.excellent;
        } else if (responseTime < 300) {
          return ConnectionQuality.good;
        } else if (responseTime < 1000) {
          return ConnectionQuality.fair;
        } else {
          return ConnectionQuality.poor;
        }
      } else {
        return ConnectionQuality.none;
      }
    } catch (e) {
      return ConnectionQuality.none;
    }
  }

  /// يختبر وصول TCP إلى خادم محدد عندما نحتاج تحققًا أدق من مجرد الإنترنت.
  /// Tests TCP reachability to a specific host when a narrower check is needed.
  Future<bool> testConnectionToServer(String host,
      {int port = 80, Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      await socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// يفحص خوادم التطبيق المعروفة كإشارة إضافية قبل اعتبار الانقطاع كاملًا.
  /// Tries known app servers as an extra signal before declaring a full outage.
  Future<bool> checkAppServerConnection() async {
    // يمكن إضافة خوادم التطبيق هنا
    const servers = [
      'api.hggzk.com',
      'hggzk.com',
    ];

    for (final server in servers) {
      try {
        final result = await InternetAddress.lookup(server);
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } catch (e) {
        continue;
      }
    }

    return false;
  }

  /// يبدأ إعادة الفحص المنتظمة حتى تبقى حالة الاتصال حديثة أثناء الاستخدام الطويل.
  /// Starts periodic rechecks so long sessions keep an up-to-date connection state.
  void _startPeriodicConnectionCheck() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer =
        Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkConnectionStatus();
    });
  }

  /// يوقف الفحص الدوري عندما لا تعود الخدمة بحاجة إلى مراقبة مستمرة.
  /// Stops periodic monitoring when continuous checks are no longer needed.
  void stopPeriodicConnectionCheck() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = null;
  }

  /// يحول تحديثات `connectivity_plus` إلى حالة بسيطة ومباشرة للتطبيق.
  /// Converts `connectivity_plus` updates into the simpler app-level state.
  void _handleConnectivityChange(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;

    if (wasConnected != _isConnected) {
      _connectionStatusController.add(_isConnected);
    }
  }

  /// يفصل الاستدعاء الداخلي لفحص الاتصال ليبقى مسار التنفيذ واضحًا.
  /// Wraps the actual probe so the internal call site stays explicit.
  Future<void> _checkConnectionStatus() async {
    await checkConnection();
  }

  /// ينهي المؤقت ويغلق التدفق حتى لا تتسرب الموارد.
  /// Disposes the timer and stream controller to avoid resource leaks.
  void dispose() {
    stopPeriodicConnectionCheck();
    _connectionStatusController.close();
  }
}

/// درجات تقريبية لجودة الإنترنت بدل الاكتفاء بحالة متصل أو غير متصل.
/// Rough quality bands instead of a simple connected/disconnected flag.
enum ConnectionQuality {
  none,
  poor,
  fair,
  good,
  excellent,
}

/// يضيف أسماء وقراءة مبسطة لدرجات جودة الاتصال.
/// Adds readable labels and convenience helpers for connection quality.
extension ConnectionQualityExtension on ConnectionQuality {
  /// يعيد الاسم البشري المناسب لدرجة الاتصال الحالية.
  /// Returns a human-readable label for the current connection quality.
  String get displayName {
    switch (this) {
      case ConnectionQuality.none:
        return 'لا يوجد اتصال';
      case ConnectionQuality.poor:
        return 'اتصال ضعيف';
      case ConnectionQuality.fair:
        return 'اتصال مقبول';
      case ConnectionQuality.good:
        return 'اتصال جيد';
      case ConnectionQuality.excellent:
        return 'اتصال ممتاز';
    }
  }

  /// يختصر التحقق إلى نعم أو لا عندما لا نحتاج تفاصيل إضافية.
  /// Collapses the quality into a simple yes/no connectivity check.
  bool get isConnected {
    return this != ConnectionQuality.none;
  }
}
