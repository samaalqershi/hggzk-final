using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Common.Models;
using System;
using System.Linq;
using System.Globalization;
using YemenBooking.Application.Contracts.Services.Configuration;
using YemenBooking.Application.Contracts.Services.Currency;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يدير إعدادات النظام العامة وإعدادات العملات والمدن وعمولة المنصة.
    /// Manages global system settings, currencies, cities, and platform commission.
    /// </summary>
    [Route("api/admin/system-settings")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class SystemSettingsController : ControllerBase
    {
        /// <summary>
        /// المفتاح المخزن لإعداد عمولة المنصة الافتراضية.
        /// Storage key for the default platform commission setting.
        /// </summary>
        private const string DefaultCommissionRateKey = "Commission:DefaultRate";
        /// <summary>
        /// القيمة الافتراضية لعمولة المنصة عند عدم وجود إعداد مخزن.
        /// Default platform commission value when no stored setting exists.
        /// </summary>
        private const decimal DefaultCommissionRate = 5m;
        /// <summary>
        /// خدمة إدارة إعدادات النظام.
        /// Service for managing system settings.
        /// </summary>
        private readonly ISystemSettingsService _settingsService;
        /// <summary>
        /// خدمة إدارة إعدادات العملات.
        /// Service for managing currency settings.
        /// </summary>
        private readonly ICurrencySettingsService _currencySettingsService;
        /// <summary>
        /// خدمة إدارة إعدادات المدن.
        /// Service for managing city settings.
        /// </summary>
        private readonly ICitySettingsService _citySettingsService;
        /// <summary>
        /// يحسب نسبة التغير بين قيمتين.
        /// Calculates the percentage change between two values.
        /// </summary>
        private static double? Trend(double current, double previous)
        {
            if (previous == 0)
                return current == 0 ? 0.0 : (double?)null;
            var pct = ((current - previous) / previous) * 100.0;
            return Math.Round(pct, 1);
        }

        /// <summary>
        /// ينشئ المتحكم مع حقن خدمات الإعدادات.
        /// Creates the controller with the settings services injected.
        /// </summary>
        public SystemSettingsController(ISystemSettingsService settingsService, ICurrencySettingsService currencySettingsService, ICitySettingsService citySettingsService)
        {
            _settingsService = settingsService;
            _currencySettingsService = currencySettingsService;
            _citySettingsService = citySettingsService;
        }

        /// <summary>
        /// يعرض إعدادات النظام الحالية.
        /// Returns the current system settings.
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ResultDto<Dictionary<string, string>>>> GetSettingsAsync(CancellationToken cancellationToken)
        {
            var settings = await _settingsService.GetSettingsAsync(cancellationToken);
            return Ok(ResultDto<Dictionary<string, string>>.Succeeded(settings));
        }

        /// <summary>
        /// يحفظ إعدادات النظام أو يحدّثها.
        /// Saves or updates the system settings.
        /// </summary>
        [HttpPut]
        public async Task<ActionResult<ResultDto<bool>>> SaveSettingsAsync([FromBody] Dictionary<string, string> settings, CancellationToken cancellationToken)
        {
            await _settingsService.SaveSettingsAsync(settings, cancellationToken);
            return Ok(ResultDto<bool>.Succeeded(true));
        }

        /// <summary>
        /// يعرض إعداد عمولة المنصة الافتراضية.
        /// Returns the default platform commission setting.
        /// </summary>
        [HttpGet("commission")]
        public async Task<ActionResult<ResultDto<CommissionSettingsDto>>> GetCommissionSettingsAsync(CancellationToken cancellationToken)
        {
            var settings = await _settingsService.GetSettingsAsync(cancellationToken);

            var parsedRate = DefaultCommissionRate;
            if (settings.TryGetValue(DefaultCommissionRateKey, out var rawRate))
            {
                var normalized = (rawRate ?? string.Empty).Trim().Replace(",", ".", StringComparison.Ordinal);
                if (decimal.TryParse(normalized, NumberStyles.Number, CultureInfo.InvariantCulture, out var rate) &&
                    rate >= 0m &&
                    rate <= 100m)
                {
                    parsedRate = Math.Round(rate, 2);
                }
            }

            return Ok(ResultDto<CommissionSettingsDto>.Succeeded(new CommissionSettingsDto
            {
                DefaultRate = parsedRate
            }));
        }

        /// <summary>
        /// يحفظ إعداد عمولة المنصة الافتراضية.
        /// Saves the default platform commission setting.
        /// </summary>
        [HttpPut("commission")]
        public async Task<ActionResult<ResultDto<bool>>> SaveCommissionSettingsAsync([FromBody] UpdateCommissionSettingsRequest request, CancellationToken cancellationToken)
        {
            if (request.DefaultRate < 0m || request.DefaultRate > 100m)
            {
                return BadRequest(ResultDto<bool>.Failed("نسبة العمولة يجب أن تكون بين 0 و 100"));
            }

            var settings = await _settingsService.GetSettingsAsync(cancellationToken);
            settings[DefaultCommissionRateKey] = Math.Round(request.DefaultRate, 2).ToString("0.##", CultureInfo.InvariantCulture);

            await _settingsService.SaveSettingsAsync(settings, cancellationToken);

            return Ok(ResultDto<bool>.Succeeded(true, "تم حفظ نسبة العمولة بنجاح"));
        }

        /// <summary>
        /// يعرض قائمة العملات المتاحة.
        /// Returns the list of available currencies.
        /// </summary>
        [AllowAnonymous]
        [HttpGet("currencies")]
        public async Task<ActionResult<ResultDto<List<Application.Common.Models.CurrencyDto>>>> GetCurrenciesAsync(CancellationToken cancellationToken)
        {
            var currencies = await _currencySettingsService.GetCurrenciesAsync(cancellationToken);
            return Ok(ResultDto<List<Application.Common.Models.CurrencyDto>>.Succeeded(currencies));
        }

        /// <summary>
        /// يعرض إحصاءات العملات مع اتجاهات اختيارية لنطاق زمني.
        /// Returns currency statistics with optional time-range trends.
        /// </summary>
        [HttpGet("currencies/stats")]
        public async Task<ActionResult<ResultDto<CurrencyStatsDto>>> GetCurrenciesStatsAsync([FromQuery] DateTime? startDate = null, [FromQuery] DateTime? endDate = null, CancellationToken cancellationToken = default)
        {
            var list = await _currencySettingsService.GetCurrenciesAsync(cancellationToken);
            var total = list.Count;
            var def = list.FirstOrDefault(c => c.IsDefault)?.Code;
            var withRate = list.Count(c => c.ExchangeRate.HasValue);
            var avgRate = withRate > 0 ? list.Where(c => c.ExchangeRate.HasValue).Average(c => (double)c.ExchangeRate!.Value) : 0.0;
            DateTime? lastUpdated = null;
            foreach (var c in list)
            {
                if (c.LastUpdated.HasValue)
                {
                    if (!lastUpdated.HasValue || c.LastUpdated.Value > lastUpdated.Value)
                        lastUpdated = c.LastUpdated.Value;
                }
            }

            var dto = new CurrencyStatsDto
            {
                TotalCurrencies = total,
                DefaultCurrencyCode = def,
                CurrenciesWithExchangeRate = withRate,
                AverageExchangeRate = Math.Round(avgRate, 4),
                LastUpdated = lastUpdated,
                UpdatesCount = 0,
                UpdatesTrendPct = null,
                AverageUpdatedRate = null,
                AverageUpdatedRateTrendPct = null
            };

            if (startDate.HasValue && endDate.HasValue && endDate > startDate)
            {
                var currentStart = startDate.Value;
                var currentEnd = endDate.Value;
                var period = currentEnd - currentStart;
                var previousStart = currentStart - period;
                var previousEnd = currentStart;

                var currentUpdated = list.Where(c => c.LastUpdated.HasValue && c.LastUpdated.Value >= currentStart && c.LastUpdated.Value <= currentEnd).ToList();
                var previousUpdated = list.Where(c => c.LastUpdated.HasValue && c.LastUpdated.Value >= previousStart && c.LastUpdated.Value <= previousEnd).ToList();

                var currUpdates = currentUpdated.Count;
                var prevUpdates = previousUpdated.Count;
                var currAvgUpdatedRate = currentUpdated.Count > 0 ? currentUpdated.Where(c => c.ExchangeRate.HasValue).Average(c => (double)c.ExchangeRate!.Value) : 0.0;
                var prevAvgUpdatedRate = previousUpdated.Count > 0 ? previousUpdated.Where(c => c.ExchangeRate.HasValue).Average(c => (double)c.ExchangeRate!.Value) : 0.0;

                dto.UpdatesCount = currUpdates;
                dto.UpdatesTrendPct = Trend(currUpdates, prevUpdates);
                dto.AverageUpdatedRate = Math.Round(currAvgUpdatedRate, 4);
                dto.AverageUpdatedRateTrendPct = Trend(currAvgUpdatedRate, prevAvgUpdatedRate);
            }

            return Ok(ResultDto<CurrencyStatsDto>.Succeeded(dto));
        }

        /// <summary>
        /// يعرض إحصاءات المدن مع اتجاهات اختيارية لنطاق زمني.
        /// Returns city statistics with optional time-range trends.
        /// </summary>
        [HttpGet("cities/stats")]
        public async Task<ActionResult<ResultDto<CityStatsDto>>> GetCitiesStatsAsync([FromQuery] DateTime? startDate = null, [FromQuery] DateTime? endDate = null, CancellationToken cancellationToken = default)
        {
            var cities = await _citySettingsService.GetCitiesAsync(cancellationToken);
            var total = cities.Count;
            var active = cities.Count(c => c.IsActive != false);
            var totalImages = cities.Sum(c => c.Images?.Count ?? 0);
            var byCountry = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            foreach (var c in cities)
            {
                var country = c.Country ?? string.Empty;
                byCountry[country] = byCountry.TryGetValue(country, out var v) ? v + 1 : 1;
            }

            var dto = new CityStatsDto
            {
                TotalCities = total,
                ActiveCities = active,
                ByCountry = byCountry,
                TotalImages = totalImages,
                ImagesTrend = null,
                UpdatesCount = 0,
                UpdatesTrendPct = null
            };

            // Trend based on cities added/changed in the period: since CityDto has no LastUpdated, we approximate by change in count per period (using settings snapshot).
            if (startDate.HasValue && endDate.HasValue && endDate > startDate)
            {
                // Without historical audit here, expose trend as null when no baseline is available
                dto.UpdatesCount = 0;
                dto.UpdatesTrendPct = null;
            }

            return Ok(ResultDto<CityStatsDto>.Succeeded(dto));
        }

        /// <summary>
        /// يعرض قائمة المدن المتاحة.
        /// Returns the list of available cities.
        /// </summary>
        [AllowAnonymous]
        [HttpGet("cities")]
        public async Task<ActionResult<ResultDto<List<CityDto>>>> GetCitiesAsync(CancellationToken cancellationToken)
        {
            var cities = await _citySettingsService.GetCitiesAsync(cancellationToken);
            // Ensure image URLs are absolute for frontend cards, leverage same behavior as ImagesController
            var baseUrl = $"{Request.Scheme}://{Request.Host}";
            foreach (var c in cities)
            {
                for (int i = 0; i < c.Images.Count; i++)
                {
                    var url = c.Images[i] ?? string.Empty;
                    if (!string.IsNullOrWhiteSpace(url) && !url.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                    {
                        c.Images[i] = baseUrl + (url.StartsWith("/") ? url : "/" + url);
                    }
                }
            }
            return Ok(ResultDto<List<CityDto>>.Succeeded(cities));
        }

        /// <summary>
        /// يحفظ قائمة العملات أو يحدّثها.
        /// Saves or updates the currency list.
        /// </summary>
        [HttpPut("currencies")]
        public async Task<ActionResult<ResultDto<bool>>> SaveCurrenciesAsync([FromBody] List<CurrencyDto> currencies, CancellationToken cancellationToken)
        {
            await _currencySettingsService.SaveCurrenciesAsync(currencies, cancellationToken);
            return Ok(ResultDto<bool>.Succeeded(true));
        }

        /// <summary>
        /// يحذف عملة نهائيًا بعد التحقق من الارتباطات.
        /// Permanently deletes a currency after verifying references.
        /// </summary>
        [HttpDelete("currencies/{code}")]
        public async Task<ActionResult<ResultDto>> DeleteCurrencyAsync([FromRoute] string code, CancellationToken cancellationToken)
        {
            try
            {
                await _currencySettingsService.DeleteCurrencyAsync(code, cancellationToken);
                return Ok(ResultDto.Ok("تم حذف العملة بنجاح"));
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(ResultDto.Failure(ex.Message, errorCode: "CURRENCY_DELETE_CONFLICT"));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ResultDto.Failure(ex.Message, errorCode: "INVALID_CURRENCY_CODE"));
            }
        }

        /// <summary>
        /// يحفظ قائمة المدن أو يحدّثها.
        /// Saves or updates the city list.
        /// </summary>
        [HttpPut("cities")]
        public async Task<ActionResult<ResultDto<bool>>> SaveCitiesAsync([FromBody] List<CityDto> cities, CancellationToken cancellationToken)
        {
            // Normalize URLs to server-relative paths to keep DB clean
            var origin = $"{Request.Scheme}://{Request.Host}";
            foreach (var c in cities)
            {
                for (int i = 0; i < c.Images.Count; i++)
                {
                    var url = c.Images[i] ?? string.Empty;
                    if (!string.IsNullOrWhiteSpace(url) && url.StartsWith(origin, StringComparison.OrdinalIgnoreCase))
                    {
                        c.Images[i] = url.Substring(origin.Length);
                    }
                }
            }
            await _citySettingsService.SaveCitiesAsync(cities, cancellationToken);
            return Ok(ResultDto<bool>.Succeeded(true));
        }

        /// <summary>
        /// يحذف مدينة بعد التحقق من الارتباطات التابعة لها.
        /// Deletes a city after validating dependent references.
        /// </summary>
        [HttpDelete("cities/{name}")]
        public async Task<ActionResult<ResultDto>> DeleteCityAsync([FromRoute] string name, CancellationToken cancellationToken)
        {
            try
            {
                await _citySettingsService.DeleteCityAsync(name, cancellationToken);
                return Ok(ResultDto.Ok("تم حذف المدينة بنجاح"));
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(ResultDto.Failure(ex.Message, errorCode: "CITY_DELETE_CONFLICT"));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ResultDto.Failure(ex.Message, errorCode: "INVALID_CITY_NAME"));
            }
        }
    }

    /// <summary>
    /// يمثل إعداد عمولة المنصة الافتراضية المعروض للواجهة.
    /// Represents the default platform commission setting exposed to the UI.
    /// </summary>
    public class CommissionSettingsDto
    {
        /// <summary>
        /// معدل العمولة الافتراضي.
        /// Default commission rate.
        /// </summary>
        public decimal DefaultRate { get; set; }
    }

    /// <summary>
    /// طلب تحديث إعداد عمولة المنصة الافتراضية.
    /// Request payload for updating the default platform commission.
    /// </summary>
    public class UpdateCommissionSettingsRequest
    {
        /// <summary>
        /// معدل العمولة المطلوب حفظه.
        /// Commission rate to persist.
        /// </summary>
        public decimal DefaultRate { get; set; }
    }
}
