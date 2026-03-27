using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations.Indexes;

/// <summary>
/// Index configuration for PropertyAmenities.
/// تكوين فهارس جدول PropertyAmenities.
/// </summary>
public class PropertyAmenityIndexConfiguration : IEntityTypeConfiguration<PropertyAmenity>
{
    /// <summary>
    /// Applies the PropertyAmenity index rules.
    /// يطبق قواعد فهارس PropertyAmenity.
    /// </summary>
    public void Configure(EntityTypeBuilder<PropertyAmenity> builder)
    {
        // Index on PropertyId + PtaId (PropertyTypeAmenityId).
        // فهرس على PropertyId + PtaId (PropertyTypeAmenityId).
        builder.HasIndex(pa => new { pa.PropertyId, pa.PtaId })
            .HasDatabaseName("IX_PropertyAmenities_PropertyId_PtaId");
        
        // Index on PtaId for reverse lookup.
        // فهرس على PtaId للبحث العكسي.
        builder.HasIndex(pa => pa.PtaId)
            .HasDatabaseName("IX_PropertyAmenities_PtaId");
    }
}
