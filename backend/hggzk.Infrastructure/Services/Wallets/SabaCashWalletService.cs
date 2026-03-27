using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
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
using YemenBooking.Core.Wallets.SabaCash;

namespace YemenBooking.Infrastructure.Services.Wallets
{
    /// <summary>
    /// يمثل خدمة محفظة سبأ كاش المدمجة مع YottaPay.
    /// Represents the SabaCash wallet service integrated with YottaPay.
    /// </summary>
    public class SabaCashWalletService : ISabaCashWalletService
    {
        // HTTP client for the SabaCash API.
        // عميل HTTP للتواصل مع واجهة SabaCash.
        private readonly HttpClient _httpClient;

        // Application configuration for connectivity settings.
        // إعدادات التطبيق لبيانات الاتصال.
        private readonly IConfiguration _configuration;

        private readonly ISystemSettingsService _systemSettingsService;

        // In-memory cache for JWT tokens.
        // ذاكرة مؤقتة لحفظ رموز JWT.
        private readonly IMemoryCache _cache;

        // JSON options for case-insensitive property mapping.
        // خيارات JSON للتعامل مع أسماء الخصائص بشكل غير حساس لحالة الأحرف.
        // SabaCash returns lower-case property names in responses.
        // يعيد SabaCash أسماء الخصائص بحروف صغيرة في الاستجابات.
        private static readonly JsonSerializerOptions _jsonOptions = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };

        private string GetSettingValue(string key, Dictionary<string, string>? settings)
        {
            if (settings != null && settings.TryGetValue(key, out var value) && !string.IsNullOrWhiteSpace(value))
            {
                return value;
            }

            return _configuration[key] ?? string.Empty;
        }

        private async Task<Dictionary<string, string>?> TryGetSystemSettingsAsync(CancellationToken cancellationToken)
        {
            try
            {
                return await _systemSettingsService.GetSettingsAsync(cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "تعذر قراءة إعدادات سبأ كاش من systemsettings.json. سيتم استخدام appsettings كبديل.");
                return null;
            }
        }

        private async Task<string> GetBaseUrlAsync(CancellationToken cancellationToken)
        {
            var settings = await TryGetSystemSettingsAsync(cancellationToken);
            return GetSettingValue("SabaCash:BaseUrl", settings);
        }

        private async Task<string> GetUsernameAsync(CancellationToken cancellationToken)
        {
            var settings = await TryGetSystemSettingsAsync(cancellationToken);
            return GetSettingValue("SabaCash:Username", settings);
        }

        private async Task<string> GetPasswordAsync(CancellationToken cancellationToken)
        {
            var settings = await TryGetSystemSettingsAsync(cancellationToken);
            return GetSettingValue("SabaCash:Password", settings);
        }

        private async Task<string> GetTerminalIdAsync(CancellationToken cancellationToken)
        {
            var settings = await TryGetSystemSettingsAsync(cancellationToken);
            return GetSettingValue("SabaCash:TerminalId", settings);
        }

        private async Task<string> GetLoginPathAsync(CancellationToken cancellationToken)
        {
            var settings = await TryGetSystemSettingsAsync(cancellationToken);
            var v = GetSettingValue("SabaCash:LoginPath", settings);
            return string.IsNullOrWhiteSpace(v) ? "/api/user-ms/v1/login" : v;
        }

        private async Task<string> GetOnlinePaymentPathAsync(CancellationToken cancellationToken)
        {
            var settings = await TryGetSystemSettingsAsync(cancellationToken);
            var v = GetSettingValue("SabaCash:OnlinePaymentPath", settings);
            return string.IsNullOrWhiteSpace(v) ? "/api/accounts/v1/adjustment/onLinePayment" : v;
        }

        private async Task<string> GetCheckAdjustmentPathAsync(CancellationToken cancellationToken)
        {
            var settings = await TryGetSystemSettingsAsync(cancellationToken);
            var v = GetSettingValue("SabaCash:CheckAdjustmentPath", settings);
            return string.IsNullOrWhiteSpace(v) ? "/api/accounts/v1/adjustment/checkAdjustmentByTransactionId" : v;
        }

        private async Task<string> GetOnlineMoneyReturnPathAsync(CancellationToken cancellationToken)
        {
            var settings = await TryGetSystemSettingsAsync(cancellationToken);
            var v = GetSettingValue("SabaCash:OnlineMoneyReturnPath", settings);
            return string.IsNullOrWhiteSpace(v) ? "/api/accounts/v1/adjustment/onlineMoneyReturn" : v;
        }

        private async Task<string> GetLanguageAsync(CancellationToken cancellationToken)
        {
            var settings = await TryGetSystemSettingsAsync(cancellationToken);
            var v = GetSettingValue("SabaCash:Language", settings);
            return string.IsNullOrWhiteSpace(v) ? "ar" : v;
        }

        private async Task<int> GetTokenCacheMinutesAsync(CancellationToken cancellationToken)
        {
            var settings = await TryGetSystemSettingsAsync(cancellationToken);
            var v = GetSettingValue("SabaCash:TokenCacheMinutes", settings);

            return int.TryParse(v, out var minutes) ? minutes : 50;
        }

        private async Task<string> GetTokenCacheKeyAsync(CancellationToken cancellationToken)
        {
            var username = await GetUsernameAsync(cancellationToken);
            username = NormalizeWalletCode(username);
            if (string.IsNullOrWhiteSpace(username))
            {
                username = "default";
            }

            return $"SabaCash_Token_{username}";
        }

        private string GetCurrencyId() => _configuration["SabaCash:CurrencyId"] ?? "1";

        private static string NormalizeCurrencyCode(string currency)
        {
            return string.IsNullOrWhiteSpace(currency)
                ? "YER"
                : currency.Trim().ToUpperInvariant();
        }

        private string ResolveCurrencyId(string currencyCode)
        {
            var code = NormalizeCurrencyCode(currencyCode);

            // ⚠️ These values were verified through hands-on testing with the SabaCash API.
            // ⚠️ تم التحقق من هذه القيم من خلال الاختبار العملي مع API سبأ كاش.
            // CurrencyId = "2" corresponds to the Yemeni Rial (YER) - confirmed on 2026-02-02.
            // CurrencyId = "2" هو الريال اليمني (YER) - تم التأكد في 2026-02-02.
            return code switch
            {
                "YER" => "2",   // ✅ Verified: Yemeni Rial.
                "SAR" => "1",   // Saudi Riyal. الريال السعودي (يحتاج تأكيد)
                "USD" => "3",   // US Dollar. الدولار الأمريكي (يحتاج تأكيد)
                _ => throw new InvalidOperationException($"عملة غير مدعومة لمحفظة سبأ كاش: {code}. العملات المدعومة: YER, SAR, USD")
            };
        }

        private readonly IPaymentRepository _paymentRepository;
        private readonly ILogger<SabaCashWalletService> _logger;

        /// <summary>
        /// ينشئ مثيلًا جديدًا من خدمة محفظة سبأ كاش.
        /// Creates a new instance of the SabaCash wallet service.
        /// </summary>
        /// <param name="httpClient">Configured HTTP client. عميل HTTP المهيأ.</param>
        /// <param name="configuration">Application configuration. إعدادات التطبيق.</param>
        /// <param name="cache">In-memory cache. الذاكرة المؤقتة.</param>
        /// <param name="systemSettingsService">System settings service. خدمة إعدادات النظام.</param>
        /// <param name="paymentRepository">Payment repository. مستودع المدفوعات.</param>
        /// <param name="logger">Logger instance. كائن تسجيل الأحداث.</param>
        public SabaCashWalletService(
            HttpClient httpClient,
            IConfiguration configuration,
            IMemoryCache cache,
            ISystemSettingsService systemSettingsService,
            IPaymentRepository paymentRepository,
            ILogger<SabaCashWalletService> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _cache = cache;
            _systemSettingsService = systemSettingsService;
            _paymentRepository = paymentRepository;
            _logger = logger;
        }

        private async Task EnsureHttpClientConfiguredAsync(CancellationToken cancellationToken)
        {
            var baseUrl = await GetBaseUrlAsync(cancellationToken);
            if (string.IsNullOrWhiteSpace(baseUrl))
            {
                throw new InvalidOperationException("إعدادات سبأ كاش غير مكتملة. يجب ضبط SabaCash:BaseUrl");
            }

            if (Uri.TryCreate(baseUrl, UriKind.Absolute, out var uri)
                && (string.Equals(uri.Scheme, "http", StringComparison.OrdinalIgnoreCase)
                    || string.Equals(uri.Scheme, "https", StringComparison.OrdinalIgnoreCase)))
            {
                if (_httpClient.BaseAddress == null || _httpClient.BaseAddress != uri)
                {
                    _httpClient.BaseAddress = uri;
                }
            }
            else
            {
                throw new InvalidOperationException($"قيمة SabaCash:BaseUrl غير صالحة: {baseUrl}");
            }

            var language = await GetLanguageAsync(cancellationToken);
            if (_httpClient.DefaultRequestHeaders.Contains("Accept-Language"))
            {
                _httpClient.DefaultRequestHeaders.Remove("Accept-Language");
            }
            _httpClient.DefaultRequestHeaders.Add("Accept-Language", language);
        }

        #region SabaCash low-level HTTP helpers

        private async Task<HttpRequestMessage> CreateAuthenticatedRequestAsync(
            HttpMethod method,
            string path,
            HttpContent? content = null,
            CancellationToken cancellationToken = default)
        {
            var token = await GetAuthTokenAsync(cancellationToken);
            var request = new HttpRequestMessage(method, path);
            request.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("bearer", token);
            
            if (content != null)
            {
                request.Content = content;
            }
            
            return request;
        }

        private async Task<string> GetAuthTokenAsync(CancellationToken cancellationToken)
        {
            await EnsureHttpClientConfiguredAsync(cancellationToken);
            var tokenCacheKey = await GetTokenCacheKeyAsync(cancellationToken);
            if (_cache.TryGetValue(tokenCacheKey, out string cachedToken))
            {
                _logger.LogDebug("استخدام رمز المصادقة من الذاكرة المؤقتة لمحفظة سبأ كاش");
                return cachedToken;
            }

            try
            {
                _logger.LogInformation("بدء عملية تسجيل الدخول إلى SabaCash لمحفظة سبأ كاش");

                var username = await GetUsernameAsync(cancellationToken);
                var password = await GetPasswordAsync(cancellationToken);
                var terminalIdStr = await GetTerminalIdAsync(cancellationToken);
                
                if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
                {
                    throw new InvalidOperationException("إعدادات سبأ كاش غير مكتملة. يجب ضبط SabaCash:Username و SabaCash:Password");
                }

                // تحويل TerminalId إلى رقم (افتراضي 1)
                int terminalId = 1;
                if (!string.IsNullOrWhiteSpace(terminalIdStr) && int.TryParse(terminalIdStr, out var parsedTerminalId))
                {
                    terminalId = parsedTerminalId;
                }

                var loginRequest = new SabaCashLoginRequest
                {
                    Username = username,
                    Password = password,
                    TerminalId = terminalId
                };

                _logger.LogDebug("إرسال طلب تسجيل دخول: Username={Username}, TerminalId={TerminalId}", username, terminalId);

                var content = new StringContent(
                    JsonSerializer.Serialize(loginRequest),
                    Encoding.UTF8,
                    "application/json");

                var loginPath = await GetLoginPathAsync(cancellationToken);
                var response = await _httpClient.PostAsync(loginPath, content, cancellationToken);
                var responseContent = await response.Content.ReadAsStringAsync(cancellationToken);

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogError("فشل تسجيل الدخول إلى SabaCash. الحالة: {Status}, المحتوى: {Content}", response.StatusCode, responseContent);
                    throw new Exception($"فشل تسجيل الدخول إلى SabaCash: {response.StatusCode}");
                }

                var loginResponse = JsonSerializer.Deserialize<SabaCashLoginResponse>(responseContent, _jsonOptions);

                if (loginResponse == null || string.IsNullOrWhiteSpace(loginResponse.Token))
                {
                    throw new Exception("لم يتم إرجاع token صالح من SabaCash");
                }

                // حفظ الرمز لمدة 50 دقيقة (صلاحية 60 دقيقة تقريباً)
                var cacheMinutes = await GetTokenCacheMinutesAsync(cancellationToken);
                _cache.Set(tokenCacheKey, loginResponse.Token, TimeSpan.FromMinutes(cacheMinutes));

                _logger.LogInformation("تم تسجيل الدخول بنجاح والحصول على رمز المصادقة من SabaCash");
                return loginResponse.Token;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء محاولة تسجيل الدخول إلى SabaCash لمحفظة سبأ كاش");
                throw new Exception("فشل الاتصال بخدمة الدفع الإلكتروني لمحفظة سبأ كاش", ex);
            }
        }

        private static string NormalizeWalletCode(string walletOrPhone)
        {
            if (string.IsNullOrWhiteSpace(walletOrPhone))
            {
                return string.Empty;
            }

            var digits = new string(walletOrPhone.Where(char.IsDigit).ToArray());
            if (digits.Length > 9)
            {
                digits = digits[^9..];
            }

            return digits;
        }

        private async Task<SabaCashPaymentResponse> CreatePaymentAsync(
            string customerWallet,
            decimal amount,
            string currencyCode,
            string note)
        {
            try
            {
                await EnsureHttpClientConfiguredAsync(CancellationToken.None);
                customerWallet = NormalizeWalletCode(customerWallet);
                _logger.LogInformation("بدء إنشاء عملية دفع عبر سبأ كاش: المحفظة={Wallet}, المبلغ={Amount}", customerWallet, amount);

                if (string.IsNullOrEmpty(customerWallet) || !customerWallet.StartsWith("7") || customerWallet.Length != 9)
                {
                    throw new ArgumentException("رقم المحفظة غير صحيح. يجب أن يبدأ بـ 7 ويتكون من 9 أرقام");
                }

                if (amount <= 0)
                {
                    throw new ArgumentException("المبلغ يجب أن يكون أكبر من صفر");
                }

                var currencyId = ResolveCurrencyId(currencyCode);

                var terminalId = await GetTerminalIdAsync(CancellationToken.None);
                if (string.IsNullOrWhiteSpace(terminalId))
                {
                    throw new InvalidOperationException("إعدادات سبأ كاش غير مكتملة. يجب ضبط SabaCash:TerminalId");
                }

                var paymentRequest = new SabaCashPaymentRequest
                {
                    Source = new SourceInfo
                    {
                        Code = customerWallet,
                        CurrencyId = currencyId
                    },
                    Beneficiary = new BeneficiaryInfo
                    {
                        Terminal = terminalId,
                        CurrencyId = currencyId
                    },
                    Amount = amount.ToString("F0"),
                    AmountCurrencyId = currencyId,
                    Note = note ?? $"عملية دفع بتاريخ {DateTime.Now:yyyy-MM-dd HH:mm}"
                };

                var content = new StringContent(
                    JsonSerializer.Serialize(paymentRequest),
                    Encoding.UTF8,
                    "application/json");

                var onlinePaymentPath = await GetOnlinePaymentPathAsync(CancellationToken.None);
                var request = await CreateAuthenticatedRequestAsync(HttpMethod.Post, onlinePaymentPath, content);
                var response = await _httpClient.SendAsync(request);

                var responseContent = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    var errorResponse = JsonSerializer.Deserialize<SabaCashErrorResponse>(responseContent, _jsonOptions);
                    var errorMessage = errorResponse?.Errors?.SubErrors?.FirstOrDefault()?.Message;

                    if (errorMessage?.Contains("sufficient balance") == true)
                    {
                        errorMessage = "الرصيد غير كافي لإتمام العملية";
                    }
                    else if (errorMessage?.Contains("not exists") == true)
                    {
                        errorMessage = "رقم المحفظة غير مسجل في النظام";
                    }
                    else if (string.IsNullOrEmpty(errorMessage))
                    {
                        errorMessage = "حدث خطأ في إنشاء عملية الدفع";
                    }

                    _logger.LogError("فشل إنشاء عملية الدفع عبر سبأ كاش: {Content}", responseContent);
                    throw new Exception(errorMessage);
                }

                var paymentResponse = JsonSerializer.Deserialize<SabaCashPaymentResponse>(responseContent, _jsonOptions);
                _logger.LogInformation("تم إنشاء عملية الدفع بنجاح عبر سبأ كاش. AdjustmentId={AdjId}, TransactionId={TxnId}",
                    paymentResponse.Adjustment.Id,
                    paymentResponse.Adjustment.TransactionId);

                return paymentResponse;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في إنشاء عملية الدفع عبر سبأ كاش");
                throw;
            }
        }

        private async Task<SabaCashConfirmResponse> ConfirmPaymentInternalAsync(
            string adjustmentId,
            string otp,
            string note)
        {
            try
            {
                await EnsureHttpClientConfiguredAsync(CancellationToken.None);
                _logger.LogInformation("بدء تأكيد عملية الدفع سبأ كاش: AdjustmentId={AdjId}", adjustmentId);

                if (string.IsNullOrEmpty(adjustmentId))
                {
                    throw new ArgumentException("معرف العملية مطلوب");
                }

                if (string.IsNullOrEmpty(otp) || otp.Length != 4)
                {
                    throw new ArgumentException("رمز التحقق يجب أن يتكون من 4 أرقام");
                }

                var confirmRequest = new SabaCashConfirmRequest
                {
                    Id = adjustmentId,
                    Otp = otp,
                    Note = note ?? "تأكيد عملية الدفع"
                };

                var content = new StringContent(
                    JsonSerializer.Serialize(confirmRequest),
                    Encoding.UTF8,
                    "application/json");

                var onlinePaymentPath = await GetOnlinePaymentPathAsync(CancellationToken.None);
                var request = await CreateAuthenticatedRequestAsync(HttpMethod.Patch, onlinePaymentPath, content);

                var response = await _httpClient.SendAsync(request, CancellationToken.None);
                var responseContent = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    var errorResponse = JsonSerializer.Deserialize<SabaCashErrorResponse>(responseContent, _jsonOptions);
                    var errorMessage = errorResponse?.Errors?.SubErrors?.FirstOrDefault()?.Message;

                    if (errorMessage?.Contains("Invalid OTP") == true)
                    {
                        errorMessage = "رمز التحقق غير صحيح";
                    }
                    else if (errorMessage?.Contains("expired") == true)
                    {
                        errorMessage = "انتهت صلاحية العملية. يرجى إعادة المحاولة";
                    }
                    else if (errorMessage?.Contains("already processed") == true)
                    {
                        errorMessage = "تمت معالجة هذه العملية مسبقاً";
                    }
                    else if (string.IsNullOrEmpty(errorMessage))
                    {
                        errorMessage = "فشل تأكيد عملية الدفع";
                    }

                    _logger.LogError("فشل تأكيد عملية الدفع عبر سبأ كاش: {Content}", responseContent);
                    throw new Exception(errorMessage);
                }

                var confirmResponse = JsonSerializer.Deserialize<SabaCashConfirmResponse>(responseContent, _jsonOptions);
                _logger.LogInformation("تم تأكيد عملية الدفع عبر سبأ كاش. النتيجة={Completed}",
                    confirmResponse.Completed ? "نجحت" : "فشلت");

                return confirmResponse;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في تأكيد عملية الدفع عبر سبأ كاش");
                throw;
            }
        }

        private async Task<SabaCashStatusResponse> CheckAdjustmentByTransactionIdAsync(string transactionId, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(transactionId))
            {
                throw new ArgumentException("transactionId مطلوب", nameof(transactionId));
            }

            await EnsureHttpClientConfiguredAsync(cancellationToken);

            var payload = new SabaCashStatusRequest { TransactionId = transactionId };
            var json = JsonSerializer.Serialize(payload);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            var checkPath = await GetCheckAdjustmentPathAsync(cancellationToken);
            var request = await CreateAuthenticatedRequestAsync(HttpMethod.Get, checkPath, content, cancellationToken);

            var response = await _httpClient.SendAsync(request, cancellationToken);
            var responseContent = await response.Content.ReadAsStringAsync(cancellationToken);

            if (!response.IsSuccessStatusCode)
            {
                _logger.LogError("فشل استعلام حالة عملية سبأ كاش. Status={Status}, Content={Content}", response.StatusCode, responseContent);
                throw new Exception("فشل الاستعلام عن حالة عملية سبأ كاش");
            }

            var result = JsonSerializer.Deserialize<SabaCashStatusResponse>(responseContent, _jsonOptions);
            if (result == null)
            {
                throw new Exception("فشل تحويل استجابة الاستعلام عن الحالة من سبأ كاش");
            }

            return result;
        }

        private async Task<(bool Success, decimal Balance, string Message)> GetMerchantBalanceAsync(
            string currencyId,
            CancellationToken cancellationToken)
        {
            try
            {
                await EnsureHttpClientConfiguredAsync(cancellationToken);

                var request = await CreateAuthenticatedRequestAsync(
                    HttpMethod.Get, 
                    "/api/accounts/v1/transaction/report/getLastBalance",
                    null,
                    cancellationToken);
                
                var response = await _httpClient.SendAsync(request, cancellationToken);
                var responseContent = await response.Content.ReadAsStringAsync(cancellationToken);

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogError("فشل الاستعلام عن رصيد التاجر في سبأ كاش. Status={Status}, Content={Content}", response.StatusCode, responseContent);
                    return (false, 0, "فشل الاستعلام عن الرصيد");
                }

                // الاستجابة عبارة عن مصفوفة من الحسابات
                var balances = JsonSerializer.Deserialize<List<SabaCashBalanceInfo>>(responseContent, _jsonOptions);
                
                // البحث عن الحساب بالعملة المطلوبة
                var account = balances?.FirstOrDefault(b => 
                    b.CurrencyId == currencyId && 
                    b.SubAccountTypeId != 2536); // استبعاد حساب الكاشير (Terminal)
                
                if (account == null)
                {
                    // إذا لم نجد الحساب الرئيسي، نبحث عن أي حساب بهذه العملة
                    account = balances?.FirstOrDefault(b => b.CurrencyId == currencyId);
                }

                if (account == null)
                {
                    return (false, 0, "لم يتم العثور على حساب بالعملة المطلوبة");
                }

                return (true, account.Balance, "تم الاستعلام عن الرصيد بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في الاستعلام عن رصيد التاجر في سبأ كاش");
                return (false, 0, ex.Message);
            }
        }

        private async Task<SabaCashPaymentResponse> RefundPaymentInternalAsync(
            string originalAdjustmentId,
            string customerWallet,
            decimal amount,
            string currencyCode,
            string note)
        {
            try
            {
                await EnsureHttpClientConfiguredAsync(CancellationToken.None);
                _logger.LogInformation("بدء عملية إرجاع عبر سبأ كاش: OriginalAdjId={AdjId}, Amount={Amount}", originalAdjustmentId, amount);

                customerWallet = NormalizeWalletCode(customerWallet);

                if (string.IsNullOrEmpty(originalAdjustmentId))
                {
                    throw new ArgumentException("معرف العملية الأصلية مطلوب");
                }

                if (string.IsNullOrEmpty(customerWallet) || !customerWallet.StartsWith("7") || customerWallet.Length != 9)
                {
                    throw new ArgumentException("رقم محفظة العميل غير صحيح");
                }

                if (amount <= 0)
                {
                    throw new ArgumentException("مبلغ الإرجاع يجب أن يكون أكبر من صفر");
                }

                var currencyId = ResolveCurrencyId(currencyCode);

                // ✅ التحقق من رصيد الحساب الرئيسي قبل الاسترداد
                var balanceCheck = await GetMerchantBalanceAsync(currencyId, CancellationToken.None);
                if (!balanceCheck.Success)
                {
                    _logger.LogWarning("فشل الاستعلام عن رصيد التاجر قبل الاسترداد. Message={Message}", balanceCheck.Message);
                    throw new Exception($"تعذر التحقق من رصيد الحساب: {balanceCheck.Message}");
                }

                if (balanceCheck.Balance < amount)
                {
                    _logger.LogWarning(
                        "رصيد الحساب الرئيسي غير كافي للاسترداد. Balance={Balance}, RefundAmount={Amount}",
                        balanceCheck.Balance,
                        amount);
                    throw new Exception(
                        $"رصيد الحساب الرئيسي غير كافي للاسترداد. الرصيد الحالي: {balanceCheck.Balance}، المطلوب: {amount}. " +
                        "⚠️ تأكد من سحب المبلغ من حساب الكاشير إلى الحساب الرئيسي أولاً.");
                }

                _logger.LogInformation(
                    "رصيد الحساب الرئيسي كافٍ للاسترداد. Balance={Balance}, RefundAmount={Amount}",
                    balanceCheck.Balance,
                    amount);


                // Important operational note from hands-on testing (2026-02-04).
                // ملاحظة تشغيلية مهمة من الاختبار العملي (2026-02-04).
                // Payment funds go to the terminal account, while refunds require the main account.
                // عند الدفع يذهب المبلغ إلى حساب الكاشير، وللاسترداد يجب أن يكون في الحساب الرئيسي.
                // Do not send transactionId in the refund request to avoid duplicate errors.
                // لا نرسل transactionId في طلب الاسترداد لتجنب أخطاء التكرار.
                var refundRequest = new SabaCashRefundRequest
                {
                    Id = originalAdjustmentId,
                    Source = new RefundSourceInfo
                    {
                        CurrencyId = currencyId,
                        IsTerminal = false  // Refund from the main account, not the terminal. الاسترداد من الحساب الرئيسي.
                    },
                    Beneficiary = new RefundBeneficiaryInfo
                    {
                        Code = customerWallet,
                        CurrencyId = currencyId
                    },
                    Amount = amount.ToString("F0"),
                    AmountCurrencyId = currencyId,
                    Note = note ?? $"إرجاع مبلغ - رقم العملية {originalAdjustmentId}"
                };

                var content = new StringContent(
                    JsonSerializer.Serialize(refundRequest),
                    Encoding.UTF8,
                    "application/json");

                var moneyReturnPath = await GetOnlineMoneyReturnPathAsync(CancellationToken.None);
                var request = await CreateAuthenticatedRequestAsync(HttpMethod.Post, moneyReturnPath, content);
                var response = await _httpClient.SendAsync(request);

                var responseContent = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    var errorResponse = JsonSerializer.Deserialize<SabaCashErrorResponse>(responseContent, _jsonOptions);
                    var errorMessage = errorResponse?.Errors?.SubErrors?.FirstOrDefault()?.Message;

                    if (errorMessage?.Contains("sufficient balance") == true)
                    {
                        errorMessage = "رصيد حساب التاجر غير كافي لإرجاع المبلغ";
                    }
                    else if (errorMessage?.Contains("not completed") == true)
                    {
                        errorMessage = "لا يمكن إرجاع مبلغ عملية غير مكتملة";
                    }
                    else if (errorMessage?.Contains("conflict") == true)
                    {
                        errorMessage = "بيانات العملية لا تتطابق مع العملية الأصلية";
                    }
                    else if (string.IsNullOrEmpty(errorMessage))
                    {
                        errorMessage = "فشلت عملية الإرجاع";
                    }

                    _logger.LogError("فشلت عملية الإرجاع عبر سبأ كاش: {Content}", responseContent);
                    throw new Exception(errorMessage);
                }

                var refundResponse = JsonSerializer.Deserialize<SabaCashPaymentResponse>(responseContent, _jsonOptions);
                _logger.LogInformation("تمت عملية الإرجاع بنجاح عبر سبأ كاش. AdjustmentId={AdjId}",
                    refundResponse.Adjustment.Id);

                // Refund confirmation always requires PATCH.
                // عملية الاسترداد تحتاج دائماً إلى PATCH لتأكيدها.
                // Even when makerChecker is false, the PATCH step is still required.
                // حتى لو كان makerChecker = false يجب إرسال PATCH لإكمال العملية.
                if (refundResponse?.Adjustment != null && refundResponse.Adjustment.Id > 0)
                {
                    _logger.LogInformation(
                        "إرسال PATCH لتأكيد عملية الإرجاع. AdjustmentId={AdjId}, MakerChecker={MakerChecker}",
                        refundResponse.Adjustment.Id,
                        refundResponse.Adjustment.MakerChecker);

                    var approvePayload = new
                    {
                        id = refundResponse.Adjustment.Id,
                        note = note ?? "online money return operation approve"
                    };

                    var approveContent = new StringContent(
                        JsonSerializer.Serialize(approvePayload),
                        Encoding.UTF8,
                        "application/json");

                    var approvePath = await GetOnlineMoneyReturnPathAsync(CancellationToken.None);
                    var approveRequest = await CreateAuthenticatedRequestAsync(HttpMethod.Patch, approvePath, approveContent);

                    var approveResponse = await _httpClient.SendAsync(approveRequest);
                    var approveResponseContent = await approveResponse.Content.ReadAsStringAsync();

                    if (!approveResponse.IsSuccessStatusCode)
                    {
                        // Check for the "Already did transaction" error - it means the operation already completed.
                        // التحقق من خطأ "Already did transaction" - يعني العملية اكتملت تلقائياً.
                        try
                        {
                            var approveError = JsonSerializer.Deserialize<SabaCashErrorResponse>(approveResponseContent, _jsonOptions);
                            var approveErrorMsg = approveError?.Errors?.SubErrors?.FirstOrDefault()?.Message ?? "";
                            
                            if (approveErrorMsg.Contains("Already did transaction") || 
                                approveErrorMsg.Contains("already processed"))
                            {
                                _logger.LogInformation(
                                    "عملية الإرجاع اكتملت مسبقاً. AdjustmentId={AdjId}",
                                    refundResponse.Adjustment.Id);
                            }
                            else
                            {
                                _logger.LogError("فشل اعتماد (PATCH) عملية الإرجاع عبر سبأ كاش. Status={Status}, Content={Content}",
                                    approveResponse.StatusCode,
                                    approveResponseContent);
                                throw new Exception("فشل اعتماد عملية الإرجاع عبر سبأ كاش");
                            }
                        }
                        catch (JsonException jsonEx)
                        {
                            _logger.LogWarning(jsonEx, "فشل تحليل استجابة الخطأ من سبأ كاش. Response={Content}", approveResponseContent);
                            // Try checking the raw text directly.
                            // محاولة التحقق من النص مباشرة.
                            if (approveResponseContent.Contains("Already did transaction") || 
                                approveResponseContent.Contains("already processed"))
                            {
                                _logger.LogInformation(
                                    "عملية الإرجاع اكتملت مسبقاً (من النص). AdjustmentId={AdjId}",
                                    refundResponse.Adjustment.Id);
                            }
                            else
                            {
                                throw new Exception($"فشل اعتماد عملية الإرجاع عبر سبأ كاش: {approveResponseContent}");
                            }
                        }
                    }
                    else
                    {
                        var approveResult = JsonSerializer.Deserialize<SabaCashConfirmResponse>(approveResponseContent, _jsonOptions);
                        if (approveResult == null || !approveResult.Completed)
                        {
                            throw new Exception("لم يتم اعتماد عملية الإرجاع عبر سبأ كاش");
                        }
                        _logger.LogInformation(
                            "تم تأكيد عملية الإرجاع بنجاح. AdjustmentId={AdjId}, TransactionId={TxnId}",
                            refundResponse.Adjustment.Id,
                            approveResult.TransactionId);
                    }
                }

                return refundResponse;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في معالجة عملية الإرجاع عبر سبأ كاش");
                throw;
            }
        }

        #endregion

        /// <summary>
        /// Initiates a payment through SabaCash.
        /// يهيئ عملية دفع عبر سبأ كاش.
        /// </summary>
        /// <param name="booking">Booking details. تفاصيل الحجز.</param>
        /// <param name="amount">Payment amount. مبلغ الدفع.</param>
        /// <param name="cancellationToken">Cancellation token. رمز الإلغاء.</param>
        /// <returns>Payment result. نتيجة الدفع.</returns>
        public async Task<PaymentResult> InitiatePaymentAsync(Booking booking, decimal amount, CancellationToken cancellationToken = default)
        {
            // This layer wraps SabaCash CreatePaymentAsync and does not persist Payment itself.
            // هذه الطبقة تغلف CreatePaymentAsync ولا تحفظ كيان Payment بنفسها.
            try
            {
                _logger.LogInformation("بدء تهيئة عملية دفع سبأ كاش للحجز {BookingId}", booking.Id);

                var note = $"دفع حجز رقم {booking.Id}";
                var response = await CreatePaymentAsync(
                    customerWallet: booking.User?.Phone ?? string.Empty,
                    amount: amount,
                    currencyCode: booking.TotalPrice?.Currency,
                    note: note);

                // Return a simplified PaymentResult; full persistence happens higher up.
                // نعيد PaymentResult مبسطاً؛ والحفظ الكامل يتم في مستوى أعلى.
                return new PaymentResult
                {
                    IsSuccess = response != null,
                    TransactionId = response?.Adjustment?.TransactionId ?? string.Empty,
                    Message = response != null
                        ? "تم إنشاء عملية الدفع عبر سبأ كاش وإرسال رمز التحقق إلى رقم هاتف العميل"
                        : "فشل في إنشاء عملية الدفع عبر سبأ كاش",
                    Status = Core.Enums.PaymentStatus.Pending,
                    ProcessedAmount = amount,
                    Fees = 0,
                    ProcessedAt = DateTime.UtcNow,
                    GatewayTransactionId = response?.Adjustment?.Id.ToString() ?? string.Empty
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء تهيئة عملية دفع سبأ كاش للحجز {BookingId}", booking.Id);
                return new PaymentResult
                {
                    IsSuccess = false,
                    TransactionId = string.Empty,
                    Message = ex.Message,
                    Status = Core.Enums.PaymentStatus.Failed,
                    ProcessedAmount = 0,
                    Fees = 0,
                    ProcessedAt = DateTime.UtcNow
                };
            }
        }

        /// <summary>
        /// Confirms a SabaCash payment.
        /// يؤكد عملية دفع عبر سبأ كاش.
        /// </summary>
        /// <param name="payment">Payment record. سجل الدفع.</param>
        /// <param name="otp">OTP code. رمز التحقق.</param>
        /// <param name="cancellationToken">Cancellation token. رمز الإلغاء.</param>
        /// <returns>Payment result. نتيجة الدفع.</returns>
        public async Task<PaymentResult> ConfirmPaymentAsync(Payment payment, string otp, CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation("بدء تأكيد عملية دفع سبأ كاش للدفعة {PaymentId}", payment.Id);

                // In this implementation we expect the adjustment id in GatewayTransactionId or a similar field.
                // في هذه النسخة نفترض أن معرف العملية مخزن داخل GatewayTransactionId أو حقل مشابه.
                var adjustmentId = payment.GatewayTransactionId;

                var confirmResponse = await ConfirmPaymentInternalAsync(
                    adjustmentId: adjustmentId,
                    otp: otp,
                    note: "تأكيد عملية دفع سبأ كاش");

                var isCompleted = confirmResponse?.Completed == true;

                if (isCompleted)
                {
                    payment.Status = Core.Enums.PaymentStatus.Successful;
                    payment.TransactionId = confirmResponse.TransactionId;
                    payment.ProcessedAt = DateTime.UtcNow;
                }

                await _paymentRepository.UpdatePaymentAsync(payment, cancellationToken);
                await _paymentRepository.SaveChangesAsync(cancellationToken);
                
                _logger.LogInformation(
                    "✅ تم حفظ تحديث حالة دفعة سبأ كاش: PaymentId={PaymentId}, NewStatus={Status}",
                    payment.Id, payment.Status);

                return new PaymentResult
                {
                    IsSuccess = isCompleted,
                    TransactionId = confirmResponse?.TransactionId ?? string.Empty,
                    Message = isCompleted ? "تم تأكيد عملية الدفع بنجاح" : "فشل تأكيد عملية الدفع",
                    Status = isCompleted ? Core.Enums.PaymentStatus.Successful : Core.Enums.PaymentStatus.Failed,
                    ProcessedAmount = payment.Amount.Amount,
                    Fees = 0,
                    ProcessedAt = DateTime.UtcNow
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء تأكيد عملية دفع سبأ كاش للدفعة {PaymentId}", payment.Id);
                return new PaymentResult
                {
                    IsSuccess = false,
                    TransactionId = string.Empty,
                    Message = ex.Message,
                    Status = Core.Enums.PaymentStatus.Failed,
                    ProcessedAmount = 0,
                    Fees = 0,
                    ProcessedAt = DateTime.UtcNow
                };
            }
        }

        /// <summary>
        /// Refunds a payment through SabaCash.
        /// يعيد مبلغاً عبر سبأ كاش.
        /// </summary>
        /// <param name="payment">Payment record. سجل الدفع.</param>
        /// <param name="booking">Related booking. الحجز المرتبط.</param>
        /// <param name="refundAmount">Refund amount. مبلغ الاسترداد.</param>
        /// <param name="reason">Refund reason. سبب الاسترداد.</param>
        /// <param name="cancellationToken">Cancellation token. رمز الإلغاء.</param>
        /// <returns>Refund result. نتيجة الاسترداد.</returns>
        public async Task<RefundResult> RefundAsync(
            Payment payment,
            Booking booking,
            decimal refundAmount,
            string reason,
            CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation(
                    "بدء استرداد مبلغ عبر سبأ كاش للدفعة {PaymentId} بمبلغ {Amount}",
                    payment.Id,
                    refundAmount);

                var originalAdjustmentId = payment.GatewayTransactionId;
                if (string.IsNullOrWhiteSpace(originalAdjustmentId))
                {
                    throw new InvalidOperationException("معرف العملية الأصلية (AdjustmentId) غير متوفر في الدفعة");
                }

                var customerWallet = booking.User?.Phone;
                if (string.IsNullOrWhiteSpace(customerWallet))
                {
                    throw new InvalidOperationException("رقم محفظة العميل غير معروف. يرجى التأكد من وجود رقم هاتف مفعّل للمستخدم");
                }

                var currencyCode = !string.IsNullOrWhiteSpace(payment.Amount.Currency)
                    ? payment.Amount.Currency
                    : booking.TotalPrice?.Currency;

                var refundResponse = await RefundPaymentInternalAsync(
                    originalAdjustmentId: originalAdjustmentId,
                    customerWallet: customerWallet,
                    amount: refundAmount,
                    currencyCode: currencyCode,
                    note: reason ?? "استرداد مبلغ عبر سبأ كاش");

                var refundId = refundResponse?.Adjustment != null
                    ? refundResponse.Adjustment.Id.ToString()
                    : string.Empty;

                _logger.LogInformation(
                    "تم إنشاء عملية استرداد عبر سبأ كاش بنجاح. RefundId={RefundId}, OriginalPaymentId={PaymentId}",
                    refundId,
                    payment.Id);

                return new RefundResult
                {
                    IsSuccess = true,
                    RefundId = refundId,
                    Message = "تم استرداد المبلغ عبر سبأ كاش بنجاح",
                    RefundedAmount = refundAmount,
                    RefundedAt = DateTime.UtcNow
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(
                    ex,
                    "خطأ أثناء استرداد مبلغ عبر سبأ كاش للدفعة {PaymentId}",
                    payment.Id);

                return new RefundResult
                {
                    IsSuccess = false,
                    RefundId = string.Empty,
                    Message = ex.Message,
                    RefundedAmount = 0,
                    RefundedAt = DateTime.UtcNow
                };
            }
        }
    }
}
