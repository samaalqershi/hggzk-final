using System;
using System.Collections.Generic;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.SearchAndFilters.DTOs {
    /// <summary>
    /// Represents the available filter sets returned to the search experience.
    /// يمثل مجموعات الفلاتر المتاحة التي تُعاد إلى تجربة البحث.
    /// </summary>
    public class SearchFiltersDto
    {
        /// <summary>
        /// Gets or sets the available city filters.
        /// يحصل أو يعيّن فلاتر المدن المتاحة.
        /// </summary>
        public List<CityFilterDto> Cities { get; set; } = new();

        /// <summary>
        /// Gets or sets the available property-type filters.
        /// يحصل أو يعيّن فلاتر أنواع العقارات المتاحة.
        /// </summary>
        public List<PropertyTypeFilterDto> PropertyTypes { get; set; } = new();

        /// <summary>
        /// Gets or sets the available price range.
        /// يحصل أو يعيّن نطاق الأسعار المتاح.
        /// </summary>
        public PriceRangeDto PriceRange { get; set; } = new();

        /// <summary>
        /// Gets or sets the available amenity filters.
        /// يحصل أو يعيّن فلاتر وسائل الراحة المتاحة.
        /// </summary>
        public List<AmenityFilterDto> Amenities { get; set; } = new();

        /// <summary>
        /// Gets or sets the available star-rating values.
        /// يحصل أو يعيّن قيم تقييم النجوم المتاحة.
        /// </summary>
        public List<int> StarRatings { get; set; } = new();

        /// <summary>
        /// Gets or sets live star-rating counters.
        /// يحصل أو يعيّن عدادات تقييم النجوم الحية.
        /// </summary>
        public List<StarRatingFilterDto> StarRatingOptions { get; set; } = new();

        /// <summary>
        /// Gets or sets the available city names as a flat string list.
        /// يحصل أو يعيّن أسماء المدن المتاحة كقائمة نصية مبسطة.
        /// </summary>
        public List<string> AvailableCities { get; set; } = new();

        /// <summary>
        /// Gets or sets the maximum guest capacity across the result set.
        /// يحصل أو يعيّن الحد الأقصى للسعة الاستيعابية ضمن النتائج.
        /// </summary>
        public int MaxGuestCapacity { get; set; } = 0;

        /// <summary>
        /// Gets or sets the available unit-type filters.
        /// يحصل أو يعيّن فلاتر أنواع الوحدات المتاحة.
        /// </summary>
        public List<UnitTypeFilterDto> UnitTypes { get; set; } = new();

        /// <summary>
        /// Gets or sets the available distance range in kilometers.
        /// يحصل أو يعيّن نطاق المسافة المتاح بالكيلومتر.
        /// </summary>
        public DistanceRangeDto DistanceRange { get; set; } = new();

        /// <summary>
        /// Gets or sets the supported currencies.
        /// يحصل أو يعيّن العملات المدعومة.
        /// </summary>
        public List<string> SupportedCurrencies { get; set; } = new();

        /// <summary>
        /// Gets or sets the available service filters.
        /// يحصل أو يعيّن فلاتر الخدمات المتاحة.
        /// </summary>
        public List<ServiceFilterDto> Services { get; set; } = new();

        /// <summary>
        /// Gets or sets the available dynamic field values used in filtering.
        /// يحصل أو يعيّن قيم الحقول الديناميكية المتاحة للاستخدام في الفلترة.
        /// </summary>
        public List<DynamicFieldValueFilterDto> DynamicFieldValues { get; set; } = new();
    }

    /// <summary>
    /// Represents a single city filter option.
    /// يمثل خيار فلترة واحدًا للمدينة.
    /// </summary>
    public class CityFilterDto
    {
        /// <summary>
        /// Gets or sets the city identifier.
        /// يحصل أو يعيّن معرف المدينة.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// Gets or sets the city name.
        /// يحصل أو يعيّن اسم المدينة.
        /// </summary>
        public string Name { get; set; } = string.Empty;
        public string? NameEn { get; set; }

        /// <summary>
        /// Gets or sets the count of available properties in the city.
        /// يحصل أو يعيّن عدد العقارات المتاحة في المدينة.
        /// </summary>
        public int PropertiesCount { get; set; }
    }

    /// <summary>
    /// Represents a single property-type filter option.
    /// يمثل خيار فلترة واحدًا لنوع العقار.
    /// </summary>
    public class PropertyTypeFilterDto
    {
        /// <summary>
        /// Gets or sets the property-type identifier.
        /// يحصل أو يعيّن معرف نوع العقار.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// Gets or sets the property-type name.
        /// يحصل أو يعيّن اسم نوع العقار.
        /// </summary>
        public string Name { get; set; } = string.Empty;
        public string? NameEn { get; set; }

        /// <summary>
        /// Gets or sets the count of available properties for the type.
        /// يحصل أو يعيّن عدد العقارات المتاحة لهذا النوع.
        /// </summary>
        public int PropertiesCount { get; set; }
    }



    /// <summary>
    /// Represents a single amenity filter option.
    /// يمثل خيار فلترة واحدًا لوسيلة الراحة.
    /// </summary>
    public class AmenityFilterDto
    {
        /// <summary>
        /// Gets or sets the amenity identifier.
        /// يحصل أو يعيّن معرف وسيلة الراحة.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// Gets or sets the amenity name.
        /// يحصل أو يعيّن اسم وسيلة الراحة.
        /// </summary>
        public string Name { get; set; } = string.Empty;
        public string? NameEn { get; set; }

        /// <summary>
        /// Gets or sets the amenity category.
        /// يحصل أو يعيّن فئة وسيلة الراحة.
        /// </summary>
        public string Category { get; set; } = string.Empty;
        public string? CategoryEn { get; set; }

        /// <summary>
        /// Gets or sets the count of properties that expose this amenity.
        /// يحصل أو يعيّن عدد العقارات التي توفر وسيلة الراحة هذه.
        /// </summary>
        public int PropertiesCount { get; set; }

        /// <summary>
        /// Gets or sets the amenity icon reference.
        /// يحصل أو يعيّن مرجع أيقونة وسيلة الراحة.
        /// </summary>
        public string Icon { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the property-type identifiers that support the amenity.
        /// يحصل أو يعيّن معرّفات أنواع العقارات التي تدعم وسيلة الراحة.
        /// </summary>
        public List<Guid> PropertyTypeIds { get; set; } = new();
    }

    /// <summary>
    /// Represents a single unit-type filter option.
    /// يمثل خيار فلترة واحدًا لنوع الوحدة.
    /// </summary>
    public class UnitTypeFilterDto
    {
        /// <summary>
        /// Gets or sets the unit-type identifier.
        /// يحصل أو يعيّن معرف نوع الوحدة.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// Gets or sets the unit-type name.
        /// يحصل أو يعيّن اسم نوع الوحدة.
        /// </summary>
        public string Name { get; set; } = string.Empty;
        public string? NameEn { get; set; }

        /// <summary>
        /// Gets or sets the parent property-type identifier.
        /// يحصل أو يعيّن معرف نوع العقار الأب.
        /// </summary>
        public Guid PropertyTypeId { get; set; }

        /// <summary>
        /// Gets or sets the count of available units for the type.
        /// يحصل أو يعيّن عدد الوحدات المتاحة لهذا النوع.
        /// </summary>
        public int UnitsCount { get; set; }

        /// <summary>
        /// Gets or sets whether the unit type requires adults.
        /// يحصل أو يعيّن ما إذا كان نوع الوحدة يتطلب وجود بالغين.
        /// </summary>
        public bool IsHasAdults { get; set; } = false;

        /// <summary>
        /// Gets or sets whether the unit type supports or requires children.
        /// يحصل أو يعيّن ما إذا كان نوع الوحدة يدعم أو يتطلب وجود أطفال.
        /// </summary>
        public bool IsHasChildren { get; set; } = false;

        /// <summary>
        /// Gets or sets whether the unit type is intended for multi-day stays.
        /// يحصل أو يعيّن ما إذا كان نوع الوحدة مخصصًا للإقامات متعددة الأيام.
        /// </summary>
        public bool IsMultiDays { get; set; } = false;

        /// <summary>
        /// Gets or sets whether the unit type requires hour selection.
        /// يحصل أو يعيّن ما إذا كان نوع الوحدة يتطلب تحديد الساعة.
        /// </summary>
        public bool IsRequiredToDetermineTheHour { get; set; } = false;
    }

    /// <summary>
    /// Represents the available distance range for geographic filters.
    /// يمثل نطاق المسافة المتاح لفلاتر البحث الجغرافي.
    /// </summary>
    public class DistanceRangeDto
    {
        /// <summary>
        /// Gets or sets the minimum distance in kilometers.
        /// يحصل أو يعيّن أقل مسافة بالكيلومتر.
        /// </summary>
        public double MinDistance { get; set; } = 0;

        /// <summary>
        /// Gets or sets the maximum distance in kilometers.
        /// يحصل أو يعيّن أقصى مسافة بالكيلومتر.
        /// </summary>
        public double MaxDistance { get; set; } = 50;
    }

    /// <summary>
    /// Represents a single service filter option.
    /// يمثل خيار فلترة واحدًا للخدمة.
    /// </summary>
    public class ServiceFilterDto
    {
        /// <summary>
        /// Gets or sets the service identifier.
        /// يحصل أو يعيّن معرف الخدمة.
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// Gets or sets the service name.
        /// يحصل أو يعيّن اسم الخدمة.
        /// </summary>
        public string Name { get; set; } = string.Empty;
        public string? NameEn { get; set; }

        /// <summary>
        /// Gets or sets the count of properties that provide the service.
        /// يحصل أو يعيّن عدد العقارات التي توفر هذه الخدمة.
        /// </summary>
        public int PropertiesCount { get; set; }

        /// <summary>
        /// Gets or sets the service icon reference.
        /// يحصل أو يعيّن مرجع أيقونة الخدمة.
        /// </summary>
        public string Icon { get; set; } = string.Empty;
    }

    /// <summary>
    /// Represents a filter option for a dynamic field value.
    /// يمثل خيار فلترة لقيمة حقل ديناميكي.
    /// </summary>
    public class DynamicFieldValueFilterDto
    {
        /// <summary>
        /// Gets or sets the dynamic field name.
        /// يحصل أو يعيّن اسم الحقل الديناميكي.
        /// </summary>
        public string FieldName { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the dynamic field display name.
        /// يحصل أو يعيّن الاسم المعروض للحقل الديناميكي.
        /// </summary>
        public string DisplayName { get; set; } = string.Empty;
        public string? DisplayNameEn { get; set; }

        /// <summary>
        /// Gets or sets the selectable value.
        /// يحصل أو يعيّن القيمة القابلة للاختيار.
        /// </summary>
        public string Value { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the number of matching units or properties.
        /// يحصل أو يعيّن عدد الوحدات أو العقارات المطابقة.
        /// </summary>
        public int Count { get; set; }
    }

    /// <summary>
    /// Represents a star-rating facet option with its live property counter.
    /// يمثل خيار تقييم النجوم مع عداد العقارات الحي الخاص به.
    /// </summary>
    public class StarRatingFilterDto
    {
        /// <summary>
        /// Gets or sets the star value.
        /// يحصل أو يعيّن قيمة النجوم.
        /// </summary>
        public int Value { get; set; }

        /// <summary>
        /// Gets or sets the number of matching properties.
        /// يحصل أو يعيّن عدد العقارات المطابقة.
        /// </summary>
        public int PropertiesCount { get; set; }
    }
}
