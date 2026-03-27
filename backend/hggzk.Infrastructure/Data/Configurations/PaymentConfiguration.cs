using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Core.ValueObjects;
using Npgsql.EntityFrameworkCore.PostgreSQL;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the payment entity mapping.
/// يهيئ ربط كيان الدفع بقاعدة البيانات.
/// </summary>
public class PaymentConfiguration : IEntityTypeConfiguration<Payment>
{
    /// <summary>
    /// Applies the payment mapping rules.
    /// يطبق قواعد ربط كيان الدفع.
    /// </summary>
    public void Configure(EntityTypeBuilder<Payment> builder)
    {
        builder.ToTable("Payments");

        builder.HasKey(p => p.Id);

        builder.Property(p => p.Id)
            .IsRequired()
            .HasComment("معرف الدفع الفريد");

        builder.Property(p => p.BookingId)
            .IsRequired()
            .HasComment("معرف الحجز");

        // Configure the embedded money value object. تهيئة الكائن القيمي المالي المضمن.
        builder.OwnsOne(p => p.Amount, moneyBuilder =>
        {
            moneyBuilder.Property(m => m.Amount)
                .HasPrecision(18, 2)
                .HasColumnName("Amount_Amount")
                .HasComment("مبلغ الدفع");

            moneyBuilder.Property(m => m.Currency)
                .HasMaxLength(10)
                .HasColumnName("Amount_Currency")
                .HasComment("عملة الدفع");
                
            moneyBuilder.Property(m => m.ExchangeRate)
                .HasPrecision(18, 6)
                .HasDefaultValue(1.0m)
                .HasColumnName("Amount_ExchangeRate")
                .HasComment("سعر الصرف");
            
            // Indexes on owned properties. فهارس على الخصائص المملوكة.
            moneyBuilder.HasIndex(m => m.Amount)
                .HasDatabaseName("IX_Payments_Amount_Amount");
        });

        // Link payment currency through a shadow foreign key. ربط عملة الدفع عبر مفتاح علاقة مخفي.
        builder.HasOne<Currency>()
            .WithMany()
            .HasForeignKey("Amount_Currency")
            .HasPrincipalKey(c => c.Code)
            .OnDelete(DeleteBehavior.Restrict);

        // Configure enum storage. تهيئة تخزين القيمة enum.
        builder.Property(p => p.PaymentMethod)
            .IsRequired()
            .HasConversion<int>()
            .HasComment("طريقة الدفع");

        builder.Property(p => p.TransactionId)
            .HasMaxLength(100)
            .HasComment("معرف المعاملة");

        builder.Property(p => p.Status)
            .IsRequired()
            .HasMaxLength(50)
            .HasComment("حالة الدفع");

        builder.Property(p => p.PaymentDate)
            .IsRequired()
            .HasColumnType("timestamp with time zone")
            .HasComment("تاريخ الدفع");

        builder.Property(p => p.IsDeleted)
            .IsRequired()
            .HasDefaultValue(false)
            .HasComment("حالة الحذف الناعم");

        builder.Property(p => p.DeletedAt)
            .HasComment("تاريخ الحذف");

        // Configure indexes. تهيئة الفهارس.
        builder.HasIndex(p => p.BookingId)
            .HasDatabaseName("IX_Payments_BookingId");

        // Unique TransactionId index excluding NULL and empty values.
        // فهرس فريد على TransactionId مع استبعاد NULL والقيم الفارغة.
        builder.HasIndex(p => p.TransactionId)
            .IsUnique()
            .HasFilter("\"TransactionId\" IS NOT NULL AND \"TransactionId\" <> ''")
            .HasDatabaseName("IX_Payments_TransactionId");

        builder.HasIndex(p => p.Status)
            .HasDatabaseName("IX_Payments_Status");

        builder.HasIndex(p => p.IsDeleted)
            .HasDatabaseName("IX_Payments_IsDeleted");
        
        builder.HasIndex(p => p.PaymentDate)
            .HasDatabaseName("IX_Payments_PaymentDate");

        builder.HasIndex(p => new { p.Status, p.PaymentDate })
            .HasDatabaseName("IX_Payments_Status_PaymentDate");

        builder.HasIndex(p => new { p.PaymentMethod, p.PaymentDate })
            .HasDatabaseName("IX_Payments_Method_PaymentDate");

        builder.HasIndex(p => new { p.BookingId, p.PaymentDate })
            .HasDatabaseName("IX_Payments_Booking_PaymentDate");

        // Configure relationships. تهيئة العلاقات.
        builder.HasOne(p => p.Booking)
            .WithMany(b => b.Payments)
            .HasForeignKey(p => p.BookingId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasQueryFilter(p => !p.IsDeleted);

        // Re-apply BaseEntity fields explicitly. إعادة تطبيق حقول BaseEntity بشكل صريح.
        builder.Property(b => b.Id).HasColumnName("PaymentId").IsRequired();
        builder.Property(b => b.IsDeleted).HasDefaultValue(false);
        builder.Property(b => b.DeletedAt).HasColumnType("timestamp with time zone");
    }
}
