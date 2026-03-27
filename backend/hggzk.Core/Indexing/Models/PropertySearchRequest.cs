using MessagePack;

namespace YemenBooking.Core.Indexing.Models
{
    /// <summary>
    /// طلب البحث في الفهرس
    /// </summary>
    [MessagePackObject]
    public class PropertySearchRequest
    {
        /// <summary>
        /// خاصية SearchText.
        /// SearchText property.
        /// </summary>
        [Key(0)] public string? SearchText { get; set; }
        /// <summary>
        /// خاصية City.
        /// City property.
        /// </summary>
        [Key(1)] public string? City { get; set; }
        /// <summary>
        /// خاصية PropertyType.
        /// PropertyType property.
        /// </summary>
        [Key(2)] public string? PropertyType { get; set; }
        /// <summary>
        /// خاصية MinPrice.
        /// MinPrice property.
        /// </summary>
        [Key(3)] public decimal? MinPrice { get; set; }
        /// <summary>
        /// خاصية MaxPrice.
        /// MaxPrice property.
        /// </summary>
        [Key(4)] public decimal? MaxPrice { get; set; }
        /// <summary>
        /// خاصية PreferredCurrency.
        /// PreferredCurrency property.
        /// </summary>
        [Key(5)] public string? PreferredCurrency { get; set; }
        /// <summary>
        /// خاصية MinRating.
        /// MinRating property.
        /// </summary>
        [Key(6)] public decimal? MinRating { get; set; }
        /// <summary>
        /// خاصية CheckIn.
        /// CheckIn property.
        /// </summary>
        [Key(7)] public DateTime? CheckIn { get; set; }
        /// <summary>
        /// خاصية CheckOut.
        /// CheckOut property.
        /// </summary>
        [Key(8)] public DateTime? CheckOut { get; set; }
        /// <summary>
        /// خاصية GuestsCount.
        /// GuestsCount property.
        /// </summary>
        [Key(9)] public int? GuestsCount { get; set; }
        /// <summary>
        /// خاصية RequiredAmenityIds.
        /// RequiredAmenityIds property.
        /// </summary>
        [Key(10)] public List<string>? RequiredAmenityIds { get; set; }
        /// <summary>
        /// خاصية ServiceIds.
        /// ServiceIds property.
        /// </summary>
        [Key(11)] public List<string>? ServiceIds { get; set; }
        /// <summary>
        /// خاصية UnitTypeId.
        /// UnitTypeId property.
        /// </summary>
        [Key(12)] public string? UnitTypeId { get; set; }
        /// <summary>
        /// خاصية DynamicFieldFilters.
        /// DynamicFieldFilters property.
        /// </summary>
        [Key(13)] public Dictionary<string, string>? DynamicFieldFilters { get; set; }
        /// <summary>
        /// خاصية Latitude.
        /// Latitude property.
        /// </summary>
        [Key(14)] public double? Latitude { get; set; }
        /// <summary>
        /// خاصية Longitude.
        /// Longitude property.
        /// </summary>
        [Key(15)] public double? Longitude { get; set; }
        /// <summary>
        /// خاصية RadiusKm.
        /// RadiusKm property.
        /// </summary>
        [Key(16)] public int? RadiusKm { get; set; }
        /// <summary>
        /// خاصية SortBy.
        /// SortBy property.
        /// </summary>
        [Key(17)] public string? SortBy { get; set; }
        /// <summary>
        /// خاصية PageNumber.
        /// PageNumber property.
        /// </summary>
        [Key(18)] public int PageNumber { get; set; } = 1;
        /// <summary>
        /// خاصية PageSize.
        /// PageSize property.
        /// </summary>
        [Key(19)] public int PageSize { get; set; } = 20;
        /// <summary>
        /// خاصية MinAdults.
        /// MinAdults property.
        /// </summary>
        [Key(20)] public int? MinAdults { get; set; }
        /// <summary>
        /// خاصية MinChildren.
        /// MinChildren property.
        /// </summary>
        [Key(21)] public int? MinChildren { get; set; }
    }

    /// <summary>
    /// نتيجة البحث في الفهرس
    /// </summary>
    [MessagePackObject]
    public class PropertySearchResult
    {
        /// <summary>
        /// خاصية Properties.
        /// Properties property.
        /// </summary>
        [Key(0)] public List<PropertySearchItem> Properties { get; set; } = new();
        /// <summary>
        /// خاصية TotalCount.
        /// TotalCount property.
        /// </summary>
        [Key(1)] public int TotalCount { get; set; }
        /// <summary>
        /// خاصية PageNumber.
        /// PageNumber property.
        /// </summary>
        [Key(2)] public int PageNumber { get; set; }
        /// <summary>
        /// خاصية PageSize.
        /// PageSize property.
        /// </summary>
        [Key(3)] public int PageSize { get; set; }
        /// <summary>
        /// خاصية TotalPages.
        /// TotalPages property.
        /// </summary>
        [Key(4)] public int TotalPages { get; set; }
    }

    /// <summary>
    /// عنصر نتيجة البحث
    /// </summary>
    [MessagePackObject]
    public class PropertySearchItem
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        [Key(0)] public string Id { get; set; } = string.Empty;
        /// <summary>
        /// خاصية Name.
        /// Name property.
        /// </summary>
        [Key(1)] public string Name { get; set; } = string.Empty;
        /// <summary>
        /// خاصية City.
        /// City property.
        /// </summary>
        [Key(2)] public string City { get; set; } = string.Empty;
        /// <summary>
        /// خاصية PropertyType.
        /// PropertyType property.
        /// </summary>
        [Key(3)] public string PropertyType { get; set; } = string.Empty;
        /// <summary>
        /// خاصية MinPrice.
        /// MinPrice property.
        /// </summary>
        [Key(4)] public decimal MinPrice { get; set; }
        /// <summary>
        /// خاصية Currency.
        /// Currency property.
        /// </summary>
        [Key(5)] public string Currency { get; set; } = "YER";
        /// <summary>
        /// خاصية AverageRating.
        /// AverageRating property.
        /// </summary>
        [Key(6)] public decimal AverageRating { get; set; }
        /// <summary>
        /// خاصية StarRating.
        /// StarRating property.
        /// </summary>
        [Key(7)] public int StarRating { get; set; }
        /// <summary>
        /// خاصية ImageUrls.
        /// ImageUrls property.
        /// </summary>
        [Key(8)] public List<string> ImageUrls { get; set; } = new();
        /// <summary>
        /// خاصية MaxCapacity.
        /// MaxCapacity property.
        /// </summary>
        [Key(9)] public int MaxCapacity { get; set; }
        /// <summary>
        /// خاصية UnitsCount.
        /// UnitsCount property.
        /// </summary>
        [Key(10)] public int UnitsCount { get; set; }
        /// <summary>
        /// خاصية DynamicFields.
        /// DynamicFields property.
        /// </summary>
        [Key(11)] public Dictionary<string, string> DynamicFields { get; set; } = new();
        /// <summary>
        /// خاصية Latitude.
        /// Latitude property.
        /// </summary>
        [Key(12)] public double Latitude { get; set; }
        /// <summary>
        /// خاصية Longitude.
        /// Longitude property.
        /// </summary>
        [Key(13)] public double Longitude { get; set; }
    }
}