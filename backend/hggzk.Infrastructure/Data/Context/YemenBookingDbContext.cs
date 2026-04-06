using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Infrastructure.Data.Configurations;
using YemenBooking.Core.Seeds;
// usings for automatic audit logging
using Microsoft.AspNetCore.Http;
using System.Diagnostics;
using System.Text.Json;
using System.Linq;
using System.Security.Claims;
using YemenBooking.Core.Enums;
using EntityUserRole = YemenBooking.Core.Entities.UserRole;
using System.Reflection;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Application.Common.Interfaces;
using Npgsql.EntityFrameworkCore.PostgreSQL;
using YemenBooking.Infrastructure.Data.Configurations.Indexes;
using YemenBooking.Infrastructure.Postgres.Configuration;

namespace YemenBooking.Infrastructure.Data.Context;

    /// <summary>
    /// Main Entity Framework Core DbContext for the application.
    /// سياق Entity Framework Core الرئيسي للتطبيق.
    /// </summary>
public class YemenBookingDbContext : DbContext
{
    // Accessor for request-scoped user and HTTP context data.
    // موفر الوصول لبيانات المستخدم الحالي وسياق HTTP الخاص بالطلب.
    /// <summary>
    /// حقل _httpContextAccessor.
    /// _httpContextAccessor field.
    /// </summary>
    private readonly IHttpContextAccessor? _httpContextAccessor;

    /// <summary>
    /// Creates a new DbContext instance.
    /// ينشئ مثيلاً جديداً من DbContext.
    /// </summary>
    /// <param name="options">DbContext options. إعدادات DbContext.</param>
    /// <param name="httpContextAccessor">Optional HTTP context accessor. موفر HTTP اختياري.</param>
    public YemenBookingDbContext(
        DbContextOptions<YemenBookingDbContext> options,
        IHttpContextAccessor? httpContextAccessor = null
    ) : base(options)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    #region DbSets

    /// <summary>
    /// Users table.
    /// جدول المستخدمين.
    /// </summary>
    public DbSet<User> Users { get; set; }

    /// <summary>
    /// User wallet accounts table.
    /// جدول حسابات محفظة المستخدمين.
    /// </summary>
    public DbSet<UserWalletAccount> UserWalletAccounts { get; set; }

    /// <summary>
    /// Roles table.
    /// جدول الأدوار.
    /// </summary>
    public DbSet<Role> Roles { get; set; }

    /// <summary>
    /// User roles table.
    /// جدول أدوار المستخدمين.
    /// </summary>
    public DbSet<EntityUserRole> UserRoles { get; set; }

    /// <summary>
    /// Property types table.
    /// جدول أنواع الكيانات.
    /// </summary>
    public DbSet<PropertyType> PropertyTypes { get; set; }

    /// <summary>
    /// Properties table.
    /// جدول الكيانات.
    /// </summary>
    public DbSet<Property> Properties { get; set; }

    /// <summary>
    /// Property images table.
    /// جدول صور الكيانات.
    /// </summary>
    public DbSet<PropertyImage> PropertyImages { get; set; }

    /// <summary>
    /// Section images table.
    /// جدول صور الأقسام.
    /// </summary>
    public DbSet<SectionImage> SectionImages { get; set; }

    /// <summary>
    /// Property-in-section images table.
    /// جدول صور "عقار في قسم".
    /// </summary>
    public DbSet<PropertyInSectionImage> PropertyInSectionImages { get; set; }

    /// <summary>
    /// Unit-in-section images table.
    /// جدول صور "وحدة في قسم".
    /// </summary>
    public DbSet<UnitInSectionImage> UnitInSectionImages { get; set; }

    /// <summary>
    /// Unit types table.
    /// جدول أنواع الوحدات.
    /// </summary>
    public DbSet<UnitType> UnitTypes { get; set; }

    /// <summary>
    /// Units table.
    /// جدول الوحدات.
    /// </summary>
    public DbSet<Unit> Units { get; set; }

    /// <summary>
    /// Sections table.
    /// جدول الأقسام.
    /// </summary>
    public DbSet<Section> Sections { get; set; }

    /// <summary>
    /// Property-in-sections table.
    /// جدول عقارات الأقسام (سجل غني).
    /// </summary>
    public DbSet<PropertyInSection> PropertyInSections { get; set; }

    /// <summary>
    /// Unit-in-sections table.
    /// جدول وحدات الأقسام (سجل غني).
    /// </summary>
    public DbSet<UnitInSection> UnitInSections { get; set; }

    /// <summary>
    /// Bookings table.
    /// جدول الحجوزات.
    /// </summary>
    public DbSet<Booking> Bookings { get; set; }

    /// <summary>
    /// Payments table.
    /// جدول المدفوعات.
    /// </summary>
    public DbSet<Payment> Payments { get; set; }

    /// <summary>
    /// Property services table.
    /// جدول خدمات الكيانات.
    /// </summary>
    public DbSet<PropertyService> PropertyServices { get; set; }

    /// <summary>
    /// Booking services table.
    /// جدول خدمات الحجوزات.
    /// </summary>
    public DbSet<BookingService> BookingServices { get; set; }

    /// <summary>
    /// Amenities table.
    /// جدول المرافق.
    /// </summary>
    public DbSet<Amenity> Amenities { get; set; }

    /// <summary>
    /// Property type amenities table.
    /// جدول مرافق أنواع الكيانات.
    /// </summary>
    public DbSet<PropertyTypeAmenity> PropertyTypeAmenities { get; set; }

    /// <summary>
    /// Property amenities table.
    /// جدول مرافق الكيانات.
    /// </summary>
    public DbSet<PropertyAmenity> PropertyAmenities { get; set; }

    /// <summary>
    /// Reviews table.
    /// جدول التقييمات.
    /// </summary>
    public DbSet<Review> Reviews { get; set; }

    /// <summary>
    /// Property policies table.
    /// جدول سياسات الكيانات.
    /// </summary>
    public DbSet<PropertyPolicy> PropertyPolicies { get; set; }

    /// <summary>
    /// Property nearby places table.
    /// جدول الأماكن القريبة للعقارات.
    /// </summary>
    public DbSet<PropertyNearbyPlace> PropertyNearbyPlaces { get; set; }

    /// <summary>
    /// Staff table.
    /// جدول الموظفين.
    /// </summary>
    public DbSet<Staff> Staff { get; set; }

    /// <summary>
    /// Admin actions table.
    /// جدول إجراءات الإدارة.
    /// </summary>
    public DbSet<AdminAction> AdminActions { get; set; }

    /// <summary>
    /// Notifications table.
    /// جدول الإشعارات.
    /// </summary>
    public DbSet<Notification> Notifications { get; set; }

    /// <summary>
    /// Notification channels table.
    /// جدول قنوات الإشعارات.
    /// </summary>
    public DbSet<NotificationChannel> NotificationChannels { get; set; }

    /// <summary>
    /// User channel subscriptions table.
    /// جدول اشتراكات المستخدمين في القنوات.
    /// </summary>
    public DbSet<UserChannel> UserChannels { get; set; }

    /// <summary>
    /// Notification channel history table.
    /// جدول سجل إشعارات القنوات.
    /// </summary>
    public DbSet<NotificationChannelHistory> NotificationChannelHistories { get; set; }

    /// <summary>
    /// Audit logs table.
    /// جدول سجلات التدقيق.
    /// </summary>
    public DbSet<AuditLog> AuditLogs { get; set; }

    /// <summary>
    /// User settings table.
    /// جدول إعدادات المستخدم.
    /// </summary>
    public DbSet<UserSettings> UserSettings { get; set; }

    /// <summary>
    /// Review images table.
    /// جدول صور التقييمات.
    /// </summary>
    public DbSet<ReviewImage> ReviewImages { get; set; }

    /// <summary>
    /// Review responses table.
    /// جدول ردود التقييمات.
    /// </summary>
    public DbSet<ReviewResponse> ReviewResponses { get; set; }

    /// <summary>
    /// Reports table.
    /// جدول البلاغات.
    /// </summary>
    public DbSet<Report> Reports { get; set; }

    /// <summary>
    /// Unit type fields table.
    /// جدول حقول أنواع الوحدات.
    /// </summary>
    public DbSet<UnitTypeField> UnitTypeFields { get; set; }

    /// <summary>
    /// Field groups table.
    /// جدول مجموعات الحقول.
    /// </summary>
    public DbSet<FieldGroup> FieldGroups { get; set; }

    /// <summary>
    /// Field group fields table.
    /// جدول ارتباط الحقول بالمجموعات.
    /// </summary>
    public DbSet<FieldGroupField> FieldGroupFields { get; set; }

    /// <summary>
    /// Search filters table.
    /// جدول الفلاتر.
    /// </summary>
    public DbSet<SearchFilter> SearchFilters { get; set; }

    /// <summary>
    /// Unit field values table.
    /// جدول قيم الحقول للوحدات.
    /// </summary>
    public DbSet<UnitFieldValue> UnitFieldValues { get; set; }

    /// <summary>
    /// Search logs table.
    /// جدول سجلات البحث.
    /// </summary>
    public DbSet<SearchLog> SearchLogs { get; set; }

    /// <summary>
    /// Chat conversations table.
    /// جدول المحادثات.
    /// </summary>
    public DbSet<YemenBooking.Core.Entities.ChatConversation> ChatConversations { get; set; }

    /// <summary>
    /// Chat messages table.
    /// جدول الرسائل.
    /// </summary>
    public DbSet<YemenBooking.Core.Entities.ChatMessage> ChatMessages { get; set; }

    /// <summary>
    /// Message reactions table.
    /// جدول التفاعلات على الرسائل.
    /// </summary>
    public DbSet<YemenBooking.Core.Entities.MessageReaction> MessageReactions { get; set; }

    /// <summary>
    /// Chat attachments table.
    /// جدول مرفقات المحادثات.
    /// </summary>
    public DbSet<YemenBooking.Core.Entities.ChatAttachment> ChatAttachments { get; set; }

    /// <summary>
    /// Chat settings table.
    /// جدول إعدادات الشات لكل مستخدم.
    /// </summary>
    public DbSet<YemenBooking.Core.Entities.ChatSettings> ChatSettings { get; set; }

    /// <summary>
    /// Index metadata table for incremental indexing.
    /// جدول بيانات تعريف الفهارس للتحديث التدريجي.
    /// </summary>
    public DbSet<IndexMetadata> IndexMetadata { get; set; }

    /// <summary>
    /// Currencies table.
    /// جدول العملات.
    /// </summary>
    public DbSet<Currency> Currencies { get; set; }

    /// <summary>
    /// Cities table.
    /// جدول المدن.
    /// </summary>
    public DbSet<City> Cities { get; set; }

    /// <summary>
    /// Daily unified schedule table for units.
    /// الجدول اليومي الموحد للوحدات (يجمع التسعير والإتاحة).
    /// </summary>
    public DbSet<DailyUnitSchedule> DailyUnitSchedules { get; set; }

    /// <summary>
    /// Favorites table.
    /// جدول المفضلات للمستخدمين.
    /// </summary>
    public DbSet<Favorite> Favorites { get; set; }

    /// <summary>
    /// Chart of accounts table.
    /// جدول دليل الحسابات المحاسبية.
    /// </summary>
    public DbSet<ChartOfAccount> ChartOfAccounts { get; set; }

    /// <summary>
    /// Financial transactions table.
    /// جدول القيود المحاسبية.
    /// </summary>
    public DbSet<FinancialTransaction> FinancialTransactions { get; set; }

    #endregion

    /// <summary>
    /// دالة OnModelCreating.
    /// OnModelCreating method.
    /// </summary>
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.HasPostgresExtension("pg_trgm");
        modelBuilder.HasPostgresExtension("btree_gist");

        // Apply all entity configurations.
        // تطبيق جميع إعدادات الكيانات.
        modelBuilder.ApplyConfiguration(new UserConfiguration());
        modelBuilder.ApplyConfiguration(new UserWalletAccountConfiguration());
        modelBuilder.ApplyConfiguration(new RoleConfiguration());
        modelBuilder.ApplyConfiguration(new UserRoleConfiguration());
        modelBuilder.ApplyConfiguration(new PropertyTypeConfiguration());
        modelBuilder.ApplyConfiguration(new PropertyConfiguration());
        modelBuilder.ApplyConfiguration(new PropertyImageConfiguration());
        modelBuilder.ApplyConfiguration(new SectionImageConfiguration());
        modelBuilder.ApplyConfiguration(new PropertyInSectionImageConfiguration());
        modelBuilder.ApplyConfiguration(new UnitInSectionImageConfiguration());
        modelBuilder.ApplyConfiguration(new UnitTypeConfiguration());
        modelBuilder.ApplyConfiguration(new UnitConfiguration());
        modelBuilder.ApplyConfiguration(new BookingConfiguration());
        modelBuilder.ApplyConfiguration(new PaymentConfiguration());
        modelBuilder.ApplyConfiguration(new PropertyServiceConfiguration());
        modelBuilder.ApplyConfiguration(new BookingServiceConfiguration());
        modelBuilder.ApplyConfiguration(new AmenityConfiguration());
        modelBuilder.ApplyConfiguration(new PropertyTypeAmenityConfiguration());
        modelBuilder.ApplyConfiguration(new PropertyAmenityConfiguration());
        modelBuilder.ApplyConfiguration(new PropertyNearbyPlaceConfiguration());
        modelBuilder.ApplyConfiguration(new UnitTypeFieldConfiguration());
        modelBuilder.ApplyConfiguration(new FieldGroupConfiguration());
        modelBuilder.ApplyConfiguration(new FieldGroupFieldConfiguration());
        modelBuilder.ApplyConfiguration(new SearchFilterConfiguration());
        modelBuilder.ApplyConfiguration(new UnitFieldValueConfiguration());
        modelBuilder.ApplyConfiguration(new ReviewConfiguration());
        modelBuilder.ApplyConfiguration(new PropertyPolicyConfiguration());
        modelBuilder.ApplyConfiguration(new StaffConfiguration());
        modelBuilder.ApplyConfiguration(new UserSettingsConfiguration());
        modelBuilder.ApplyConfiguration(new AdminActionConfiguration());
        modelBuilder.ApplyConfiguration(new SectionConfiguration());
        // SectionItem configuration removed.
        // تمت إزالة إعداد SectionItem.
        modelBuilder.ApplyConfiguration(new PropertyInSectionConfiguration());
        modelBuilder.ApplyConfiguration(new UnitInSectionConfiguration());

        // Search log configuration.
        // تكوين سجل البحث.
        modelBuilder.ApplyConfiguration(new SearchLogConfiguration());

        // Configurations for new entities.
        // إعدادات الكيانات الجديدة.
        modelBuilder.ApplyConfiguration(new NotificationConfiguration());
        modelBuilder.ApplyConfiguration(new NotificationChannelConfiguration());
        modelBuilder.ApplyConfiguration(new UserChannelConfiguration());
        modelBuilder.ApplyConfiguration(new NotificationChannelHistoryConfiguration());
        modelBuilder.ApplyConfiguration(new AuditLogConfiguration());
        modelBuilder.ApplyConfiguration(new ReviewImageConfiguration());
        modelBuilder.ApplyConfiguration(new ReviewResponseConfiguration());
        modelBuilder.ApplyConfiguration(new ReportConfiguration());

        // Chat configuration for conversations, messages, reactions, attachments, and settings.
        // تكوين الشات للمحادثات والرسائل والتفاعلات والمرفقات والإعدادات.
        modelBuilder.ApplyConfiguration(new ChatConversationConfiguration());
        modelBuilder.ApplyConfiguration(new ChatMessageConfiguration());
        modelBuilder.ApplyConfiguration(new MessageReactionConfiguration());
        modelBuilder.ApplyConfiguration(new ChatAttachmentConfiguration());
        modelBuilder.ApplyConfiguration(new ChatSettingsConfiguration());

        // Configurations for daily unit schedule.
        // إعدادات الجدول اليومي الموحد للوحدات.
        modelBuilder.ApplyConfiguration(new DailyUnitScheduleConfiguration());

        // Index metadata configuration for incremental indexing.
        // تكوين بيانات تعريف الفهارس للتحديث التدريجي.
        modelBuilder.ApplyConfiguration(new IndexMetadataConfiguration());

        // Currency and city configurations.
        // إعدادات العملات والمدن.
        modelBuilder.ApplyConfiguration(new CurrencyConfiguration());
        modelBuilder.ApplyConfiguration(new CityConfiguration());
        modelBuilder.ApplyConfiguration(new FavoriteConfiguration());

        // Financial accounting configurations.
        // إعدادات المحاسبة المالية.
        modelBuilder.ApplyConfiguration(new ChartOfAccountConfiguration());
        modelBuilder.ApplyConfiguration(new FinancialTransactionConfiguration());

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // Search and filter index configurations.
        // تكوينات فهارس البحث والفلترة لضمان الإنشاء التلقائي.
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        modelBuilder.ApplyConfiguration(new Configurations.Indexes.UnitIndexConfiguration());
        modelBuilder.ApplyConfiguration(new Configurations.Indexes.PropertyIndexConfiguration());
        modelBuilder.ApplyConfiguration(new Configurations.Indexes.UnitFieldValueIndexConfiguration());
        modelBuilder.ApplyConfiguration(new Configurations.Indexes.PropertyAmenityIndexConfiguration());
        modelBuilder.ApplyConfiguration(new Configurations.Indexes.PropertyServiceIndexConfiguration());
        
        // Apply advanced indexes (partial, composite, etc.).
        // تطبيق الفهارس المتقدمة (Partial, Composite, etc.).
        modelBuilder.ConfigureAdvancedIndexes();
        
        // Apply PostgreSQL-specific indexes (full-text, GiST, covering).
        // ملاحظة: يتم تطبيقها فقط عند إنشاء قاعدة البيانات أو تشغيل Migration.
        modelBuilder.ApplyPostgreSQLIndexes();
        
        // Configure PostgreSQL helper functions for search and filtering.
        // تكوين دوال PostgreSQL المخصصة للبحث والفلترة.
        modelBuilder.ConfigurePostgreSqlFunctions();

        // Seed data moved to DataSeedingService (runtime seeding).
        // تم نقل البيانات الأولية إلى DataSeedingService أثناء التشغيل.
        // DatabaseSeeder.Seed(modelBuilder); // COMMENTED OUT - causes duplicate data in migrations
        
        // Configure DateTime mappings for PostgreSQL.
        // تكوين DateTime لـ PostgreSQL وتحويل جميع القيم إلى UTC.
        var dateTimeConverter = new Microsoft.EntityFrameworkCore.Storage.ValueConversion.ValueConverter<DateTime, DateTime>(
            v => v.Kind == DateTimeKind.Utc ? v : DateTime.SpecifyKind(v, DateTimeKind.Utc),
            v => DateTime.SpecifyKind(v, DateTimeKind.Utc));
            
        var nullableDateTimeConverter = new Microsoft.EntityFrameworkCore.Storage.ValueConversion.ValueConverter<DateTime?, DateTime?>(
            v => v.HasValue ? (v.Value.Kind == DateTimeKind.Utc ? v : DateTime.SpecifyKind(v.Value, DateTimeKind.Utc)) : v,
            v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : v);
        
        foreach (var entityType in modelBuilder.Model.GetEntityTypes())
        {
            foreach (var property in entityType.GetProperties())
            {
                if (property.ClrType == typeof(DateTime))
                {
                    property.SetColumnType("timestamp with time zone");
                    property.SetValueConverter(dateTimeConverter);
                }
                else if (property.ClrType == typeof(DateTime?))
                {
                    property.SetColumnType("timestamp with time zone");
                    property.SetValueConverter(nullableDateTimeConverter);
                }
            }
        }
    }
   
    /// <summary>
    /// Saves changes without automatic audit logging.
    /// يحفظ التغييرات بدون تسجيل تدقيق تلقائي.
    /// </summary>
    public override int SaveChanges()
    {
        EnsureUtcDates();
        return base.SaveChanges();
    }

    /// <summary>
    /// Saves changes asynchronously without automatic audit logging.
    /// يحفظ التغييرات غير المتزامنة بدون تسجيل تدقيق تلقائي.
    /// </summary>
    public override Task<int> SaveChangesAsync(bool acceptAllChangesOnSuccess, CancellationToken cancellationToken = default)
    {
        EnsureUtcDates();
        return base.SaveChangesAsync(acceptAllChangesOnSuccess, cancellationToken);
    }
    
    /// <summary>
    /// Ensures all DateTime properties are stored in UTC.
    /// يضمن تخزين جميع خصائص DateTime بصيغة UTC.
    /// </summary>
    private void EnsureUtcDates()
    {
        var entries = ChangeTracker.Entries()
            .Where(e => e.State == EntityState.Added || e.State == EntityState.Modified);
        
        foreach (var entry in entries)
        {
            var entityType = entry.Entity.GetType();
            var properties = entityType.GetProperties()
                .Where(p => p.PropertyType == typeof(DateTime) || p.PropertyType == typeof(DateTime?));
            
            foreach (var property in properties)
            {
                if (!property.CanRead || !property.CanWrite)
                    continue;
                    
                var value = property.GetValue(entry.Entity);

                if (value is DateTime dateTime)
                {
                    // Guard against values that can roundtrip to Postgres "-infinity" (e.g., DateTime.MinValue).
                    // الحماية من القيم التي قد تُفسَّر كـ -infinity في PostgreSQL مثل DateTime.MinValue.
                    // Normalize values that should be stored as UTC.
                    var normalized = NormalizeDateTimeForPostgres(dateTime);
                    property.SetValue(entry.Entity, normalized);
                }
                else if (value is DateTime?)
                {
                    var nullable = (DateTime?)value;
                    if (nullable.HasValue)
                    {
                        var normalized = NormalizeDateTimeForPostgres(nullable.Value);
                        property.SetValue(entry.Entity, (DateTime?)normalized);
                    }
                }
            }
        }
    }

    /// <summary>
    /// Normalizes DateTime values before persisting to PostgreSQL.
    /// يطبع قيم DateTime قبل الحفظ في PostgreSQL.
    /// </summary>
    private static DateTime NormalizeDateTimeForPostgres(DateTime value)
    {
        // Treat MinValue ("default") as unset and replace it with a safe value.
        // اعتبار MinValue قيمة غير مهيأة واستبدالها بقيمة آمنة.
        if (value == default || value == DateTime.MinValue)
            return DateTime.UtcNow;

        // Normalize to UTC.
        // التطبيع إلى UTC.
        if (value.Kind == DateTimeKind.Utc)
            return value;

        if (value.Kind == DateTimeKind.Local)
            return value.ToUniversalTime();

        // Unspecified: assume it's already UTC-ish but mark it as UTC.
        // القيم غير المحددة تُعامل كأنها UTC وتُعلَّم على هذا الأساس.
        return DateTime.SpecifyKind(value, DateTimeKind.Utc);
    }
}
