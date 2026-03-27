using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;

namespace YemenBooking.Infrastructure.Services.Settings
{
    /// <summary>
    /// خدمة إدارة إعدادات النظام المعتمدة على ملف JSON محمي. / System settings service backed by a protected JSON file.
    /// </summary>
    public class SystemSettingsService : ISystemSettingsService
    {
        private const string DefaultCommissionRateKey = "Commission:DefaultRate";
        private const string DefaultCommissionRateValue = "5";
        private readonly string _settingsFilePath;

        /// <summary>
        /// ينشئ خدمة إعدادات النظام ويجهز مسار التخزين. / Creates the system settings service and prepares the storage path.
        /// </summary>
        public SystemSettingsService(IHostEnvironment env)
        {
            var settingsDir = Path.Combine(env.ContentRootPath, "Settings");
            if (!Directory.Exists(settingsDir))
            {
                Directory.CreateDirectory(settingsDir);
            }
            _settingsFilePath = Path.Combine(settingsDir, "systemsettings.json");
        }

        /// <summary>
        /// يجلب إعدادات النظام الحالية. / Gets the current system settings.
        /// </summary>
        public async Task<Dictionary<string, string>> GetSettingsAsync(CancellationToken cancellationToken = default)
        {
            if (!File.Exists(_settingsFilePath))
            {
                var defaultSettings = CreateDefaultSettings();
                var defaultContent = JsonSerializer.Serialize(defaultSettings, new JsonSerializerOptions { WriteIndented = true });
                await File.WriteAllTextAsync(_settingsFilePath, defaultContent, cancellationToken);
                return defaultSettings;
            }

            var content = await File.ReadAllTextAsync(_settingsFilePath, cancellationToken);
            var settings = JsonSerializer.Deserialize<Dictionary<string, string>>(content)
                ?? CreateDefaultSettings();

            // Ensure required defaults always exist without overriding custom values.
            if (!settings.ContainsKey(DefaultCommissionRateKey))
            {
                settings[DefaultCommissionRateKey] = DefaultCommissionRateValue;
                await SaveSettingsAsync(settings, cancellationToken);
            }

            return settings;
        }

        /// <summary>
        /// يحفظ إعدادات النظام في ملف JSON. / Saves the system settings to the JSON file.
        /// </summary>
        public async Task SaveSettingsAsync(Dictionary<string, string> settings, CancellationToken cancellationToken = default)
        {
            var content = JsonSerializer.Serialize(settings, new JsonSerializerOptions { WriteIndented = true });
            await File.WriteAllTextAsync(_settingsFilePath, content, cancellationToken);
        }

        private static Dictionary<string, string> CreateDefaultSettings()
        {
            return new Dictionary<string, string>
            {
                [DefaultCommissionRateKey] = DefaultCommissionRateValue
            };
        }
    }
}
