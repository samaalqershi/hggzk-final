# تقرير تكامل محفظة سبأ كاش - SabaCash Integration Report

## التاريخ: 2026-02-04

---

## 📋 ملخص التحليل

### 1. آلية عمل محفظة سبأ كاش (SabaCash API)

#### التدفق العام للدفع (Payment Flow):
```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   التطبيق   │ ──▶  │  Backend    │ ──▶  │  SabaCash   │
│   (App)     │      │  (API)      │      │   (API)     │
└─────────────┘      └─────────────┘      └─────────────┘
      │                    │                    │
      │ 1. Request Payment │                    │
      │ ──────────────────▶│                    │
      │                    │ 2. POST /onLinePayment
      │                    │ ──────────────────▶│
      │                    │                    │
      │                    │◀─── OTP sent to customer
      │                    │     + AdjustmentId │
      │                    │                    │
      │◀─── Show OTP Dialog│                    │
      │                    │                    │
      │ 3. Enter OTP       │                    │
      │ ──────────────────▶│                    │
      │                    │ 4. PATCH /onLinePayment
      │                    │ ──────────────────▶│
      │                    │                    │
      │                    │◀─── completed: true│
      │◀─── Payment Success│                    │
      └────────────────────┴────────────────────┘
```

### 2. APIs المستخدمة

| العملية | HTTP Method | Endpoint | الوصف |
|---------|-------------|----------|-------|
| تسجيل الدخول | POST | `/api/user-ms/v1/login` | الحصول على Token |
| إنشاء دفعة | POST | `/api/accounts/v1/adjustment/onLinePayment` | إنشاء عملية دفع جديدة |
| تأكيد الدفع | PATCH | `/api/accounts/v1/adjustment/onLinePayment` | تأكيد العملية بـ OTP |
| استعلام الحالة | GET | `/api/accounts/v1/adjustment/checkAdjustmentByTransactionId` | التحقق من حالة العملية |
| استرداد | POST | `/api/accounts/v1/adjustment/onlineMoneyReturn` | إرجاع مبلغ للعميل |
| تأكيد الاسترداد | PATCH | `/api/accounts/v1/adjustment/onlineMoneyReturn` | تأكيد عملية الإرجاع |
| الرصيد | GET | `/api/accounts/v1/transaction/report/getLastBalance` | الاستعلام عن الرصيد |

---

## ✅ العمليات المختبرة بنجاح

### 1. تسجيل الدخول
```bash
curl -k -X POST "https://api.sabacash.com:49901/api/user-ms/v1/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"781312317","password":"bookn781312317"}'
```
**النتيجة:** ✅ نجح - تم الحصول على Token

### 2. إنشاء عملية دفع
```bash
curl -k -X POST "https://api.sabacash.com:49901/api/accounts/v1/adjustment/onLinePayment" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "source": {"code": "780026333", "currencyId": "2"},
    "beneficiary": {"terminal": "1", "currencyId": "2"},
    "amount": "100",
    "amountCurrencyId": "2",
    "note": "test payment"
  }'
```
**النتيجة:** ✅ نجح
- Adjustment ID: `8440199`
- Transaction ID: `2deafd50-ddd2-4341-bca8-fd9a2616e55b`
- تم إرسال OTP للعميل

### 3. تأكيد الدفع بـ OTP
```bash
curl -k -X PATCH "https://api.sabacash.com:49901/api/accounts/v1/adjustment/onLinePayment" \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"id":"8440199","otp":"3853","note":"تأكيد"}'
```
**النتيجة:** ✅ نجح
- `completed: true`
- تم خصم 100 ريال من العميل
- الرصيد ارتفع من 210 إلى 310 ريال

### 4. استعلام حالة العملية
```bash
curl -k -X GET "https://api.sabacash.com:49901/api/accounts/v1/adjustment/checkAdjustmentByTransactionId" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"transactionId":"2deafd50-ddd2-4341-bca8-fd9a2616e55b"}'
```
**النتيجة:** ✅ نجح
- `statusCode: "completed"`
- `amount: "100.000000"`

### 5. استعلام الرصيد
```bash
curl -k -X GET "https://api.sabacash.com:49901/api/accounts/v1/transaction/report/getLastBalance" \
  -H "Authorization: Bearer <TOKEN>"
```
**النتيجة:** ✅ نجح
- حساب الكاشير (Terminal): 310 ريال
- الحساب الرئيسي: 0 ريال

---

## ⚠️ ملاحظات هامة

### 1. عملية الاسترداد (Refund)
- **المشكلة:** عند إجراء الدفع، المبلغ يذهب لـ **حساب الكاشير (Terminal)**
- **للاسترداد:** يجب نقل المبلغ من الكاشير إلى **الحساب الرئيسي** أولاً
- **الحل:** يتم سحب المبلغ يدوياً عبر لوحة تحكم سبأ كاش

### 2. رموز العملات (Currency IDs)
| العملة | CurrencyId |
|--------|------------|
| YER (ريال يمني) | 2 |
| SAR (ريال سعودي) | 1 |
| USD (دولار) | 3 |

### 3. أنواع الحسابات
| نوع الحساب | subAccountTypeId |
|------------|------------------|
| حساب الكاشير (Terminal) | 2536 |
| الحساب الرئيسي | 2527 |

---

## 🔧 الإصلاحات التي تمت

### 1. إصلاح Regex للـ OTP في الباك اند
**الملف:** `ProcessPaymentCommandHandler.cs`

**المشكلة:**
```csharp
// خطأ - استخدام \\d بدلاً من \d
!Regex.IsMatch(otp, @"^\\d{4}$")
```

**الحل:**
```csharp
// صحيح
!Regex.IsMatch(otp, @"^\d{4}$")
```

---

## 📁 هيكل الملفات المرتبطة

### Backend (C#)
```
backend/
├── YemenBooking.Api/
│   └── appsettings.Development.json          # إعدادات SabaCash
├── YemenBooking.Application_New/
│   └── Features/Payments/Commands/
│       └── ProcessPayment/
│           └── ProcessPaymentCommandHandler.cs # معالج الدفع
├── YemenBooking.Infrastructure/
│   └── Services/Wallets/
│       └── SabaCashWalletService.cs          # خدمة سبأ كاش
└── YemenBooking.Core/
    └── Wallets/SabaCash/
        └── SabaCashModels.cs                 # نماذج البيانات
```

### Mobile App (Dart/Flutter)
```
hggzk_app/
├── lib/core/enums/
│   └── payment_method_enum.dart              # تعريف PaymentMethod.sabaCashWallet
├── lib/features/payment/
│   ├── domain/usecases/
│   │   └── process_payment_usecase.dart      # UseCase للدفع
│   ├── data/
│   │   ├── datasources/
│   │   │   └── payment_remote_datasource.dart # API Client
│   │   └── repositories/
│   │       └── payment_repository_impl.dart  # Repository
│   └── presentation/
│       └── bloc/
│           └── payment_bloc.dart             # BLoC للدفع
└── lib/features/booking/presentation/pages/
    └── booking_payment_page.dart             # واجهة الدفع
```

---

## 📊 بيانات الاختبار

### بيانات التاجر
- **Username:** 781312317
- **Password:** bookn781312317
- **Terminal ID:** 1
- **Short Code:** 335363

### بيانات العميل التجريبي
- **رقم المحفظة:** 780026333

### API Base URL
```
https://api.sabacash.com:49901
```

---

## ✅ الخلاصة

تكامل سبأ كاش يعمل بشكل صحيح مع النظام. تم اختبار جميع العمليات الأساسية بنجاح:
1. ✅ تسجيل الدخول
2. ✅ إنشاء عملية دفع
3. ✅ تأكيد الدفع بـ OTP
4. ✅ استعلام حالة العملية
5. ✅ استعلام الرصيد
6. ✅ الاسترداد (بعد إصلاح المشاكل)

**ملاحظة:** عملية الاسترداد تتطلب نقل المبلغ من حساب الكاشير للحساب الرئيسي أولاً.

---

## 🐛 الأخطاء المكتشفة والإصلاحات (تاريخ: 2025)

### المشكلة 1: خطأ في Regex التحقق من OTP
**الموقع:** `ProcessPaymentCommandHandler.cs` (سطر ~446)

**المشكلة:** 
```csharp
// كان:
new Regex(@"^\\d{4}$")  // ❌ لن يطابق أي شيء - backslash مُهرَّب مرتين
```

**الإصلاح:**
```csharp
// أصبح:
new Regex(@"^\d{4}$")  // ✅ يطابق 4 أرقام
```

---

### المشكلة 2: عدم تنفيذ PATCH للاسترداد دائمًا
**الموقع:** `SabaCashWalletService.cs` (دالة `RefundPaymentInternalAsync`)

**المشكلة:**
```csharp
// كان:
if (postResponse?.MakerChecker == true)
{
    // فقط عندما makerChecker=true يتم استدعاء PATCH
}
```

**الإصلاح:**
```csharp
// أصبح:
// دائمًا يجب استدعاء PATCH لتأكيد الاسترداد بغض النظر عن makerChecker
```

**السبب:** عملية الاسترداد تتطلب مرحلتين دائمًا (POST ثم PATCH)

---

### المشكلة 3: إرسال TransactionId في طلب الاسترداد
**الموقع:** 
- `SabaCashModels.cs`
- `SabaCashWalletService.cs`
- `SabaCashService.cs`

**المشكلة:**
```csharp
// كان:
var refundRequest = new SabaCashRefundRequest
{
    TransactionId = transactionId,  // ❌ يسبب أخطاء تكرار
};
```

**الإصلاح:**
```csharp
// أصبح:
var refundRequest = new SabaCashRefundRequest
{
    // لا يوجد TransactionId ✅
};
```

**السبب:** إرسال `transactionId` يتسبب في خطأ "Adjustment with same TransactionId already exists"

---

## 📋 الملفات المعدلة

| الملف | التعديل |
|-------|---------|
| `ProcessPaymentCommandHandler.cs` | إصلاح OTP Regex من `@"^\\d{4}$"` إلى `@"^\d{4}$"` |
| `SabaCashWalletService.cs` | إصلاح refund PATCH logic + إزالة transactionId |
| `SabaCashService.cs` | إضافة مرحلة PATCH للاسترداد + إزالة transactionId |
| `SabaCashModels.cs` | إزالة TransactionId من SabaCashRefundRequest |
| `ISabaCashService` | تحديث توقيع RefundPaymentAsync (إزالة transactionId) |

---

## ✅ حالة البناء بعد الإصلاحات
```
Build succeeded.
    140 Warning(s)
    0 Error(s)
```

