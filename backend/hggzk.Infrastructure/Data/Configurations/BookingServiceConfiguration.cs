using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the BookingService entity mapping.
/// يهيئ ربط كيان خدمة الحجز بقاعدة البيانات. / Configures the BookingService entity mapping.
/// </summary>
public class BookingServiceConfiguration : IEntityTypeConfiguration<BookingService>
{
    /// <summary>
    /// Applies the BookingService mapping rules.
    /// يطبق قواعد ربط كيان خدمة الحجز. / Applies the BookingService mapping rules.
    /// </summary>
    public void Configure(EntityTypeBuilder<BookingService> builder)
    {
        builder.ToTable("BookingServices");

        // Re-apply BaseEntity fields explicitly for the schema. / إعادة تطبيق حقول BaseEntity بشكل صريح في المخطط.
        builder.Property(b => b.Id).HasColumnName("BookingServiceId").IsRequired();
        builder.Property(b => b.IsDeleted).HasDefaultValue(false);
        builder.Property(b => b.DeletedAt).HasColumnType("timestamp with time zone");
        
        // Configure the remaining scalar properties. / تهيئة الخصائص البسيطة المتبقية.
        builder.Property(bs => bs.BookingId).IsRequired();
        builder.Property(bs => bs.ServiceId).IsRequired();
        builder.Property(bs => bs.Quantity).IsRequired();
        // Do not duplicate the TotalPrice property mapping. / عدم تكرار تهيئة الخاصية TotalPrice.
        
        // Configure the composite primary key. / تهيئة المفتاح الأساسي المركب.
        builder.HasKey(bs => new { bs.BookingId, bs.ServiceId });

        builder.Property(bs => bs.BookingId)
            .IsRequired()
            .HasComment("Booking identifier / معرف الحجز");

        builder.Property(bs => bs.ServiceId)
            .IsRequired()
            .HasComment("Service identifier / معرف الخدمة");

        builder.Property(bs => bs.Quantity)
            .IsRequired()
            .HasComment("Quantity / الكمية");

        // Configure the embedded money value object. / تهيئة الكائن القيمي المالي المضمن.
        builder.OwnsOne(bs => bs.TotalPrice, moneyBuilder =>
        {
            moneyBuilder.Property(m => m.Amount)
                .HasPrecision(18, 2)
                .HasColumnName("TotalPrice_Amount")
                .HasComment("Total service price amount / مبلغ السعر الإجمالي للخدمة");

            moneyBuilder.Property(m => m.Currency)
                .HasMaxLength(10)
                .HasColumnName("TotalPrice_Currency")
                .HasComment("Total service price currency / عملة السعر الإجمالي للخدمة");
                
            moneyBuilder.Property(m => m.ExchangeRate)
                .HasPrecision(18, 6)
                .HasDefaultValue(1.0m)
                .HasColumnName("TotalPrice_ExchangeRate")
                .HasComment("Exchange rate / سعر الصرف");
        });

        // Configure indexes. / تهيئة الفهارس.
        builder.HasIndex(bs => bs.BookingId)
            .HasDatabaseName("IX_BookingServices_BookingId");

        builder.HasIndex(bs => bs.ServiceId)
            .HasDatabaseName("IX_BookingServices_ServiceId");

        builder.HasIndex(bs => bs.IsDeleted)
            .HasDatabaseName("IX_BookingServices_IsDeleted");

        // Configure relationships. / تهيئة العلاقات.
        builder.HasOne(bs => bs.Booking)
            .WithMany(b => b.BookingServices)
            .HasForeignKey(bs => bs.BookingId);

        builder.HasOne(bs => bs.Service)
            .WithMany(ps => ps.BookingServices)
            .HasForeignKey(bs => bs.ServiceId);

        builder.HasQueryFilter(bs => !bs.IsDeleted);
    }
}
