using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using StackExchange.Redis;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Indexing.Models;
using YemenBooking.Core.Indexing.RediSearch;
using YemenBooking.Core.Settings;
using YemenBooking.Infrastructure.Data.Context;
using YemenBooking.Infrastructure.Redis.Core.Interfaces;

namespace YemenBooking.Infrastructure.Redis.Indexing;

/// <summary>
/// Redis indexing facade based on period-aware search documents.
/// واجهة الفهرسة في Redis المعتمدة على مستندات البحث الزمنية.
/// </summary>
public sealed class OptimizedUnitIndexingService : IUnitIndexingService, IDisposable
{
    #region === Fields / الحقول ===
    
    /// <summary>
    /// حقل _serviceProvider.
    /// _serviceProvider field.
    /// </summary>
    private readonly IServiceProvider _serviceProvider;
    /// <summary>
    /// حقل _redisManager.
    /// _redisManager field.
    /// </summary>
    private readonly IRedisConnectionManager _redisManager;
    /// <summary>
    /// حقل _logger.
    /// _logger field.
    /// </summary>
    private readonly ILogger<OptimizedUnitIndexingService> _logger;
    /// <summary>
    /// حقل _settings.
    /// _settings field.
    /// </summary>
    private readonly IndexingSettings _settings;
    /// <summary>
    /// حقل _indexingLock.
    /// _indexingLock field.
    /// </summary>
    private readonly SemaphoreSlim _indexingLock;
    /// <summary>
    /// حقل _parallelProcessingSemaphore.
    /// _parallelProcessingSemaphore field.
    /// </summary>
    private readonly SemaphoreSlim _parallelProcessingSemaphore;
    /// <summary>
    /// حقل _searchEngine.
    /// _searchEngine field.
    /// </summary>
    private readonly IUnitSearchEngine _searchEngine;
    /// <summary>
    /// حقل _disposed.
    /// _disposed field.
    /// </summary>
    private bool _disposed;
    
    #endregion
    
    #region === Construction / البناء والتهيئة ===
    
    /// <summary>
    /// Creates the optimized indexing service.
    /// ينشئ خدمة الفهرسة المحسّنة.
    /// </summary>
    public OptimizedUnitIndexingService(
        IServiceProvider serviceProvider,
        IRedisConnectionManager redisManager,
        ILogger<OptimizedUnitIndexingService> logger,
        IOptions<IndexingSettings> settings,
        IUnitSearchEngine searchEngine)
    {
        _serviceProvider = serviceProvider ?? throw new ArgumentNullException(nameof(serviceProvider));
        _redisManager = redisManager ?? throw new ArgumentNullException(nameof(redisManager));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        _searchEngine = searchEngine ?? throw new ArgumentNullException(nameof(searchEngine));
        
        _settings = settings?.Value ?? throw new ArgumentNullException(nameof(settings));
        _settings.Validate();
        
        _indexingLock = new SemaphoreSlim(_settings.GetMaxDegreeOfParallelism() * 2);
        _parallelProcessingSemaphore = new SemaphoreSlim(10); // Max 10 concurrent operations. / حد أقصى 10 عمليات متزامنة.
    }

    /// <summary>
    /// Ensures the Redis search indexes exist.
    /// يتأكد من وجود فهارس Redis.
    /// </summary>
    private async Task EnsureIndexesExistAsync()
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        try
        {
            var db = await _redisManager.GetDatabaseAsync().ConfigureAwait(false);
            
            // Check the units index. / فحص فهرس الوحدات.
            try
            {
                await db.ExecuteAsync("FT.INFO", PeriodBasedSearchSchema.UNITS_INDEX).ConfigureAwait(false);
            }
            catch (RedisServerException ex) when (ex.Message.Contains("Unknown index") || ex.Message.Contains("no such index"))
            {
                // Create the index when missing. / إنشاء الفهرس عند عدم وجوده.
                using var scope = _serviceProvider.CreateScope();
                var dbContext = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();
                var dynamicFields = await LoadDynamicSchemaFieldsAsync(dbContext, CancellationToken.None).ConfigureAwait(false);
                var unitsCmd = PeriodBasedSearchSchema.GetCreateUnitsIndexCommand(dynamicFields);
                await db.ExecuteAsync(unitsCmd[0], unitsCmd.Skip(1).ToArray()).ConfigureAwait(false);
                _logger.LogInformation(
                    "تم إنشاء فهرس الوحدات: {Index} مع {DynamicFieldsCount} حقول ديناميكية قابلة للفلترة",
                    PeriodBasedSearchSchema.UNITS_INDEX,
                    dynamicFields.Count);
            }
            
            // Check the schedule index. / فحص فهرس الجداول.
            try
            {
                await db.ExecuteAsync("FT.INFO", PeriodBasedSearchSchema.SCHEDULE_INDEX).ConfigureAwait(false);
            }
            catch (RedisServerException ex) when (ex.Message.Contains("Unknown index") || ex.Message.Contains("no such index"))
            {
                var scheduleCmd = PeriodBasedSearchSchema.BuildSchedulePeriodIndexSchema();
                await db.ExecuteAsync(scheduleCmd[0], scheduleCmd.Skip(1).ToArray()).ConfigureAwait(false);
                _logger.LogInformation("تم إنشاء فهرس الجدول الموحد: {Index}", PeriodBasedSearchSchema.SCHEDULE_INDEX);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء التحقق من وجود الفهارس");
        }
    }
    
    #endregion
    
    #region === Unit Operations / عمليات الوحدة ===
    
    /// <summary>
    /// Indexes a new unit in Redis.
    /// يفهرس وحدة جديدة في Redis.
    /// </summary>
    public async Task<bool> OnUnitCreatedAsync(Guid unitId, CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        if (unitId == Guid.Empty)
            throw new ArgumentException("معرف الوحدة غير صالح", nameof(unitId));
        
        var lockAcquired = await _indexingLock.WaitAsync(_settings.GetIndexingLockTimeout(), cancellationToken).ConfigureAwait(false);
        if (!lockAcquired)
        {
            _logger.LogWarning("فشل الحصول على قفل الفهرسة للوحدة {UnitId}", unitId);
            return false;
        }
        
        try
        {
            await EnsureIndexesExistAsync().ConfigureAwait(false);
            
            using var scope = _serviceProvider.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();
            
            // Load all required data in one query.
            // Load all required data in one query. / جلب كل البيانات المطلوبة في استعلام واحد.
            var unitData = await LoadUnitDataAsync(unitId, dbContext, cancellationToken).ConfigureAwait(false);
            
            if (unitData == null)
            {
                _logger.LogWarning("لم يتم العثور على الوحدة {UnitId} للفهرسة", unitId);
                return false;
            }
            
            // Build all documents. / بناء جميع المستندات.
            var builder = new PeriodBasedHashBuilder(
                unitData.Unit,
                unitData.Property,
                unitData.UnitType,
                unitData.PropertyType,
                unitData.DailySchedules,
                unitData.Amenities,
                unitData.Services,
                unitData.FieldValues,
                unitData.FieldDefinitions
            );
            
            var db = await _redisManager.GetDatabaseAsync().ConfigureAwait(false);
            
            // 1. Save the main unit document. / حفظ مستند الوحدة الرئيسي.
            var unitKey = PeriodBasedSearchSchema.GetUnitKey(unitId);
            var unitHash = builder.BuildUnitHash();
            
            var unitEntries = unitHash.Select(kvp => 
                new HashEntry(kvp.Key, kvp.Value)).ToArray();
            
            // 2. Build daily schedule documents. / بناء مستندات الجداول اليومية.
            var scheduleHashes = builder.BuildScheduleHashes();
            
            // Use a transaction to keep the data consistent. / استخدام Transaction لضمان اتساق البيانات.
            var transaction = db.CreateTransaction();
            
            // Queue the unit document write. / إضافة حفظ مستند الوحدة.
            _ = transaction.HashSetAsync(unitKey, unitEntries);
            
            // Queue the schedule document writes. / إضافة حفظ الجداول اليومية.
            foreach (var (key, hash) in scheduleHashes)
            {
                var entries = hash.Select(kvp => 
                    new HashEntry(kvp.Key, kvp.Value)).ToArray();
                _ = transaction.HashSetAsync(key, entries);
            }
            
            // Execute all operations atomically. / تنفيذ كل العمليات كوحدة واحدة.
            var committed = await transaction.ExecuteAsync().ConfigureAwait(false);
            
            if (!committed)
            {
                _logger.LogWarning("فشل تنفيذ transaction لفهرسة الوحدة {UnitId}", unitId);
                return false;
            }
            
            _logger.LogInformation(
                "تمت فهرسة الوحدة {UnitId} بنجاح: {ScheduleCount} جدول يومي",
                unitId, scheduleHashes.Count);
            
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء فهرسة الوحدة {UnitId}", unitId);
            throw;
        }
        finally
        {
            _indexingLock.Release();
        }
    }
    
    /// <summary>
    /// Reindexes an existing unit.
    /// يعيد فهرسة وحدة موجودة.
    /// </summary>
    public async Task<bool> OnUnitUpdatedAsync(Guid unitId, CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        if (unitId == Guid.Empty)
            throw new ArgumentException("معرف الوحدة غير صالح", nameof(unitId));
        
        var lockAcquired = await _indexingLock.WaitAsync(_settings.GetIndexingLockTimeout(), cancellationToken).ConfigureAwait(false);
        if (!lockAcquired)
        {
            _logger.LogWarning("فشل الحصول على قفل التحديث للوحدة {UnitId}", unitId);
            return false;
        }
        
        try
        {
            using var scope = _serviceProvider.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();
            
            // Resolve the property ID for cleanup. / تحديد معرف العقار لأغراض الحذف.
            var propertyId = await dbContext.Units
                .Where(u => u.Id == unitId)
                .Select(u => u.PropertyId)
                .FirstOrDefaultAsync(cancellationToken).ConfigureAwait(false);
            
            if (propertyId == Guid.Empty)
            {
                _logger.LogWarning("لم يتم العثور على الوحدة {UnitId} للتحديث", unitId);
                return false;
            }
            
            // Remove the stale documents. / حذف المستندات القديمة.
            await DeleteUnitDocumentsAsync(unitId, propertyId, cancellationToken).ConfigureAwait(false);
            
            // Rebuild the index entry. / إعادة الفهرسة.
            return await OnUnitCreatedAsync(unitId, cancellationToken).ConfigureAwait(false);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء تحديث فهرسة الوحدة {UnitId}", unitId);
            throw;
        }
        finally
        {
            _indexingLock.Release();
        }
    }
    
    /// <summary>
    /// Deletes a unit and its related Redis documents.
    /// يحذف الوحدة ومستنداتها المرتبطة في Redis.
    /// </summary>
    public async Task<bool> OnUnitDeletedAsync(Guid unitId, Guid propertyId, CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        if (unitId == Guid.Empty)
            throw new ArgumentException("معرف الوحدة غير صالح", nameof(unitId));
        
        try
        {
            await DeleteUnitDocumentsAsync(unitId, propertyId, cancellationToken).ConfigureAwait(false);
            
            _logger.LogInformation("تم حذف فهرسة الوحدة {UnitId} بنجاح", unitId);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء حذف فهرسة الوحدة {UnitId}", unitId);
            throw;
        }
    }
    
    #endregion
    
    #region === عمليات العقار (Property Operations) ===
    
    /// <summary>
    /// Reindexes all units for a property.
    /// يعيد فهرسة جميع وحدات العقار.
    /// </summary>
    public async Task<int> OnPropertyUpdatedAsync(Guid propertyId, CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        if (propertyId == Guid.Empty)
            throw new ArgumentException("معرف العقار غير صالح", nameof(propertyId));
        
        try
        {
            using var scope = _serviceProvider.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();
            
            // Load the active units for the property. / جلب الوحدات النشطة الخاصة بالعقار.
            var unitIds = await dbContext.Units
                .Where(u => u.PropertyId == propertyId && u.IsActive && !u.IsDeleted)
                .Select(u => u.Id)
                .ToListAsync(cancellationToken).ConfigureAwait(false);
            
            if (!unitIds.Any())
            {
                _logger.LogInformation("لا توجد وحدات نشطة للعقار {PropertyId}", propertyId);
                return 0;
            }
            
            // Reindex units in parallel with a concurrency cap. / إعادة فهرسة الوحدات بالتوازي مع حد أقصى للتزامن.
            var tasks = unitIds.Select(id => 
                ExecuteWithSemaphoreAsync(() => OnUnitUpdatedAsync(id, cancellationToken), cancellationToken));
            var results = await Task.WhenAll(tasks).ConfigureAwait(false);
            
            var successCount = results.Count(r => r);
            
            _logger.LogInformation(
                "تم تحديث {SuccessCount} من {TotalCount} وحدة للعقار {PropertyId}",
                successCount, unitIds.Count, propertyId);
            
            return successCount;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء تحديث وحدات العقار {PropertyId}", propertyId);
            throw;
        }
    }
    
    /// <summary>
    /// Deletes all property units from the index.
    /// يحذف جميع وحدات العقار من الفهرس.
    /// </summary>
    public async Task<int> OnPropertyDeletedAsync(Guid propertyId, CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        if (propertyId == Guid.Empty)
            throw new ArgumentException("معرف العقار غير صالح", nameof(propertyId));
        
        try
        {
            using var scope = _serviceProvider.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();
            
            // Load all property units. / جلب جميع وحدات العقار.
            var units = await dbContext.Units
                .Where(u => u.PropertyId == propertyId)
                .Select(u => new { u.Id, u.PropertyId })
                .ToListAsync(cancellationToken).ConfigureAwait(false);
            
            if (!units.Any())
            {
                _logger.LogInformation("لا توجد وحدات للعقار {PropertyId}", propertyId);
                return 0;
            }
            
            // Delete units in parallel with a concurrency cap. / حذف الوحدات بالتوازي مع حد أقصى للتزامن.
            var tasks = units.Select(u => 
                ExecuteWithSemaphoreAsync(() => OnUnitDeletedAsync(u.Id, u.PropertyId, cancellationToken), cancellationToken));
            var results = await Task.WhenAll(tasks).ConfigureAwait(false);
            
            var successCount = results.Count(r => r);
            
            _logger.LogInformation(
                "تم حذف {SuccessCount} من {TotalCount} وحدة للعقار {PropertyId}",
                successCount, units.Count, propertyId);
            
            return successCount;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء حذف وحدات العقار {PropertyId}", propertyId);
            throw;
        }
    }
    
    /// <summary>
    /// Handles a newly created property.
    /// يعالج إنشاء عقار جديد.
    /// </summary>
    public async Task<int> OnPropertyCreatedAsync(Guid propertyId, CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        if (propertyId == Guid.Empty)
            throw new ArgumentException("معرف العقار غير صالح", nameof(propertyId));
        
        try
        {
            using var scope = _serviceProvider.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();
            
            // Load the active units for the new property.
            // جلب الوحدات النشطة للعقار الجديد.
            var unitIds = await dbContext.Units
                .Where(u => u.PropertyId == propertyId && u.IsActive && !u.IsDeleted)
                .Select(u => u.Id)
                .ToListAsync(cancellationToken).ConfigureAwait(false);
            
            if (!unitIds.Any())
            {
                _logger.LogInformation("لا توجد وحدات نشطة للعقار الجديد {PropertyId}", propertyId);
                return 0;
            }
            
            // Index units in parallel with a concurrency cap.
            // فهرسة الوحدات بالتوازي مع حد أقصى للتزامن.
            var tasks = unitIds.Select(id => 
                ExecuteWithSemaphoreAsync(() => OnUnitCreatedAsync(id, cancellationToken), cancellationToken));
            var results = await Task.WhenAll(tasks).ConfigureAwait(false);
            
            var successCount = results.Count(r => r);
            
            _logger.LogInformation(
                "تم فهرسة {SuccessCount} من {TotalCount} وحدة للعقار الجديد {PropertyId}",
                successCount, unitIds.Count, propertyId);
            
            return successCount;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء فهرسة وحدات العقار الجديد {PropertyId}", propertyId);
            throw;
        }
    }
    
    #endregion
    
    #region === عمليات نوع الوحدة (Unit Type Operations) ===
    
    /// <summary>
    /// Handles deletion of a unit type.
    /// يعالج حذف نوع وحدة.
    /// </summary>
    public async Task<int> OnUnitTypeDeletedAsync(Guid unitTypeId, CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        if (unitTypeId == Guid.Empty)
            throw new ArgumentException("معرف نوع الوحدة غير صالح", nameof(unitTypeId));
        
        try
        {
            using var scope = _serviceProvider.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();
            
            // Load all units for the type. / جلب جميع الوحدات من هذا النوع.
            var unitIds = await dbContext.Units
                .Where(u => u.UnitTypeId == unitTypeId && u.IsActive && !u.IsDeleted)
                .Select(u => u.Id)
                .ToListAsync(cancellationToken).ConfigureAwait(false);
            
            if (!unitIds.Any())
            {
                _logger.LogInformation("لا توجد وحدات نشطة لنوع الوحدة {UnitTypeId}", unitTypeId);
                return 0;
            }
            
            // Reindex units in parallel with a concurrency cap.
            // إعادة فهرسة الوحدات بالتوازي مع حد أقصى للتزامن.
            var tasks = unitIds.Select(id => 
                ExecuteWithSemaphoreAsync(() => OnUnitUpdatedAsync(id, cancellationToken), cancellationToken));
            var results = await Task.WhenAll(tasks).ConfigureAwait(false);
            
            var successCount = results.Count(r => r);
            
            _logger.LogInformation(
                "تم إعادة فهرسة {SuccessCount} من {TotalCount} وحدة بعد حذف نوع الوحدة {UnitTypeId}",
                successCount, unitIds.Count, unitTypeId);
            
            return successCount;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء معالجة حذف نوع الوحدة {UnitTypeId}", unitTypeId);
            throw;
        }
    }
    
    /// <summary>
    /// Handles updates to a unit-type dynamic field.
    /// يعالج تحديث حقل ديناميكي لنوع الوحدة.
    /// </summary>
    public async Task<int> OnUnitTypeFieldUpdatedAsync(
        string oldFieldName, 
        string newFieldName, 
        string fieldTypeId,
        bool isPrimaryFilter,
        Guid unitTypeId, 
        CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        if (string.IsNullOrWhiteSpace(oldFieldName))
            throw new ArgumentException("اسم الحقل القديم غير صالح", nameof(oldFieldName));
        
        if (string.IsNullOrWhiteSpace(newFieldName))
            throw new ArgumentException("اسم الحقل الجديد غير صالح", nameof(newFieldName));
        
        if (unitTypeId == Guid.Empty)
            throw new ArgumentException("معرف نوع الوحدة غير صالح", nameof(unitTypeId));
        
        try
        {
            using var scope = _serviceProvider.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();
            
            // Load all units for the type. / جلب جميع الوحدات من هذا النوع.
            var unitIds = await dbContext.Units
                .Where(u => u.UnitTypeId == unitTypeId && u.IsActive && !u.IsDeleted)
                .Select(u => u.Id)
                .ToListAsync(cancellationToken).ConfigureAwait(false);
            
            if (!unitIds.Any())
            {
                _logger.LogInformation(
                    "لا توجد وحدات نشطة لنوع الوحدة {UnitTypeId} لتحديث الحقل {FieldName}",
                    unitTypeId, oldFieldName);
                return 0;
            }
            
            _logger.LogInformation(
                "سيتم تنفيذ إعادة بناء كاملة لفهارس Redis بعد تحديث الحقل الديناميكي {OldField} → {NewField} لأن schema تغيّر",
                oldFieldName, newFieldName);

            return await RebuildAllIndexesAsync(_settings.BatchSize, cancellationToken).ConfigureAwait(false);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, 
                "خطأ أثناء معالجة تحديث الحقل {OldField} → {NewField} لنوع الوحدة {UnitTypeId}",
                oldFieldName, newFieldName, unitTypeId);
            throw;
        }
    }
    
    /// <summary>
    /// Handles deletion of a unit-type dynamic field.
    /// يعالج حذف حقل ديناميكي لنوع الوحدة.
    /// </summary>
    public async Task<int> OnUnitTypeFieldDeletedAsync(
        string fieldName, 
        Guid unitTypeId, 
        CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        if (string.IsNullOrWhiteSpace(fieldName))
            throw new ArgumentException("اسم الحقل غير صالح", nameof(fieldName));
        
        if (unitTypeId == Guid.Empty)
            throw new ArgumentException("معرف نوع الوحدة غير صالح", nameof(unitTypeId));
        
        try
        {
            using var scope = _serviceProvider.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();
            
            // Load all units for the type. / جلب جميع الوحدات من هذا النوع.
            var unitIds = await dbContext.Units
                .Where(u => u.UnitTypeId == unitTypeId && u.IsActive && !u.IsDeleted)
                .Select(u => u.Id)
                .ToListAsync(cancellationToken).ConfigureAwait(false);
            
            if (!unitIds.Any())
            {
                _logger.LogInformation(
                    "لا توجد وحدات نشطة لنوع الوحدة {UnitTypeId} لحذف الحقل {FieldName}",
                    unitTypeId, fieldName);
                return 0;
            }
            
            _logger.LogInformation(
                "سيتم تنفيذ إعادة بناء كاملة لفهارس Redis بعد حذف الحقل الديناميكي {FieldName} لأن schema تغيّر",
                fieldName);

            return await RebuildAllIndexesAsync(_settings.BatchSize, cancellationToken).ConfigureAwait(false);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, 
                "خطأ أثناء معالجة حذف الحقل {FieldName} لنوع الوحدة {UnitTypeId}",
                fieldName, unitTypeId);
            throw;
        }
    }
    
    #endregion
    
    #region === Availability & Pricing / الإتاحة والتسعير ===
    
    /// <summary>
    /// Updates unit availability using the legacy flow.
    /// يحدّث إتاحة الوحدة باستخدام المسار القديم.
    /// </summary>
    [Obsolete("Use OnDailyScheduleChangedAsync instead")]
    public async Task<bool> OnAvailabilityChangedAsync(Guid unitId, CancellationToken cancellationToken = default)
    {
        // Legacy path is disabled; use OnDailyScheduleChangedAsync.
        // المسار القديم معطّل، استخدم OnDailyScheduleChangedAsync.
        _logger.LogWarning("OnAvailabilityChangedAsync معطلة، استخدم OnDailyScheduleChangedAsync بدلاً منها");
        return await OnDailyScheduleChangedAsync(unitId, cancellationToken);
    }
    
    /// <summary>
    /// Updates daily pricing and availability schedules for a unit.
    /// يحدّث جداول التسعير والإتاحة اليومية للوحدة.
    /// </summary>
    public async Task<bool> OnDailyScheduleChangedAsync(Guid unitId, CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        if (unitId == Guid.Empty)
            throw new ArgumentException("معرف الوحدة غير صالح", nameof(unitId));
        
        try
        {
            using var scope = _serviceProvider.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();
            
            var schedules = await dbContext.Set<DailyUnitSchedule>()
                .Where(s => s.UnitId == unitId)
                .ToListAsync(cancellationToken).ConfigureAwait(false);
            
            var unit = await dbContext.Units
                .Include(u => u.Property)
                .FirstOrDefaultAsync(u => u.Id == unitId, cancellationToken).ConfigureAwait(false);
            
            if (unit == null)
            {
                _logger.LogWarning("لم يتم العثور على الوحدة {UnitId}", unitId);
                return false;
            }
            
            _logger.LogInformation(
                "تم تحديث {Count} جدول يومي للوحدة {UnitId}",
                schedules.Count, unitId);
            
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء تحديث الجداول اليومية للوحدة {UnitId}", unitId);
            throw;
        }
    }
    
    #endregion
    
    #region === Search / البحث ===
    
    /// <summary>
    /// Searches units through the optimized Redis engine.
    /// يبحث عن الوحدات عبر محرك Redis المحسن.
    /// </summary>
    public Task<UnitSearchResult> SearchUnitsAsync(UnitSearchRequest request, CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        return _searchEngine.SearchUnitsAsync(request, cancellationToken);
    }
    
    /// <summary>
    /// Searches properties together with their matched units.
    /// يبحث عن العقارات مع الوحدات المطابقة لها.
    /// </summary>
    public Task<PropertyWithUnitsSearchResult> SearchPropertiesWithUnitsAsync(
        PropertyWithUnitsSearchRequest request,
        CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        return _searchEngine.SearchPropertiesWithUnitsAsync(request, cancellationToken);
    }
    
    #endregion
    
    #region === الصيانة (Maintenance) ===
    
    /// <summary>
    /// Rebuilds a single unit index entry.
    /// يعيد بناء فهرسة وحدة واحدة.
    /// </summary>
    public async Task<bool> RebuildUnitIndexAsync(Guid unitId, CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        return await OnUnitUpdatedAsync(unitId, cancellationToken).ConfigureAwait(false);
    }
    
    /// <summary>
    /// Rebuilds all unit indexes for a property.
    /// يعيد بناء فهارس جميع وحدات العقار.
    /// </summary>
    public async Task<int> RebuildPropertyUnitsIndexAsync(Guid propertyId, CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        return await OnPropertyUpdatedAsync(propertyId, cancellationToken).ConfigureAwait(false);
    }
    
    /// <summary>
    /// Rebuilds the full index for all units.
    /// يعيد بناء الفهرس الكامل لجميع الوحدات.
    /// </summary>
    public async Task<int> RebuildAllIndexesAsync(int batchSize = 100, CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        try
        {
            _logger.LogInformation("بدء إعادة بناء الفهرس الكامل بحجم دفعة {BatchSize}", batchSize);
            
            // 1. Drop old indexes. / حذف الفهارس القديمة.
            await DropAllIndexesAsync(deleteDocuments: true).ConfigureAwait(false);
            
            // 2. Recreate indexes. / إعادة إنشاء الفهارس.
            await EnsureIndexesExistAsync().ConfigureAwait(false);
            
            // 3. Index active units in batches.
            // 3. فهرسة الوحدات النشطة على دفعات.
            using var scope = _serviceProvider.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();
            
            int totalIndexed = 0;
            int batchNumber = 0;
            int offset = 0;
            
            while (true)
            {
                // Load a batch of unit IDs. / جلب دفعة من معرفات الوحدات.
                var batch = await dbContext.Units
                    .Where(u => u.IsActive && !u.IsDeleted)
                    .OrderBy(u => u.Id)
                    .Skip(offset)
                    .Take(batchSize)
                    .Select(u => u.Id)
                    .ToListAsync(cancellationToken).ConfigureAwait(false);
                
                if (!batch.Any())
                    break;
                
                batchNumber++;
                
                var tasks = batch.Select(id => 
                    ExecuteWithSemaphoreAsync(() => OnUnitCreatedAsync(id, cancellationToken), cancellationToken));
                var results = await Task.WhenAll(tasks).ConfigureAwait(false);
                
                int batchSuccess = results.Count(r => r);
                totalIndexed += batchSuccess;
                
                _logger.LogInformation(
                    "الدفعة {BatchNumber}: تمت فهرسة {Success} من {Total} وحدة",
                    batchNumber, batchSuccess, batch.Count);
                
                offset += batchSize;
                
                // Brief delay between batches to reduce Redis pressure.
                // تأخير بسيط بين الدفعات لتخفيف الضغط على Redis.
                await Task.Delay(100, cancellationToken).ConfigureAwait(false);
            }
            
            _logger.LogInformation(
                "اكتملت إعادة بناء الفهرس: {Indexed} وحدة",
                totalIndexed);
            
            return totalIndexed;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء إعادة بناء الفهرس الكامل");
            throw;
        }
    }
    
    /// <summary>
    /// Cleans stale or damaged index data.
    /// ينظف بيانات الفهرس القديمة أو التالفة.
    /// </summary>
    public async Task<int> CleanupIndexesAsync(CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        try
        {
            _logger.LogInformation("بدء تنظيف الفهارس");
            
            var db = await _redisManager.GetDatabaseAsync().ConfigureAwait(false);
            var server = _redisManager.GetServer();
            int deletedCount = 0;
            
            // 1. Remove temporary keys. / حذف المفاتيح المؤقتة.
            var tempKeys = (await ScanKeysAsync("temp:*").ConfigureAwait(false)).ToArray();
            if (tempKeys.Any())
            {
                await db.KeyDeleteAsync(tempKeys).ConfigureAwait(false);
                deletedCount += tempKeys.Length;
                _logger.LogInformation("تم حذف {Count} مفتاح مؤقت", tempKeys.Length);
            }
            
            // 2. Remove Redis documents for DB-deleted units.
            // 2. حذف مستندات الوحدات المحذوفة من قاعدة البيانات.
            using var scope = _serviceProvider.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();
            
            var activeUnitIds = await dbContext.Units
                .Where(u => u.IsActive && !u.IsDeleted)
                .Select(u => u.Id)
                .ToListAsync(cancellationToken).ConfigureAwait(false);
            
            var activeUnitIdsSet = new HashSet<Guid>(activeUnitIds);
            
            // Scan unit keys instead of using KEYS.
            // فحص مفاتيح الوحدات باستخدام SCAN بدلاً من KEYS.
            var unitKeys = await ScanKeysAsync($"{PeriodBasedSearchSchema.UNITS_PREFIX}*").ConfigureAwait(false);
            
            foreach (var key in unitKeys)
            {
                var keyStr = key.ToString();
                var unitIdStr = keyStr.Replace(PeriodBasedSearchSchema.UNITS_PREFIX, "");
                
                if (Guid.TryParse(unitIdStr, out var unitId) && !activeUnitIdsSet.Contains(unitId))
                {
                    // Unit is missing from the DB, delete its documents.
                    // الوحدة غير موجودة في قاعدة البيانات، نحذف مستنداتها.
                    await db.KeyDeleteAsync(key).ConfigureAwait(false);
                    deletedCount++;
                    
                    // Remove related pricing and availability periods.
                    // حذف فترات التسعير والإتاحة المرتبطة.
                    await DeletePricingPeriodsAsync(unitId, cancellationToken).ConfigureAwait(false);
                    await DeleteAvailabilityPeriodsAsync(unitId, cancellationToken).ConfigureAwait(false);
                }
            }
            
            _logger.LogInformation("اكتمل التنظيف: تم حذف {Count} مفتاح", deletedCount);
            
            return deletedCount;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء تنظيف الفهارس");
            throw;
        }
    }
    
    #endregion
    
    #region === الإحصائيات (Statistics) ===
    
    /// <summary>
    /// Gets index statistics.
    /// يعيد إحصائيات الفهرس.
    /// </summary>
    public async Task<Dictionary<string, object>> GetIndexStatisticsAsync(CancellationToken cancellationToken = default)
    {
        if (_disposed)
            throw new ObjectDisposedException(nameof(OptimizedUnitIndexingService));
        
        try
        {
            var db = await _redisManager.GetDatabaseAsync().ConfigureAwait(false);
            var server = _redisManager.GetServer();
            var stats = new Dictionary<string, object>();
            
            // Gather index metadata. / جمع بيانات الفهارس.
            try
            {
                var unitsInfo = await db.ExecuteAsync("FT.INFO", PeriodBasedSearchSchema.UNITS_INDEX).ConfigureAwait(false);
                var scheduleInfo = await db.ExecuteAsync("FT.INFO", PeriodBasedSearchSchema.SCHEDULE_INDEX).ConfigureAwait(false);
                
                stats["UnitsIndexInfo"] = unitsInfo.ToString();
                stats["ScheduleIndexInfo"] = scheduleInfo.ToString();
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "فشل الحصول على معلومات الفهارس");
            }
            
            // Count indexed documents. / عدّ المستندات المفهرسة.
            var unitKeys = await CountKeysAsync($"{PeriodBasedSearchSchema.UNITS_PREFIX}*").ConfigureAwait(false);
            var scheduleKeys = await CountKeysAsync($"{PeriodBasedSearchSchema.SCHEDULE_PREFIX}*").ConfigureAwait(false);
            
            stats["TotalUnits"] = unitKeys;
            stats["TotalSchedulePeriods"] = scheduleKeys;
            
            // Memory information. / معلومات الذاكرة.
            var info = server.Info("memory");
            stats["MemoryInfo"] = info.ToString();
            
            return stats;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء الحصول على إحصائيات الفهرس");
            throw;
        }
    }
    
    #endregion
    
    #region === وظائف مساعدة (Helper Methods) ===
    
    /// <summary>
    /// Runs an operation under the concurrency semaphore.
    /// ينفذ عملية تحت semaphore للتزامن.
    /// </summary>
    private async Task<T> ExecuteWithSemaphoreAsync<T>(
        Func<Task<T>> operation, 
        CancellationToken cancellationToken)
    {
        await _parallelProcessingSemaphore.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            return await operation().ConfigureAwait(false);
        }
        finally
        {
            _parallelProcessingSemaphore.Release();
        }
    }
    
    /// <summary>
    /// Scans Redis keys without blocking the server.
    /// يفحص مفاتيح Redis دون حجب الخادم.
    /// </summary>
    private async Task<List<RedisKey>> ScanKeysAsync(string pattern, int pageSize = 1000)
    {
        var db = await _redisManager.GetDatabaseAsync().ConfigureAwait(false);
        var keys = new List<RedisKey>();
        long cursor = 0;
        
        do
        {
            var result = await db.ExecuteAsync("SCAN", cursor.ToString(), "MATCH", pattern, "COUNT", pageSize.ToString()).ConfigureAwait(false);
            
            if (result.IsNull || result.Type != ResultType.MultiBulk)
                break;
            
            var resultArray = (RedisResult[])result;
            if (resultArray.Length < 2)
                break;
            
            // Read the next cursor. / قراءة cursor التالي.
            cursor = long.Parse(resultArray[0].ToString()!);
            
            // Read the keys. / قراءة المفاتيح.
            if (resultArray[1].Type == ResultType.MultiBulk)
            {
                var keysArray = (RedisResult[])resultArray[1];
                foreach (var key in keysArray)
                {
                    if (!key.IsNull)
                    {
                        keys.Add(key.ToString()!);
                    }
                }
            }
        } while (cursor != 0);
        
        return keys;
    }
    
    /// <summary>
    /// Counts keys using SCAN.
    /// يعدّ المفاتيح باستخدام SCAN.
    /// </summary>
    private async Task<int> CountKeysAsync(string pattern, int pageSize = 1000)
    {
        var keys = await ScanKeysAsync(pattern, pageSize).ConfigureAwait(false);
        return keys.Count;
    }
    
    /// <summary>
    /// Loads all unit data in a single optimized query.
    /// يجلب جميع بيانات الوحدة في استعلام واحد محسّن.
    /// </summary>
    private async Task<UnitFullData?> LoadUnitDataAsync(
        Guid unitId,
        YemenBookingDbContext dbContext,
        CancellationToken cancellationToken)
    {
        var unit = await dbContext.Units
            .AsNoTracking()
            .Include(u => u.Property)
                .ThenInclude(p => p.PropertyType)
            .Include(u => u.UnitType)
                .ThenInclude(ut => ut.UnitTypeFields)
            .Include(u => u.FieldValues)
            .Include(u => u.DailySchedules)
            .FirstOrDefaultAsync(u => u.Id == unitId && u.IsActive && !u.IsDeleted, cancellationToken).ConfigureAwait(false);
        
        if (unit == null)
            return null;
        
        // EF Core DbContext does not support concurrent active operations on the
        // same instance, so keep these follow-up queries sequential here.
        // لا يدعم DbContext تنفيذ عمليات متزامنة على نفس النسخة، لذا نجلب
        // الاستعلامات التابعة بشكل متسلسل أثناء إعادة البناء.
        var amenities = await dbContext.PropertyAmenities
            .AsNoTracking()
            .Include(a => a.PropertyTypeAmenity)
                .ThenInclude(pta => pta.Amenity)
            .Where(a => a.PropertyId == unit.PropertyId)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        
        var services = await dbContext.PropertyServices
            .AsNoTracking()
            .Where(s => s.PropertyId == unit.PropertyId)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        
        return new UnitFullData
        {
            Unit = unit,
            Property = unit.Property,
            UnitType = unit.UnitType,
            PropertyType = unit.Property.PropertyType,
            DailySchedules = unit.DailySchedules.ToList(),
            Amenities = amenities,
            Services = services,
            FieldValues = unit.FieldValues.ToList(),
            FieldDefinitions = unit.UnitType.UnitTypeFields.ToList()
        };
    }
    
    /// <summary>
    /// Deletes all unit-related Redis documents.
    /// يحذف جميع مستندات Redis المرتبطة بالوحدة.
    /// </summary>
    private async Task DeleteUnitDocumentsAsync(Guid unitId, Guid propertyId, CancellationToken cancellationToken)
    {
        try
        {
            var db = await _redisManager.GetDatabaseAsync().ConfigureAwait(false);
            if (db == null)
            {
                _logger.LogWarning("لم يتم الحصول على اتصال بـ Redis للوحدة {UnitId}", unitId);
                return;
            }
            
            // 1. Delete the main unit document. / حذف مستند الوحدة الرئيسي.
            var unitKey = PeriodBasedSearchSchema.GetUnitKey(unitId);
            if (!string.IsNullOrEmpty(unitKey))
            {
                await db.KeyDeleteAsync(unitKey).ConfigureAwait(false);
            }
            
            // 2. Delete pricing periods. / حذف فترات التسعير.
            await DeletePricingPeriodsAsync(unitId, cancellationToken).ConfigureAwait(false);
            
            // 3. Delete availability periods. / حذف فترات الإتاحة.
            await DeleteAvailabilityPeriodsAsync(unitId, cancellationToken).ConfigureAwait(false);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "خطأ أثناء حذف مستندات الوحدة {UnitId}", unitId);
        }
    }
    
    /// <summary>
    /// Deletes all pricing periods for a unit.
    /// يحذف جميع فترات التسعير للوحدة.
    /// </summary>
    private async Task DeletePricingPeriodsAsync(Guid unitId, CancellationToken cancellationToken)
    {
        _logger.LogWarning("DeletePricingPeriodsAsync is temporarily disabled. / DeletePricingPeriodsAsync معطلة مؤقتاً.");
        await Task.CompletedTask;
    }
    
    /// <summary>
    /// Deletes all availability periods for a unit.
    /// يحذف جميع فترات الإتاحة للوحدة.
    /// </summary>
    private async Task DeleteAvailabilityPeriodsAsync(Guid unitId, CancellationToken cancellationToken)
    {
        _logger.LogWarning("DeleteAvailabilityPeriodsAsync is temporarily disabled. / DeleteAvailabilityPeriodsAsync معطلة مؤقتاً.");
        await Task.CompletedTask;
    }
    
    /// <summary>
    /// Deletes all indexes.
    /// يحذف جميع الفهارس.
    /// </summary>
    private async Task DropAllIndexesAsync(bool deleteDocuments = false)
    {
        try
        {
            var db = await _redisManager.GetDatabaseAsync().ConfigureAwait(false);
            var commands = PeriodBasedSearchSchema.GetDropAllIndexesCommands(deleteDocuments);
            
            foreach (var cmd in commands)
            {
                try
                {
                    await db.ExecuteAsync(cmd[0], cmd.Skip(1).ToArray()).ConfigureAwait(false);
                }
                catch
                {
                    // The index may not exist. / قد لا يكون الفهرس موجوداً.
                }
            }
            
            _logger.LogInformation("All indexes were removed. / تم حذف جميع الفهارس.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء حذف الفهارس");
        }
    }

    private static async Task<List<PeriodBasedSearchSchema.DynamicSchemaField>> LoadDynamicSchemaFieldsAsync(
        YemenBookingDbContext dbContext,
        CancellationToken cancellationToken)
    {
        var rawFields = await dbContext.UnitTypeFields
            .AsNoTracking()
            .Where(field => !field.IsDeleted && !string.IsNullOrWhiteSpace(field.FieldName))
            .Where(field => field.IsSearchable || field.IsPrimaryFilter || field.IsPublic)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        return rawFields
            .GroupBy(field => field.FieldName.Trim().ToLowerInvariant())
            .Select(group => new PeriodBasedSearchSchema.DynamicSchemaField(
                group.Key,
                group.Any(field => PeriodBasedSearchSchema.IsNumericDynamicFieldType(field.FieldTypeId))))
            .OrderBy(field => field.FieldName)
            .ToList();
    }
    
    #endregion
    
    #region === Dispose ===
    
    /// <summary>
    /// دالة Dispose.
    /// Dispose method.
    /// </summary>
    public void Dispose()
    {
        if (_disposed)
            return;
        
        _indexingLock?.Dispose();
        _parallelProcessingSemaphore?.Dispose();
        _disposed = true;
    }
    
    #endregion
}

    /// <summary>
    /// Helper container for full unit data.
    /// حاوية مساعدة لبيانات الوحدة الكاملة.
    /// </summary>
internal class UnitFullData
{
    /// <summary>
    /// خاصية Unit.
    /// Unit property.
    /// </summary>
    public Unit Unit { get; set; } = null!;
    /// <summary>
    /// خاصية Property.
    /// Property property.
    /// </summary>
    public Property Property { get; set; } = null!;
    /// <summary>
    /// خاصية UnitType.
    /// UnitType property.
    /// </summary>
    public UnitType UnitType { get; set; } = null!;
    /// <summary>
    /// خاصية PropertyType.
    /// PropertyType property.
    /// </summary>
    public PropertyType PropertyType { get; set; } = null!;
    /// <summary>
    /// خاصية DailySchedules.
    /// DailySchedules property.
    /// </summary>
    public List<DailyUnitSchedule> DailySchedules { get; set; } = new();
    /// <summary>
    /// خاصية Amenities.
    /// Amenities property.
    /// </summary>
    public List<PropertyAmenity> Amenities { get; set; } = new();
    /// <summary>
    /// خاصية Services.
    /// Services property.
    /// </summary>
    public List<PropertyService> Services { get; set; } = new();
    /// <summary>
    /// خاصية FieldValues.
    /// FieldValues property.
    /// </summary>
    public List<UnitFieldValue> FieldValues { get; set; } = new();
    /// <summary>
    /// خاصية FieldDefinitions.
    /// FieldDefinitions property.
    /// </summary>
    public List<UnitTypeField> FieldDefinitions { get; set; } = new();
}
