using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Data.Configurations.Indexes;

/// <summary>
/// PostgreSQL index initializer.
/// مُهيّئ فهارس PostgreSQL - يُنشئ جميع الفهارس المتقدمة تلقائياً.
/// Works independently from migrations.
/// يعمل بشكل مستقل عن Migrations.
///
/// Note: updated to match the real database shape.
/// ملاحظة: تم تحديثه ليتطابق مع البنية الحقيقية لقاعدة البيانات.
/// - DailyUnitSchedules instead of UnitAvailabilities and PricingRules.
/// - DailyUnitSchedules بدلاً من UnitAvailabilities و PricingRules.
/// - Units without BasePrice; pricing comes from DailyUnitSchedules.
/// - Units بدون BasePrice (التسعير من DailyUnitSchedules).
/// </summary>
public class PostgresIndexInitializer
{
    /// <summary>
    /// حقل _context.
    /// _context field.
    /// </summary>
    private readonly YemenBookingDbContext _context;
    /// <summary>
    /// حقل _logger.
    /// _logger field.
    /// </summary>
    private readonly ILogger<PostgresIndexInitializer> _logger;

    /// <summary>
    /// منشئ PostgresIndexInitializer.
    /// PostgresIndexInitializer constructor.
    /// </summary>
    public PostgresIndexInitializer(
        YemenBookingDbContext context,
        ILogger<PostgresIndexInitializer> logger)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Applies all advanced indexes.
    /// يطبق جميع الفهارس المتقدمة.
    /// </summary>
    public async Task ApplyIndexesAsync()
    {
        try
        {
            _logger.LogInformation("🔧 Starting advanced PostgreSQL index creation...");

            // 0. Enable PostgreSQL extensions.
            // 0. تفعيل امتدادات PostgreSQL.
            await EnablePostgresExtensionsAsync();

            // 1. Composite Indexes
            await CreateCompositeIndexesAsync();

            // 2. Partial Indexes
            await CreatePartialIndexesAsync();

            // 3. Full-Text Search Indexes (GIN)
            await CreateFullTextIndexesAsync();

            // 4. Geographic Indexes (GiST)
            await CreateGeographicIndexesAsync();

            // 5. Range Indexes (GiST) - للجداول اليومية
            await CreateRangeIndexesAsync();

            // 6. Covering Indexes (INCLUDE)
            await CreateCoveringIndexesAsync();

            // 7. Expression Indexes
            await CreateExpressionIndexesAsync();

            // 8. Additional optimized indexes for performance.
            // 8. فهارس محسنة إضافية لتحسين الأداء.
            await CreateOptimizedScheduleIndexesAsync();

            // 9. PostgreSQL statistics configuration.
            // 9. إعداد إحصائيات PostgreSQL.
            await ConfigureStatisticsAsync();

            // 10. Analyze tables.
            // 10. تحليل الجداول.
            await AnalyzeTablesAsync();

            _logger.LogInformation("✅ All indexes were created successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "❌ Error while creating indexes");
            throw;
        }
    }

    #region === Enable extensions / تفعيل الامتدادات ===

    /// <summary>
    /// دالة EnablePostgresExtensionsAsync.
    /// EnablePostgresExtensionsAsync method.
    /// </summary>
    private async Task EnablePostgresExtensionsAsync()
    {
        _logger.LogInformation("Enabling PostgreSQL extensions...");

        await _context.Database.ExecuteSqlRawAsync(
            "CREATE EXTENSION IF NOT EXISTS pg_trgm;");

        await _context.Database.ExecuteSqlRawAsync(
            "CREATE EXTENSION IF NOT EXISTS btree_gist;");

        _logger.LogInformation("✓ Extensions enabled");
    }

    #endregion

    #region === Composite Indexes / الفهارس المركبة ===

    /// <summary>
    /// دالة CreateCompositeIndexesAsync.
    /// CreateCompositeIndexesAsync method.
    /// </summary>
    private async Task CreateCompositeIndexesAsync()
    {
        _logger.LogInformation("Creating composite indexes...");

        // Units - Composite شامل (بدون BasePrice - يتم حسابه من DailyUnitSchedules)
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Units_Composite_Main"" 
            ON ""Units"" (""PropertyId"", ""UnitTypeId"", ""MaxCapacity"", ""PricingMethod"");
        ");

        // Properties - Composite شامل
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Properties_Composite_Main"" 
            ON ""Properties"" (""City"", ""TypeId"", ""IsApproved"", ""AverageRating"" DESC, ""StarRating"" DESC);
        ");

        // SearchLogs - تسريع استرجاع أحدث السجلات حسب نوع البحث
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_SearchLogs_SearchType_CreatedAt"" 
            ON ""SearchLogs"" (""SearchType"", ""CreatedAt"" DESC);
        ");

        // DailyUnitSchedules - فهرس مركب للبحث السريع
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_DailyUnitSchedules_Composite_Main"" 
            ON ""DailyUnitSchedules"" (""UnitId"", ""Date"", ""Status"");
        ");

        _logger.LogInformation("✓ Composite Indexes");
    }

    #endregion

    #region === Partial Indexes ===

    /// <summary>
    /// دالة CreatePartialIndexesAsync.
    /// CreatePartialIndexesAsync method.
    /// </summary>
    private async Task CreatePartialIndexesAsync()
    {
        _logger.LogInformation("إنشاء Partial Indexes...");

        // Properties - AverageRating للعقارات المعتمدة
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Properties_AverageRating_Approved"" 
            ON ""Properties"" (""AverageRating"" DESC) 
            WHERE ""IsApproved"" = true AND NOT ""IsDeleted"";
        ");

        // Properties - StarRating للعقارات المعتمدة
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Properties_StarRating_Approved"" 
            ON ""Properties"" (""StarRating"" DESC) 
            WHERE ""IsApproved"" = true AND NOT ""IsDeleted"";
        ");

        // Properties - العقارات المميزة
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Properties_Featured"" 
            ON ""Properties"" (""IsFeatured"", ""AverageRating"" DESC, ""StarRating"" DESC) 
            WHERE ""IsFeatured"" = true AND ""IsApproved"" = true AND NOT ""IsDeleted"";
        ");

        // DailyUnitSchedules - الجداول المحجوزة فقط (الأهم للأداء)
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_DailyUnitSchedules_Blocked"" 
            ON ""DailyUnitSchedules"" (""UnitId"", ""Date"") 
            WHERE ""Status"" != 'Available';
        ");

        // DailyUnitSchedules - الجداول المتاحة فقط
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_DailyUnitSchedules_Available"" 
            ON ""DailyUnitSchedules"" (""UnitId"", ""Date"") 
            WHERE ""Status"" = 'Available';
        ");

        // PropertyImages - صور الوحدات فقط
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_PropertyImages_UnitId_DisplayOrder"" 
            ON ""PropertyImages"" (""UnitId"", ""DisplayOrder"") 
            WHERE ""UnitId"" IS NOT NULL;
        ");

        // PropertyImages - الصور الرئيسية فقط
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_PropertyImages_Main"" 
            ON ""PropertyImages"" (""PropertyId"", ""UnitId"") 
            WHERE ""IsMain"" = true;
        ");

        // Units - الوحدات النشطة فقط
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Units_Active"" 
            ON ""Units"" (""PropertyId"", ""UnitTypeId"") 
            WHERE ""IsActive"" = true AND NOT ""IsDeleted"";
        ");

        _logger.LogInformation("✓ Partial Indexes");
    }

    #endregion

    #region === Full-Text Search Indexes ===

    /// <summary>
    /// دالة CreateFullTextIndexesAsync.
    /// CreateFullTextIndexesAsync method.
    /// </summary>
    private async Task CreateFullTextIndexesAsync()
    {
        _logger.LogInformation("إنشاء Full-Text Search Indexes (GIN)...");

        // Units - بحث نصي على Name
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Units_Name_GIN"" 
            ON ""Units"" USING gin(to_tsvector('english', ""Name""));
        ");

        // Properties - بحث نصي شامل
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Properties_Search_GIN"" 
            ON ""Properties"" 
            USING gin(
                to_tsvector('english', 
                    coalesce(""Name"", '') || ' ' || 
                    coalesce(""Description"", '') || ' ' || 
                    coalesce(""Address"", '') || ' ' || 
                    coalesce(""City"", '')
                )
            );
        ");

        // Properties - Trigram Indexes لدعم Autocomplete سريع ومرن
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Properties_Name_Trigram"" 
            ON ""Properties"" 
            USING gin(lower(""Name"") gin_trgm_ops);
        ");

        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Properties_City_Trigram"" 
            ON ""Properties"" 
            USING gin(lower(""City"") gin_trgm_ops);
        ");

        // UnitFieldValues - بحث نصي على FieldValue
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_UnitFieldValues_FieldValue_GIN"" 
            ON ""UnitFieldValues"" 
            USING gin(to_tsvector('english', ""FieldValue""));
        ");

        // UnitTypes - بحث نصي على Name
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_UnitTypes_Name_GIN"" 
            ON ""UnitTypes"" 
            USING gin(to_tsvector('english', ""Name""));
        ");

        _logger.LogInformation("✓ Full-Text Indexes");
    }

    #endregion

    #region === Geographic Indexes ===

    /// <summary>
    /// دالة CreateGeographicIndexesAsync.
    /// CreateGeographicIndexesAsync method.
    /// </summary>
    private async Task CreateGeographicIndexesAsync()
    {
        _logger.LogInformation("إنشاء Geographic Indexes (GiST)...");

        // Properties - فهرس جغرافي
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Properties_Location_GiST"" 
            ON ""Properties"" 
            USING gist (point(CAST(""Longitude"" AS float8), CAST(""Latitude"" AS float8)));
        ");

        _logger.LogInformation("✓ Geographic Indexes");
    }

    #endregion

    #region === Range Indexes ===

    /// <summary>
    /// دالة CreateRangeIndexesAsync.
    /// CreateRangeIndexesAsync method.
    /// </summary>
    private async Task CreateRangeIndexesAsync()
    {
        _logger.LogInformation("إنشاء Range Indexes (GiST)...");

        // DailyUnitSchedules - فهرس التواريخ للبحث السريع عن الفترات
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_DailyUnitSchedules_DateRange"" 
            ON ""DailyUnitSchedules"" (""UnitId"", ""Date"");
        ");

        _logger.LogInformation("✓ Range Indexes");
    }

    #endregion

    #region === Covering Indexes ===

    /// <summary>
    /// دالة CreateCoveringIndexesAsync.
    /// CreateCoveringIndexesAsync method.
    /// </summary>
    private async Task CreateCoveringIndexesAsync()
    {
        _logger.LogInformation("إنشاء Covering Indexes (INCLUDE)...");

        // Units - Covering Index
        // يغطي الحقول الأكثر استخداماً في SELECT
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Units_Covering"" 
            ON ""Units"" (""PropertyId"", ""UnitTypeId"") 
            INCLUDE (""MaxCapacity"", ""Name"", ""BookingCount"", ""ViewCount"", ""PricingMethod"", ""AdultsCapacity"", ""ChildrenCapacity"");
        ");

        // Properties - Covering Index
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Properties_Covering"" 
            ON ""Properties"" (""City"", ""IsApproved"") 
            INCLUDE (""TypeId"", ""Name"", ""AverageRating"", ""StarRating"", ""IsFeatured"", ""Latitude"", ""Longitude"", ""ViewCount"", ""BookingCount"");
        ");

        // DailyUnitSchedules - Covering لتجنب الرجوع للجدول الرئيسي
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_DailyUnitSchedules_Covering"" 
            ON ""DailyUnitSchedules"" (""UnitId"", ""Date"")
            INCLUDE (""Status"", ""BookingId"", ""PriceAmount"", ""Currency"", ""PricingTier"");
        ");

        _logger.LogInformation("✓ Covering Indexes");
    }

    #endregion

    #region === Expression Indexes ===

    /// <summary>
    /// دالة CreateExpressionIndexesAsync.
    /// CreateExpressionIndexesAsync method.
    /// </summary>
    private async Task CreateExpressionIndexesAsync()
    {
        _logger.LogInformation("إنشاء Expression Indexes...");

        // Units - فهرس الشعبية
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Units_Popularity"" 
            ON ""Units"" (""BookingCount"" DESC, ""ViewCount"" DESC);
        ");

        // Properties - فهرس الشعبية
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Properties_Popularity"" 
            ON ""Properties"" (""BookingCount"" DESC, ""ViewCount"" DESC, ""AverageRating"" DESC);
        ");

        // PropertyImages - ترتيب صور العقارات
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_PropertyImages_PropertyId_DisplayOrder"" 
            ON ""PropertyImages"" (""PropertyId"", ""DisplayOrder"");
        ");

        _logger.LogInformation("✓ Expression Indexes");
    }

    #endregion

    #region === فهارس محسنة إضافية ===

    /// <summary>
    /// فهارس محسنة إضافية لتحسين أداء البحث والفلترة
    /// التركيز: DailyUnitSchedules (الأهم للأداء)
    /// </summary>
    private async Task CreateOptimizedScheduleIndexesAsync()
    {
        _logger.LogInformation("إنشاء فهارس محسنة إضافية...");

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 1. فهارس DailyUnitSchedules المحسنة
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        // فهرس لحساب الأسعار حسب النطاق الزمني
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_DailyUnitSchedules_Pricing"" 
            ON ""DailyUnitSchedules"" (""UnitId"", ""Date"", ""PriceAmount"")
            WHERE ""PriceAmount"" IS NOT NULL;
        ");

        // فهرس للبحث حسب نوع التسعير
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_DailyUnitSchedules_PricingTier"" 
            ON ""DailyUnitSchedules"" (""PricingTier"", ""Date"")
            WHERE ""PricingTier"" IS NOT NULL;
        ");

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 2. فهارس Units المحسنة
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        // فهرس على السعة للبحث السريع حسب عدد الضيوف
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Units_Capacity_Range"" 
            ON ""Units"" (""MaxCapacity"" ASC, ""AdultsCapacity"", ""ChildrenCapacity"")
            WHERE ""MaxCapacity"" > 0;
        ");

        // فهرس على طريقة التسعير
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_Units_PricingMethod"" 
            ON ""Units"" (""PricingMethod"", ""PropertyId"");
        ");

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // 3. فهارس العلاقات (Foreign Keys المحسنة)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        // UnitFieldValues - للبحث في الحقول الديناميكية
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_UnitFieldValues_FieldName_Value"" 
            ON ""UnitFieldValues"" (""UnitTypeFieldId"", ""FieldValue"")
            WHERE ""FieldValue"" IS NOT NULL AND ""FieldValue"" != '';
        ");

        // PropertyServices - لفلترة الخدمات
        await _context.Database.ExecuteSqlRawAsync(@"
            CREATE INDEX IF NOT EXISTS ""IX_PropertyServices_PropertyId"" 
            ON ""PropertyServices"" (""PropertyId"");
        ");

        _logger.LogInformation("✓ فهارس محسنة إضافية");
    }

    #endregion

    #region === Statistics Configuration ===

    /// <summary>
    /// دالة ConfigureStatisticsAsync.
    /// ConfigureStatisticsAsync method.
    /// </summary>
    private async Task ConfigureStatisticsAsync()
    {
        _logger.LogInformation("تكوين PostgreSQL Statistics...");

        await _context.Database.ExecuteSqlRawAsync(@"
            -- Units - الحقول المستخدمة فعلياً في البحث
            ALTER TABLE ""Units"" ALTER COLUMN ""PropertyId"" SET STATISTICS 1000;
            ALTER TABLE ""Units"" ALTER COLUMN ""UnitTypeId"" SET STATISTICS 1000;
            ALTER TABLE ""Units"" ALTER COLUMN ""MaxCapacity"" SET STATISTICS 1000;
            ALTER TABLE ""Units"" ALTER COLUMN ""BookingCount"" SET STATISTICS 1000;
            ALTER TABLE ""Units"" ALTER COLUMN ""ViewCount"" SET STATISTICS 1000;
            ALTER TABLE ""Units"" ALTER COLUMN ""PricingMethod"" SET STATISTICS 1000;
            
            -- Properties
            ALTER TABLE ""Properties"" ALTER COLUMN ""City"" SET STATISTICS 1000;
            ALTER TABLE ""Properties"" ALTER COLUMN ""TypeId"" SET STATISTICS 1000;
            ALTER TABLE ""Properties"" ALTER COLUMN ""AverageRating"" SET STATISTICS 1000;
            ALTER TABLE ""Properties"" ALTER COLUMN ""IsApproved"" SET STATISTICS 1000;
            ALTER TABLE ""Properties"" ALTER COLUMN ""Latitude"" SET STATISTICS 1000;
            ALTER TABLE ""Properties"" ALTER COLUMN ""Longitude"" SET STATISTICS 1000;
            
            -- DailyUnitSchedules - الأهم للأداء
            ALTER TABLE ""DailyUnitSchedules"" ALTER COLUMN ""UnitId"" SET STATISTICS 2000;
            ALTER TABLE ""DailyUnitSchedules"" ALTER COLUMN ""Date"" SET STATISTICS 2000;
            ALTER TABLE ""DailyUnitSchedules"" ALTER COLUMN ""Status"" SET STATISTICS 2000;
            ALTER TABLE ""DailyUnitSchedules"" ALTER COLUMN ""PriceAmount"" SET STATISTICS 1500;
            ALTER TABLE ""DailyUnitSchedules"" ALTER COLUMN ""PricingTier"" SET STATISTICS 1000;
        ");

        _logger.LogInformation("✓ Statistics");
    }

    #endregion

    #region === Analyze Tables ===

    /// <summary>
    /// دالة AnalyzeTablesAsync.
    /// AnalyzeTablesAsync method.
    /// </summary>
    private async Task AnalyzeTablesAsync()
    {
        _logger.LogInformation("تحديث الإحصائيات (ANALYZE)...");

        await _context.Database.ExecuteSqlRawAsync(@"
            ANALYZE ""Units"";
            ANALYZE ""Properties"";
            ANALYZE ""DailyUnitSchedules"";
            ANALYZE ""UnitFieldValues"";
            ANALYZE ""PropertyServices"";
            ANALYZE ""PropertyImages"";
            ANALYZE ""UnitTypes"";
        ");

        _logger.LogInformation("✓ Analyze");
    }

    #endregion
}
