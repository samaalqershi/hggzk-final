# HGGZK Backend

## العربية

هذا المجلد يحتوي على باك اند مشروع حجزك، وتم البدء بتنظيمه ليكون أوضح عند التسليم أو البيع.

### الطبقات الأساسية

- `hggzk.Api`: واجهة HTTP وملفات التهيئة ونقاط الدخول.
- `hggzk.Application`: طبقة التطبيق، مع namespace تشغيلي حالي داخل الكود هو `YemenBooking.Application`.
- `hggzk.Core`: الكيانات والقواعد الأساسية والعقود المشتركة.
- `hggzk.Infrastructure`: تنفيذات التخزين والخدمات الخارجية والبنية التشغيلية.
- `hggzk.Tests`: اختبارات المشروع.

### ملاحظات تنظيمية

- ملف الحل `backend.sln` يجب أن يبقى هو نقطة الدخول الأساسية للمطورين.
- ملفات `bin/` و `obj/` وملفات بيئات التطوير لا ينبغي أن تدخل ضمن النسخة النهائية.
- الملفات التجريبية أو المعزولة مثل `TestRedisSystem` تحتاج مراجعة منفصلة قبل تضمينها في نسخة البيع.

## English

This folder contains the HGGZK backend. Cleanup and structural alignment have started to make the codebase easier to review, maintain, and ship.

### Main layers

- `hggzk.Api`: HTTP surface, startup configuration, and entry points.
- `hggzk.Application`: the application layer, while the current runtime namespace remains `YemenBooking.Application`.
- `hggzk.Core`: domain entities, shared contracts, and core rules.
- `hggzk.Infrastructure`: persistence, external services, and operational infrastructure.
- `hggzk.Tests`: automated tests.

### Repository notes

- `backend.sln` should remain the primary entry point for backend contributors.
- Generated folders such as `bin/` and `obj/` and local IDE files should stay out of the distributable package.
- Experimental folders such as `TestRedisSystem` should be reviewed before they are included in a marketplace-ready release.
