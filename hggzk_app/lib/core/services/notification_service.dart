import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:hggzk/app/router/navigation_service.dart';
import 'package:hggzk/core/constants/route_constants.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:hggzk/core/localization/locale_manager.dart';
import 'package:hggzk/core/network/api_client.dart';
import 'package:hggzk/core/services/local_storage_service.dart';
import 'package:hggzk/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:go_router/go_router.dart';

/// يدير دورة الإشعارات كاملة: الأذونات، القنوات، FCM، والتعامل مع النقرات.
/// Orchestrates the full notification lifecycle: permissions, channels, FCM, and tap handling.
class NotificationService {
  /// واجهة Firebase Messaging التي نستقبل عبرها الرموز والرسائل الجديدة.
  /// Firebase Messaging entry point used for tokens and incoming pushes.
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// عميل الشبكة المستخدم عندما نحتاج لمزامنة التوكن مع الخادم.
  /// Network client used to sync tokens or notification preferences with the backend.
  final ApiClient? _apiClient;

  /// التخزين المحلي الذي يحتفظ بالتوكن وبعض القيم المساندة.
  /// Local storage used to persist the token and related cached values.
  final LocalStorageService? _localStorage;

  /// مصدر محلي نقرأ منه هوية المستخدم وأدواره للاشتراك في القنوات المناسبة.
  /// Local auth source used to resolve the current user and its topic subscriptions.
  final AuthLocalDataSource? _authLocalDataSource;

  /// يربط الخدمة باعتمادياتها مع إبقاء التنفيذ قابلاً للاختبار والاستبدال.
  /// Receives dependencies explicitly so the service stays testable and replaceable.
  NotificationService({
    ApiClient? apiClient,
    LocalStorageService? localStorage,
    AuthLocalDataSource? authLocalDataSource,
  })  : _apiClient = apiClient,
        _localStorage = localStorage,
        _authLocalDataSource = authLocalDataSource;

  /// يجهز الأذونات والقنوات والمستمعين قبل أن يبدأ التطبيق باستقبال الإشعارات.
  /// Prepares permissions, channels, and listeners before notifications can flow.
  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('NotificationService.initialize skipped on web');
      return;
    }

    // Request permission
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Configure Firebase messaging
    await _configureFirebaseMessaging();

    // Get and register FCM token
    await _registerFcmToken();

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);
  }

  /// يطلب أذونات الإشعارات ويغطي فروقات Android 13+ وFirebase.
  /// Requests notification permissions and handles Android 13+ plus Firebase-specific flow.
  Future<void> _requestPermission() async {
    if (kIsWeb) {
      return;
    }

    // Android 13+ requires runtime POST_NOTIFICATIONS permission
    if (Platform.isAndroid) {
      final current = await Permission.notification.status;
      if (!current.isGranted) {
        final result = await Permission.notification.request();
        debugPrint('Android notification permission result: $result');
      }
    }

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    debugPrint(
        'Notification permission status: ${settings.authorizationStatus}');
  }

  /// يهيئ القنوات المحلية حتى تظهر الإشعارات بشكل موثوق حتى في الخلفية.
  /// Sets up local notification channels so pushes render reliably in foreground/background.
  Future<void> _initializeLocalNotifications() async {
    if (kIsWeb) {
      return;
    }

    // Ensure the Android channel exists so push notifications render reliably
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Android: create notification channels up front
    final androidChannel = AndroidNotificationChannel(
      'hggzk_channel',
      await _tr('core.notifications.channel.main.name'),
      description: await _tr('core.notifications.channel.main.description'),
      importance: Importance.high,
    );
    final androidScheduledChannel = AndroidNotificationChannel(
      'hggzk_scheduled',
      await _tr('core.notifications.channel.scheduled.name'),
      description:
          await _tr('core.notifications.channel.scheduled.description'),
      importance: Importance.high,
    );
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);
    await androidPlugin?.createNotificationChannel(androidScheduledChannel);
  }

  /// يربط حالات وصول الرسائل وفتح التطبيق بالإشعار.
  /// Hooks Firebase messaging events for foreground delivery and notification taps.
  Future<void> _configureFirebaseMessaging() async {
    if (kIsWeb) {
      return;
    }

    // Suppress OS banners/sounds while foreground; we'll show our own in-app dialog
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Message opened app handler
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check if app was opened by notification
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// يسجل توكن FCM في الخادم ويخزنه محليًا للاستخدام اللاحق.
  /// Registers the FCM token with the backend and persists it locally.
  Future<void> _registerFcmToken() async {
    if (kIsWeb) {
      return;
    }

    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('FCM token: $token');
        await _sendTokenToServer(token);
        await _localStorage?.saveFcmToken(token);
        await _subscribeToDefaultTopics();
      }
    } catch (e) {
      debugPrint('Error registering FCM token: $e');
    }
  }

  /// يشترك في القنوات المرتبطة بالمستخدم الحالي وأدواره الفعلية فقط.
  /// Subscribes the device to user-specific and role-specific topics only.
  Future<void> _subscribeToDefaultTopics() async {
    if (kIsWeb) {
      return;
    }

    try {
      final user = await _authLocalDataSource?.getCachedUser();
      if (user != null) {
        final String userId = user.userId;
        if (userId.isNotEmpty) {
          await _firebaseMessaging.subscribeToTopic('user_$userId');
        }
        final List<String> roles =
            (user.roles).map((e) => e.toString()).toList();
        final uniqueRoles = roles
            .where((r) => r.trim().isNotEmpty)
            .map((r) => _normalizeRole(r))
            .toSet()
            .toList();
        for (final role in uniqueRoles) {
          await _firebaseMessaging.subscribeToTopic('role_$role');
        }
      }
    } catch (e) {
      debugPrint('Error subscribing to default topics: $e');
    }
  }

  /// يزيل اشتراكات القنوات عند تسجيل الخروج حتى لا تصل إشعارات غير مرتبطة.
  /// Removes topic subscriptions during sign-out so stale notifications stop arriving.
  Future<void> _unsubscribeFromDefaultTopics() async {
    if (kIsWeb) {
      return;
    }

    try {
      final user = await _authLocalDataSource?.getCachedUser();
      if (user != null) {
        final String userId = user.userId;
        if (userId.isNotEmpty) {
          await _firebaseMessaging.unsubscribeFromTopic('user_$userId');
        }
        final List<String> roles =
            (user.roles).map((e) => e.toString()).toList();
        final uniqueRoles = roles
            .where((r) => r.trim().isNotEmpty)
            .map((r) => _normalizeRole(r))
            .toSet()
            .toList();
        for (final role in uniqueRoles) {
          await _firebaseMessaging.unsubscribeFromTopic('role_$role');
        }
      }
    } catch (e) {
      debugPrint('Error unsubscribing from default topics: $e');
    }
  }

  /// Maps role labels from different backend sources to one canonical value so
  /// topic names stay predictable.
  /// يطبع أسماء الأدوار القادمة من مصادر مختلفة إلى قيمة موحدة حتى تبقى أسماء
  /// الـ topics قابلة للتوقع.
  String _normalizeRole(String role) {
    final r = role.trim();
    switch (r.toLowerCase()) {
      case 'client':
      case 'customer':
        return 'client';
      case 'superadmin':
      case 'super_admin':
        return 'admin';
      case 'staff':
        return 'staff';
      case 'guest':
        return 'guest';
      default:
        return r.toLowerCase();
    }
  }

  /// Sends the current device token to the backend together with the active
  /// user identity and platform type.
  /// يرسل توكن الجهاز الحالي إلى الخادم مع هوية المستخدم الحالية ونوع المنصة
  /// حتى يمكن توجيه الإشعارات بشكل صحيح.
  Future<void> _sendTokenToServer(String token) async {
    if (kIsWeb) {
      return;
    }

    if (_apiClient == null || _authLocalDataSource == null) return;

    try {
      final user = await _authLocalDataSource!.getCachedUser();
      if (user == null) return;

      final deviceType = Platform.isIOS ? 'iOS' : 'Android';

      await _apiClient!.post(
        '/api/fcm/register',
        data: {
          'userId': user.userId,
          'token': token,
          'deviceType': deviceType,
        },
      );
    } catch (e) {
      debugPrint('Error sending FCM token to server: $e');
    }
  }

  /// Re-synchronizes the token lifecycle whenever Firebase rotates it behind
  /// the scenes.
  /// يعيد مزامنة دورة حياة التوكن كلما قامت Firebase بتدويره في الخلفية.
  Future<void> _onTokenRefresh(String token) async {
    debugPrint('FCM token refreshed: $token');
    await _sendTokenToServer(token);
    await _localStorage?.saveFcmToken(token);
    await _subscribeToDefaultTopics();
  }

  /// Removes the backend association and topic subscriptions for the current
  /// token when the signed-in user should no longer receive pushes.
  /// يزيل ربط التوكن الحالي من الخادم ويلغي اشتراكاته عندما لا ينبغي للمستخدم
  /// الحالي أن يستمر في استقبال الإشعارات.
  Future<void> unregisterFcmToken() async {
    if (_apiClient == null || _authLocalDataSource == null) return;

    try {
      final user = await _authLocalDataSource!.getCachedUser();
      if (user == null) return;
      final token = await _firebaseMessaging.getToken();

      await _apiClient!.post(
        '/api/fcm/unregister',
        data: {
          'userId': user.userId,
          if (token != null) 'token': token,
        },
      );

      await _unsubscribeFromDefaultTopics();
      await _firebaseMessaging.deleteToken();
    } catch (e) {
      debugPrint('Error unregistering FCM token: $e');
    }
  }

  /// Interprets a foreground push, skips silent real-time updates, derives a
  /// sensible visual priority, and surfaces the message inside the app.
  /// يفسر إشعار الـ foreground، ويتجاوز التحديثات الصامتة، ويستنتج أولوية
  /// بصرية مناسبة، ثم يعرض الرسالة داخل التطبيق.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.messageId}');
    final data = message.data;
    final type = (data['type'] ?? data['event_type'] ?? '').toString();

    // Silent types (chat updates etc.)
    if (type == 'new_message' ||
        type == 'chat.new_message' ||
        type == 'conversation_created' ||
        type == 'reaction_added' ||
        type == 'reaction_removed' ||
        type == 'message_status_updated' ||
        (data['silent']?.toString() == 'true')) {
      return;
    }

    final notification = message.notification;
    String title =
        (notification?.title ?? data['title'] ?? '').toString().trim();
    String body = (notification?.body ?? data['body'] ?? data['message'] ?? '')
        .toString()
        .trim();

    // Fallbacks
    final fallbackType = (data['type'] ?? data['event_type'] ?? '').toString();
    final id =
        (data['id'] ?? data['booking_id'] ?? data['conversation_id'] ?? '')
            .toString();
    if (title.isEmpty) {
      switch (fallbackType) {
        case 'booking':
          title = await _tr(
            'core.notifications.booking.title',
          );
          break;
        case 'chat':
        case 'new_message':
          title = await _tr(
            'core.notifications.chat.title',
          );
          break;
        case 'conversation_created':
          title = await _tr(
            'core.notifications.conversationCreated.title',
          );
          break;
        default:
          title = await _tr(
            'core.notifications.default.title',
          );
      }
    }
    if (body.isEmpty) {
      switch (fallbackType) {
        case 'booking':
          body = id.isNotEmpty
              ? await _tr(
                  'core.notifications.booking.bodyWithId',
                  params: {'id': id},
                )
              : await _tr(
                  'core.notifications.booking.body',
                );
          break;
        case 'chat':
        case 'new_message':
          body = await _tr(
            'core.notifications.chat.body',
          );
          break;
        case 'conversation_created':
          body = await _tr(
            'core.notifications.conversationCreated.body',
          );
          break;
        default:
          body = await _tr(
            'core.notifications.default.body',
          );
      }
    }

    // Derive priority
    final rawPriority = (data['priority'] ??
            data['severity'] ??
            data['level'] ??
            data['importance'] ??
            data['urgency'] ??
            '')
        .toString();
    String derivedPriority = rawPriority.trim().toLowerCase();
    String normalizePriority(String v) {
      final s = v.trim().toLowerCase();
      if (s.isEmpty) return s;
      if (RegExp(r'^[0-9]+$').hasMatch(s)) {
        final n = int.tryParse(s) ?? 0;
        if (n == 1 || n == 2) return 'high';
        if (n == 3) return 'medium';
        if (n == 4) return 'low';
        if (n >= 5) return 'info';
      }
      if ([
        'critical',
        'crit',
        'urgent',
        'high',
        'danger',
        'severe',
        'fatal',
        'error',
        'fail'
      ].contains(s)) return 'high';
      if (['warn', 'warning', 'medium'].contains(s)) return 'medium';
      if (['success', 'ok', 'done', 'approved', 'complete', 'completed', 'paid']
          .contains(s)) return 'success';
      if (['low', 'minor', 'info', 'default', 'normal'].contains(s))
        return 'info';
      if ([
        'عاجل',
        'طارئ',
        'خطر',
        'حرج',
        'عالية',
        'عالي',
        'مرتفع',
        'خطير',
        'خطأ',
        'فشل',
        'إلغاء',
        'ملغي',
        'رفض',
        'مرفوض'
      ].contains(s)) return 'high';
      if ([
        'تحذير',
        'متوسط',
        'معلق',
        'انتظار',
        'قيد',
        'قيد الانتظار',
        'قيد المعالجة',
        'تحذيري'
      ].contains(s)) return 'medium';
      if ([
        'نجاح',
        'ناجح',
        'مؤكد',
        'تم',
        'تم الدفع',
        'مدفوع',
        'مكتمل',
        'اكتمل',
        'موافق',
        'تمت الموافقة'
      ].contains(s)) return 'success';
      if (['منخفض', 'منخفضة', 'عادي', 'عادية', 'افتراضي', 'معلومات']
          .contains(s)) return 'info';
      return s;
    }

    if (derivedPriority.isNotEmpty) {
      derivedPriority = normalizePriority(derivedPriority);
    }
    if (derivedPriority.isEmpty || derivedPriority == 'info') {
      final contentToAnalyze = '${title.toLowerCase()} ${body.toLowerCase()}';
      bool containsAny(List<String> keys) =>
          keys.any((k) => contentToAnalyze.contains(k));
      if (containsAny([
        'cancelled',
        'canceled',
        'failed',
        'error',
        'rejected',
        'declined',
        'urgent',
        'critical',
        'expired',
        'overdue',
        'blocked',
        'suspended',
        'terminated',
        'denied',
        'ملغي',
        'إلغاء',
        'فشل',
        'خطأ',
        'رفض',
        'عاجل',
        'طارئ',
        'حرج'
      ])) {
        derivedPriority = 'high';
      } else if (containsAny([
        'confirmed',
        'approved',
        'successful',
        'completed',
        'paid',
        'accepted',
        'activated',
        'verified',
        'processed',
        'delivered',
        'received',
        'مؤكد',
        'موافق',
        'ناجح',
        'مكتمل',
        'مدفوع',
        'تم الدفع',
        'تم التحقق',
        'تم التسليم',
        'تم الاستلام'
      ])) {
        derivedPriority = 'success';
      } else if (containsAny([
        'pending',
        'waiting',
        'processing',
        'reminder',
        'attention',
        'review',
        'update required',
        'expiring soon',
        'action needed',
        'incomplete',
        'معلق',
        'قيد الانتظار',
        'قيد المعالجة',
        'تذكير',
        'انتباه',
        'مراجعة',
        'يتطلب تحديث',
        'ينتهي قريب',
        'يتطلب إجراء',
        'غير مكتمل'
      ])) {
        derivedPriority = 'medium';
      } else {
        derivedPriority = 'info';
      }
    }

    await _showInAppNotificationDialog(
      title: title,
      body: body,
      priority: derivedPriority,
      onOpen: () {
        try {
          _navigateToScreen(data, preferPush: true);
        } catch (e) {
          debugPrint('Navigation from in-app dialog failed: $e');
        }
      },
    );
  }

  /// Shows a focused in-app alert for important foreground notifications and
  /// gives the user a direct path to the related screen.
  /// يعرض تنبيهًا داخليًا مركزًا للإشعارات المهمة أثناء استخدام التطبيق ويمنح
  /// المستخدم انتقالًا مباشرًا إلى الشاشة المرتبطة.
  Future<void> _showInAppNotificationDialog({
    required String title,
    required String body,
    required String priority,
    required VoidCallback onOpen,
  }) async {
    final context = NavigationService.rootNavigatorKey.currentContext;
    if (context == null) {
      debugPrint('In-app notification context unavailable');
      return;
    }

    Color accentColor;
    switch (priority) {
      case 'error':
        accentColor = Colors.redAccent;
        break;
      case 'warning':
      case 'medium':
        accentColor = Colors.orangeAccent;
        break;
      case 'success':
        accentColor = Colors.green;
        break;
      default:
        accentColor = Colors.blueAccent;
        break;
    }

    final closeLabel = await _tr(
      'notifications.service.close',
    );
    final openLabel = await _tr(
      'notifications.service.open',
    );

    if (!context.mounted) {
      debugPrint('In-app notification context disposed before dialog display');
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.notifications_active_outlined, color: accentColor),
              const SizedBox(width: 8),
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(closeLabel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onOpen();
              },
              child: Text(openLabel),
            ),
          ],
        );
      },
    );
  }

  /// Routes a push payload after the user opens the application from the system
  /// notification tray.
  /// يوجّه حمولة الإشعار بعد أن يفتح المستخدم التطبيق من درج إشعارات النظام.
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.messageId}');
    _navigateToScreen(message.data);
  }

  /// Decodes the payload attached to a local notification so the same routing
  /// logic can be reused for remote and scheduled alerts.
  /// يفك شيفرة الحمولة المرفقة بإشعار محلي حتى يمكن إعادة استخدام منطق التوجيه
  /// نفسه مع الإشعارات البعيدة والمجدولة.
  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final data = json.decode(response.payload!);
      _navigateToScreen(data);
    }
  }

  /// Chooses the destination screen from notification metadata and optionally
  /// pushes instead of replacing the current route.
  /// يختار شاشة الوجهة من بيانات الإشعار الوصفية، ويمكنه الدفع فوق المسار
  /// الحالي بدل استبداله عند الحاجة.
  void _navigateToScreen(Map<String, dynamic> data, {bool preferPush = false}) {
    final type = data['type'];
    final id = data['id'] ?? data['conversation_id'];
    final context = NavigationService.rootNavigatorKey.currentContext;
    if (context == null) {
      debugPrint('Navigation context unavailable');
      return;
    }

    try {
      switch (type) {
        case 'booking':
          if (id != null && id.toString().isNotEmpty) {
            preferPush
                ? context.push('/booking/${id.toString()}')
                : context.go('/booking/${id.toString()}');
            return;
          }
          preferPush ? context.push('/main') : context.go('/main');
          return;
        case 'property':
          if (id != null && id.toString().isNotEmpty) {
            preferPush
                ? context.push('/property/${id.toString()}')
                : context.go('/property/${id.toString()}');
            return;
          }
          preferPush ? context.push('/search') : context.go('/search');
          return;
        case 'chat':
        case 'new_message':
        case 'conversation_created':
          if (id != null && id.toString().isNotEmpty) {
            preferPush
                ? context.push('/chat/${id.toString()}')
                : context.go('/chat/${id.toString()}');
            return;
          }
          preferPush
              ? context.push(RouteConstants.conversations)
              : context.go(RouteConstants.conversations);
          return;
        default:
          preferPush ? context.push('/main') : context.go('/main');
          return;
      }
    } catch (e) {
      debugPrint('Navigation failed: $e');
    }
  }

  /// Exposes the current notification authorization state for settings and
  /// onboarding flows.
  /// يوفّر حالة تفويض الإشعارات الحالية لاستخدامها في شاشات الإعدادات والتهيئة.
  Future<bool> areNotificationsEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Re-runs the permission prompt flow when the app wants to encourage the
  /// user to re-enable notifications.
  /// يعيد تشغيل مسار طلب الإذن عندما يرغب التطبيق في تشجيع المستخدم على إعادة
  /// تفعيل الإشعارات.
  Future<void> openNotificationSettings() async {
    await _firebaseMessaging.requestPermission();
  }

  /// Lists scheduled local notifications that are still waiting to fire.
  /// يسرد الإشعارات المحلية المجدولة التي ما زالت بانتظار التنفيذ.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  /// Cancels one scheduled notification when its reminder is no longer valid.
  /// يلغي إشعارًا مجدولًا واحدًا عندما يصبح التذكير المرتبط به غير صالح.
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Clears every scheduled or displayed local notification managed by this
  /// service.
  /// يمسح جميع الإشعارات المحلية المجدولة أو المعروضة التي تديرها هذه الخدمة.
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Schedules a future local notification using the device timezone so timing
  /// stays correct across regions.
  /// يجدول إشعارًا محليًا مستقبليًا باستخدام المنطقة الزمنية للجهاز حتى يبقى
  /// التوقيت صحيحًا عبر المناطق المختلفة.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, dynamic>? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'hggzk_scheduled',
      await _tr('notifications.service.scheduledChannelName'),
      channelDescription:
          await _tr('notifications.service.scheduledChannelDescription'),
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert DateTime to TZDateTime
    final tz.TZDateTime tzScheduledDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload != null ? json.encode(payload) : null,
    );
  }

  /// Exposes the latest FCM token currently associated with this device for
  /// diagnostics or explicit synchronization flows.
  /// يوفّر أحدث FCM token مرتبط بهذا الجهاز لاستخدامات التشخيص أو المزامنة
  /// الصريحة عند الحاجة.
  Future<String?> getFcmToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Adds the device to a custom topic outside the default user/role channels.
  /// يضيف الجهاز إلى topic مخصص خارج قنوات المستخدم والأدوار الافتراضية.
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  /// Removes the device from a custom topic when that message stream is no
  /// longer needed.
  /// يزيل الجهاز من topic مخصص عندما لا تبقى هناك حاجة لذلك المسار من الرسائل.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
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
}
