using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;
using Npgsql.EntityFrameworkCore.PostgreSQL;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the Booking entity mapping.
/// يهيئ ربط كيان الحجز بقاعدة البيانات. / Configures the Booking entity mapping.
/// </summary>
public class BookingConfiguration : IEntityTypeConfiguration<Booking>
{
    /// <summary>
    /// Applies the Booking mapping rules.
    /// يطبق قواعد ربط كيان الحجز. / Applies the Booking mapping rules.
    /// </summary>
    public void Configure(EntityTypeBuilder<Booking> builder)
    {
        builder.ToTable("Bookings");

        builder.HasKey(b => b.Id);

        builder.Property(b => b.Id)
            .IsRequired()
            .HasComment("Unique booking identifier / معرف الحجز الفريد");

        builder.Property(b => b.UserId)
            .IsRequired()
            .HasComment("User identifier / معرف المستخدم");

        builder.Property(b => b.UnitId)
            .IsRequired()
            .HasComment("Unit identifier / معرف الوحدة");

        builder.Property(b => b.CheckIn)
            .IsRequired()
            .HasComment("Check-in date / تاريخ الوصول");

        builder.Property(b => b.CheckOut)
            .IsRequired()
            .HasComment("Check-out date / تاريخ المغادرة");

        builder.Property(b => b.GuestsCount)
            .IsRequired()
            .HasComment("Guest count / عدد الضيوف");

        // Configure the embedded money value object. / تهيئة الكائن القيمي الخاص بالمال.
        builder.OwnsOne(b => b.TotalPrice, moneyBuilder =>
        {
            moneyBuilder.Property(m => m.Amount)
                .HasPrecision(18, 2)
                .HasColumnName("TotalPrice_Amount")
                .HasComment("Total price amount / مبلغ السعر الإجمالي");

            moneyBuilder.Property(m => m.Currency)
                .HasMaxLength(10)
                .HasColumnName("TotalPrice_Currency")
                .HasComment("Total price currency / عملة السعر الإجمالي");
                
            moneyBuilder.Property(m => m.ExchangeRate)
                .HasPrecision(18, 6)
                .HasDefaultValue(1.0m)
                .HasColumnName("TotalPrice_ExchangeRate")
                .HasComment("Exchange rate / سعر الصرف");
        });

        // Link the booking currency to Currency by using a shadow foreign key column. / ربط عملة الحجز بكيان Currency عبر عمود علاقة مخفي.
        builder.HasOne<Currency>()
            .WithMany()
            .HasForeignKey("TotalPrice_Currency")
            .HasPrincipalKey(c => c.Code)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(b => b.Status)
            .IsRequired()
            .HasMaxLength(50)
            .HasComment("Booking status / حالة الحجز");

        builder.Property(b => b.BookedAt)
            .IsRequired()
            .HasDefaultValueSql("CURRENT_TIMESTAMP")
            .HasComment("Booking date / تاريخ الحجز");

        builder.Property(b => b.IsDeleted)
            .IsRequired()
            .HasDefaultValue(false)
            .HasComment("Soft-delete status / حالة الحذف الناعم");

        builder.Property(b => b.DeletedAt)
            .HasComment("Deletion date / تاريخ الحذف");

        // Map the booking policy snapshot metadata. / ربط بيانات لقطة السياسات الخاصة بالحجز.
        builder.Property(b => b.PolicySnapshot)
            .HasColumnType("text")
            .HasComment("Policy snapshot at booking creation (JSON) / لقطة السياسات وقت إنشاء الحجز (JSON)");
        builder.Property(b => b.PolicySnapshotAt)
            .HasColumnType("timestamp with time zone")
            .HasComment("Policy snapshot saved at / تاريخ حفظ لقطة السياسات");

        // Indexes. / الفهارس.
        builder.HasIndex(b => b.UserId)
            .HasDatabaseName("IX_Bookings_UserId");

        builder.HasIndex(b => b.UnitId)
            .HasDatabaseName("IX_Bookings_UnitId");

        builder.HasIndex(b => b.Status)
            .HasDatabaseName("IX_Bookings_Status");

        builder.HasIndex(b => new { b.CheckIn, b.CheckOut })
            .HasDatabaseName("IX_Bookings_CheckInOut");

        builder.HasIndex(b => b.IsDeleted)
            .HasDatabaseName("IX_Bookings_IsDeleted");

        builder.HasIndex(b => new { b.UserId, b.BookedAt });
        builder.HasIndex(b => new { b.UnitId, b.CheckIn, b.CheckOut });

        builder.HasIndex(b => b.BookedAt)
            .HasDatabaseName("IX_Bookings_BookedAt");

        builder.HasIndex(b => b.UnitId)
            .HasDatabaseName("IX_Bookings_Unit_Confirmed")
            .HasFilter("\"Status\" = 0");

        builder.HasIndex(b => new { b.UnitId, b.CheckIn, b.CheckOut })
            .HasDatabaseName("IX_Bookings_Unit_CheckIn_CheckOut_gist")
            .HasMethod("gist");

        // Define entity relationships. / تعريف العلاقات بين الكيانات.
        builder.HasOne(b => b.User)
            .WithMany(u => u.Bookings)
            .HasForeignKey(b => b.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(b => b.Unit)
            .WithMany(u => u.Bookings)
            .HasForeignKey(b => b.UnitId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(b => b.Payments)
            .WithOne(p => p.Booking)
            .HasForeignKey(p => p.BookingId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(b => b.BookingServices)
            .WithOne(bs => bs.Booking)
            .HasForeignKey(bs => bs.BookingId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(b => b.Reviews)
            .WithOne(r => r.Booking)
            .HasForeignKey(r => r.BookingId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasQueryFilter(b => !b.IsDeleted);

        // Re-apply BaseEntity fields explicitly for clarity in the database schema. / إعادة تطبيق حقول BaseEntity بشكل صريح لتوضيح مخطط قاعدة البيانات.
        builder.Property(b => b.Id).HasColumnName("BookingId").IsRequired();
        builder.Property(b => b.IsDeleted).HasDefaultValue(false);
        builder.Property(b => b.DeletedAt).HasColumnType("timestamp with time zone");

        // Re-apply the remaining scalar properties. / إعادة تطبيق الخصائص البسيطة المتبقية.
        builder.Property(b => b.UserId).IsRequired();
        builder.Property(b => b.UnitId).IsRequired();
        builder.Property(b => b.CheckIn).HasColumnType("timestamp with time zone").IsRequired();
        builder.Property(b => b.CheckOut).HasColumnType("timestamp with time zone").IsRequired();
        builder.Property(b => b.GuestsCount).IsRequired();
        builder.Property(b => b.Status).IsRequired();
        builder.Property(b => b.BookedAt).HasColumnType("timestamp with time zone").IsRequired();
    }
}
