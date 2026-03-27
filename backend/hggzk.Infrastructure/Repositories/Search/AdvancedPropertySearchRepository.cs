using System.Collections.Generic;
using System.Data;
using System.Threading;
using System.Threading.Tasks;
using Dapper;
using YemenBooking.Application.Features.Properties.Queries.SearchAdvancedProperty;
using YemenBooking.Application.Features.Properties.DTOs;
using YemenBooking.Application.Contracts.Persistence.Repositories.Search;
using YemenBooking.Application.Common.Models;
using System.Linq;

namespace YemenBooking.Infrastructure.Repositories.Search
{
    /// <summary>
    /// Executes advanced property searches through Dapper.
    /// ينفّذ عمليات البحث المتقدم عن العقارات باستخدام Dapper.
    /// </summary>
    public class AdvancedPropertySearchRepository : IAdvancedPropertySearchRepository
    {
        private readonly IDbConnection _connection;

        /// <summary>
        /// يهيئ مثيلاً جديدًا من AdvancedPropertySearchRepository باستخدام سياق قاعدة البيانات المشترك.
        /// Initializes a new instance of AdvancedPropertySearchRepository with the shared database context.
        /// </summary>
        public AdvancedPropertySearchRepository(IDbConnection connection)
        {
            _connection = connection;
        }

        /// <summary>
        /// Executes an advanced property search using the provided criteria.
        /// ينفّذ بحثًا متقدمًا عن العقارات باستخدام المعايير المقدمة.
        /// </summary>
        public async Task<IEnumerable<AdvancedPropertyDto>> SearchAsync(AdvancedPropertySearchQuery query, CancellationToken cancellationToken = default)
        {
            // تجهيز المعاملات للإجراء المخزن
            var parameters = new DynamicParameters();
            parameters.Add("@PropertyTypeId", query.PropertyTypeId);
            parameters.Add("@FromDate", query.FromDate);
            parameters.Add("@ToDate", query.ToDate);
            parameters.Add("@MinPrice", query.MinPrice);
            parameters.Add("@MaxPrice", query.MaxPrice);
            parameters.Add("@Currency", query.Currency);
            // المصفوفات المسموحة يجب تمريرها كجداول قياسية (see SQL types JsonFilters/GuidList)
            parameters.Add("@PrimaryFieldFilters", query.PrimaryFieldFilters);
            parameters.Add("@FieldFilters", query.FieldFilters);
            parameters.Add("@UnitTypeIds", query.UnitTypeIds);
            parameters.Add("@AmenityIds", query.AmenityIds);
            parameters.Add("@ServiceIds", query.ServiceIds);
            parameters.Add("@SortBy", query.SortBy);
            parameters.Add("@IsAscending", query.IsAscending);
            // pagination parameters removed from repository

            // تنفيذ الإجراء المخزن واسترجاع البيانات
            var allResults = await _connection.QueryAsync<AdvancedPropertyDto>(
                "sp_AdvancedPropertySearch", 
                parameters, 
                commandType: CommandType.StoredProcedure);

            // Return full list without pagination
            return allResults.AsList();
        }
    }
} 
