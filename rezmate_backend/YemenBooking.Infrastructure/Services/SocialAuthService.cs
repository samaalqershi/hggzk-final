using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Google.Apis.Auth;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using YemenBooking.Application.Features.Authentication.Services;
using YemenBooking.Infrastructure.Settings;

namespace YemenBooking.Infrastructure.Services
{
    /// <summary>
    /// تحقق من رموز Google/Facebook وإرجاع معلومات المستخدم الموثقة
    /// </summary>
    public class SocialAuthService : ISocialAuthService
    {
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly ILogger<SocialAuthService> _logger;
        private readonly SocialAuthSettings _settings;

        private static IReadOnlyCollection<SecurityKey>? _appleSigningKeys;
        private static DateTime _appleJwksFetchedAtUtc = DateTime.MinValue;
        private static readonly SemaphoreSlim _appleJwksLock = new SemaphoreSlim(1, 1);

        private sealed class AppleJwksDocument
        {
            public List<AppleJwk> Keys { get; set; } = new List<AppleJwk>();
        }

        private sealed class AppleJwk
        {
            public string? Kid { get; set; }
            public string? Kty { get; set; }
            public string? N { get; set; }
            public string? E { get; set; }
        }

        public SocialAuthService(
            IHttpClientFactory httpClientFactory,
            ILogger<SocialAuthService> logger,
            IOptions<SocialAuthSettings> settings)
        {
            _httpClientFactory = httpClientFactory;
            _logger = logger;
            _settings = settings.Value;
        }

        public async Task<SocialUserInfo> VerifyGoogleIdTokenAsync(string idToken, CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(idToken))
            {
                throw new InvalidOperationException("Google token is missing");
            }

            var token = idToken.Trim();
            var isJwtLike = token.Count(c => c == '.') == 2;

            if (isJwtLike)
            {
                try
                {
                    var validationSettings = new GoogleJsonWebSignature.ValidationSettings
                    {
                        Audience = _settings.GoogleClientIds is { Length: > 0 } ? _settings.GoogleClientIds : null
                    };
                    var payload = await GoogleJsonWebSignature.ValidateAsync(token, validationSettings);
                    return new SocialUserInfo
                    {
                        Provider = "google",
                        ProviderUserId = payload.Subject,
                        Email = payload.Email,
                        Name = payload.Name,
                        PictureUrl = payload.Picture
                    };
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Google id_token validation failed. Falling back to access token userinfo endpoint.");
                }
            }

            return await VerifyGoogleAccessTokenAsync(token, cancellationToken);
        }

        private async Task<SocialUserInfo> VerifyGoogleAccessTokenAsync(
            string accessToken,
            CancellationToken cancellationToken)
        {
            var http = _httpClientFactory.CreateClient();
            using var request = new HttpRequestMessage(
                HttpMethod.Get,
                "https://www.googleapis.com/oauth2/v3/userinfo");
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

            using var response = await http.SendAsync(request, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                var errorBody = await response.Content.ReadAsStringAsync(cancellationToken);
                _logger.LogWarning(
                    "Google access token validation failed. Status: {StatusCode}, Body: {Body}",
                    (int)response.StatusCode,
                    errorBody);
                throw new InvalidOperationException("Invalid Google access token");
            }

            var payloadJson = await response.Content.ReadAsStringAsync(cancellationToken);
            using var doc = JsonDocument.Parse(payloadJson);
            var root = doc.RootElement;

            var subject = root.TryGetProperty("sub", out var subEl) ? subEl.GetString() : null;
            if (string.IsNullOrWhiteSpace(subject))
            {
                throw new InvalidOperationException("Google userinfo payload is missing 'sub'");
            }

            return new SocialUserInfo
            {
                Provider = "google",
                ProviderUserId = subject,
                Email = root.TryGetProperty("email", out var emailEl) ? emailEl.GetString() : null,
                Name = root.TryGetProperty("name", out var nameEl) ? nameEl.GetString() : null,
                PictureUrl = root.TryGetProperty("picture", out var pictureEl) ? pictureEl.GetString() : null
            };
        }

        public async Task<SocialUserInfo> VerifyFacebookAccessTokenAsync(string accessToken, CancellationToken cancellationToken = default)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(_settings.FacebookAppId) || string.IsNullOrWhiteSpace(_settings.FacebookAppSecret))
                {
                    throw new InvalidOperationException("Missing FacebookAppId/AppSecret in configuration");
                }

                var http = _httpClientFactory.CreateClient();

                // Validate token
                var appAccess = $"{_settings.FacebookAppId}|{_settings.FacebookAppSecret}";
                var debugUrl = $"https://graph.facebook.com/debug_token?input_token={Uri.EscapeDataString(accessToken)}&access_token={Uri.EscapeDataString(appAccess)}";
                using (var debugResp = await http.GetAsync(debugUrl, cancellationToken))
                {
                    debugResp.EnsureSuccessStatusCode();
                    var json = await debugResp.Content.ReadAsStringAsync(cancellationToken);
                    using var doc = JsonDocument.Parse(json);
                    var data = doc.RootElement.GetProperty("data");
                    var isValid = data.TryGetProperty("is_valid", out var isValidEl) && isValidEl.GetBoolean();
                    if (!isValid)
                    {
                        throw new InvalidOperationException("Invalid Facebook access token");
                    }
                }

                // Fetch user info
                var meUrl = $"https://graph.facebook.com/me?fields=id,name,email,picture&type=large&access_token={Uri.EscapeDataString(accessToken)}";
                using var meResp = await http.GetAsync(meUrl, cancellationToken);
                meResp.EnsureSuccessStatusCode();
                var meJson = await meResp.Content.ReadAsStringAsync(cancellationToken);
                using var meDoc = JsonDocument.Parse(meJson);
                var root = meDoc.RootElement;
                var id = root.GetProperty("id").GetString();
                var name = root.TryGetProperty("name", out var nameEl) ? nameEl.GetString() : null;
                var email = root.TryGetProperty("email", out var emailEl) ? emailEl.GetString() : null;
                string? pictureUrl = null;
                if (root.TryGetProperty("picture", out var pic) && pic.TryGetProperty("data", out var dataEl) && dataEl.TryGetProperty("url", out var urlEl))
                {
                    pictureUrl = urlEl.GetString();
                }

                return new SocialUserInfo
                {
                    Provider = "facebook",
                    ProviderUserId = id ?? string.Empty,
                    Email = email,
                    Name = name,
                    PictureUrl = pictureUrl
                };
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Facebook access token validation failed");
                throw;
            }
        }

        public async Task<SocialUserInfo> VerifyAppleIdTokenAsync(string idToken, string? nonce = null, CancellationToken cancellationToken = default)
        {
            try
            {
                if (_settings.AppleClientIds is not { Length: > 0 })
                {
                    throw new InvalidOperationException("Missing AppleClientIds in configuration");
                }

                var handler = new JwtSecurityTokenHandler();
                if (!handler.CanReadToken(idToken))
                {
                    throw new InvalidOperationException("Invalid Apple id_token format");
                }

                var parts = idToken.Split('.');
                if (parts.Length != 3)
                {
                    throw new InvalidOperationException("Invalid Apple id_token format");
                }

                string? headerKid = null;
                string? headerAlg = null;
                string? payloadIss = null;
                string? payloadAud = null;
                long? payloadExp = null;
                string? payloadSub = null;
                string? payloadEmail = null;
                string? payloadNonce = null;
                try
                {
                    _logger.LogInformation("Apple id_token parts count: {PartsCount}", parts.Length);
                    var headerJson = Encoding.UTF8.GetString(Base64UrlEncoder.DecodeBytes(parts[0]));
                    _logger.LogInformation("Apple id_token header json: {HeaderJson}", headerJson);
                    using var headerDoc = JsonDocument.Parse(headerJson);
                    if (headerDoc.RootElement.TryGetProperty("kid", out var kidEl))
                    {
                        headerKid = kidEl.GetString();
                    }
                    if (headerDoc.RootElement.TryGetProperty("alg", out var algEl))
                    {
                        headerAlg = algEl.GetString();
                    }

                    var payloadJson = Encoding.UTF8.GetString(Base64UrlEncoder.DecodeBytes(parts[1]));
                    using var payloadDoc = JsonDocument.Parse(payloadJson);
                    payloadIss = payloadDoc.RootElement.TryGetProperty("iss", out var issEl) ? issEl.GetString() : null;
                    if (payloadDoc.RootElement.TryGetProperty("aud", out var audEl))
                    {
                        payloadAud = audEl.ValueKind == JsonValueKind.String
                            ? audEl.GetString()
                            : audEl.ValueKind == JsonValueKind.Array
                                ? audEl.EnumerateArray().FirstOrDefault().GetString()
                                : null;
                    }
                    if (payloadDoc.RootElement.TryGetProperty("exp", out var expEl) && expEl.ValueKind == JsonValueKind.Number)
                    {
                        payloadExp = expEl.GetInt64();
                    }
                    payloadSub = payloadDoc.RootElement.TryGetProperty("sub", out var subEl) ? subEl.GetString() : null;
                    payloadEmail = payloadDoc.RootElement.TryGetProperty("email", out var emailEl) ? emailEl.GetString() : null;
                    payloadNonce = payloadDoc.RootElement.TryGetProperty("nonce", out var nonceEl) ? nonceEl.GetString() : null;
                    _logger.LogInformation(
                        "Apple id_token payload: iss={Iss}, aud={Aud}, exp={Exp}",
                        payloadIss,
                        payloadAud,
                        payloadExp);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to decode Apple id_token header/payload for diagnostics");
                }

                var keys = await GetAppleSigningKeysAsync(cancellationToken);

                if (!string.IsNullOrWhiteSpace(headerKid))
                {
                    var hasKid = keys.Any(k => string.Equals(k.KeyId, headerKid, StringComparison.Ordinal));
                    _logger.LogInformation("Apple JWKS contains kid {Kid}: {HasKid}", headerKid, hasKid);
                }

                if (string.IsNullOrWhiteSpace(headerKid))
                {
                    throw new InvalidOperationException("Apple id_token missing kid");
                }

                var selectedKey = keys.FirstOrDefault(k => string.Equals(k.KeyId, headerKid, StringComparison.Ordinal)) as RsaSecurityKey;
                if (selectedKey == null)
                {
                    throw new InvalidOperationException($"Apple JWKS does not contain a key for kid '{headerKid}'");
                }

                if (!string.Equals(headerAlg, "RS256", StringComparison.OrdinalIgnoreCase))
                {
                    throw new InvalidOperationException($"Unsupported Apple id_token alg '{headerAlg}'");
                }

                var signingInput = $"{parts[0]}.{parts[1]}";
                var signature = Base64UrlEncoder.DecodeBytes(parts[2]);
                if (!VerifyRs256Signature(signingInput, signature, selectedKey))
                {
                    throw new SecurityTokenInvalidSignatureException("Apple id_token signature validation failed");
                }

                if (!string.Equals(payloadIss, "https://appleid.apple.com", StringComparison.Ordinal))
                {
                    throw new InvalidOperationException("Apple id_token issuer invalid");
                }

                if (string.IsNullOrWhiteSpace(payloadAud) || !_settings.AppleClientIds.Contains(payloadAud, StringComparer.Ordinal))
                {
                    throw new InvalidOperationException("Apple id_token audience invalid");
                }

                if (payloadExp == null)
                {
                    throw new InvalidOperationException("Apple id_token missing exp");
                }
                var expUtc = DateTimeOffset.FromUnixTimeSeconds(payloadExp.Value);
                if (DateTimeOffset.UtcNow > expUtc.AddMinutes(2))
                {
                    throw new InvalidOperationException("Apple id_token expired");
                }

                if (!string.IsNullOrWhiteSpace(nonce))
                {
                    var expected = Sha256Hex(nonce);
                    if (string.IsNullOrWhiteSpace(payloadNonce) || !string.Equals(payloadNonce, expected, StringComparison.Ordinal))
                    {
                        throw new InvalidOperationException("Apple nonce validation failed");
                    }
                }

                if (string.IsNullOrWhiteSpace(payloadSub))
                {
                    throw new InvalidOperationException("Apple token missing subject");
                }

                return new SocialUserInfo
                {
                    Provider = "apple",
                    ProviderUserId = payloadSub,
                    Email = string.IsNullOrWhiteSpace(payloadEmail) ? null : payloadEmail,
                    Name = null,
                    PictureUrl = null,
                };
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Apple ID token validation failed");
                throw;
            }
        }

        private static bool VerifyRs256Signature(string signingInput, byte[] signature, RsaSecurityKey key)
        {
            try
            {
                using var rsa = RSA.Create();
                rsa.ImportParameters(key.Parameters);
                var data = Encoding.ASCII.GetBytes(signingInput);
                return rsa.VerifyData(data, signature, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
            }
            catch
            {
                return false;
            }
        }

        private async Task<IEnumerable<SecurityKey>> GetAppleSigningKeysAsync(CancellationToken cancellationToken)
        {
            var now = DateTime.UtcNow;
            if (_appleSigningKeys != null && (now - _appleJwksFetchedAtUtc) < TimeSpan.FromHours(12))
            {
                return _appleSigningKeys;
            }

            await _appleJwksLock.WaitAsync(cancellationToken);
            try
            {
                if (_appleSigningKeys != null && (now - _appleJwksFetchedAtUtc) < TimeSpan.FromHours(12))
                {
                    return _appleSigningKeys;
                }

                var http = _httpClientFactory.CreateClient();
                using var resp = await http.GetAsync("https://appleid.apple.com/auth/keys", cancellationToken);
                resp.EnsureSuccessStatusCode();
                var json = await resp.Content.ReadAsStringAsync(cancellationToken);
                var doc = JsonSerializer.Deserialize<AppleJwksDocument>(json, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
                if (doc == null || doc.Keys == null || doc.Keys.Count == 0)
                {
                    throw new InvalidOperationException("Apple JWKS is empty");
                }

                var keys = new List<SecurityKey>();
                foreach (var jwk in doc.Keys)
                {
                    if (!string.Equals(jwk.Kty, "RSA", StringComparison.OrdinalIgnoreCase))
                    {
                        continue;
                    }
                    if (string.IsNullOrWhiteSpace(jwk.N) || string.IsNullOrWhiteSpace(jwk.E) || string.IsNullOrWhiteSpace(jwk.Kid))
                    {
                        continue;
                    }

                    var rsaKey = new RsaSecurityKey(new RSAParameters
                    {
                        Modulus = Base64UrlEncoder.DecodeBytes(jwk.N),
                        Exponent = Base64UrlEncoder.DecodeBytes(jwk.E)
                    })
                    {
                        KeyId = jwk.Kid
                    };
                    keys.Add(rsaKey);
                }

                if (keys.Count == 0)
                {
                    throw new InvalidOperationException("Failed to build Apple signing keys from JWKS");
                }

                _appleSigningKeys = keys;
                _appleJwksFetchedAtUtc = now;
                return _appleSigningKeys;
            }
            finally
            {
                _appleJwksLock.Release();
            }
        }

        private static string Sha256Hex(string input)
        {
            var bytes = Encoding.UTF8.GetBytes(input);
            var hash = SHA256.HashData(bytes);
            var sb = new StringBuilder(hash.Length * 2);
            foreach (var b in hash)
            {
                sb.Append(b.ToString("x2"));
            }
            return sb.ToString();
        }
    }
}
