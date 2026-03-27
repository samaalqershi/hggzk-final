using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using YemenBooking.Application.Features.Payments.Services;
using YemenBooking.Application.Contracts.Services.Wallets;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Wallets.Jwali;

namespace YemenBooking.Infrastructure.Services.Wallets
{
    /// <summary>
    /// يمثل خدمة محفظة جوالي لمسارات الدفع والاسترداد.
    /// Represents the Jwali wallet service for payment and refund flows.
    /// </summary>
    public class JwaliWalletService : IJwaliWalletService
    {
        // HTTP client for the Jwali API.
        // عميل HTTP للتواصل مع واجهة جوالي.
        private readonly HttpClient _httpClient;

        // Application configuration for connectivity and credentials.
        // إعدادات التطبيق لبيانات الاتصال والاعتمادات.
        private readonly IConfiguration _configuration;

        // In-memory cache for login and wallet access tokens.
        // ذاكرة مؤقتة لرموز الدخول والوصول.
        private readonly IMemoryCache _cache;
        private const string LOGIN_TOKEN_CACHE_KEY = "Jwali_LoginToken";
        private const string WALLET_TOKEN_CACHE_KEY = "Jwali_WalletAccessToken";

        private readonly ILogger<JwaliWalletService> _logger;

        /// <summary>
        /// ينشئ مثيلًا جديدًا من خدمة محفظة جوالي.
        /// Creates a new instance of the Jwali wallet service.
        /// </summary>
        /// <param name="httpClient">Configured HTTP client. عميل HTTP المهيأ.</param>
        /// <param name="configuration">Application configuration. إعدادات التطبيق.</param>
        /// <param name="cache">In-memory cache. الذاكرة المؤقتة.</param>
        /// <param name="logger">Logger instance. كائن تسجيل الأحداث.</param>
        public JwaliWalletService(
            HttpClient httpClient,
            IConfiguration configuration,
            IMemoryCache cache,
            ILogger<JwaliWalletService> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _cache = cache;
            _logger = logger;

            // Initialize the base API address for Jwali.
            // تهيئة عنوان الـ API الأساسي لمحفظة جوالي.
            // BaseUrl may be a full endpoint URL.
            // يمكن أن يكون BaseUrl هو الرابط الكامل لنقطة النهاية.
            var baseUrl = _configuration["Jwali:BaseUrl"];
            if (string.IsNullOrWhiteSpace(baseUrl))
            {
                _logger.LogWarning("لم يتم ضبط قيمة Jwali:BaseUrl في ملف الإعدادات. لن تعمل عمليات محفظة جوالي بدون هذا الإعداد.");
            }
            else
            {
                _httpClient.BaseAddress = new Uri(baseUrl);
            }
        }

        #region Low-level helpers (Header + HTTP)

        private string GetOAuthTokenPath() => _configuration["Jwali:OAuthTokenPath"] ?? "/paygate/oauth/token";

        private string GetCallWsPath() => _configuration["Jwali:CallWsPath"] ?? "/paygate/v1/ws/callWS";

        private static string GetStringOrThrow(IConfiguration configuration, string key, string error)
        {
            var value = configuration[key];
            if (string.IsNullOrWhiteSpace(value))
            {
                throw new InvalidOperationException(error);
            }

            return value;
        }

        private static JToken? GetResponseBodyValue(JObject response, params string[] candidateKeys)
        {
            var responseBody = response["responseBody"] as JObject ?? response["ResponseBody"] as JObject;
            if (responseBody == null || candidateKeys == null || candidateKeys.Length == 0)
            {
                return null;
            }

            foreach (var key in candidateKeys)
            {
                if (string.IsNullOrWhiteSpace(key))
                {
                    continue;
                }

                var directValue = responseBody[key];
                if (directValue != null)
                {
                    return directValue;
                }

                var matchedProperty = responseBody.Properties()
                    .FirstOrDefault(p => string.Equals(p.Name, key, StringComparison.OrdinalIgnoreCase));
                if (matchedProperty != null)
                {
                    return matchedProperty.Value;
                }
            }

            return null;
        }

        private static string GetResponseBodyString(JObject response, params string[] candidateKeys)
        {
            var token = GetResponseBodyValue(response, candidateKeys);
            return token == null || token.Type == JTokenType.Null ? string.Empty : token.ToString();
        }

        private static bool TryParseResponseBodyDecimal(JObject response, out decimal value, params string[] candidateKeys)
        {
            var token = GetResponseBodyValue(response, candidateKeys);
            return TryParseTokenDecimal(token, out value);
        }

        private static bool TryParseTokenDecimal(JToken? token, out decimal value)
        {
            value = 0m;
            if (token == null || token.Type == JTokenType.Null)
            {
                return false;
            }

            if (token.Type == JTokenType.Integer || token.Type == JTokenType.Float)
            {
                value = token.Value<decimal>();
                return true;
            }

            var raw = token.ToString().Trim();
            if (string.IsNullOrWhiteSpace(raw))
            {
                return false;
            }

            var normalized = NormalizeDigits(raw)
                .Replace("٬", ",", StringComparison.Ordinal)
                .Replace("٫", ".", StringComparison.Ordinal);

            if (decimal.TryParse(normalized, NumberStyles.Number, CultureInfo.InvariantCulture, out value))
            {
                return true;
            }

            if (decimal.TryParse(normalized, NumberStyles.Number, CultureInfo.CurrentCulture, out value))
            {
                return true;
            }

            var compact = normalized.Replace(",", string.Empty, StringComparison.Ordinal)
                .Replace(" ", string.Empty, StringComparison.Ordinal);

            return decimal.TryParse(compact, NumberStyles.Number, CultureInfo.InvariantCulture, out value);
        }

        private static string NormalizeDigits(string input)
        {
            if (string.IsNullOrEmpty(input))
            {
                return input;
            }

            var normalized = new StringBuilder(input.Length);
            foreach (var ch in input)
            {
                if (ch >= '\u0660' && ch <= '\u0669')
                {
                    normalized.Append((char)('0' + (ch - '\u0660')));
                }
                else if (ch >= '\u06F0' && ch <= '\u06F9')
                {
                    normalized.Append((char)('0' + (ch - '\u06F0')));
                }
                else
                {
                    normalized.Append(ch);
                }
            }

            return normalized.ToString();
        }

        private JObject BuildHeaderObject(string serviceName, string domainName)
        {
            return new JObject
            {
                ["serviceDetail"] = new JObject
                {
                    ["corrID"] = Guid.NewGuid().ToString(),
                    ["domainName"] = domainName,
                    ["serviceName"] = serviceName
                },
                ["signonDetail"] = new JObject
                {
                    ["clientID"] = _configuration["Jwali:ClientID"] ?? string.Empty,
                    ["orgID"] = _configuration["Jwali:OrgID"] ?? string.Empty,
                    ["userID"] = _configuration["Jwali:UserID"] ?? string.Empty,
                    ["externalUser"] = _configuration["Jwali:ExternalUser"] ?? "External User"
                },
                ["messageContext"] = new JObject
                {
                    ["clientDate"] = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds().ToString(),
                    ["bodyType"] = "Clear"
                }
            };
        }

        private async Task<string> GetLoginTokenAsync(CancellationToken cancellationToken)
        {
            if (_cache.TryGetValue(LOGIN_TOKEN_CACHE_KEY, out string cachedToken) && !string.IsNullOrWhiteSpace(cachedToken))
            {
                return cachedToken;
            }

            var username = GetStringOrThrow(_configuration, "Jwali:UserID", "إعدادات جوالي غير مكتملة. يجب ضبط Jwali:UserID لاستخدامه في عملية LOGIN.");
            var password = _configuration["Jwali:UserPwd"] ?? _configuration["Jwali:UserPassword"] ?? _configuration["Jwali:Password"];
            if (string.IsNullOrWhiteSpace(password))
            {
                throw new InvalidOperationException("إعدادات جوالي غير مكتملة. يجب ضبط Jwali:UserPwd (كلمة مرور المستخدم) لعملية LOGIN.");
            }

            var form = new FormUrlEncodedContent(new[]
            {
                new KeyValuePair<string, string>("username", username),
                new KeyValuePair<string, string>("password", password),
                new KeyValuePair<string, string>("grant_type", _configuration["Jwali:GrantType"] ?? "password"),
                new KeyValuePair<string, string>("client_id", _configuration["Jwali:OAuthClientId"] ?? "restapp"),
                new KeyValuePair<string, string>("client_secret", _configuration["Jwali:OAuthClientSecret"] ?? "restapp"),
                new KeyValuePair<string, string>("scope", _configuration["Jwali:Scope"] ?? "read")
            });

            var request = new HttpRequestMessage(HttpMethod.Post, GetOAuthTokenPath())
            {
                Content = form
            };

            var response = await _httpClient.SendAsync(request, cancellationToken);
            var responseContent = await response.Content.ReadAsStringAsync(cancellationToken);

            if (!response.IsSuccessStatusCode)
            {
                _logger.LogError("فشل LOGIN (oauth/token) لمحفظة جوالي. Status={Status}", response.StatusCode);
                throw new Exception("فشل LOGIN لمحفظة جوالي");
            }

            var json = JObject.Parse(responseContent);
            var token = json.Value<string>("access_token") ?? string.Empty;
            if (string.IsNullOrWhiteSpace(token))
            {
                throw new Exception("لم يتم إرجاع access_token من LOGIN");
            }

            var expiresIn = json.Value<int?>("expires_in") ?? (60 * 60);
            var cacheFor = TimeSpan.FromSeconds(Math.Max(60, expiresIn - 60));
            _cache.Set(LOGIN_TOKEN_CACHE_KEY, token, cacheFor);
            return token;
        }

        private async Task<string> GetWalletAccessTokenAsync(string loginToken, CancellationToken cancellationToken)
        {
            if (_cache.TryGetValue(WALLET_TOKEN_CACHE_KEY, out string cachedToken) && !string.IsNullOrWhiteSpace(cachedToken))
            {
                return cachedToken;
            }

            var agentWallet = GetStringOrThrow(_configuration, "Jwali:AgentWallet", "إعدادات محفظة جوالي غير مكتملة. يجب ضبط Jwali:AgentWallet.");
            var walletPassword = GetStringOrThrow(_configuration, "Jwali:Password", "إعدادات محفظة جوالي غير مكتملة. يجب ضبط Jwali:Password.");

            var payload = new JObject
            {
                ["header"] = BuildHeaderObject("PAYWA.WALLETAUTHENTICATION", _configuration["Jwali:WalletDomainName"] ?? "WalletDomain"),
                ["body"] = new JObject
                {
                    ["identifier"] = agentWallet,
                    ["password"] = walletPassword
                }
            };

            var response = await PostCallWsAsync(payload, loginToken, cancellationToken);
            var token = response.SelectToken("responseBody.access_token")?.ToString() ?? string.Empty;

            if (string.IsNullOrWhiteSpace(token))
            {
                throw new Exception("لم يتم إرجاع access_token من WALLETAUTHENTICATION");
            }

            _cache.Set(WALLET_TOKEN_CACHE_KEY, token, TimeSpan.FromMinutes(30));
            return token;
        }

        private async Task<JObject> PostCallWsAsync(JObject payload, string loginToken, CancellationToken cancellationToken)
        {
            var json = payload.ToString(Formatting.None);
            
            // Log the request payload for debugging
            var serviceName = payload.SelectToken("header.serviceDetail.serviceName")?.ToString() ?? "Unknown";
            _logger.LogInformation("📤 إرسال طلب {ServiceName}. Payload: {Payload}", serviceName, json);
            
            var request = new HttpRequestMessage(HttpMethod.Post, GetCallWsPath())
            {
                Content = new StringContent(json, Encoding.UTF8, "application/json")
            };

            request.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", loginToken);

            var response = await _httpClient.SendAsync(request, cancellationToken);
            var responseContent = await response.Content.ReadAsStringAsync(cancellationToken);
            
            // Log the response for debugging
            _logger.LogInformation("📥 استجابة {ServiceName}: {Response}", serviceName, responseContent);

            if (!response.IsSuccessStatusCode)
            {
                _logger.LogError("فشل استدعاء callWS لمحفظة جوالي. Status={Status}, Response={Response}", response.StatusCode, responseContent);
                throw new Exception("فشل الاتصال بخدمة جوالي");
            }

            var obj = JObject.Parse(responseContent);

            var systemStatus = obj.SelectToken("responseStatus.systemStatus")?.ToString();
            if (!string.IsNullOrWhiteSpace(systemStatus) && systemStatus != "0")
            {
                var desc = obj.SelectToken("responseStatus.systemStatusDesc")?.ToString() ?? "Unknown";
                var descNative = obj.SelectToken("responseStatus.systemStatusDescNative")?.ToString();
                _logger.LogWarning(
                    "⚠️ استجابة جوالي تحتوي على systemStatus غير ناجح. systemStatus={SystemStatus}, Desc={Desc}, DescNative={DescNative}, Service={Service}",
                    systemStatus,
                    desc,
                    descNative,
                    serviceName);
            }

            return obj;
        }

        private async Task<JObject> AgentCheckStatusAsync(
            string agentWallet,
            string walletPassword,
            string walletAccessToken,
            string refId,
            string loginToken,
            CancellationToken cancellationToken)
        {
            var payload = new JObject
            {
                ["header"] = BuildHeaderObject("PAYWA.AGENTCHECKSTATUS", _configuration["Jwali:WalletDomainName"] ?? "WalletDomain"),
                ["body"] = new JObject
                {
                    ["agentWallet"] = agentWallet,
                    ["password"] = walletPassword,
                    ["accessToken"] = walletAccessToken,
                    ["refId"] = refId
                }
            };

            return await PostCallWsAsync(payload, loginToken, cancellationToken);
        }

        private async Task<(bool Success, decimal Balance, string Message)> GetWalletBalanceAsync(
            string loginToken,
            string walletAccessToken,
            CancellationToken cancellationToken)
        {
            try
            {
                var agentWallet = GetStringOrThrow(_configuration, "Jwali:AgentWallet", "إعدادات محفظة جوالي غير مكتملة. يجب ضبط Jwali:AgentWallet.");
                var walletPassword = GetStringOrThrow(_configuration, "Jwali:Password", "إعدادات محفظة جوالي غير مكتملة. يجب ضبط Jwali:Password.");

                var payload = new JObject
                {
                    ["header"] = BuildHeaderObject("PAYWA.WALLETBALANCE", _configuration["Jwali:WalletDomainName"] ?? "WalletDomain"),
                    ["body"] = new JObject
                    {
                        ["identifier"] = agentWallet,
                        ["password"] = walletPassword,
                        ["accessToken"] = walletAccessToken
                    }
                };

                var response = await PostCallWsAsync(payload, loginToken, cancellationToken);
                
                var systemStatus = response.SelectToken("responseStatus.systemStatus")?.ToString();
                if (systemStatus != "0")
                {
                    var desc = response.SelectToken("responseStatus.systemStatusDesc")?.ToString() ?? "Unknown";
                    var descNative = response.SelectToken("responseStatus.systemStatusDescNative")?.ToString();
                    return (false, 0, descNative ?? desc);
                }

                var balance = response.SelectToken("responseBody.balance")?.Value<decimal>() ?? 0m;
                return (true, balance, "تم الاستعلام عن الرصيد بنجاح");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ في الاستعلام عن رصيد محفظة جوالي");
                return (false, 0, ex.Message);
            }
        }

        #endregion

        #region Public API - حجز عبر جوالي

        /// <summary>
        /// Processes a booking payment through Jwali.
        /// يعالج عملية دفع الحجز عبر جوالي.
        /// </summary>
        /// <param name="booking">Target booking. الحجز المستهدف.</param>
        /// <param name="amount">Payment amount. مبلغ الدفع.</param>
        /// <param name="voucher">Payment voucher or reference. قسيمة أو مرجع الدفع.</param>
        /// <param name="receiverMobile">Receiver mobile number. رقم هاتف المستلم.</param>
        /// <param name="cancellationToken">Cancellation token. رمز الإلغاء.</param>
        /// <returns>Payment processing result. نتيجة معالجة الدفع.</returns>
        public async Task<PaymentResult> ProcessBookingPaymentAsync(
            Booking booking,
            decimal amount,
            string voucher,
            string? receiverMobile,
            CancellationToken cancellationToken = default)
        {
            if (booking == null)
            {
                throw new ArgumentNullException(nameof(booking));
            }

            if (amount <= 0)
            {
                throw new ArgumentException("المبلغ يجب أن يكون أكبر من صفر", nameof(amount));
            }

            if (string.IsNullOrWhiteSpace(voucher))
            {
                throw new ArgumentException("كود القسيمة (Voucher) مطلوب لعملية جوالي", nameof(voucher));
            }

            // receiverMobile is required by the ECOMMERCEINQUIRY flow.
            // receiverMobile إلزامي في ECOMMERCEINQUIRY حسب وثائق جوالي.
            // If missing, fall back to the booking user's phone.
            // إذا لم يُرسل، نحاول استخدام رقم هاتف العميل من الحجز.
            var effectiveReceiverMobile = receiverMobile;
            if (string.IsNullOrWhiteSpace(effectiveReceiverMobile))
            {
                effectiveReceiverMobile = booking.User?.Phone;
            }
            
            if (string.IsNullOrWhiteSpace(effectiveReceiverMobile))
            {
                throw new ArgumentException("رقم هاتف العميل (receiverMobile) مطلوب لعملية الدفع عبر جوالي", nameof(receiverMobile));
            }

            try
            {
                // Strictly validate amount and currency before any external call.
                // تحقق صارم من المبلغ والعملة قبل أي استعلام خارجي.
                var totalAmount = booking.TotalPrice?.Amount ?? 0m;
                var totalCurrency = booking.TotalPrice?.Currency ?? "YER";
                if (decimal.Round(amount, 2) != decimal.Round(totalAmount, 2))
                {
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = string.Empty,
                        Message = $"المبلغ المدفوع ({amount}) لا يطابق مبلغ الحجز المطلوب ({totalAmount}). يجب دفع كامل مبلغ الحجز.",
                        Status = PaymentStatus.Failed,
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow,
                        GatewayTransactionId = string.Empty
                    };
                }
                if (!string.Equals(totalCurrency, booking.TotalPrice?.Currency ?? "YER", StringComparison.OrdinalIgnoreCase))
                {
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = string.Empty,
                        Message = $"العملة المدفوعة ({booking.TotalPrice?.Currency}) لا تطابق عملة الحجز المطلوبة ({totalCurrency}). يجب الدفع بنفس العملة.",
                        Status = PaymentStatus.Failed,
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow,
                        GatewayTransactionId = string.Empty
                    };
                }
                _logger.LogInformation(
                    "بدء معالجة دفع حجز عبر محفظة جوالي. BookingId={BookingId}, Voucher={Voucher}, ReceiverMobile={ReceiverMobile}",
                    booking.Id,
                    voucher,
                    effectiveReceiverMobile);

                var agentWallet = GetStringOrThrow(_configuration, "Jwali:AgentWallet", "إعدادات محفظة جوالي غير مكتملة. يجب ضبط Jwali:AgentWallet.");
                var walletPassword = GetStringOrThrow(_configuration, "Jwali:Password", "إعدادات محفظة جوالي غير مكتملة. يجب ضبط Jwali:Password.");

                var bookingCurrency = booking.TotalPrice?.Currency ?? "YER";

                    // refId must always stay within 32 characters.
                    // يجب أن يكون طول refId ضمن 32 حرفاً دائماً.
                    var refId = Guid.NewGuid().ToString("N").Substring(0, 32);

                var loginToken = await GetLoginTokenAsync(cancellationToken);
                var walletAccessToken = await GetWalletAccessTokenAsync(loginToken, cancellationToken);

                // Field order follows the ECOMMERCEINQUIRY documentation exactly.
                // ترتيب الحقول يطابق وثائق ECOMMERCEINQUIRY بدقة.
                // agentWallet, voucher, receiverMobile, password, accessToken, refId, txncurrency, purpose
                var inquiryPayload = new JObject
                {
                    ["header"] = BuildHeaderObject("PAYAG.ECOMMERCEINQUIRY", _configuration["Jwali:MerchantDomainName"] ?? "MerchantDomain"),
                    ["body"] = new JObject
                    {
                        ["agentWallet"] = agentWallet,
                        ["voucher"] = voucher,
                        ["receiverMobile"] = effectiveReceiverMobile, // Required by Jwali docs. إلزامي حسب وثائق جوالي.
                        ["password"] = walletPassword,
                        ["accessToken"] = walletAccessToken,
                        ["refId"] = refId,
                        ["txncurrency"] = bookingCurrency,
                        ["purpose"] = $"Booking Payment #{booking.Id}"
                    }
                };

                _logger.LogInformation(
                    "إرسال ECOMMERCEINQUIRY. AgentWallet={AgentWallet}, Voucher={Voucher}, ReceiverMobile={ReceiverMobile}, Currency={Currency}",
                    agentWallet, voucher, effectiveReceiverMobile, bookingCurrency);

                var inquiryResponse = await PostCallWsAsync(inquiryPayload, loginToken, cancellationToken);

                var issuerTrxRef = GetResponseBodyString(inquiryResponse, "issuerTrxRef", "IssuerTrxRef");
                var state = GetResponseBodyString(inquiryResponse, "state", "State").ToUpperInvariant();
                var txnCurrency = GetResponseBodyString(inquiryResponse, "txncurrency", "txnCurrency", "TxnCurrency");
                var inquiryReceiverMobile = GetResponseBodyString(inquiryResponse, "receiverMobile", "ReceiverMobile");

                var hasTxnAmount = TryParseResponseBodyDecimal(
                    inquiryResponse,
                    out var txnAmount,
                    "txnamount",
                    "txnAmount",
                    "TxnAmount");

                // استخدام الـ receiverMobile من الاستجابة إذا وُجد، وإلا استخدام ما أرسلناه
                var finalReceiverMobile = !string.IsNullOrWhiteSpace(inquiryReceiverMobile)
                    ? inquiryReceiverMobile
                    : effectiveReceiverMobile;

                if (!hasTxnAmount)
                {
                    var responseBody = inquiryResponse["responseBody"] as JObject ?? inquiryResponse["ResponseBody"] as JObject;
                    var responseBodyKeys = responseBody == null
                        ? "<none>"
                        : string.Join(", ", responseBody.Properties().Select(p => p.Name));

                    _logger.LogWarning(
                        "تعذر قراءة مبلغ الفاتورة من استجابة ECOMMERCEINQUIRY. BookingId={BookingId}, Voucher={Voucher}, ResponseBodyKeys=[{ResponseBodyKeys}]",
                        booking.Id,
                        voucher,
                        responseBodyKeys);

                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = issuerTrxRef,
                        Message = "تعذر قراءة مبلغ الفاتورة من جوالي. يرجى إنشاء كود شراء جديد والمحاولة مرة أخرى",
                        Status = PaymentStatus.Failed,
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow,
                        GatewayTransactionId = refId
                    };
                }

                if (string.IsNullOrWhiteSpace(state))
                {
                    var desc = inquiryResponse.SelectToken("responseStatus.systemStatusDesc")?.ToString() ?? "Unknown";
                    var descNative = inquiryResponse.SelectToken("responseStatus.systemStatusDescNative")?.ToString();
                    
                    // تحسين رسالة الخطأ للمستخدم
                    var userMessage = desc;
                    if (!string.IsNullOrWhiteSpace(descNative))
                    {
                        if (descNative.Contains("Do not honor", StringComparison.OrdinalIgnoreCase))
                        {
                            userMessage = "كود الشراء غير صالح أو مستخدم مسبقاً. يرجى إنشاء كود شراء جديد من تطبيق جوالي";
                        }
                        else if (descNative.Contains("not found", StringComparison.OrdinalIgnoreCase))
                        {
                            userMessage = "كود الشراء غير موجود. يرجى التأكد من صحة الكود";
                        }
                        else
                        {
                            userMessage = $"{desc}: {descNative}";
                        }
                    }
                    
                    _logger.LogWarning(
                        "فشل الاستعلام عن كود جوالي. Voucher={Voucher}, Desc={Desc}, DescNative={DescNative}",
                        voucher, desc, descNative);
                    
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = issuerTrxRef,
                        Message = userMessage,
                        Status = PaymentStatus.Failed,
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow,
                        GatewayTransactionId = refId
                    };
                }

                var isCashable = state == "PENDING";
                var isAlreadyCashed = state == "ACCEPTED";
                if (!isCashable && !isAlreadyCashed)
                {
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = issuerTrxRef,
                        Message = $"لا يمكن تنفيذ السحب لأن حالة الكود في جوالي هي {state}",
                        Status = PaymentStatus.Failed,
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow,
                        GatewayTransactionId = refId
                    };
                }

                if (!string.IsNullOrWhiteSpace(txnCurrency) &&
                    !string.Equals(txnCurrency, bookingCurrency, StringComparison.OrdinalIgnoreCase))
                {
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = issuerTrxRef,
                        Message = "عملة الفاتورة في جوالي لا تطابق عملة الحجز في النظام",
                        Status = PaymentStatus.Failed,
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow,
                        GatewayTransactionId = refId
                    };
                }

                if (decimal.Round(txnAmount, 2) != decimal.Round(amount, 2))
                {
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = issuerTrxRef,
                        Message = "مبلغ الفاتورة في جوالي لا يطابق مبلغ الحجز في النظام",
                        Status = PaymentStatus.Failed,
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow,
                        GatewayTransactionId = refId
                    };
                }

                if (isAlreadyCashed)
                {
                    // ⚠️ Security warning: the purchase code was already cashed out.
                    // ⚠️ تحذير أمني: كود الشراء مصروف مسبقاً.
                    // Do not auto-accept this state because it may belong to another booking.
                    // لا نقبل هذه الحالة تلقائياً لأنه قد يكون مصروفاً لحجز آخر.
                    // The customer must generate a new purchase code.
                    // يجب على العميل استخدام كود شراء جديد.
                    _logger.LogWarning(
                        "محاولة استخدام كود شراء مصروف مسبقاً. BookingId={BookingId}, Voucher={Voucher}, IssuerTrxRef={IssuerTrxRef}",
                        booking.Id,
                        voucher,
                        issuerTrxRef);
                    
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = issuerTrxRef,
                        Message = "كود الشراء تم استخدامه مسبقاً. يرجى إنشاء كود شراء جديد من تطبيق جوالي",
                        Status = PaymentStatus.Failed,
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow,
                        GatewayTransactionId = refId
                    };
                }

                // ⚠️ Important: ECOMMCASHOUT must use a different refId than ECOMMERCEINQUIRY.
                // ⚠️ مهم: يجب استخدام refId مختلف لـ ECOMMCASHOUT عن الـ refId المستخدم في ECOMMERCEINQUIRY.
                // Jwali rejects reusing the same refId twice.
                // جوالي يرفض استخدام نفس الـ refId مرتين.
                // cashoutRefId must always stay within 32 characters.
                // يجب أن يكون طول cashoutRefId ≤ 32 حرفاً دائماً.
                var cashoutRefId = Guid.NewGuid().ToString("N").Substring(0, 32);
                
                // Field ordering follows the ECOMMCASHOUT documentation exactly.
                // ترتيب الحقول حسب وثائق ECOMMCASHOUT بالضبط.
                var cashoutPayload = new JObject
                {
                    ["header"] = BuildHeaderObject("PAYAG.ECOMMCASHOUT", _configuration["Jwali:MerchantDomainName"] ?? "MerchantDomain"),
                    ["body"] = new JObject
                    {
                        ["agentWallet"] = agentWallet,
                        ["voucher"] = voucher,
                        ["receiverMobile"] = finalReceiverMobile, // Required by Jwali docs. إلزامي حسب وثائق جوالي.
                        ["password"] = walletPassword,
                        ["accessToken"] = walletAccessToken,
                        ["refId"] = cashoutRefId, // New refId for Cashout. refId جديد خاص بـ Cashout.
                        ["purpose"] = $"Booking Payment #{booking.Id}",
                        ["amount"] = (int)amount, // Docs use an integer value. الوثائق تستخدم رقم صحيح.
                        ["currency"] = bookingCurrency
                    }
                };

                var cashoutResponse = await PostCallWsAsync(cashoutPayload, loginToken, cancellationToken);
                var status = (
                        cashoutResponse.SelectToken("responseBody.status")?.ToString()
                        ?? cashoutResponse.SelectToken("responseBody.Status")?.ToString()
                        ?? string.Empty)
                    .ToUpperInvariant();
                var issuerRef = cashoutResponse.SelectToken("responseBody.IssuerRef")?.ToString() ??
                                cashoutResponse.SelectToken("responseBody.issuerRef")?.ToString() ?? string.Empty;

                if (string.IsNullOrWhiteSpace(status))
                {
                    var desc = cashoutResponse.SelectToken("responseStatus.systemStatusDesc")?.ToString() ?? "Unknown";
                    var descNative = cashoutResponse.SelectToken("responseStatus.systemStatusDescNative")?.ToString();
                    var userMessage = !string.IsNullOrWhiteSpace(descNative) ? $"{desc}: {descNative}" : desc;
                    
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = issuerRef,
                        Message = userMessage,
                        Status = PaymentStatus.Failed,
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow,
                        GatewayTransactionId = cashoutRefId
                    };
                }

                var isAccepted = status == "ACCEPTED" || status == "SUCCESS";
                if (!isAccepted)
                {
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = issuerRef,
                        Message = cashoutResponse.SelectToken("responseStatus.systemStatusDesc")?.ToString() ?? "فشلت عملية السحب (Cashout) عبر محفظة جوالي",
                        Status = PaymentStatus.Failed,
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow,
                        GatewayTransactionId = cashoutRefId
                    };
                }

                string? checkStatus = null;
                JObject? checkStatusResponse = null;
                for (var i = 0; i < 3; i++)
                {
                    checkStatusResponse = await AgentCheckStatusAsync(
                        agentWallet,
                        walletPassword,
                        walletAccessToken,
                        cashoutRefId, // استخدام cashoutRefId للتحقق من حالة عملية Cashout
                        loginToken,
                        cancellationToken);

                    checkStatus = (
                            checkStatusResponse.SelectToken("responseBody.status")?.ToString()
                            ?? checkStatusResponse.SelectToken("responseBody.Status")?.ToString()
                            ?? checkStatusResponse.SelectToken("responseBody.state")?.ToString()
                            ?? checkStatusResponse.SelectToken("responseBody.State")?.ToString()
                            ?? string.Empty)
                        .ToUpperInvariant();

                    if (string.IsNullOrWhiteSpace(checkStatus))
                    {
                        break;
                    }

                    if (checkStatus is "ACCEPTED" or "SUCCESS" or "COMPLETED")
                    {
                        break;
                    }

                    if (checkStatus is "PENDING" or "PROCESSING")
                    {
                        await Task.Delay(TimeSpan.FromMilliseconds(800), cancellationToken);
                        continue;
                    }

                    break;
                }

                if (!string.IsNullOrWhiteSpace(checkStatus) &&
                    !(checkStatus is "ACCEPTED" or "SUCCESS" or "COMPLETED"))
                {
                    var desc = checkStatusResponse?.SelectToken("responseStatus.systemStatusDesc")?.ToString();
                    return new PaymentResult
                    {
                        IsSuccess = false,
                        TransactionId = issuerRef,
                        Message = desc ?? $"عملية جوالي لم تكتمل. الحالة الحالية: {checkStatus}",
                        Status = PaymentStatus.Failed,
                        ProcessedAmount = 0,
                        Fees = 0,
                        ProcessedAt = DateTime.UtcNow,
                        GatewayTransactionId = cashoutRefId
                    };
                }

                return new PaymentResult
                {
                    IsSuccess = true,
                    TransactionId = issuerRef,
                    Message = "تم تنفيذ عملية الدفع عبر محفظة جوالي بنجاح",
                    Status = PaymentStatus.Successful,
                    ProcessedAmount = amount,
                    Fees = 0,
                    ProcessedAt = DateTime.UtcNow,
                    GatewayTransactionId = cashoutRefId
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "خطأ أثناء معالجة دفع حجز عبر محفظة جوالي. BookingId={BookingId}",
                    booking.Id);

                return new PaymentResult
                {
                    IsSuccess = false,
                    TransactionId = string.Empty,
                    Message = ex.Message,
                    Status = PaymentStatus.Failed,
                    ProcessedAmount = 0,
                    Fees = 0,
                    ProcessedAt = DateTime.UtcNow,
                    GatewayTransactionId = string.Empty
                };
            }
        }

        /// <summary>
        /// Refunds a payment through Jwali wallet transfer.
        /// يعيد مبلغاً عبر تحويل محفظة جوالي.
        ///
        /// The transfer moves funds from the agent wallet to the customer wallet.
        /// يتم التحويل من محفظة التطبيق إلى محفظة العميل.
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
            if (payment == null)
            {
                throw new ArgumentNullException(nameof(payment));
            }

            if (booking == null)
            {
                throw new ArgumentNullException(nameof(booking));
            }

            if (refundAmount <= 0)
            {
                throw new ArgumentException("مبلغ الاسترداد يجب أن يكون أكبر من صفر", nameof(refundAmount));
            }

            // Get the customer wallet as transfer destination.
            // الحصول على رقم محفظة العميل كوجهة للتحويل.
            var customerWallet = booking.User?.Phone;
            if (string.IsNullOrWhiteSpace(customerWallet))
            {
                throw new InvalidOperationException("رقم هاتف/محفظة العميل غير متوفر للاسترداد");
            }

            // Clean the wallet number by stripping plus signs and spaces.
            // تنظيف رقم المحفظة بإزالة + والمسافات.
            customerWallet = customerWallet.Replace("+", "").Replace(" ", "").Trim();

            try
            {
                _logger.LogInformation(
                    "بدء استرداد مبلغ عبر تحويل محفظة جوالي (WALLETTRANSFER). PaymentId={PaymentId}, Amount={Amount}, ToWallet={ToWallet}",
                    payment.Id,
                    refundAmount,
                    customerWallet);

                var agentWallet = GetStringOrThrow(_configuration, "Jwali:AgentWallet", "إعدادات محفظة جوالي غير مكتملة. يجب ضبط Jwali:AgentWallet.");
                var walletPassword = GetStringOrThrow(_configuration, "Jwali:Password", "إعدادات محفظة جوالي غير مكتملة. يجب ضبط Jwali:Password.");

                // Resolve the currency from the original payment or booking.
                // الحصول على العملة من الدفعة الأصلية أو الحجز.
                var currency = payment.Amount?.Currency ?? booking.TotalPrice?.Currency ?? "YER";

                var loginToken = await GetLoginTokenAsync(cancellationToken);
                var walletAccessToken = await GetWalletAccessTokenAsync(loginToken, cancellationToken);

                // Check wallet balance before refunding.
                // التحقق من رصيد المحفظة قبل الاسترداد.
                // This is enabled by default to avoid balance-related refund failures.
                // هذا مفعل افتراضياً لتجنب فشل الاسترداد بسبب عدم كفاية الرصيد.
                var enableBalanceCheck = _configuration.GetValue<bool?>("Jwali:EnableBalanceCheckBeforeRefund") ?? true; // Enabled by default. مفعل افتراضياً.
                var failRefundIfBalanceCheckFails = _configuration.GetValue<bool?>("Jwali:FailRefundIfBalanceCheckFails") ?? true; // ✅ إيقاف العملية عند فشل التحقق

                if (enableBalanceCheck)
                {
                    _logger.LogInformation(
                        "🔍 بدء التحقق من رصيد محفظة التطبيق قبل الاسترداد. RefundAmount={RefundAmount} {Currency}",
                        refundAmount,
                        currency);

                    var balanceCheck = await GetWalletBalanceAsync(loginToken, walletAccessToken, cancellationToken);

                    if (!balanceCheck.Success)
                    {
                        var isKnownNonFatal =
                            balanceCheck.Message.Contains("User.NotFound", StringComparison.OrdinalIgnoreCase)
                            || balanceCheck.Message.Contains("User domain not Found", StringComparison.OrdinalIgnoreCase);

                        if (isKnownNonFatal || !failRefundIfBalanceCheckFails)
                        {
                            _logger.LogWarning(
                                "⚠️ تم تجاهل فشل التحقق من الرصيد قبل الاسترداد وسيتم المتابعة. Message={Message}",
                                balanceCheck.Message);
                        }
                        else
                        {
                            _logger.LogWarning(
                                "❌ فشل التحقق من الرصيد قبل الاسترداد وسيتم إيقاف العملية. Message={Message}",
                                balanceCheck.Message);

                            return new RefundResult
                            {
                                IsSuccess = false,
                                RefundId = string.Empty,
                                Message = $"تعذر التحقق من رصيد محفظة التطبيق. يرجى المحاولة لاحقاً أو التواصل مع الدعم الفني. ({balanceCheck.Message})",
                                RefundedAmount = 0,
                                RefundedAt = DateTime.UtcNow
                            };
                        }
                    }
                    else
                    {
                        _logger.LogInformation(
                            "💰 رصيد محفظة التطبيق الحالي: {Balance} {Currency}",
                            balanceCheck.Balance,
                            currency);

                        if (balanceCheck.Balance < refundAmount)
                        {
                            _logger.LogError(
                                "❌ رصيد المحفظة غير كافي للاسترداد! Balance={Balance}, RefundAmount={RefundAmount}, Shortage={Shortage}",
                                balanceCheck.Balance,
                                refundAmount,
                                refundAmount - balanceCheck.Balance);

                            return new RefundResult
                            {
                                IsSuccess = false,
                                RefundId = string.Empty,
                                Message = $"رصيد محفظة التطبيق غير كافي للاسترداد. الرصيد الحالي: {balanceCheck.Balance:N2} {currency}، المطلوب: {refundAmount:N2} {currency}. يرجى شحن المحفظة أولاً.",
                                RefundedAmount = 0,
                                RefundedAt = DateTime.UtcNow
                            };
                        }

                        _logger.LogInformation(
                            "✅ رصيد المحفظة كافٍ للاسترداد. Balance={Balance}, RefundAmount={RefundAmount}, Remaining={Remaining}",
                            balanceCheck.Balance,
                            refundAmount,
                            balanceCheck.Balance - refundAmount);
                    }
                }

                var refId = Guid.NewGuid().ToString("N");

                // Build the wallet transfer request according to the official documentation (Wallet_Transfer.pdf).
                // بناء طلب تحويل المحفظة وفقاً للتوثيق الرسمي (Wallet_Transfer.pdf).
                // PAYWA.WALLETTRANSFER - transfer from the application wallet to the customer wallet.
                // PAYWA.WALLETTRANSFER - تحويل من محفظة التطبيق إلى محفظة العميل.
                // Required fields:
                // المعاملات المطلوبة:
                //   - walletDestination: recipient wallet number (customer).
                //   - walletDestination: رقم محفظة المستلم (العميل).
                //   - tomember: fixed value = "14000" (per Jwali docs - external transfer membership type).
                //   - tomember: قيمة ثابتة = "14000" (وفقاً لتوثيق جوالي - تمثل نوع العضوية للتحويلات الخارجية).
                //   - txnamount: amount (must be Double).
                //   - txnamount: المبلغ (يجب أن يكون Double).
                //   - currency: currency.
                //   - currency: العملة.
                //   - password: sender wallet password (application).
                //   - password: كلمة مرور محفظة المرسل (التطبيق).
                //   - accessToken: wallet token from WALLETAUTHENTICATION.
                //   - accessToken: توكن المحفظة من WALLETAUTHENTICATION.

                // ⚠️ Important note: tomember = "14000" is a fixed value required by Jwali.
                // ⚠️ ملاحظة مهمة: tomember = "14000" هي قيمة ثابتة مطلوبة من جوالي.
                // Do not change it to the customer's wallet number - this was confirmed by Jwali support.
                // لا يجب تغييرها إلى رقم محفظة العميل - تم التأكيد من الدعم الفني لجوالي.
                var toMemberValue = _configuration["Jwali:ToMemberValue"] ?? "14000";
                
                var transferPayload = new JObject
                {
                    ["header"] = BuildHeaderObject("PAYWA.WALLETTRANSFER", _configuration["Jwali:WalletDomainName"] ?? "WalletDomain"),
                    ["body"] = new JObject
                    {
                        ["walletDestination"] = customerWallet,     // محفظة العميل (الوجهة/المستلم)
                        ["tomember"] = toMemberValue,               // قيمة ثابتة "14000" (نوع العضوية للتحويلات)
                        ["txnamount"] = (double)refundAmount,       // المبلغ (Double مطلوب لتجنب خطأ ClassCastException)
                        ["currency"] = currency,                    // العملة
                        ["password"] = walletPassword,              // كلمة مرور محفظة المرسل
                        ["accessToken"] = walletAccessToken,        // توكن المحفظة
                        ["purpose"] = string.IsNullOrWhiteSpace(reason) 
                            ? $"Refund for Booking #{booking.Id}" 
                            : reason,
                        ["refId"] = refId                           // معرف العملية الفريد
                    }
                };

                _logger.LogDebug(
                    "إرسال طلب WALLETTRANSFER. From={From}, To={To}, Amount={Amount} {Currency}",
                    agentWallet,
                    customerWallet,
                    refundAmount,
                    currency);

                var transferResponse = await PostCallWsAsync(transferPayload, loginToken, cancellationToken);

                // التحقق من نجاح العملية
                var systemStatus = transferResponse.SelectToken("responseStatus.systemStatus")?.ToString();
                var systemStatusDesc = transferResponse.SelectToken("responseStatus.systemStatusDesc")?.ToString() ?? "Unknown";
                var systemStatusDescNative = transferResponse.SelectToken("responseStatus.systemStatusDescNative")?.ToString();
                var httpResponseCode = transferResponse.SelectToken("responseBody.httpResponseCode")?.Value<int?>() ?? 0;
                var issuerTrxRef = transferResponse.SelectToken("responseBody.IssuerTrxRef")?.ToString() 
                    ?? transferResponse.SelectToken("responseBody.issuerTrxRef")?.ToString() 
                    ?? string.Empty;
                var responseRefId = transferResponse.SelectToken("responseBody.refId")?.ToString() ?? refId;
                var newBalance = transferResponse.SelectToken("responseBody.balance")?.ToString() ?? "N/A";

                // النجاح: systemStatus = "0" و httpResponseCode = 200
                var isSuccess = systemStatus == "0" && httpResponseCode == 200;

                if (!isSuccess)
                {
                    _logger.LogWarning(
                        "فشل تحويل المحفظة. SystemStatus={SystemStatus}, Desc={Desc}, HttpCode={HttpCode}",
                        systemStatus,
                        systemStatusDesc,
                        httpResponseCode);

                    var combinedDesc = !string.IsNullOrWhiteSpace(systemStatusDescNative)
                        && !string.Equals(systemStatusDescNative, systemStatusDesc, StringComparison.OrdinalIgnoreCase)
                            ? $"{systemStatusDescNative} ({systemStatusDesc})"
                            : (systemStatusDescNative ?? systemStatusDesc);

                    return new RefundResult
                    {
                        IsSuccess = false,
                        RefundId = responseRefId,
                        Message = $"فشل استرداد المبلغ: {combinedDesc}",
                        RefundedAmount = 0,
                        RefundedAt = DateTime.UtcNow
                    };
                }

                _logger.LogInformation(
                    "تم استرداد المبلغ بنجاح عبر تحويل المحفظة. IssuerTrxRef={IssuerTrxRef}, RefId={RefId}, NewBalance={NewBalance}",
                    issuerTrxRef,
                    responseRefId,
                    newBalance);

                return new RefundResult
                {
                    IsSuccess = true,
                    RefundId = string.IsNullOrWhiteSpace(issuerTrxRef) ? responseRefId : issuerTrxRef,
                    Message = "تم استرداد المبلغ عبر محفظة جوالي بنجاح",
                    RefundedAmount = refundAmount,
                    RefundedAt = DateTime.UtcNow
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "خطأ أثناء استرداد مبلغ عبر تحويل محفظة جوالي. PaymentId={PaymentId}",
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

        /// <summary>
        /// Gets the application wallet balance through Jwali.
        /// يحصل على رصيد محفظة التطبيق عبر جوالي.
        /// </summary>
        /// <param name="cancellationToken">Cancellation token. رمز الإلغاء.</param>
        /// <returns>Wallet balance result. نتيجة الرصيد.</returns>
        public async Task<WalletBalanceResult> GetApplicationWalletBalanceAsync(CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation("🔍 بدء الاستعلام عن رصيد محفظة التطبيق (جوالي)...");

                var loginToken = await GetLoginTokenAsync(cancellationToken);
                var walletAccessToken = await GetWalletAccessTokenAsync(loginToken, cancellationToken);
                var currency = _configuration["Jwali:DefaultCurrency"] ?? "YER";

                var result = await GetWalletBalanceAsync(loginToken, walletAccessToken, cancellationToken);

                if (result.Success)
                {
                    _logger.LogInformation("💰 رصيد محفظة التطبيق: {Balance} {Currency}", result.Balance, currency);
                    return new WalletBalanceResult
                    {
                        Success = true,
                        Balance = result.Balance,
                        Currency = currency,
                        Message = "تم الاستعلام عن الرصيد بنجاح"
                    };
                }
                else
                {
                    _logger.LogWarning("⚠️ فشل الاستعلام عن رصيد المحفظة: {Message}", result.Message);
                    return new WalletBalanceResult
                    {
                        Success = false,
                        Balance = 0,
                        Currency = currency,
                        Message = result.Message
                    };
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ خطأ أثناء الاستعلام عن رصيد محفظة التطبيق");
                return new WalletBalanceResult
                {
                    Success = false,
                    Balance = 0,
                    Currency = "YER",
                    Message = ex.Message
                };
            }
        }

        /// <summary>
        /// Checks whether the current wallet balance is sufficient.
        /// يتحقق مما إذا كان الرصيد الحالي كافياً.
        /// </summary>
        /// <param name="refundAmount">Requested refund amount. مبلغ الاسترداد المطلوب.</param>
        /// <param name="cancellationToken">Cancellation token. رمز الإلغاء.</param>
        /// <returns>Tuple indicating sufficiency, balance, and message. قيمة توضح الكفاية والرصيد والرسالة.</returns>
        public async Task<(bool IsSufficient, decimal CurrentBalance, string Message)> CheckBalanceSufficiencyAsync(
            decimal refundAmount,
            CancellationToken cancellationToken = default)
        {
            try
            {
                if (refundAmount <= 0)
                {
                    return (false, 0, "مبلغ الاسترداد يجب أن يكون أكبر من صفر");
                }

                var balanceResult = await GetApplicationWalletBalanceAsync(cancellationToken);

                if (!balanceResult.Success)
                {
                    // Known non-fatal errors should not block the refund flow.
                    // Known non-fatal errors should not block the refund flow.
                    // الأخطاء المعروفة غير الحرجة لا تمنع مسار الاسترداد.
                    // WALLETBALANCE may not be supported for some account types.
                    // خدمة WALLETBALANCE قد لا تكون مدعومة لبعض أنواع الحسابات.
                    // In that case, skip the check and allow the refund attempt.
                    // في هذه الحالة نتجاوز الفحص ونسمح بمحاولة الاسترداد.
                    var isKnownNonFatalError = 
                        balanceResult.Message.Contains("User.NotFound", StringComparison.OrdinalIgnoreCase)
                        || balanceResult.Message.Contains("User domain not Found", StringComparison.OrdinalIgnoreCase)
                        || balanceResult.Message.Contains("NotFound", StringComparison.OrdinalIgnoreCase);

                    if (isKnownNonFatalError)
                    {
                        _logger.LogWarning(
                            "⚠️ خدمة WALLETBALANCE غير مدعومة لهذا الحساب. سيتم تجاوز فحص الرصيد والمتابعة. Message={Message}",
                            balanceResult.Message);
                        
                        // Assume the balance is sufficient and let Jwali validate it during transfer.
                        // نفترض أن الرصيد كافٍ ونترك جوالي يتحقق من ذلك عند التحويل.
                        return (true, -1, $"⚠️ تم تجاوز فحص الرصيد (WALLETBALANCE غير مدعومة): {balanceResult.Message}");
                    }

                    return (false, 0, $"تعذر التحقق من رصيد المحفظة: {balanceResult.Message}");
                }

                var isSufficient = balanceResult.Balance >= refundAmount;
                var message = isSufficient
                    ? $"✅ رصيد المحفظة كافٍ للاسترداد. الرصيد: {balanceResult.Balance:N2} {balanceResult.Currency}, المطلوب: {refundAmount:N2} {balanceResult.Currency}"
                    : $"❌ رصيد المحفظة غير كافٍ للاسترداد. الرصيد: {balanceResult.Balance:N2} {balanceResult.Currency}, المطلوب: {refundAmount:N2} {balanceResult.Currency}, النقص: {(refundAmount - balanceResult.Balance):N2} {balanceResult.Currency}";

                _logger.LogInformation(message);

                return (isSufficient, balanceResult.Balance, message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء التحقق من كفاية رصيد المحفظة");
                return (false, 0, ex.Message);
            }
        }

        #endregion
    }
}
