using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the City entity mapping.
/// يهيئ ربط كيان المدينة بقاعدة البيانات. / Configures the City entity mapping.
/// </summary>
public class CityConfiguration : IEntityTypeConfiguration<City>
{
    /// <summary>
    /// Applies the City mapping rules.
    /// يطبق قواعد ربط كيان المدينة. / Applies the City mapping rules.
    /// </summary>
    public void Configure(EntityTypeBuilder<City> builder)
    {
        builder.ToTable("Cities");

        builder.HasKey(c => c.Name);
        builder.Property(c => c.Name)
               .HasMaxLength(100)
               .IsRequired();
        builder.Property(c => c.Country)
               .HasMaxLength(100)
               .IsRequired();
        builder.Property(c => c.ImagesJson)
               .HasColumnType("text")
               .HasDefaultValue("[]");

        // We avoid a direct FK because the table is shared, while preserving index length. / نتجنب FK مباشر لأن الجدول مشترك مع الحفاظ على طول مناسب للفهرس.
        builder.HasMany(c => c.Images)
               .WithOne(i => i.City)
               .HasForeignKey(i => i.CityName)
               .HasPrincipalKey(c => c.Name)
               .OnDelete(DeleteBehavior.SetNull);

        builder.HasIndex(c => new { c.Name, c.Country }).IsUnique();
    }
}
