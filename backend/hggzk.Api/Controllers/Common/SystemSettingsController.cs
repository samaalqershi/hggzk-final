using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Contracts.Services.Configuration;
using YemenBooking.Application.Contracts.Services.Currency;

namespace YemenBooking.Api.Controllers.Common
{
    /// <summary>
    /// إعدادات النظام والعملات والمدن.
    /// System, currency, and city settings.
    /// </summary>
    [Route("api/common/system-settings")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class SystemSettingsController : ControllerBase
    {
        /// <summary>
        /// خدمة إعدادات النظام.
        /// System settings service.
        /// </summary>
        private readonly ISystemSettingsService _settingsService;
        /// <summary>
        /// خدمة إعدادات العملات.
        /// Currency settings service.
        /// </summary>
        private readonly ICurrencySettingsService _currencySettingsService;
        /// <summary>
        /// خدمة إعدادات المدن.
        /// City settings service.
        /// </summary>
        private readonly ICitySettingsService _citySettingsService;

        /// <summary>
        /// ينشئ متحكم إعدادات النظام مع خدماته المعتمدة.
        /// Creates the system settings controller with its dependencies.
        /// </summary>
        public SystemSettingsController(ISystemSettingsService settingsService, ICurrencySettingsService currencySettingsService, ICitySettingsService citySettingsService)
        {
            _settingsService = settingsService;
            _currencySettingsService = currencySettingsService;
            _citySettingsService = citySettingsService;
        }

        /// <summary>
        /// يعيد إعدادات النظام.
        /// Returns system settings.
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<ResultDto<Dictionary<string, string>>>> GetSettingsAsync(CancellationToken cancellationToken)
        {
            var settings = await _settingsService.GetSettingsAsync(cancellationToken);
            return Ok(ResultDto<Dictionary<string, string>>.Succeeded(settings));
        }

        /// <summary>
        /// يعيد قائمة العملات.
        /// Returns the currency list.
        /// </summary>
        [AllowAnonymous]
        [HttpGet("currencies")]
        public async Task<ActionResult<ResultDto<List<CurrencyDto>>>> GetCurrenciesAsync(CancellationToken cancellationToken)
        {
            var currencies = await _currencySettingsService.GetCurrenciesAsync(cancellationToken);
            return Ok(ResultDto<List<CurrencyDto>>.Succeeded(currencies));
        }

        /// <summary>
        /// يعيد قائمة المدن.
        /// Returns the city list.
        /// </summary>
        [AllowAnonymous]
        [HttpGet("cities")]
        public async Task<ActionResult<ResultDto<List<CityDto>>>> GetCitiesAsync(CancellationToken cancellationToken)
        {
            var cities = await _citySettingsService.GetCitiesAsync(cancellationToken);
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
    }
} 
