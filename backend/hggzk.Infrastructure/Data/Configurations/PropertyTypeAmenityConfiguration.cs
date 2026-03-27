using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the property-type amenity entity mapping.
/// يهيئ ربط كيان وسيلة نوع العقار بقاعدة البيانات.
/// </summary>
public class PropertyTypeAmenityConfiguration : IEntityTypeConfiguration<PropertyTypeAmenity>
{
    /// <summary>
    /// Applies the property-type amenity mapping rules.
    /// يطبق قواعد ربط كيان وسيلة نوع العقار.
    /// </summary>
    public void Configure(EntityTypeBuilder<PropertyTypeAmenity> builder)
    {
        builder.ToTable("PropertyTypeAmenities");

        // BaseEntity fields. حقول BaseEntity.
        builder.Property(b => b.Id).HasColumnName("PtaId").IsRequired();
        builder.Property(b => b.IsDeleted).HasDefaultValue(false);
        builder.Property(b => b.DeletedAt).HasColumnType("timestamp with time zone");
        
        // Other scalar properties. الخصائص الأخرى.
        builder.Property(pta => pta.PropertyTypeId).IsRequired();
        builder.Property(pta => pta.AmenityId).IsRequired();
        builder.Property(pta => pta.IsDefault).HasDefaultValue(false);
        
        // Primary key. المفتاح الأساسي.
        builder.HasKey(pta => pta.Id);
        
        // Relationships. العلاقات.
        builder.HasOne(pta => pta.PropertyType)
               .WithMany(pt => pt.PropertyTypeAmenities)
               .HasForeignKey(pta => pta.PropertyTypeId);
        
        builder.HasOne(pta => pta.Amenity)
               .WithMany(a => a.PropertyTypeAmenities)
               .HasForeignKey(pta => pta.AmenityId);
        
        builder.HasMany(pta => pta.PropertyAmenities)
               .WithOne(pa => pa.PropertyTypeAmenity)
               .HasForeignKey(pa => pa.PtaId);

        // Indexes. الفهارس.
        builder.HasIndex(pta => pta.PropertyTypeId)
            .HasDatabaseName("IX_PropertyTypeAmenities_PropertyTypeId");

        builder.HasIndex(pta => pta.AmenityId)
            .HasDatabaseName("IX_PropertyTypeAmenities_AmenityId");

        builder.HasIndex(pta => new { pta.PropertyTypeId, pta.AmenityId })
            .IsUnique()
            .HasDatabaseName("IX_PropertyTypeAmenities_PropertyTypeId_AmenityId");

        builder.HasIndex(pta => pta.IsDeleted)
            .HasDatabaseName("IX_PropertyTypeAmenities_IsDeleted");

        builder.HasQueryFilter(pta => !pta.IsDeleted);
    }
}
