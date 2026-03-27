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
/// فئة DiagnosticTest2.
/// DiagnosticTest2 class.
/// </summary>
public class DiagnosticTest2 : IAsyncLifetime
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
    /// منشئ DiagnosticTest2.
    /// DiagnosticTest2 constructor.
    /// </summary>
    public DiagnosticTest2(ITestOutputHelper output)
    {
        _output = output;
    }
    
    /// <summary>
    /// دالة InitializeAsync.
    /// InitializeAsync method.
    /// </summary>
    public async Task InitializeAsync()
    {
        var services = new ServiceCollection();
        services.AddDbContext<YemenBookingDbContext>(options =>
            options.UseNpgsql("Host=localhost;Database=YemenBookingDb;Username=postgres;Password=postgres"));
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
        if (_dbContext != null) await _dbContext.DisposeAsync();
        if (_serviceProvider != null && _serviceProvider is IDisposable disposable) disposable.Dispose();
    }
    
    /// <summary>
    /// دالة Test_ProjectionWithoutDisplayFields.
    /// Test_ProjectionWithoutDisplayFields method.
    /// </summary>
    [Fact]
    public async Task Test_ProjectionWithoutDisplayFields()
    {
        _output.WriteLine("Testing projection WITHOUT DisplayFields...");
        
        try
        {
            var results = await _dbContext.Units
                .AsNoTracking()
                .Include(u => u.Property)
                .Where(u => u.Property.IsApproved)
                .Take(5)
                .Select(u => new
                {
                    UnitId = u.Id,
                    UnitName = u.Name,
                    PropertyName = u.Property.Name,
                    City = u.Property.City
                })
                .ToListAsync();
            
            _output.WriteLine($"✅ Results WITHOUT DisplayFields: {results.Count}");
            foreach (var r in results)
            {
                _output.WriteLine($"  - {r.UnitName} in {r.PropertyName} ({r.City})");
            }
        }
        catch (Exception ex)
        {
            _output.WriteLine($"❌ ERROR: {ex.Message}");
        }
    }
    
    /// <summary>
    /// دالة Test_ProjectionWithDisplayFields.
    /// Test_ProjectionWithDisplayFields method.
    /// </summary>
    [Fact]
    public async Task Test_ProjectionWithDisplayFields()
    {
        _output.WriteLine("Testing projection WITH DisplayFields...");
        
        try
        {
            var results = await _dbContext.Units
                .AsNoTracking()
                .Include(u => u.Property)
                .Where(u => u.Property.IsApproved)
                .Take(5)
                .Select(u => new
                {
                    UnitId = u.Id,
                    UnitName = u.Name,
                    PropertyName = u.Property.Name,
                    City = u.Property.City,
                    DisplayFields = _dbContext.UnitFieldValues
                        .Where(fv => fv.UnitId == u.Id && fv.UnitTypeField.ShowInCards)
                        .Take(5)
                        .ToDictionary(
                            fv => fv.UnitTypeField.DisplayName ?? fv.UnitTypeField.FieldName ?? "",
                            fv => fv.FieldValue ?? ""
                        )
                })
                .ToListAsync();
            
            _output.WriteLine($"✅ Results WITH DisplayFields: {results.Count}");
            foreach (var r in results)
            {
                _output.WriteLine($"  - {r.UnitName}: {r.DisplayFields.Count} fields");
            }
        }
        catch (Exception ex)
        {
            _output.WriteLine($"❌ ERROR: {ex.Message}");
            _output.WriteLine($"Stack: {ex.StackTrace}");
            if (ex.InnerException != null)
            {
                _output.WriteLine($"Inner: {ex.InnerException.Message}");
            }
        }
    }
    
    /// <summary>
    /// دالة Test_DirectQueryUnitFieldValues.
    /// Test_DirectQueryUnitFieldValues method.
    /// </summary>
    [Fact]
    public async Task Test_DirectQueryUnitFieldValues()
    {
        _output.WriteLine("Testing direct query to UnitFieldValues...");
        
        try
        {
            var units = await _dbContext.Units
                .Where(u => u.Property.IsApproved)
                .Take(3)
                .Select(u => u.Id)
                .ToListAsync();
            
            _output.WriteLine($"Units count: {units.Count}");
            
            foreach (var unitId in units)
            {
                var fieldValues = await _dbContext.UnitFieldValues
                    .Include(fv => fv.UnitTypeField)
                    .Where(fv => fv.UnitId == unitId)
                    .ToListAsync();
                
                _output.WriteLine($"Unit {unitId}: {fieldValues.Count} field values");
                foreach (var fv in fieldValues)
                {
                    _output.WriteLine($"  - Field: {fv.UnitTypeField.FieldName}, ShowInCards: {fv.UnitTypeField.ShowInCards}, Value: {fv.FieldValue}");
                }
            }
        }
        catch (Exception ex)
        {
            _output.WriteLine($"❌ ERROR: {ex.Message}");
        }
    }
}
