using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace YemenBooking.Infrastructure.Services.Media
{
    /// <summary>
    /// خدمة رفع الملفات وتخزينها محليًا. / Local file upload and storage service.
    /// </summary>
    public class FileUploadService : IFileUploadService
    {
        private readonly ILogger<FileUploadService> _logger;

        /// <summary>
        /// ينشئ خدمة رفع الملفات. / Creates a file upload service.
        /// </summary>
        public FileUploadService(ILogger<FileUploadService> logger)
        {
            _logger = logger;
        }

        private async Task<string> SaveFileAsync(Stream fileStream, string fileName, string folder)
        {
            var root = Path.Combine(Directory.GetCurrentDirectory(), "Uploads", folder);
            Directory.CreateDirectory(root);
            var uniqueName = GenerateUniqueFileName(fileName);
            var fullPath = Path.Combine(root, uniqueName);
            using (var fs = new FileStream(fullPath, FileMode.Create, FileAccess.Write, FileShare.None))
            {
                await fileStream.CopyToAsync(fs);
            }
            var url = $"/uploads/{folder}/{uniqueName}";
            _logger.LogInformation("Uploaded file {FileName} to {Path}", fileName, url);
            return url;
        }

        /// <summary>
        /// يرفع صورة إلى التخزين المحلي ويعيد رابطها. / Uploads an image to local storage and returns its URL.
        /// </summary>
        public async Task<string> UploadImageAsync(Stream imageStream, string fileName, int maxWidth = 1920, int maxHeight = 1080, int quality = 85, string folder = "images")
        {
            // Simple save; image processing can be added later
            return await SaveFileAsync(imageStream, fileName, folder);
        }

        /// <summary>
        /// يرفع صورة ملف شخصي إلى مجلد الصور المخصص. / Uploads a profile image to the dedicated images folder.
        /// </summary>
        public async Task<string> UploadProfileImageAsync(Stream imageStream, string fileName, CancellationToken cancellationToken = default)
        {
            // Store under images/profile
            return await UploadImageAsync(imageStream, fileName, folder: Path.Combine("images", "profile"));
        }

        /// <summary>
        /// يحذف ملفًا باستخدام رابطه العام. / Deletes a file using its public URL.
        /// </summary>
        public Task<bool> DeleteFileAsync(string fileUrl)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(fileUrl)) return Task.FromResult(false);
                var relativePath = fileUrl.StartsWith("/uploads/") ? fileUrl.Replace("/uploads/", string.Empty) : fileUrl;
                var fullPath = Path.Combine(Directory.GetCurrentDirectory(), "Uploads", relativePath);
                if (File.Exists(fullPath))
                {
                    File.Delete(fullPath);
                    _logger.LogInformation("Deleted file {Path}", fileUrl);
                    return Task.FromResult(true);
                }
                return Task.FromResult(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to delete file {Path}", fileUrl);
                return Task.FromResult(false);
            }
        }

        /// <summary>
        /// يتحقق من أن امتداد الملف مسموح به. / Verifies that the file extension is allowed.
        /// </summary>
        public bool IsValidFileType(string fileName, string[] allowedExtensions)
        {
            var extension = Path.GetExtension(fileName);
            return !string.IsNullOrWhiteSpace(extension) && allowedExtensions.Any(e => e.Equals(extension, StringComparison.OrdinalIgnoreCase));
        }

        /// <summary>
        /// يتحقق من أن حجم الملف ضمن الحد المسموح. / Verifies that the file size is within the allowed limit.
        /// </summary>
        public bool IsValidFileSize(long fileSize, int maxSizeInMB)
        {
            return fileSize <= maxSizeInMB * 1024 * 1024;
        }

        /// <summary>
        /// ينشئ اسم ملف فريدًا. / Generates a unique file name.
        /// </summary>
        public string GenerateUniqueFileName(string originalFileName)
        {
            return $"{Guid.NewGuid()}{Path.GetExtension(originalFileName)}";
        }
    }
}
