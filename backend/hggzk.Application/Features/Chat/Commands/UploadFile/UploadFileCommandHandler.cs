using System;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using MediatR;
using Microsoft.AspNetCore.Http;
using YemenBooking.Application.Features.Chat;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Chat.DTOs;

namespace YemenBooking.Application.Features.Chat.Commands.UploadFile
{
    /// <summary>
    /// يعالج الطلب ويطبق منطق التنفيذ.
    /// Processes the request and applies the execution logic.
    /// </summary>
    public class UploadFileCommandHandler : IRequestHandler<UploadFileCommand, ResultDto<ChatAttachmentDto>>
    {
        private readonly IFileStorageService _fileStorageService;
        private readonly IChatAttachmentRepository _attachmentRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly IMapper _mapper;
        private readonly IMediaMetadataService _mediaMetadataService;

        /// <summary>
        /// يهيئ مثيلاً جديدًا من المعالج.
        /// Initializes a new handler instance.
        /// </summary>
        public UploadFileCommandHandler(
            IFileStorageService fileStorageService,
            IChatAttachmentRepository attachmentRepository,
            ICurrentUserService currentUserService,
            IMapper mapper,
            IMediaMetadataService mediaMetadataService)
        {
            _fileStorageService = fileStorageService;
            _attachmentRepository = attachmentRepository;
            _currentUserService = currentUserService;
            _mapper = mapper;
            _mediaMetadataService = mediaMetadataService;
        }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
        public async Task<ResultDto<ChatAttachmentDto>> Handle(UploadFileCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var file = request.File;
                using var stream = file.OpenReadStream();
                var uploadResult = await _fileStorageService.UploadFileAsync(
                    stream,
                    file.FileName,
                    file.ContentType,
                    folder: "ChatAttachments",
                    cancellationToken: cancellationToken
                );

                if (!uploadResult.IsSuccess || string.IsNullOrEmpty(uploadResult.FilePath))
                    return ResultDto<ChatAttachmentDto>.Failed("فشل في رفع الملف");

                // Try to extract media duration if applicable
                int? durationSeconds = null;
                try
                {
                    durationSeconds = await _mediaMetadataService.TryGetDurationSecondsAsync(
                        uploadResult.FilePath!,
                        uploadResult.ContentType ?? file.ContentType,
                        cancellationToken);
                }
                catch { /* non-fatal */ }

                var attachment = new ChatAttachment
                {
                    ConversationId = request.ConversationId,
                    FileName = uploadResult.FileName ?? file.FileName,
                    ContentType = uploadResult.ContentType ?? file.ContentType,
                    FileSize = uploadResult.FileSizeBytes,
                    FilePath = uploadResult.FilePath!,
                    UploadedBy = _currentUserService.UserId,
                    CreatedAt = uploadResult.UploadedAt,
                    DurationSeconds = durationSeconds
                };

                // Optional thumbnail upload (client-generated), typically for videos
                if (request.Thumbnail != null)
                {
                    try
                    {
                        using var thumbStream = request.Thumbnail.OpenReadStream();
                        var thumbUpload = await _fileStorageService.UploadFileAsync(
                            thumbStream,
                            request.Thumbnail.FileName,
                            request.Thumbnail.ContentType,
                            folder: "ChatAttachments/Thumbnails",
                            cancellationToken: cancellationToken
                        );
                        if (thumbUpload.IsSuccess && (!string.IsNullOrEmpty(thumbUpload.FileUrl) || !string.IsNullOrEmpty(thumbUpload.FilePath)))
                        {
                            attachment.ThumbnailUrl = thumbUpload.FileUrl ?? thumbUpload.FilePath;
                        }
                    }
                    catch { /* non-fatal */ }
                }

                await _attachmentRepository.CreateAttachmentAsync(attachment, cancellationToken);
                await _attachmentRepository.SaveChangesAsync(cancellationToken);

                var dto = _mapper.Map<ChatAttachmentDto>(attachment);
                return ResultDto<ChatAttachmentDto>.Ok(dto, "تم رفع الملف بنجاح");
            }
            catch (Exception ex)
            {
                return ResultDto<ChatAttachmentDto>.Failed($"خطأ أثناء رفع الملف: {ex.Message}");
            }
        }
    }
}
