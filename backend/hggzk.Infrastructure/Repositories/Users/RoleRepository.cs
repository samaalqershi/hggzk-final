using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Users
{
    /// <summary>
    /// مستودع الأدوار.
    /// Role repository.
    /// </summary>
    public class RoleRepository : BaseRepository<Role>, IRoleRepository
    {
        /// <summary>
        /// ينشئ مثيلاً جديداً من RoleRepository.
        /// Initializes a new instance of RoleRepository.
        /// </summary>
        public RoleRepository(YemenBookingDbContext context) : base(context) { }

        /// <summary>
        /// يجلب الدور حسب المعرف.
        /// Gets the role by identifier.
        /// </summary>
        public async Task<Role?> GetRoleByIdAsync(Guid roleId, CancellationToken cancellationToken = default)
            => await _dbSet.FindAsync(new object[]{roleId}, cancellationToken);

        /// <summary>
        /// يجلب جميع الأدوار.
        /// Gets all roles.
        /// </summary>
        public async Task<IEnumerable<Role>> GetAllRolesAsync(CancellationToken cancellationToken = default)
            => await _dbSet.ToListAsync(cancellationToken);

        /// <summary>
        /// ينشئ دورًا جديدًا.
        /// Creates a new role.
        /// </summary>
        public async Task<Role> CreateRoleAsync(Role role, CancellationToken cancellationToken = default)
        {
            await _dbSet.AddAsync(role, cancellationToken);
            return role;
        }

        /// <summary>
        /// يحدّث الدور.
        /// Updates the role.
        /// </summary>
        public Task<Role> UpdateRoleAsync(Role role, CancellationToken cancellationToken = default)
        {
            return Task.FromResult(TrackForUpdate(_dbSet, role));
        }

        /// <summary>
        /// يحذف الدور.
        /// Deletes the role.
        /// </summary>
        public async Task<bool> DeleteRoleAsync(Guid roleId, CancellationToken cancellationToken = default)
        {
            var role = await GetRoleByIdAsync(roleId, cancellationToken);
            if (role == null) return false;
            _dbSet.Remove(role);
            return true;
        }

        /// <summary>
        /// يسند الدور إلى المستخدم.
        /// Assigns the role to the user.
        /// </summary>
        public async Task<bool> AssignRoleToUserAsync(Guid userId, Guid roleId, CancellationToken cancellationToken = default)
        {
            var alreadyTracked = _context.Set<UserRole>().Local.Any(ur => ur.UserId == userId && ur.RoleId == roleId);
            if (alreadyTracked)
            {
                return true;
            }

            var alreadyExists = await _context.Set<UserRole>()
                .AnyAsync(r => r.UserId == userId && r.RoleId == roleId, cancellationToken);

            if (alreadyExists)
            {
                return true;
            }

            var trackedUser = _context.Users.Local.FirstOrDefault(u => u.Id == userId);
            var trackedRole = _context.Roles.Local.FirstOrDefault(r => r.Id == roleId);

            var userRole = new UserRole
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                RoleId = roleId,
                AssignedAt = DateTime.UtcNow,
                User = trackedUser!,
                Role = trackedRole!
            };

            await _context.Set<UserRole>().AddAsync(userRole, cancellationToken);
            return true;
        }

        /// <summary>
        /// يزيل الدور من المستخدم.
        /// Removes the role from the user.
        /// </summary>
        public async Task<bool> RemoveRoleFromUserAsync(Guid userId, Guid roleId, CancellationToken cancellationToken = default)
        {
            var ur = await _context.Set<UserRole>().FirstOrDefaultAsync(r => r.UserId == userId && r.RoleId == roleId, cancellationToken);
            if (ur == null) return false;
            _context.Set<UserRole>().Remove(ur);
            return true;
        }

    }
}
