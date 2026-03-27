using System;
using MediatR;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using YemenBooking.Application.Features.Payments;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Payments.DTOs;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Enums;
using YemenBooking.Application.Features;
using YemenBooking.Application.Features.Payments.DTOs;
using YemenBooking.Application.Infrastructure.Services;
using System.Collections.Generic;
using System.Linq;

namespace YemenBooking.Application.Features.Payments.Queries.GetPaymentMethods;

/// <summary>
/// معالج استعلام الحصول على طرق الدفع المتاحة للعميل
/// Handler for client get payment methods query
/// </summary>
public class ClientGetPaymentMethodsQueryHandler : IRequestHandler<ClientGetPaymentMethodsQuery, ResultDto<List<ClientPaymentMethodDto>>>
{
    private readonly IUserRepository _userRepository;
    private readonly IConfiguration _configuration;
    private readonly ISystemSettingsService _systemSettingsService;
    private readonly ILogger<ClientGetPaymentMethodsQueryHandler> _logger;

    private static bool IsValueSet(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return false;
        }

        var v = value.Trim();

        return v.IndexOf("<", StringComparison.Ordinal) < 0
               && v.IndexOf("YOUR", StringComparison.OrdinalIgnoreCase) < 0
               && v.IndexOf("PUT-", StringComparison.OrdinalIgnoreCase) < 0
               && v.IndexOf("PLACEHOLDER", StringComparison.OrdinalIgnoreCase) < 0;
    }

    private bool IsJwaliConfigured()
    {
        return IsValueSet(_configuration["Jwali:BaseUrl"])
               && IsValueSet(_configuration["Jwali:AgentWallet"])
               && IsValueSet(_configuration["Jwali:Password"])
               && IsValueSet(_configuration["Jwali:UserID"])
               && IsValueSet(_configuration["Jwali:UserPwd"]);
    }

    private bool IsSabaCashConfigured(Dictionary<string, string>? systemSettings)
    {
        var baseUrl = GetSystemSetting(systemSettings, "SabaCash:BaseUrl") ?? _configuration["SabaCash:BaseUrl"];
        var username = GetSystemSetting(systemSettings, "SabaCash:Username") ?? _configuration["SabaCash:Username"];
        var password = GetSystemSetting(systemSettings, "SabaCash:Password") ?? _configuration["SabaCash:Password"];
        var terminalId = GetSystemSetting(systemSettings, "SabaCash:TerminalId") ?? _configuration["SabaCash:TerminalId"];

        return IsValueSet(baseUrl)
               && IsValueSet(username)
               && IsValueSet(password)
               && IsValueSet(terminalId);
    }

    private string? GetSystemSetting(Dictionary<string, string>? systemSettings, string key)
    {
        if (systemSettings == null)
        {
            return null;
        }

        return systemSettings.TryGetValue(key, out var value) ? value : null;
    }

    private bool IsFloskConfigured(Dictionary<string, string>? systemSettings)
    {
        var key = GetSystemSetting(systemSettings, "Flosk:Key") ?? _configuration["Flosk:Key"];

        var hasAnyPerCurrency = GetFloskSupportedCurrencies(systemSettings).Count > 0;

        var sourceWalletFallback =
            GetSystemSetting(systemSettings, "Flosk:SourceWalletId") ?? _configuration["Flosk:SourceWalletId"];

        var hasFallback = IsValueSet(sourceWalletFallback);

        return IsValueSet(_configuration["Flosk:BaseUrl"])
               && IsValueSet(key)
               && (hasAnyPerCurrency || hasFallback);
    }

    private List<string> GetFloskSupportedCurrencies(Dictionary<string, string>? systemSettings)
    {
        var supported = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        if (systemSettings != null)
        {
            foreach (var kv in systemSettings)
            {
                const string prefix = "Flosk:SourceWalletIds:";
                if (kv.Key.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)
                    && long.TryParse(kv.Value, out var id)
                    && id > 0)
                {
                    var code = kv.Key.Substring(prefix.Length).Trim().ToUpperInvariant();
                    if (code.Length == 3)
                    {
                        supported.Add(code);
                    }
                }
            }
        }

        var section = _configuration.GetSection("Flosk:SourceWalletIds");
        foreach (var child in section.GetChildren())
        {
            if (long.TryParse(child.Value, out var id) && id > 0)
            {
                var code = (child.Key ?? string.Empty).Trim().ToUpperInvariant();
                if (code.Length == 3)
                {
                    supported.Add(code);
                }
            }
        }

        var fallback = GetSystemSetting(systemSettings, "Flosk:SourceWalletId") ?? _configuration["Flosk:SourceWalletId"];
        if (long.TryParse(fallback, out var fallbackId) && fallbackId > 0)
        {
            supported.Add("YER");
        }

        return supported.OrderBy(x => x).ToList();
    }

    /// <summary>
    /// منشئ معالج استعلام طرق الدفع للعميل
    /// Constructor for client get payment methods query handler
    /// </summary>
    /// <param name="userRepository">مستودع المستخدمين</param>
    /// <param name="configuration">إعدادات التطبيق</param>
    /// <param name="logger">مسجل الأحداث</param>
    public ClientGetPaymentMethodsQueryHandler(
        IUserRepository userRepository,
        IConfiguration configuration,
        ISystemSettingsService systemSettingsService,
        ILogger<ClientGetPaymentMethodsQueryHandler> logger)
    {
        _userRepository = userRepository;
        _configuration = configuration;
        _systemSettingsService = systemSettingsService;
        _logger = logger;
    }

    /// <summary>
    /// معالجة استعلام الحصول على طرق الدفع المتاحة للعميل
    /// Handle client get payment methods query
    /// </summary>
    /// <param name="request">طلب الاستعلام</param>
    /// <param name="cancellationToken">رمز الإلغاء</param>
    /// <returns>قائمة طرق الدفع المتاحة</returns>
    public async Task<ResultDto<List<ClientPaymentMethodDto>>> Handle(ClientGetPaymentMethodsQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء استعلام طرق الدفع المتاحة للعميل. معرف المستخدم: {UserId}, البلد: {Country}, العملة: {Currency}, المبلغ: {Amount}", 
                request.UserId, request.Country, request.Currency, request.Amount);

            Dictionary<string, string>? systemSettings = null;
            try
            {
                systemSettings = await _systemSettingsService.GetSettingsAsync(cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "تعذر قراءة systemsettings.json أثناء جلب طرق الدفع. سيتم الاعتماد على appsettings فقط.");
            }

            // التحقق من صحة البيانات المدخلة
            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            // تحديد البلد إذا لم يتم تحديده
            string userCountry = request.Country ?? "YE"; // اليمن كبلد افتراضي
            
            // إذا تم تحديد معرف المستخدم، جلب بيانات المستخدم
            if (request.UserId.HasValue)
            {
                var user = await _userRepository.GetByIdAsync(request.UserId.Value, cancellationToken);
                if (user != null)
                {
                    userCountry = "YE"; // افتراضي اليمن (سيتم تحديثه لاحقاً)
                }
            }
            
            var countryCode = "YE"; // افتراضي اليمن

            // إرجاع جميع طرق الدفع المتاحة من PaymentMethodEnum
            var availablePaymentMethods = GetAllPaymentMethods(request.Currency, userCountry, request.Amount, systemSettings);

            // ترتيب طرق الدفع
            availablePaymentMethods = availablePaymentMethods
                .OrderByDescending(pm => pm.IsRecommended)
                .ThenBy(pm => pm.DisplayOrder)
                .ThenBy(pm => pm.Name)
                .ToList();

            _logger.LogInformation("تم العثور على {Count} طريقة دفع متاحة", availablePaymentMethods.Count);

            return ResultDto<List<ClientPaymentMethodDto>>.Ok(
                availablePaymentMethods, 
                $"تم العثور على {availablePaymentMethods.Count} طريقة دفع متاحة"
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء الحصول على طرق الدفع المتاحة للعميل");
            return ResultDto<List<ClientPaymentMethodDto>>.Failed(
                $"حدث خطأ أثناء الحصول على طرق الدفع: {ex.Message}", 
                "GET_PAYMENT_METHODS_ERROR"
            );
        }
    }

    /// <summary>
    /// التحقق من صحة البيانات المدخلة
    /// Validate request data
    /// </summary>
    /// <param name="request">طلب الاستعلام</param>
    /// <returns>نتيجة التحقق</returns>
    private ResultDto<List<ClientPaymentMethodDto>> ValidateRequest(ClientGetPaymentMethodsQuery request)
    {
        if (string.IsNullOrWhiteSpace(request.Currency))
        {
            _logger.LogWarning("العملة مطلوبة");
            return ResultDto<List<ClientPaymentMethodDto>>.Failed("العملة مطلوبة", "CURRENCY_REQUIRED");
        }

        if (request.Currency.Length != 3)
        {
            _logger.LogWarning("رمز العملة يجب أن يكون 3 أحرف");
            return ResultDto<List<ClientPaymentMethodDto>>.Failed("رمز العملة يجب أن يكون 3 أحرف", "INVALID_CURRENCY_CODE");
        }

        if (request.Amount.HasValue && request.Amount.Value < 0)
        {
            _logger.LogWarning("المبلغ لا يمكن أن يكون سالباً");
            return ResultDto<List<ClientPaymentMethodDto>>.Failed("المبلغ لا يمكن أن يكون سالباً", "INVALID_AMOUNT");
        }

        if (request.Amount.HasValue && request.Amount.Value > 10000000) // 10 مليون
        {
            _logger.LogWarning("المبلغ كبير جداً");
            return ResultDto<List<ClientPaymentMethodDto>>.Failed("المبلغ كبير جداً", "AMOUNT_TOO_LARGE");
        }

        return ResultDto<List<ClientPaymentMethodDto>>.Ok(null);
    }

    /// <summary>
    /// الحصول على طرق الدفع الفعلية المدعومة حالياً (محفظة جوالي + محفظة سبأ كاش)
    /// يمكن توسيعها لاحقاً بإضافة طرق أخرى حقيقية
    /// </summary>
    private List<ClientPaymentMethodDto> GetAllPaymentMethods(string currency, string country, decimal? amount, Dictionary<string, string>? systemSettings)
    {
        var methods = new List<ClientPaymentMethodDto>();

        var requestedCurrency = string.IsNullOrWhiteSpace(currency) ? "YER" : currency.Trim().ToUpperInvariant();

        var jwaliCurrencies = new List<string> { "YER", "SAR", "USD" };
        if (IsJwaliConfigured() && jwaliCurrencies.Contains(requestedCurrency))
        {
            methods.Add(new ClientPaymentMethodDto
            {
                Id = ((int)PaymentMethodEnum.JwaliWallet).ToString(),
                Name = GetPaymentMethodName(PaymentMethodEnum.JwaliWallet),
                Description = GetPaymentMethodDescription(PaymentMethodEnum.JwaliWallet),
                IconUrl = GetPaymentMethodIcon(PaymentMethodEnum.JwaliWallet),
                LogoUrl = "/images/payment-jwali.png",
                IsAvailable = true,
                TransactionFee = 0,
                FeePercentage = GetPaymentMethodFeePercentage(PaymentMethodEnum.JwaliWallet),
                MinAmount = 0,
                MaxAmount = 1000000,
                SupportedCurrencies = jwaliCurrencies,
                SupportedCountries = new List<string> { "YE" },
                ProcessingTime = "فوري",
                Type = PaymentMethodEnum.JwaliWallet.ToString(),
                RequiresVerification = false,
                SupportsRefunds = true,
                DisplayOrder = (int)PaymentMethodEnum.JwaliWallet,
                IsRecommended = true,
                WarningMessage = null
            });
        }

        if (IsSabaCashConfigured(systemSettings) && string.Equals(requestedCurrency, "YER", StringComparison.OrdinalIgnoreCase))
        {
            methods.Add(new ClientPaymentMethodDto
            {
                Id = ((int)PaymentMethodEnum.SabaCashWallet).ToString(),
                Name = "محفظة سبأ كاش",
                Description = "الدفع عبر محفظة سبأ كاش الإلكترونية (عبر YottaPay)",
                IconUrl = "/images/payment-sabacash.png",
                LogoUrl = "/images/payment-sabacash.png",
                IsAvailable = true,
                TransactionFee = 0,
                FeePercentage = 0,
                MinAmount = 0,
                MaxAmount = 1000000,
                SupportedCurrencies = new List<string> { "YER" },
                SupportedCountries = new List<string> { "YE" },
                ProcessingTime = "فوري",
                Type = PaymentMethodEnum.SabaCashWallet.ToString(),
                RequiresVerification = true,
                SupportsRefunds = true,
                DisplayOrder = (int)PaymentMethodEnum.SabaCashWallet,
                IsRecommended = false,
                WarningMessage = null
            });
        }
        else
        {
            _logger.LogWarning("SabaCash payment method is not configured; hiding it from client payment methods.");
        }

        var floskCurrencies = GetFloskSupportedCurrencies(systemSettings);
        if (IsFloskConfigured(systemSettings) && floskCurrencies.Contains(requestedCurrency))
        {
            methods.Add(new ClientPaymentMethodDto
            {
                Id = ((int)PaymentMethodEnum.FloskWallet).ToString(),
                Name = GetPaymentMethodName(PaymentMethodEnum.FloskWallet),
                Description = GetPaymentMethodDescription(PaymentMethodEnum.FloskWallet),
                IconUrl = GetPaymentMethodIcon(PaymentMethodEnum.FloskWallet),
                LogoUrl = "/images/payment-flosk.png",
                IsAvailable = true,
                TransactionFee = 0,
                FeePercentage = GetPaymentMethodFeePercentage(PaymentMethodEnum.FloskWallet),
                MinAmount = 0,
                MaxAmount = 1000000,
                SupportedCurrencies = floskCurrencies,
                SupportedCountries = new List<string> { "YE" },
                ProcessingTime = "فوري",
                Type = PaymentMethodEnum.FloskWallet.ToString(),
                RequiresVerification = true,
                SupportsRefunds = true,
                DisplayOrder = (int)PaymentMethodEnum.FloskWallet,
                IsRecommended = false,
                WarningMessage = null
            });
        }
        else
        {
            _logger.LogWarning("Flosk payment method is not configured; hiding it from client payment methods.");
        }

        return methods;
    }
    
    private string GetPaymentMethodName(PaymentMethodEnum method)
    {
        return method switch
        {
            PaymentMethodEnum.JwaliWallet => "محفظة جوالي",
            PaymentMethodEnum.CashWallet => "محفظة كاش",
            PaymentMethodEnum.OneCashWallet => "محفظة ون كاش",
            PaymentMethodEnum.FloskWallet => "محفظة فلوس",
            PaymentMethodEnum.JaibWallet => "محفظة جيب",
            PaymentMethodEnum.Cash => "نقدي",
            PaymentMethodEnum.Paypal => "PayPal",
            PaymentMethodEnum.CreditCard => "بطاقة ائتمان",
            _ => method.ToString()
        };
    }
    
    private string GetPaymentMethodDescription(PaymentMethodEnum method)
    {
        return method switch
        {
            PaymentMethodEnum.JwaliWallet => "الدفع عبر محفظة جوالي الإلكترونية",
            PaymentMethodEnum.CashWallet => "الدفع عبر محفظة كاش الإلكترونية",
            PaymentMethodEnum.OneCashWallet => "الدفع عبر محفظة ون كاش",
            PaymentMethodEnum.FloskWallet => "الدفع عبر محفظة فلوس",
            PaymentMethodEnum.JaibWallet => "الدفع عبر محفظة جيب",
            PaymentMethodEnum.Cash => "الدفع نقداً عند الوصول",
            PaymentMethodEnum.Paypal => "الدفع عبر PayPal",
            PaymentMethodEnum.CreditCard => "الدفع بالبطاقة الائتمانية",
            _ => "طريقة دفع"
        };
    }
    
    private string GetPaymentMethodIcon(PaymentMethodEnum method)
    {
        return method switch
        {
            PaymentMethodEnum.JwaliWallet => "/images/payment-jwali.png",
            PaymentMethodEnum.CashWallet => "/images/payment-cash.png",
            PaymentMethodEnum.OneCashWallet => "/images/payment-onecash.png",
            PaymentMethodEnum.FloskWallet => "/images/payment-flosk.png",
            PaymentMethodEnum.JaibWallet => "/images/payment-jaib.png",
            PaymentMethodEnum.Cash => "/images/payment-cash.png",
            PaymentMethodEnum.Paypal => "/images/payment-paypal.png",
            PaymentMethodEnum.CreditCard => "/images/payment-card.png",
            _ => "/images/payment-default.png"
        };
    }
    
    private decimal GetPaymentMethodFeePercentage(PaymentMethodEnum method)
    {
        return method switch
        {
            PaymentMethodEnum.CreditCard => 2.5m,
            PaymentMethodEnum.Paypal => 3.0m,
            _ => 0
        };
    }



    /// <summary>
    /// الحصول على طرق دفع افتراضية
    /// Get default payment methods
    /// </summary>
    /// <param name="currency">العملة</param>
    /// <param name="country">البلد</param>
    /// <returns>قائمة طرق الدفع الافتراضية</returns>
    private List<ClientPaymentMethodDto> GetDefaultPaymentMethods(string currency, string country)
    {
        var defaultMethods = new List<ClientPaymentMethodDto>();

        // طرق دفع افتراضية للسوق اليمني
        if (country == "YE")
        {
            defaultMethods.AddRange(new[]
            {
                new ClientPaymentMethodDto
                {
                    Id = "cash_on_delivery",
                    Name = "الدفع عند الاستلام",
                    Description = "ادفع نقداً عند وصولك للعقار",
                    Type = "cash",
                    IsAvailable = true,
                    TransactionFee = 0,
                    FeePercentage = 0,
                    MinAmount = 1,
                    MaxAmount = 1000000,
                    SupportedCurrencies = new List<string> { "YER" },
                    SupportedCountries = new List<string> { "YE" },
                    ProcessingTime = "فوري",
                    SupportsRefunds = true,
                    DisplayOrder = 1,
                    IsRecommended = true
                },
                new ClientPaymentMethodDto
                {
                    Id = "bank_transfer",
                    Name = "تحويل بنكي",
                    Description = "حوّل المبلغ إلى حساب العقار مباشرة",
                    Type = "bank_transfer",
                    IsAvailable = true,
                    TransactionFee = 10,
                    FeePercentage = 0,
                    MinAmount = 100,
                    MaxAmount = 5000000,
                    SupportedCurrencies = new List<string> { "YER", "USD", "SAR" },
                    SupportedCountries = new List<string> { "YE", "SA", "AE" },
                    ProcessingTime = "1-3 أيام عمل",
                    SupportsRefunds = true,
                    DisplayOrder = 2
                },
                new ClientPaymentMethodDto
                {
                    Id = "mobile_wallet",
                    Name = "محفظة موبايل",
                    Description = "ادفع باستخدام محفظتك الرقمية",
                    Type = "digital_wallet",
                    IsAvailable = true,
                    TransactionFee = 5,
                    FeePercentage = 1.5m,
                    MinAmount = 10,
                    MaxAmount = 500000,
                    SupportedCurrencies = new List<string> { "YER" },
                    SupportedCountries = new List<string> { "YE" },
                    ProcessingTime = "فوري",
                    SupportsRefunds = true,
                    DisplayOrder = 3
                }
            });
        }

        // إضافة طرق دفع دولية إذا كانت العملة غير يمنية
        if (currency != "YER")
        {
            defaultMethods.Add(new ClientPaymentMethodDto
            {
                Id = "credit_card",
                Name = "بطاقة ائتمانية",
                Description = "ادفع باستخدام بطاقة فيزا أو ماستركارد",
                Type = "credit_card",
                MinAmount = 1,
                MaxAmount = 50000,
                SupportedCurrencies = new List<string> { "USD", "EUR", "SAR", "AED" },
                SupportedCountries = new List<string> { "YE", "SA", "AE", "US", "GB" },
                ProcessingTime = "فوري",
                RequiresVerification = true,
                SupportsRefunds = true,
                IsRecommended = true
            });
        }

        return defaultMethods;
    }
}
