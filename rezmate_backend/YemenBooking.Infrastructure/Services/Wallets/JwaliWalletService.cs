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
using YemenBooking.Application.Infrastructure.Services.Wallets;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Wallets.Jwali;

namespace YemenBooking.Infrastructure.Services.Wallets
{
    /// <summary>
    /// تنفيذ خدمة محفظة جوالي (JwaliWallet)
    /// تغلّف استدعاءات واجهات PAYWA / PAYAG الخاصة بجوالي
    /// لاستخدامها في عمليات دفع الحجوزات والاسترداد داخل النظام.
    /// </summary>
    public class JwaliWalletService : IJwaliWalletService
    {
        // عميل HTTP للتواصل مع واجهة جوالي
        private readonly HttpClient _httpClient;

        // إعدادات التطبيق للحصول على بيانات الاتصال (BaseUrl, AgentWallet, Password, ClientID, OrgID, UserID, ExternalUser, DefaultRefundType)
        private readonly IConfiguration _configuration;

        // ذاكرة مؤقتة لحفظ رمز الوصول (AccessToken)
        private readonly IMemoryCache _cache;
        private const string LOGIN_TOKEN_CACHE_KEY = "Jwali_LoginToken";
        private const string WALLET_TOKEN_CACHE_KEY = "Jwali_WalletAccessToken";

        private readonly ILogger<JwaliWalletService> _logger;

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

            // تهيئة عنوان الـ API الأساسي لمحفظة جوالي
            // ملاحظة: يمكن أن يكون BaseUrl هو الرابط الكامل لنقطة النهاية (Endpoint)
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

        /// <summary>
        /// الاستعلام عن رصيد محفظة التطبيق
        /// </summary>
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

        /// <inheritdoc />
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

            // receiverMobile إلزامي في ECOMMERCEINQUIRY حسب وثائق جوالي
            // إذا لم يُرسل، نحاول استخدام رقم هاتف العميل من الحجز
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
                // تحقق صارم من المبلغ والعملة قبل أي استعلام خارجي
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

                    // يجب أن يكون طول refId ≤ 32 حرفاً دائماً
                    var refId = Guid.NewGuid().ToString("N").Substring(0, 32);

                var loginToken = await GetLoginTokenAsync(cancellationToken);
                var walletAccessToken = await GetWalletAccessTokenAsync(loginToken, cancellationToken);

                // ترتيب الحقول حسب وثائق ECOMMERCEINQUIRY بالضبط:
                // agentWallet, voucher, receiverMobile, password, accessToken, refId, txncurrency, purpose
                var inquiryPayload = new JObject
                {
                    ["header"] = BuildHeaderObject("PAYAG.ECOMMERCEINQUIRY", _configuration["Jwali:MerchantDomainName"] ?? "MerchantDomain"),
                    ["body"] = new JObject
                    {
                        ["agentWallet"] = agentWallet,
                        ["voucher"] = voucher,
                        ["receiverMobile"] = effectiveReceiverMobile, // إلزامي حسب وثائق جوالي
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
                    // ⚠️ تحذير أمني: كود الشراء مصروف مسبقاً
                    // لا نقبل هذه الحالة تلقائياً لأنه قد يكون مصروفاً لحجز آخر
                    // يجب على العميل استخدام كود شراء جديد
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

                // ⚠️ مهم: يجب استخدام refId مختلف لـ ECOMMCASHOUT عن الـ refId المستخدم في ECOMMERCEINQUIRY
                // جوالي يرفض استخدام نفس الـ refId مرتين
                // يجب أن يكون طول cashoutRefId ≤ 32 حرفاً دائماً
                var cashoutRefId = Guid.NewGuid().ToString("N").Substring(0, 32);
                
                // ترتيب الحقول حسب وثائق ECOMMCASHOUT بالضبط
                var cashoutPayload = new JObject
                {
                    ["header"] = BuildHeaderObject("PAYAG.ECOMMCASHOUT", _configuration["Jwali:MerchantDomainName"] ?? "MerchantDomain"),
                    ["body"] = new JObject
                    {
                        ["agentWallet"] = agentWallet,
                        ["voucher"] = voucher,
                        ["receiverMobile"] = finalReceiverMobile, // إلزامي حسب وثائق جوالي
                        ["password"] = walletPassword,
                        ["accessToken"] = walletAccessToken,
                        ["refId"] = cashoutRefId, // refId جديد خاص بـ Cashout
                        ["purpose"] = $"Booking Payment #{booking.Id}",
                        ["amount"] = (int)amount, // الوثائق تستخدم رقم صحيح
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

        /// <inheritdoc />
        /// <summary>
        /// استرداد مبلغ للعميل عبر تحويل محفظة (PAYWA.WALLETTRANSFER)
        /// يتم التحويل من محفظة التطبيق (agentWallet) إلى محفظة العميل (walletDestination)
        /// 
        /// ⚠️ ملاحظة مهمة:
        /// - WALLETTRANSFER قد يتطلب صلاحيات خاصة من جوالي
        /// - في حالة فشل التحويل التلقائي، يجب الاسترداد يدوياً من لوحة تحكم جوالي
        /// - تواصل مع الدعم الفني لجوالي للحصول على صلاحيات WALLETTRANSFER
        /// </summary>
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

            // الحصول على رقم محفظة العميل (وجهة التحويل)
            var customerWallet = booking.User?.Phone;
            if (string.IsNullOrWhiteSpace(customerWallet))
            {
                throw new InvalidOperationException("رقم هاتف/محفظة العميل غير متوفر للاسترداد");
            }

            // تنظيف رقم المحفظة (إزالة + والمسافات)
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

                // الحصول على العملة من الدفعة الأصلية أو الحجز
                var currency = payment.Amount?.Currency ?? booking.TotalPrice?.Currency ?? "YER";

                var loginToken = await GetLoginTokenAsync(cancellationToken);
                var walletAccessToken = await GetWalletAccessTokenAsync(loginToken, cancellationToken);

                // ✅ التحقق من رصيد المحفظة قبل الاسترداد (اختياري)
                // بعض بيئات جوالي تُرجع User.NotFound في WALLETBALANCE حتى مع صلاحية WALLETTRANSFER.
                // لذلك جعلناه اختياريًا وغير قاتل افتراضيًا.
                var enableBalanceCheck = _configuration.GetValue<bool?>("Jwali:EnableBalanceCheckBeforeRefund") ?? false;
                var failRefundIfBalanceCheckFails = _configuration.GetValue<bool?>("Jwali:FailRefundIfBalanceCheckFails") ?? false;

                if (enableBalanceCheck)
                {
                    var balanceCheck = await GetWalletBalanceAsync(loginToken, walletAccessToken, cancellationToken);

                    if (!balanceCheck.Success)
                    {
                        var isKnownNonFatal =
                            balanceCheck.Message.Contains("User.NotFound", StringComparison.OrdinalIgnoreCase)
                            || balanceCheck.Message.Contains("User domain not Found", StringComparison.OrdinalIgnoreCase);

                        if (isKnownNonFatal || !failRefundIfBalanceCheckFails)
                        {
                            _logger.LogWarning(
                                "تم تجاهل فشل التحقق من الرصيد قبل الاسترداد وسيتم المتابعة. Message={Message}",
                                balanceCheck.Message);
                        }
                        else
                        {
                            _logger.LogWarning(
                                "فشل التحقق من الرصيد قبل الاسترداد وسيتم إيقاف العملية حسب الإعدادات. Message={Message}",
                                balanceCheck.Message);

                            return new RefundResult
                            {
                                IsSuccess = false,
                                RefundId = string.Empty,
                                Message = $"تعذر التحقق من رصيد المحفظة: {balanceCheck.Message}",
                                RefundedAmount = 0,
                                RefundedAt = DateTime.UtcNow
                            };
                        }
                    }
                    else
                    {
                        if (balanceCheck.Balance < refundAmount)
                        {
                            _logger.LogWarning(
                                "رصيد المحفظة غير كافي للاسترداد. Balance={Balance}, RefundAmount={RefundAmount}",
                                balanceCheck.Balance,
                                refundAmount);

                            return new RefundResult
                            {
                                IsSuccess = false,
                                RefundId = string.Empty,
                                Message = $"رصيد المحفظة غير كافي للاسترداد. الرصيد الحالي: {balanceCheck.Balance} {currency}، المطلوب: {refundAmount} {currency}",
                                RefundedAmount = 0,
                                RefundedAt = DateTime.UtcNow
                            };
                        }

                        _logger.LogInformation(
                            "رصيد المحفظة كافٍ للاسترداد. Balance={Balance}, RefundAmount={RefundAmount}",
                            balanceCheck.Balance,
                            refundAmount);
                    }
                }

                var refId = Guid.NewGuid().ToString("N");
                //   - walletDestination: رقم محفظة المستلم (العميل)
                //   - tomember: قيمة ثابتة = "14000" (وفقاً لتوثيق جوالي - تمثل نوع العضوية للتحويلات الخارجية)
                //   - txnamount: المبلغ (يجب أن يكون Double)
                //   - currency: العملة
                //   - password: كلمة مرور محفظة المرسل (التطبيق)
                //   - accessToken: توكن المحفظة من WALLETAUTHENTICATION
                
                // ⚠️ ملاحظة مهمة: tomember = "14000" هي قيمة ثابتة مطلوبة من جوالي
                // لا يجب تغييرها إلى رقم محفظة العميل - تم التأكيد من الدعم الفني لجوالي
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

        #endregion
    }
}
