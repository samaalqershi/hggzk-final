using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the property entity mapping.
/// يهيئ ربط كيان العقار بقاعدة البيانات.
/// </summary>
public class PropertyConfiguration : IEntityTypeConfiguration<Property>
{
    /// <summary>
    /// Applies the property mapping rules.
    /// يطبق قواعد ربط كيان العقار.
    /// </summary>
    public void Configure(EntityTypeBuilder<Property> builder)
    {
        // Set the table name. تعيين اسم الجدول.
        builder.ToTable("Properties");

        // Set the primary key. تعيين المفتاح الأساسي.
        builder.HasKey(p => p.Id);

        // Re-apply BaseEntity fields explicitly. إعادة تطبيق حقول BaseEntity بشكل صريح.
        builder.Property(b => b.Id).HasColumnName("PropertyId").IsRequired();
        builder.Property(b => b.IsDeleted).HasDefaultValue(false);
        builder.Property(b => b.DeletedAt).HasColumnType("timestamp with time zone");
        
        // Configure the remaining scalar properties. تهيئة الخصائص البسيطة المتبقية.
        builder.Property(p => p.OwnerId).IsRequired();
        builder.Property(p => p.TypeId).IsRequired();
        builder.Property(p => p.Name).IsRequired().HasMaxLength(100);
        builder.Property(p => p.Address).IsRequired().HasMaxLength(500);
        builder.Property(p => p.City).IsRequired().HasMaxLength(100); // Match City.Name length. مطابق لطول City.Name.
        builder.Property(p => p.Latitude).HasColumnType("decimal(9,6)");
        builder.Property(p => p.Longitude).HasColumnType("decimal(9,6)");
        builder.Property(p => p.StarRating).HasDefaultValue(0);
        builder.Property(p => p.Description).HasColumnType("text");
        builder.Property(p => p.IsApproved).HasDefaultValue(false);
        builder.Property(p => p.CreatedAt).HasColumnType("timestamp with time zone").IsRequired();
        builder.Property(p => p.BookingCount).HasDefaultValue(0);
        builder.Property(p => p.AverageRating).HasColumnType("decimal(5,2)").HasDefaultValue(0);
        builder.Property(p => p.IsIndexed).HasDefaultValue(false);
        builder.Property(p => p.SystemCommissionRate)
            .HasPrecision(5, 2)
            .HasColumnType("decimal(5,2)")
            .HasComment("نسبة عمولة المنصة المخصصة للعقار (0-100)");
        
        // Configure entity relationships. تهيئة العلاقات بين الكيانات.
        builder.HasOne(p => p.Owner)
               .WithMany(o => o.Properties)
               .HasForeignKey(p => p.OwnerId);
        
        builder.HasOne(p => p.PropertyType)
               .WithMany(pt => pt.Properties)
               .HasForeignKey(p => p.TypeId);
        
        builder.HasMany(p => p.Units)
               .WithOne(u => u.Property)
               .HasForeignKey(u => u.PropertyId);
        
        builder.HasMany(p => p.Services)
               .WithOne(s => s.Property)
               .HasForeignKey(s => s.PropertyId);
        
        builder.HasMany(p => p.Policies)
               .WithOne(po => po.Property)
               .HasForeignKey(po => po.PropertyId);
        
        // Map reviews via PropertyId. ربط المراجعات عبر PropertyId.
        builder.HasMany(p => p.Reviews)
               .WithOne(r => r.Property)
               .HasForeignKey(r => r.PropertyId)
               .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasMany(p => p.Staff)
               .WithOne(s => s.Property)
               .HasForeignKey(s => s.PropertyId);
        
        builder.HasMany(p => p.Images)
               .WithOne(i => i.Property)
               .HasForeignKey(i => i.PropertyId);
        
        builder.HasMany(p => p.Amenities)
               .WithOne(pa => pa.Property)
               .HasForeignKey(pa => pa.PropertyId);
        
        // Reports linked to this property. البلاغات المرتبطة بهذا العقار.
        builder.HasMany(p => p.Reports)
               .WithOne(r => r.ReportedProperty)
               .HasForeignKey(r => r.ReportedPropertyId)
               .OnDelete(DeleteBehavior.SetNull);
        
        // Configure indexes. تهيئة الفهارس.
        builder.HasIndex(p => new { p.Name, p.City });

        // Map the currency string foreign key to Currency by Code.
        // ربط مفتاح العملة النصي بكيان Currency عبر Code.
        builder.Property(p => p.Currency)
               .HasMaxLength(10)
               .IsRequired();
        builder.HasOne<Currency>()
               .WithMany(c => c.Properties)
               .HasForeignKey(p => p.Currency)
               .HasPrincipalKey(c => c.Code)
               .OnDelete(DeleteBehavior.Restrict);

        // Map the optional city navigation using the city name key.
        // ربط التنقل الاختياري للمدينة باستخدام اسم المدينة.
        builder.HasOne(p => p.CityRef)
               .WithMany(c => c.Properties)
               .HasForeignKey(p => p.City)
               .HasPrincipalKey(c => c.Name)
               .OnDelete(DeleteBehavior.Restrict);
    }
}
