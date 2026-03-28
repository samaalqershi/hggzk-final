# Portal Architecture

## English

This document defines the baseline structure for `hggzkportal_app` so the codebase looks consistent, reviewable, and marketplace-ready.

### Current baseline

- `lib/main.dart`: application bootstrap and runtime initialization only.
- `lib/app/`: application shell, router, and top-level pages that are not owned by a single feature.
- `lib/core/`: shared primitives used across the app such as theme, localization, networking, errors, and utilities.
- `lib/features/<feature_name>/`: feature-oriented modules split into `data`, `domain`, and `presentation`.
- `lib/services/`: cross-feature runtime services that are not owned by a single feature and are consumed from multiple modules.

### Import policy

- Prefer `package:hggzkportal/...` imports across feature and core boundaries.
- Use relative imports only inside the same narrow module, such as files inside `lib/app/router/`.
- Avoid reintroducing root-level files like `lib/app.dart` or `lib/routes/...` when the ownership belongs under `lib/app/...`.

### Placement rules

- App-shell concerns belong in `lib/app/`.
- Reusable framework-level utilities belong in `lib/core/`.
- Business behavior belongs in the owning feature folder.
- Services should stay in `lib/services/` only when they coordinate app-wide behavior such as notifications, connectivity, navigation, or sync.

### Cleanup sequence

1. Stabilize bootstrap and router ownership.
2. Fix stale imports and dead references after file moves.
3. Rehome misplaced feature files to their owning modules.
4. Remove truly unused files after verifying references.
5. Expand bilingual API documentation across feature modules.

## العربية

هذا المستند يحدد خط الأساس البنيوي لتطبيق `hggzkportal_app` حتى يصبح المشروع متناسقاً وقابلاً للمراجعة ويظهر بشكل احترافي وجاهز للبيع.

### الهيكل المعتمد حالياً

- `lib/main.dart`: مسؤول فقط عن إقلاع التطبيق وتهيئة الخدمات الأساسية.
- `lib/app/`: غلاف التطبيق والراوتر والصفحات العليا التي لا تتبع ميزة واحدة بعينها.
- `lib/core/`: اللبنات المشتركة بين جميع أجزاء التطبيق مثل الثيم والترجمة والشبكات والأخطاء والأدوات العامة.
- `lib/features/<feature_name>/`: كل ميزة يجب أن تكون مستقلة قدر الإمكان ومقسمة إلى `data` و`domain` و`presentation`.
- `lib/services/`: الخدمات العامة العابرة للميزات والتي تُستخدم من أكثر من جزء داخل التطبيق.

### سياسة الاستيراد

- نفضل استخدام `package:hggzkportal/...` عند عبور حدود الميزات أو `core`.
- نستخدم الاستيراد النسبي فقط داخل النطاق الصغير نفسه مثل ملفات `lib/app/router/`.
- لا نعيد إنشاء ملفات جذرية قديمة مثل `lib/app.dart` أو `lib/routes/...` عندما تكون الملكية الصحيحة تحت `lib/app/...`.

### قواعد توزيع الملفات

- ما يخص غلاف التطبيق يوضع داخل `lib/app/`.
- الأدوات المشتركة على مستوى الإطار العام توضع داخل `lib/core/`.
- السلوك المرتبط بميزة معينة يجب أن يبقى داخل مجلد تلك الميزة.
- تبقى الخدمات داخل `lib/services/` فقط إذا كانت تنسق سلوكاً عاماً مثل الإشعارات والاتصال والملاحة والمزامنة.

### تسلسل التنظيف المقترح

1. تثبيت ملكية طبقة الإقلاع والراوتر.
2. تصحيح الاستيرادات القديمة والمراجع الميتة بعد عمليات النقل.
3. إعادة الملفات الموضوعة في غير مكانها إلى الميزات المالكة لها.
4. حذف الملفات غير المستخدمة فعلاً بعد التحقق من جميع المراجع.
5. توسيع التوثيق الثنائي اللغة تدريجياً داخل الميزات.
