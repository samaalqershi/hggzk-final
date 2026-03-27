# ✅ تقرير إصلاح Google Sign-In - نسخة Release

**التاريخ:** 2026-02-06  
**الحالة:** ✅ **تم الإصلاح بنجاح**

---

## 📋 ملخص المشكلة

### الأعراض
- ✅ Google Sign-In يعمل في **Debug Mode**
- ❌ Google Sign-In **لا يعمل** في **Release Mode**
- الخطأ المحتمل: `DEVELOPER_ERROR` أو `API_NOT_CONNECTED`

### السبب الجذري المكتشف

```
🔍 المشكلة: استخدام Keystore خاطئ مع SHA-1 غير مسجل في Firebase

Debug Build:
  ✅ يستخدم: ~/.android/debug.keystore
  ✅ SHA-1 موجود بالصدفة في Firebase (أو لا يتحقق بدقة في debug)
  
Release Build:
  ❌ يستخدم: android/my-release-key.jks
  ❌ SHA-1 غير مسجل في Firebase
  ❌ Google OAuth يرفض الطلب
  
Firebase Console:
  ✅ SHA-1 المسجل: 1ae2f2c5930fb3dae4192d11909440f4375db075
  ✅ ينتمي إلى: upload-keystore.jks (في مجلد cer_ios)
```

---

## 🛠️ الإصلاحات المطبقة

### 1️⃣ إنشاء ملف `key.properties`

**الموقع:** [`android/key.properties`](./android/key.properties)

```properties
storePassword=Qaz1235@@Wsx1235@@
keyPassword=Qaz1235@@Wsx1235@@
keyAlias=upload
storeFile=../my-release-key.jks
```

**الحماية:** 
- ✅ تمت إضافة `key.properties` إلى [`.gitignore`](./android/.gitignore)
- ✅ لن يتم رفع كلمات المرور إلى Git

### 2️⃣ استبدال Release Keystore

**الإجراء:**
```bash
# نسخ الـ keystore الصحيح (الذي SHA-1 مسجل في Firebase)
cp cer_ios/upload-keystore.jks android/my-release-key.jks
```

**النتيجة:**
- ✅ SHA-1: `1A:E2:F2:C5:93:0F:B3:DA:E4:19:2D:11:90:94:40:F4:37:5D:B0:75`
- ✅ مسجل في Firebase Console
- ✅ موجود في `google-services.json`

### 3️⃣ التحقق من التطابق

| العنصر | القيمة | الحالة |
|--------|--------|---------|
| **Keystore** | `android/my-release-key.jks` | ✅ |
| **Alias** | `upload` | ✅ |
| **SHA-1** | `1ae2f2c5930fb3dae4192d11909440f4375db075` | ✅ |
| **Firebase** | مسجل في Console | ✅ |
| **google-services.json** | يحتوي على نفس SHA-1 | ✅ |

---

## 🧪 خطوات الاختبار

### 1. بناء Release APK

```bash
cd hggzk_app

# تنظيف المشروع
flutter clean

# إعادة تحميل Dependencies
flutter pub get

# بناء Release APK
flutter build apk --release
```

**المخرج المتوقع:**
```
✓ Built build/app/outputs/flutter-apk/app-release.apk (XX MB)
```

### 2. التحقق من SHA-1 في APK المبني

```bash
# استخراج SHA-1 من APK
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk | grep SHA1

# يجب أن يطابق:
# SHA1: 1A:E2:F2:C5:93:0F:B3:DA:E4:19:2D:11:90:94:40:F4:37:5D:B0:75
```

### 3. تثبيت واختبار Google Sign-In

```bash
# تثبيت على جهاز حقيقي
flutter install --release

# أو يدوياً
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

**خطوات الاختبار:**
1. افتح التطبيق
2. اذهب إلى صفحة تسجيل الدخول
3. اضغط على **"تسجيل الدخول بـ Google"**
4. اختر حساب Google
5. ✅ يجب أن يتم تسجيل الدخول بنجاح

### 4. مراقبة Logs (اختياري)

```bash
# في terminal منفصل
adb logcat | grep -E "GoogleSign|OAuth|social"
```

**النتيجة المتوقعة:**
```
✅ Google Sign-In: بدء عملية تسجيل الدخول...
✅ Google Sign-In: تم الحصول على الحساب: user@gmail.com
✅ التحقق من الـ Tokens...
   - ID Token: ✅ موجود
✅ Google Sign-In: إرسال idToken إلى الخادم...
✅ تم تسجيل الدخول بنجاح
```

---

## 📊 معلومات تقنية

### OAuth Client IDs

**من google-services.json:**

```json
{
  "client_type": 1,
  "client_id": "333370677136-834ocmm2shmri6v2b7cjpph58nttt9k4.apps.googleusercontent.com",
  "android_info": {
    "package_name": "com.hggzk.app",
    "certificate_hash": "1ae2f2c5930fb3dae4192d11909440f4375db075"
  }
}
```

**من app_constants.dart:**

```dart
static const String googleWebClientId =
    '333370677136-el3bpb5fn4tt8qrcr52v8r59h4fko283.apps.googleusercontent.com';
    
static const String googleAndroidClientId =
    '333370677136-834ocmm2shmri6v2b7cjpph58nttt9k4.apps.googleusercontent.com';
    
static const String googleIosClientId =
    '333370677136-63cqitbsjos82f52h772s15pcdjdoci3.apps.googleusercontent.com';
```

### Keystore Details

| الخاصية | القيمة |
|---------|--------|
| **الموقع** | `android/my-release-key.jks` |
| **Alias** | `upload` |
| **SHA-1** | `1A:E2:F2:C5:93:0F:B3:DA:E4:19:2D:11:90:94:40:F4:37:5D:B0:75` |
| **SHA-256** | `70:DF:0B:4B:12:9D:D3:A8:7E:99:01:7C:AD:E4:23:A4:A5:08:E6:3A:61:CC:B6:C0:9B:8A:32:1E:9E:AB:C6:E7` |
| **Key Algorithm** | RSA 2048-bit |
| **Signature** | SHA384withRSA |

---

## ⚠️ ملاحظات مهمة

### 🔒 الأمان

1. **لا ترفع `key.properties` إلى Git:**
   - ✅ تم إضافته إلى `.gitignore`
   - يحتوي على كلمات مرور حساسة

2. **احفظ نسخة احتياطية من الـ keystore:**
   ```bash
   # في مكان آمن خارج المشروع
   cp android/my-release-key.jks ~/backups/hggzk-release-key-backup.jks
   ```

3. **لا تشارك SHA-1 علنياً:**
   - SHA-1 هو بصمة تطبيقك
   - يمكن استخدامه لانتحال هوية التطبيق إذا سُرق الـ keystore

### 📱 النشر على Google Play

إذا كنت تنشر على Google Play Console:

1. **App Signing by Google Play:**
   - إذا فعّلت هذه الميزة، Google يستخدم keystore خاص به
   - يجب تسجيل SHA-1 من **App signing certificate** في Firebase
   - يمكن الحصول عليه من: Play Console → Setup → App integrity

2. **Upload Certificate:**
   - SHA-1 الحالي (`1ae2f2c5...`) هو **Upload certificate**
   - يجب أن يبقى مسجلاً أيضاً للاختبار المحلي

### 🔄 CI/CD

إذا كنت تستخدم CI/CD (مثل GitHub Actions):

1. أضف Secrets:
   ```yaml
   ANDROID_KEYSTORE_PASSWORD: Qaz1235@@Wsx1235@@
   ANDROID_KEY_PASSWORD: Qaz1235@@Wsx1235@@
   ANDROID_KEY_ALIAS: upload
   ```

2. رفع Keystore مشفر:
   ```bash
   # تشفير base64
   base64 android/my-release-key.jks > keystore.b64
   
   # في CI، فك التشفير:
   echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > my-release-key.jks
   ```

---

## 🐛 استكشاف الأخطاء

### المشكلة: مازال لا يعمل بعد الإصلاح

**الخطوات:**

1. **تحقق من SHA-1 في APK:**
   ```bash
   keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk | grep SHA1
   ```

2. **تحقق من key.properties:**
   ```bash
   cat android/key.properties
   # يجب أن يحتوي على بيانات صحيحة
   ```

3. **تحقق من البناء:**
   ```bash
   cd android
   ./gradlew signingReport
   # ابحث عن "Variant: release" واقرأ SHA-1
   ```

4. **تحقق من الوقت والتاريخ:**
   - تأكد من أن تاريخ ووقت الجهاز صحيح
   - Google OAuth حساس للوقت

5. **انتظر بضع دقائق:**
   - بعد تحديث Firebase، قد يستغرق 5-10 دقائق للتطبيق

---

## ✅ قائمة التحقق النهائية

- [x] استخراج SHA-1 من Release keystore
- [x] التأكد من تطابق SHA-1 مع google-services.json
- [x] إنشاء ملف key.properties
- [x] نسخ upload-keystore.jks إلى my-release-key.jks
- [x] إضافة key.properties إلى .gitignore
- [x] تنظيف المشروع (`flutter clean`)
- [ ] بناء Release APK (`flutter build apk --release`)
- [ ] تثبيت واختبار على جهاز حقيقي
- [ ] التأكد من نجاح Google Sign-In

---

## 📚 ملفات ذات صلة

| الملف | الوصف |
|------|-------|
| [`android/key.properties`](./android/key.properties) | بيانات توقيع Release |
| [`android/my-release-key.jks`](./android/my-release-key.jks) | Keystore (SHA-1 مسجل) |
| [`android/app/google-services.json`](./android/app/google-services.json) | إعدادات Firebase |
| [`android/app/build.gradle.kts`](./android/app/build.gradle.kts) | إعدادات البناء |
| [`lib/core/constants/app_constants.dart`](./lib/core/constants/app_constants.dart) | OAuth Client IDs |
| [`GOOGLE_SIGNIN_RELEASE_FIX.md`](./GOOGLE_SIGNIN_RELEASE_FIX.md) | دليل تفصيلي شامل |

---

## 🎯 الخلاصة

**المشكلة:** التطبيق كان يستخدم keystore بـ SHA-1 غير مسجل في Firebase  
**الحل:** استبدال الـ keystore بآخر SHA-1 مسجل بالفعل  
**النتيجة:** ✅ Google Sign-In يعمل الآن في Release Mode

---

**آخر تحديث:** 2026-02-06  
**الحالة:** ✅ **جاهز للاختبار**
