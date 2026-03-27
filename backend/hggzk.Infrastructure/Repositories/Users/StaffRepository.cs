using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;
using YemenBooking.Core.Enums;

namespace YemenBooking.Infrastructure.Repositories.Users
{
    /// <summary>
    /// مستودع الموظفين.
    /// Staff repository.
    /// </summary>
    public class StaffRepository : BaseRepository<Staff>, IStaffRepository
    {
        /// <summary>
        /// ينشئ مثيلاً جديداً من StaffRepository.
        /// Initializes a new instance of StaffRepository.
        /// </summary>
        public StaffRepository(YemenBookingDbContext context) : base(context) { }

        /// <summary>
        /// يضيف موظفًا جديدًا.
        /// Adds a new staff member.
        /// </summary>
        public async Task<Staff> AddStaffAsync(Staff staff, CancellationToken cancellationToken = default)
        {
            await _dbSet.AddAsync(staff, cancellationToken);
            return staff;
        }

        /// <summary>
        /// يجلب الموظف حسب المعرف.
        /// Gets the staff member by identifier.
        /// </summary>
        public async Task<Staff?> GetStaffByIdAsync(Guid staffId, CancellationToken cancellationToken = default)
            => await _dbSet.FindAsync(new object[]{staffId}, cancellationToken);

        /// <summary>
        /// يحدّث بيانات الموظف.
        /// Updates the staff member.
        /// </summary>
        public async Task<Staff> UpdateStaffAsync(Staff staff, CancellationToken cancellationToken = default)
        {
            return TrackForUpdate(_dbSet, staff);
        }

        /// <summary>
        /// يحذف الموظف.
        /// Removes the staff member.
        /// </summary>
        public async Task<bool> RemoveStaffAsync(Guid staffId, CancellationToken cancellationToken = default)
        {
            var staff = await GetStaffByIdAsync(staffId, cancellationToken);
            if (staff == null) return false;
            _dbSet.Remove(staff);
            return true;
        }

        /// <summary>
        /// يجلب الموظفين حسب العقار.
        /// Gets staff members by property.
        /// </summary>
        public async Task<IEnumerable<Staff>> GetStaffByPropertyAsync(Guid propertyId, CancellationToken cancellationToken = default)
            => await _dbSet.Where(s => s.PropertyId == propertyId).ToListAsync(cancellationToken);

        /// <summary>
        /// يجلب الموظف حسب المستخدم.
        /// Gets the staff member by user.
        /// </summary>
        public async Task<Staff?> GetStaffByUserAsync(Guid userId, CancellationToken cancellationToken = default)
            => await _dbSet.FirstOrDefaultAsync(s => s.UserId == userId, cancellationToken);

        /// <summary>
        /// يجلب الموظفين حسب المنصب.
        /// Gets staff members by position.
        /// </summary>
        public async Task<IEnumerable<Staff>> GetStaffByPositionAsync(string position, Guid? propertyId = null, CancellationToken cancellationToken = default)
        {
            var parsedPosition = Enum.Parse<StaffPosition>(position, true);
            var query = _dbSet.Where(s => s.Position == parsedPosition);
            if (propertyId.HasValue) query = query.Where(s => s.PropertyId == propertyId.Value);
            return await query.ToListAsync(cancellationToken);
        }

        /// <summary>
        /// يجلب المستخدم حسب المعرف.
        /// Gets the user by identifier.
        /// </summary>
        public async Task<User?> GetUserByIdAsync(Guid userId, CancellationToken cancellationToken = default)
            => await _context.Set<User>().FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);

        /// <summary>
        /// يجلب العقار حسب المعرف.
        /// Gets the property by identifier.
        /// </summary>
        public async Task<Property?> GetPropertyByIdAsync(Guid propertyId, CancellationToken cancellationToken = default)
            => await _context.Set<Property>().FirstOrDefaultAsync(p => p.Id == propertyId, cancellationToken);
    }
} 
