using YemenBooking.Api.Extensions;
using YemenBooking.Api.Services;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Mappings;
using YemenBooking.Core.Settings;
using YemenBooking.Infrastructure;
using YemenBooking.Infrastructure.Configuration;
using YemenBooking.Infrastructure.Data;
using YemenBooking.Infrastructure.Data.Context;
using YemenBooking.Infrastructure.Data.Configurations.Indexes;
using YemenBooking.Infrastructure.Data.Initialization;
using YemenBooking.Infrastructure.Dapper;
// using YemenBooking.Infrastructure.Migrations;
using YemenBooking.Infrastructure.Services;
using YemenBooking.Infrastructure.Settings;
using YemenBooking.Infrastructure.Extensions; // ✅ Extension Methods للتسجيل
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
// using Microsoft.Data.Sqlite;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using System.Data;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using AutoMapper;
using Microsoft.AspNetCore.Mvc.ApplicationModels;
using YemenBooking.Api.Transformers;
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.AspNetCore.Hosting;
using System.IO;
using YemenBooking.Infrastructure.Redis.Configuration;
using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Http;
using YemenBooking.Application.Features.Properties.Queries.GetPropertyDetails;
using YemenBooking.Application.Features.Payments.Services;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Application.Infrastructure.Services;
using YemenBooking.Application.Infrastructure.Services.Wallets;
using YemenBooking.Infrastructure.Services.Wallets;
using YemenBooking.Application.Features.Units.Services;
using YemenBooking.Application.Features.Notifications.Services;
using Microsoft.AspNetCore.RateLimiting;
using System.Threading.RateLimiting;
using System.Security.Claims;
using YemenBooking.Api.Services.AiAssistant;
using YemenBooking.Api.Settings;

var builder = WebApplication.CreateBuilder(args);

// Optional local secrets file for non-committed sensitive settings
builder.Configuration.AddJsonFile("appsettings.secrets.json", optional: true, reloadOnChange: true);

// If ASPNETCORE_URLS is provided, force Kestrel to use it
var urlsEnv = Environment.GetEnvironmentVariable("ASPNETCORE_URLS");
if (!string.IsNullOrWhiteSpace(urlsEnv))
{
    builder.WebHost.UseUrls(urlsEnv);
}

// In Development, bind to port 5000 ONLY if no ASPNETCORE_URLS or URLs are configured
if (builder.Environment.IsDevelopment())
{
    var urlsConfigured = !string.IsNullOrWhiteSpace(urlsEnv) || builder.Configuration.GetValue<string>("urls") is { Length: > 0 };
    if (!urlsConfigured)
    {
        builder.WebHost.ConfigureKestrel(options =>
        {
            options.ListenAnyIP(5000);
        });
    }
}

// WebSocket chat disabled: using FCM for real-time notifications

// إضافة خدمات Dapper
builder.Services.AddDapperRepository(builder.Configuration);

// Add services to the container.
// Configuring Swagger/OpenAPI with JWT security
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "YemenBooking API",
        Version = "v1",
        Description = "وثائق واجهة برمجة تطبيقات YemenBooking"
    });
    // تعريف أمان JWT
    options.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Description = "أدخل 'Bearer ' متبوعًا برمز JWT"
    });
    options.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
    // تضمين تعليقات XML
    var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = System.IO.Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (System.IO.File.Exists(xmlPath))
    {
        options.IncludeXmlComments(xmlPath);
    }

    // استخدام الاسم الكامل للنوع كمُعرّف للمخطط لمنع التعارضات بين الأنواع المتشابهة الاسم
    options.CustomSchemaIds(type => (type.FullName ?? type.Name).Replace('+', '.'));

    // تمكين دعم رفع الملفات عبر فلتر مخصص
    options.OperationFilter<YemenBooking.Api.Swagger.SwaggerFileOperationFilter>();
});

// إضافة MediatR مع معالجات الأوامر
builder.Services.AddMediatR(cfg => {
    cfg.RegisterServicesFromAssembly(typeof(GetPropertyDetailsQueryHandler).Assembly);
});

// إضافة AutoMapper مع تقييد البحث على مجلد Mappings في طبقة Application
builder.Services.AddAutoMapper(
    cfg => cfg.AddMaps(typeof(QueryMappingProfile).Assembly),
    typeof(QueryMappingProfile).Assembly);

// إضافة خدمات المشروع - تعطيل مؤقتاً لإنشاء migrations
// builder.Services.AddYemenBookingServices();
// إضافة التخزين المؤقت في الذاكرة لحفظ الفهارس
builder.Services.AddMemoryCache();

// Rate limiting: partition by authenticated user when available,
// fallback to forwarded/client IP. Audit logs endpoint gets a higher
// bucket to support infinite scrolling without 429 bursts.
builder.Services.AddRateLimiter(options =>
{
    options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(httpContext =>
    {
        var userId = httpContext.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value
            ?? httpContext.User?.FindFirst("sub")?.Value
            ?? httpContext.User?.FindFirst("userId")?.Value;

        var forwardedFor = httpContext.Request.Headers["X-Forwarded-For"].FirstOrDefault();
        var forwardedIp = string.IsNullOrWhiteSpace(forwardedFor)
            ? null
            : forwardedFor.Split(',')[0].Trim();

        var remoteIp = httpContext.Connection.RemoteIpAddress?.ToString();
        var clientKey = !string.IsNullOrWhiteSpace(userId)
            ? $"user:{userId}"
            : (!string.IsNullOrWhiteSpace(forwardedIp) ? $"ip:{forwardedIp}" : $"ip:{remoteIp ?? "unknown"}");

        var normalizedPath = httpContext.Request.Path.Value?.ToLowerInvariant() ?? string.Empty;
        var isAuditLogsEndpoint = normalizedPath.StartsWith("/api/admin/audit-logs");

        var permitLimit = isAuditLogsEndpoint ? 360 : 120;
        var window = isAuditLogsEndpoint ? TimeSpan.FromMinutes(1) : TimeSpan.FromMinutes(1);
        var queueLimit = isAuditLogsEndpoint ? 30 : 5;

        return RateLimitPartition.GetFixedWindowLimiter(
            $"{clientKey}:{(isAuditLogsEndpoint ? "audit-logs" : "default")}",
            _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = permitLimit,
                Window = window,
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = queueLimit
            }
        );
    });
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
});

// إضافة دعم Controllers مع تحويل PascalCase إلى kebab-case في المسارات ودعم تحويل الـ enum كسلاسل نصية
builder.Services.AddControllers(options =>
{
    options.Conventions.Add(new RouteTokenTransformerConvention(new KebabCaseParameterTransformer()));
    
    // إضافة UtcDateTimeModelBinder لضمان توافق DateTime مع PostgreSQL
    options.ModelBinderProviders.Insert(0, new YemenBooking.Api.Infrastructure.ModelBinders.UtcDateTimeModelBinderProvider());
    
    // إضافة DictionaryModelBinder لربط query parameters بصيغة key[subkey]=value إلى Dictionary<string, string>
    options.ModelBinderProviders.Insert(0, new YemenBooking.Api.Infrastructure.ModelBinders.DictionaryModelBinderProvider());
})
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
        options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
        options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
        options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
        // Preserve all Unicode characters in JSON without escaping
        options.JsonSerializerOptions.Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping;
    });

// Bind file storage settings so URLs are absolute and paths are correct
builder.Services.Configure<YemenBooking.Infrastructure.Settings.FileStorageSettings>(
    builder.Configuration.GetSection("FileStorageSettings"));

// إضافة سياسة CORS للسماح بالاتصالات من الواجهة الأمامية
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
        policy.WithOrigins(
            "http://localhost:5000", // Your actual frontend URL
            "http://localhost:5173", 
            "https://localhost:5173"
        )
        .AllowAnyMethod()
        .AllowAnyHeader()
        .AllowCredentials()
        .SetIsOriginAllowed(origin => true)
        .WithExposedHeaders("*")
    );
});

// تسجيل إعدادات JWT من ملفات التكوين
builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("JwtSettings"));
// تسجيل إعدادات البريد الإلكتروني من ملفات التكوين
builder.Services.Configure<EmailSettings>(builder.Configuration.GetSection("EmailSettings"));
// تسجيل إعدادات تسجيل الدخول الاجتماعي من ملفات التكوين
builder.Services.Configure<SocialAuthSettings>(builder.Configuration.GetSection("SocialAuthSettings"));
// تسجيل إعدادات استراتيجية البحث مع التخفيف التدريجي (Fallback Search)
builder.Services.Configure<YemenBooking.Core.Indexing.Options.FallbackSearchOptions>(
    builder.Configuration.GetSection("FallbackSearchSettings"));
// تسجيل إعدادات حماية البحث من الطلبات الخطيرة (Search Safe Guards)
builder.Services.Configure<YemenBooking.Core.Indexing.Options.SearchSafeGuardOptions>(
    builder.Configuration.GetSection("SearchSafeGuards"));
// تسجيل إعدادات Groq للمساعد الذكي
builder.Services.Configure<GroqAiSettings>(
    builder.Configuration.GetSection("Groq"));

// إعداد المصادقة باستخدام JWT
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(options =>
{
    var jwtSettings = builder.Configuration.GetSection("JwtSettings").Get<JwtSettings>();
    var hasSecret = !string.IsNullOrWhiteSpace(jwtSettings?.Secret);
    options.RequireHttpsMetadata = false; // Changed to false for development
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = hasSecret,
        ValidIssuer = jwtSettings?.Issuer,
        ValidateAudience = hasSecret,
        ValidAudience = jwtSettings?.Audience,
        ValidateLifetime = hasSecret,
        IssuerSigningKey = hasSecret ? new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings!.Secret)) : null,
        ValidateIssuerSigningKey = hasSecret,
        ClockSkew = TimeSpan.Zero
    };
    // Make sure expired tokens yield a 401 with a clear payload
    options.Events = new JwtBearerEvents
    {
        OnAuthenticationFailed = context =>
        {
            if (context.Exception is SecurityTokenExpiredException)
            {
                context.NoResult();
                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                context.Response.ContentType = "application/json";
                var payload = JsonSerializer.Serialize(new { success = false, message = "Token expired" });
                return context.Response.WriteAsync(payload);
            }
            return Task.CompletedTask;
        },
        OnChallenge = context =>
        {
            // Suppress default WWW-Authenticate header body
            context.HandleResponse();
            if (!context.Response.HasStarted)
            {
                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                context.Response.ContentType = "application/json";
                var payload = JsonSerializer.Serialize(new { success = false, message = "Unauthorized" });
                return context.Response.WriteAsync(payload);
            }
            return Task.CompletedTask;
        }
    };
});

// إضافة التفويض
builder.Services.AddAuthorization();

// Do not stop the host when a BackgroundService throws; log and continue
builder.Services.Configure<HostOptions>(o =>
{
    o.BackgroundServiceExceptionBehavior = BackgroundServiceExceptionBehavior.Ignore;
});

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// إعداد DbContext لاستخدام PostgreSQL مع Connection Pooling للأداء الأمثل
// Configure DbContext with Connection Pooling for optimal performance
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ✅ استخدام DbContextPool بدلاً من DbContext العادي للحصول على أداء أفضل
// Using DbContextPool instead of regular DbContext for better performance
// - يعيد استخدام نفس الـ DbContext بدلاً من إنشاء واحد جديد في كل طلب
// - يقلل استهلاك الذاكرة وتحسين الأداء خاصة مع الطلبات المتزامنة الكثيرة
// - poolSize: 128 = عدد الاتصالات المخزنة مسبقاً (يمكن تعديله حسب الحاجة)
builder.Services.AddDbContextPool<YemenBookingDbContext>(options =>
{
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection"), npgsqlOptions =>
    {
        // ✅ تفعيل إعادة المحاولة عند فشل الاتصال (Retry on Failure)
        // Enable automatic retry on transient failures
        npgsqlOptions.EnableRetryOnFailure(
            maxRetryCount: 3,              // عدد المحاولات: 3
            maxRetryDelay: TimeSpan.FromSeconds(5), // أقصى وقت انتظار بين المحاولات: 5 ثوانٍ
            errorCodesToAdd: null);        // استخدام الأخطاء الافتراضية
        
        // ✅ تحديد Timeout للأوامر (Command Timeout)
        // Set command timeout to 300 seconds for long operations
        npgsqlOptions.CommandTimeout(300);  // انتظار أطول للعمليات الثقيلة
    });
    
    // ✅ تجاهل تحذيرات مفاتيح القيم الافتراضية
    // Ignore model validation key default value warnings
    options.ConfigureWarnings(w => w.Ignore(RelationalEventId.ModelValidationKeyDefaultValueWarning));
    
    #if DEBUG
    // ✅ في بيئة التطوير فقط: تفعيل البيانات الحساسة في Logs
    // In development only: Enable sensitive data logging
    options.EnableSensitiveDataLogging();
    
    // ✅ في بيئة التطوير فقط: تفعيل رسائل الخطأ التفصيلية
    // In development only: Enable detailed error messages
    options.EnableDetailedErrors();
    #endif
}, poolSize: 128); // حجم البركة = 128 اتصال (يمكن تعديله حسب الحاجة)

// إضافة HttpContextAccessor لاستخدامه في CurrentUserService
builder.Services.AddHttpContextAccessor();

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🎯 تسجيل جميع Repositories والخدمات بشكل احترافي ومنظم
// Professional and organized registration of all repositories and services
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// تسجيل جميع الـRepositories (IUserRepository, IPropertyRepository, etc.)
builder.Services.AddRepositories();

// تسجيل جميع الـApplication Services (IEmailService, IAuthenticationService, etc.)
builder.Services.AddApplicationServices();

// تسجيل خدمة مقارنة الفلاتر (مطلوبة لمحرك البحث)
builder.Services.AddScoped<PropertyFilterComparisonService>();

// إضافة HttpClient للخدمات التي تحتاجه
builder.Services.AddHttpClient<IGeolocationService, GeolocationService>();

// خدمات المحافظ الإلكترونية المتكاملة
// محفظة سبأ كاش عبر YottaPay
builder.Services.AddHttpClient<ISabaCashWalletService, SabaCashWalletService>();
// محفظة جوالي (JwaliWallet) عبر PAYWA / PAYAG
builder.Services.AddHttpClient<IJwaliWalletService, JwaliWalletService>();
// محفظة فلوسك (Flosk) عبر Floosak Online Payment API
builder.Services.AddHttpClient<IFloskWalletService, FloskWalletService>();
// خدمة المساعد الذكي (Groq)
builder.Services.AddHttpClient<IAiAssistantService, GroqAiAssistantService>((sp, client) =>
{
    var settings = sp.GetRequiredService<Microsoft.Extensions.Options.IOptions<GroqAiSettings>>().Value;
    var baseUrl = string.IsNullOrWhiteSpace(settings.BaseUrl) ? "https://api.groq.com" : settings.BaseUrl.Trim();
    if (baseUrl.EndsWith('/'))
    {
        baseUrl = baseUrl[..^1];
    }

    client.BaseAddress = new Uri(baseUrl, UriKind.Absolute);
    client.Timeout = TimeSpan.FromSeconds(Math.Clamp(settings.HttpTimeoutSeconds, 60, 3600));
});

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// تسجيل خدمات استراتيجية البحث مع التخفيف التدريجي (Fallback Search)
// Register Fallback Search Strategy Services
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
builder.Services.AddScoped<ISearchRelaxationService, YemenBooking.Infrastructure.Services.SearchRelaxationService>();
builder.Services.AddScoped<YemenBooking.Infrastructure.Services.SearchMessageGenerator>();

// تسجيل خدمة الفهرسة باستخدام LiteDB
// builder.Services.AddSingleton<YemenBooking.Infrastructure.Indexing.Services.ILiteDbWriteQueue>(provider =>
// {
//     var env = provider.GetRequiredService<IWebHostEnvironment>();
//     var dbPath = Path.Combine(env.ContentRootPath, "Data", "PropertyIndex.db");
//     Directory.CreateDirectory(Path.GetDirectoryName(dbPath)!);
//     return new YemenBooking.Infrastructure.Indexing.Services.QueuedLiteDbService(
//         dbPath,
//         provider.GetRequiredService<ILogger<YemenBooking.Infrastructure.Indexing.Services.QueuedLiteDbService>>()
//     );
// });

// builder.Services.AddHostedService(provider => (YemenBooking.Infrastructure.Indexing.Services.QueuedLiteDbService)provider.GetRequiredService<YemenBooking.Infrastructure.Indexing.Services.ILiteDbWriteQueue>());

// إشغّل مرسل الإشعارات المجدولة
builder.Services.AddHostedService<ScheduledNotificationsDispatcher>();

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// تسجيل محرك البحث والفهرسة (Redis أو PostgreSQL)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// يتم التحكم من appsettings.json → SearchEngine:Provider
// القيم المسموحة: "Redis", "Postgres", "Auto"
builder.Services.AddSearchEngine(builder.Configuration);
builder.Services.AddDomainEventsForIndexing();
builder.Services.AddDatabaseIndexInitialization();

// IMPORTANT: IIndexingService depends on scoped repositories/services, so register it as Scoped
// builder.Services.AddScoped<IIndexingService>(provider =>
// {
//     var env = provider.GetRequiredService<IWebHostEnvironment>();
//     var dbPath = Path.Combine(env.ContentRootPath, "Data", "PropertyIndex.db");
//     Directory.CreateDirectory(Path.GetDirectoryName(dbPath)!);
    //  return new YemenBooking.Infrastructure.Indexing.Services.LiteDbIndexingService(
    //     dbPath,
    //     provider.GetRequiredService<YemenBooking.Core.Interfaces.Repositories.IPropertyRepository>(),
    //     provider.GetRequiredService<YemenBooking.Core.Interfaces.Repositories.IUnitRepository>(),
    //     provider.GetRequiredService<IAvailabilityService>(),
    //     provider.GetRequiredService<IPricingService>(),
    //     provider.GetRequiredService<IMemoryCache>(),
    //     // provider.GetRequiredService<ILogger<YemenBooking.Infrastructure.Indexing.Services.LiteDbIndexingService>>(),
    //     provider.GetRequiredService<YemenBooking.Infrastructure.Indexing.Services.ILiteDbWriteQueue>()
    // );
// });

var app = builder.Build();

// التأكد من وجود الإجراءات المخزنة عند بدء التطبيق
using (var scope = app.Services.CreateScope())
{
    var logger = scope.ServiceProvider.GetRequiredService<ILoggerFactory>().CreateLogger("Startup");
    try
    {
        var connection = scope.ServiceProvider.GetRequiredService<IDbConnection>();
        connection.Open();
        StoredProceduresInitializer.EnsureAdvancedSearchProc(connection);
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Failed to ensure stored procedures on startup");
    }
}

// تطبيق المهاجرات وتشغيل البذور عند بدء التشغيل
using (var scope = app.Services.CreateScope())
{
    var logger = scope.ServiceProvider.GetRequiredService<ILoggerFactory>().CreateLogger("Startup");
    try
    {
        var db = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // ✅ تهيئة قاعدة البيانات (Migrations + SQL Scripts)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        var dbLogger = scope.ServiceProvider.GetRequiredService<ILogger<DatabaseInitializer>>();
        var dbInitializer = new DatabaseInitializer(db, dbLogger);
        await dbInitializer.InitializeAsync();

        var seedLogger = scope.ServiceProvider.GetRequiredService<ILogger<DataSeedingService>>();
        var seeder = new DataSeedingService(db, seedLogger);
        await seeder.SeedAsync();
        // Ensure default system notification channels exist
        var channelService = scope.ServiceProvider.GetRequiredService<INotificationChannelService>();
        await channelService.CreateDefaultSystemChannelsAsync();
        logger.LogInformation("Database migrated and seeded successfully.");
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Failed to migrate and seed database on startup");
        // لا نرمي الاستثناء لكي لا يمنع تشغيل التطبيق في بيئات التطوير
    }
}

// استخدام امتداد لتكوين كافة middleware الخاصة بالتطبيق
app.UseYemenBookingMiddlewares();

// Apply Rate Limiter
app.UseRateLimiter();

// بناء/إعادة بناء فهرس LiteDB بعد بدء التطبيق لضمان تشغيل Hosted Services (طابور الكتابة)
app.Lifetime.ApplicationStarted.Register(() =>
{
    _ = Task.Run(async () =>
    {
        using var scope = app.Services.CreateScope();
        var indexService = scope.ServiceProvider.GetRequiredService<IIndexingService>();
        try
        {
            await indexService.RebuildIndexAsync(CancellationToken.None);
        }
        catch (Exception ex)
        {
            app.Logger.LogError(ex, "خطأ في بناء الفهرس الأولي");
        }
    });
});

// Initialize Firebase Admin SDK
try
{
    if (FirebaseApp.DefaultInstance == null)
    {
        GoogleCredential credential;
        var credentialsPath = builder.Configuration["Firebase:CredentialsPath"]; // file path
        var credentialsJson = builder.Configuration["Firebase:CredentialsJson"]; // raw JSON (appsettings or env)
        var credentialsBase64 = builder.Configuration["Firebase:CredentialsBase64"]; // base64-encoded JSON (env-friendly)

        if (!string.IsNullOrWhiteSpace(credentialsPath) && System.IO.File.Exists(credentialsPath) && new FileInfo(credentialsPath).Length > 0)
        {
            credential = GoogleCredential.FromFile(credentialsPath);
        }
        else if (!string.IsNullOrWhiteSpace(credentialsJson))
        {
            using var ms = new MemoryStream(System.Text.Encoding.UTF8.GetBytes(credentialsJson));
            credential = GoogleCredential.FromStream(ms);
        }
        else if (!string.IsNullOrWhiteSpace(credentialsBase64))
        {
            var json = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(credentialsBase64));
            using var ms = new MemoryStream(System.Text.Encoding.UTF8.GetBytes(json));
            credential = GoogleCredential.FromStream(ms);
        }
        else if (!string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS_JSON")))
        {
            var envJson = Environment.GetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS_JSON")!;
            using var ms = new MemoryStream(System.Text.Encoding.UTF8.GetBytes(envJson));
            credential = GoogleCredential.FromStream(ms);
        }
        else if (!string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS")))
        {
            // Use standard ADC path if explicitly provided via env var
            credential = GoogleCredential.GetApplicationDefault();
        }
        else
        {
            app.Logger.LogWarning("Firebase credentials not provided or empty. Skipping Firebase Admin initialization until credentials are configured.");
            credential = null!; // won't be used
        }

        if (credential != null)
        {
            FirebaseApp.Create(new AppOptions { Credential = credential });
        }
    }
}
catch (Exception ex)
{
    app.Logger.LogError(ex, "Failed to initialize Firebase Admin SDK. Configure Firebase:CredentialsPath or credentials JSON (Firebase:CredentialsJson / Firebase:CredentialsBase64 / GOOGLE_APPLICATION_CREDENTIALS_JSON).");
}

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
{
    var forecast =  Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast");

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
