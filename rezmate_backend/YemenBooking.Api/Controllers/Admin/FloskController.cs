using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Infrastructure.Services;
using YemenBooking.Application.Infrastructure.Services.Wallets;

namespace YemenBooking.Api.Controllers.Admin
{
    [ApiController]
    [Route("api/admin/flosk")]
    [Authorize(Roles = "Admin")]
    public class FloskController : ControllerBase
    {
        private readonly IFloskWalletService _floskWalletService;
        private readonly ISystemSettingsService _systemSettingsService;

        public FloskController(IFloskWalletService floskWalletService, ISystemSettingsService systemSettingsService)
        {
            _floskWalletService = floskWalletService;
            _systemSettingsService = systemSettingsService;
        }

        public class FloskVerifyKeyDto
        {
            public long RequestId { get; set; }
            public string Otp { get; set; } = string.Empty;
        }

        [HttpPost("request-key")]
        public async Task<ActionResult<ResultDto<object>>> RequestKeyAsync(CancellationToken cancellationToken)
        {
            var response = await _floskWalletService.RequestKeyAsync(cancellationToken);
            return Ok(ResultDto<object>.Ok(response));
        }

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
