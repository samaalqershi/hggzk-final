using System;
using System.Linq;
using System.Threading.Tasks;
using FluentAssertions;
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
/// اختبارات شاملة لفلتر السعر مع دعم العملات المتعددة
/// </summary>
public class PriceFilterMultiCurrencyTests : IAsyncLifetime
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
    /// منشئ PriceFilterMultiCurrencyTests.
    /// PriceFilterMultiCurrencyTests constructor.
    /// </summary>
    public PriceFilterMultiCurrencyTests(ITestOutputHelper output)
    {
        _output = output;
    }
    
    /// <summary>
    /// دالة InitializeAsync.
    /// InitializeAsync method.
    /// </summary>
    public async Task InitializeAsync()
    {
        _output.WriteLine("🔧 تهيئة اختبارات فلتر السعر متعدد العملات...");
        
        var services = new ServiceCollection();
        
        services.AddDbContext<YemenBookingDbContext>(options =>
            options.UseNpgsql("Host=localhost;Database=YemenBookingDb;Username=postgres;Password=postgres"));
        
        services.AddMemoryCache();
        services.AddLogging(builder => builder.AddConsole().SetMinimumLevel(LogLevel.Debug));
        services.AddScoped<IUnitSearchEngine, PostgresUnitSearchEngine>();
        
        _serviceProvider = services.BuildServiceProvider();
        _dbContext = _serviceProvider.GetRequiredService<YemenBookingDbContext>();
        _searchEngine = _serviceProvider.GetRequiredService<IUnitSearchEngine>();
        
        await _dbContext.Database.MigrateAsync();
        
        // عرض معلومات العملات وأسعار الصرف
        var currencies = await _dbContext.Set<Core.Entities.Currency>()
            .Select(c => new { c.Code, c.Name, c.ExchangeRate, c.IsDefault })
            .ToListAsync();
        
        _output.WriteLine("\n💱 العملات المتاحة في النظام:");
        foreach (var currency in currencies)
        {
            var rate = currency.IsDefault ? "1.0 (افتراضية)" : currency.ExchangeRate?.ToString("F6") ?? "N/A";
            _output.WriteLine($"   - {currency.Code} ({currency.Name}): معدل الصرف = {rate}");
        }
        
        _output.WriteLine("✅ تم التهيئة بنجاح\n");
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
    /// دالة Test01_PriceFilter_YER_Currency.
    /// Test01_PriceFilter_YER_Currency method.
    /// </summary>
    [Fact]
    public async Task Test01_PriceFilter_YER_Currency()
    {
        // Arrange
        _output.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        _output.WriteLine("🧪 اختبار 1: فلترة السعر بالريال اليمني (YER)");
        _output.WriteLine("   النطاق: 50,000 - 150,000 YER");
        _output.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        var request = new UnitSearchRequest
        {
            MinPrice = 50000m,
            MaxPrice = 150000m,
            PreferredCurrency = "YER",
            PageNumber = 1,
            PageSize = 100
        };
        
        // Act
        var result = await _searchEngine.SearchUnitsAsync(request);
        
        // Assert
        _output.WriteLine($"\n✅ النتائج: {result.Units.Count} وحدة");
        
        result.Units.Should().NotBeEmpty("يجب أن تكون هناك وحدات في هذا النطاق السعري");
        
        foreach (var unit in result.Units.Take(10))
        {
            _output.WriteLine($"   - {unit.UnitName}: {unit.BasePrice:N2} {unit.Currency}");
            
            // التحقق من أن السعر ضمن النطاق (مع مراعاة العملة)
            if (unit.BasePrice > 0)
            {
                if (unit.Currency == "YER")
                {
                    unit.BasePrice.Should().BeInRange(request.MinPrice.Value, request.MaxPrice.Value,
                        $"السعر {unit.BasePrice} YER يجب أن يكون ضمن النطاق {request.MinPrice}-{request.MaxPrice}");
                }
            }
        }
        
        _output.WriteLine($"\n📊 إجمالي الوحدات المطابقة: {result.TotalCount}");
    }
    
    /// <summary>
    /// دالة Test02_PriceFilter_USD_Currency.
    /// Test02_PriceFilter_USD_Currency method.
    /// </summary>
    [Fact]
    public async Task Test02_PriceFilter_USD_Currency()
    {
        // Arrange
        _output.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        _output.WriteLine("🧪 اختبار 2: فلترة السعر بالدولار (USD)");
        _output.WriteLine("   النطاق: 200 - 600 USD");
        _output.WriteLine("   ملاحظة: سيتم تحويل الأسعار من YER إلى USD حسب سعر الصرف");
        _output.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        // الحصول على سعر الصرف
        var usdRate = await _dbContext.Set<Core.Entities.Currency>()
            .Where(c => c.Code == "USD")
            .Select(c => c.ExchangeRate)
            .FirstOrDefaultAsync();
        
        _output.WriteLine($"\n💱 سعر الصرف: 1 USD = {usdRate:F2} YER");
        _output.WriteLine($"💱 أو: 1 YER = {(1 / usdRate.Value):F6} USD");
        
        var request = new UnitSearchRequest
        {
            MinPrice = 200m,
            MaxPrice = 600m,
            PreferredCurrency = "USD",
            PageNumber = 1,
            PageSize = 100
        };
        
        // Act
        var result = await _searchEngine.SearchUnitsAsync(request);
        
        // Assert
        _output.WriteLine($"\n✅ النتائج: {result.Units.Count} وحدة");
        
        result.Units.Should().NotBeEmpty("يجب أن تكون هناك وحدات في هذا النطاق السعري بالدولار");
        
        foreach (var unit in result.Units.Take(10))
        {
            decimal priceInUSD = unit.Currency == "USD" 
                ? unit.BasePrice 
                : unit.BasePrice / usdRate.Value;
            
            _output.WriteLine($"   - {unit.UnitName}:");
            _output.WriteLine($"     السعر الأصلي: {unit.BasePrice:N2} {unit.Currency}");
            _output.WriteLine($"     السعر بالدولار: {priceInUSD:N2} USD");
            
            // التحقق من أن السعر المُحوّل ضمن النطاق
            if (unit.BasePrice > 0)
            {
                priceInUSD.Should().BeInRange(request.MinPrice.Value, request.MaxPrice.Value,
                    $"السعر {priceInUSD:N2} USD يجب أن يكون ضمن النطاق {request.MinPrice}-{request.MaxPrice}");
            }
        }
        
        _output.WriteLine($"\n📊 إجمالي الوحدات المطابقة: {result.TotalCount}");
    }
    
    /// <summary>
    /// دالة Test03_PriceFilter_CrossCurrency_Conversion.
    /// Test03_PriceFilter_CrossCurrency_Conversion method.
    /// </summary>
    [Fact]
    public async Task Test03_PriceFilter_CrossCurrency_Conversion()
    {
        // Arrange
        _output.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        _output.WriteLine("🧪 اختبار 3: تحويل العملات - نفس النطاق بعملات مختلفة");
        _output.WriteLine("   سنبحث عن نفس الوحدات باستخدام YER و USD ونتأكد من التطابق");
        _output.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        // الحصول على سعر الصرف
        var usdRate = await _dbContext.Set<Core.Entities.Currency>()
            .Where(c => c.Code == "USD")
            .Select(c => c.ExchangeRate)
            .FirstOrDefaultAsync();
        
        var usdToYer = usdRate.Value;
        var yerToUsd = 1 / usdToYer;
        
        _output.WriteLine($"\n💱 سعر الصرف: 1 USD = {usdToYer:F2} YER");
        _output.WriteLine($"💱 أو: 1 YER = {yerToUsd:F6} USD");
        
        // البحث بالريال: 100,000 - 200,000 YER
        var requestYER = new UnitSearchRequest
        {
            MinPrice = 100000m,
            MaxPrice = 200000m,
            PreferredCurrency = "YER",
            PageNumber = 1,
            PageSize = 50
        };
        
        // البحث بالدولار: نفس النطاق محوّل
        var requestUSD = new UnitSearchRequest
        {
            MinPrice = 100000m / usdToYer,  // تحويل إلى دولار
            MaxPrice = 200000m / usdToYer,   // تحويل إلى دولار
            PreferredCurrency = "USD",
            PageNumber = 1,
            PageSize = 50
        };
        
        _output.WriteLine($"\n🔍 البحث بالريال: {requestYER.MinPrice:N0} - {requestYER.MaxPrice:N0} YER");
        _output.WriteLine($"🔍 البحث بالدولار: {requestUSD.MinPrice:N2} - {requestUSD.MaxPrice:N2} USD");
        
        // Act
        var resultYER = await _searchEngine.SearchUnitsAsync(requestYER);
        var resultUSD = await _searchEngine.SearchUnitsAsync(requestUSD);
        
        // Assert
        _output.WriteLine($"\n✅ النتائج بالريال: {resultYER.Units.Count} وحدة");
        _output.WriteLine($"✅ النتائج بالدولار: {resultUSD.Units.Count} وحدة");
        
        // يجب أن يكون عدد النتائج متساوياً (أو قريباً جداً بسبب التقريب)
        var difference = Math.Abs(resultYER.Units.Count - resultUSD.Units.Count);
        difference.Should().BeLessThanOrEqualTo(2, 
            "عدد النتائج يجب أن يكون متطابقاً تقريباً عند البحث بعملات مختلفة لنفس النطاق");
        
        _output.WriteLine($"\n📊 الفرق في عدد النتائج: {difference} وحدة (مقبول ≤ 2)");
        _output.WriteLine("✅ اختبار التحويل بين العملات ناجح!");
    }
    
    /// <summary>
    /// دالة Test04_PriceFilter_ExchangeRateAccuracy.
    /// Test04_PriceFilter_ExchangeRateAccuracy method.
    /// </summary>
    [Fact]
    public async Task Test04_PriceFilter_ExchangeRateAccuracy()
    {
        // Arrange
        _output.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        _output.WriteLine("🧪 اختبار 4: دقة سعر الصرف في الفلترة");
        _output.WriteLine("   نتحقق من أن الوحدات المُرجعة تطابق النطاق السعري بدقة");
        _output.WriteLine("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        
        var usdRate = await _dbContext.Set<Core.Entities.Currency>()
            .Where(c => c.Code == "USD")
            .Select(c => c.ExchangeRate)
            .FirstOrDefaultAsync();
        
        var request = new UnitSearchRequest
        {
            MinPrice = 300m,
            MaxPrice = 500m,
            PreferredCurrency = "USD",
            PageNumber = 1,
            PageSize = 20
        };
        
        _output.WriteLine($"\n💱 سعر الصرف المستخدم: 1 USD = {usdRate:F2} YER");
        _output.WriteLine($"🔍 البحث عن وحدات بنطاق: {request.MinPrice} - {request.MaxPrice} USD");
        
        // Act
        var result = await _searchEngine.SearchUnitsAsync(request);
        
        // Assert
        _output.WriteLine($"\n✅ النتائج: {result.Units.Count} وحدة\n");
        
        int passedCount = 0;
        int totalChecked = 0;
        
        foreach (var unit in result.Units)
        {
            totalChecked++;
            
            // حساب السعر بالدولار
            decimal priceInUSD = unit.Currency == "USD" 
                ? unit.BasePrice 
                : unit.BasePrice / usdRate.Value;
            
            bool isInRange = priceInUSD >= request.MinPrice.Value && 
                           priceInUSD <= request.MaxPrice.Value;
            
            var status = isInRange ? "✅" : "❌";
            
            _output.WriteLine($"{status} {unit.UnitName}:");
            _output.WriteLine($"   السعر: {unit.BasePrice:N2} {unit.Currency} = {priceInUSD:N2} USD");
            _output.WriteLine($"   ضمن النطاق: {isInRange}");
            
            if (isInRange) passedCount++;
        }
        
        var accuracy = totalChecked > 0 ? (passedCount * 100.0 / totalChecked) : 0;
        
        _output.WriteLine($"\n📊 نتائج الدقة:");
        _output.WriteLine($"   - مطابق: {passedCount} / {totalChecked}");
        _output.WriteLine($"   - دقة: {accuracy:F1}%");
        
        // يجب أن تكون الدقة 100% أو قريبة جداً (مع مراعاة التقريب)
        accuracy.Should().BeGreaterThanOrEqualTo(95.0, 
            "يجب أن تكون دقة فلتر السعر 95% على الأقل");
    }
}
