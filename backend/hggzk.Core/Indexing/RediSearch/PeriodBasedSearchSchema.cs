using System;
using System.Collections.Generic;
using System.Linq;

namespace YemenBooking.Core.Indexing.RediSearch;

/// <summary>
/// Schema محسّن للبحث المباشر في التواريخ على مستوى Redis
/// 
/// الاستراتيجية:
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// فهرسة نوعين من المستندات:
/// 
/// 1. المستند الرئيسي للوحدة: unit:{unitId}
///    - جميع البيانات الأساسية للوحدة
///    - المدينة، نوع العقار، نوع الوحدة، إلخ
///    - بدون IS_AVAILABLE (نحذفه تماماً)
///    - بدون MIN/MAX prices (نحذفهم تماماً)
/// 
/// 2. مستندات الجدول اليومي: period:schedule:{scheduleId}
///    - scheduleId (TAG) - معرف الجدول
///    - unitId (TAG, SORTABLE) - معرف الوحدة
///    - propertyId (TAG) - معرف العقار
///    - dateTs (NUMERIC, SORTABLE) - timestamp التاريخ اليومي
///    - status (TAG) - Available / Blocked / Booked
///    - price (NUMERIC, SORTABLE) - السعر (اختياري)
///    - currency (TAG) - العملة (اختياري)
///    - bookingId (TAG) - معرف الحجز (اختياري)
///    - priceType (TAG) - نوع التسعير (اختياري)
///    - pricingTier (TAG) - مستوى التسعير (اختياري)
///    - reason (TEXT) - السبب أو ملاحظات (اختياري)
/// 
/// استراتيجية البحث:
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// عند البحث بتواريخ (CheckIn, CheckOut):
/// 
/// 1. البحث عن الوحدات المتاحة:
///    - نبحث في idx:periods:schedule عن أيام محجوزة تتقاطع مع (CheckIn, CheckOut)
///    - نستثني UnitIds الموجودة في النتيجة
///    
/// 2. حساب السعر:
///    - نبحث في idx:periods:schedule عن الأيام ضمن النطاق (CheckIn, CheckOut)
///    - نجمع الأسعار ونحسب المجموع
///    
/// 3. الفلترة النهائية:
///    - نبحث في idx:units عن الوحدات المتبقية بالمعايير الأخرى
/// </summary>
public static class PeriodBasedSearchSchema
{
    public sealed record DynamicSchemaField(string FieldName, bool IsNumeric);

    #region === Units Index (الوحدات) ===
    
    /// <summary>
    /// حقل UNITS_INDEX.
    /// UNITS_INDEX field.
    /// </summary>
    public const string UNITS_INDEX = "idx:units:v3";
    /// <summary>
    /// حقل UNITS_PREFIX.
    /// UNITS_PREFIX field.
    /// </summary>
    public const string UNITS_PREFIX = "unit:";
    
    /// <summary>
    /// حقول مستند الوحدة (بدون IS_AVAILABLE وبدون MIN/MAX prices)
    /// </summary>
    public static class UnitFields
    {
        /// <summary>
        /// حقل UNIT_ID.
        /// UNIT_ID field.
        /// </summary>
        public const string UNIT_ID = "unitId";
        /// <summary>
        /// حقل PROPERTY_ID.
        /// PROPERTY_ID field.
        /// </summary>
        public const string PROPERTY_ID = "propertyId";
        /// <summary>
        /// حقل UNIT_NAME.
        /// UNIT_NAME field.
        /// </summary>
        public const string UNIT_NAME = "unitName";
        /// <summary>
        /// حقل PROPERTY_NAME.
        /// PROPERTY_NAME field.
        /// </summary>
        public const string PROPERTY_NAME = "propertyName";
        
        // الفلتر 1: المدينة
        /// <summary>
        /// حقل CITY.
        /// CITY field.
        /// </summary>
        public const string CITY = "city";
        
        // الفلتر 2: نوع العقار
        /// <summary>
        /// حقل PROPERTY_TYPE_ID.
        /// PROPERTY_TYPE_ID field.
        /// </summary>
        public const string PROPERTY_TYPE_ID = "propertyTypeId";
        /// <summary>
        /// حقل PROPERTY_TYPE_NAME.
        /// PROPERTY_TYPE_NAME field.
        /// </summary>
        public const string PROPERTY_TYPE_NAME = "propertyTypeName";
        
        // الفلتر 3: نوع الوحدة
        /// <summary>
        /// حقل UNIT_TYPE_ID.
        /// UNIT_TYPE_ID field.
        /// </summary>
        public const string UNIT_TYPE_ID = "unitTypeId";
        /// <summary>
        /// حقل UNIT_TYPE_NAME.
        /// UNIT_TYPE_NAME field.
        /// </summary>
        public const string UNIT_TYPE_NAME = "unitTypeName";
        
        /// <summary>
        /// حقل OWNER_ID.
        /// OWNER_ID field.
        /// </summary>
        public const string OWNER_ID = "ownerId";
        /// <summary>
        /// حقل IS_APPROVED.
        /// IS_APPROVED field.
        /// </summary>
        public const string IS_APPROVED = "isApproved";
        /// <summary>
        /// حقل IS_FEATURED.
        /// IS_FEATURED field.
        /// </summary>
        public const string IS_FEATURED = "isFeatured";
        /// <summary>
        /// حقل STAR_RATING.
        /// STAR_RATING field.
        /// </summary>
        public const string STAR_RATING = "starRating";
        /// <summary>
        /// حقل AVERAGE_RATING.
        /// AVERAGE_RATING field.
        /// </summary>
        public const string AVERAGE_RATING = "averageRating";
        
        // الموقع الجغرافي
        /// <summary>
        /// حقل ADDRESS.
        /// ADDRESS field.
        /// </summary>
        public const string ADDRESS = "address";
        /// <summary>
        /// حقل LOCATION.
        /// LOCATION field.
        /// </summary>
        public const string LOCATION = "location";
        /// <summary>
        /// حقل LATITUDE.
        /// LATITUDE field.
        /// </summary>
        public const string LATITUDE = "latitude";
        /// <summary>
        /// حقل LONGITUDE.
        /// LONGITUDE field.
        /// </summary>
        public const string LONGITUDE = "longitude";
        
        // السعة
        /// <summary>
        /// حقل MAX_CAPACITY.
        /// MAX_CAPACITY field.
        /// </summary>
        public const string MAX_CAPACITY = "maxCapacity";
        /// <summary>
        /// حقل ADULTS_CAPACITY.
        /// ADULTS_CAPACITY field.
        /// </summary>
        public const string ADULTS_CAPACITY = "adultsCapacity";
        /// <summary>
        /// حقل CHILDREN_CAPACITY.
        /// CHILDREN_CAPACITY field.
        /// </summary>
        public const string CHILDREN_CAPACITY = "childrenCapacity";
        
        // السعر الأساسي (للرجوع فقط، ليس للبحث)
        /// <summary>
        /// حقل BASE_PRICE.
        /// BASE_PRICE field.
        /// </summary>
        public const string BASE_PRICE = "basePrice";
        /// <summary>
        /// حقل CURRENCY.
        /// CURRENCY field.
        /// </summary>
        public const string CURRENCY = "currency";
        
        // الفلتر 6: المرافق
        /// <summary>
        /// حقل AMENITY_IDS.
        /// AMENITY_IDS field.
        /// </summary>
        public const string AMENITY_IDS = "amenityIds";
        /// <summary>
        /// حقل AMENITY_NAMES.
        /// AMENITY_NAMES field.
        /// </summary>
        public const string AMENITY_NAMES = "amenityNames";
        
        // الفلتر 7: الخدمات
        /// <summary>
        /// حقل SERVICE_IDS.
        /// SERVICE_IDS field.
        /// </summary>
        public const string SERVICE_IDS = "serviceIds";
        /// <summary>
        /// حقل SERVICE_NAMES.
        /// SERVICE_NAMES field.
        /// </summary>
        public const string SERVICE_NAMES = "serviceNames";
        
        // الحقول الديناميكية - الفلتر 5
        /// <summary>
        /// حقل DYNAMIC_FIELD_PREFIX.
        /// DYNAMIC_FIELD_PREFIX field.
        /// </summary>
        public const string DYNAMIC_FIELD_PREFIX = "df_";
        /// <summary>
        /// حقل DYNAMIC_NUMERIC_PREFIX.
        /// DYNAMIC_NUMERIC_PREFIX field.
        /// </summary>
        public const string DYNAMIC_NUMERIC_PREFIX = "dfn_";
        
        // بيانات وصفية
        /// <summary>
        /// حقل VIEW_COUNT.
        /// VIEW_COUNT field.
        /// </summary>
        public const string VIEW_COUNT = "viewCount";
        /// <summary>
        /// حقل BOOKING_COUNT.
        /// BOOKING_COUNT field.
        /// </summary>
        public const string BOOKING_COUNT = "bookingCount";
        /// <summary>
        /// حقل INDEXED_AT.
        /// INDEXED_AT field.
        /// </summary>
        public const string INDEXED_AT = "indexedAt";
        
        // الكلمات المفتاحية
        /// <summary>
        /// حقل SEARCH_KEYWORDS.
        /// SEARCH_KEYWORDS field.
        /// </summary>
        public const string SEARCH_KEYWORDS = "searchKeywords";
        
        // المستند الكامل
        /// <summary>
        /// حقل FULL_DOCUMENT.
        /// FULL_DOCUMENT field.
        /// </summary>
        public const string FULL_DOCUMENT = "_doc";
    }
    
    /// <summary>
    /// دالة GetCreateUnitsIndexCommand.
    /// GetCreateUnitsIndexCommand method.
    /// </summary>
    public static string[] GetCreateUnitsIndexCommand(IEnumerable<DynamicSchemaField>? dynamicFields = null)
    {
        var command = new List<string>
        {
            "FT.CREATE", UNITS_INDEX,
            "ON", "HASH",
            "PREFIX", "1", UNITS_PREFIX,
            "SCHEMA",
            
            UnitFields.UNIT_ID, "TAG", "SORTABLE",
            UnitFields.PROPERTY_ID, "TAG", "SORTABLE",
            UnitFields.UNIT_NAME, "TEXT", "WEIGHT", "2.0", "SORTABLE",
            UnitFields.PROPERTY_NAME, "TEXT", "WEIGHT", "1.5", "SORTABLE",
            UnitFields.CITY, "TAG", "SORTABLE",
            UnitFields.PROPERTY_TYPE_ID, "TAG", "SORTABLE",
            UnitFields.PROPERTY_TYPE_NAME, "TEXT",
            UnitFields.UNIT_TYPE_ID, "TAG", "SORTABLE",
            UnitFields.UNIT_TYPE_NAME, "TEXT",
            UnitFields.OWNER_ID, "TAG",
            UnitFields.IS_APPROVED, "TAG",
            UnitFields.IS_FEATURED, "TAG",
            UnitFields.STAR_RATING, "NUMERIC", "SORTABLE",
            UnitFields.AVERAGE_RATING, "NUMERIC", "SORTABLE",
            
            UnitFields.ADDRESS, "TEXT",
            UnitFields.LOCATION, "GEO", "SORTABLE",
            UnitFields.LATITUDE, "NUMERIC", "SORTABLE",
            UnitFields.LONGITUDE, "NUMERIC", "SORTABLE",
            
            UnitFields.MAX_CAPACITY, "NUMERIC", "SORTABLE",
            UnitFields.ADULTS_CAPACITY, "NUMERIC", "SORTABLE",
            UnitFields.CHILDREN_CAPACITY, "NUMERIC", "SORTABLE",
            
            UnitFields.BASE_PRICE, "NUMERIC",
            UnitFields.CURRENCY, "TAG",
            
            UnitFields.AMENITY_IDS, "TAG", "SEPARATOR", ",",
            UnitFields.AMENITY_NAMES, "TEXT",
            UnitFields.SERVICE_IDS, "TAG", "SEPARATOR", ",",
            UnitFields.SERVICE_NAMES, "TEXT",
            
            UnitFields.VIEW_COUNT, "NUMERIC", "SORTABLE",
            UnitFields.BOOKING_COUNT, "NUMERIC", "SORTABLE",
            UnitFields.INDEXED_AT, "NUMERIC", "SORTABLE",
            
            UnitFields.SEARCH_KEYWORDS, "TEXT", "WEIGHT", "1.0"
        };

        foreach (var field in dynamicFields ?? Enumerable.Empty<DynamicSchemaField>())
        {
            var normalizedFieldName = NormalizeDynamicFieldName(field.FieldName);
            if (string.IsNullOrWhiteSpace(normalizedFieldName))
            {
                continue;
            }

            if (field.IsNumeric)
            {
                command.Add(GetDynamicNumericField(normalizedFieldName));
                command.Add("NUMERIC");
                command.Add("SORTABLE");
                continue;
            }

            command.Add(GetDynamicTextField(normalizedFieldName));
            command.Add("TAG");
            command.Add("SEPARATOR");
            command.Add(",");
        }

        return command.ToArray();
    }
    
    #endregion
    
    #region === Schedule Periods Index (جدول الوحدات اليومي) ===
    
    /// <summary>
    /// حقل SCHEDULE_INDEX.
    /// SCHEDULE_INDEX field.
    /// </summary>
    public const string SCHEDULE_INDEX = "idx:periods:schedule";
    /// <summary>
    /// حقل SCHEDULE_PREFIX.
    /// SCHEDULE_PREFIX field.
    /// </summary>
    public const string SCHEDULE_PREFIX = "period:schedule:";
    
    /// <summary>
    /// حقول مستند جدول اليوم للوحدة
    /// </summary>
    public static class SchedulePeriodFields
    {
        /// <summary>معرف الجدول اليومي</summary>
        public const string SCHEDULE_ID = "scheduleId";
        
        /// <summary>معرف الوحدة المرتبطة</summary>
        public const string UNIT_ID = "unitId";
        
        /// <summary>معرف العقار (للفلترة السريعة)</summary>
        public const string PROPERTY_ID = "propertyId";
        
        /// <summary>timestamp التاريخ اليومي (NUMERIC للبحث بالنطاق)</summary>
        public const string DATE_TS = "dateTs";
        
        /// <summary>حالة اليوم: Available / Blocked / Booked</summary>
        public const string STATUS = "status";
        
        /// <summary>السعر لهذا اليوم (اختياري)</summary>
        public const string PRICE = "price";
        
        /// <summary>العملة (اختياري)</summary>
        public const string CURRENCY = "currency";
        
        /// <summary>معرف الحجز (اختياري)</summary>
        public const string BOOKING_ID = "bookingId";
        
        /// <summary>نوع التسعير (اختياري)</summary>
        public const string PRICE_TYPE = "priceType";
        
        /// <summary>مستوى التسعير (اختياري)</summary>
        public const string PRICING_TIER = "pricingTier";
        
        /// <summary>السبب أو ملاحظات (اختياري)</summary>
        public const string REASON = "reason";
    }
    
    /// <summary>
    /// دالة BuildSchedulePeriodIndexSchema.
    /// BuildSchedulePeriodIndexSchema method.
    /// </summary>
    public static string[] BuildSchedulePeriodIndexSchema()
    {
        return new[]
        {
            "FT.CREATE", SCHEDULE_INDEX,
            "ON", "HASH",
            "PREFIX", "1", SCHEDULE_PREFIX,
            "SCHEMA",
            
            SchedulePeriodFields.SCHEDULE_ID, "TAG",
            SchedulePeriodFields.UNIT_ID, "TAG", "SORTABLE",
            SchedulePeriodFields.PROPERTY_ID, "TAG",
            SchedulePeriodFields.DATE_TS, "NUMERIC", "SORTABLE",
            SchedulePeriodFields.STATUS, "TAG",
            SchedulePeriodFields.PRICE, "NUMERIC", "SORTABLE",
            SchedulePeriodFields.CURRENCY, "TAG",
            SchedulePeriodFields.BOOKING_ID, "TAG",
            SchedulePeriodFields.PRICE_TYPE, "TAG",
            SchedulePeriodFields.PRICING_TIER, "TAG",
            SchedulePeriodFields.REASON, "TEXT"
        };
    }
    
    #endregion
    
    #region === Helper Methods ===
    
    /// <summary>
    /// الحصول على اسم حقل ديناميكي نصي
    /// </summary>
    public static string GetDynamicTextField(string fieldName) 
        => $"{UnitFields.DYNAMIC_FIELD_PREFIX}{NormalizeDynamicFieldName(fieldName)}";
    
    /// <summary>
    /// الحصول على اسم حقل ديناميكي رقمي
    /// </summary>
    public static string GetDynamicNumericField(string fieldName) 
        => $"{UnitFields.DYNAMIC_NUMERIC_PREFIX}{NormalizeDynamicFieldName(fieldName)}";

    public static bool IsNumericDynamicFieldType(string? fieldTypeId)
    {
        if (string.IsNullOrWhiteSpace(fieldTypeId))
        {
            return false;
        }

        var normalized = fieldTypeId.Trim().ToLowerInvariant();
        return normalized is "number" or "numeric" or "decimal" or "float" or "double" or "integer" or "int";
    }

    public static string NormalizeDynamicFieldName(string fieldName)
        => string.IsNullOrWhiteSpace(fieldName) ? string.Empty : fieldName.Trim().ToLowerInvariant();
    
    /// <summary>
    /// بناء مفتاح وحدة
    /// </summary>
    public static string GetUnitKey(Guid unitId) => $"{UNITS_PREFIX}{unitId}";
    
    /// <summary>
    /// بناء مفتاح جدول يومي
    /// </summary>
    public static string GetSchedulePeriodKey(Guid scheduleId) => $"{SCHEDULE_PREFIX}{scheduleId}";
    
    /// <summary>
    /// حذف جميع الفهارس
    /// </summary>
    public static string[][] GetDropAllIndexesCommands(bool deleteDocuments = false)
    {
        var suffix = deleteDocuments ? new[] { "DD" } : Array.Empty<string>();
        
        return new[]
        {
            new[] { "FT.DROPINDEX", UNITS_INDEX }.Concat(suffix).ToArray(),
            new[] { "FT.DROPINDEX", SCHEDULE_INDEX }.Concat(suffix).ToArray()
        };
    }
    
    #endregion
}
