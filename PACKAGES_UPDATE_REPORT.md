# 📦 تقرير تحديث المكتبات (Packages Update Report)

## 📅 التاريخ
18 يناير 2026

## 🎯 الهدف
توحيد إصدارات المكتبات بين تطبيقات العملاء (hggzk_app & rezmate_app) وتطبيقات البورتال (hggzkportal_app & rezmateportal_app)

---

## 📊 جدول المقارنة والتحديثات

### 1️⃣ مكتبات الشبكة (Network)

| المكتبة | النسخة القديمة<br/>(Portal) | النسخة الجديدة<br/>(Apps) | الحالة |
|---------|---------------------------|--------------------------|--------|
| **web_socket_channel** | `^2.4.3` | `^3.0.3` | ✅ تم التحديث |
| **connectivity_plus** | `^5.0.2` | `^6.0.5` (hggzk)<br/>`^5.0.2` (rezmate) | ✅ تم تحديث hggzkportal |
| **google_sign_in** | ❌ غير موجود | `^6.3.0` | ✅ تمت الإضافة |
| **flutter_facebook_auth** | ❌ غير موجود | `^6.0.4` | ✅ تمت الإضافة |

---

### 2️⃣ مكتبات Firebase

| المكتبة | النسخة القديمة | النسخة الجديدة | الفرق |
|---------|----------------|----------------|-------|
| **firebase_core** | `^2.25.4` | `^3.8.1` | ⬆️ +1 Major |
| **firebase_messaging** | `^14.7.15` | `^15.1.6` | ⬆️ +1 Major |
| **firebase_analytics** | `^10.8.6` | `^11.3.6` | ⬆️ +1 Major |
| **firebase_crashlytics** | `^3.4.14` | `^4.2.1` | ⬆️ +1 Major |
| **firebase_dynamic_links** | `^5.4.13` | `^6.0.10` | ⬆️ +1 Major |

⚠️ **ملاحظة:** جميع مكتبات Firebase تم ترقيتها إلى Major Version جديد - قد يتطلب تحديثات في الكود.

---

### 3️⃣ مكتبات متطابقة (لا تحتاج تحديث)

المكتبات التالية متطابقة في جميع المشاريع:

- ✅ `dio: ^5.4.1`
- ✅ `pretty_dio_logger: ^1.3.1`
- ✅ `internet_connection_checker: ^1.0.0+1`
- ✅ `shared_preferences: ^2.2.2`
- ✅ `hive: ^2.2.3`
- ✅ `hive_flutter: ^1.1.0`
- ✅ `geolocator: ^11.0.0`
- ✅ `geocoding: ^2.1.1`
- ✅ `permission_handler: ^11.2.0`
- ✅ `flutter_local_notifications: ^17.2.3`
- ✅ `equatable: ^2.0.5`
- ✅ `dartz: ^0.10.1`
- ✅ `http: ^1.2.0`
- ✅ `intl: ^0.20.2`
- ✅ `cached_network_image: ^3.3.1`
- ✅ `flutter_svg: ^2.0.10+1`
- ✅ `flutter_spinkit: ^5.2.1`
- ✅ `flutter_rating_bar: ^4.0.1`
- ✅ `timezone: ^0.9.4`
- ✅ `shimmer: ^2.0.0`
- ✅ `google_maps_flutter: ^2.2.3`
- ✅ `photo_view: ^0.14.0`
- ✅ `smooth_page_indicator: ^1.0.0`
- ✅ `visibility_detector: ^0.4.0`
- ✅ `qr_flutter: ^4.1.0`
- ✅ `go_router: ^14.2.7`
- ✅ `app_links: ^6.4.0`
- ✅ `carousel_slider: ^5.1.1`
- ✅ `url_launcher: ^6.3.0`
- ✅ `package_info_plus: ^8.0.2`
- ✅ `device_info_plus: ^9.0.0`
- ✅ `flutter_credit_card: ^4.0.1`
- ✅ `mask_text_input_formatter: ^2.5.0`
- ✅ `webview_flutter: ^4.7.0`
- ✅ `provider: ^6.1.1`
- ✅ `record: ^6.0.0`
- ✅ `image_picker: ^1.0.7`
- ✅ `image_cropper: ^8.0.2`
- ✅ `flutter_timezone: ^5.0.0`

---

### 4️⃣ مكتبات خاصة بالبورتال (لن يتم حذفها)

البورتالات تحتوي على مكتبات إضافية غير موجودة في التطبيقات:

- `flutter_map: ^7.0.2`
- `latlong2: ^0.9.1`
- `local_auth: ^2.3.0`
- `flutter_secure_storage: ^9.2.2`
- `table_calendar: ^3.1.2` (موجودة في rezmate_app أيضاً)
- `timeline_tile: ^2.0.0`
- `fl_chart: ^1.0.0`
- `percent_indicator: ^4.2.3`
- `dotted_border: ^2.1.0`
- `flutter_staggered_animations: ^1.1.1` (موجودة في التطبيقات أيضاً)
- `reorderable_grid_view: ^1.0.10`
- `reorderables: ^0.6.0`
- `video_player: ^2.8.2`
- `video_thumbnail: ^0.5.3`
- `path_provider: ^2.1.2`
- `chewie: ^1.13.0`
- `just_audio: ^0.9.36`
- `photo_manager: ^3.0.0`
- `image_editor_plus: ^1.0.0`
- `image: ^4.1.7`
- `pdf: ^3.10.8`
- `lottie: ^3.3.2`

---

### 5️⃣ مكتبات خاصة بالتطبيقات (لن يتم إضافتها للبورتال)

التطبيقات تحتوي على مكتبات غير ضرورية للبورتال:

- (لا توجد مكتبات إضافية كبيرة)

---

## 📝 ملخص التغييرات

### hggzkportal_app

**تم التحديث:**
```yaml
# Network
web_socket_channel: ^2.4.3 → ^3.0.3 ⬆️
connectivity_plus: ^5.0.2 → ^6.0.5 ⬆️

# تمت الإضافة
google_sign_in: ^6.3.0 ✅
flutter_facebook_auth: ^6.0.4 ✅

# Firebase
firebase_core: ^2.25.4 → ^3.8.1 ⬆️
firebase_messaging: ^14.7.15 → ^15.1.6 ⬆️
firebase_analytics: ^10.8.6 → ^11.3.6 ⬆️
firebase_crashlytics: ^3.4.14 → ^4.2.1 ⬆️
firebase_dynamic_links: ^5.4.13 → ^6.0.10 ⬆️
```

---

### rezmateportal_app

**تم التحديث:**
```yaml
# Network
web_socket_channel: ^2.4.3 → ^3.0.3 ⬆️

# تمت الإضافة
google_sign_in: ^6.3.0 ✅
flutter_facebook_auth: ^6.0.4 ✅

# Firebase
firebase_core: ^2.25.4 → ^3.8.1 ⬆️
firebase_messaging: ^14.7.15 → ^15.1.6 ⬆️
firebase_analytics: ^10.8.6 → ^11.3.6 ⬆️
firebase_crashlytics: ^3.4.14 → ^4.2.1 ⬆️
firebase_dynamic_links: ^5.4.13 → ^6.0.10 ⬆️
```

---

## ⚠️ تحذيرات هامة

### 1. Breaking Changes في Firebase

**Firebase Core 3.x:**
- تغييرات في طريقة التهيئة
- قد يتطلب تحديث `google-services.json` و `GoogleService-Info.plist`

**Firebase Messaging 15.x:**
- تغييرات في API للإشعارات
- قد يتطلب تحديث كود معالجة الإشعارات

**Firebase Crashlytics 4.x:**
- تحسينات في الأداء
- قد يتطلب تحديث إعدادات Gradle

---

### 2. Breaking Changes في web_socket_channel

**من 2.x إلى 3.x:**
- تغييرات في `WebSocketChannel` API
- قد يتطلب تحديث كود WebSocket

---

### 3. Breaking Changes في connectivity_plus

**من 5.x إلى 6.x (hggzkportal فقط):**
- تحسينات في الأداء
- قد يتطلب تحديث استخدامات `ConnectivityResult`

---

## 🔧 خطوات ما بعد التحديث

### 1️⃣ تشغيل Flutter Pub Get

```bash
# hggzkportal_app
cd /home/ameen/Desktop/BOOKIN/BOOKIN/hggzkportal_app
flutter pub get
flutter pub upgrade

# rezmateportal_app
cd /home/ameen/Desktop/BOOKIN/BOOKIN/rezmateportal_app
flutter pub get
flutter pub upgrade
```

---

### 2️⃣ تحديث Firebase Configuration

#### Android:

تأكد من تحديث `google-services.json`:
```bash
# hggzkportal_app
cp android/app/google-services.json android/app/google-services.json.backup
# حمّل نسخة جديدة من Firebase Console إذا لزم الأمر
```

تأكد من Gradle مُحدّث:
```gradle
// android/build.gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'  // تحديث هذا
    classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'
}
```

#### iOS:

تأكد من تحديث `GoogleService-Info.plist`:
```bash
# hggzkportal_app
cp ios/Runner/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist.backup
# حمّل نسخة جديدة من Firebase Console إذا لزم الأمر
```

تأكد من Podfile مُحدّث:
```ruby
# ios/Podfile
platform :ios, '12.0'  # تأكد من minimum iOS version
```

---

### 3️⃣ تحديث كود WebSocket (إذا لزم الأمر)

```dart
// قديم (2.x)
import 'package:web_socket_channel/io.dart';
final channel = IOWebSocketChannel.connect(url);

// جديد (3.x) - قد يظل نفسه، لكن تحقق من التوثيق
import 'package:web_socket_channel/web_socket_channel.dart';
final channel = WebSocketChannel.connect(Uri.parse(url));
```

---

### 4️⃣ تحديث كود Firebase Messaging (إذا لزم الأمر)

```dart
// تأكد من أن هذا الكود يعمل مع 15.x
FirebaseMessaging.instance.getToken().then((token) {
  print('FCM Token: $token');
});

// Foreground messages
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // معالجة الإشعار
});
```

---

### 5️⃣ تحديث كود Connectivity Plus (hggzkportal فقط)

```dart
// تأكد من استخدام API الجديد
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityResult = await Connectivity().checkConnectivity();
if (connectivityResult == ConnectivityResult.mobile) {
  // متصل بالموبايل
} else if (connectivityResult == ConnectivityResult.wifi) {
  // متصل بالواي فاي
}
```

---

### 6️⃣ اختبار شامل

```bash
# تشغيل اختبارات الوحدة
flutter test

# تشغيل على Android
flutter run -d android

# تشغيل على iOS
flutter run -d ios

# تشغيل على Web
flutter run -d chrome
```

---

### 7️⃣ تنظيف الملفات المؤقتة

```bash
cd /home/ameen/Desktop/BOOKIN/BOOKIN/hggzkportal_app
flutter clean
flutter pub get

# Android
cd android && ./gradlew clean && cd ..

# iOS
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
```

---

## 📋 Checklist النهائي

### hggzkportal_app:
- [x] تحديث `pubspec.yaml`
- [ ] `flutter pub get`
- [ ] تحديث `google-services.json` (إذا لزم)
- [ ] تحديث `GoogleService-Info.plist` (إذا لزم)
- [ ] تحديث كود WebSocket
- [ ] تحديث كود Firebase
- [ ] تحديث كود Connectivity
- [ ] اختبار التطبيق على Android
- [ ] اختبار التطبيق على iOS
- [ ] اختبار التطبيق على Web

### rezmateportal_app:
- [x] تحديث `pubspec.yaml`
- [ ] `flutter pub get`
- [ ] تحديث `google-services.json` (إذا لزم)
- [ ] تحديث `GoogleService-Info.plist` (إذا لزم)
- [ ] تحديث كود WebSocket
- [ ] تحديث كود Firebase
- [ ] اختبار التطبيق على Android
- [ ] اختبار التطبيق على iOS
- [ ] اختبار التطبيق على Web

---

## 🐛 مشاكل متوقعة وحلولها

### مشكلة 1: خطأ في Gradle Sync

**الخطأ:**
```
Could not resolve com.google.firebase:firebase-messaging:XX.X.X
```

**الحل:**
```bash
cd android
./gradlew clean
./gradlew --stop
cd ..
flutter clean
flutter pub get
```

---

### مشكلة 2: خطأ في Pod Install

**الخطأ:**
```
[!] CocoaPods could not find compatible versions for pod "Firebase/Messaging"
```

**الحل:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install --repo-update
cd ..
```

---

### مشكلة 3: خطأ WebSocket Connection

**الخطأ:**
```
WebSocketChannelException: WebSocket connection failed
```

**الحل:**
```dart
// تأكد من استخدام Uri.parse()
final channel = WebSocketChannel.connect(Uri.parse('wss://your-url'));
```

---

### مشكلة 4: FCM Token null

**الخطأ:**
```
FCM Token is null
```

**الحل:**
```dart
// تأكد من طلب الأذونات أولاً
await FirebaseMessaging.instance.requestPermission();
final token = await FirebaseMessaging.instance.getToken();
```

---

## 📚 مراجع

- **Firebase Flutter:** https://firebase.flutter.dev/
- **web_socket_channel:** https://pub.dev/packages/web_socket_channel
- **connectivity_plus:** https://pub.dev/packages/connectivity_plus
- **Migration Guides:** https://firebase.google.com/support/release-notes/flutter

---

**تاريخ التحديث:** 18 يناير 2026  
**الحالة:** ✅ تم تحديث pubspec.yaml في كلا البورتالين  
**الخطوة التالية:** تشغيل `flutter pub get` واختبار التطبيقات
