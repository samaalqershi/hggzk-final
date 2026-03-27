#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# Script: إصلاح مشكلة Google Sign-In في نسخة Release
# المشكلة: عدم تطابق SHA-1 Certificate Fingerprint
# التاريخ: $(date '+%Y-%m-%d')
# ═══════════════════════════════════════════════════════════════════════════

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  إصلاح مشكلة Google Sign-In في نسخة Release                      ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}\n"

# ═══════════════════════════════════════════════════════════════════════════
# الخطوة 1: تحديد موقع Release Keystore
# ═══════════════════════════════════════════════════════════════════════════

PROJECT_DIR="/home/ameen/Desktop/BOOKIN/BOOKIN/hggzk_app"
ANDROID_DIR="$PROJECT_DIR/android"

RELEASE_KEYSTORE="$ANDROID_DIR/app/my-release-key.jks"
UPLOAD_KEYSTORE="/home/ameen/Desktop/BOOKIN/BOOKIN/cer_ios/upload-keystore.jks"

echo -e "${YELLOW}📁 البحث عن Release Keystore...${NC}\n"

if [ -f "$RELEASE_KEYSTORE" ]; then
    KEYSTORE_PATH="$RELEASE_KEYSTORE"
    echo -e "${GREEN}✅ تم العثور على: $RELEASE_KEYSTORE${NC}"
elif [ -f "$UPLOAD_KEYSTORE" ]; then
    KEYSTORE_PATH="$UPLOAD_KEYSTORE"
    echo -e "${GREEN}✅ تم العثور على: $UPLOAD_KEYSTORE${NC}"
else
    echo -e "${RED}❌ لم يتم العثور على Release Keystore${NC}"
    echo -e "${YELLOW}الرجاء تحديد مسار الملف يدويًا:${NC}"
    read -p "مسار keystore.jks: " KEYSTORE_PATH
    if [ ! -f "$KEYSTORE_PATH" ]; then
        echo -e "${RED}❌ الملف غير موجود: $KEYSTORE_PATH${NC}"
        exit 1
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════
# الخطوة 2: استخراج SHA-1 و SHA-256
# ═══════════════════════════════════════════════════════════════════════════

echo -e "\n${YELLOW}🔑 الرجاء إدخال كلمة مرور الـ Keystore:${NC}"
echo -e "${CYAN}(كلمات المرور المحتملة: hggzk@2024, hggzk123@, hggzk2024)${NC}"
read -sp "Password: " KEYSTORE_PASSWORD
echo ""

echo -e "\n${YELLOW}🔍 استخراج Certificate Fingerprints...${NC}\n"

# محاولة استخراج SHA-1 و SHA-256
FINGERPRINTS=$(keytool -list -v -keystore "$KEYSTORE_PATH" -storepass "$KEYSTORE_PASSWORD" 2>&1)

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ فشل الوصول إلى Keystore - كلمة المرور غير صحيحة${NC}"
    
    # محاولة تلقائية مع كلمات مرور شائعة
    echo -e "\n${YELLOW}⚠️  محاولة كلمات المرور الشائعة...${NC}"
    
    for pwd in "hggzk@2024" "hggzk123@" "hggzk2024" "android" "123456"; do
        echo -e "${CYAN}جاري التجربة: $pwd${NC}"
        FINGERPRINTS=$(keytool -list -v -keystore "$KEYSTORE_PATH" -storepass "$pwd" 2>&1)
        if [ $? -eq 0 ]; then
            KEYSTORE_PASSWORD="$pwd"
            echo -e "${GREEN}✅ نجح! كلمة المرور: $pwd${NC}"
            break
        fi
    done
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ فشلت جميع المحاولات${NC}"
        exit 1
    fi
fi

SHA1=$(echo "$FINGERPRINTS" | grep "SHA1:" | head -1 | sed 's/.*SHA1: //' | tr -d ' ')
SHA256=$(echo "$FINGERPRINTS" | grep "SHA256:" | head -1 | sed 's/.*SHA256: //' | tr -d ' ')

echo -e "${GREEN}✅ تم استخراج Fingerprints بنجاح:${NC}\n"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}SHA-1 (Release):${NC}"
echo -e "${GREEN}$SHA1${NC}"
echo -e ""
echo -e "${YELLOW}SHA-256 (Release):${NC}"
echo -e "${GREEN}$SHA256${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# استخراج Debug SHA-1 للمقارنة
echo -e "${YELLOW}🔍 استخراج Debug Keystore SHA-1 للمقارنة...${NC}"
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"
if [ -f "$DEBUG_KEYSTORE" ]; then
    DEBUG_SHA1=$(keytool -list -v -keystore "$DEBUG_KEYSTORE" -storepass android 2>/dev/null | grep "SHA1:" | head -1 | sed 's/.*SHA1: //' | tr -d ' ')
    echo -e "${CYAN}Debug SHA-1: $DEBUG_SHA1${NC}\n"
else
    echo -e "${YELLOW}⚠️  Debug keystore غير موجود${NC}\n"
fi

# ═══════════════════════════════════════════════════════════════════════════
# الخطوة 3: التحقق من google-services.json
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${YELLOW}📋 التحقق من google-services.json الحالي...${NC}\n"

GS_JSON="$PROJECT_DIR/android/app/google-services.json"
if [ -f "$GS_JSON" ]; then
    CURRENT_SHA1=$(grep -o '"certificate_hash": "[^"]*"' "$GS_JSON" | head -1 | cut -d'"' -f4)
    echo -e "${CYAN}SHA-1 المسجل حاليًا في google-services.json:${NC}"
    echo -e "${YELLOW}$CURRENT_SHA1${NC}\n"
    
    # تنظيف SHA-1 من النقطتين
    CLEAN_RELEASE_SHA1=$(echo "$SHA1" | tr -d ':' | tr '[:upper:]' '[:lower:]')
    CLEAN_CURRENT_SHA1=$(echo "$CURRENT_SHA1" | tr -d ':' | tr '[:upper:]' '[:lower:]')
    
    if [ "$CLEAN_RELEASE_SHA1" == "$CLEAN_CURRENT_SHA1" ]; then
        echo -e "${GREEN}✅ SHA-1 متطابق! المشكلة ليست في الـ Certificate${NC}"
    else
        echo -e "${RED}❌ SHA-1 غير متطابق!${NC}"
        echo -e "${YELLOW}هذا هو سبب فشل Google Sign-In في Release mode${NC}\n"
    fi
fi

# ═══════════════════════════════════════════════════════════════════════════
# الخطوة 4: تعليمات الإصلاح
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  خطوات الإصلاح المطلوبة                                          ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${GREEN}1️⃣  إضافة SHA-1 إلى Firebase Console:${NC}"
echo -e "   ${YELLOW}→${NC} افتح https://console.firebase.google.com"
echo -e "   ${YELLOW}→${NC} اختر مشروع hggzk-67002"
echo -e "   ${YELLOW}→${NC} انتقل إلى Project Settings > General"
echo -e "   ${YELLOW}→${NC} ابحث عن تطبيق Android (com.hggzk.app)"
echo -e "   ${YELLOW}→${NC} اضغط على \"Add fingerprint\""
echo -e "   ${YELLOW}→${NC} الصق SHA-1 التالي:"
echo -e "   ${GREEN}$SHA1${NC}\n"

echo -e "${GREEN}2️⃣  تنزيل google-services.json المحدث:${NC}"
echo -e "   ${YELLOW}→${NC} بعد إضافة SHA-1، اضغط على زر \"Download google-services.json\""
echo -e "   ${YELLOW}→${NC} استبدل الملف الموجود في:"
echo -e "   ${CYAN}$GS_JSON${NC}\n"

echo -e "${GREEN}3️⃣  إنشاء OAuth 2.0 Client ID (إذا لزم الأمر):${NC}"
echo -e "   ${YELLOW}→${NC} افتح https://console.cloud.google.com/apis/credentials"
echo -e "   ${YELLOW}→${NC} اختر المشروع hggzk-67002"
echo -e "   ${YELLOW}→${NC} تحقق من وجود OAuth Client ID من نوع Android"
echo -e "   ${YELLOW}→${NC} إذا لم يكن موجودًا، قم بإنشائه:"
echo -e "      - Application type: Android"
echo -e "      - Package name: com.hggzk.app"
echo -e "      - SHA-1: ${GREEN}$SHA1${NC}\n"

echo -e "${GREEN}4️⃣  إعادة بناء التطبيق:${NC}"
echo -e "   ${YELLOW}cd $PROJECT_DIR${NC}"
echo -e "   ${YELLOW}flutter clean${NC}"
echo -e "   ${YELLOW}flutter pub get${NC}"
echo -e "   ${YELLOW}flutter build apk --release${NC}\n"

echo -e "${GREEN}5️⃣  اختبار Google Sign-In:${NC}"
echo -e "   ${YELLOW}→${NC} قم بتثبيت نسخة Release على جهاز حقيقي"
echo -e "   ${YELLOW}→${NC} جرب تسجيل الدخول عبر Google"
echo -e "   ${YELLOW}→${NC} راقب Logs عبر: ${CYAN}adb logcat | grep -i 'google\|oauth\|auth'${NC}\n"

# ═══════════════════════════════════════════════════════════════════════════
# الخطوة 5: إنشاء ملف مرجعي
# ═══════════════════════════════════════════════════════════════════════════

REPORT_FILE="$PROJECT_DIR/GOOGLE_SIGNIN_FIX_REPORT.md"

cat > "$REPORT_FILE" << EOF
# 🔐 تقرير إصلاح Google Sign-In - نسخة Release

**التاريخ:** $(date '+%Y-%m-%d %H:%M:%S')
**المشروع:** hggzk_app

---

## 📊 معلومات الـ Certificate

### Release Keystore
- **الموقع:** \`$KEYSTORE_PATH\`
- **SHA-1:** \`$SHA1\`
- **SHA-256:** \`$SHA256\`

### Debug Keystore (للمقارنة)
- **الموقع:** \`$DEBUG_KEYSTORE\`
- **SHA-1:** \`${DEBUG_SHA1:-N/A}\`

### google-services.json الحالي
- **SHA-1 المسجل:** \`${CURRENT_SHA1:-N/A}\`

---

## 🔍 التشخيص

المشكلة الأساسية: **عدم تطابق SHA-1 Certificate Fingerprint**

- ✅ **Debug mode**: يعمل لأن debug.keystore SHA-1 قد يكون مسجلاً
- ❌ **Release mode**: لا يعمل لأن release keystore SHA-1 غير مسجل في Firebase

---

## ✅ خطوات الحل

### 1. Firebase Console
1. افتح [Firebase Console](https://console.firebase.google.com)
2. اختر مشروع **hggzk-67002**
3. انتقل إلى **Project Settings > General**
4. ابحث عن تطبيق Android: **com.hggzk.app**
5. اضغط على **Add fingerprint**
6. الصق SHA-1:
   \`\`\`
   $SHA1
   \`\`\`
7. احفظ التغييرات
8. نزّل **google-services.json** المحدث

### 2. Google Cloud Console (OAuth Client ID)
1. افتح [Google Cloud Console Credentials](https://console.cloud.google.com/apis/credentials)
2. اختر المشروع **hggzk-67002**
3. تحقق من وجود OAuth 2.0 Client ID من نوع **Android**
4. إذا لم يكن موجودًا، قم بإنشائه:
   - **Application type**: Android
   - **Package name**: com.hggzk.app
   - **SHA-1 certificate fingerprint**: \`$SHA1\`

### 3. تحديث المشروع
\`\`\`bash
cd $PROJECT_DIR

# استبدال google-services.json (بعد تنزيله من Firebase)
cp ~/Downloads/google-services.json android/app/google-services.json

# تنظيف وإعادة البناء
flutter clean
flutter pub get
flutter build apk --release
\`\`\`

### 4. الاختبار
\`\`\`bash
# تثبيت النسخة على الجهاز
flutter install --release

# مراقبة Logs
adb logcat | grep -E "GoogleSign|OAuth|AuthBloc"
\`\`\`

---

## 🔧 معلومات إضافية

### OAuth Client IDs المطلوبة

**من google-services.json:**
- **Type 1 (Android):** \`333370677136-834ocmm2shmri6v2b7cjpph58nttt9k4.apps.googleusercontent.com\`
  - Package: com.hggzk.app
  - SHA-1: \`$SHA1\` ← **يجب تحديثه**

- **Type 3 (Web):** \`333370677136-el3bpb5fn4tt8qrcr52v8r59h4fko283.apps.googleusercontent.com\`
  - يُستخدم كـ serverClientId

### app_constants.dart
\`\`\`dart
static const String googleWebClientId =
    '333370677136-el3bpb5fn4tt8qrcr52v8r59h4fko283.apps.googleusercontent.com';
static const String googleAndroidClientId =
    '333370677136-834ocmm2shmri6v2b7cjpph58nttt9k4.apps.googleusercontent.com';
static const String googleIosClientId =
    '333370677136-63cqitbsjos82f52h772s15pcdjdoci3.apps.googleusercontent.com';
\`\`\`

---

## ⚠️ ملاحظات مهمة

1. **لا تشارك SHA-1 مع أطراف خارجية** - إنه بصمة تطبيقك
2. **احتفظ بنسخة احتياطية** من google-services.json القديم
3. **اختبر على جهاز حقيقي** - المحاكي قد يعطي نتائج مختلفة
4. قد تحتاج إلى **الانتظار بضع دقائق** بعد تحديث Firebase لتطبيق التغييرات
5. تأكد من أن **تاريخ ووقت الجهاز** صحيح (مهم لـ OAuth)

---

## 📚 مراجع

- [Firebase Android Setup](https://firebase.google.com/docs/android/setup)
- [Google Sign-In for Android](https://developers.google.com/identity/sign-in/android/start)
- [OAuth 2.0 Client IDs](https://console.cloud.google.com/apis/credentials)

---

**تم إنشاء هذا التقرير بواسطة:** fix_google_signin_release.sh
EOF

echo -e "${GREEN}✅ تم إنشاء تقرير تفصيلي:${NC}"
echo -e "${CYAN}$REPORT_FILE${NC}\n"

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  انتهى التحليل بنجاح ✅                                           ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${YELLOW}💡 الخطوات التالية:${NC}"
echo -e "1. افتح Firebase Console وأضف SHA-1"
echo -e "2. نزّل google-services.json المحدث"
echo -e "3. قم بتشغيل: ${CYAN}flutter clean && flutter build apk --release${NC}\n"
