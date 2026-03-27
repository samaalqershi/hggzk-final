using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the Amenity entity mapping.
/// يهيئ ربط كيان المرفق بقاعدة البيانات. / Configures the Amenity entity mapping.
/// </summary>
public class AmenityConfiguration : IEntityTypeConfiguration<Amenity>
{
    /// <summary>
    /// Applies the Amenity mapping rules.
    /// يطبق قواعد ربط كيان المرفق. / Applies the Amenity mapping rules.
    /// </summary>
    public void Configure(EntityTypeBuilder<Amenity> builder)
    {
        builder.ToTable("Amenities");

        builder.HasKey(a => a.Id);

        builder.Property(b => b.Id).HasColumnName("AmenityId").IsRequired();
        builder.Property(b => b.IsDeleted).HasDefaultValue(false);
        builder.Property(b => b.DeletedAt).HasColumnType("timestamp with time zone");

        builder.Property(a => a.Name).IsRequired().HasMaxLength(50);
        builder.Property(a => a.Description).HasMaxLength(200);

        builder.HasIndex(a => a.Name).IsUnique();

        builder.HasMany(a => a.PropertyTypeAmenities)
            .WithOne(pta => pta.Amenity)
            .HasForeignKey(pta => pta.AmenityId);

        builder.HasQueryFilter(a => !a.IsDeleted);

        // Seed data is handled by DataSeedingService. / تتم معالجة البيانات الأولية عبر DataSeedingService.
    }
}
