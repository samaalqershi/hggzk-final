# تقرير تكامل سبأ كاش في التطبيقات الموبايل
# SabaCash Mobile Integration Report

## 📅 التاريخ: 2026-02-04

---

## ✅ ملخص التغييرات

تم إضافة محفظة سبأ كاش إلى قائمة طرق الدفع في التطبيقين:
- **hggzk_app** ✅
- **rezmate_app** ✅

---

## 📁 الملفات المعدّلة

### تطبيق hggzk_app

| الملف | التغيير |
|-------|---------|
| `lib/features/booking/presentation/widgets/payment_methods_widget.dart` | إضافة `sabaCashWallet` لقائمة المحافظ |
| نفس الملف | إضافة لون سبأ كاش (`AppTheme.primaryCyan`) |
| نفس الملف | إضافة أيقونة (`Icons.currency_exchange_rounded`) |
| نفس الملف | إضافة اسم العرض ("سبأ كاش") |

### تطبيق rezmate_app

| الملف | التغيير |
|-------|---------|
| `lib/features/booking/presentation/widgets/payment_methods_widget.dart` | إضافة `sabaCashWallet` لقائمة المحافظ |
| نفس الملف | إضافة لون سبأ كاش (`Color(0xFF0EA5E9)` - Cyan) |
| نفس الملف | إضافة أيقونة (`Icons.currency_exchange`) |
| نفس الملف | إضافة اسم العرض ("سبأ كاش") |

---

## 🎨 التصميم

### اللون
- **hggzk_app**: `AppTheme.primaryCyan`
- **rezmate_app**: `Color(0xFF0EA5E9)` (Cyan/Sky Blue)

### الأيقونة
- `Icons.currency_exchange` / `Icons.currency_exchange_rounded`

### الاسم
- بالعربية: "سبأ كاش"
- بالإنجليزية: "SabaCash Wallet"

---

## 🔧 الكود الموجود مسبقاً (لم يتغير)

### في hggzk_app

```
lib/core/enums/payment_method_enum.dart
├── sabaCashWallet enum value ✅
├── backendValue = 10 ✅
├── displayNameAr = "محفظة سبأ كاش" ✅
├── displayNameEn = "SabaCash Wallet" ✅
└── isWallet = true ✅

lib/features/booking/presentation/pages/booking_payment_page.dart
├── _dispatchSabaCashOtp() ✅
├── PaymentMethod.sabaCashWallet handling ✅
├── OTP dialog for sabaCashWallet ✅
└── _getWalletColor() - sabaCashWallet case ✅
```

### في rezmate_app

```
lib/core/enums/payment_method_enum.dart
├── sabaCashWallet enum value ✅
├── backendValue = 10 ✅
└── isWallet = true ✅

lib/features/booking/presentation/pages/booking_payment_page.dart
├── _dispatchSabaCashOtpConfirmation() ✅
├── PaymentMethod.sabaCashWallet handling ✅
├── OTP dialog for sabaCashWallet ✅
├── _getWalletAccentColor() - sabaCashWallet case ✅
├── _getWalletDialogTitle() - sabaCashWallet case ✅
└── _getWalletDialogDescription() - sabaCashWallet case ✅
```

---

## 🔄 تدفق الدفع (Payment Flow)

```
┌─────────────────────────────────────────────────────────────────┐
│                     المستخدم يختار سبأ كاش                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│         التطبيق يرسل طلب الدفع (بدون OTP في البداية)            │
│         PaymentMethod: sabaCashWallet                           │
│         paymentDetails: null                                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  الباك إند يتواصل مع سبأ كاش API                 │
│                  POST /onLinePayment                            │
│                  → يُرسل OTP لهاتف العميل                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              الباك إند يرجع status: pending                      │
│              + adjustmentId (GatewayTransactionId)              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              التطبيق يعرض dialog إدخال OTP                       │
│              "أدخل رمز التحقق المكون من 4 أرقام"                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              المستخدم يدخل OTP ويضغط تأكيد                       │
│              _dispatchSabaCashOtp(otp)                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              التطبيق يرسل طلب جديد مع OTP                        │
│              paymentDetails: {'otp': otp}                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              الباك إند يتواصل مع سبأ كاش API                     │
│              PATCH /onLinePayment مع OTP                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              completed: true → الدفع تم بنجاح!                   │
│              التطبيق يعرض رسالة نجاح                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 الباك إند

### الخدمات المسجلة
```csharp
// Program.cs
builder.Services.AddHttpClient<ISabaCashWalletService, SabaCashWalletService>();
```

### Enum Value
```csharp
// PaymentMethodEnum.cs
SabaCashWallet = 10
```

### Handler
```csharp
// ProcessPaymentCommandHandler.cs
case PaymentMethodEnum.SabaCashWallet:
    return await HandleSabaCashWalletPaymentAsync(request, booking, cancellationToken);
```

---

## ✅ حالة التحليل

### hggzk_app
```
flutter analyze → 4093 issues (warnings/info only, no errors)
```

### rezmate_app
```
flutter analyze → 4628 issues (warnings/info only, no errors)
```

---

## 🎯 النتيجة النهائية

| التطبيق | سبأ كاش في قائمة المحافظ | معالجة OTP | اللون | الأيقونة |
|---------|------------------------|------------|-------|----------|
| hggzk_app | ✅ | ✅ | ✅ Cyan | ✅ currency_exchange |
| rezmate_app | ✅ | ✅ | ✅ Sky Blue | ✅ currency_exchange |
| Backend | ✅ | ✅ | - | - |

---

## 📝 ملاحظات إضافية

1. **التطبيق يتطلب رقم هاتف**: إذا لم يكن للمستخدم رقم هاتف محفوظ، سيظهر تنبيه يطلب منه إضافته في الملف الشخصي
2. **OTP مكون من 4 أرقام**: يختلف عن المحافظ الأخرى التي تستخدم 6 أرقام
3. **الاسترداد**: يتطلب أن يكون المبلغ في حساب Main وليس Terminal

---

## 🔗 المراجع

- [SABACASH_INTEGRATION_REPORT.md](./SABACASH_INTEGRATION_REPORT.md) - تقرير تكامل الباك إند
- SabaCash API Documentation: `/home/ameen/Downloads/سبأكاش/`
