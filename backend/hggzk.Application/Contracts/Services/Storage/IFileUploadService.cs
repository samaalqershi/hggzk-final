using System.Collections.Generic;
using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace YemenBooking.Application.Contracts.Services.Storage;

/// <summary>
/// File upload abstraction used by the application layer.
/// عقد تجريد رفع الملفات المستخدم في طبقة التطبيق.
/// </summary>
public interface IFileUploadService
{
    /// <summary>Uploads an optimized image and returns its public URL. يرفع صورة محسّنة ويعيد رابطها العام.</summary>
    Task<string> UploadImageAsync(Stream imageStream, string fileName, int maxWidth = 1920, int maxHeight = 1080, int quality = 85, string folder = "images");

    /// <summary>Uploads a user profile image. يرفع صورة الملف الشخصي للمستخدم.</summary>
    Task<string> UploadProfileImageAsync(Stream imageStream, string fileName, CancellationToken cancellationToken = default);

    /// <summary>Deletes a file by URL. يحذف ملفاً عبر رابطه.</summary>
    Task<bool> DeleteFileAsync(string fileUrl);

    /// <summary>Checks whether a file extension is allowed. يتحقق من السماح بامتداد الملف.</summary>
    bool IsValidFileType(string fileName, string[] allowedExtensions);

    /// <summary>Checks whether the file size is within the allowed limit. يتحقق من أن حجم الملف ضمن الحد المسموح.</summary>
    bool IsValidFileSize(long fileSize, int maxSizeInMB);

    /// <summary>Generates a unique file name for storage. ينشئ اسماً فريداً للملف عند التخزين.</summary>
    string GenerateUniqueFileName(string originalFileName);
}
