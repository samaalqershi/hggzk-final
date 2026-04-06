namespace YemenBooking.Infrastructure.Settings
{
    /// <summary>
    /// إعدادات خدمة تحديد الموقع الجغرافي
    /// Geolocation service settings
    /// </summary>
    public class GeolocationSettings
    {
        /// <summary>
        /// Enables server-side Google-based travel metrics for nearby places.
        /// يفعّل احتساب المسافة والمدة من Google على مستوى الخادم للأماكن القريبة.
        /// </summary>
        public bool EnableGoogleDistanceMatrix { get; set; } = false;

        /// <summary>
        /// Google Distance Matrix endpoint used by the backend.
        /// رابط Google Distance Matrix المستخدم من الباك اند.
        /// </summary>
        public string GoogleDistanceMatrixApiUrl { get; set; } =
            "https://maps.googleapis.com/maps/api/distancematrix/json";

        /// <summary>
        /// Server API key used for Google Maps platform requests.
        /// مفتاح الخادم المستخدم لطلبات Google Maps Platform.
        /// </summary>
        public string GoogleMapsApiKey { get; set; } = "";

        /// <summary>
        /// عنوان API للترميز الجغرافي
        /// Geocoding API base URL
        /// </summary>
        public string GeocodingApiUrl { get; set; } = "https://nominatim.openstreetmap.org";

        /// <summary>
        /// عنوان API لخدمات المنطقة الزمنية
        /// Timezone API base URL
        /// </summary>
        public string TimezoneApiUrl { get; set; } = "http://api.timezonedb.com/v2.1/get-time-zone";

        /// <summary>
        /// مفتاح API (اختياري)
        /// API key (optional)
        /// </summary>
        public string ApiKey { get; set; } = "";
    }
} 
