using System;
using System.Threading.Tasks;
using StackExchange.Redis;

namespace YemenBooking.Infrastructure.Redis.Core.Interfaces
{
    /// <summary>
    /// واجهة إدارة اتصال Redis
    /// </summary>
    public interface IRedisConnectionManager : IDisposable
    {
        /// <summary>
        /// الحصول على قاعدة بيانات Redis
        /// </summary>
        IDatabase GetDatabase(int db = -1);

        /// <summary>
        /// الحصول على قاعدة بيانات Redis بشكل async مع فحص الاتصال
        /// </summary>
        Task<IDatabase> GetDatabaseAsync(int db = -1);

        /// <summary>
        /// الحصول على Subscriber
        /// </summary>
        ISubscriber GetSubscriber();

        /// <summary>
        /// الحصول على Server
        /// </summary>
        IServer GetServer();

        /// <summary>
        /// التحقق من الاتصال
        /// </summary>
        Task<bool> IsConnectedAsync();

        /// <summary>
        /// إعادة الاتصال
        /// </summary>
        Task ReconnectAsync();

        /// <summary>
        /// الحصول على معلومات الاتصال
        /// </summary>
        ConnectionInfo GetConnectionInfo();
    }

    /// <summary>
    /// معلومات الاتصال
    /// </summary>
    public class ConnectionInfo
    {
        /// <summary>
        /// خاصية IsConnected.
        /// IsConnected property.
        /// </summary>
        public bool IsConnected { get; set; }
        /// <summary>
        /// خاصية Endpoint.
        /// Endpoint property.
        /// </summary>
        public string Endpoint { get; set; }
        /// <summary>
        /// خاصية ResponseTime.
        /// ResponseTime property.
        /// </summary>
        public TimeSpan ResponseTime { get; set; }
        /// <summary>
        /// خاصية TotalConnections.
        /// TotalConnections property.
        /// </summary>
        public long TotalConnections { get; set; }
        /// <summary>
        /// خاصية FailedConnections.
        /// FailedConnections property.
        /// </summary>
        public long FailedConnections { get; set; }
        /// <summary>
        /// خاصية LastReconnectTime.
        /// LastReconnectTime property.
        /// </summary>
        public DateTime LastReconnectTime { get; set; }
    }
}
