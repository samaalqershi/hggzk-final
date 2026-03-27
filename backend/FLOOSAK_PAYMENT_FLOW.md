# 🔄 آلية الدفع عبر محفظة فلوسك (Floosak)

## 📋 نظرة عامة

محفظة فلوسك تستخدم نظام **دفع من مرحلتين** (Two-Phase Payment):
1. **المرحلة الأولى**: طلب الدفع (Purchase Request) → يُرسل OTP للعميل
2. **المرحلة الثانية**: تأكيد الدفع (Purchase Confirm) → باستخدام OTP

---

## 🏗️ هيكل APIs المتوفرة

```
Floosak APIs
├── 1. Auth APIs (مرة واحدة فقط - عند انتهاء صلاحية المفتاح)
│   ├── Request Key   → طلب مفتاح جديد (يُرسل OTP للتاجر)
│   └── Verify Key    → تأكيد المفتاح والحصول على Token
│
└── 2. Payment APIs (P2MCL - Person to Merchant CashLess)
    ├── P2MCL (Purchase)  → طلب الدفع من العميل
    ├── Confirm           → تأكيد الدفع بـ OTP
    └── Refund            → استرداد المبلغ للعميل
```

---

## 🔑 المرحلة صفر: الحصول على مفتاح التاجر (مرة واحدة سنوياً)

### 1️⃣ Request Key
```
POST /api/v1/request/key
Headers:
  - Content-Type: application/json
  - x-channel: merchant

Body:
{
  "phone": "967781312317",      // رقم هاتف التاجر
  "short_code": "335363"        // الشورت كود (6 أرقام)
}

Response:
{
  "message": "key request created successfuly and sms sent to merchant",
  "request_id": 1000186,        // ⚠️ احفظ هذا الرقم!
  "name": null
}
```
> 📱 **النتيجة**: يصل SMS للتاجر يحتوي على OTP (6 أرقام)

### 2️⃣ Verify Key
```
POST /api/v1/verify/key
Headers:
  - Content-Type: application/json
  - x-channel: merchant

Body:
{
  "request_id": 1000186,        // من الخطوة السابقة
  "otp": "123456"               // من SMS
}

Response:
{
  "message": "يرجى نسخ الرمز، يتم اضهاره فقط مرة واحدة",
  "key": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...",  // ⚠️ احفظ هذا! صلاحيته سنة
  "account_detail": {
    "account": {
      "id": 144,
      "phone": "967771800770",
      "wallets": [
        {
          "id": 144,            // ⚠️ هذا هو source_wallet_id للـ YER
          "currency": { "symbol": { "en": "YER" } },
          "balance": 336037
        }
      ]
    }
  }
}
```
> 🔐 **المخرجات المهمة**:
> - `key` → يُحفظ في `Flosk:Key` في الإعدادات
> - `wallets[0].id` → يُحفظ في `Flosk:SourceWalletId`

---

## 💳 عملية الدفع (التدفق الرئيسي)

### التدفق الكامل:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        تدفق الدفع عبر فلوسك                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  [العميل]                    [التطبيق]                    [فلوسك API]    │
│     │                           │                              │         │
│     │  1. يختار الدفع بفلوسك    │                              │         │
│     │ ─────────────────────────>│                              │         │
│     │                           │                              │         │
│     │                           │  2. Purchase Request         │         │
│     │                           │  POST /api/v1/merchant/p2mcl │         │
│     │                           │ ────────────────────────────>│         │
│     │                           │                              │         │
│     │                           │  3. Response: id + Pending   │         │
│     │                           │<──────────────────────────── │         │
│     │                           │                              │         │
│     │                           │         ┌─────────────────┐  │         │
│     │                           │         │ 📱 SMS إلى      │  │         │
│     │  4. يستلم SMS بـ OTP      │         │ العميل (OTP)    │  │         │
│     │<──────────────────────────│─────────┴─────────────────┘  │         │
│     │                           │                              │         │
│     │  5. يدخل OTP              │                              │         │
│     │ ─────────────────────────>│                              │         │
│     │                           │                              │         │
│     │                           │  6. Confirm                  │         │
│     │                           │  POST .../p2mcl/confirm      │         │
│     │                           │ ────────────────────────────>│         │
│     │                           │                              │         │
│     │                           │  7. Response: Completed      │         │
│     │                           │<──────────────────────────── │         │
│     │                           │                              │         │
│     │  8. تأكيد نجاح الدفع      │                              │         │
│     │<───────────────────────── │                              │         │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 📡 تفاصيل APIs الدفع

### 1️⃣ Purchase Request (طلب الدفع)

```
POST /api/v1/merchant/p2mcl
Headers:
  - Content-Type: application/json
  - x-channel: merchant
  - Authorization: Bearer {key}    // المفتاح من Verify Key

Body:
{
  "source_wallet_id": 144,         // معرف محفظة التاجر (من verify key)
  "request_id": "booking-12345",   // معرف فريد تولّده أنت
  "target_phone": "967781312317",  // رقم هاتف العميل الذي سيدفع
  "amount": 100,                   // المبلغ
  "purpose": "Booking Payment #123" // غرض الدفع
}

Response (نجاح):
{
  "data": {
    "name": "اسم التاجر",
    "balance": 3795308.90,         // رصيد التاجر بعد العملية
    "phone": "967781312317",
    "status": {
      "ar": "معلقه",
      "en": "Pending"              // ⚠️ الحالة: معلقة بانتظار OTP
    },
    "net": 100,                    // المبلغ الصافي
    "fee": 0,                      // الرسوم
    "rate": 0,                     // معدل التحويل
    "gross": 100,                  // المبلغ الإجمالي
    "reference_id": "booking-12345",
    "id": 71954,                   // ⚠️ purchase_id للتأكيد
    "created_at": "2023-03-19T07:54:13.000000Z"
  },
  "message": "تمت بنجاح",
  "is_success": true
}
```

> 📱 **بعد هذه الخطوة**: يستلم العميل SMS يحتوي على OTP (6 أرقام)

---

### 2️⃣ Purchase Confirm (تأكيد الدفع)

```
POST /api/v1/merchant/p2mcl/confirm
Headers:
  - Content-Type: application/json
  - x-channel: merchant
  - Authorization: Bearer {key}

Body:
{
  "purchase_id": 71954,            // من response السابق (data.id)
  "otp": "123456"                  // الذي وصل للعميل عبر SMS
}

Response (نجاح):
{
  "data": {
    "name": "اسم التاجر",
    "balance": 3795208.90,
    "phone": "967781312317",
    "status": {
      "ar": "مكتملة",
      "en": "Completed"            // ✅ الحالة: مكتملة
    },
    "net": 100,
    "fee": 0,
    "rate": 0,
    "gross": 100,
    "reference_id": "booking-12345",
    "id": 267316,
    "created_at": "2023-03-19T08:13:53.000000Z"
  },
  "message": "تمت بنجاح",
  "is_success": true
}
```

---

## 🔧 الإعدادات المطلوبة في `appsettings.json`

```json
"Flosk": {
  "BaseUrl": "https://staging.fintech-expert.net",  // أو production URL
  "Channel": "merchant",
  "RequestKeyPath": "/api/v1/request/key",
  "VerifyKeyPath": "/api/v1/verify/key",
  "PurchasePath": "/api/v1/merchant/p2mcl",
  "ConfirmPath": "/api/v1/merchant/p2mcl/confirm",
  "RefundPath": "/api/v1/merchant/p2mcl/refund",
  "MerchantPhone": "967781312317",                  // رقم هاتف التاجر
  "MerchantShortCode": "335363",                    // الشورت كود
  "Key": "eyJ0eXAiOiJKV1QiLCJhbGci...",            // من Verify Key
  "KeyCacheMinutes": "120",
  "SourceWalletId": "144",                          // من Verify Key (wallets[0].id)
  "SourceWalletIds": {
    "YER": "144",                                   // محفظة الريال اليمني
    "SAR": "0",                                     // محفظة الريال السعودي (إذا وجد)
    "USD": "0"                                      // محفظة الدولار (إذا وجد)
  }
}
```

---

## ⚠️ ملاحظات مهمة

1. **صلاحية المفتاح**: سنة واحدة من تاريخ الإصدار
2. **OTP للتاجر**: يُطلب فقط عند Request Key / Verify Key
3. **OTP للعميل**: يُطلب في كل عملية دفع
4. **request_id**: يجب أن يكون فريداً في كل طلب (يُفضل timestamp)
5. **source_wallet_id**: يختلف حسب العملة (YER, SAR, USD)

---

## 🔄 مقارنة مع جوالي

| الميزة | جوالي | فلوسك |
|--------|-------|-------|
| نوع المصادقة | كود شراء (Voucher) | OTP عبر SMS |
| عدد الخطوات | خطوة واحدة (CASHOUT) | خطوتين (Request + Confirm) |
| من يبادر | العميل (ينشئ كود) | التاجر (يطلب الدفع) |
| التحقق | من حالة الكود | من OTP يصل للعميل |
| التوكن | يتجدد كل ساعة | يتجدد كل سنة |

---

## ✅ قائمة التحقق للتكامل

- [ ] الحصول على `MerchantPhone` و `MerchantShortCode` من فلوسك
- [ ] تنفيذ Request Key للحصول على request_id
- [ ] تنفيذ Verify Key بـ OTP للحصول على `Key` و `SourceWalletId`
- [ ] حفظ الإعدادات في appsettings.json
- [ ] اختبار Purchase Request
- [ ] اختبار Purchase Confirm
