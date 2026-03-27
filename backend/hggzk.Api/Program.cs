using YemenBooking.Api.Extensions;
using YemenBooking.Application;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Core.Settings;
using YemenBooking.Infrastructure.Data;
using YemenBooking.Infrastructure.Data.Context;
using YemenBooking.Infrastructure.Data.Initialization;
using YemenBooking.Infrastructure.DependencyInjection;
using YemenBooking.Infrastructure.Dapper;
// using YemenBooking.Infrastructure.Migrations;
using YemenBooking.Infrastructure.Settings;
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
using Microsoft.AspNetCore.Mvc.ApplicationModels;
using YemenBooking.Api.Transformers;
using YemenBooking.Api.JsonConverters;
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.AspNetCore.Hosting;
using System.IO;
using YemenBooking.Infrastructure.Redis.Configuration;
using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Http;
using YemenBooking.Application.Features.Notifications.Services;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using Microsoft.AspNetCore.RateLimiting;
using System.Threading.RateLimiting;
using System.Security.Claims;
using YemenBooking.Api.Services.AiAssistant;
using YemenBooking.Api.Settings;
using Serilog;
using Serilog.Events;
using YemenBooking.Api.Infrastructure.Logging;

var builder = WebApplication.CreateBuilder(args);

// Optional local secrets file for non-committed sensitive settings
builder.Configuration.AddJsonFile("appsettings.secrets.json", optional: true, reloadOnChange: true);

var logsDirectory = Path.Combine(
    builder.Environment.ContentRootPath,
    builder.Configuration["SearchDiagnosticsLogging:LogsDirectory"] ?? "logs");
Directory.CreateDirectory(logsDirectory);

var minimumLevelText = builder.Configuration["SearchDiagnosticsLogging:MinimumLevel"] ?? "Information";
if (!Enum.TryParse(minimumLevelText, ignoreCase: true, out LogEventLevel minimumLevel))
{
    minimumLevel = LogEventLevel.Information;
}

var retainedFileCountLimit = builder.Configuration.GetValue<int?>("SearchDiagnosticsLogging:RetainedFileCountLimit") ?? 14;

builder.Host.UseSerilog((context, services, loggerConfiguration) =>
{
    loggerConfiguration
        .MinimumLevel.Is(minimumLevel)
        .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
        .MinimumLevel.Override("Microsoft.AspNetCore", LogEventLevel.Warning)
        .Enrich.FromLogContext()
        .Enrich.WithProperty("Application", "hggzk.Api")
        .WriteTo.File(
            Path.Combine(logsDirectory, "application-.log"),
            rollingInterval: RollingInterval.Day,
            retainedFileCountLimit: retainedFileCountLimit,
            shared: true,
            outputTemplate:
                "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] {Message:lj} " +
                "{Properties:j}{NewLine}{Exception}")
        .WriteTo.Logger(searchLogger => searchLogger
            .Filter.ByIncludingOnly(logEvent =>
                logEvent.Properties.TryGetValue("SearchDiagnostics", out var value) &&
                value is Serilog.Events.ScalarValue { Value: true })
            .WriteTo.File(
                Path.Combine(logsDirectory, "search-diagnostics-.log"),
                rollingInterval: RollingInterval.Day,
                retainedFileCountLimit: retainedFileCountLimit,
                shared: true,
                outputTemplate:
                    "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] {Message:lj} " +
                    "{Properties:j}{NewLine}{Exception}"));
});

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

// Register Dapper services.
// تسجيل خدمات Dapper.
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
    // Define JWT security for Swagger/OpenAPI.
    // تعريف إعدادات أمان JWT الخاصة بـ Swagger/OpenAPI.
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
    // Include XML comments from both the API and Application layers to enrich Swagger documentation.
    // تضمين تعليقات XML من طبقتي API وApplication لتحسين توثيق Swagger.
    var xmlDocumentationAssemblies = new[]
    {
        System.Reflection.Assembly.GetExecutingAssembly(),
        typeof(ICurrentUserService).Assembly
    };

    foreach (var assembly in xmlDocumentationAssemblies.Distinct())
    {
        var xmlFile = $"{assembly.GetName().Name}.xml";
        var xmlPath = System.IO.Path.Combine(AppContext.BaseDirectory, xmlFile);
        if (System.IO.File.Exists(xmlPath))
        {
            options.IncludeXmlComments(xmlPath);
        }
    }

    // Use the fully qualified type name as the schema identifier to avoid naming collisions.
    // استخدام الاسم الكامل للنوع كمعرّف للمخطط لتجنب التعارض بين الأنواع المتشابهة.
    options.CustomSchemaIds(type => (type.FullName ?? type.Name).Replace('+', '.'));

    // Enable file-upload support through a dedicated Swagger operation filter.
    // تمكين دعم رفع الملفات عبر مرشح Swagger مخصص.
    options.OperationFilter<YemenBooking.Api.Swagger.SwaggerFileOperationFilter>();
});

// Register the Application layer while keeping shared pipeline behaviors disabled for now to avoid changing runtime behavior all at once.
// تسجيل طبقة Application مع الإبقاء على سلوكيات خط الأنابيب المشتركة معطلة حالياً لتجنب تغيير السلوك الحالي دفعة واحدة.
builder.Services.AddApplicationLayer(registerPipelineBehaviors: false);

// Infrastructure registrations are centralized in AddInfrastructure below.
// تم توحيد تسجيلات البنية التحتية في AddInfrastructure بالأسفل.
// Register in-memory caching for transient index and lookup data.
// تسجيل التخزين المؤقت في الذاكرة للفهارس والبيانات المؤقتة.
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

// Register MVC controllers with kebab-case route tokens and string enum serialization.
// تسجيل وحدات التحكم مع تحويل المسارات إلى kebab-case وتحويل قيم enum إلى نصوص.
builder.Services.AddControllers(options =>
{
    options.Conventions.Add(new RouteTokenTransformerConvention(new KebabCaseParameterTransformer()));
    
    // Insert the UTC DateTime binder first to normalize incoming timestamps for PostgreSQL.
    // إدراج UtcDateTimeModelBinder أولاً لتطبيع التواريخ الواردة بما يتوافق مع PostgreSQL.
    options.ModelBinderProviders.Insert(0, new YemenBooking.Api.Infrastructure.ModelBinders.UtcDateTimeModelBinderProvider());
    
    // Insert the dictionary binder to support query strings shaped like key[subkey]=value.
    // إدراج DictionaryModelBinder لدعم معاملات الاستعلام بصيغة key[subkey]=value.
    options.ModelBinderProviders.Insert(0, new YemenBooking.Api.Infrastructure.ModelBinders.DictionaryModelBinderProvider());
})
    .AddJsonOptions(options =>
    {
        // Custom converter for SectionType to ensure values are grid/bigCards/list
        options.JsonSerializerOptions.Converters.Add(new SectionTypeJsonConverter());
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

// Register the frontend CORS policy used by local and deployed clients.
// تسجيل سياسة CORS الخاصة بالواجهة الأمامية محليًا وفي البيئات المنشورة.
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

// Bind JWT settings from configuration.
// ربط إعدادات JWT من ملفات التكوين.
builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("JwtSettings"));
// Bind email settings from configuration.
// ربط إعدادات البريد الإلكتروني من ملفات التكوين.
builder.Services.Configure<EmailSettings>(builder.Configuration.GetSection("EmailSettings"));
// Bind social authentication settings from configuration.
// ربط إعدادات تسجيل الدخول الاجتماعي من ملفات التكوين.
builder.Services.Configure<SocialAuthSettings>(builder.Configuration.GetSection("SocialAuthSettings"));
// Bind fallback-search strategy settings.
// ربط إعدادات استراتيجية البحث مع التخفيف التدريجي.
builder.Services.Configure<YemenBooking.Core.Indexing.Options.FallbackSearchOptions>(
    builder.Configuration.GetSection("FallbackSearchSettings"));
// Bind defensive search guard settings.
// ربط إعدادات حماية البحث من الطلبات الخطيرة.
builder.Services.Configure<YemenBooking.Core.Indexing.Options.SearchSafeGuardOptions>(
    builder.Configuration.GetSection("SearchSafeGuards"));
// Bind Groq AI assistant settings.
// ربط إعدادات Groq الخاصة بالمساعد الذكي.
builder.Services.Configure<GroqAiSettings>(
    builder.Configuration.GetSection("Groq"));

// Configure JWT bearer authentication.
// إعداد المصادقة باستخدام JWT.
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

// Register authorization services.
// تسجيل خدمات التفويض.
builder.Services.AddAuthorization();

// Do not stop the host when a BackgroundService throws; log and continue
builder.Services.Configure<HostOptions>(o =>
{
    o.BackgroundServiceExceptionBehavior = BackgroundServiceExceptionBehavior.Ignore;
});

// Configure DbContext with PostgreSQL connection pooling for optimal performance.
// إعداد DbContext لاستخدام PostgreSQL مع تجميع الاتصالات لتحقيق أداء أفضل.

// Use DbContextPool instead of the regular DbContext registration for better throughput.
// استخدام DbContextPool بدل التسجيل التقليدي لـ DbContext لتحسين الإنتاجية.
// - Reuses pooled DbContext instances instead of creating one per request.
// - يعيد استخدام كائنات DbContext المجمّعة بدل إنشاء كائن جديد لكل طلب.
// - Reduces memory pressure under concurrent workloads.
// - يقلل استهلاك الذاكرة خصوصًا مع الأحمال المتزامنة.
// - poolSize: 128 preallocated pooled slots and can be tuned per environment.
// - قيمة poolSize الحالية 128 ويمكن تعديلها حسب البيئة.
builder.Services.AddDbContextPool<YemenBookingDbContext>(options =>
{
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection"), npgsqlOptions =>
    {
        // Enable automatic retry on transient failures.
        // تفعيل إعادة المحاولة عند فشل الاتصال المؤقت.
        npgsqlOptions.EnableRetryOnFailure(
            maxRetryCount: 3,              // Maximum retry attempts. الحد الأقصى للمحاولات.
            maxRetryDelay: TimeSpan.FromSeconds(5), // Maximum wait between retries. أقصى مدة انتظار بين المحاولات.
            errorCodesToAdd: null);        // Use provider defaults. استخدام أخطاء المزود الافتراضية.
        
        // Set command timeout to 300 seconds for long-running operations.
        // ضبط مهلة تنفيذ الأوامر إلى 300 ثانية للعمليات الطويلة.
        npgsqlOptions.CommandTimeout(300);
    });
    
    // Ignore model validation key default value warnings.
    // تجاهل تحذيرات مفاتيح القيم الافتراضية في التحقق من النموذج.
    options.ConfigureWarnings(w => w.Ignore(RelationalEventId.ModelValidationKeyDefaultValueWarning));
    
    #if DEBUG
    // In development only: enable sensitive data logging.
    // في بيئة التطوير فقط: تفعيل تسجيل البيانات الحساسة.
    options.EnableSensitiveDataLogging();
    
    // In development only: enable detailed error messages.
    // في بيئة التطوير فقط: تفعيل رسائل الخطأ التفصيلية.
    options.EnableDetailedErrors();
    #endif
}, poolSize: 128); // Pool size is 128 by default. حجم البركة الافتراضي هو 128.

// Register HttpContextAccessor for request-scoped services such as CurrentUserService.
// تسجيل HttpContextAccessor للخدمات المعتمدة على سياق الطلب مثل CurrentUserService.
builder.Services.AddHttpContextAccessor();

// Register infrastructure repositories and services through a clear composition root.
// تسجيل مستودعات وخدمات البنية التحتية عبر نقطة تركيب واضحة.

// Register the infrastructure layer through a single composition root.
// تسجيل طبقة البنية التحتية عبر نقطة دخول موحدة.
builder.Services.AddInfrastructure(builder.Configuration);
// Register the Groq-backed AI assistant client.
// تسجيل عميل المساعد الذكي المعتمد على Groq.
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

var app = builder.Build();

app.UseMiddleware<SearchDiagnosticsLoggingMiddleware>();

// Ensure required stored procedures exist during startup.
// التأكد من وجود الإجراءات المخزنة المطلوبة عند بدء التطبيق.
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

// Apply migrations and run data seeding during startup.
// تطبيق المهاجرات وتشغيل البذور عند بدء التشغيل.
using (var scope = app.Services.CreateScope())
{
    var logger = scope.ServiceProvider.GetRequiredService<ILoggerFactory>().CreateLogger("Startup");
    try
    {
        var db = scope.ServiceProvider.GetRequiredService<YemenBookingDbContext>();
        
        // Initialize the database schema and bundled SQL scripts.
        // تهيئة مخطط قاعدة البيانات ونصوص SQL المضمنة.
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
        // Do not rethrow here to avoid blocking local startup during development.
        // عدم إعادة رمي الاستثناء هنا حتى لا يتم تعطيل التشغيل المحلي في بيئات التطوير.
    }
}

// Configure the application middleware pipeline through a dedicated extension.
// تهيئة خط أنابيب الـ middleware عبر امتداد مخصص.
app.UseYemenBookingMiddlewares();

// Apply Rate Limiter
app.UseRateLimiter();

// Trigger a best-effort index rebuild after startup using the active unit indexing engine.
// تشغيل إعادة بناء بأفضل جهد بعد الإقلاع باستخدام محرك فهرسة الوحدات الفعّال.
app.Lifetime.ApplicationStarted.Register(() =>
{
    _ = Task.Run(async () =>
    {
        using var scope = app.Services.CreateScope();
        var indexService = scope.ServiceProvider.GetRequiredService<IUnitIndexingService>();
        try
        {
            await indexService.RebuildAllIndexesAsync(cancellationToken: CancellationToken.None);
        }
        catch (Exception ex)
        {
            app.Logger.LogError(ex, "Failed to rebuild the initial unit indexes during startup.");
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

/// <summary>
/// سجل WeatherForecast.
/// WeatherForecast record.
/// </summary>
record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    /// <summary>
    /// خاصية TemperatureF.
    /// TemperatureF property.
    /// </summary>
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
