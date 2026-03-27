using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;
using Xunit.Abstractions;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Tests.SearchAndFiltering;

/// <summary>
/// اختبارات تشخيصية للتحقق من البيانات في قاعدة البيانات
/// </summary>
public class DiagnosticTests : IAsyncLifetime
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
    /// حقل _serviceProvider.
    /// _serviceProvider field.
    /// </summary>
    private IServiceProvider _serviceProvider = null!;
    
    /// <summary>
    /// منشئ DiagnosticTests.
    /// DiagnosticTests constructor.
    /// </summary>
    public DiagnosticTests(ITestOutputHelper output)
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
        
        _serviceProvider = services.BuildServiceProvider();
        _dbContext = _serviceProvider.GetRequiredService<YemenBookingDbContext>();
        
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
    /// دالة Diagnostic01_CheckPropertiesByCity.
    /// Diagnostic01_CheckPropertiesByCity method.
    /// </summary>
    [Fact]
    public async Task Diagnostic01_CheckPropertiesByCity()
    {
        _output.WriteLine("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        _output.WriteLine("🔍 تشخيص 1: فحص العقارات حسب المدينة");
        _output.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        var propertiesByCity = await _dbContext.Properties
            .Where(p => p.IsApproved)
            .GroupBy(p => p.City)
            .Select(g => new { City = g.Key, Count = g.Count() })
            .ToListAsync();
        
        _output.WriteLine($"📊 العقارات حسب المدينة:");
        foreach (var item in propertiesByCity.OrderByDescending(x => x.Count))
        {
            _output.WriteLine($"   - {item.City}: {item.Count} عقارات");
        }
    }
    
    /// <summary>
    /// دالة Diagnostic02_CheckUnitsByCity.
    /// Diagnostic02_CheckUnitsByCity method.
    /// </summary>
    [Fact]
    public async Task Diagnostic02_CheckUnitsByCity()
    {
        _output.WriteLine("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        _output.WriteLine("🔍 تشخيص 2: فحص الوحدات حسب المدينة");
        _output.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        var unitsByCity = await _dbContext.Units
            .Include(u => u.Property)
            .Where(u => u.Property.IsApproved)
            .GroupBy(u => u.Property.City)
            .Select(g => new { City = g.Key, Count = g.Count() })
            .ToListAsync();
        
        _output.WriteLine($"📊 الوحدات حسب المدينة:");
        foreach (var item in unitsByCity.OrderByDescending(x => x.Count))
        {
            _output.WriteLine($"   - {item.City}: {item.Count} وحدة");
        }
    }
    
    /// <summary>
    /// دالة Diagnostic03_CheckSampleProperties.
    /// Diagnostic03_CheckSampleProperties method.
    /// </summary>
    [Fact]
    public async Task Diagnostic03_CheckSampleProperties()
    {
        _output.WriteLine("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        _output.WriteLine("🔍 تشخيص 3: فحص عينة من العقارات");
        _output.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        var properties = await _dbContext.Properties
            .Where(p => p.IsApproved)
            .OrderBy(p => p.City)
            .Take(10)
            .ToListAsync();
        
        _output.WriteLine($"📋 عينة من العقارات:");
        foreach (var prop in properties)
        {
            _output.WriteLine($"   - {prop.Name}");
            _output.WriteLine($"     • المدينة: {prop.City}");
            _output.WriteLine($"     • معتمد: {prop.IsApproved}");
            _output.WriteLine($"     • ID: {prop.Id}");
        }
    }
    
    /// <summary>
    /// دالة Diagnostic04_CheckUnitsBasicQuery.
    /// Diagnostic04_CheckUnitsBasicQuery method.
    /// </summary>
    [Fact]
    public async Task Diagnostic04_CheckUnitsBasicQuery()
    {
        _output.WriteLine("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        _output.WriteLine("🔍 تشخيص 4: استعلام بسيط للوحدات");
        _output.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        var units = await _dbContext.Units
            .Include(u => u.Property)
            .Where(u => u.Property.IsApproved)
            .Take(5)
            .ToListAsync();
        
        _output.WriteLine($"📋 عينة من الوحدات:");
        foreach (var unit in units)
        {
            _output.WriteLine($"   - {unit.Name} في {unit.Property.Name}");
            _output.WriteLine($"     • المدينة: {unit.Property.City}");
            _output.WriteLine($"     • السعة: {unit.MaxCapacity}");
        }
    }
    
    /// <summary>
    /// دالة Diagnostic05_TestCityFilterDirectly.
    /// Diagnostic05_TestCityFilterDirectly method.
    /// </summary>
    [Fact]
    public async Task Diagnostic05_TestCityFilterDirectly()
    {
        _output.WriteLine("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        _output.WriteLine("🔍 تشخيص 5: اختبار فلتر المدينة مباشرة");
        _output.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        var city = "صنعاء";
        _output.WriteLine($"🔎 البحث عن وحدات في: {city}");
        
        var units = await _dbContext.Units
            .Include(u => u.Property)
            .Where(u => u.Property.IsApproved && u.Property.City == city)
            .ToListAsync();
        
        _output.WriteLine($"✅ النتائج: {units.Count} وحدة");
        
        if (units.Any())
        {
            foreach (var unit in units.Take(5))
            {
                _output.WriteLine($"   - {unit.Name}: {unit.Property.City}");
            }
        }
        else
        {
            _output.WriteLine("⚠️ لم يتم العثور على وحدات في صنعاء");
            
            // فحص جميع المدن المتاحة
            var cities = await _dbContext.Properties
                .Where(p => p.IsApproved)
                .Select(p => p.City)
                .Distinct()
                .ToListAsync();
            
            _output.WriteLine($"\n📍 المدن المتاحة:");
            foreach (var c in cities)
            {
                _output.WriteLine($"   - {c}");
            }
        }
    }
}
