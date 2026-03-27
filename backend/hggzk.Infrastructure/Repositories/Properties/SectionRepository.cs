using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Linq.Expressions;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Properties
{
	/// <summary>
	/// Provides persistence and assignment workflows for sections.
	/// يوفّر عمليات الحفظ وتعيين العناصر الخاصة بالأقسام.
	/// </summary>
	public class SectionRepository : ISectionRepository
	{
        private readonly YemenBookingDbContext _context;
        private readonly DbSet<Section> _sections;

		/// <summary>
		/// يهيئ مثيلاً جديدًا من SectionRepository باستخدام سياق قاعدة البيانات المشترك.
		/// Initializes a new instance of SectionRepository with the shared database context.
		/// </summary>
		public SectionRepository(YemenBookingDbContext context)
        {
            _context = context;
            _sections = context.Set<Section>();
        }

        /// <summary>
        /// Retrieves the specified section by its identifier.
        /// يسترجع القسم المحدد بواسطة المعرّف.
        /// </summary>
        public async Task<Section?> GetByIdAsync(Guid sectionId, CancellationToken cancellationToken = default)
            => await _sections.FirstOrDefaultAsync(section => section.Id == sectionId, cancellationToken);

        /// <summary>
        /// Retrieves all sections.
        /// يسترجع جميع الأقسام.
        /// </summary>
        public async Task<IEnumerable<Section>> GetAllAsync(CancellationToken cancellationToken = default)
            => await _sections
                .OrderBy(section => section.DisplayOrder)
                .ToListAsync(cancellationToken);

        /// <summary>
        /// Finds sections that match the provided predicate.
        /// يبحث عن الأقسام المطابقة للشرط المقدم.
        /// </summary>
        public async Task<IEnumerable<Section>> FindAsync(Expression<Func<Section, bool>> predicate, CancellationToken cancellationToken = default)
            => await _sections.Where(predicate).ToListAsync(cancellationToken);

		/// <summary>
		/// Creates a new section and stages it for persistence.
		/// ينشئ قسمًا جديدًا ويجهزه للحفظ.
		/// </summary>
		public async Task<Section> CreateAsync(Section section, CancellationToken cancellationToken = default)
		{
			await _sections.AddAsync(section, cancellationToken);
			return section;
		}

		/// <summary>
		/// Updates an existing section.
		/// يحدّث القسم الموجود.
		/// </summary>
		public async Task<Section> UpdateAsync(Section section, CancellationToken cancellationToken = default)
		{
			return TrackForUpdate(_sections, section);
		}

        /// <summary>
        /// Deletes the specified section.
        /// يحذف القسم المحدد.
        /// </summary>
        public async Task<bool> DeleteAsync(Guid sectionId, CancellationToken cancellationToken = default)
        {
            var entity = await _sections
                .Include(s => s.PropertyItems)
                .Include(s => s.UnitItems)
                .FirstOrDefaultAsync(s => s.Id == sectionId, cancellationToken);
            if (entity == null) return false;
            _context.RemoveRange(entity.PropertyItems);
            _context.RemoveRange(entity.UnitItems);
            _sections.Remove(entity);
            return true;
        }

        public async Task<(IEnumerable<Section> Items, int TotalCount)> GetPagedAsync(int pageNumber, int pageSize, SectionTarget? target, SectionType? type, string? cityName, CancellationToken cancellationToken = default)
        {
            var query = _sections.AsQueryable();
            if (target.HasValue) query = query.Where(s => s.Target == target);
            if (type.HasValue) query = query.Where(s => s.Type == type);
            if (!string.IsNullOrWhiteSpace(cityName))
            {
                var cn = cityName!.Trim();
                query = query.Where(s => s.CityName != null && s.CityName == cn);
            }
            var total = await query.CountAsync(cancellationToken);
            var items = await query
                .OrderBy(s => s.DisplayOrder)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync(cancellationToken);
            return (items, total);
        }

        // Legacy GetItemsAsync removed along with SectionItem

		/// <summary>
		/// Retrieves the property items linked to the specified section.
		/// يسترجع عناصر العقارات المرتبطة بالقسم المحدد.
		/// </summary>
		public async Task<IEnumerable<PropertyInSection>> GetPropertyItemsAsync(Guid sectionId, CancellationToken cancellationToken = default)
		{
			return await _context.PropertyInSections
				.Where(i => i.SectionId == sectionId)
				.OrderBy(i => i.DisplayOrder)
				.ToListAsync(cancellationToken);
		}

		/// <summary>
		/// Retrieves the unit items linked to the specified section.
		/// يسترجع عناصر الوحدات المرتبطة بالقسم المحدد.
		/// </summary>
		public async Task<IEnumerable<UnitInSection>> GetUnitItemsAsync(Guid sectionId, CancellationToken cancellationToken = default)
		{
			return await _context.UnitInSections
				.Where(i => i.SectionId == sectionId)
				.OrderBy(i => i.DisplayOrder)
				.ToListAsync(cancellationToken);
		}

        /// <summary>
        /// Assigns properties to the specified section.
        /// يعين العقارات إلى القسم المحدد.
        /// </summary>
        public async Task AssignPropertiesAsync(Guid sectionId, IEnumerable<Guid> propertyIds, CancellationToken cancellationToken = default)
        {
            // This compatibility path keeps legacy callers working until all flows migrate to rich section items.
			var existing = await _context.PropertyInSections.Where(i => i.SectionId == sectionId).ToListAsync(cancellationToken);
			_context.PropertyInSections.RemoveRange(existing);
			var toAdd = propertyIds.Distinct().Select(pid => new PropertyInSection { SectionId = sectionId, PropertyId = pid }).ToList();
			await _context.PropertyInSections.AddRangeAsync(toAdd, cancellationToken);
		}

        /// <summary>
        /// Assigns units to the specified section.
        /// يعين الوحدات إلى القسم المحدد.
        /// </summary>
        public async Task AssignUnitsAsync(Guid sectionId, IEnumerable<Guid> unitIds, CancellationToken cancellationToken = default)
        {
            var existing = await _context.UnitInSections.Where(i => i.SectionId == sectionId).ToListAsync(cancellationToken);
            _context.UnitInSections.RemoveRange(existing);

            var distinctIds = unitIds.Distinct().ToList();
			if (distinctIds.Count == 0)
			{
				return;
			}

            var units = await _context.Units
                .AsNoTracking()
                .Where(u => distinctIds.Contains(u.Id))
                .Include(u => u.Property)
                .Include(u => u.UnitType)
                .ToListAsync(cancellationToken);

            // Unit section items intentionally denormalize display fields so section reads stay fast.
            var items = new List<UnitInSection>(units.Count);
            foreach (var u in units)
            {
                var p = u.Property;
                var ut = u.UnitType;
                if (p == null || ut == null) continue;

                items.Add(new UnitInSection
                {
                    SectionId = sectionId,
                    UnitId = u.Id,
                    PropertyId = u.PropertyId,

                    UnitName = u.Name,
                    PropertyName = p.Name,
                    UnitTypeId = u.UnitTypeId,
                    UnitTypeName = ut.Name,
                    UnitTypeIcon = ut.Icon,

                    MaxCapacity = u.MaxCapacity,
                    Currency = p.Currency,
                    PricingMethod = u.PricingMethod,
                    AdultsCapacity = u.AdultsCapacity,
                    ChildrenCapacity = u.ChildrenCapacity,

                    PropertyAddress = p.Address,
                    PropertyCity = p.City,
                    Latitude = p.Latitude,
                    Longitude = p.Longitude,
                    PropertyStarRating = p.StarRating,
                    PropertyAverageRating = p.AverageRating,

                    // Defaults handled by entity defaults
                });
            }

            if (items.Count > 0)
            {
                await _context.UnitInSections.AddRangeAsync(items, cancellationToken);
            }
        }

		/// <summary>
		/// Assigns property items to the specified section.
		/// يعين عناصر العقار إلى القسم المحدد.
		/// </summary>
		public async Task AssignPropertyItemsAsync(Guid sectionId, IEnumerable<PropertyInSection> items, CancellationToken cancellationToken = default)
		{
			var existing = await _context.PropertyInSections.Where(i => i.SectionId == sectionId).ToListAsync(cancellationToken);
			_context.PropertyInSections.RemoveRange(existing);
			foreach (var item in items)
			{
				item.SectionId = sectionId;
			}
			await _context.PropertyInSections.AddRangeAsync(items, cancellationToken);
		}

		/// <summary>
		/// Assigns unit items to the specified section.
		/// يعين عناصر الوحدة إلى القسم المحدد.
		/// </summary>
		public async Task AssignUnitItemsAsync(Guid sectionId, IEnumerable<UnitInSection> items, CancellationToken cancellationToken = default)
		{
			var existing = await _context.UnitInSections.Where(i => i.SectionId == sectionId).ToListAsync(cancellationToken);
			_context.UnitInSections.RemoveRange(existing);
			foreach (var item in items)
			{
				item.SectionId = sectionId;
			}
			await _context.UnitInSections.AddRangeAsync(items, cancellationToken);
		}

        /// <summary>
        /// Adds properties to the specified section.
        /// يضيف العقارات إلى القسم المحدد.
        /// </summary>
        public async Task AddPropertiesAsync(Guid sectionId, IEnumerable<Guid> propertyIds, CancellationToken cancellationToken = default)
        {
            var existingKeys = await _context.PropertyInSections.Where(i => i.SectionId == sectionId).Select(i => i.PropertyId).ToListAsync(cancellationToken);
            var toAdd = propertyIds.Distinct().Except(existingKeys).Select(pid => new PropertyInSection { SectionId = sectionId, PropertyId = pid }).ToList();
            if (toAdd.Count > 0)
            {
                await _context.PropertyInSections.AddRangeAsync(toAdd, cancellationToken);
            }
        }

        /// <summary>
        /// Adds units to the specified section.
        /// يضيف الوحدات إلى القسم المحدد.
        /// </summary>
        public async Task AddUnitsAsync(Guid sectionId, IEnumerable<Guid> unitIds, CancellationToken cancellationToken = default)
        {
            var existingKeys = await _context.UnitInSections.Where(i => i.SectionId == sectionId).Select(i => i.UnitId).ToListAsync(cancellationToken);
            var newUnitIds = unitIds.Distinct().Except(existingKeys).ToList();

            if (newUnitIds.Count == 0)
                return;

            var units = await _context.Units
                .AsNoTracking()
                .Where(u => newUnitIds.Contains(u.Id))
                .Include(u => u.Property)
                .Include(u => u.UnitType)
                .ToListAsync(cancellationToken);

            var items = new List<UnitInSection>(units.Count);
            foreach (var u in units)
            {
                var p = u.Property;
                var ut = u.UnitType;
                if (p == null || ut == null) continue;

                items.Add(new UnitInSection
                {
                    SectionId = sectionId,
                    UnitId = u.Id,
                    PropertyId = u.PropertyId,

                    UnitName = u.Name,
                    PropertyName = p.Name,
                    UnitTypeId = u.UnitTypeId,
                    UnitTypeName = ut.Name,
                    UnitTypeIcon = ut.Icon,

                    MaxCapacity = u.MaxCapacity,
                    Currency = p.Currency,
                    PricingMethod = u.PricingMethod,
                    AdultsCapacity = u.AdultsCapacity,
                    ChildrenCapacity = u.ChildrenCapacity,

                    PropertyAddress = p.Address,
                    PropertyCity = p.City,
                    Latitude = p.Latitude,
                    Longitude = p.Longitude,
                    PropertyStarRating = p.StarRating,
                    PropertyAverageRating = p.AverageRating,

                    // Defaults handled by entity defaults
                });
            }

			if (items.Count > 0)
			{
				await _context.UnitInSections.AddRangeAsync(items, cancellationToken);
			}
        }

        /// <summary>
        /// Removes the specified item from the section.
        /// يزيل العنصر المحدد من القسم.
        /// </summary>
        public async Task RemoveItemAsync(Guid sectionId, Guid itemId, CancellationToken cancellationToken = default)
        {
            // Try remove from rich tables
            var propItem = await _context.PropertyInSections.FirstOrDefaultAsync(i => i.SectionId == sectionId && i.Id == itemId, cancellationToken);
            if (propItem != null)
            {
                _context.PropertyInSections.Remove(propItem);
                return;
            }
            var unitItem = await _context.UnitInSections.FirstOrDefaultAsync(i => i.SectionId == sectionId && i.Id == itemId, cancellationToken);
            if (unitItem != null)
            {
                _context.UnitInSections.Remove(unitItem);
            }
        }

        /// <summary>
        /// Reorders the items within the specified section.
        /// يعيد ترتيب العناصر داخل القسم المحدد.
        /// </summary>
        public async Task ReorderItemsAsync(Guid sectionId, IReadOnlyList<(Guid ItemId, int SortOrder)> orders, CancellationToken cancellationToken = default)
        {
            var itemIds = orders.Select(o => o.ItemId).ToList();
            var propItems = await _context.PropertyInSections.Where(i => i.SectionId == sectionId && itemIds.Contains(i.Id)).ToListAsync(cancellationToken);
            foreach (var item in propItems)
            {
                var ord = orders.First(o => o.ItemId == item.Id).SortOrder;
                item.DisplayOrder = ord;
            }

            var unitItems = await _context.UnitInSections.Where(i => i.SectionId == sectionId && itemIds.Contains(i.Id)).ToListAsync(cancellationToken);
            foreach (var item in unitItems)
            {
                var ord = orders.First(o => o.ItemId == item.Id).SortOrder;
                item.DisplayOrder = ord;
            }
        }

        /// <summary>
        /// Persists the pending changes to the database.
        /// يحفظ التغييرات المعلّقة في قاعدة البيانات.
        /// </summary>
        public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
            => _context.SaveChangesAsync(cancellationToken);

        private TEntity TrackForUpdate<TEntity>(DbSet<TEntity> dbSet, TEntity entity) where TEntity : class
        {
            var entry = _context.Entry(entity);
            if (entry.State == EntityState.Detached)
            {
                dbSet.Attach(entity);
                entry = _context.Entry(entity);
            }

            if (entry.State != EntityState.Added)
            {
                entry.State = EntityState.Modified;
            }

            return entity;
        }
	}
}
