import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() => _instance;

  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  bool _isConnected = false;

  Timer? _connectionCheckTimer;

  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  bool get isConnected => _isConnected;

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

  Future<ConnectivityResult> getConnectionType() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.isNotEmpty ? results.first : ConnectivityResult.none;
    } catch (e) {
      print('Error getting connection type: $e');
      return ConnectivityResult.none;
    }
  }

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

  void _startPeriodicConnectionCheck() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer =
        Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkConnectionStatus();
    });
  }

  void stopPeriodicConnectionCheck() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = null;
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;

    if (wasConnected != _isConnected) {
      _connectionStatusController.add(_isConnected);
    }
  }

  Future<void> _checkConnectionStatus() async {
    await checkConnection();
  }

  void dispose() {
    stopPeriodicConnectionCheck();
    _connectionStatusController.close();
  }
}

enum ConnectionQuality {
  none,
  poor,
  fair,
  good,
  excellent,
}

extension ConnectionQualityExtension on ConnectionQuality {
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

  bool get isConnected {
    return this != ConnectionQuality.none;
  }
}
