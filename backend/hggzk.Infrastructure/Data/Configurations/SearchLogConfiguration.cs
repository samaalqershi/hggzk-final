using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations
{
    /// <summary>
    /// Configuration for the search log entity.
    /// تكوين كيان سجل البحث.
    /// </summary>
    public class SearchLogConfiguration : IEntityTypeConfiguration<SearchLog>
    {
        /// <summary>
        /// Applies the search log mapping rules.
        /// يطبق قواعد ربط سجل البحث.
        /// </summary>
        public void Configure(EntityTypeBuilder<SearchLog> builder)
        {
            builder.ToTable("SearchLogs");
            builder.HasKey(sl => sl.Id);
            builder.Property(sl => sl.UserId).IsRequired();
            builder.Property(sl => sl.SearchType).HasMaxLength(50).IsRequired();
            builder.Property(sl => sl.CriteriaJson).IsRequired();
            builder.Property(sl => sl.ResultCount).IsRequired();
            builder.Property(sl => sl.PageNumber).IsRequired();
            builder.Property(sl => sl.PageSize).IsRequired();

            // Optimized reads for suggestions endpoint (recent logs by type).
            builder.HasIndex(sl => new { sl.SearchType, sl.CreatedAt })
                .HasDatabaseName("IX_SearchLogs_SearchType_CreatedAt");
        }
    }
} 
