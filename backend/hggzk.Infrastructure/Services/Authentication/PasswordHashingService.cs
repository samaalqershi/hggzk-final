using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Contracts.Services.Authentication;
using System.Security.Cryptography;
using System.Text;
using System.Linq;
using System.Collections.Generic;

namespace YemenBooking.Infrastructure.Services.Authentication
{
    /// <summary>
    /// Provides password hashing, verification, and strength checks.
    /// يوفّر تجزئة كلمات المرور والتحقق منها وفحص قوتها.
    /// </summary>
    public class PasswordHashingService : IPasswordHashingService
    {
        private readonly ILogger<PasswordHashingService> _logger;

        /// <summary>
        /// Initializes a new instance of PasswordHashingService with the required dependencies.
        /// يهيئ مثيلاً جديدًا من PasswordHashingService باستخدام الاعتماديات المطلوبة.
        /// </summary>
        public PasswordHashingService(ILogger<PasswordHashingService> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Hashes the provided password using PBKDF2 and a random salt.
        /// يشفّر كلمة المرور باستخدام PBKDF2 وملح عشوائي.
        /// </summary>
        public Task<string> HashPasswordAsync(string password, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("تشفير كلمة المرور");
            // إنشاء ملح عشوائي
            var salt = new byte[16];
            RandomNumberGenerator.Fill(salt);
            // اشتقاق المفتاح باستخدام PBKDF2
            using var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 100_000, HashAlgorithmName.SHA256);
            var hash = pbkdf2.GetBytes(32);
            // دمج الملح والتجزئة
            var saltB64 = Convert.ToBase64String(salt);
            var hashB64 = Convert.ToBase64String(hash);
            return Task.FromResult($"{saltB64}.{hashB64}");
        }

        /// <summary>
        /// Verifies a password against the stored hash.
        /// يتحقق من كلمة المرور مقابل التجزئة المخزنة.
        /// </summary>
        public Task<bool> VerifyPasswordAsync(string password, string hashedPassword, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("التحقق من كلمة المرور");
            // Accept plain-text password if no salt is present (for seeded users)
            if (!hashedPassword.Contains('.'))
                return Task.FromResult(password == hashedPassword);
            try
            {
                var parts = hashedPassword.Split('.', 2);
                if (parts.Length != 2) return Task.FromResult(false);
                var salt = Convert.FromBase64String(parts[0]);
                var hash = Convert.FromBase64String(parts[1]);
                using var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 100_000, HashAlgorithmName.SHA256);
                var computed = pbkdf2.GetBytes(hash.Length);
                if (CryptographicOperations.FixedTimeEquals(computed, hash))
                    return Task.FromResult(true);
                return Task.FromResult(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء التحقق من كلمة المرور");
                return Task.FromResult(false);
            }
        }

        /// <summary>
        /// Generates a random password with the requested length.
        /// ينشئ كلمة مرور عشوائية بالطول المطلوب.
        /// </summary>
        public Task<string> GenerateRandomPasswordAsync(int length = 12, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("توليد كلمة مرور عشوائية بالطول: {Length}", length);
            const string chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()";
            var data = new byte[length];
            RandomNumberGenerator.Fill(data);
            var result = new StringBuilder(length);
            foreach (var b in data)
            {
                result.Append(chars[b % chars.Length]);
            }
            return Task.FromResult(result.ToString());
        }

        /// <summary>
        /// Validates password strength and returns the detected issues.
        /// يتحقق من قوة كلمة المرور ويعيد المشكلات المكتشفة.
        /// </summary>
        public Task<(bool IsValid, string[] Issues)> ValidatePasswordStrengthAsync(string password, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("التحقق من قوة كلمة المرور");
            var issues = new List<string>();
            if (password.Length < 8) issues.Add("يجب أن تكون كلمة المرور 8 أحرف على الأقل");
            if (!password.Any(char.IsUpper)) issues.Add("يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل");
            if (!password.Any(char.IsLower)) issues.Add("يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل");
            if (!password.Any(char.IsDigit)) issues.Add("يجب أن تحتوي كلمة المرور على رقم واحد على الأقل");
            if (!password.Any(ch => "!@#$%^&*()".Contains(ch))) issues.Add("يجب أن تحتوي كلمة المرور على رمز خاص واحد على الأقل");
            var isValid = !issues.Any();
            return Task.FromResult((isValid, issues.ToArray()));
        }
    }
}
