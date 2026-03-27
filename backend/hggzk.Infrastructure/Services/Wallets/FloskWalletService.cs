using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Payments.Services;
using YemenBooking.Application.Contracts.Services.Wallets;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Wallets.Flosk;

namespace YemenBooking.Infrastructure.Services.Wallets
{
    /// <summary>
    /// يمثل خدمة محفظة فلوسك لمسارات المفتاح والدفع والاسترداد.
    /// Represents the Flosk wallet service for key, payment, and refund flows.
    /// </summary>
    public class FloskWalletService : IFloskWalletService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;
        private readonly IMemoryCache _cache;
        private readonly ISystemSettingsService _systemSettingsService;
        private readonly IPaymentRepository _paymentRepository;
        private readonly ILogger<FloskWalletService> _logger;

        private const string TOKEN_CACHE_KEY = "Flosk_MerchantKey";

        private static readonly JsonSerializerOptions JsonOptions = new()
        {
            PropertyNameCaseInsensitive = true
        };

        private string GetRequestKeyPath() => _configuration["Flosk:RequestKeyPath"] ?? "/api/v1/request/key";
        private string GetVerifyKeyPath() => _configuration["Flosk:VerifyKeyPath"] ?? "/api/v1/verify/key";
        private string GetPurchasePath() => _configuration["Flosk:PurchasePath"] ?? "/api/v1/merchant/p2mcl";
        private string GetConfirmPath() => _configuration["Flosk:ConfirmPath"] ?? "/api/v1/merchant/p2mcl/confirm";
        private string GetRefundPath() => _configuration["Flosk:RefundPath"] ?? "/api/v1/merchant/p2mcl/refund";

        private string GetChannel() => _configuration["Flosk:Channel"] ?? "merchant";

        private int GetKeyCacheMinutes() => int.TryParse(_configuration["Flosk:KeyCacheMinutes"], out var minutes)
            ? minutes
            : 120;

        /// <summary>
        /// ينشئ مثيلًا جديدًا من خدمة محفظة فلوسك.
        /// Creates a new instance of the Flosk wallet service.
        /// </summary>
        /// <param name="httpClient">Configured HTTP client. عميل HTTP المهيأ.</param>
        /// <param name="configuration">Application configuration. إعدادات التطبيق.</param>
        /// <param name="cache">In-memory cache. الذاكرة المؤقتة.</param>
        /// <param name="systemSettingsService">System settings service. خدمة إعدادات النظام.</param>
        /// <param name="paymentRepository">Payment repository. مستودع المدفوعات.</param>
        /// <param name="logger">Logger instance. كائن تسجيل الأحداث.</param>
        public FloskWalletService(
            HttpClient httpClient,
            IConfiguration configuration,
            IMemoryCache cache,
            ISystemSettingsService systemSettingsService,
            IPaymentRepository paymentRepository,
            ILogger<FloskWalletService> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _cache = cache;
            _systemSettingsService = systemSettingsService;
            _paymentRepository = paymentRepository;
            _logger = logger;

            var baseUrl = _configuration["Flosk:BaseUrl"];
            if (string.IsNullOrWhiteSpace(baseUrl))
            {
                _logger.LogWarning("لم يتم ضبط قيمة Flosk:BaseUrl في ملف الإعدادات. لن تعمل عمليات محفظة فلوسك بدون هذا الإعداد.");
            }
            else
            {
                if (Uri.TryCreate(baseUrl, UriKind.Absolute, out var uri)
                    && (string.Equals(uri.Scheme, "http", StringComparison.OrdinalIgnoreCase)
                        || string.Equals(uri.Scheme, "https", StringComparison.OrdinalIgnoreCase)))
                {
                    _httpClient.BaseAddress = uri;
                }
                else
                {
                    _logger.LogWarning("قيمة Flosk:BaseUrl غير صالحة: {BaseUrl}. لن تعمل عمليات محفظة فلوسك حتى يتم ضبط BaseUrl بشكل صحيح.", baseUrl);
                }
            }

            if (_httpClient.DefaultRequestHeaders.Contains("x-channel"))
            {
                _httpClient.DefaultRequestHeaders.Remove("x-channel");
            }
            _httpClient.DefaultRequestHeaders.Add("x-channel", GetChannel());

            if (_httpClient.DefaultRequestHeaders.Accept.All(a => a.MediaType != "application/json"))
            {
                _httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            }
        }

        private static string NormalizePhone(string phone)
        {
            if (string.IsNullOrWhiteSpace(phone))
            {
                return string.Empty;
            }

            // Remove every non-numeric character.
            // إزالة كل الأحرف غير الرقمية.
            var digitsOnly = new string(phone.Where(char.IsDigit).ToArray());
            
            if (string.IsNullOrEmpty(digitsOnly))
            {
                return string.Empty;
            }

            // Handle the known phone-number formats.
            // معالجة الحالات المختلفة لتنسيق الرقم.
            // If it starts with 00967 (13 digits).
            // إذا بدأ بـ 00967 (13 رقم).
            if (digitsOnly.StartsWith("00967") && digitsOnly.Length == 13)
            {
                return digitsOnly.Substring(2); // Remove 00 -> 967XXXXXXXXX. إزالة 00.
            }
            
            // If it already starts with 967 (12 digits).
            // إذا بدأ بـ +967 سيصبح 967 (12 رقم).
            if (digitsOnly.StartsWith("967") && digitsOnly.Length == 12)
            {
                return digitsOnly; // Already valid. صحيح.
            }
            
            // If it starts with 0 (10 digits) use the Yemeni format.
            // إذا بدأ بـ 0 (10 أرقام) - تنسيق محلي يمني.
            if (digitsOnly.StartsWith("0") && digitsOnly.Length == 10)
            {
                return "967" + digitsOnly.Substring(1); // Convert to 967XXXXXXXXX. تحويل إلى 967XXXXXXXXX.
            }
            
            // If it is 9 digits without a leading zero.
            // إذا كان 9 أرقام فقط (بدون 0 في البداية).
            if (digitsOnly.Length == 9 && (digitsOnly.StartsWith("7") || digitsOnly.StartsWith("1") || digitsOnly.StartsWith("2") || digitsOnly.StartsWith("3") || digitsOnly.StartsWith("4") || digitsOnly.StartsWith("5")))
            {
                return "967" + digitsOnly; // Convert to 967XXXXXXXXX. تحويل إلى 967XXXXXXXXX.
            }

            // Return the number as-is if no known pattern matches.
            // إرجاع الرقم كما هو إذا لم يتطابق مع أي نمط معروف.
            return digitsOnly;
        }

        private static (string UserMessage, string ErrorCode) ParseFloskError(string responseContent)
        {
            try
            {
                using var doc = JsonDocument.Parse(responseContent);
                var root = doc.RootElement;
                
                var message = root.TryGetProperty("message", out var msgProp) 
                    ? msgProp.GetString() ?? "خطأ غير معروف"
                    : "خطأ غير معروف";
                
                // Determine the error code from the message.
                // تحديد كود الخطأ من الرسالة.
                var errorCode = "UNKNOWN_ERROR";
                var userMessage = message;
                
                // Translate common error messages.
                // ترجمة رسائل الخطأ الشائعة.
                if (message.Contains("Account does not exists", StringComparison.OrdinalIgnoreCase) ||
                    message.Contains("Account does not exist", StringComparison.OrdinalIgnoreCase))
                {
                    errorCode = "ACCOUNT_NOT_FOUND";
                    userMessage = "حساب فلوسك غير موجود لهذا الرقم. يرجى التأكد من أن العميل مسجل في محفظة فلوسك";
                }
                else if (message.Contains("Insufficient balance", StringComparison.OrdinalIgnoreCase) ||
                         message.Contains("رصيد غير كافي", StringComparison.OrdinalIgnoreCase))
                {
                    errorCode = "INSUFFICIENT_BALANCE";
                    userMessage = "رصيد العميل في محفظة فلوسك غير كافٍ لإتمام العملية";
                }
                else if (message.Contains("Invalid OTP", StringComparison.OrdinalIgnoreCase) ||
                         message.Contains("رمز خاطئ", StringComparison.OrdinalIgnoreCase))
                {
                    errorCode = "INVALID_OTP";
                    userMessage = "رمز التحقق غير صحيح. يرجى إدخال الرمز الصحيح المرسل إلى هاتفك";
                }
                else if (message.Contains("OTP expired", StringComparison.OrdinalIgnoreCase) ||
                         message.Contains("انتهت صلاحية", StringComparison.OrdinalIgnoreCase))
                {
                    errorCode = "OTP_EXPIRED";
                    userMessage = "انتهت صلاحية رمز التحقق. يرجى طلب رمز جديد";
                }
                else if (message.Contains("Transaction not found", StringComparison.OrdinalIgnoreCase))
                {
                    errorCode = "TRANSACTION_NOT_FOUND";
                    userMessage = "العملية غير موجودة أو منتهية الصلاحية";
                }
                else if (message.Contains("Already confirmed", StringComparison.OrdinalIgnoreCase) ||
                         message.Contains("مؤكدة مسبقاً", StringComparison.OrdinalIgnoreCase))
                {
                    errorCode = "ALREADY_CONFIRMED";
                    userMessage = "تم تأكيد هذه العملية مسبقاً";
                }
                else if (message.Contains("Already refunded", StringComparison.OrdinalIgnoreCase))
                {
                    errorCode = "ALREADY_REFUNDED";
                    userMessage = "تم استرداد هذه العملية مسبقاً";
                }
                else if (message.Contains("Unauthorized", StringComparison.OrdinalIgnoreCase) ||
                         message.Contains("Invalid token", StringComparison.OrdinalIgnoreCase))
                {
                    errorCode = "UNAUTHORIZED";
                    userMessage = "خطأ في المصادقة مع محفظة فلوسك. يرجى التواصل مع الدعم الفني";
                }
                else if (message.Contains("source_wallet_id", StringComparison.OrdinalIgnoreCase))
                {
                    errorCode = "INVALID_SOURCE_WALLET";
                    userMessage = "خطأ في إعدادات محفظة التاجر. يرجى التواصل مع الدعم الفني";
                }
                else if (message.Contains("Invalid phone", StringComparison.OrdinalIgnoreCase) ||
                         message.Contains("رقم الهاتف", StringComparison.OrdinalIgnoreCase))
                {
                    errorCode = "INVALID_PHONE";
                    userMessage = "رقم الهاتف غير صالح. يرجى التأكد من إدخال رقم صحيح";
                }
                else if (message.Contains("amount", StringComparison.OrdinalIgnoreCase) &&
                         (message.Contains("minimum", StringComparison.OrdinalIgnoreCase) || 
                          message.Contains("الحد الأدنى", StringComparison.OrdinalIgnoreCase)))
                {
                    errorCode = "AMOUNT_TOO_LOW";
                    userMessage = "المبلغ أقل من الحد الأدنى المسموح به";
                }
                else if (message.Contains("amount", StringComparison.OrdinalIgnoreCase) &&
                         (message.Contains("maximum", StringComparison.OrdinalIgnoreCase) ||
                          message.Contains("الحد الأقصى", StringComparison.OrdinalIgnoreCase)))
                {
                    errorCode = "AMOUNT_TOO_HIGH";
                    userMessage = "المبلغ أكبر من الحد الأقصى المسموح به";
                }
                else if (message.Contains("Service unavailable", StringComparison.OrdinalIgnoreCase) ||
                         message.Contains("الخدمة غير متاحة", StringComparison.OrdinalIgnoreCase))
                {
                    errorCode = "SERVICE_UNAVAILABLE";
                    userMessage = "خدمة فلوسك غير متاحة حالياً. يرجى المحاولة لاحقاً";
                }
                
                return (userMessage, errorCode);
            }
            catch
            {
                return ("خطأ في معالجة استجابة فلوسك", "PARSE_ERROR");
            }
        }

        /// <summary>
        /// Clears the cached merchant key.
        /// يمسح المفتاح التجاري المخزن مؤقتاً.
        /// </summary>
        /// <param name="cancellationToken">Cancellation token. رمز الإلغاء.</param>
        /// <returns>Completed task. مهمة مكتملة.</returns>
        public Task InvalidateMerchantKeyCacheAsync(CancellationToken cancellationToken = default)
        {
            _cache.Remove(TOKEN_CACHE_KEY);
            return Task.CompletedTask;
        }

        /// <summary>
        /// Checks whether a currency is supported by Flosk.
        /// يتحقق مما إذا كانت العملة مدعومة في فلوسك.
        /// </summary>
        /// <param name="currency">Currency code. رمز العملة.</param>
        /// <param name="cancellationToken">Cancellation token. رمز الإلغاء.</param>
        /// <returns>True if supported. صحيح إذا كانت مدعومة.</returns>
        public async Task<bool> IsCurrencySupportedAsync(string currency, CancellationToken cancellationToken = default)
        {
            var code = string.IsNullOrWhiteSpace(currency) ? "YER" : currency.Trim().ToUpperInvariant();

            try
            {
                Dictionary<string, string>? settings = null;
                try
                {
                    settings = await _systemSettingsService.GetSettingsAsync(cancellationToken);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "تعذر قراءة إعدادات فلوسك من systemsettings.json أثناء التحقق من العملة. سيتم استخدام appsettings كبديل.");
                }

                if (settings != null &&
                    settings.TryGetValue($"Flosk:SourceWalletIds:{code}", out var systemValue) &&
                    long.TryParse(systemValue, out var systemId) && systemId > 0)
                {
                    return true;
                }

                var configValue = _configuration[$"Flosk:SourceWalletIds:{code}"];
                if (long.TryParse(configValue, out var configId) && configId > 0)
                {
                    return true;
                }

                if (code == "YER")
                {
                    if (settings != null &&
                        settings.TryGetValue("Flosk:SourceWalletId", out var fallbackSystem) &&
                        long.TryParse(fallbackSystem, out var fallbackSystemId) && fallbackSystemId > 0)
                    {
                        return true;
                    }

                    var fallbackConfig = _configuration["Flosk:SourceWalletId"];
                    if (long.TryParse(fallbackConfig, out var fallbackConfigId) && fallbackConfigId > 0)
                    {
                        return true;
                    }
                }

                return false;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "فشل التحقق من دعم عملة فلوسك. Currency={Currency}", currency);
                return false;
            }
        }

        private async Task<long> GetSourceWalletIdAsync(string currency, CancellationToken cancellationToken)
        {
            var code = string.IsNullOrWhiteSpace(currency) ? "YER" : currency.Trim().ToUpperInvariant();

            Dictionary<string, string>? settings = null;
            try
            {
                settings = await _systemSettingsService.GetSettingsAsync(cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "تعذر قراءة إعدادات فلوسك من systemsettings.json أثناء تحديد SourceWalletId. سيتم استخدام appsettings كبديل.");
            }

            if (settings != null &&
                settings.TryGetValue($"Flosk:SourceWalletIds:{code}", out var systemValue) &&
                long.TryParse(systemValue, out var systemId) && systemId > 0)
            {
                return systemId;
            }

            var configValue = _configuration[$"Flosk:SourceWalletIds:{code}"];
            if (long.TryParse(configValue, out var configId) && configId > 0)
            {
                return configId;
            }

            if (code == "YER")
            {
                if (settings != null &&
                    settings.TryGetValue("Flosk:SourceWalletId", out var fallbackSystem) &&
                    long.TryParse(fallbackSystem, out var fallbackSystemId) && fallbackSystemId > 0)
                {
                    return fallbackSystemId;
                }

                var fallbackConfig = _configuration["Flosk:SourceWalletId"];
                if (long.TryParse(fallbackConfig, out var fallbackConfigId) && fallbackConfigId > 0)
                {
                    return fallbackConfigId;
                }
            }

            throw new InvalidOperationException($"إعدادات فلوسك غير مكتملة. يجب ضبط Flosk:SourceWalletIds:{code} أو Flosk:SourceWalletId.");
        }

        private async Task<string> GetMerchantKeyAsync(CancellationToken cancellationToken)
        {
            if (_cache.TryGetValue(TOKEN_CACHE_KEY, out string cachedKey) && !string.IsNullOrWhiteSpace(cachedKey))
            {
                return cachedKey;
            }

            string? configuredKey = null;
            try
            {
                var settings = await _systemSettingsService.GetSettingsAsync(cancellationToken);
                if (settings != null && settings.TryGetValue("Flosk:Key", out var keyFromSettings))
                {
                    configuredKey = keyFromSettings;
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "تعذر قراءة Flosk:Key من systemsettings.json. سيتم استخدام appsettings كبديل.");
            }

            configuredKey ??= _configuration["Flosk:Key"];
            if (string.IsNullOrWhiteSpace(configuredKey))
            {
                throw new InvalidOperationException(
                    "إعدادات فلوسك غير مكتملة. يجب ضبط Flosk:Key (المفتاح/Token) من خلال Verify Key API لأنه يصل عبر SMS ولا يمكن توليده تلقائياً.");
            }

            _cache.Set(TOKEN_CACHE_KEY, configuredKey, TimeSpan.FromMinutes(GetKeyCacheMinutes()));
            return configuredKey;
        }

        private async Task<HttpRequestMessage> CreateAuthenticatedRequestAsync(
            HttpMethod method,
            string path,
            HttpContent? content = null,
            CancellationToken cancellationToken = default)
        {
            var merchantKey = await GetMerchantKeyAsync(cancellationToken);
            var request = new HttpRequestMessage(method, path);
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", merchantKey);
            
            if (content != null)
            {
                request.Content = content;
            }
            
            return request;
        }

        /// <summary>
        /// Initiates a Flosk payment for a booking.
        /// يهيئ عملية دفع عبر فلوسك للحجز.
        /// </summary>
        /// <param name="booking">Target booking. الحجز المستهدف.</param>
        /// <param name="amount">Payment amount. مبلغ الدفع.</param>
        /// <param name="cancellationToken">Cancellation token. رمز الإلغاء.</param>
        /// <returns>Payment result. نتيجة الدفع.</returns>
        public async Task<PaymentResult> InitiatePaymentAsync(Booking booking, decimal amount, CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation("بدء تهيئة عملية دفع فلوسك للحجز {BookingId}", booking.Id);

                // Validate the customer's phone number.
                // التحقق من رقم هاتف العميل.
                var rawPhone = booking.User?.Phone ?? string.Empty;
                var customerPhone = NormalizePhone(rawPhone);
                
                _logger.LogDebug("رقم الهاتف الخام: {RawPhone}, بعد التطبيع: {NormalizedPhone}", rawPhone, customerPhone);
                
                if (string.IsNullOrWhiteSpace(customerPhone))
                {
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = string.Empty,
                        GatewayTransactionId = string.Empty,
                        Message = "رقم هاتف العميل غير متوفر. يرجى تحديث بيانات الحساب",
                        Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                        ErrorCode = "PHONE_MISSING",
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow
                    };
                }

                // Validate the phone format (12 digits: 967XXXXXXXXX).
                // التحقق من صحة تنسيق الرقم (يجب أن يكون 12 رقم: 967XXXXXXXXX).
                if (customerPhone.Length != 12 || !customerPhone.StartsWith("967"))
                {
                    _logger.LogWarning("رقم الهاتف بتنسيق غير صحيح: {Phone}, الطول: {Length}", customerPhone, customerPhone.Length);
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = string.Empty,
                        GatewayTransactionId = string.Empty,
                        Message = $"رقم الهاتف غير صالح ({rawPhone}). يجب أن يكون رقم يمني صحيح",
                        Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                        ErrorCode = "INVALID_PHONE_FORMAT",
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow
                    };
                }

                if (!long.TryParse(customerPhone, out var customerPhoneNumber))
                {
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = string.Empty,
                        GatewayTransactionId = string.Empty,
                        Message = "رقم هاتف العميل غير صالح",
                        Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                        ErrorCode = "INVALID_PHONE",
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow
                    };
                }

                if (amount <= 0)
                {
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = string.Empty,
                        GatewayTransactionId = string.Empty,
                        Message = "المبلغ يجب أن يكون أكبر من صفر",
                        Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                        ErrorCode = "INVALID_AMOUNT",
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow
                    };
                }

                var bookingCurrency = booking.TotalPrice?.Currency ?? "YER";
                var sourceWalletId = await GetSourceWalletIdAsync(bookingCurrency, cancellationToken);

                var requestId = $"{booking.Id.ToString().Replace("-", "").Substring(0, 8)}-{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}";
                var purchaseRequest = new FloskPurchaseRequest
                {
                    SourceWalletId = sourceWalletId,
                    RequestId = requestId,
                    TargetPhone = customerPhoneNumber,
                    Amount = amount,
                    Purpose = $"حجز رقم {booking.Id}"
                };

                _logger.LogInformation("إرسال طلب دفع فلوسك: SourceWallet={SourceWallet}, TargetPhone={TargetPhone}, Amount={Amount}, RequestId={RequestId}",
                    sourceWalletId, customerPhoneNumber, amount, requestId);

                var content = new StringContent(JsonSerializer.Serialize(purchaseRequest, JsonOptions), Encoding.UTF8, "application/json");
                
                using var request = await CreateAuthenticatedRequestAsync(HttpMethod.Post, GetPurchasePath(), content, cancellationToken);
                var response = await _httpClient.SendAsync(request, cancellationToken);
                var responseContent = await response.Content.ReadAsStringAsync(cancellationToken);

                _logger.LogDebug("استجابة فلوسك: Status={Status}, Content={Content}", response.StatusCode, responseContent);

                    // Handle API errors.
                    // معالجة الأخطاء.
                if (!response.IsSuccessStatusCode)
                {
                    var (userMessage, errorCode) = ParseFloskError(responseContent);
                    _logger.LogError("فشل تهيئة دفع فلوسك. Status={Status}, ErrorCode={ErrorCode}, Content={Content}", 
                        response.StatusCode, errorCode, responseContent);
                    
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = string.Empty,
                        GatewayTransactionId = string.Empty,
                        Message = userMessage,
                        Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                        ErrorCode = errorCode,
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow
                    };
                }

                var apiResponse = JsonSerializer.Deserialize<FloskApiResponse<FloskPurchaseData>>(responseContent, JsonOptions);
                if (apiResponse == null || !apiResponse.IsSuccess || apiResponse.Data == null)
                {
                    var errorMessage = string.IsNullOrWhiteSpace(apiResponse?.Message)
                        ? "فشل إنشاء عملية الدفع عبر فلوسك"
                        : apiResponse.Message;
                        
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = string.Empty,
                        GatewayTransactionId = string.Empty,
                        Message = errorMessage,
                        Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                        ErrorCode = "API_ERROR",
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow
                    };
                }

                _logger.LogInformation("تم إنشاء طلب دفع فلوسك بنجاح. PurchaseId={PurchaseId}, ReferenceId={ReferenceId}", 
                    apiResponse.Data.Id, apiResponse.Data.ReferenceId);

                return new PaymentResult
                {
                    IsSuccess = true,
                    TransactionId = apiResponse.Data.ReferenceId ?? requestId,
                    GatewayTransactionId = apiResponse.Data.Id.ToString(),
                    Message = apiResponse.Message ?? "تم إنشاء طلب الدفع بنجاح. يرجى إدخال رمز التحقق",
                    Status = YemenBooking.Core.Enums.PaymentStatus.Pending,
                    ProcessedAmount = amount,
                    Fees = apiResponse.Data.Fee,
                    ProcessedAt = DateTime.UtcNow
                };
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "خطأ في الاتصال بخادم فلوسك للحجز {BookingId}", booking.Id);
                return new PaymentResult
                {
                    IsSuccess = false,
                    TransactionId = string.Empty,
                    GatewayTransactionId = string.Empty,
                    Message = "تعذر الاتصال بخدمة فلوسك. يرجى المحاولة لاحقاً",
                    Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                    ErrorCode = "CONNECTION_ERROR",
                    ProcessedAmount = 0,
                    Fees = 0,
                    ProcessedAt = DateTime.UtcNow
                };
            }
            catch (TaskCanceledException ex) when (ex.InnerException is TimeoutException)
            {
                _logger.LogError(ex, "انتهت مهلة الاتصال بخادم فلوسك للحجز {BookingId}", booking.Id);
                return new PaymentResult
                {
                    IsSuccess = false,
                    TransactionId = string.Empty,
                    GatewayTransactionId = string.Empty,
                    Message = "انتهت مهلة الاتصال بخدمة فلوسك. يرجى المحاولة لاحقاً",
                    Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                    ErrorCode = "TIMEOUT",
                    ProcessedAmount = 0,
                    Fees = 0,
                    ProcessedAt = DateTime.UtcNow
                };
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogError(ex, "خطأ في الإعدادات أثناء تهيئة دفع فلوسك للحجز {BookingId}", booking.Id);
                return new PaymentResult
                {
                    IsSuccess = false,
                    TransactionId = string.Empty,
                    GatewayTransactionId = string.Empty,
                    Message = ex.Message,
                    Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                    ErrorCode = "CONFIG_ERROR",
                    ProcessedAmount = 0,
                    Fees = 0,
                    ProcessedAt = DateTime.UtcNow
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ غير متوقع أثناء تهيئة دفع فلوسك للحجز {BookingId}", booking.Id);
                return new PaymentResult
                {
                    IsSuccess = false,
                    TransactionId = string.Empty,
                    GatewayTransactionId = string.Empty,
                    Message = "حدث خطأ غير متوقع. يرجى المحاولة لاحقاً",
                    Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                    ErrorCode = "UNEXPECTED_ERROR",
                    ProcessedAmount = 0,
                    Fees = 0,
                    ProcessedAt = DateTime.UtcNow
                };
            }
        }

        /// <summary>
        /// Confirms a Flosk payment.
        /// يؤكد عملية دفع عبر فلوسك.
        /// </summary>
        /// <param name="payment">Payment record. سجل الدفع.</param>
        /// <param name="otp">OTP code. رمز التحقق.</param>
        /// <param name="cancellationToken">Cancellation token. رمز الإلغاء.</param>
        /// <returns>Payment result. نتيجة الدفع.</returns>
        public async Task<PaymentResult> ConfirmPaymentAsync(Payment payment, string otp, CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation("بدء تأكيد عملية دفع فلوسك للدفعة {PaymentId}", payment.Id);

                if (string.IsNullOrWhiteSpace(payment.GatewayTransactionId) || !long.TryParse(payment.GatewayTransactionId, out var purchaseId) || purchaseId <= 0)
                {
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = string.Empty,
                        GatewayTransactionId = payment.GatewayTransactionId ?? string.Empty,
                        Message = "معرف العملية غير متوفر. يرجى إعادة عملية الدفع",
                        Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                        ErrorCode = "MISSING_PURCHASE_ID",
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow
                    };
                }

                // Normalize the OTP by removing non-digit characters only.
                // تطبيع رمز التحقق بإزالة الأحرف غير الرقمية فقط.
                var normalizedOtp = new string(otp?.Where(char.IsDigit).ToArray() ?? Array.Empty<char>());
                if (string.IsNullOrWhiteSpace(normalizedOtp) || normalizedOtp.Length != 6 || !int.TryParse(normalizedOtp, out var otpNumber))
                {
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = string.Empty,
                        GatewayTransactionId = payment.GatewayTransactionId,
                        Message = "رمز التحقق يجب أن يتكون من 6 أرقام",
                        Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                        ErrorCode = "INVALID_OTP_FORMAT",
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow
                    };
                }

                var confirmRequest = new FloskConfirmRequest
                {
                    Otp = otpNumber,
                    PurchaseId = purchaseId
                };

                _logger.LogInformation("إرسال طلب تأكيد فلوسك: PurchaseId={PurchaseId}", purchaseId);

                var content = new StringContent(JsonSerializer.Serialize(confirmRequest, JsonOptions), Encoding.UTF8, "application/json");
                
                using var request = await CreateAuthenticatedRequestAsync(HttpMethod.Post, GetConfirmPath(), content, cancellationToken);
                var response = await _httpClient.SendAsync(request, cancellationToken);
                var responseContent = await response.Content.ReadAsStringAsync(cancellationToken);

                _logger.LogDebug("استجابة تأكيد فلوسك: Status={Status}, Content={Content}", response.StatusCode, responseContent);

                if (!response.IsSuccessStatusCode)
                {
                    var (userMessage, errorCode) = ParseFloskError(responseContent);
                    _logger.LogError("فشل تأكيد دفع فلوسك. Status={Status}, ErrorCode={ErrorCode}, Content={Content}", 
                        response.StatusCode, errorCode, responseContent);
                    
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = string.Empty,
                        GatewayTransactionId = payment.GatewayTransactionId,
                        Message = userMessage,
                        Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                        ErrorCode = errorCode,
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow
                    };
                }

                var apiResponse = JsonSerializer.Deserialize<FloskApiResponse<FloskPurchaseData>>(responseContent, JsonOptions);
                if (apiResponse == null || !apiResponse.IsSuccess || apiResponse.Data == null)
                {
                    var errorMessage = string.IsNullOrWhiteSpace(apiResponse?.Message)
                        ? "فشل تأكيد عملية الدفع عبر فلوسك"
                        : apiResponse.Message;
                        
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = string.Empty,
                        GatewayTransactionId = payment.GatewayTransactionId,
                        Message = errorMessage,
                        Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                        ErrorCode = "API_ERROR",
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow
                    };
                }

                var statusEn = apiResponse.Data.Status?.En ?? string.Empty;
                var isCompleted = string.Equals(statusEn, "Completed", StringComparison.OrdinalIgnoreCase);

                if (isCompleted)
                {
                    payment.Status = YemenBooking.Core.Enums.PaymentStatus.Successful;
                    payment.TransactionId = apiResponse.Data.Id.ToString();
                    payment.ProcessedAt = DateTime.UtcNow;
                    
                    _logger.LogInformation("تم تأكيد دفع فلوسك بنجاح. TransactionId={TransactionId}", payment.TransactionId);
                }
                else
                {
                    payment.Status = YemenBooking.Core.Enums.PaymentStatus.Failed;
                    payment.ProcessedAt = DateTime.UtcNow;
                    
                    _logger.LogWarning("تأكيد فلوسك لم يكتمل. Status={Status}", statusEn);
                }

                await _paymentRepository.UpdatePaymentAsync(payment, cancellationToken);
                await _paymentRepository.SaveChangesAsync(cancellationToken);
                
                _logger.LogInformation(
                    "✅ تم حفظ تحديث حالة دفعة فلوسك: PaymentId={PaymentId}, NewStatus={Status}",
                    payment.Id, payment.Status);

                return new PaymentResult
                {
                    IsSuccess = isCompleted,
                    TransactionId = payment.TransactionId ?? string.Empty,
                    GatewayTransactionId = payment.GatewayTransactionId ?? string.Empty,
                    Message = isCompleted ? "تم الدفع بنجاح" : (apiResponse.Message ?? "فشل تأكيد الدفع"),
                    Status = isCompleted ? YemenBooking.Core.Enums.PaymentStatus.Successful : YemenBooking.Core.Enums.PaymentStatus.Failed,
                    ProcessedAmount = payment.Amount.Amount,
                    Fees = apiResponse.Data.Fee,
                    ProcessedAt = DateTime.UtcNow
                };
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "خطأ في الاتصال بخادم فلوسك أثناء التأكيد للدفعة {PaymentId}", payment.Id);
                return new PaymentResult
                {
                    IsSuccess = false,
                    TransactionId = string.Empty,
                    GatewayTransactionId = payment.GatewayTransactionId ?? string.Empty,
                    Message = "تعذر الاتصال بخدمة فلوسك. يرجى المحاولة لاحقاً",
                    Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                    ErrorCode = "CONNECTION_ERROR",
                    ProcessedAmount = 0,
                    Fees = 0,
                    ProcessedAt = DateTime.UtcNow
                };
            }
            catch (TaskCanceledException ex) when (ex.InnerException is TimeoutException)
            {
                _logger.LogError(ex, "انتهت مهلة الاتصال بخادم فلوسك أثناء التأكيد للدفعة {PaymentId}", payment.Id);
                return new PaymentResult
                {
                    IsSuccess = false,
                    TransactionId = string.Empty,
                    GatewayTransactionId = payment.GatewayTransactionId ?? string.Empty,
                    Message = "انتهت مهلة الاتصال بخدمة فلوسك. يرجى المحاولة لاحقاً",
                    Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                    ErrorCode = "TIMEOUT",
                    ProcessedAmount = 0,
                    Fees = 0,
                    ProcessedAt = DateTime.UtcNow
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ غير متوقع أثناء تأكيد دفع فلوسك للدفعة {PaymentId}", payment.Id);
                return new PaymentResult
                {
                    IsSuccess = false,
                    TransactionId = string.Empty,
                    GatewayTransactionId = payment.GatewayTransactionId ?? string.Empty,
                    Message = "حدث خطأ غير متوقع. يرجى المحاولة لاحقاً",
                    Status = YemenBooking.Core.Enums.PaymentStatus.Failed,
                    ErrorCode = "UNEXPECTED_ERROR",
                    ProcessedAmount = 0,
                    Fees = 0,
                    ProcessedAt = DateTime.UtcNow
                };
            }
        }

        /// <summary>
        /// Refunds a Flosk payment.
        /// يعيد مبلغاً عبر فلوسك.
        /// </summary>
        /// <param name="payment">Payment record. سجل الدفع.</param>
        /// <param name="booking">Related booking. الحجز المرتبط.</param>
        /// <param name="refundAmount">Refund amount. مبلغ الاسترداد.</param>
        /// <param name="reason">Refund reason. سبب الاسترداد.</param>
        /// <param name="cancellationToken">Cancellation token. رمز الإلغاء.</param>
        /// <returns>Refund result. نتيجة الاسترداد.</returns>
        public async Task<RefundResult> RefundAsync(Payment payment, Booking booking, decimal refundAmount, string reason, CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation("بدء استرداد مبلغ عبر فلوسك للدفعة {PaymentId} بمبلغ {Amount}", payment.Id, refundAmount);

                if (refundAmount <= 0)
                {
                    return new RefundResult
                    {
                        IsSuccess = false,
                        RefundId = string.Empty,
                        Message = "مبلغ الاسترداد يجب أن يكون أكبر من صفر",
                        RefundedAmount = 0,
                        RefundedAt = DateTime.UtcNow
                    };
                }

                // Extract transaction_id from TransactionId and ensure it is numeric.
                // استخراج transaction_id من TransactionId - يجب أن يكون رقماً.
                var transactionIdStr = payment.TransactionId?.Trim();
                if (string.IsNullOrWhiteSpace(transactionIdStr) || !long.TryParse(transactionIdStr, out var transactionId) || transactionId <= 0)
                {
                    return new RefundResult
                    {
                        IsSuccess = false,
                        RefundId = string.Empty,
                        Message = "لا يمكن استرداد هذه الدفعة. يجب أن تكون الدفعة مؤكدة (Completed) أولاً",
                        RefundedAmount = 0,
                        RefundedAt = DateTime.UtcNow
                    };
                }

                var requestId = $"REFUND-{payment.Id.ToString().Replace("-", "").Substring(0, 8)}-{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}";
                var refundRequest = new FloskRefundRequest
                {
                    TransactionId = transactionId,
                    RequestId = requestId,
                    Amount = refundAmount
                };

                _logger.LogInformation("إرسال طلب استرداد فلوسك: TransactionId={TransactionId}, Amount={Amount}, RequestId={RequestId}",
                    transactionId, refundAmount, requestId);

                var content = new StringContent(JsonSerializer.Serialize(refundRequest, JsonOptions), Encoding.UTF8, "application/json");
                
                using var request = await CreateAuthenticatedRequestAsync(HttpMethod.Post, GetRefundPath(), content, cancellationToken);
                var response = await _httpClient.SendAsync(request, cancellationToken);
                var responseContent = await response.Content.ReadAsStringAsync(cancellationToken);

                _logger.LogDebug("استجابة استرداد فلوسك: Status={Status}, Content={Content}", response.StatusCode, responseContent);

                if (!response.IsSuccessStatusCode)
                {
                    var (userMessage, errorCode) = ParseFloskError(responseContent);
                    _logger.LogError("فشل استرداد فلوسك. Status={Status}, ErrorCode={ErrorCode}, Content={Content}", 
                        response.StatusCode, errorCode, responseContent);
                    
                    return new RefundResult
                    {
                        IsSuccess = false,
                        RefundId = string.Empty,
                        Message = userMessage,
                        RefundedAmount = 0,
                        RefundedAt = DateTime.UtcNow
                    };
                }

                var apiResponse = JsonSerializer.Deserialize<FloskApiResponse<FloskPurchaseData>>(responseContent, JsonOptions);
                if (apiResponse == null || !apiResponse.IsSuccess)
                {
                    var errorMessage = string.IsNullOrWhiteSpace(apiResponse?.Message)
                        ? "فشل الاسترداد عبر فلوسك"
                        : apiResponse.Message;
                        
                    return new RefundResult
                    {
                        IsSuccess = false,
                        RefundId = string.Empty,
                        Message = errorMessage,
                        RefundedAmount = 0,
                        RefundedAt = DateTime.UtcNow
                    };
                }

                _logger.LogInformation("تم استرداد المبلغ بنجاح عبر فلوسك. RefundId={RefundId}", apiResponse.Data?.Id);

                return new RefundResult
                {
                    IsSuccess = true,
                    RefundId = apiResponse.Data?.Id.ToString() ?? requestId,
                    Message = apiResponse.Message ?? "تم الاسترداد بنجاح",
                    RefundedAmount = refundAmount,
                    RefundedAt = DateTime.UtcNow
                };
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError(ex, "خطأ في الاتصال بخادم فلوسك أثناء الاسترداد للدفعة {PaymentId}", payment.Id);
                return new RefundResult
                {
                    IsSuccess = false,
                    RefundId = string.Empty,
                    Message = "تعذر الاتصال بخدمة فلوسك. يرجى المحاولة لاحقاً",
                    RefundedAmount = 0,
                    RefundedAt = DateTime.UtcNow
                };
            }
            catch (TaskCanceledException ex) when (ex.InnerException is TimeoutException)
            {
                _logger.LogError(ex, "انتهت مهلة الاتصال بخادم فلوسك أثناء الاسترداد للدفعة {PaymentId}", payment.Id);
                return new RefundResult
                {
                    IsSuccess = false,
                    RefundId = string.Empty,
                    Message = "انتهت مهلة الاتصال بخدمة فلوسك. يرجى المحاولة لاحقاً",
                    RefundedAmount = 0,
                    RefundedAt = DateTime.UtcNow
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ غير متوقع أثناء استرداد مبلغ عبر فلوسك للدفعة {PaymentId}", payment.Id);
                return new RefundResult
                {
                    IsSuccess = false,
                    RefundId = string.Empty,
                    Message = "حدث خطأ غير متوقع. يرجى المحاولة لاحقاً",
                    RefundedAmount = 0,
                    RefundedAt = DateTime.UtcNow
                };
            }
        }

        /// <summary>
        /// Requests a merchant key from Flosk.
        /// يطلب مفتاح التاجر من فلوسك.
        /// </summary>
        /// <param name="cancellationToken">Cancellation token. رمز الإلغاء.</param>
        /// <returns>Request key response. نتيجة طلب المفتاح.</returns>
        public async Task<FloskRequestKeyResponse> RequestKeyAsync(CancellationToken cancellationToken = default)
        {
            string? phoneRaw = null;
            string? shortCodeRaw = null;
            try
            {
                var settings = await _systemSettingsService.GetSettingsAsync(cancellationToken);
                if (settings != null)
                {
                    settings.TryGetValue("Flosk:MerchantPhone", out phoneRaw);
                    settings.TryGetValue("Flosk:MerchantShortCode", out shortCodeRaw);
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "تعذر قراءة بيانات Flosk:MerchantPhone/Flosk:MerchantShortCode من systemsettings.json. سيتم استخدام appsettings كبديل.");
            }

            phoneRaw ??= _configuration["Flosk:MerchantPhone"];
            shortCodeRaw ??= _configuration["Flosk:MerchantShortCode"];

            var phone = NormalizePhone(phoneRaw ?? string.Empty);
            var shortCode = NormalizePhone(shortCodeRaw ?? string.Empty);

            if (string.IsNullOrWhiteSpace(phone) || string.IsNullOrWhiteSpace(shortCode))
            {
                throw new InvalidOperationException("يجب ضبط Flosk:MerchantPhone و Flosk:MerchantShortCode لاستخدام Request Key API");
            }

            var request = new FloskRequestKeyRequest
            {
                Phone = phone,
                ShortCode = shortCode
            };

            var content = new StringContent(JsonSerializer.Serialize(request, JsonOptions), Encoding.UTF8, "application/json");
            var response = await _httpClient.PostAsync(GetRequestKeyPath(), content, cancellationToken);
            var responseContent = await response.Content.ReadAsStringAsync(cancellationToken);

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception("فشل Request Key API");
            }

            var parsed = JsonSerializer.Deserialize<FloskRequestKeyResponse>(responseContent, JsonOptions);
            if (parsed == null)
            {
                throw new Exception("تعذر قراءة استجابة Request Key");
            }

            return parsed;
        }

        /// <summary>
        /// Verifies a merchant key using the supplied OTP.
        /// يتحقق من مفتاح التاجر باستخدام رمز التحقق المرسل.
        /// </summary>
        /// <param name="requestId">Request identifier. معرف الطلب.</param>
        /// <param name="otp">One-time password. رمز التحقق لمرة واحدة.</param>
        /// <param name="cancellationToken">Cancellation token. رمز الإلغاء.</param>
        /// <returns>Verify key response. نتيجة التحقق من المفتاح.</returns>
        public async Task<FloskVerifyKeyResponse> VerifyKeyAsync(long requestId, string otp, CancellationToken cancellationToken = default)
        {
            var normalizedOtp = NormalizePhone(otp);
            if (string.IsNullOrWhiteSpace(normalizedOtp) || normalizedOtp.Length != 6)
            {
                throw new ArgumentException("رمز التحقق يجب أن يتكون من 6 أرقام");
            }

            var request = new FloskVerifyKeyRequest
            {
                RequestId = requestId,
                Otp = normalizedOtp
            };

            var content = new StringContent(JsonSerializer.Serialize(request, JsonOptions), Encoding.UTF8, "application/json");
            var response = await _httpClient.PostAsync(GetVerifyKeyPath(), content, cancellationToken);
            var responseContent = await response.Content.ReadAsStringAsync(cancellationToken);

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception("فشل Verify Key API");
            }

            var parsed = JsonSerializer.Deserialize<FloskVerifyKeyResponse>(responseContent, JsonOptions);
            if (parsed == null)
            {
                throw new Exception("تعذر قراءة استجابة Verify Key");
            }

            return parsed;
        }
    }
}
