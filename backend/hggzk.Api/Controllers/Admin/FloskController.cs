using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Contracts.Services.Configuration;
using YemenBooking.Application.Contracts.Services.Wallets;

namespace YemenBooking.Api.Controllers.Admin
{
    /// <summary>
    /// يوفّر عمليات إدارة ربط Flosk من لوحة الإدارة.
    /// Provides admin operations for Flosk wallet integration.
    /// </summary>
    [ApiController]
    [Route("api/admin/flosk")]
    [Authorize(Roles = "Admin")]
    public class FloskController : ControllerBase
    {
    /// <summary>
    /// خدمة محافظ Flosk.
    /// Flosk wallet service.
    /// </summary>
        private readonly IFloskWalletService _floskWalletService;
    /// <summary>
    /// خدمة إعدادات النظام.
    /// System settings service.
    /// </summary>
        private readonly ISystemSettingsService _systemSettingsService;

    /// <summary>
    /// يهيئ المتحكم بخدمات Flosk وإعدادات النظام.
    /// Initializes the controller with Flosk and system settings services.
    /// </summary>
        public FloskController(IFloskWalletService floskWalletService, ISystemSettingsService systemSettingsService)
        {
            _floskWalletService = floskWalletService;
            _systemSettingsService = systemSettingsService;
        }

    /// <summary>
    /// بيانات التحقق من مفتاح Flosk.
    /// Payload used to verify a Flosk key.
    /// </summary>
    public class FloskVerifyKeyDto
    {
        /// <summary>
        /// معرّف الطلب الصادر من Flosk.
        /// The request identifier returned by Flosk.
        /// </summary>
        public long RequestId { get; set; }
        /// <summary>
        /// رمز التحقق لمرة واحدة.
        /// The one-time verification code.
        /// </summary>
        public string Otp { get; set; } = string.Empty;
    }

        /// <summary>
        /// يطلب مفتاح Flosk جديدًا.
        /// Requests a new Flosk key.
        /// </summary>
        [HttpPost("request-key")]
        public async Task<ActionResult<ResultDto<object>>> RequestKeyAsync(CancellationToken cancellationToken)
        {
            var response = await _floskWalletService.RequestKeyAsync(cancellationToken);
            return Ok(ResultDto<object>.Ok(response));
        }

        /// <summary>
        /// يتحقق من المفتاح ويحدث إعدادات الربط.
        /// Verifies the key and updates integration settings.
        /// </summary>
        [HttpPost("verify-key")]
        public async Task<ActionResult<ResultDto<object>>> VerifyKeyAsync([FromBody] FloskVerifyKeyDto dto, CancellationToken cancellationToken)
        {
            var response = await _floskWalletService.VerifyKeyAsync(dto.RequestId, dto.Otp, cancellationToken);

            var wallets = response.AccountDetail?.Account?.Wallets ?? new List<YemenBooking.Core.Wallets.Flosk.FloskWallet>();

            var currencyToWalletId = new Dictionary<string, long>(StringComparer.OrdinalIgnoreCase);
            foreach (var w in wallets)
            {
                var code = (w.Currency?.Symbol?.En ?? string.Empty).Trim().ToUpperInvariant();
                if (code.Length == 3 && w.Id > 0)
                {
                    currencyToWalletId[code] = w.Id;
                }
            }

            var settings = await _systemSettingsService.GetSettingsAsync(cancellationToken);

            var keysToRemove = settings.Keys
                .Where(k => k.StartsWith("Flosk:SourceWalletIds:", StringComparison.OrdinalIgnoreCase))
                .ToList();
            foreach (var k in keysToRemove)
            {
                settings.Remove(k);
            }

            settings["Flosk:Key"] = response.Key;

            foreach (var kv in currencyToWalletId)
            {
                settings[$"Flosk:SourceWalletIds:{kv.Key}"] = kv.Value.ToString();
            }

            if (!settings.ContainsKey("Flosk:SourceWalletId") && currencyToWalletId.TryGetValue("YER", out var yerWalletId))
            {
                settings["Flosk:SourceWalletId"] = yerWalletId.ToString();
            }

            await _systemSettingsService.SaveSettingsAsync(settings, cancellationToken);
            await _floskWalletService.InvalidateMerchantKeyCacheAsync(cancellationToken);

            return Ok(ResultDto<object>.Ok(new
            {
                Currencies = currencyToWalletId.ToDictionary(k => k.Key, v => v.Value)
            }));
        }
    }
}
