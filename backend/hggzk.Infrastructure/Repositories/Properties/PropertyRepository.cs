using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;
using YemenBooking.Core.Enums;

namespace YemenBooking.Infrastructure.Repositories.Properties
{
    /// <summary>
    /// Provides persistence operations and read helpers for properties.
    /// يوفّر عمليات الحفظ وقراءة البيانات الخاصة بالعقارات.
    /// </summary>
    public class PropertyRepository : BaseRepository<Property>, IPropertyRepository
    {
        /// <summary>
        /// يهيئ مثيلاً جديدًا من PropertyRepository باستخدام سياق قاعدة البيانات المشترك.
        /// Initializes a new instance of PropertyRepository with the shared database context.
        /// </summary>
        public PropertyRepository(YemenBookingDbContext context) : base(context) { }

        /// <summary>
        /// Creates a new property and stages it for persistence.
        /// ينشئ عقارًا جديدًا ويجهزه للحفظ.
        /// </summary>
        public async Task<Property> CreatePropertyAsync(Property property, CancellationToken cancellationToken = default)
        {
            await _dbSet.AddAsync(property, cancellationToken);
            return property;
        }

        /// <summary>
        /// Retrieves the specified property by its identifier.
        /// يسترجع العقار المحدد بواسطة المعرّف.
        /// </summary>
        public async Task<Property?> GetPropertyByIdAsync(Guid propertyId, CancellationToken cancellationToken = default)
            => await _dbSet
                .Include(p => p.PropertyType)
                .Include(p => p.Amenities)
                .Include(p => p.Services)
                .Include(p => p.Images)
                .Include(p => p.Reviews)
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.Id == propertyId, cancellationToken);

        /// <summary>
        /// Retrieves the specified property together with its linked units.
        /// يسترجع العقار المحدد مع الوحدات المرتبطة به.
        /// </summary>
        public async Task<Property?> GetPropertyWithUnitsAsync(Guid propertyId, CancellationToken cancellationToken = default)
            => await _dbSet
                .Include(p => p.Units)
                .FirstOrDefaultAsync(p => p.Id == propertyId, cancellationToken);

        /// <summary>
        /// Updates an existing property.
        /// يحدّث العقار الموجود.
        /// </summary>
        public async Task<Property> UpdatePropertyAsync(Property property, CancellationToken cancellationToken = default)
        {
            return TrackForUpdate(_dbSet, property);
        }

        /// <summary>
        /// Marks the specified property as approved.
        /// يعتمد العقار المحدد.
        /// </summary>
        public async Task<bool> ApprovePropertyAsync(Guid propertyId, CancellationToken cancellationToken = default)
        {
            var prop = await GetPropertyByIdAsync(propertyId, cancellationToken);
            if (prop == null) return false;
            prop.IsApproved = true;
            TrackForUpdate(_dbSet, prop);
            return true;
        }

        /// <summary>
        /// Marks the specified property as rejected and records the provided reason.
        /// يرفض العقار المحدد ويسجل السبب المقدم.
        /// </summary>
        public async Task<bool> RejectPropertyAsync(Guid propertyId, string reason, CancellationToken cancellationToken = default)
        {
            var prop = await GetPropertyByIdAsync(propertyId, cancellationToken);
            if (prop == null) return false;
            prop.IsApproved = false;
            TrackForUpdate(_dbSet, prop);
            return true;
        }

        /// <summary>
        /// Deletes the specified property.
        /// يحذف العقار المحدد.
        /// </summary>
        public async Task<bool> DeletePropertyAsync(Guid propertyId, CancellationToken cancellationToken = default)
        {
            var prop = await GetPropertyByIdAsync(propertyId, cancellationToken);
            if (prop == null) return false;
            _dbSet.Remove(prop);
            return true;
        }

        /// <summary>
        /// Retrieves all properties for the specified owner.
        /// يسترجع جميع العقارات الخاصة بالمالك المحدد.
        /// </summary>
        public async Task<IEnumerable<Property>> GetPropertiesByOwnerAsync(Guid ownerId, CancellationToken cancellationToken = default)
            => await _dbSet.Where(p => p.OwnerId == ownerId).ToListAsync(cancellationToken);

        /// <summary>
        /// Searches properties using the provided text term.
        /// يبحث في العقارات باستخدام نص البحث المقدم.
        /// </summary>
        public async Task<IEnumerable<Property>> SearchPropertiesAsync(string searchTerm, CancellationToken cancellationToken = default)
            => await _dbSet.Where(p => p.Name.Contains(searchTerm) || p.Description.Contains(searchTerm)).ToListAsync(cancellationToken);

        /// <summary>
        /// Returns search suggestions for the provided term.
        /// يعيد اقتراحات البحث للنص المقدم.
        /// </summary>
        public async Task<IReadOnlyList<string>> GetSearchSuggestionsAsync(
            string query,
            int limit = 10,
            CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(query))
            {
                return Array.Empty<string>();
            }

            var normalizedQuery = query.Trim();
            var boundedLimit = Math.Clamp(limit, 1, 20);

            try
            {
                return await GetSuggestionsWithFullTextAndTrigramAsync(
                    normalizedQuery,
                    boundedLimit,
                    cancellationToken);
            }
            catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.UndefinedFunction)
            {
                // Fallback when pg_trgm functions are not available.
                return await GetSuggestionsWithLikeFallbackAsync(
                    normalizedQuery,
                    boundedLimit,
                    cancellationToken);
            }
        }

        private async Task<IReadOnlyList<string>> GetSuggestionsWithFullTextAndTrigramAsync(
            string query,
            int limit,
            CancellationToken cancellationToken)
        {
            var sql = @"
WITH candidates AS (
    SELECT
        p.""Name"" AS ""Suggestion"",
        (
            ts_rank(
                to_tsvector(
                    'simple',
                    coalesce(p.""Name"", '') || ' ' ||
                    coalesce(p.""City"", '') || ' ' ||
                    coalesce(p.""Address"", '') || ' ' ||
                    coalesce(p.""Description"", '')
                ),
                plainto_tsquery('simple', @query)
            ) * 0.65
            +
            similarity(lower(coalesce(p.""Name"", '')), lower(@query)) * 0.30
            +
            similarity(lower(coalesce(p.""City"", '')), lower(@query)) * 0.05
        ) AS ""Score"",
        p.""BookingCount"" AS ""Popularity"",
        p.""CreatedAt"" AS ""CreatedAt""
    FROM ""Properties"" p
    WHERE p.""IsApproved"" = TRUE
      AND p.""IsDeleted"" = FALSE
      AND (
            to_tsvector(
                'simple',
                coalesce(p.""Name"", '') || ' ' ||
                coalesce(p.""City"", '') || ' ' ||
                coalesce(p.""Address"", '') || ' ' ||
                coalesce(p.""Description"", '')
            ) @@ plainto_tsquery('simple', @query)
            OR p.""Name"" ILIKE '%' || @query || '%'
            OR p.""City"" ILIKE '%' || @query || '%'
            OR p.""Address"" ILIKE '%' || @query || '%'
            OR similarity(lower(coalesce(p.""Name"", '')), lower(@query)) >= 0.20
            OR similarity(lower(coalesce(p.""City"", '')), lower(@query)) >= 0.25
      )

    UNION ALL

    SELECT
        p.""City"" AS ""Suggestion"",
        (
            ts_rank(
                to_tsvector('simple', coalesce(p.""City"", '')),
                plainto_tsquery('simple', @query)
            ) * 0.60
            +
            similarity(lower(coalesce(p.""City"", '')), lower(@query)) * 0.40
        ) AS ""Score"",
        p.""BookingCount"" AS ""Popularity"",
        p.""CreatedAt"" AS ""CreatedAt""
    FROM ""Properties"" p
    WHERE p.""IsApproved"" = TRUE
      AND p.""IsDeleted"" = FALSE
      AND (
            p.""City"" ILIKE '%' || @query || '%'
            OR similarity(lower(coalesce(p.""City"", '')), lower(@query)) >= 0.25
      )
)
SELECT c.""Suggestion"" AS ""Value""
FROM candidates c
WHERE c.""Suggestion"" IS NOT NULL
  AND length(trim(c.""Suggestion"")) > 0
GROUP BY c.""Suggestion""
ORDER BY
    max(c.""Score"") DESC,
    max(c.""Popularity"") DESC,
    max(c.""CreatedAt"") DESC
LIMIT @limit;
";

            var queryParam = new NpgsqlParameter("query", query);
            var limitParam = new NpgsqlParameter("limit", limit);

            var suggestions = await _context.Database
                .SqlQueryRaw<string>(sql, queryParam, limitParam)
                .ToListAsync(cancellationToken);

            return suggestions
                .Where(s => !string.IsNullOrWhiteSpace(s))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .Take(limit)
                .ToList();
        }

        private async Task<IReadOnlyList<string>> GetSuggestionsWithLikeFallbackAsync(
            string query,
            int limit,
            CancellationToken cancellationToken)
        {
            var sql = @"
WITH candidates AS (
    SELECT
        p.""Name"" AS ""Suggestion"",
        p.""BookingCount"" AS ""Popularity"",
        p.""CreatedAt"" AS ""CreatedAt""
    FROM ""Properties"" p
    WHERE p.""IsApproved"" = TRUE
      AND p.""IsDeleted"" = FALSE
      AND (
            p.""Name"" ILIKE '%' || @query || '%'
            OR p.""City"" ILIKE '%' || @query || '%'
            OR p.""Address"" ILIKE '%' || @query || '%'
      )

    UNION ALL

    SELECT
        p.""City"" AS ""Suggestion"",
        p.""BookingCount"" AS ""Popularity"",
        p.""CreatedAt"" AS ""CreatedAt""
    FROM ""Properties"" p
    WHERE p.""IsApproved"" = TRUE
      AND p.""IsDeleted"" = FALSE
      AND p.""City"" ILIKE '%' || @query || '%'
)
SELECT c.""Suggestion"" AS ""Value""
FROM candidates c
WHERE c.""Suggestion"" IS NOT NULL
  AND length(trim(c.""Suggestion"")) > 0
GROUP BY c.""Suggestion""
ORDER BY
    max(c.""Popularity"") DESC,
    max(c.""CreatedAt"") DESC,
    c.""Suggestion""
LIMIT @limit;
";

            var queryParam = new NpgsqlParameter("query", query);
            var limitParam = new NpgsqlParameter("limit", limit);

            var suggestions = await _context.Database
                .SqlQueryRaw<string>(sql, queryParam, limitParam)
                .ToListAsync(cancellationToken);

            return suggestions
                .Where(s => !string.IsNullOrWhiteSpace(s))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .Take(limit)
                .ToList();
        }

        /// <summary>
        /// Retrieves properties near the requested location.
        /// يسترجع العقارات القريبة من الموقع المطلوب.
        /// </summary>
        public async Task<IEnumerable<Property>> GetPropertiesNearLocationAsync(double latitude, double longitude, double radiusKm, CancellationToken cancellationToken = default)
        {
            return await _dbSet
                .Where(p => (Math.Pow((double)p.Latitude - latitude, 2) + Math.Pow((double)p.Longitude - longitude, 2)) <= radiusKm * radiusKm)
                .ToListAsync(cancellationToken);
        }

        /// <summary>
        /// Checks whether the property has active bookings.
        /// يتحقق مما إذا كان للعقار حجوزات نشطة.
        /// </summary>
        public async Task<bool> CheckActiveBookingsAsync(Guid propertyId, CancellationToken cancellationToken = default)
        {
            return await _context.Set<Booking>()
                .AnyAsync(b => b.Unit.PropertyId == propertyId && b.Status == BookingStatus.Confirmed, cancellationToken);
        }
        /// <summary>
        /// Returns the booking count for the specified property.
        /// يعيد عدد الحجوزات للعقار المحدد.
        /// </summary>
        public async Task<int> GetPropertyBookingCountAsync(Guid propertyId, CancellationToken cancellationToken = default)
        {
            return await _context.Set<Booking>()
                .CountAsync(b => b.Unit.PropertyId == propertyId, cancellationToken);
        }

        /// <summary>
        /// Returns the unit count for the specified property.
        /// يعيد عدد الوحدات للعقار المحدد.
        /// </summary>
        public async Task<int> GetUnitsCountAsync(Guid propertyId, CancellationToken cancellationToken = default)
            => await _context.Set<Unit>().CountAsync(u => u.PropertyId == propertyId, cancellationToken);

        /// <summary>
        /// Returns the service count for the specified property.
        /// يعيد عدد الخدمات للعقار المحدد.
        /// </summary>
        public async Task<int> GetServicesCountAsync(Guid propertyId, CancellationToken cancellationToken = default)
            => await _context.Set<PropertyService>().CountAsync(s => s.PropertyId == propertyId, cancellationToken);

        /// <summary>
        /// Returns the amenity count for the specified property.
        /// يعيد عدد المرافق للعقار المحدد.
        /// </summary>
        public async Task<int> GetAmenitiesCountAsync(Guid propertyId, CancellationToken cancellationToken = default)
            => await _context.Set<PropertyAmenity>().CountAsync(a => a.PropertyId == propertyId, cancellationToken);

        /// <summary>
        /// Returns the payment count for the specified property.
        /// يعيد عدد الدفعات للعقار المحدد.
        /// </summary>
        public async Task<int> GetPaymentsCountAsync(Guid propertyId, CancellationToken cancellationToken = default)
            => await _context.Set<Payment>().CountAsync(p => p.Booking.Unit.PropertyId == propertyId, cancellationToken);

        /// <summary>
        /// Retrieves the amenities linked to the property.
        /// يسترجع المرافق المرتبطة بالعقار.
        /// </summary>
        public async Task<IEnumerable<PropertyAmenity>> GetPropertyAmenitiesAsync(Guid propertyId, CancellationToken cancellationToken = default)
            => (await _context.Set<PropertyAmenity>().Where(a => a.PropertyId == propertyId).ToListAsync(cancellationToken));

        /// <summary>
        /// Calculates performance metrics for the requested property and date range.
        /// يحسب مؤشرات الأداء للعقار ونطاق التاريخ المطلوب.
        /// </summary>
        public async Task<object> CalculatePerformanceMetricsAsync(Guid propertyId, DateTime fromDate, DateTime toDate, CancellationToken cancellationToken = default)
        {
            var totalBookings = await _context.Set<Booking>()
                .CountAsync(b => b.Unit.PropertyId == propertyId && b.BookedAt >= fromDate && b.BookedAt <= toDate, cancellationToken);
            var totalRevenue = await _context.Set<Payment>()
                .Where(p => p.Booking.Unit.PropertyId == propertyId && p.PaymentDate >= fromDate && p.PaymentDate <= toDate)
                .SumAsync(p => p.Amount.Amount, cancellationToken);
            return new { totalBookings, totalRevenue };
        }

        /// <summary>
        /// Retrieves the owner identified by the given ID.
        /// يسترجع المالك المحدد بواسطة المعرّف.
        /// </summary>
        public async Task<User?> GetOwnerByIdAsync(Guid ownerId, CancellationToken cancellationToken = default)
            => await _context.Users.FindAsync(new object[]{ownerId}, cancellationToken);

        /// <summary>
        /// Retrieves the property type identified by the given ID.
        /// يسترجع نوع العقار المحدد بواسطة المعرّف.
        /// </summary>
        public async Task<PropertyType?> GetPropertyTypeByIdAsync(Guid propertyTypeId, CancellationToken cancellationToken = default)
            => await _context.Set<PropertyType>().FindAsync(new object[]{propertyTypeId}, cancellationToken);

        /// <summary>
        /// Retrieves the top-performing properties.
        /// يسترجع العقارات الأعلى أداءً.
        /// </summary>
        public async Task<IEnumerable<Property>> GetTopPerformingPropertiesAsync(int count, CancellationToken cancellationToken = default)
        {
            return await _dbSet
                .GroupJoin(_context.Set<Booking>(), p => p.Id, b => b.Unit.PropertyId, (p, bs) => new { Property = p, Count = bs.Count() })
                .OrderByDescending(x => x.Count)
                .Take(count)
                .Select(x => x.Property)
                .ToListAsync(cancellationToken);
        }

        /// <summary>
        /// Retrieves the cancellation policy for the specified property.
        /// يسترجع سياسة الإلغاء الخاصة بالعقار المحدد.
        /// </summary>
        public async Task<PropertyPolicy?> GetCancellationPolicyAsync(Guid propertyId, CancellationToken cancellationToken = default)
        {
            return await _context.Set<PropertyPolicy>()
                .FirstOrDefaultAsync(p => p.PropertyId == propertyId && p.Type == PolicyType.Cancellation, cancellationToken);
        }
    }
}
