# HGGZK Bilingual Content Handoff

هذا الملف هو نقطة التسليم الحالية للعمل الخاص بدعم المحتوى الثنائي اللغة
`ar/en` عبر:
- `backend`
- `hggzkportal_app`
- `hggzk_app`

الهدف من الملف:
- حفظ ما تم إنجازه بدقة
- توثيق ما تبقى
- تسهيل استكمال العمل لاحقًا دون فقدان السياق

## 1. ما تم إنجازه في الباك إند

تمت إضافة حقول إنجليزية موازية في الكيانات الأساسية التالية:
- `Property`
- `Unit`
- `City`
- `Amenity`
- `PropertyService`
- `PropertyPolicy`
- `PropertyType`
- `UnitType`
- `FieldGroup`
- `UnitTypeField`
- `SearchFilter`

أمثلة الحقول المضافة:
- `NameEn`
- `DescriptionEn`
- `ShortDescriptionEn`
- `AddressEn`
- `CityEn`
- `CountryEn`
- `CustomFeaturesEn`
- `DisplayNameEn`
- `GroupNameEn`
- `FieldOptionsEn`
- `FilterOptionsEn`
- `RulesEn`
- عدة حقول EN إضافية في السياسات مثل:
  - `CancellationPenaltyAfterDeadlineEn`
  - `CheckInEarlyCheckInNoteEn`
  - `CheckInLateCheckOutNoteEn`
  - `CheckInLateCheckOutFeeEn`
  - `ChildrenCribsNoteEn`
  - `PetsReasonEn`
  - `PetsMaxWeightEn`
  - `ModificationFeesAfterEn`
  - `ModificationReasonEn`

تم أيضًا:
- تحديث EF configurations لتلك الحقول
- تحديث أوامر الإنشاء/التحديث والمعالجات الخاصة بها
- تحديث DTOs وجزء كبير من query handlers وmapping profiles
- تحديث `CitySettingsService`
- توسيع مسار localization الخاص برسائل الباك إند سابقًا

## 2. ما تم تثبيته في قاعدة البيانات

تم إنشاء migration يدوي جديد:
- [20260328120000_AddBilingualContentFields.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Infrastructure/Data/Migrations/20260328120000_AddBilingualContentFields.cs)

وتم تحديث snapshot:
- [YemenBookingDbContextModelSnapshot.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Infrastructure/Data/Migrations/YemenBookingDbContextModelSnapshot.cs)

مهم:
- هذا الجزء أنشئ يدويًا لتثبيت الأعمدة الجديدة في schema
- لم يتم تأكيد build نهائي موثوق للباك إند من البيئة الحالية بسبب سلوك `dotnet build` غير الحاسم في الجلسات السابقة

## 3. الملفات التي عُدلت فعليًا في الباك إند

أهم الملفات التي تم تعديلها:
- [Property.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Entities/Property.cs)
- [Unit.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Entities/Unit.cs)
- [City.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Entities/City.cs)
- [Amenity.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Entities/Amenity.cs)
- [PropertyService.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Entities/PropertyService.cs)
- [PropertyPolicy.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Entities/PropertyPolicy.cs)
- [PropertyType.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Entities/PropertyType.cs)
- [UnitType.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Entities/UnitType.cs)
- [FieldGroup.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Entities/FieldGroup.cs)
- [UnitTypeField.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Entities/UnitTypeField.cs)
- [SearchFilter.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Entities/SearchFilter.cs)

وملفات التهيئة:
- [PropertyConfiguration.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Infrastructure/Data/Configurations/PropertyConfiguration.cs)
- [UnitConfiguration.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Infrastructure/Data/Configurations/UnitConfiguration.cs)
- [CityConfiguration.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Infrastructure/Data/Configurations/CityConfiguration.cs)
- [AmenityConfiguration.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Infrastructure/Data/Configurations/AmenityConfiguration.cs)
- [PropertyServiceConfiguration.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Infrastructure/Data/Configurations/PropertyServiceConfiguration.cs)
- [PropertyPolicyConfiguration.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Infrastructure/Data/Configurations/PropertyPolicyConfiguration.cs)
- [PropertyTypeConfiguration.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Infrastructure/Data/Configurations/PropertyTypeConfiguration.cs)
- [UnitTypeConfiguration.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Infrastructure/Data/Configurations/UnitTypeConfiguration.cs)
- [FieldGroupConfiguration.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Infrastructure/Data/Configurations/FieldGroupConfiguration.cs)
- [SearchFilterConfiguration.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Infrastructure/Data/Configurations/SearchFilterConfiguration.cs)
- [UnitTypeFieldConfiguration.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Infrastructure/Data/Configurations/UnitTypeFieldConfiguration.cs)

## 4. حالة البورتال الآن

تم الاستكشاف والتحليل على مستوى:
- entities
- models
- repositories
- data sources
- events/blocs
- pages

النطاقات التي تم التأكد من وجودها في البورتال:
- properties
- units
- cities
- amenities
- services
- policies

ما تم إنجازه فعليًا الآن في `hggzkportal_app`:
- تم إضافة حقول EN في طبقة `domain/entities` و`data/models` و`usecases` و`events/blocs` و`remote payloads` للنطاقات التالية:
  - `properties`
  - `cities`
  - `amenities`
  - `services`
- أمثلة الحقول التي تم تمريرها في البورتال:
  - `nameEn`
  - `shortDescriptionEn`
  - `addressEn`
  - `descriptionEn`
  - `countryEn`
  - `propertyNameEn`
- تم إضافة حقول إدخال EN فعلية في الواجهات التالية:
  - [city_form_page.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_cities/presentation/pages/city_form_page.dart)
  - [create_amenity_page.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_amenities/presentation/pages/create_amenity_page.dart)
  - [create_service_page.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_services/presentation/pages/create_service_page.dart)

أهم نقاط العمل المتبقية في البورتال:
- إكمال sweep نهائي على البورتال للتأكد من عدم بقاء أي شاشة create/edit رئيسية تعرض العربية فقط
- مراجعة أي helpers أو lists أو cards ما تزال تستخدم الحقول العربية مباشرة بدل الحقول الثنائية الجديدة
- التحقق النهائي end-to-end على دورة: حفظ من البورتال -> قراءة من الباك إند -> عرض في العميل

## 5. حالة تطبيق العميل الآن

تم تحليل الطبقات التالية:
- property
- reference
- search
- home

النماذج المرشحة للتحديث لاحقًا:
- property detail models
- unit models
- amenity models
- city models
- search filter/search result models
- home property type/unit type models
- section item models

النهج المخطط للعميل:
- عند وصول `nameEn/descriptionEn/...` من الخادم
- يتم اختيار القيمة العربية أو الإنجليزية تلقائيًا بحسب اللغة الحالية
- الهدف هو جعل الشاشات الحالية تستفيد من الحقول الجديدة دون الحاجة لإعادة كتابة كل الودجتات يدويًا

ما تم إنجازه فعليًا الآن في `hggzk_app`:
- تم إنشاء utility مركزية:
  - [localized_api_value.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzk_app/lib/core/localization/localized_api_value.dart)
- تم تحسين [locale_manager.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzk_app/lib/core/localization/locale_manager.dart) بحيث يقرأ اللغة الحالية من التخزين المحلي قبل الرجوع إلى اللغة الافتراضية
- تم ربط القراءة الثنائية في النماذج التالية:
  - [property_detail_model.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzk_app/lib/features/property/data/models/property_detail_model.dart)
  - [unit_model.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzk_app/lib/features/property/data/models/unit_model.dart)
  - [amenity_model.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzk_app/lib/features/property/data/models/amenity_model.dart)
  - [city_model.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzk_app/lib/features/reference/data/models/city_model.dart)
  - [search_filter_model.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzk_app/lib/features/search/data/models/search_filter_model.dart)
  - [search_result_model.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzk_app/lib/features/search/data/models/search_result_model.dart)
  - [property_type_model.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzk_app/lib/features/home/data/models/property_type_model.dart)
  - [unit_type_model.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzk_app/lib/features/home/data/models/unit_type_model.dart)
  - [section_item_models.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzk_app/lib/features/home/data/models/section_item_models.dart)

مهم:
- هذا الجزء أصبح منجزًا على مستوى طبقة النماذج والقراءة الأساسية
- المتبقي في العميل الآن هو التحقق الأوسع على تدفقات أخرى عند الحاجة وليس البنية الأساسية للاختيار بين `AR/EN`

## 6. ما كان جاريًا مباشرة قبل التوقف

آخر نقطة تنفيذية فعلية الآن:
- تم إكمال طبقة القراءة الثنائية الأساسية في `hggzk_app`
- وتم ربط جزء مهم من `hggzkportal_app` حتى أصبحت بعض النطاقات تحفظ فعليًا حقول EN
- وتم في هذه الجولة إغلاق المسارات التالية في البورتال:
  - `edit_amenity_page.dart`
  - `edit_service_page.dart`
  - `create_property_page.dart`
  - `edit_property_page.dart`
- وتم بعد ذلك إغلاق واجهات السياسات نفسها في:
  - [create_policy_page.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_policies/presentation/pages/create_policy_page.dart)
  - [edit_policy_page.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_policies/presentation/pages/edit_policy_page.dart)
  وأصبحت تحفظ/تعدل فعليًا:
  - `descriptionEn`
  - `rules`
  - `rulesEn`
  - `checkInEarlyCheckInNoteEn`
  - `childrenCribsNoteEn`
  - `petsReasonEn`
  - `modificationReasonEn`
- وتم بعد ذلك إكمال نطاق `units` في البورتال end-to-end على مستوى:
  - [unit.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_units/domain/entities/unit.dart)
  - [unit_model.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_units/data/models/unit_model.dart)
  - [units_repository.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_units/domain/repositories/units_repository.dart)
  - [create_unit_usecase.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_units/domain/usecases/create_unit_usecase.dart)
  - [update_unit_usecase.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_units/domain/usecases/update_unit_usecase.dart)
  - [units_repository_impl.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_units/data/repositories/units_repository_impl.dart)
  - [unit_form_state.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_units/presentation/bloc/unit_form/unit_form_state.dart)
  - [unit_form_event.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_units/presentation/bloc/unit_form/unit_form_event.dart)
  - [unit_form_bloc.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_units/presentation/bloc/unit_form/unit_form_bloc.dart)
  - [create_unit_page.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_units/presentation/pages/create_unit_page.dart)
  - [edit_unit_page.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_units/presentation/pages/edit_unit_page.dart)
  وأصبح يدعم فعليًا:
  - `nameEn`
  - `customFeaturesEn`
  - `propertyNameEn`
  - `unitTypeNameEn`
- وتم بعد ذلك تحسين مسارات العرض الأساسية في البورتال بحيث تعرض العربية كسطر رئيسي والإنجليزية كسطر ثانٍ عند توفرها في:
  - [futuristic_units_table.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_units/presentation/widgets/futuristic_units_table.dart)
  - [futuristic_services_table.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_services/presentation/widgets/futuristic_services_table.dart)
  - [futuristic_amenities_table.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_amenities/presentation/widgets/futuristic_amenities_table.dart)
  - [futuristic_city_card.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_cities/presentation/widgets/futuristic_city_card.dart)
  - [futuristic_policies_table.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_policies/presentation/widgets/futuristic_policies_table.dart)
- وتم لاحقًا إغلاق دفعة إضافية لمسارات العرض الثانوية التي كانت ما تزال تعرض العربية فقط، في:
  - [unit_details_page.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_units/presentation/pages/unit_details_page.dart)
  - [futuristic_unit_card.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_units/presentation/widgets/futuristic_unit_card.dart)
  - [service_details_dialog.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_services/presentation/widgets/service_details_dialog.dart)
  - [futuristic_service_card.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_services/presentation/widgets/futuristic_service_card.dart)
  - [futuristic_amenity_card.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_amenities/presentation/widgets/futuristic_amenity_card.dart)
  - [assign_amenity_dialog.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_amenities/presentation/widgets/assign_amenity_dialog.dart)
  - [futuristic_policy_card.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_policies/presentation/widgets/futuristic_policy_card.dart)
  وأصبح العرض فيها يدعم:
  - `unit.name / unit.nameEn`
  - `propertyName / propertyNameEn`
  - `unitTypeName / unitTypeNameEn`
  - `customFeatures / customFeaturesEn`
  - `service.name / service.nameEn`
  - `service.description / service.descriptionEn`
  - `amenity.name / amenity.nameEn`
  - `amenity.description / amenity.descriptionEn`
  - `policy.description / policy.descriptionEn`
  - `policy.rules / policy.rulesEn` داخل بطاقات وتلميحات السياسات
- وتم توسيع طبقة السياسات في البورتال على مستوى:
  - `policy entity/model`
  - `repository`
  - `create/update usecases`
  - `policies bloc/events`
  - `remote datasource`
  بحيث أصبحت تدعم الحقول الإنجليزية التالية:
  - `descriptionEn`
  - `rulesEn`
  - `checkInEarlyCheckInNoteEn`
  - `childrenCribsNoteEn`
  - `petsReasonEn`
  - `modificationReasonEn`
- وما يزال المسار الحالي المفتوح هو:
  1. تنفيذ sweep نهائي على بقية شاشات وقوائم البورتال التي لم تُمس بعد، مع الانتباه خصوصًا للمسارات التي ما تزال تعتمد على `admin_properties/domain/entities/policy.dart` لأنه نوع قديم لا يحمل حقول EN
  2. مراجعة العميل على المسارات التي تعرض الوحدات/السياسات/الخدمات/المرافق بعد اكتمال الحقول الجديدة
  3. تنفيذ تحقق نهائي على الربط بين الباك إند والبورتال والعميل
  4. عند الحاجة، إنشاء migration/data backfill لمحتوى EN القديم غير الموجود في البيانات الحالية

## 7. الأولويات المقترحة عند الاستكمال

عند العودة للعمل، ابدأ بهذا الترتيب:

1. التحقق من صحة الباك إند
- مراجعة migration/snapshot
- تجربة build أو على الأقل مراجعة نصية للملفات المعدلة

2. إكمال `hggzkportal_app`
- مراجعة lists/details/cards بعد اكتمال create/edit
- التأكد من أن `units / policies / properties / amenities / services / cities` تقرأ وتعرض الحقول الثنائية كما يجب
- مراجعة أي admin helpers أو search helpers مرتبطة بهذه الكيانات

4. تحقق نهائي
- حفظ البيانات باللغتين من البورتال
- عودة الحقول باللغتين من الباك إند
- عرض اللغة المناسبة في العميل

## 9. حالة التحقق الحالية

تم تشغيل:
- `dart format` على ملفات البورتال المعدلة في هذه الجولة
- `/home/ameen/flutter/bin/dart analyze` على ملفات البورتال المعدلة في هذه الجولة

النتيجة الحالية:
- لا توجد `errors` build-blocking في الدفعة الحالية
- المتبقي فقط `info` قديمة/أسلوبية مثل:
  - `use_build_context_synchronously`
  - `avoid_print`
  - `use_super_parameters`
  - وبعض `deprecated_member_use / prefer_const_constructors` في ويدجتات قديمة ولم تكن blockers
  - وفي آخر دفعة بطاقات العرض بقيت فقط ملاحظات `deprecated_member_use` قديمة داخل رسامي الخلفية في [futuristic_unit_card.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_units/presentation/widgets/futuristic_unit_card.dart)، وليست مرتبطة بمنطق العرض الثنائي الجديد

## 8. ملاحظة مهمة جدًا

لا تعتمد لاحقًا على "الذاكرة فقط".

اعتمد على هذا الملف مع الملفات التالية أيضًا:
- [20260328120000_AddBilingualContentFields.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Infrastructure/Data/Migrations/20260328120000_AddBilingualContentFields.cs)
- [YemenBookingDbContextModelSnapshot.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Infrastructure/Data/Migrations/YemenBookingDbContextModelSnapshot.cs)

هذا الملف هو المرجع الرسمي الحالي للحالة.

## تحديث 2026-03-29

- أُغلق مسار العرض الثنائي اللغة للعقارات في البورتال على مستوى:
  - بطاقات العقارات
  - الجداول المستقبلية للعقارات
  - صفحة تفاصيل العقار
  - بطاقة الهوية المنبثقة للعقار
  - بطاقة معلومات العقار
  - عرض الخرائط/العناقيد المرتبط بالعقارات
- أصبح كيان العقار في البورتال يحمل ويقرأ ويصدر أيضًا:
  - `cityEn`
  - `typeNameEn`
  - `formattedAddressEn`
- أُغلق مسار نتائج البحث في الباك إند لهذه النقاط:
  - `PropertySearchResultDto` أصبح يمرر:
    - `NameEn`
    - `DescriptionEn`
    - `AddressEn`
    - `CityEn`
    - `UnitNameEn`
    - `PropertyTypeEn`
  - `SearchPropertiesCommandHandler`
  - `GetRecommendedPropertiesQueryHandler`
  - `SearchPropertiesQueryHandler`
  - `SearchUnitsQueryHandler`
- أُغلق أيضًا مسار `AdvancedPropertySearch` من ناحية البيانات المعادة عند إنشاء الإجراء:
  - `AdvancedPropertyDto` يحمل الآن `Id`
  - `sp_AdvancedPropertySearch` أصبح يعيد:
    - `NameEn`
    - `Address`
    - `AddressEn`
    - `City`
    - `CityEn`
    - `TypeName`
    - `TypeNameEn`
- `SearchPropertiesQueryHandler` صار يثري نتائج البحث المفهرسة بالبيانات الإنجليزية من مستودع العقارات.
- `SearchUnitsQueryHandler` صار يثري نتائج بحث الوحدات بالبيانات الإنجليزية من مستودع الوحدات بدل إرجاع حقول EN فارغة.

## تحقق هذه الجولة

- `dart analyze hggzkportal_app/lib/features/admin_properties hggzkportal_app/lib/core/widgets/property_identity_card_tooltip.dart`
  - نجح بدون أخطاء
  - المتبقي فقط `info` قديمة/أسلوبية لا تخص هذا المسار
- `dotnet build backend/hggzk.Application/hggzk.Application.csproj --no-restore -v minimal`
  - نجح
  - المتبقي warnings قديمة عامة في المشروع، وليس أخطاء مرتبطة بهذه الجولة
- تمت أيضًا إزالة تكرارات قديمة من `backend/hggzk.Core/Indexing/Models/UnitSearchModels.cs` كانت تكسر البناء عند تجميع `Core/Application`.

## ملاحظات مهمة متبقية

- توجد مسارات بحث متقدم قديمة مثل `AdvancedPropertySearch` ما تزال تحتاج جولة منفصلة إذا أردنا توسيع الحقول الإنجليزية فيها بنفس عمق المسارات الأساسية، لأن الـ DTO الحالي لذلك المسار محدود أصلًا ولا يحمل هوية كافية للإثراء الكامل دون توسيع إضافي.

## 10. تحديث نهائي بتاريخ 2026-03-29

تم في هذه الجولة إغلاق المسارات المفتوحة التالية:

- إكمال مسار السياسات القديم داخل `admin_properties` في البورتال، ولم يعد معزولًا عن الحقول الثنائية.
- إكمال مسار الحقول الديناميكية داخل `admin_units` في البورتال على مستوى القراءة والعرض، بحيث أصبحت أسماء الحقول/المجموعات وأوصافها تدعم النسخ الإنجليزية أيضًا.
- توسيع DTO/queries الخاصة بتفاصيل العقار في الباك إند لإرجاع:
  - `DescriptionEn`
  - `RulesEn`
  - `RulesJson`
  ضمن سياسات العقار، إضافة إلى الحقول الإنجليزية للعقار والخدمات والمرافق ونوع العقار في نفس المسار.
- توسيع نموذج وسيط السياسات القديم في البورتال على مستوى:
  - [policy.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_properties/domain/entities/policy.dart)
  - [policy_model.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_properties/data/models/policy_model.dart)
  - [create_policy_usecase.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_properties/domain/usecases/policies/create_policy_usecase.dart)
  - [update_policy_usecase.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_properties/domain/usecases/policies/update_policy_usecase.dart)
  - [policies_event.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_properties/presentation/bloc/policies/policies_event.dart)
  - [policies_bloc.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_properties/presentation/bloc/policies/policies_bloc.dart)
  - [policy_editor_widget.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_properties/presentation/widgets/policy_editor_widget.dart)
  - [property_policies_list.dart](/home/ameen/Desktop/myProjects/Rezmate/hggzkportal_app/lib/features/admin_properties/presentation/widgets/property_policies_list.dart)
- أصبحت هذه الطبقة تدعم الآن فعليًا:
  - `description / descriptionEn`
  - `rules / rulesEn`
  - عرض النصين في التحرير والقوائم والتفاصيل والتلميحات
- وأصبحت طبقة الحقول الديناميكية في البورتال تدعم الآن فعليًا:
  - `displayName / displayNameEn`
  - `description / descriptionEn`
  - `groupName / groupNameEn`
  - `group displayName / displayNameEn`
  - عرض القيم العربية والإنجليزية في:
    - بطاقات الوحدات
    - جداول الوحدات
    - تفاصيل الوحدة
    - مراجعات create/edit للوحدة
    - widget الحقول الديناميكية نفسها

تم في هذه الجولة أيضًا تحديث السيدرز في الباك إند بحيث تضخ القيم الإنجليزية للكيانات المطلوبة عند إعادة الإنشاء:

- [SeedLocalizationHelper.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Seeds/SeedLocalizationHelper.cs)
- [CitySeeder.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Seeds/CitySeeder.cs)
- [AmenitySeeder.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Seeds/AmenitySeeder.cs)
- [PropertyTypeSeeder.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Seeds/PropertyTypeSeeder.cs)
- [PropertyServiceSeeder.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Seeds/PropertyServiceSeeder.cs)
- [PropertySeeder.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Seeds/PropertySeeder.cs)
- [UnitTypeSeeder.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Seeds/UnitTypeSeeder.cs)
- [UnitSeeder.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Seeds/UnitSeeder.cs)
- [UnitTypeFieldSeeder.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Seeds/UnitTypeFieldSeeder.cs)
- [PropertyPolicySeeder.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Seeds/PropertyPolicySeeder.cs)
- [DatabaseSeeder.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Seeds/DatabaseSeeder.cs)

الكيانات المغطاة فعليًا في السيدرز الآن:

- `properties`
- `units`
- `dynamic fields`
- `cities`
- `services`
- `amenities`
- `policies`
- وتم أيضًا توسيع التصنيفات المرتبطة:
  - `property types`
  - `unit types`

مهم جدًا:

- التهيئة الفعلية وقت التشغيل تعتمد على:
  - [DataSeedingService.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Infrastructure/Data/Initialization/DataSeedingService.cs)
- وهذا يعني أن حذف قاعدة البيانات ثم تشغيل الباك إند سيعيد إنشاء البيانات من السيدرز المحدثة أعلاه.

التحقق المنفذ في هذه الجولة:

- `dotnet build` نجح على:
  - `hggzk.Core`
  - `hggzk.Application`
- `dart analyze` لمسارات البورتال المعدلة استمر دون `errors` build-blocking.
- تم حذف قاعدة البيانات الحالية:
  - `YemenBookingDb`
- وتم التحقق بعد الحذف أن اسم القاعدة لم يعد موجودًا ضمن قواعد PostgreSQL المحلية.

المتبقي الواقعي بعد هذه الجولة:

- لا يوجد مسار مفتوح رئيسي من نفس الفئة التي كنا نغلقها في:
  - `backend`
  - `hggzkportal_app`
  - `hggzk_app`
- المتبقي لاحقًا إن ظهر سيكون من نوع:
  - بيانات قديمة محفوظة مسبقًا قبل إضافة الحقول الإنجليزية
  - أو تحسينات تغطية إضافية على محتوى domain قديم لا يملك أصلًا عمود EN مقابلًا له

ملاحظة حدود دقيقة:

- [UnitFieldValueSeeder.cs](/home/ameen/Desktop/myProjects/Rezmate/backend/hggzk.Core/Seeds/UnitFieldValueSeeder.cs) ما يزال يضخ قيمًا عربية تخص قيم الحقول نفسها، لكن ذلك لأن كيان `UnitFieldValue` لا يملك أصلًا حقولًا إنجليزية مقابلة في المخطط الحالي. لذلك لم يتم اصطناع حقول غير موجودة على مستوى الـ schema.
