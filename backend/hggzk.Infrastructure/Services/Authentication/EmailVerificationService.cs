using System;
using System.Collections.Concurrent;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace YemenBooking.Infrastructure.Services.Authentication
{
    /// <summary>
    /// Provides short-lived in-memory email verification codes.
    /// يوفّر رموز تحقق قصيرة العمر للبريد الإلكتروني مخزنة في الذاكرة.
    /// </summary>
    public class EmailVerificationService : IEmailVerificationService
    {
        private static readonly ConcurrentDictionary<string, (string Code, DateTime ExpiresAt)> _codes = new();
        private readonly IEmailService _emailService;
        private readonly ILogger<EmailVerificationService> _logger;
        private const int VerificationCodeValidityMinutes = 10;
        private const int MaxSendAttempts = 2;

        /// <summary>
        /// Initializes a new instance of EmailVerificationService with the required dependencies.
        /// يهيئ مثيلاً جديدًا من EmailVerificationService باستخدام الاعتماديات المطلوبة.
        /// </summary>
        public EmailVerificationService(IEmailService emailService, ILogger<EmailVerificationService> logger)
        {
            _emailService = emailService;
            _logger = logger;
        }

        /// <summary>
        /// Sends a verification email and stores the code for later validation.
        /// يرسل رسالة تحقق ويخزن الرمز للتحقق اللاحق.
        /// </summary>
        public async Task<bool> SendVerificationEmailAsync(string email, string verificationCode)
        {
            if (string.IsNullOrWhiteSpace(email))
            {
                _logger.LogWarning("محاولة إرسال رمز التحقق مع بريد إلكتروني فارغ");
                return false;
            }

            var normalizedEmail = email.Trim();
            var subject = "تأكيد بريدك الإلكتروني في حجزك";

var body = $@"<div style='direction: rtl; text-align: right; font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; font-size: 14px; color: #222;'>
<p>مرحباً،</p>

<p>شكراً لتسجيلك في منصة <strong>حجزك</strong>. حرصاً على حماية حسابك وضمان إمكانية استعادة الوصول إليه في أي وقت، نحتاج إلى تأكيد عنوان بريدك الإلكتروني.</p>

<p>رمز التحقق الخاص بك هو:</p>

<p style='font-size: 20px; font-weight: bold; letter-spacing: 4px; color: #1b6cf0;'>
    {verificationCode}
</p>

<p>هذا الرمز صالح لمدة <strong>10 دقائق</strong> من وقت الإرسال. يرجى إدخاله في شاشة ""تأكيد البريد الإلكتروني"" داخل التطبيق لإكمال تفعيل حسابك.</p>

<p>إذا لم تكن قد قمت بإنشاء حساب أو لم تطلب هذا التحقق، فيمكنك تجاهل هذه الرسالة بأمان، وسيبقى حسابك غير مفعّل.</p>

<p style='margin-top: 24px;'>مع تحيات فريق <strong>حجزك</strong><br/>
<span style='font-size: 12px; color: #666;'>هذه الرسالة أُرسلت تلقائياً، لا تقم بالرد عليها.</span></p>
</div>";

            for (var attempt = 1; attempt <= MaxSendAttempts; attempt++)
            {
                var sent = await _emailService.SendEmailAsync(normalizedEmail, subject, body, true);
                if (sent)
                {
                    _codes[NormalizeEmailKey(normalizedEmail)] =
                        (verificationCode, DateTime.UtcNow.AddMinutes(VerificationCodeValidityMinutes));

                    if (attempt > 1)
                    {
                        _logger.LogInformation(
                            "تم إرسال رمز التحقق بعد إعادة المحاولة. البريد: {Email}, المحاولة: {Attempt}",
                            normalizedEmail, attempt);
                    }

                    return true;
                }

                if (attempt < MaxSendAttempts)
                {
                    _logger.LogWarning(
                        "فشل إرسال رمز التحقق في المحاولة {Attempt} للبريد: {Email}. سيتم إعادة المحاولة.",
                        attempt, normalizedEmail);
                    await Task.Delay(800);
                }
            }

            _logger.LogError("فشل إرسال رمز التحقق بعد {Attempts} محاولات للبريد: {Email}", MaxSendAttempts, normalizedEmail);
            return false;
        }

        /// <summary>
        /// Verifies the code for the specified email address.
        /// يتحقق من الرمز الخاص بالبريد المحدد.
        /// </summary>
        public Task<bool> VerifyCodeAsync(string email, string verificationCode)
        {
            var key = NormalizeEmailKey(email);
            if (_codes.TryGetValue(key, out var entry))
            {
                if (DateTime.UtcNow <= entry.ExpiresAt && string.Equals(entry.Code, verificationCode, StringComparison.OrdinalIgnoreCase))
                {
                    _codes.TryRemove(key, out _);
                    return Task.FromResult(true);
                }
            }
            return Task.FromResult(false);
        }

        /// <summary>
        /// Generates a numeric verification code.
        /// ينشئ رمز تحقق رقميًا.
        /// </summary>
        public string GenerateVerificationCode()
        {
            var rng = new Random();
            return rng.Next(100000, 999999).ToString();
        }

        /// <summary>
        /// Checks whether the verification code has expired.
        /// يتحقق مما إذا كان رمز التحقق قد انتهت صلاحيته.
        /// </summary>
        public Task<bool> IsCodeExpiredAsync(string email, string verificationCode)
        {
            var key = NormalizeEmailKey(email);
            if (_codes.TryGetValue(key, out var entry))
            {
                // Only consider time expiry here; token mismatch should be handled by VerifyCodeAsync
                return Task.FromResult(DateTime.UtcNow > entry.ExpiresAt);
            }
            // No code stored => treat as expired
            return Task.FromResult(true);
        }

        private static string NormalizeEmailKey(string email)
        {
            return string.IsNullOrWhiteSpace(email)
                ? string.Empty
                : email.Trim().ToLowerInvariant();
        }
    }
}
