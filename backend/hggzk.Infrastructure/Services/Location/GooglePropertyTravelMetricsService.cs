using System.Globalization;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Contracts.Services.Location;
using YemenBooking.Infrastructure.Settings;

namespace YemenBooking.Infrastructure.Services.Location;

/// <summary>
/// Uses Google Distance Matrix to calculate nearby-place travel metrics.
/// يستخدم Google Distance Matrix لحساب قياسات التنقل للأماكن القريبة.
/// </summary>
public sealed class GooglePropertyTravelMetricsService : IPropertyTravelMetricsService
{
    private readonly HttpClient _httpClient;
    private readonly GeolocationSettings _settings;
    private readonly ILogger<GooglePropertyTravelMetricsService> _logger;

    public GooglePropertyTravelMetricsService(
        HttpClient httpClient,
        IOptions<GeolocationSettings> options,
        ILogger<GooglePropertyTravelMetricsService> logger)
    {
        _httpClient = httpClient;
        _settings = options.Value;
        _logger = logger;
    }

    public async Task<ResultDto<PropertyTravelMetrics>> CalculateAsync(
        decimal originLatitude,
        decimal originLongitude,
        decimal destinationLatitude,
        decimal destinationLongitude,
        CancellationToken cancellationToken = default)
    {
        if (!_settings.EnableGoogleDistanceMatrix)
        {
            return ResultDto<PropertyTravelMetrics>.Failed(
                "خدمة Google لحساب المسافة غير مفعلة في إعدادات الخادم");
        }

        if (string.IsNullOrWhiteSpace(_settings.GoogleMapsApiKey))
        {
            return ResultDto<PropertyTravelMetrics>.Failed(
                "مفتاح Google Maps API غير موجود في إعدادات الخادم");
        }

        try
        {
            var walkingResult = await QueryDistanceMatrixAsync(
                originLatitude,
                originLongitude,
                destinationLatitude,
                destinationLongitude,
                "walking",
                cancellationToken);

            var drivingResult = await QueryDistanceMatrixAsync(
                originLatitude,
                originLongitude,
                destinationLatitude,
                destinationLongitude,
                "driving",
                cancellationToken);

            if (!walkingResult.Success && !drivingResult.Success)
            {
                var message = walkingResult.Message ??
                              drivingResult.Message ??
                              "تعذر احتساب المسافة والمدة من Google";
                return ResultDto<PropertyTravelMetrics>.Failed(message);
            }

            var distance = walkingResult.Data?.DistanceInMeters
                ?? drivingResult.Data?.DistanceInMeters
                ?? 0;

            if (distance <= 0)
            {
                return ResultDto<PropertyTravelMetrics>.Failed(
                    "تعذر استلام مسافة صحيحة من خدمة Google");
            }

            return ResultDto<PropertyTravelMetrics>.Succeeded(
                new PropertyTravelMetrics
                {
                    DistanceInMeters = distance,
                    WalkingMinutes = walkingResult.Data?.WalkingMinutes,
                    DrivingMinutes = drivingResult.Data?.DrivingMinutes,
                },
                "تم احتساب المسافة والمدة تلقائيًا");
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to calculate Google travel metrics between property ({OriginLat}, {OriginLng}) and place ({DestLat}, {DestLng})",
                originLatitude,
                originLongitude,
                destinationLatitude,
                destinationLongitude);

            return ResultDto<PropertyTravelMetrics>.Failed(
                "تعذر الاتصال بخدمة Google لحساب المسافة والمدة");
        }
    }

    private async Task<ResultDto<PropertyTravelMetrics>> QueryDistanceMatrixAsync(
        decimal originLatitude,
        decimal originLongitude,
        decimal destinationLatitude,
        decimal destinationLongitude,
        string mode,
        CancellationToken cancellationToken)
    {
        var url =
            $"{_settings.GoogleDistanceMatrixApiUrl}?origins={FormatCoordinate(originLatitude)},{FormatCoordinate(originLongitude)}" +
            $"&destinations={FormatCoordinate(destinationLatitude)},{FormatCoordinate(destinationLongitude)}" +
            $"&mode={mode}&language=ar&region=ye&key={Uri.EscapeDataString(_settings.GoogleMapsApiKey)}";

        using var response = await _httpClient.GetAsync(url, cancellationToken);
        var payload = await response.Content.ReadAsStringAsync(cancellationToken);

        if (!response.IsSuccessStatusCode)
        {
            _logger.LogWarning(
                "Google Distance Matrix returned HTTP {StatusCode} for mode {Mode}. Payload: {Payload}",
                (int)response.StatusCode,
                mode,
                payload);

            return ResultDto<PropertyTravelMetrics>.Failed(
                $"فشل طلب Google ({(int)response.StatusCode}) عند احتساب {TranslateMode(mode)}");
        }

        var model = JsonSerializer.Deserialize<GoogleDistanceMatrixResponse>(
            payload,
            new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

        if (!string.Equals(model?.Status, "OK", StringComparison.OrdinalIgnoreCase))
        {
            _logger.LogWarning(
                "Google Distance Matrix returned status {Status} for mode {Mode}. Payload: {Payload}",
                model?.Status,
                mode,
                payload);

            return ResultDto<PropertyTravelMetrics>.Failed(
                $"تعذر احتساب {TranslateMode(mode)} من Google: {model?.Status ?? "UNKNOWN"}");
        }

        var element = model?.Rows?.FirstOrDefault()?.Elements?.FirstOrDefault();
        if (element == null ||
            !string.Equals(element.Status, "OK", StringComparison.OrdinalIgnoreCase) ||
            element.Distance == null ||
            element.Duration == null)
        {
            return ResultDto<PropertyTravelMetrics>.Failed(
                $"لم تُرجع Google مسارًا صالحًا لوضع {TranslateMode(mode)}");
        }

        var durationMinutes = (int)Math.Ceiling(element.Duration.Value / 60d);

        return ResultDto<PropertyTravelMetrics>.Succeeded(
            new PropertyTravelMetrics
            {
                DistanceInMeters = element.Distance.Value,
                WalkingMinutes = string.Equals(mode, "walking", StringComparison.OrdinalIgnoreCase)
                    ? durationMinutes
                    : null,
                DrivingMinutes = string.Equals(mode, "driving", StringComparison.OrdinalIgnoreCase)
                    ? durationMinutes
                    : null,
            });
    }

    private static string FormatCoordinate(decimal value)
        => value.ToString(CultureInfo.InvariantCulture);

    private static string TranslateMode(string mode)
        => string.Equals(mode, "walking", StringComparison.OrdinalIgnoreCase)
            ? "المشي"
            : "القيادة";

    private sealed class GoogleDistanceMatrixResponse
    {
        public string? Status { get; set; }
        public List<GoogleDistanceMatrixRow>? Rows { get; set; }
    }

    private sealed class GoogleDistanceMatrixRow
    {
        public List<GoogleDistanceMatrixElement>? Elements { get; set; }
    }

    private sealed class GoogleDistanceMatrixElement
    {
        public string? Status { get; set; }
        public GoogleValueWrapper? Distance { get; set; }
        public GoogleValueWrapper? Duration { get; set; }
    }

    private sealed class GoogleValueWrapper
    {
        public int Value { get; set; }
    }
}
