// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// استيراد المكتبات المطلوبة
// Required imports
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using StackExchange.Redis; // مكتبة Redis الرسمية / Official Redis client
using Polly; // مكتبة للمرونة وإعادة المحاولة / Resilience and retry policies
using Polly.CircuitBreaker;
using YemenBooking.Infrastructure.Redis.Core.Interfaces;

namespace YemenBooking.Infrastructure.Redis.Core
{
    /// <summary>
    /// Manages a single Redis connection with resilience, retries, and event tracking.
    /// يدير اتصال Redis واحداً مع المرونة وإعادة المحاولة وتتبع الأحداث.
    /// </summary>
    public sealed class RedisConnectionManager : IRedisConnectionManager
    {
        #region === الحقول الخاصة (Private Fields) ===
        
        /// <summary>Logger used for operational events. / المسجل المستخدم لأحداث التشغيل.</summary>
        private readonly ILogger<RedisConnectionManager> _logger;
        
        /// <summary>Configuration source used to resolve the Redis connection string. / مصدر الإعدادات لقراءة سلسلة اتصال Redis.</summary>
        private readonly IConfiguration _configuration;
        
        /// <summary>Semaphore that serializes connection creation and reconnect operations. / قفل يضمن تسلسل إنشاء الاتصال وإعادة الاتصال.</summary>
        private readonly SemaphoreSlim _connectionLock;
        
        /// <summary>Polly retry policy for reconnect attempts. / سياسة إعادة المحاولة الخاصة بـ Polly لمحاولات إعادة الاتصال.</summary>
        private readonly IAsyncPolicy<IConnectionMultiplexer> _reconnectPolicy;
        
        /// <summary>Active Redis connection multiplexer. / موصل Redis الفعلي النشط.</summary>
        private IConnectionMultiplexer _connection;
        
        /// <summary>Mutable connection metadata and counters. / بيانات الاتصال والعدّادات القابلة للتحديث.</summary>
        private readonly ConnectionInfo _connectionInfo;
        
        /// <summary>Indicates whether the manager has been disposed. / يشير إلى أن المدير تم التخلص منه.</summary>
        private bool _disposed;
        
        #endregion
        
        #region === البناء والتهيئة (Constructor & Initialization) ===

        /// <summary>
        /// Creates a new Redis connection manager and configures its retry strategy.
        /// ينشئ مدير اتصال Redis ويهيئ استراتيجية إعادة المحاولة.
        /// </summary>
        public RedisConnectionManager(
            ILogger<RedisConnectionManager> logger,
            IConfiguration configuration)
        {
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
            
            // Allow only one connection workflow at a time.
            // السماح بعملية اتصال واحدة فقط في كل مرة.
            _connectionLock = new SemaphoreSlim(1, 1);
            _connectionInfo = new ConnectionInfo();
            
            // Configure a bounded retry policy with exponential backoff.
            // إعداد سياسة محدودة لإعادة المحاولة مع تدرج أسي في الانتظار.
            _reconnectPolicy = Policy<IConnectionMultiplexer>
                .Handle<RedisConnectionException>() // Connection failures
                .Or<RedisTimeoutException>() // Timeout failures
                .Or<ObjectDisposedException>() // Disposed objects
                .WaitAndRetryAsync(
                    3, // Retry count
                    retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)), // Exponential delay
                    onRetry: (outcome, timespan, retryCount, context) =>
                    {
                        // Record each retry attempt for observability.
                        // تسجيل كل محاولة إعادة لتحسين المراقبة.
                        _logger.LogWarning(
                            "Retry {RetryCount} after {TimeSpan}ms to connect to Redis",
                            retryCount, timespan.TotalMilliseconds);
                    });
        }
        
        #endregion

        #region === الوصول إلى موارد Redis (Redis Resources Access) ===
        
        /// <summary>
        /// Returns a Redis database instance after ensuring the connection is active.
        /// يعيد كائن قاعدة بيانات Redis بعد التأكد من أن الاتصال نشط.
        /// </summary>
        /// <param name="db">The database number, or -1 for the default database. / رقم قاعدة البيانات أو -1 للافتراضية.</param>
        /// <returns>A live database handle. / مقبض مباشر لقاعدة البيانات.</returns>
        public IDatabase GetDatabase(int db = -1)
        {
            // Ensure the synchronous path always operates on a live connection.
            // التأكد من أن المسار المتزامن يعمل دائماً على اتصال نشط.
            EnsureConnected();
            return _connection.GetDatabase(db);
        }

        /// <summary>
        /// Returns a Redis database instance asynchronously, reconnecting if needed and validating with a ping.
        /// يعيد كائن قاعدة بيانات Redis بشكل غير متزامن مع إعادة الاتصال عند الحاجة والتحقق عبر Ping.
        /// </summary>
        public async Task<IDatabase> GetDatabaseAsync(int db = -1)
        {
            const int maxRetries = 3; // Maximum retry count. / الحد الأقصى لعدد المحاولات.
            
            // Retry the full acquisition flow to cover transient disconnects and lock contention.
            // إعادة محاولة كامل المسار لتغطية الانقطاعات المؤقتة والتنافس على القفل.
            for (int attempt = 0; attempt < maxRetries; attempt++)
            {
                try
                {
                    // Reconnect lazily when the shared multiplexer is missing or disconnected.
                    // إعادة الاتصال عند الحاجة إذا كان الموصل مفقوداً أو غير متصل.
                    if (_connection == null || !_connection.IsConnected)
                    {
                        // Acquire the connection lock with a bounded wait.
                        // محاولة الحصول على القفل ضمن مهلة محددة.
                        var lockAcquired = await _connectionLock.WaitAsync(TimeSpan.FromSeconds(5)).ConfigureAwait(false);
                        if (!lockAcquired)
                        {
                            _logger.LogWarning("Failed to acquire connection lock, attempt {Attempt}", attempt + 1);
                            if (attempt < maxRetries - 1)
                            {
                                continue;
                            }
                            throw new TimeoutException("Failed to acquire connection lock");
                        }
                        
                        try
                        {
                            // Double-check inside the lock to avoid duplicate reconnects.
                            // تحقق مزدوج داخل القفل لتجنب إعادة الاتصال المتكررة.
                            if (_connection == null || !_connection.IsConnected)
                            {
                                _logger.LogWarning("Redis connection lost, attempting to reconnect (attempt {Attempt}/{MaxRetries})...", attempt + 1, maxRetries);
                                // Recreate the multiplexer using the shared reconnect path.
                                // إعادة إنشاء الموصل عبر مسار إعادة الاتصال المشترك.
                                _connection = await ConnectAsync().ConfigureAwait(false);
                                _connectionInfo.LastReconnectTime = DateTime.UtcNow;
                            }
                        }
                        finally
                        {
                            _connectionLock.Release();
                        }
                    }
                    
                    // Validate the connection before returning it to the caller.
                    // التحقق من الاتصال قبل إرجاعه للمتصل.
                    var database = _connection.GetDatabase(db);
                    await database.PingAsync().ConfigureAwait(false);
                    return database;
                }
                catch (Exception ex) when (attempt < maxRetries - 1)
                {
                    // Log the failure and continue with the next retry.
                    // تسجيل الفشل والمتابعة إلى المحاولة التالية.
                    _logger.LogWarning(ex, "Failed to get database, retry {Attempt} of {MaxRetries}", attempt + 1, maxRetries);
                }
            }
            
            return _connection?.GetDatabase(db) ?? throw new InvalidOperationException("Failed to get Redis database after multiple retries");
        }

        /// <summary>
        /// Gets the Redis subscriber endpoint for pub/sub operations.
        /// يعيد واجهة الاشتراك في Redis لعمليات النشر والاشتراك.
        /// </summary>
        public ISubscriber GetSubscriber()
        {
            EnsureConnected();
            return _connection.GetSubscriber();
        }

        /// <summary>
        /// Gets a Redis server endpoint for administrative commands.
        /// يعيد نقطة نهاية خادم Redis لأوامر الإدارة.
        /// </summary>
        public IServer GetServer()
        {
            EnsureConnected();
            // Select the first configured endpoint as the server handle.
            // اختيار أول نقطة نهاية مكوّنة كمرجع للخادم.
            var endpoints = _connection.GetEndPoints();
            if (endpoints.Length == 0)
            {
                throw new InvalidOperationException("No Redis endpoints configured");
            }
            return _connection.GetServer(endpoints[0]);
        }
        
        #endregion
        
        #region === فحص الاتصال وإعادة الاتصال (Connection Check & Reconnect) ===

        /// <summary>
        /// Checks whether Redis is currently reachable by issuing a ping.
        /// يتحقق من إمكانية الوصول إلى Redis عبر Ping فعلي.
        /// </summary>
        public async Task<bool> IsConnectedAsync()
        {
            try
            {
                // Fast-fail when no active connection is available.
                // إرجاع مبكر عند عدم وجود اتصال نشط.
                if (_connection == null || !_connection.IsConnected)
                {
                    return false;
                }

                var db = GetDatabase();
                await db.PingAsync().ConfigureAwait(false);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Redis connection check failed");
                return false;
            }
        }

        /// <summary>
        /// Reconnects to Redis by closing the current connection and creating a new one.
        /// يعيد الاتصال بـ Redis عبر إغلاق الاتصال الحالي وإنشاء اتصال جديد.
        /// </summary>
        public async Task ReconnectAsync()
        {
            // Serialize reconnect attempts so the multiplexer is replaced safely.
            // تسلسل محاولات إعادة الاتصال لضمان استبدال الموصل بأمان.
            await _connectionLock.WaitAsync().ConfigureAwait(false);
            try
            {
                _logger.LogInformation("Attempting to reconnect to Redis");
                
                // Dispose the old connection first to avoid keeping stale sockets alive.
                // إغلاق الاتصال القديم أولاً لتجنب بقاء مقابس قديمة نشطة.
                if (_connection != null)
                {
                    try
                    {
                        await _connection.CloseAsync().ConfigureAwait(false);
                        _connection.Dispose();
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex, "Error closing old Redis connection");
                    }
                }

                // Build a new connection and refresh the tracked timestamps.
                // إنشاء اتصال جديد وتحديث الطوابع الزمنية المتتبعة.
                _connection = await ConnectAsync().ConfigureAwait(false);
                _connectionInfo.LastReconnectTime = DateTime.UtcNow;
                _connectionInfo.IsConnected = true;
                
                _logger.LogInformation("Successfully reconnected to Redis");
            }
            catch (Exception ex)
            {
                // Update the failure counters before rethrowing the error.
                // تحديث عدّادات الفشل قبل إعادة رمي الخطأ.
                _connectionInfo.FailedConnections++;
                _connectionInfo.IsConnected = false;
                _logger.LogError(ex, "Failed to reconnect to Redis");
                throw;
            }
            finally
            {
                _connectionLock.Release();
            }
        }

        /// <summary>
        /// Returns a snapshot of the current connection information and counters.
        /// يعيد لقطة من معلومات الاتصال والعدّادات الحالية.
        /// </summary>
        public ConnectionInfo GetConnectionInfo()
        {
            return new ConnectionInfo
            {
                IsConnected = _connection?.IsConnected ?? false,
                Endpoint = _connectionInfo.Endpoint,
                ResponseTime = _connectionInfo.ResponseTime,
                TotalConnections = _connectionInfo.TotalConnections,
                FailedConnections = _connectionInfo.FailedConnections,
                LastReconnectTime = _connectionInfo.LastReconnectTime
            };
        }
        
        #endregion

        /// <summary>
        /// Ensures the manager has an active Redis connection before synchronous access.
        /// يضمن وجود اتصال Redis نشط قبل الوصول المتزامن.
        /// </summary>
        private void EnsureConnected()
        {
            if (_disposed)
            {
                throw new ObjectDisposedException(nameof(RedisConnectionManager));
            }

            if (_connection == null || !_connection.IsConnected)
            {
                // Use a bounded cancellation token so a blocked startup does not hang indefinitely.
                // استخدام مهلة إلغاء محددة حتى لا يتعطل بدء التشغيل إلى أجل غير مسمى.
                using (var cts = new CancellationTokenSource(TimeSpan.FromSeconds(60)))
                {
                    var lockAcquired = _connectionLock.Wait(TimeSpan.FromSeconds(10), cts.Token);
                    if (!lockAcquired)
                    {
                        _logger.LogError("Failed to acquire connection lock within 10 seconds");
                        throw new TimeoutException("Failed to acquire Redis connection lock");
                    }
                    
                    try
                    {
                        if (_connection == null || !_connection.IsConnected)
                        {
                            _logger.LogInformation("Establishing Redis connection (synchronous call)...");
                            
                            _connection = Task.Run(async () => await ConnectAsync().ConfigureAwait(false), cts.Token)
                                .ConfigureAwait(false)
                                .GetAwaiter()
                                .GetResult();
                            
                            _logger.LogInformation("Redis connection established successfully");
                        }
                    }
                    catch (OperationCanceledException)
                    {
                        _logger.LogError("Redis connection cancelled due to timeout");
                        throw new TimeoutException("Redis connection timeout after 60 seconds");
                    }
                    finally
                    {
                        _connectionLock.Release();
                    }
                }
            }
        }

        /// <summary>
        /// Builds a new Redis connection using the configured retry and event pipeline.
        /// ينشئ اتصال Redis جديداً باستخدام خط الإعدادات وإعادة المحاولة ومعالجات الأحداث.
        /// </summary>
        private async Task<IConnectionMultiplexer> ConnectAsync()
        {
            var connectionString = _configuration.GetConnectionString("Redis") 
                ?? _configuration["Redis:ConnectionString"]
                ?? _configuration["RedisConnectionString"]
                ?? "localhost:6379";

            _logger.LogInformation("Preparing Redis connection to: {ConnectionString}", connectionString);

            var options = ConfigurationOptions.Parse(connectionString);
            
            options.AbortOnConnectFail = false;              
            options.ConnectRetry = 5;                        
            options.ConnectTimeout = 30000;                  
            options.SyncTimeout = 10000;                     
            options.AsyncTimeout = 10000;                    
            options.KeepAlive = 60;                          
            options.ReconnectRetryPolicy = new ExponentialRetry(5000);
            
            if (!options.AllowAdmin && (connectionString.Contains("allowadmin=true", StringComparison.OrdinalIgnoreCase) ||
                                        _configuration.GetValue<bool>("Redis:AllowAdmin")))
            {
                options.AllowAdmin = true;
            }
            
            var connection = await _reconnectPolicy.ExecuteAsync(async () =>
            {
                _logger.LogInformation("Attempting to connect to Redis at {Endpoint}", connectionString);
                
                var conn = await ConnectionMultiplexer.ConnectAsync(options).ConfigureAwait(false);
                
                _logger.LogInformation("Redis connection multiplexer created, registering event handlers...");
                
                conn.ConnectionFailed += OnConnectionFailed;
                conn.ConnectionRestored += OnConnectionRestored;
                conn.ErrorMessage += OnErrorMessage;
                conn.InternalError += OnInternalError;
                
                _connectionInfo.TotalConnections++;
                _connectionInfo.Endpoint = connectionString;
                
                return conn;
            }).ConfigureAwait(false);

            _logger.LogInformation("Successfully connected to Redis at {Endpoint}", connectionString);
            return connection;
        }

        /// <summary>
        /// Handles Redis connection failures and updates the tracked counters.
        /// يعالج فشل الاتصال بـ Redis ويحدث العدّادات المتتبعة.
        /// </summary>
        private void OnConnectionFailed(object sender, ConnectionFailedEventArgs e)
        {
            // Record the failure locally before logging the detailed event.
            // تسجيل الفشل محلياً قبل كتابة تفاصيل الحدث.
            _connectionInfo.FailedConnections++;
            _connectionInfo.IsConnected = false;
            
            // Log the endpoint and failure type for diagnostics.
            // تسجيل نقطة النهاية ونوع الفشل لأغراض التشخيص.
            _logger.LogError(e.Exception, 
                "Redis connection failed. Endpoint: {Endpoint}, FailureType: {FailureType}", 
                e.EndPoint, e.FailureType);
        }

        /// <summary>
        /// Handles Redis connection restoration and flips the connection state back to healthy.
        /// يعالج استعادة الاتصال بـ Redis ويعيد حالة الاتصال إلى سليم.
        /// </summary>
        private void OnConnectionRestored(object sender, ConnectionFailedEventArgs e)
        {
            // Mark the connection as healthy again.
            // وسم الاتصال بأنه عاد للعمل.
            _connectionInfo.IsConnected = true;
            
            // Log the restored endpoint for operational tracing.
            // تسجيل نقطة النهاية المستعادة للتتبع التشغيلي.
            _logger.LogInformation(
                "Redis connection restored. Endpoint: {Endpoint}", 
                e.EndPoint);
        }

        /// <summary>
        /// Logs Redis error messages emitted by the server.
        /// يسجل رسائل الخطأ الصادرة من خادم Redis.
        /// </summary>
        private void OnErrorMessage(object sender, RedisErrorEventArgs e)
        {
            _logger.LogError("Redis error: {Message} from {EndPoint}", 
                e.Message, e.EndPoint);
        }

        /// <summary>
        /// Logs internal StackExchange.Redis exceptions with their origin.
        /// يسجل الاستثناءات الداخلية من StackExchange.Redis مع مصدرها.
        /// </summary>
        private void OnInternalError(object sender, InternalErrorEventArgs e)
        {
            _logger.LogError(e.Exception, 
                "Redis internal error: {Origin}", e.Origin);
        }

        /// <summary>
        /// Releases Redis resources and unregisters all event handlers.
        /// يحرر موارد Redis ويُلغي تسجيل جميع معالجات الأحداث.
        /// </summary>
        public void Dispose()
        {
            // Keep disposal idempotent.
            // الحفاظ على أن عملية التخلص قابلة للتكرار بأمان.
            if (_disposed) return;

            _disposed = true;

            try
            {
                if (_connection != null)
                {
                    // Unregister event handlers to avoid memory leaks.
                    // إلغاء تسجيل المعالجات لتجنب تسرب الذاكرة.
                    _connection.ConnectionFailed -= OnConnectionFailed;
                    _connection.ConnectionRestored -= OnConnectionRestored;
                    _connection.ErrorMessage -= OnErrorMessage;
                    _connection.InternalError -= OnInternalError;
                    
                    // Close and dispose the active connection.
                    // إغلاق الاتصال النشط والتخلص منه.
                    _connection.Close();
                    _connection.Dispose();
                }

                // Dispose the synchronization primitive.
                // التخلص من أداة التزامن.
                _connectionLock?.Dispose();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error disposing Redis connection manager");
            }
        }
    }
}
