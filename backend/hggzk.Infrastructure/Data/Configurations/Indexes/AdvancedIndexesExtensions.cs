using Microsoft.EntityFrameworkCore;
using Npgsql.EntityFrameworkCore.PostgreSQL.Infrastructure;

namespace YemenBooking.Infrastructure.Data.Configurations.Indexes;

/// <summary>
/// Extensions for advanced indexes that EF Core Fluent API does not cover.
/// امتدادات لإضافة الفهارس المتقدمة التي لا يدعمها EF Core Fluent API.
/// </summary>
public static class AdvancedIndexesExtensions
{
    /// <summary>
    /// Adds all advanced indexes for performance.
    /// تضيف جميع الفهارس المتقدمة لتحسين الأداء.
    /// </summary>
    public static void ConfigureAdvancedIndexes(this ModelBuilder modelBuilder)
    {
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 1. Advanced Units indexes.
        // 1. فهارس Units المتقدمة.
        // ⚠️ All indexes depending on IsAvailable were removed.
        // ⚠️ تم إزالة جميع الفهارس المعتمدة على IsAvailable.
        // Reason: availability search relies on UnitAvailabilities only.
        // السبب: البحث يعتمد على UnitAvailabilities فقط، وليس على IsAvailable.
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        // Note: indexes containing BasePrice_Amount are created in UnitIndexConfiguration.
        // ملاحظة: الفهارس التي تحتوي على BasePrice_Amount يتم إنشاؤها في UnitIndexConfiguration.
        // They use OwnsOne() for type-safe indexes.
        // باستخدام OwnsOne() للحصول على Type-Safe indexes.
        
        // Comprehensive composite index without IsAvailable.
        // فهرس مركب شامل بدون IsAvailable.
        modelBuilder.Entity<Core.Entities.Unit>()
            .HasIndex("UnitTypeId", "PropertyId", "MaxCapacity")
            .HasDatabaseName("IX_Units_Composite_Advanced");
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 2. Advanced Properties indexes.
        // 2. فهارس Properties المتقدمة.
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        // Comprehensive composite index.
        // فهرس مركب شامل.
        modelBuilder.Entity<Core.Entities.Property>()
            .HasIndex("City", "TypeId", "IsApproved", "AverageRating", "StarRating")
            .HasDatabaseName("IX_Properties_Composite_Main");
        
        // Partial index on approved properties only.
        // فهرس جزئي على العقارات المعتمدة فقط.
        modelBuilder.Entity<Core.Entities.Property>()
            .HasIndex("AverageRating")
            .HasDatabaseName("IX_Properties_AverageRating_Approved")
            .HasFilter("\"IsApproved\" = true")
            .IsDescending();
        
        // Partial index on featured properties only.
        // فهرس جزئي على العقارات المميزة فقط.
        modelBuilder.Entity<Core.Entities.Property>()
            .HasIndex("IsFeatured", "AverageRating", "StarRating")
            .HasDatabaseName("IX_Properties_Featured")
            .HasFilter("\"IsFeatured\" = true AND \"IsApproved\" = true")
            .IsDescending();
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 3. Advanced DailyUnitSchedule indexes.
        // 3. فهارس DailyUnitSchedule المتقدمة (الكيان الموحد الجديد).
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        // Partial index on blocked or booked days only.
        // فهرس جزئي على الأيام المحجوزة أو المحظورة فقط.
        modelBuilder.Entity<Core.Entities.DailyUnitSchedule>()
            .HasIndex("UnitId", "Date", "Status")
            .HasDatabaseName("IX_DailyUnitSchedules_Unavailable")
            .HasFilter("\"Status\" != 'Available'");
        
        // Partial index on available days with prices.
        // فهرس جزئي على الأيام المتاحة مع الأسعار.
        modelBuilder.Entity<Core.Entities.DailyUnitSchedule>()
            .HasIndex("Date", "PriceAmount", "Currency")
            .HasDatabaseName("IX_DailyUnitSchedules_Available_Price")
            .HasFilter("\"Status\" = 'Available' AND \"PriceAmount\" IS NOT NULL");
        
        // Composite index for fast date-range lookup.
        // فهرس مركب للبحث السريع في نطاقات التاريخ.
        // Used by queries that search for units available in a time window.
        // يُستخدم في الاستعلامات التي تبحث عن الوحدات المتاحة في فترة معينة.
        modelBuilder.Entity<Core.Entities.DailyUnitSchedule>()
            .HasIndex("Date", "UnitId")
            .HasDatabaseName("IX_DailyUnitSchedules_Date_UnitId")
            .IsDescending(true, false);
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 4. PropertyImages indexes.
        // 4. فهارس PropertyImages.
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        // Index on PropertyId + DisplayOrder.
        // فهرس على PropertyId + DisplayOrder.
        modelBuilder.Entity<Core.Entities.PropertyImage>()
            .HasIndex("PropertyId", "DisplayOrder")
            .HasDatabaseName("IX_PropertyImages_PropertyId_DisplayOrder");
        
        // Partial index on unit images only.
        // فهرس جزئي على صور الوحدات فقط.
        modelBuilder.Entity<Core.Entities.PropertyImage>()
            .HasIndex("UnitId", "DisplayOrder")
            .HasDatabaseName("IX_PropertyImages_UnitId_DisplayOrder")
            .HasFilter("\"UnitId\" IS NOT NULL");
    }
    
    /// <summary>
    /// Adds advanced PostgreSQL-only indexes.
    /// تضيف الفهارس المتقدمة الخاصة بـ PostgreSQL.
    /// </summary>
    public static void ConfigurePostgreSQLSpecificIndexes(this ModelBuilder modelBuilder)
    {
        // Note: these indexes require Raw SQL.
        // ملاحظة: هذه الفهارس تحتاج تنفيذ عبر Raw SQL.
        // They are added in OnModelCreating using the relational API.
        // سيتم إضافتها في OnModelCreating باستخدام relational API.
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 1. Full-text search indexes (GIN).
        // 1. فهارس البحث النصي الكامل (GIN).
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        // Units - full-text on Name.
        // Units - بحث نصي على Name.
        modelBuilder.Entity<Core.Entities.Unit>()
            .HasIndex("Name")
            .HasDatabaseName("IX_Units_Name_FTS")
            .HasMethod("gin")
            .HasOperators("gin_trgm_ops");
        
        // Properties - full-text on Name, Description, Address.
        // Properties - بحث نصي على Name و Description و Address.
        // Note: EF Core does not support expression indexes here; use Raw SQL.
        // ملاحظة: EF Core لا يدعم expression indexes هنا ويجب استخدام Raw SQL.
        
        // UnitFieldValues - full-text on Value.
        // UnitFieldValues - بحث نصي على Value.
        modelBuilder.Entity<Core.Entities.UnitFieldValue>()
            .HasIndex("Value")
            .HasDatabaseName("IX_UnitFieldValues_Value_FTS")
            .HasMethod("gin")
            .HasOperators("gin_trgm_ops");
        
        // UnitTypes - full-text on Name.
        // UnitTypes - بحث نصي على Name.
        modelBuilder.Entity<Core.Entities.UnitType>()
            .HasIndex("Name")
            .HasDatabaseName("IX_UnitTypes_Name_FTS")
            .HasMethod("gin")
            .HasOperators("gin_trgm_ops");
    }
}
