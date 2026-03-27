using System;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Xunit;
using Xunit.Abstractions;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Core.Indexing.Models;
using YemenBooking.Infrastructure.Data.Context;
using YemenBooking.Infrastructure.Postgres.Indexing;

namespace YemenBooking.Tests.SearchAndFiltering;

/// <summary>
/// اختبارات تشخيصية لمحرك البحث
/// </summary>
public class SearchEngineDiagnosticTests : IAsyncLifetime
{
    /// <summary>
    /// حقل _output.
    /// _output field.
    /// </summary>
    private readonly ITestOutputHelper _output;
    /// <summary>
    /// حقل _dbContext.
    /// _dbContext field.
    /// </summary>
    private YemenBookingDbContext _dbContext = null!;
    /// <summary>
    /// حقل _searchEngine.
    /// _searchEngine field.
    /// </summary>
    private IUnitSearchEngine _searchEngine = null!;
    /// <summary>
    /// حقل _serviceProvider.
    /// _serviceProvider field.
    /// </summary>
    private IServiceProvider _serviceProvider = null!;
    
    /// <summary>
    /// منشئ SearchEngineDiagnosticTests.
    /// SearchEngineDiagnosticTests constructor.
    /// </summary>
    public SearchEngineDiagnosticTests(ITestOutputHelper output)
    {
        _output = output ?? throw new ArgumentNullException(nameof(output));
    }
    
    /// <summary>
    /// دالة InitializeAsync.
    /// InitializeAsync method.
    /// </summary>
    public async Task InitializeAsync()
    {
        var services = new ServiceCollection();
        
        services.AddDbContext<YemenBookingDbContext>(options =>
            options.UseNpgsql(
                "Host=localhost;Database=YemenBookingDb;Username=postgres;Password=postgres"
            ));
        
        services.AddMemoryCache();
        services.AddLogging(builder => 
        {
            builder.AddConsole();
            builder.SetMinimumLevel(LogLevel.Debug); // تفعيل Debug logs
        });
        services.AddScoped<IUnitSearchEngine, PostgresUnitSearchEngine>();
        
        _serviceProvider = services.BuildServiceProvider();
        _dbContext = _serviceProvider.GetRequiredService<YemenBookingDbContext>();
        _searchEngine = _serviceProvider.GetRequiredService<IUnitSearchEngine>();
        
        await _dbContext.Database.MigrateAsync();
    }
    
    /// <summary>
    /// دالة DisposeAsync.
    /// DisposeAsync method.
    /// </summary>
    public async Task DisposeAsync()
    {
        if (_dbContext != null)
        {
            await _dbContext.DisposeAsync();
        }
        
        if (_serviceProvider != null && _serviceProvider is IDisposable disposable)
        {
            disposable.Dispose();
        }
    }
    
    /// <summary>
    /// دالة SearchEngine_Test01_BasicSearch_NoFilters.
    /// SearchEngine_Test01_BasicSearch_NoFilters method.
    /// </summary>
    [Fact]
    public async Task SearchEngine_Test01_BasicSearch_NoFilters()
    {
        _output.WriteLine("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        _output.WriteLine("🔍 اختبار محرك البحث: بحث بسيط بدون فلاتر");
        _output.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        var request = new UnitSearchRequest
        {
            PageNumber = 1,
            PageSize = 10
        };
        
        var result = await _searchEngine.SearchUnitsAsync(request);
        
        _output.WriteLine($"✅ النتائج: {result.Units.Count} وحدة");
        _output.WriteLine($"📊 العدد الإجمالي: {result.TotalCount}");
        
        foreach (var unit in result.Units)
        {
            _output.WriteLine($"   - {unit.UnitName} في {unit.PropertyName} ({unit.City})");
        }
    }
    
    /// <summary>
    /// دالة SearchEngine_Test02_SearchWithCity_Sanaa.
    /// SearchEngine_Test02_SearchWithCity_Sanaa method.
    /// </summary>
    [Fact]
    public async Task SearchEngine_Test02_SearchWithCity_Sanaa()
    {
        _output.WriteLine("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        _output.WriteLine("🔍 اختبار محرك البحث: فلتر المدينة - صنعاء");
        _output.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        var request = new UnitSearchRequest
        {
            City = "صنعاء",
            PageNumber = 1,
            PageSize = 100
        };
        
        _output.WriteLine($"📍 البحث عن: {request.City}");
        
        var result = await _searchEngine.SearchUnitsAsync(request);
        
        _output.WriteLine($"✅ النتائج: {result.Units.Count} وحدة");
        _output.WriteLine($"📊 العدد الإجمالي: {result.TotalCount}");
        _output.WriteLine($"⏱️ وقت البحث: {result.SearchTimeMs} ms");
        
        if (result.Units.Count > 0)
        {
            _output.WriteLine($"\n📋 عينة من النتائج:");
            foreach (var unit in result.Units.Take(10))
            {
                _output.WriteLine($"   - {unit.UnitName}");
                _output.WriteLine($"     • العقار: {unit.PropertyName}");
                _output.WriteLine($"     • المدينة: {unit.City}");
                _output.WriteLine($"     • السعر: {unit.BasePrice} {unit.Currency}");
            }
        }
        else
        {
            _output.WriteLine("\n⚠️ لا توجد نتائج!");
            _output.WriteLine("📝 سأتحقق من البيانات مباشرة في قاعدة البيانات...");
            
            var directUnits = await _dbContext.Units
                .Include(u => u.Property)
                .Where(u => u.Property.IsApproved && u.Property.City == "صنعاء")
                .Take(5)
                .ToListAsync();
            
            _output.WriteLine($"\n✅ الاستعلام المباشر: {directUnits.Count} وحدات");
            foreach (var unit in directUnits)
            {
                _output.WriteLine($"   - {unit.Name} في {unit.Property.Name} ({unit.Property.City})");
            }
        }
    }
    
    /// <summary>
    /// دالة SearchEngine_Test03_AllCities.
    /// SearchEngine_Test03_AllCities method.
    /// </summary>
    [Fact]
    public async Task SearchEngine_Test03_AllCities()
    {
        _output.WriteLine("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        _output.WriteLine("🔍 اختبار محرك البحث: اختبار جميع المدن");
        _output.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        var cities = new[] { "صنعاء", "عدن", "تعز" };
        
        foreach (var city in cities)
        {
            var request = new UnitSearchRequest
            {
                City = city,
                PageNumber = 1,
                PageSize = 100
            };
            
            var result = await _searchEngine.SearchUnitsAsync(request);
            
            _output.WriteLine($"📍 {city}: {result.Units.Count} وحدة (إجمالي: {result.TotalCount})");
        }
    }
}
