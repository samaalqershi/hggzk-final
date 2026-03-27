using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Contracts.Services.Authentication;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Infrastructure.Services.Authentication
{
    /// <summary>
    /// Provides password-reset token generation workflows.
    /// يوفّر مسارات إنشاء رموز إعادة تعيين كلمة المرور.
    /// </summary>
    public class PasswordResetService : IPasswordResetService
    {
        private readonly IUserRepository _userRepository;
        private readonly ILogger<PasswordResetService> _logger;

        /// <summary>
        /// Initializes a new instance of PasswordResetService with the required dependencies.
        /// يهيئ مثيلاً جديدًا من PasswordResetService باستخدام الاعتماديات المطلوبة.
        /// </summary>
        public PasswordResetService(
            IUserRepository userRepository,
            ILogger<PasswordResetService> logger)
        {
            _userRepository = userRepository;
            _logger = logger;
        }

        /// <summary>
        /// Generates a password-reset token for the specified user and stores its expiry.
        /// ينشئ رمز إعادة تعيين كلمة المرور للمستخدم المحدد ويخزن تاريخ انتهاء صلاحيته.
        /// </summary>
        public async Task<string> GenerateResetTokenAsync(Guid userId)
        {
            var user = await _userRepository.GetUserByIdAsync(userId, CancellationToken.None);
            if (user == null)
            {
                _logger.LogWarning("GenerateResetTokenAsync: لم يتم العثور على المستخدم {UserId}", userId);
                return string.Empty;
            }

            var token = Guid.NewGuid().ToString("N");
            user.PasswordResetToken = token;
            user.PasswordResetTokenExpires = DateTime.UtcNow.AddHours(2);

            await _userRepository.UpdateUserAsync(user, CancellationToken.None);
            await _userRepository.SaveChangesAsync(CancellationToken.None);
            _logger.LogInformation("تم إنشاء رمز إعادة تعيين كلمة المرور للمستخدم {UserId}", userId);

            return token;
        }
    }
}
