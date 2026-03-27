namespace YemenBooking.Infrastructure.Data.Configurations;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

/// <summary>
/// Configures the DailyUnitSchedule entity mapping.
/// يهيئ ربط كيان جدول الوحدة اليومي بقاعدة البيانات. / Configures the DailyUnitSchedule entity mapping.
/// </summary>
public class DailyUnitScheduleConfiguration : IEntityTypeConfiguration<DailyUnitSchedule>
{
    /// <summary>
    /// Applies the DailyUnitSchedule mapping rules.
    /// يطبق قواعد ربط كيان جدول الوحدة اليومي. / Applies the DailyUnitSchedule mapping rules.
    /// </summary>
    public void Configure(EntityTypeBuilder<DailyUnitSchedule> builder)
    {
        // Set the table name. / تعيين اسم الجدول.
        builder.ToTable("DailyUnitSchedules");

        // Set the primary key. / تعيين المفتاح الأساسي.
        builder.HasKey(d => d.Id);

        // Configure required properties. / تهيئة الخصائص المطلوبة.
        builder.Property(d => d.UnitId)
            .IsRequired();

        builder.Property(d => d.Date)
            .IsRequired()
            .HasColumnType("date"); // Store the date only, without time. / تخزين التاريخ فقط بدون وقت.

        builder.Property(d => d.Status)
            .IsRequired()
            .HasMaxLength(50)
            .HasDefaultValue("Available");

        // Configure optional properties. / تهيئة الخصائص الاختيارية.
        builder.Property(d => d.Reason)
            .HasMaxLength(200);

        builder.Property(d => d.Notes)
            .HasMaxLength(1000);

        builder.Property(d => d.PriceAmount)
            .HasColumnType("decimal(18,2)");

        builder.Property(d => d.Currency)
            .HasMaxLength(3); // ISO 4217 currency code. / رمز العملة وفق ISO 4217.

        builder.Property(d => d.PriceType)
            .HasMaxLength(50);

        builder.Property(d => d.PricingTier)
            .HasMaxLength(50);

        builder.Property(d => d.PercentageChange)
            .HasColumnType("decimal(5,2)");

        builder.Property(d => d.MinPrice)
            .HasColumnType("decimal(18,2)");

        builder.Property(d => d.MaxPrice)
            .HasColumnType("decimal(18,2)");

        builder.Property(d => d.CreatedBy)
            .HasMaxLength(100);

        builder.Property(d => d.ModifiedBy)
            .HasMaxLength(100);

        // Configure relationships. / تهيئة العلاقات.
        
        // Relationship with Unit. / علاقة مع الوحدة.
        builder.HasOne(d => d.Unit)
            .WithMany(u => u.DailySchedules)
            .HasForeignKey(d => d.UnitId)
            .OnDelete(DeleteBehavior.Cascade);

        // Relationship with Booking. / علاقة مع الحجز.
        builder.HasOne(d => d.Booking)
            .WithMany()
            .HasForeignKey(d => d.BookingId)
            .OnDelete(DeleteBehavior.SetNull);

        // Relationship with Currency. / علاقة مع العملة.
        builder.HasOne(d => d.CurrencyRef)
            .WithMany()
            .HasForeignKey(d => d.Currency)
            .HasPrincipalKey(c => c.Code)
            .OnDelete(DeleteBehavior.NoAction);

        // Configure indexes. / تهيئة الفهارس.
        
        // Unique composite index: unit + date. / فهرس مركب فريد: وحدة + تاريخ.
        builder.HasIndex(d => new { d.UnitId, d.Date })
            .IsUnique()
            .HasDatabaseName("IX_DailyUnitSchedules_UnitId_Date");

        // Index for searching by date. / فهرس للبحث بالتاريخ.
        builder.HasIndex(d => d.Date)
            .HasDatabaseName("IX_DailyUnitSchedules_Date");

        // Index for searching by status. / فهرس للبحث بالحالة.
        builder.HasIndex(d => d.Status)
            .HasDatabaseName("IX_DailyUnitSchedules_Status");

        // Index for searching by booking. / فهرس للبحث بالحجز.
        builder.HasIndex(d => d.BookingId)
            .HasDatabaseName("IX_DailyUnitSchedules_BookingId");

        // Composite index for efficient searching: unit + date + status. / فهرس مركب للبحث الفعال: وحدة + تاريخ + حالة.
        builder.HasIndex(d => new { d.UnitId, d.Date, d.Status })
            .HasDatabaseName("IX_DailyUnitSchedules_UnitId_Date_Status");

        // Index for prices, used by analytical queries. / فهرس للأسعار للاستعلامات التحليلية.
        builder.HasIndex(d => new { d.UnitId, d.PriceAmount })
            .HasDatabaseName("IX_DailyUnitSchedules_UnitId_PriceAmount")
            .HasFilter("\"PriceAmount\" IS NOT NULL");
        
        // Advanced indexes for fast search and filtering. / فهارس متقدمة للبحث والفلترة السريعة.
        
        // Covering index for availability and pricing lookups. / فهرس تغطية للاستعلامات الخاصة بالإتاحة والتسعير.
        // Enables index-only scans without hitting the base table. / يسمح باستعلامات تعتمد على الفهرس فقط دون الرجوع للجدول الأصلي.
        builder.HasIndex(d => new { d.UnitId, d.Date, d.Status, d.PriceAmount, d.Currency })
            .HasDatabaseName("IX_DailyUnitSchedules_Covering")
            .HasFilter("\"PriceAmount\" IS NOT NULL");
        
        // Composite index for queries that start with date filtering. / فهرس مركب للاستعلامات التي تبدأ بتصفية التاريخ.
        builder.HasIndex(d => new { d.Date, d.Status, d.UnitId })
            .HasDatabaseName("IX_DailyUnitSchedules_Date_Status_UnitId");
        
        // Index for currency and price filtering. / فهرس للعملة والسعر.
        builder.HasIndex(d => new { d.Currency, d.PriceAmount })
            .HasDatabaseName("IX_DailyUnitSchedules_Currency_Price")
            .HasFilter("\"PriceAmount\" IS NOT NULL AND \"Currency\" IS NOT NULL");

        // Inherited BaseEntity properties. / خصائص BaseEntity الموروثة.
        builder.Property(d => d.CreatedAt)
            .IsRequired()
            .HasDefaultValueSql("NOW()");

        builder.Property(d => d.UpdatedAt)
            .IsRequired()
            .HasDefaultValueSql("NOW()");

        // Global query filter. / مرشح استعلام عام.
        builder.HasQueryFilter(d => !d.IsDeleted);
    }
}
