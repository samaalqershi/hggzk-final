# نظام الفهرسة والبحث المحسّن - Period-Based Search

## نظرة عامة

تم إعادة بناء نظام الفهرسة بالكامل ليعتمد على **RediSearch** مع استراتيجية **Period-Based Indexing** التي تسمح بالبحث والفلترة **مباشرة على مستوى Redis** للتواريخ والأسعار.

---

## ✨ المميزات الرئيسية

### 1. فهرسة ثلاثة أنواع من المستندات

```
📦 unit:{unitId}              → بيانات الوحدة الأساسية
📅 period:price:{ruleId}      → فترة تسعير واحدة
📅 period:avail:{availId}     → فترة إتاحة واحدة
```

### 2. البحث المباشر في التواريخ على Redis

- ❌ **تم حذف**: `IS_AVAILABLE`, `MIN_DAILY_PRICE`, `MAX_DAILY_PRICE`
- ✅ **البديل**: البحث المباشر في الفترات باستخدام RediSearch

### 3. الالتزام بالقواعد المحددة

- ✅ السعر من `PricingRule` حسب التاريخ، وإلا `BasePrice`
- ✅ الإتاحة من `UnitAvailability`، ولو مافيش سجل = متاحة
- ✅ فحص التقاطع بين الفترات مباشرة في Redis

---

## 📐 البنية المعمارية

### الطبقات الأساسية

```
hggzk.Core/Indexing/RediSearch/
├── PeriodBasedSearchSchema.cs      ← تعريف الفهارس الثلاثة
├── PeriodBasedQueryBuilder.cs      ← بناء استعلامات RediSearch
├── PeriodBasedHashBuilder.cs       ← بناء البيانات للفهرسة
└── DateRangeHelper.cs              ← حساب السعر والإتاحة
```

---

## 🔍 استراتيجية البحث

### الترتيب المحدد (حسب طلبك):

```
1️⃣ المدينة (City)
2️⃣ نوع العقار (PropertyTypeId)
3️⃣ نوع الوحدة (UnitTypeId)
4️⃣ + 5️⃣ تاريخ الوصول والمغادرة (CheckIn / CheckOut)
6️⃣ الحقول الديناميكية (DynamicFieldFilters)
7️⃣ المرافق (RequiredAmenities)
8️⃣ الخدمات (RequiredServices)
```

### خطوات التنفيذ:

#### **المرحلة 1: فلترة الإتاحة (إذا كانت هناك تواريخ)**

```csharp
// البحث في idx:periods:avail عن الفترات المحجوزة
FT.SEARCH idx:periods:avail 
  "@status:{Blocked|Booked} 
   @startDateTs:[-inf 1735689600] 
   @endDateTs:[1733011200 +inf]"
   
// النتيجة: قائمة UnitIds المحجوزة
// نستثنيها من البحث الرئيسي
```

#### **المرحلة 2: البحث في الوحدات**

```csharp
// البحث في idx:units:v3
FT.SEARCH idx:units:v3 
  "@city:{صنعاء} 
   @propertyTypeId:{guid1} 
   @unitTypeId:{guid2}
   @amenityIds:{guid3,guid4}
   -@unitId:(excludedIds)"
```

#### **المرحلة 3: حساب السعر للفترة**

```csharp
// لكل وحدة في النتائج:
FT.SEARCH idx:periods:price 
  "@unitId:{unitGuid} 
   @startDateTs:[-inf checkOutTs] 
   @endDateTs:[checkInTs +inf]"

// حساب السعر الإجمالي من الفترات المسترجعة
```

---

## 💾 بنية البيانات في Redis

### 1. مستند الوحدة

```redis
HSET unit:abc123-... 
  unitId "abc123..."
  propertyId "def456..."
  unitName "جناح ملكي"
  city "صنعاء"
  propertyTypeId "guid1"
  unitTypeId "guid2"
  basePrice "1000"
  currency "YER"
  amenityIds "amenity1,amenity2,amenity3"
  maxCapacity "4"
  adultsCapacity "2"
  location "44.1234,15.5678"
  df_bedrooms "2"
  dfn_area "120"
  ...
```

### 2. مستند فترة التسعير

```redis
HSET period:price:rule123
  pricingRuleId "rule123"
  unitId "abc123..."
  propertyId "def456..."
  startDateTs "1733011200"    # 2024-12-01 00:00:00
  endDateTs "1735689600"      # 2025-01-01 00:00:00
  price "1500"
  currency "YER"
```

### 3. مستند فترة الإتاحة (المحجوزة فقط)

```redis
HSET period:avail:avail456
  availabilityId "avail456"
  unitId "abc123..."
  propertyId "def456..."
  startDateTs "1734220800"    # 2024-12-15 00:00:00
  endDateTs "1734566400"      # 2024-12-20 00:00:00
  status "Booked"
  bookingId "booking789"
```

---

## 🔧 القواعد والمنطق

### قاعدة السعر:

```
إذا كان (التاريخ ضمن نطاق PricingRule):
  ✅ استخدم PriceAmount من القاعدة
وإلا:
  ✅ استخدم BasePrice من الوحدة
```

### قاعدة الإتاحة:

```
إذا لم يكن هناك سجل في UnitAvailability:
  ✅ الوحدة متاحة (الافتراض)

إذا كان هناك سجل:
  ✅ فحص التقاطع مع الفترة المطلوبة:
     - إذا Status = "Available" → متاحة ✅
     - إذا Status = "Blocked" أو "Booked" → غير متاحة ❌
```

### فحص التقاطع بين فترتين:

```
Period1: [start1, end1]
Period2: [start2, end2]

تقاطع = (start1 < end2) AND (start2 < end1)
```

---

## 📊 أمثلة على الاستعلامات

### مثال 1: بحث بسيط (بدون تواريخ)

```
الطلب:
- المدينة: صنعاء
- نوع العقار: فندق
- المرافق: wifi, مسبح

الاستعلام:
FT.SEARCH idx:units:v3 
  "@city:{صنعاء} 
   @propertyTypeId:{hotel-guid} 
   @amenityIds:{wifi-guid} 
   @amenityIds:{pool-guid}"
   LIMIT 0 20
```

### مثال 2: بحث مع تواريخ

```
الطلب:
- المدينة: صنعاء
- تاريخ الوصول: 2024-12-20
- تاريخ المغادرة: 2024-12-25
- عدد الضيوف: 2

الخطوات:
1. FT.SEARCH idx:periods:avail للحصول على الوحدات المحجوزة
2. FT.SEARCH idx:units:v3 مع استثناء الوحدات المحجوزة
3. لكل نتيجة: FT.SEARCH idx:periods:price لحساب السعر
4. فلترة حسب MinPrice/MaxPrice (إن وجد)
```

---

## 🚀 الخطوات التالية للتنفيذ

### ما تم إنجازه ✅

1. ✅ `PeriodBasedSearchSchema` - تعريف الفهارس الثلاثة
2. ✅ `PeriodBasedQueryBuilder` - بناء الاستعلامات
3. ✅ `PeriodBasedHashBuilder` - بناء البيانات
4. ✅ `DateRangeHelper` - حساب السعر والإتاحة

### ما يحتاج للإكمال ⏳

1. ⏳ **خدمة الفهرسة** (`OptimizedUnitIndexingService`)
   - فهرسة الوحدة + فترات التسعير + فترات الإتاحة
   - معالجة أحداث التحديث والحذف

2. ⏳ **خدمة البحث** (`OptimizedUnitSearchEngine`)
   - تنفيذ الاستراتيجية متعددة المراحل
   - حساب السعر الإجمالي من الفترات
   - فلترة نهائية حسب السعر

3. ⏳ **تحديث الواجهات** (في Application Layer)
   - `IIndexingService` - قد تحتاج لتعديلات طفيفة
   - `IUnitIndexingService` - التوافق مع الهيكل الجديد

4. ⏳ **Migration Script**
   - نقل البيانات من الفهرس القديم للجديد
   - إنشاء الفهارس الثلاثة في Redis
   - إعادة فهرسة جميع الوحدات

---

## 📝 ملاحظات مهمة

### الأداء

- ✅ البحث في الفترات يتم **مباشرة على Redis** بدون جلب JSON
- ✅ فهرسة الفترات المحجوزة فقط (توفير مساحة)
- ✅ استخدام NUMERIC indexes للتواريخ (بحث سريع جداً)
- ⚠️ Post-processing محدود فقط لحساب السعر النهائي

### التوافقية

- ✅ متوافق مع جميع أنواع `PricingMethod` (Hourly, Daily, Weekly, Monthly)
- ✅ يدعم عملات متعددة
- ✅ يدعم الحقول الديناميكية بأنواعها (نصية ورقمية)

### الصيانة

- 🔄 عند تحديث `PricingRule` → تحديث `period:price:{ruleId}`
- 🔄 عند تحديث `UnitAvailability` → تحديث `period:avail:{availId}`
- 🔄 عند حذف قاعدة → حذف المستند من Redis
- 🧹 تنظيف دوري للفترات القديمة (أقدم من 6 أشهر مثلاً)

---

## 🎯 الخلاصة

تم تصميم النظام الجديد ليكون:

1. **دقيق 100%**: يطبق جميع القواعد المحددة
2. **سريع**: البحث والفلترة على Redis مباشرة
3. **قابل للتوسع**: سهل إضافة معايير بحث جديدة
4. **موثوق**: لا يعتمد على افتراضات أو حسابات تقريبية

---

## 📞 للمتابعة

الملفات الجاهزة:
- ✅ `PeriodBasedSearchSchema.cs`
- ✅ `PeriodBasedQueryBuilder.cs`
- ✅ `PeriodBasedHashBuilder.cs`
- ✅ `DateRangeHelper.cs`

التالي: إنشاء خدمات الفهرسة والبحث الفعلية.
