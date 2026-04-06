using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the property nearby-place entity mapping.
/// يهيئ ربط كيان المكان القريب للعقار بقاعدة البيانات.
/// </summary>
public class PropertyNearbyPlaceConfiguration : IEntityTypeConfiguration<PropertyNearbyPlace>
{
    public void Configure(EntityTypeBuilder<PropertyNearbyPlace> builder)
    {
        builder.ToTable("PropertyNearbyPlaces");

        builder.HasKey(place => place.Id);

        builder.Property(place => place.Id).HasColumnName("NearbyPlaceId").IsRequired();
        builder.Property(place => place.IsDeleted).HasDefaultValue(false).IsRequired();
        builder.Property(place => place.DeletedAt).HasColumnType("timestamp with time zone");
        builder.Property(place => place.CreatedAt).HasColumnType("timestamp with time zone").IsRequired();
        builder.Property(place => place.UpdatedAt).HasColumnType("timestamp with time zone").IsRequired();

        builder.Property(place => place.PropertyId).IsRequired();
        builder.Property(place => place.Name).IsRequired().HasMaxLength(200);
        builder.Property(place => place.NameEn).HasMaxLength(200);
        builder.Property(place => place.Description).HasMaxLength(1000);
        builder.Property(place => place.DescriptionEn).HasMaxLength(1000);
        builder.Property(place => place.Category).IsRequired().HasMaxLength(100);
        builder.Property(place => place.Icon).IsRequired().HasMaxLength(100);
        builder.Property(place => place.Latitude).HasPrecision(10, 7);
        builder.Property(place => place.Longitude).HasPrecision(10, 7);
        builder.Property(place => place.DistanceInMeters).IsRequired();
        builder.Property(place => place.DisplayOrder).HasDefaultValue(0);

        builder.HasIndex(place => place.PropertyId)
            .HasDatabaseName("IX_PropertyNearbyPlaces_PropertyId");

        builder.HasIndex(place => new { place.PropertyId, place.DisplayOrder })
            .HasDatabaseName("IX_PropertyNearbyPlaces_PropertyId_DisplayOrder");

        builder.HasOne(place => place.Property)
            .WithMany(property => property.NearbyPlaces)
            .HasForeignKey(place => place.PropertyId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasQueryFilter(place => !place.IsDeleted);
    }
}
