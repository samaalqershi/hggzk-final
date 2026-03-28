import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hggzkportal/app/app.dart';
import 'package:hggzkportal/core/bloc/app_bloc.dart';
import 'package:hggzkportal/core/localization/locale_manager.dart';
import 'package:hggzkportal/core/utils/timezone_helper.dart';
import 'package:hggzkportal/injection_container.dart' as di;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hggzkportal/services/chat_sync_manager.dart';
import 'package:hggzkportal/services/connectivity_service.dart';
import 'package:hggzkportal/services/notification_service.dart';

/// Starts the portal app after preparing Firebase, local storage, routing
/// services, and the pieces that must be ready before the first screen appears.
/// يشغّل تطبيق البورتال بعد تجهيز Firebase والتخزين المحلي وخدمات التوجيه
/// وكل ما يجب أن يكون حاضرًا قبل ظهور أول شاشة.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _bootstrapApplication();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const HggzkPortalApp());

  WidgetsBinding.instance.addPostFrameCallback(
    (_) => _initializeDeferredServices(),
  );
}

/// Prepares the foundation required for the app shell: Firebase, Hive, DI,
/// locale state, and the background FCM handler.
/// يجهز الأساس المطلوب لواجهة التطبيق: Firebase وHive والحقن واللغة ومعالج
/// رسائل FCM الخلفية.
Future<void> _bootstrapApplication() async {
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await Hive.initFlutter();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await di.init();

  AppBloc.initialize();
  AppBloc.initializeEvents();

  final initialLocale = await LocaleManager.getInitialLocale();
  AppBloc.locale.setLocale(initialLocale);
}

/// Starts services that can wait until the first frame so the app becomes
/// visible quickly without delaying heavy setup work.
/// يشغّل الخدمات التي يمكن تأخيرها لما بعد أول إطار حتى تظهر الواجهة بسرعة
/// من دون حبس الإقلاع في أعمال ثقيلة.
Future<void> _initializeDeferredServices() async {
  await ConnectivityService().initialize();
  await di.sl<NotificationService>().initialize();
  await di.sl<ChatSyncManager>().initialize();
  await TimezoneHelper.initialize();
}

/// Receives background FCM messages on a background isolate and forwards them
/// to the notification layer after Firebase has been initialized.
/// يستقبل رسائل FCM الخلفية في معزول منفصل ثم يمررها إلى طبقة الإشعارات
/// بعد تهيئة Firebase.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.handleBackgroundMessageEntryPoint(message);
}
