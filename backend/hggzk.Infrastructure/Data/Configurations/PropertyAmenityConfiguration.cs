using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the property-amenity entity mapping.
/// يهيئ ربط كيان مرفق العقار بقاعدة البيانات.
/// </summary>
public class PropertyAmenityConfiguration : IEntityTypeConfiguration<PropertyAmenity>
{
    /// <summary>
    /// Applies the property-amenity mapping rules.
    /// يطبق قواعد ربط كيان مرفق العقار.
    /// </summary>
    public void Configure(EntityTypeBuilder<PropertyAmenity> builder)
    {
        builder.ToTable("PropertyAmenities");

        builder.HasKey(pa => pa.Id);

        builder.Property(b => b.Id).HasColumnName("PaId").IsRequired();
        builder.Property(b => b.IsDeleted).HasDefaultValue(false);
        builder.Property(b => b.DeletedAt).HasColumnType("timestamp with time zone");

        builder.Property(pa => pa.PropertyId)
            .IsRequired()
            .HasComment("معرف الكيان");

        builder.Property(pa => pa.PtaId)
            .IsRequired()
            .HasComment("معرف مرفق نوع الكيان");

        builder.Property(pa => pa.IsAvailable)
            .IsRequired()
            .HasDefaultValue(true)
            .HasComment("هل المرفق متاح");

        // Do not duplicate the ExtraCost mapping. عدم تكرار تهيئة الخاصية ExtraCost.

        // Configure the embedded money value object. تهيئة الكائن القيمي المالي المضمن.
        builder.OwnsOne(pa => pa.ExtraCost, moneyBuilder =>
        {
            moneyBuilder.Property(m => m.Amount)
                .HasPrecision(18, 2)
                .HasColumnName("ExtraCost_Amount")
                .HasComment("مبلغ التكلفة الإضافية");

            moneyBuilder.Property(m => m.Currency)
                .HasMaxLength(10)
                .HasColumnName("ExtraCost_Currency")
                .HasComment("عملة التكلفة الإضافية");
                
            moneyBuilder.Property(m => m.ExchangeRate)
                .HasPrecision(18, 6)
                .HasDefaultValue(1.0m)
                .HasColumnName("ExtraCost_ExchangeRate")
                .HasComment("سعر الصرف");
        });

        // Configure indexes. تهيئة الفهارس.
        builder.HasIndex(pa => pa.PropertyId)
            .HasDatabaseName("IX_PropertyAmenities_PropertyId");

        builder.HasIndex(pa => pa.PtaId)
            .HasDatabaseName("IX_PropertyAmenities_PtaId");

        builder.HasIndex(pa => new { pa.PropertyId, pa.PtaId })
            .IsUnique()
            .HasDatabaseName("IX_PropertyAmenities_PropertyId_PtaId");

        builder.HasIndex(pa => pa.IsDeleted)
            .HasDatabaseName("IX_PropertyAmenities_IsDeleted");

        // Configure relationships. تهيئة العلاقات.
        builder.HasOne(pa => pa.Property)
            .WithMany(p => p.Amenities)
            .HasForeignKey(pa => pa.PropertyId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(pa => pa.PropertyTypeAmenity)
            .WithMany(pta => pta.PropertyAmenities)
            .HasForeignKey(pa => pa.PtaId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasQueryFilter(pa => !pa.IsDeleted);
    }
}
