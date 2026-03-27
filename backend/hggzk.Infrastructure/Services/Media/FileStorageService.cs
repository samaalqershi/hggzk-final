using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using YemenBooking.Infrastructure.Settings;

namespace YemenBooking.Infrastructure.Services.Media
{
    /// <summary>
    /// خدمة تخزين الملفات وإدارتها محليًا. / Local file storage and management service.
    /// </summary>
    public class FileStorageService : IFileStorageService
    {
        private readonly ILogger<FileStorageService> _logger;
        private readonly FileStorageSettings _settings;

        /// <summary>
        /// ينشئ خدمة تخزين الملفات. / Creates a file storage service.
        /// </summary>
        public FileStorageService(ILogger<FileStorageService> logger, IOptions<FileStorageSettings> options)
        {
            _logger = logger;
            _settings = options.Value;
        }

        /// <summary>
        /// يرفع ملفًا من مجرى بيانات إلى التخزين المحلي. / Uploads a file stream to local storage.
        /// </summary>
        public async Task<FileUploadResult> UploadFileAsync(Stream fileStream, string fileName, string? contentType = null, string? folder = null, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("رفع ملف: {FileName} إلى المجلد: {Folder}", fileName, folder);
            try
            {
                var root = Path.Combine(Directory.GetCurrentDirectory(), _settings.RootPath);
                if (!Directory.Exists(root)) Directory.CreateDirectory(root);
                var folderPath = string.IsNullOrEmpty(folder) ? root : Path.Combine(root, folder);
                if (!Directory.Exists(folderPath)) Directory.CreateDirectory(folderPath);
                var fullPath = Path.Combine(folderPath, fileName);
                await using var fs = new FileStream(fullPath, FileMode.Create, FileAccess.Write, FileShare.None);
                await fileStream.CopyToAsync(fs, cancellationToken);
                // Build a safe URL by URL-encoding each path segment to support spaces/Arabic characters
                var relativePath = string.IsNullOrEmpty(folder) ? fileName : ($"{folder}/{fileName}");
                var encoded = string.Join('/', relativePath
                    .Split(new[] {'/'}, StringSplitOptions.RemoveEmptyEntries)
                    .Select(seg => Uri.EscapeDataString(seg)));
                var baseUrl = _settings.BaseUrl.TrimEnd('/');
                var fileUrl = $"{baseUrl}/{encoded}";
                return new FileUploadResult
                {
                    IsSuccess = true,
                    FilePath = fullPath,
                    FileUrl = fileUrl,
                    FileName = fileName,
                    FileSizeBytes = fs.Length,
                    ContentType = contentType
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء رفع الملف");
                return new FileUploadResult { IsSuccess = false, ErrorMessage = ex.Message };
            }
        }

        /// <summary>
        /// يرفع ملفًا من مصفوفة بايت إلى التخزين المحلي. / Uploads a byte array to local storage.
        /// </summary>
        public async Task<FileUploadResult> UploadFileAsync(byte[] fileBytes, string fileName, string? contentType = null, string? folder = null, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("رفع ملف من مصفوفة البايت: {FileName} إلى المجلد: {Folder}", fileName, folder);
            try
            {
                var root = Path.Combine(Directory.GetCurrentDirectory(), _settings.RootPath);
                if (!Directory.Exists(root)) Directory.CreateDirectory(root);
                var folderPath = string.IsNullOrEmpty(folder) ? root : Path.Combine(root, folder);
                if (!Directory.Exists(folderPath)) Directory.CreateDirectory(folderPath);
                var fullPath = Path.Combine(folderPath, fileName);
                await File.WriteAllBytesAsync(fullPath, fileBytes, cancellationToken);
                // Build a safe URL by URL-encoding each path segment to support spaces/Arabic characters
                var relativePath = string.IsNullOrEmpty(folder) ? fileName : ($"{folder}/{fileName}");
                var encoded = string.Join('/', relativePath
                    .Split(new[] {'/'}, StringSplitOptions.RemoveEmptyEntries)
                    .Select(seg => Uri.EscapeDataString(seg)));
                var baseUrl = _settings.BaseUrl.TrimEnd('/');
                var fileUrl = $"{baseUrl}/{encoded}";
                return new FileUploadResult
                {
                    IsSuccess = true,
                    FilePath = fullPath,
                    FileUrl = fileUrl,
                    FileName = fileName,
                    FileSizeBytes = fileBytes.Length,
                    ContentType = contentType
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء رفع الملف");
                return new FileUploadResult { IsSuccess = false, ErrorMessage = ex.Message };
            }
        }

        /// <summary>
        /// يحذف ملفًا من التخزين المحلي. / Deletes a file from local storage.
        /// </summary>
        public Task<bool> DeleteFileAsync(string filePath, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("حذف ملف: {FilePath}", filePath);
            try
            {
                var fullPath = Path.Combine(Directory.GetCurrentDirectory(), _settings.RootPath, filePath);
                if (File.Exists(fullPath)) File.Delete(fullPath);
                return Task.FromResult(true);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء حذف الملف");
                return Task.FromResult(false);
            }
        }

        /// <summary>
        /// ينشئ رابطًا عامًا للملف. / Builds a public file URL.
        /// </summary>
        public Task<string> GetFileUrlAsync(string filePath, TimeSpan? expiration = null, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("الحصول على رابط الملف: {FilePath} لمدة: {Expiration}", filePath, expiration);
            var baseUrl = _settings.BaseUrl.TrimEnd('/');
            var encoded = string.Join('/', filePath
                .Split(new[] {'/'}, StringSplitOptions.RemoveEmptyEntries)
                .Select(seg => Uri.EscapeDataString(seg)));
            var url = $"{baseUrl}/{encoded}";
            return Task.FromResult(url);
        }

        /// <summary>
        /// ينسخ ملفًا داخل التخزين المحلي. / Copies a file within local storage.
        /// </summary>
        public Task<bool> CopyFileAsync(string sourceFilePath, string destinationFilePath, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("نسخ ملف من {Source} إلى {Destination}", sourceFilePath, destinationFilePath);
            try
            {
                var sourceFull = Path.Combine(Directory.GetCurrentDirectory(), _settings.RootPath, sourceFilePath);
                var destFull = Path.Combine(Directory.GetCurrentDirectory(), _settings.RootPath, destinationFilePath);
                var destDir = Path.GetDirectoryName(destFull);
                if (!string.IsNullOrEmpty(destDir) && !Directory.Exists(destDir)) Directory.CreateDirectory(destDir);
                File.Copy(sourceFull, destFull, true);
                return Task.FromResult(true);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء نسخ الملف");
                return Task.FromResult(false);
            }
        }

        /// <summary>
        /// ينقل ملفًا داخل التخزين المحلي. / Moves a file within local storage.
        /// </summary>
        public Task<bool> MoveFileAsync(string sourceFilePath, string destinationFilePath, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation("نقل ملف من {Source} إلى {Destination}", sourceFilePath, destinationFilePath);
            try
            {
                var sourceFull = Path.Combine(Directory.GetCurrentDirectory(), _settings.RootPath, sourceFilePath);
                var destFull = Path.Combine(Directory.GetCurrentDirectory(), _settings.RootPath, destinationFilePath);
                var destDir = Path.GetDirectoryName(destFull);
                if (!string.IsNullOrEmpty(destDir) && !Directory.Exists(destDir)) Directory.CreateDirectory(destDir);
                File.Move(sourceFull, destFull);
                return Task.FromResult(true);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "خطأ أثناء نقل الملف");
                return Task.FromResult(false);
            }
        }

    }
}
