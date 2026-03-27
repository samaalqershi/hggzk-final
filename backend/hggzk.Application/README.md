# hggzk.Application

## العربية

هذا المجلد يمثل طبقة `Application` في المشروع، وهي الطبقة المسؤولة عن حالات الاستخدام، أوامر واستعلامات `CQRS`، الـ handlers، العقود المشتركة، والسلوكيات العابرة مثل التحقق والتسجيل والقياس.

### الهدف من هذه الطبقة

- تجميع منطق التطبيق القابل لإعادة الاستخدام بعيداً عن HTTP وواجهات العرض.
- تنظيم الأوامر والاستعلامات والـ DTOs حسب الميزة الوظيفية.
- تعريف العقود التي تعتمد عليها الطبقة من الخدمات الخارجية أو البنية التحتية.

### الهيكل الحالي

- `Common`: سلوكيات MediatR، الاستثناءات المشتركة، الواجهات، والنماذج العامة.
- `Features`: تنظيم الوظائف حسب الميزة مثل الحجوزات، المدفوعات، العقارات، المستخدمين، وغيرها.
- `Infrastructure`: عقود أو تكيفات خاصة بطبقة التطبيق مع الخدمات الخارجية.
- `Mappings`: ملفات AutoMapper الخاصة بطبقة التطبيق.
- `Validators`: المدققات العامة.

### قواعد تنظيمية

- namespace القياسي داخل الكود هو `YemenBooking.Application`، ولا ينبغي إضافة أي namespaces أو مسارات قديمة باسم `YemenBooking.Application_New`.
- أي ملفات `bin/` و `obj/` أو سجلات بناء أو نتائج تشغيل يجب ألا تُضمّن في نسخة البيع.
- ملفات الشرح أو الوسائط الخاصة بميزة معينة يجب أن تبقى محدودة وواضحة، وألا تتحول هذه الطبقة إلى مجلد أرشيف أو ملفات تشغيل مؤقتة.
- عند إضافة ميزة جديدة، استخدم النمط: `Features/<FeatureName>/{Commands,Queries,DTOs,Services}` بحسب الحاجة فقط.

### أولويات التنظيف الحالية

- توحيد التسميات والمعايير بين الميزات.
- تقليل الملفات الضخمة متعددة المسؤوليات إلى مكوّنات أصغر.
- رفع تغطية توثيق XML بالعربي والإنجليزي على الأنواع الأساسية والواجهات والـ handlers.

## English

This directory contains the `Application` layer. It is responsible for use cases, `CQRS` commands and queries, handlers, shared contracts, and cross-cutting behaviors such as validation, logging, and performance monitoring.

### Layer responsibilities

- Keep application workflows independent from HTTP controllers and UI concerns.
- Organize commands, queries, handlers, and DTOs by feature area.
- Define contracts required by the application layer from infrastructure and external services.

### Current structure

- `Common`: MediatR behaviors, shared exceptions, interfaces, and generic models.
- `Features`: feature-oriented organization for bookings, payments, properties, users, and more.
- `Infrastructure`: application-facing service contracts and adapters.
- `Mappings`: AutoMapper profiles owned by the application layer.
- `Validators`: cross-cutting validators.

### Cleanup conventions

- The canonical runtime namespace is `YemenBooking.Application`; avoid reintroducing legacy `YemenBooking.Application_New` namespaces or paths.
- Generated folders such as `bin/` and `obj/`, build logs, and local run artifacts must stay out of the distributable package.
- Feature-specific documentation or media should remain intentional and limited, not become a dumping area for temporary assets.
- For new feature work, prefer `Features/<FeatureName>/{Commands,Queries,DTOs,Services}` and add only the folders the feature actually needs.

### Current cleanup priorities

- Normalize naming and folder conventions across features.
- Break down oversized handlers and services into smaller focused units.
- Increase Arabic and English XML documentation coverage for foundational types, interfaces, and handlers.
