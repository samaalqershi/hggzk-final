using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the property-type entity mapping.
/// يهيئ ربط كيان نوع العقار بقاعدة البيانات.
/// </summary>
public class PropertyTypeConfiguration : IEntityTypeConfiguration<PropertyType>
{
    /// <summary>
    /// Applies the property-type mapping rules.
    /// يطبق قواعد ربط كيان نوع العقار.
    /// </summary>
    public void Configure(EntityTypeBuilder<PropertyType> builder)
    {
        // Set the table name. تعيين اسم الجدول.
        builder.ToTable("PropertyTypes");

        // Set the primary key. تعيين المفتاح الأساسي.
        builder.HasKey(pt => pt.Id);

        // Re-apply BaseEntity fields explicitly. إعادة تطبيق حقول BaseEntity بشكل صريح.
        builder.Property(b => b.Id).HasColumnName("TypeId").IsRequired();
        builder.Property(b => b.IsDeleted).HasDefaultValue(false);
        builder.Property(b => b.DeletedAt).HasColumnType("timestamp with time zone");
        
        // Configure the remaining scalar properties. تهيئة الخصائص البسيطة المتبقية.
        builder.Property(pt => pt.Name).IsRequired().HasMaxLength(50);
        builder.Property(pt => pt.Description).HasMaxLength(500);
        builder.Property(pt => pt.DefaultAmenities).HasColumnType("text");
        
        // Configure the unique index. تهيئة الفهرس الفريد.
        builder.HasIndex(pt => pt.Name).IsUnique();

        // Configure relationships. تهيئة العلاقات.
        builder.HasMany(pt => pt.Properties)
            .WithOne(p => p.PropertyType)
            .HasForeignKey(p => p.TypeId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(pt => pt.UnitTypes)
            .WithOne(ut => ut.PropertyType)
            .HasForeignKey(ut => ut.PropertyTypeId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(pt => pt.PropertyTypeAmenities)
            .WithOne(pta => pta.PropertyType)
            .HasForeignKey(pta => pta.PropertyTypeId)
            .OnDelete(DeleteBehavior.Cascade);

        // Seed data is handled by DataSeedingService to avoid duplicates in migrations.
        // تتم معالجة البيانات الأولية عبر DataSeedingService لتجنب التكرار في المهاجرات.

        // Apply the soft-delete filter. تطبيق مرشح الحذف الناعم.
        builder.HasQueryFilter(pt => !pt.IsDeleted);
    }
}
