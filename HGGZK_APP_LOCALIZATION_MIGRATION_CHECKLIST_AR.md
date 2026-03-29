# خطة ترحيل اللغة في `hggzk_app`

## الهدف

ترحيل جميع النصوص الظاهرة للمستخدم في تطبيق العميل من النصوص المضمّنة داخل الكود إلى ملفات لغة خارجية للغتين:

- العربية
- الإنجليزية

مع ضمان عدم نسيان أي شاشة أو رسالة أو تنبيه أو Label أو Dialog أو SnackBar أو Placeholder أو عنوان ظاهر للمستخدم.

## البنية المستهدفة

- استخدام ملفات خارجية داخل:
  - `hggzk_app/assets/l10n/ar/`
  - `hggzk_app/assets/l10n/en/`
- استخدام Loader مركزي في:
  - `hggzk_app/lib/core/localization/app_localizations.dart`
- اعتماد واجهة استخدام موحدة داخل الكود:
  - `context.tr('key')`
  - `context.l10n.get('key')`

## الترتيب التنفيذي

1. تأسيس بنية الترجمة الخارجية وطبقة التحميل المركزي.
2. الإبقاء على توافق رجعي مؤقت مع المفاتيح القديمة أثناء الترحيل.
3. جرد النصوص الظاهرة للمستخدم حسب النطاقات الوظيفية.
4. ترحيل النطاقات الأقل تشابكًا أولًا.
5. ترحيل النطاقات الأكبر والأكثر تشابكًا بعد تثبيت النمط.
6. تشغيل فحص شامل لاكتشاف أي نصوص باقية hardcoded.
7. مراجعة نهائية لمطابقة جميع الشاشات والخدمات مع ملفات اللغة.

## حالة التنفيذ الحالية

- [x] إنشاء Loader مركزي للترجمة الخارجية من `assets/l10n/<lang>/*.json`
- [x] ربط `MaterialApp` بمفوضات اللغة واللغات المدعومة
- [x] تفعيل واجهة استخدام موحدة عبر `context.tr(...)`
- [x] إنشاء ملفات أولية للعربية والإنجليزية في:
  - `common`
  - `navigation`
  - `settings`
  - `chat`
  - `core_runtime`
  - `auth`
  - `favorites`
  - `home`
  - `reference`
  - `search`
- [x] تثبيت أول دفعة من الشاشات والخدمات:
  - `login_page`
  - `login_form`
  - `forgot_password_page`
  - `verify_email_modern_page`
  - `favorites_page`
  - `futuristic_home_page`
  - `city_selector_dialog`
  - `filter_chips_widget`
  - `main_shell_page`
  - `support_page`
  - `settings_bloc`
  - `location_service`
  - `deep_link_service`
  - `biometric_auth_service`
  - `notification_service`
- [x] استكمال ترحيل بقية شاشات `auth`
- [x] استكمال `chat` على مستوى الصفحات والويدجتس الأساسية
- [x] استكمال جزء كبير من `profile/settings/ai_assistant`
- [x] استكمال جزء كبير من `booking/payment/notifications`
- [x] استكمال جزء كبير من `home/search/property/review/favorites/reference`
- [ ] pass ثانٍ على `search_filters_page.dart`
- [ ] pass ثانٍ على `property_units_page.dart`
- [ ] pass ثانٍ على `booking_form_page.dart`
- [ ] pass ثانٍ على `booking_details_page.dart`
- [ ] pass ثانٍ على `notifications` للتأكد من عدم بقاء نصوص ظاهرة متفرقة
- [ ] pass ثانٍ على `edit_profile/settings/legal/support/ai_assistant`
- [ ] تشغيل sweep نهائي على كامل `hggzk_app/lib`

## توزيع النطاقات

### الوكيل 1

النطاق:

- `auth`
- `settings`
- `splash`
- `onboarding`
- `support`
- `ai_assistant`

### الوكيل 2

النطاق:

- `home`
- `search`
- `property`
- `review`
- `favorites`
- `reference`

### الوكيل 3

النطاق:

- `booking`
- `payment`
- `notifications`

### الوكيل 4

النطاق:

- `chat`
- `app shell`
- `router/navigation`
- `core` user-facing services/messages

### الوكيل 5

النطاق:

- `auth` المتبقي
- `social login`
- `register/change password`

## قائمة تحقق المراجعة النهائية

- [ ] لا توجد شاشة Presentation تعتمد على نص ظاهر للمستخدم مكتوب مباشرة داخل الكود إلا عند وجود سبب تقني واضح ومقبول.
- [ ] جميع الرسائل داخل الـ dialogs والنوافذ والتنبيهات تعتمد على ملفات اللغة.
- [ ] جميع عناوين الأزرار والقوائم والعلامات والـ placeholders تعتمد على ملفات اللغة.
- [ ] جميع رسائل الـ snackbars والنجاح والفشل تعتمد على ملفات اللغة.
- [ ] جميع شاشات الإعدادات والحساب والدردشة والحجز والعقار والبحث والمساعدة مغطاة.
- [ ] ملفات العربية والإنجليزية تحتوي مفاتيح متوازية.
- [ ] لا توجد مفاتيح مفقودة عند التشغيل.
- [ ] لا توجد مفاتيح مهجورة واضحة بعد اكتمال الترحيل.
