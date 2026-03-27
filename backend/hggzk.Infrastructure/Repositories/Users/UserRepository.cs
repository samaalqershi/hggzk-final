using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;
using System.Linq;
using System.Text.Json;

namespace YemenBooking.Infrastructure.Repositories.Users
{
    /// <summary>
    /// مستودع المستخدمين.
    /// User repository.
    /// </summary>
    public class UserRepository : BaseRepository<User>, IUserRepository
    {
        /// <summary>
        /// ينشئ مثيلاً جديداً من UserRepository.
        /// Initializes a new instance of UserRepository.
        /// </summary>
        public UserRepository(YemenBookingDbContext context) : base(context) { }

        /// <summary>
        /// ينشئ مستخدمًا جديدًا.
        /// Creates a new user.
        /// </summary>
        public async Task<User> CreateUserAsync(User user, CancellationToken cancellationToken = default)
        {
            await _dbSet.AddAsync(user, cancellationToken);
            return user;
        }

        /// <summary>
        /// يجلب المستخدم حسب المعرف.
        /// Gets the user by identifier.
        /// </summary>
        public async Task<User?> GetUserByIdAsync(Guid userId, CancellationToken cancellationToken = default)
            => await _dbSet.FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);

        /// <summary>
        /// يجلب المستخدم حسب البريد الإلكتروني.
        /// Gets the user by email.
        /// </summary>
        public async Task<User?> GetUserByEmailAsync(string email, CancellationToken cancellationToken = default)
        {
            var normalized = (email ?? string.Empty).Trim().ToLower();
            return await _dbSet.FirstOrDefaultAsync(u => u.Email.ToLower() == normalized, cancellationToken);
        }

        /// <summary>
        /// يجلب المستخدم حسب مزود تسجيل الدخول الاجتماعي.
        /// Gets the user by social provider identifier.
        /// </summary>
        public async Task<User?> GetUserBySocialProviderIdAsync(string provider, string providerUserId, CancellationToken cancellationToken = default)
        {
            var p = (provider ?? string.Empty).Trim().ToLowerInvariant();
            var id = (providerUserId ?? string.Empty).Trim();
            if (string.IsNullOrWhiteSpace(p) || string.IsNullOrWhiteSpace(id)) return null;

            var like = $"\"{p}\"";
            var candidates = await _dbSet
                .Where(u => u.SettingsJson != null && EF.Functions.ILike(u.SettingsJson, $"%{like}%"))
                .ToListAsync(cancellationToken);

            foreach (var user in candidates)
            {
                try
                {
                    if (string.IsNullOrWhiteSpace(user.SettingsJson)) continue;
                    using var doc = JsonDocument.Parse(user.SettingsJson);
                    if (!doc.RootElement.TryGetProperty("social", out var socialEl) || socialEl.ValueKind != JsonValueKind.Object)
                        continue;

                    if (!socialEl.TryGetProperty(p, out var providerEl) || providerEl.ValueKind != JsonValueKind.Object)
                        continue;

                    if (!providerEl.TryGetProperty("id", out var idEl)) continue;
                    var storedId = idEl.GetString();
                    if (!string.IsNullOrWhiteSpace(storedId) && string.Equals(storedId, id, StringComparison.Ordinal))
                    {
                        return user;
                    }
                }
                catch
                {
                }
            }
            return null;
        }

        /// <summary>
        /// يجلب المستخدم حسب رقم الهاتف.
        /// Gets the user by phone number.
        /// </summary>
        public async Task<User?> GetByPhoneAsync(string phone, CancellationToken cancellationToken = default)
            => await _dbSet.FirstOrDefaultAsync(u => u.Phone == phone, cancellationToken);

        /// <summary>
        /// يتحقق من وجود البريد الإلكتروني.
        /// Checks whether the email exists.
        /// </summary>
        public async Task<bool> CheckEmailExistsAsync(string email, CancellationToken cancellationToken = default)
        {
            var normalized = (email ?? string.Empty).Trim().ToLower();
            return await _dbSet.AnyAsync(u => u.Email.ToLower() == normalized, cancellationToken);
        }

        /// <summary>
        /// يحدّث المستخدم.
        /// Updates the user.
        /// </summary>
        public Task<User> UpdateUserAsync(User user, CancellationToken cancellationToken = default)
        {
            return Task.FromResult(TrackForUpdate(_dbSet, user));
        }

        /// <summary>
        /// يعطّل المستخدم.
        /// Deactivates the user.
        /// </summary>
        public async Task<bool> DeactivateUserAsync(Guid userId, CancellationToken cancellationToken = default)
        {
            var user = await GetUserByIdAsync(userId, cancellationToken);
            if (user == null) return false;
            user.IsActive = false;
            TrackForUpdate(_dbSet, user);
            return true;
        }


        /// <summary>
        /// يفعّل المستخدم.
        /// Activates the user.
        /// </summary>
        public async Task<bool> ActivateUserAsync(Guid userId, CancellationToken cancellationToken = default)
        {
            var user = await GetUserByIdAsync(userId, cancellationToken);
            if (user == null) return false;
            user.IsActive = true;
            TrackForUpdate(_dbSet, user);
            return true;
        }

        /// <summary>
        /// يجلب جميع المستخدمين.
        /// Gets all users.
        /// </summary>
        public async Task<IEnumerable<User>> GetAllUsersAsync(CancellationToken cancellationToken = default)
            => await _dbSet.ToListAsync(cancellationToken);

        /// <summary>
        /// يبحث عن المستخدمين.
        /// Searches users.
        /// </summary>
        public async Task<IEnumerable<User>> SearchUsersAsync(string searchTerm, CancellationToken cancellationToken = default)
            => await _dbSet
                .Where(u => u.Name.Contains(searchTerm) || u.Email.Contains(searchTerm))
                .ToListAsync(cancellationToken);

        /// <summary>
        /// يجلب المالك حسب المعرف.
        /// Gets the owner by identifier.
        /// </summary>
        public async Task<User?> GetOwnerByIdAsync(Guid ownerId, CancellationToken cancellationToken = default)
            => await GetUserByIdAsync(ownerId, cancellationToken);

        /// <summary>
        /// يجلب أدوار المستخدم.
        /// Gets the user roles.
        /// </summary>
        public async Task<IEnumerable<UserRole>> GetUserRolesAsync(Guid userId, CancellationToken cancellationToken = default)
        {
            return await _context.Set<UserRole>()
                .Include(ur => ur.Role)
                .Where(ur => ur.UserId == userId)
                .ToListAsync(cancellationToken);
        }

    }
}
