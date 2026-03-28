import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hggzk/core/utils/timezone_helper.dart';
import 'package:hggzk/app/app.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart' as di;
import 'package:hggzk/app/bloc/app_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hggzk/core/services/connectivity_service.dart';
import 'package:hggzk/core/services/notification_service.dart';

/// نقطة تشغيل التطبيق وتهيئة الخدمات العامة قبل بناء الواجهة.
/// Application entry point that initializes shared services before UI startup.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  // Background FCM handling is only applicable to mobile platforms.
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  await Hive.initFlutter();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await di.init();

  // Initialize AppBloc after dependency injection
  AppBloc.initialize();
  AppBloc.initializeEvents();

  // Set system UI overlay style
  final platformBrightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;
  final isDark = platformBrightness == Brightness.dark;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ),
  );
  runApp(const HggzkApp());

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // Initialize connectivity service
    await ConnectivityService().initialize();
    // Initialize notifications only on supported mobile platforms.
    if (!kIsWeb) {
      await di.sl<NotificationService>().initialize();
    }
    // تهيئة timezone
    await TimezoneHelper.initialize();
  });
}

// Top-level background message handler (required by firebase_messaging)
@pragma('vm:entry-point')

/// يعالج رسائل Firebase الخلفية بعد تهيئة التطبيق في وضع منفذ
/// entry-point حتى تظل الإشعارات تعمل عندما لا تكون الواجهة مفتوحة.
/// Processes the Firebase background messages from the app's entry-point
/// isolate so notifications still work when the UI is not visible flow and keeps the behavior aligned with the surrounding feature.
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}
