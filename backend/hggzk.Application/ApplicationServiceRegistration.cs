using AutoMapper;
using FluentValidation;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using System.Reflection;
using YemenBooking.Application.Common.Authorization;
using YemenBooking.Application.Common.Behaviors;

namespace YemenBooking.Application;

/// <summary>
/// Registers application-layer services in the dependency injection container.
/// يسجل خدمات طبقة التطبيق داخل حاوية الاعتمادية.
/// </summary>
public static class ApplicationServiceRegistration
{
    /// <summary>
    /// Adds the core application-layer building blocks such as MediatR, AutoMapper, and FluentValidation, with optional pipeline behavior registration.
    /// يضيف مكوّنات طبقة التطبيق الأساسية مثل MediatR وAutoMapper وFluentValidation مع إمكانية تسجيل سلوكيات خط الأنابيب عند الحاجة.
    /// </summary>
    /// <param name="services">The current service collection. حاوية الخدمات الحالية.</param>
    /// <param name="registerPipelineBehaviors">Indicates whether shared MediatR pipeline behaviors should be registered. يحدد ما إذا كان يجب تسجيل سلوكيات MediatR المشتركة.</param>
    /// <returns>The updated service collection. حاوية الخدمات بعد التسجيل.</returns>
    public static IServiceCollection AddApplicationLayer(this IServiceCollection services, bool registerPipelineBehaviors = false)
    {
        services.AddAutoMapper(Assembly.GetExecutingAssembly());
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(Assembly.GetExecutingAssembly()));
        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());

        if (registerPipelineBehaviors)
        {
            services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
            services.AddTransient(typeof(IPipelineBehavior<,>), typeof(LoggingBehavior<,>));
            services.AddTransient(typeof(IPipelineBehavior<,>), typeof(AuthorizationBehavior<,>));
            services.AddTransient(typeof(IPipelineBehavior<,>), typeof(PerformanceBehavior<,>));
        }

        services.AddScoped<PropertyAuthorizationHelper>();

        return services;
    }
}
