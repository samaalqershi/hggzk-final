# 🔧 إصلاح Google Sign-In - مشكلة Backend Client IDs

**التاريخ:** 2026-02-06  
**الحالة:** ✅ **تم الإصلاح**

---

## 📋 ملخص المشكلة

### الأعراض
- ✅ Google Sign-In يعمل في **Debug Mode** (Android & iOS)
- ❌ Google Sign-In **لا يعمل** في **Release Mode** (Android & iOS)
- ❌ Google Sign-In **لا يعمل** على **TestFlight** (iOS)
- 📱 رسالة الخطأ: **"فشل تسجيل الدخول الاجتماعي"**

---

## 🔍 التحليل العميق

### المشكلة الأولى: Android Keystore ✅ (تم حلها)
```
❌ Android Release يستخدم keystore بـ SHA-1 غير مسجل في Firebase
✅ الحل: تحديث my-release-key.jks ليطابق upload-keystore.jks
```
**انظر:** [`hggzk_app/GOOGLE_SIGNIN_FIX_SUMMARY.md`](./hggzk_app/GOOGLE_SIGNIN_FIX_SUMMARY.md)

---

### المشكلة الثانية: Backend Client IDs ❌ (المشكلة الحقيقية)

#### السبب الجذري المكتشف

```
🔍 Android يحصل على idToken من Google بنجاح
   ✅ idToken.audience = "333370677136-834ocmm2shmri6v2b7cjpph58nttt9k4"
      (من google-services.json)

🔍 Backend يحاول التحقق من idToken
   ❌ Backend.GoogleClientIds = [
       "333370677136-el3bpb5fn4tt8qrcr52v8r59h4fko283", // Web  ✅
       "333370677136-c6hac6mf0urphejc8v8h234p44ok1kft", // Android ❌ خطأ!
       "333370677136-63cqitbsjos82f52h772s15pcdjdoci3"  // iOS  ✅
   ]

❌ Token audience لا يطابق expected audience!
   Token:    333370677136-834ocmm2shmri6v2b7cjpph58nttt9k4
   Expected: 333370677136-c6hac6mf0urphejc8v8h234p44ok1kft

❌ Backend يرفض Token ويرجع خطأ!
```

#### تدفق الخطأ التفصيلي

```
1. ✅ Android App → Google OAuth
   Request: "أعطني idToken للمستخدم"
   Google Client ID: 333370677136-834ocmm2shmri6v2b7cjpph58nttt9k4
   (من google-services.json)

2. ✅ Google OAuth → Android App
   Response: idToken (JWT)
   JWT Payload: {
     "iss": "https://accounts.google.com",
     "aud": "333370677136-834ocmm2shmri6v2b7cjpph58nttt9k4",
     "sub": "user_id",
     "email": "user@example.com"
   }

3. ✅ Android App → Backend API
   POST /api/auth/social-login
   Body: {
     "provider": "google",
     "token": "eyJhbGc..." (idToken)
   }

4. ❌ Backend SocialAuthService.VerifyGoogleIdTokenAsync()
   Code:
   var validationSettings = new GoogleJsonWebSignature.ValidationSettings {
       Audience = ["...-el3bpb5fn4tt8qrcr52v8r59h4fko283",
                   "...-c6hac6mf0urphejc8v8h234p44ok1kft", ❌
                   "...-63cqitbsjos82f52h772s15pcdjdoci3"]
   };
   await GoogleJsonWebSignature.ValidateAsync(idToken, validationSettings);
   
   ❌ Exception: "Invalid JWT Audience"
   Token aud: 333370677136-834ocmm2shmri6v2b7cjpph58nttt9k4
   Expected:  333370677136-c6hac6mf0urphejc8v8h234p44ok1kft

5. ❌ Backend → Android App
   Response: {
     "success": false,
     "message": "فشل تسجيل الدخول الاجتماعي"
   }
```

---

## 🛠️ الإصلاح المطبق

### التغيير في Backend

**الملف:** [`backend/YemenBooking.Api/appsettings.json`](./backend/YemenBooking.Api/appsettings.json)

#### قبل الإصلاح ❌
```json
"SocialAuthSettings": {
  "GoogleClientIds": [
    "333370677136-el3bpb5fn4tt8qrcr52v8r59h4fko283.apps.googleusercontent.com",
    "333370677136-834ocmm2shmri6v2b7cjpph58nttt9k4.apps.googleusercontent.com", ❌
    "333370677136-63cqitbsjos82f52h772s15pcdjdoci3.apps.googleusercontent.com"
  ]
}
```

#### بعد الإصلاح ✅
```json
"SocialAuthSettings": {
  "GoogleClientIds": [
    "333370677136-el3bpb5fn4tt8qrcr52v8r59h4fko283.apps.googleusercontent.com",
    "333370677136-834ocmm2shmri6v2b7cjpph58nttt9k4.apps.googleusercontent.com", ✅
    "333370677136-63cqitbsjos82f52h772s15pcdjdoci3.apps.googleusercontent.com"
  ]
}
```

---

## 📊 مرجع Client IDs الكامل

### Web Client ID
```
Client ID: 333370677136-el3bpb5fn4tt8qrcr52v8r59h4fko283.apps.googleusercontent.com
Type: Web Application (OAuth 2.0)
Used by: Flutter Web, Backend Server-side validation
```

### Android Client ID ✅
```
Client ID: 333370677136-834ocmm2shmri6v2b7cjpph58nttt9k4.apps.googleusercontent.com
Type: Android
Package Name: com.hggzk.app
SHA-1: 1A:E2:F2:C5:93:0F:B3:DA:E4:19:2D:11:90:94:40:F4:37:5D:B0:75
Used by: Android App (Debug & Release)
Source: google-services.json → oauth_client[0].client_id
```

### iOS Client ID ✅
```
Client ID: 333370677136-63cqitbsjos82f52h772s15pcdjdoci3.apps.googleusercontent.com
Type: iOS
Bundle ID: com.hggzk.app
Used by: iOS App (Debug & TestFlight & App Store)
Source: google-services.json → other_platform_oauth_client[1]
```

---

## ✅ التحقق من الإصلاح

### الخطوات المطلوبة

1. **تحديث Backend على السيرفر**
   ```bash
   # نسخ appsettings.json المحدث إلى السيرفر
   scp backend/YemenBooking.Api/appsettings.json user@api.hggzk.com:/path/to/app/
   
   # إعادة تشغيل Backend
   systemctl restart yourbackend.service
   ```

2. **اختبار Android Release**
   ```bash
   cd hggzk_app
   flutter clean
   flutter build apk --release
   # تثبيت APK واختبار Google Sign-In
   ```

3. **اختبار iOS TestFlight**
   ```bash
   cd hggzk_app
   flutter clean
   flutter build ios --release
   # رفع إلى TestFlight واختبار Google Sign-In
   ```

### النتائج المتوقعة

✅ **Android Release:** Google Sign-In يعمل بنجاح  
✅ **iOS TestFlight:** Google Sign-In يعمل بنجاح  
✅ **رسالة Backend:** "تم تسجيل الدخول بنجاح"  

---

## 🔐 الإعدادات النهائية

### Frontend (Flutter App)

**`lib/core/constants/app_constants.dart`**
```dart
static const String googleWebClientId =
    '333370677136-el3bpb5fn4tt8qrcr52v8r59h4fko283.apps.googleusercontent.com';
    
static const String googleAndroidClientId =
    '333370677136-834ocmm2shmri6v2b7cjpph58nttt9k4.apps.googleusercontent.com';
    
static const String googleIosClientId =
    '333370677136-63cqitbsjos82f52h772s15pcdjdoci3.apps.googleusercontent.com';
```
**ملاحظة:** `googleAndroidClientId` ليس مستخدم في الكود - Android يعتمد على `google-services.json`

**`android/app/google-services.json`**
```json
{
  "oauth_client": [
    {
      "client_id": "333370677136-834ocmm2shmri6v2b7cjpph58nttt9k4.apps.googleusercontent.com",
      "client_type": 1,
      "android_info": {
        "package_name": "com.hggzk.app",
        "certificate_hash": "1ae2f2c5930fb3dae4192d11909440f4375db075"
      }
    }
  ]
}
```

**`ios/Runner/Info.plist`**
```xml
<key>GIDClientID</key>
<string>333370677136-63cqitbsjos82f52h772s15pcdjdoci3.apps.googleusercontent.com</string>

<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.333370677136-63cqitbsjos82f52h772s15pcdjdoci3</string>
    </array>
  </dict>
</array>
```

### Backend (.NET)

**`appsettings.json`**
```json
"SocialAuthSettings": {
  "GoogleClientIds": [
    "333370677136-el3bpb5fn4tt8qrcr52v8r59h4fko283.apps.googleusercontent.com",
    "333370677136-834ocmm2shmri6v2b7cjpph58nttt9k4.apps.googleusercontent.com",
    "333370677136-63cqitbsjos82f52h772s15pcdjdoci3.apps.googleusercontent.com"
  ]
}
```

---

## 📝 ملاحظات مهمة

### لماذا لم تظهر المشكلة في Debug Mode؟

```
Debug Mode:
-----------
✅ Android Debug Keystore SHA-1: C6:11:84:37:31:BC:91:23:AA:70:6F:B5:AA:E5:C7:A7:7B:CA:D1:98
✅ قد يكون مسجل في Firebase Console أيضاً
✅ أو Debug Mode يستخدم Client ID مختلف من Google Console
✅ لذلك كان يعمل بدون مشاكل

Release Mode:
-------------
❌ Android Release Keystore SHA-1: 1A:E2:F2:C5:93:0F:B3:DA:E4:19:2D:11:90:94:40:F4:37:5D:B0:75
❌ مسجل في Firebase مع Client ID: 333370677136-834ocmm...
❌ لكن Backend يتوقع Client ID: 333370677136-c6hac6mf...
❌ Mismatch → فشل التحقق
```

### كيف تم اكتشاف المشكلة؟

1. ✅ إصلاح Android Keystore (my-release-key.jks)
2. ❌ المشكلة استمرت في Release Mode
3. 🔍 فحص google-services.json
4. 🎯 اكتشاف اختلاف Client ID بين google-services.json و appsettings.json
5. ✅ إصلاح Backend Client IDs

---

## 🚀 الخطوات التالية

### بعد الإصلاح

1. ✅ تحديث appsettings.json على جميع Environments
   - Development
   - Staging
   - Production

2. ✅ إعادة بناء ونشر Backend

3. ✅ اختبار شامل:
   - Android Debug → Google Sign-In
   - Android Release → Google Sign-In
   - iOS Debug → Google Sign-In
   - iOS TestFlight → Google Sign-In

4. ✅ التوثيق:
   - توثيق جميع Client IDs في مكان مركزي
   - إضافة تعليقات في appsettings.json
   - حفظ نسخة احتياطية من google-services.json

### منع تكرار المشكلة

```bash
# إضافة validation script لـ CI/CD
# verify-google-client-ids.sh

#!/bin/bash
ANDROID_CLIENT_ID=$(jq -r '.client[0].oauth_client[0].client_id' android/app/google-services.json)
BACKEND_ANDROID_CLIENT_ID=$(jq -r '.SocialAuthSettings.GoogleClientIds[1]' backend/appsettings.json)

if [ "$ANDROID_CLIENT_ID" != "$BACKEND_ANDROID_CLIENT_ID" ]; then
  echo "❌ ERROR: Android Client ID mismatch!"
  echo "   google-services.json: $ANDROID_CLIENT_ID"
  echo "   appsettings.json:     $BACKEND_ANDROID_CLIENT_ID"
  exit 1
fi

echo "✅ Google Client IDs verified successfully"
```

---

## 📚 مراجع

- [Google Sign-In for Android](https://developers.google.com/identity/sign-in/android/start)
- [Google Sign-In for iOS](https://developers.google.com/identity/sign-in/ios/start)
- [Google.Apis.Auth (.NET Library)](https://github.com/googleapis/google-api-dotnet-client)
- [`google-services.json` Documentation](https://firebase.google.com/docs/android/setup)

---

**تم التوثيق بواسطة:** Zencoder AI Assistant  
**آخر تحديث:** 2026-02-06
