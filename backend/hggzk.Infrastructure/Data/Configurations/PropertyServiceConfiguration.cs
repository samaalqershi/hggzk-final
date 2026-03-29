using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the property-service entity mapping.
/// يهيئ ربط كيان خدمة العقار بقاعدة البيانات.
/// </summary>
public class PropertyServiceConfiguration : IEntityTypeConfiguration<PropertyService>
{
    /// <summary>
    /// Applies the property-service mapping rules.
    /// يطبق قواعد ربط كيان خدمة العقار.
    /// </summary>
    public void Configure(EntityTypeBuilder<PropertyService> builder)
    {
        builder.ToTable("PropertyServices");

        builder.HasKey(ps => ps.Id);

        builder.Property(ps => ps.Id)
            .IsRequired()
            .HasComment("معرف الخدمة الفريد");

        builder.Property(ps => ps.PropertyId)
            .IsRequired()
            .HasComment("معرف الكيان");

        builder.Property(ps => ps.Name)
            .IsRequired()
            .HasMaxLength(200)
            .HasComment("اسم الخدمة");

        builder.Property(ps => ps.NameEn)
            .HasMaxLength(200)
            .HasComment("اسم الخدمة بالإنجليزية");

        builder.Property(ps => ps.Description)
            .HasMaxLength(1000)
            .IsRequired(false)
            .HasComment("وصف الخدمة");

        builder.Property(ps => ps.DescriptionEn)
            .HasMaxLength(1000)
            .IsRequired(false)
            .HasComment("وصف الخدمة بالإنجليزية");

        // Configure the embedded money value object. تهيئة الكائن القيمي المالي المضمن.
        builder.OwnsOne(ps => ps.Price, moneyBuilder =>
        {
            moneyBuilder.Property(m => m.Amount)
                .HasPrecision(18, 2)
                .HasColumnName("Price_Amount")
                .HasComment("مبلغ سعر الخدمة");

            moneyBuilder.Property(m => m.Currency)
                .HasMaxLength(10)
                .HasColumnName("Price_Currency")
                .HasComment("عملة سعر الخدمة");
                
            moneyBuilder.Property(m => m.ExchangeRate)
                .HasPrecision(18, 6)
                .HasDefaultValue(1.0m)
                .HasColumnName("Price_ExchangeRate")
                .HasComment("سعر الصرف");
        });

        builder.Property(ps => ps.PricingModel)
            .IsRequired()
            .HasComment("نموذج التسعير");

        // Re-apply BaseEntity fields explicitly. إعادة تطبيق حقول BaseEntity بشكل صريح.
        builder.Property(ps => ps.Id).HasColumnName("ServiceId").IsRequired();
        builder.Property(ps => ps.IsDeleted).HasDefaultValue(false);
        builder.Property(ps => ps.DeletedAt).HasColumnType("timestamp with time zone");
        builder.Property(ps => ps.CreatedAt).HasColumnType("timestamp with time zone").IsRequired();
        builder.Property(ps => ps.UpdatedAt).HasColumnType("timestamp with time zone").IsRequired();

        // Configure indexes. تهيئة الفهارس.
        builder.HasIndex(ps => ps.PropertyId)
            .HasDatabaseName("IX_PropertyServices_PropertyId");

        builder.HasIndex(ps => ps.Name)
            .HasDatabaseName("IX_PropertyServices_Name");

        builder.HasIndex(ps => ps.NameEn)
            .HasDatabaseName("IX_PropertyServices_NameEn");

        builder.HasIndex(ps => ps.IsDeleted)
            .HasDatabaseName("IX_PropertyServices_IsDeleted");

        // Configure relationships. تهيئة العلاقات.
        builder.HasOne(ps => ps.Property)
            .WithMany(p => p.Services)
            .HasForeignKey(ps => ps.PropertyId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(ps => ps.BookingServices)
            .WithOne(bs => bs.Service)
            .HasForeignKey(bs => bs.ServiceId)
            .OnDelete(DeleteBehavior.Restrict);

        // Apply the query filter. تطبيق مرشح الاستعلام.
        builder.HasQueryFilter(ps => !ps.IsDeleted);
    }
}
