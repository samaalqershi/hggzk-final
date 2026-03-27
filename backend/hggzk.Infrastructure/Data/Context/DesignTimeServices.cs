using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.DependencyInjection;

namespace YemenBooking.Infrastructure.Data.Context;

/// <summary>
/// Design-time services hook for EF Core tooling.
/// نقطة ربط خدمات وقت التصميم لأدوات EF Core.
/// </summary>
public class DesignTimeServices : IDesignTimeServices
{
    /// <summary>
    /// Configures EF Core tooling to rely on the design-time DbContext factory.
    /// يهيئ أدوات EF Core للاعتماد على مولد DbContext الخاص بوقت التصميم.
    /// </summary>
    public void ConfigureDesignTimeServices(IServiceCollection services)
    {
        // Tell EF tools to use the DbContext factory instead of application services.
        // إخبار EF Tools باستخدام DbContextFactory بدلاً من خدمات التطبيق.
    }
}
