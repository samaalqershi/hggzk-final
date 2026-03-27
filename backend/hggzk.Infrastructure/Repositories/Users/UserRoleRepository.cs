using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Users
{
    /// <summary>
    /// مستودع أدوار المستخدمين.
    /// User role repository.
    /// </summary>
    public class UserRoleRepository : BaseRepository<UserRole>, IUserRoleRepository
    {
        /// <summary>
        /// ينشئ مثيلاً جديداً من UserRoleRepository.
        /// Initializes a new instance of UserRoleRepository.
        /// </summary>
        public UserRoleRepository(YemenBookingDbContext context) : base(context) { }

        /// <summary>
        /// يجلب أدوار المستخدم.
        /// Gets the user roles.
        /// </summary>
        public async Task<IEnumerable<UserRole>> GetUserRolesAsync(Guid userId, CancellationToken cancellationToken = default)
            => await _dbSet.Where(ur => ur.UserId == userId).ToListAsync(cancellationToken);

    }
}
