namespace YemenBooking.Application.Contracts.Services.Storage;

/// <summary>
/// واجهة خدمة تخزين الملفات
/// File storage service interface
/// </summary>
public interface IFileStorageService
{
    /// <summary>
    /// رفع ملف
    /// Upload file
    /// </summary>
    Task<FileUploadResult> UploadFileAsync(
        Stream fileStream,
        string fileName,
        string? contentType = null,
        string? folder = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// رفع ملف من byte array
    /// Upload file from byte array
    /// </summary>
    Task<FileUploadResult> UploadFileAsync(
        byte[] fileBytes,
        string fileName,
        string? contentType = null,
        string? folder = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// حذف ملف
    /// Delete file
    /// </summary>
    Task<bool> DeleteFileAsync(
        string filePath,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// الحصول على رابط الملف
    /// Get file URL
    /// </summary>
    Task<string> GetFileUrlAsync(
        string filePath,
        TimeSpan? expiration = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// نسخ ملف
    /// Copy file
    /// </summary>
    Task<bool> CopyFileAsync(
        string sourceFilePath,
        string destinationFilePath,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// نقل ملف
    /// Move file
    /// </summary>
    Task<bool> MoveFileAsync(
        string sourceFilePath,
        string destinationFilePath,
        CancellationToken cancellationToken = default);

}
