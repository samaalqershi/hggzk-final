using System;
using System.Threading.Tasks;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using YemenBooking.Application.Features.Properties.Commands.UploadImages;
using YemenBooking.Application.Features.Properties.Commands.ManageImages;
using YemenBooking.Application.Features.Properties.Commands.OptimizeImages;
using YemenBooking.Application.Features.Properties.Queries.GetImages;
using YemenBooking.Application.Features.Properties.Queries.GetImageStatistics;
using YemenBooking.Application.Features.Properties.Queries.SearchImages;
using YemenBooking.Application.Features.Properties.Queries.GetImageById;
using YemenBooking.Application.Features.Properties.Queries.GetUploadProgress;
using YemenBooking.Application.Features.Properties.Queries.GetDownloadUrl;
using YemenBooking.Application.Common.Models;
using Microsoft.AspNetCore.Http;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using YemenBooking.Core.Enums;

namespace YemenBooking.Api.Controllers.Images
{
    /// <summary>
    /// إدارة الصور وعمليات الرفع والبحث والإعادة ترتيب.
    /// Image management for upload, search, ordering, and related actions.
    /// </summary>
    [Authorize]
    [ApiController]
    [Route("api/images")]
    public class ImagesController : ControllerBase
    {
        /// <summary>
        /// المرسل الوسيط المستخدم لتنفيذ الأوامر والاستعلامات.
        /// Mediator used to dispatch commands and queries.
        /// </summary>
        private readonly IMediator _mediator;

        /// <summary>
        /// ينشئ المتحكم مع المرسل الوسيط.
        /// Creates the controller with the mediator.
        /// </summary>
        /// <param name="mediator">المرسل الوسيط المستخدم لتنفيذ الطلبات.</param>
        public ImagesController(IMediator mediator) => _mediator = mediator;

        /// <summary>
        /// يرفع صورة واحدة.
        /// Uploads a single image.
        /// </summary>
        [HttpPost("upload")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadImage([FromForm] UploadImageRequest request)
        {
            using var ms = new MemoryStream();
            await request.File.CopyToAsync(ms);
            var fileBytes = ms.ToArray();
            FileUploadRequest? clientPoster = null;
            if (request.VideoThumbnail != null)
            {
                using var ps = new MemoryStream();
                await request.VideoThumbnail.CopyToAsync(ps);
                clientPoster = new FileUploadRequest
                {
                    FileName = request.VideoThumbnail.FileName,
                    FileContent = ps.ToArray(),
                    ContentType = request.VideoThumbnail.ContentType
                };
            }

            var command = new UploadImageCommand
            {
                TempKey = string.IsNullOrWhiteSpace(request.TempKey) ? null : request.TempKey,
                File = new FileUploadRequest
                {
                    FileName = request.File.FileName,
                    FileContent = fileBytes,
                    ContentType = request.File.ContentType
                },
                VideoThumbnail = clientPoster,
                Name = Path.GetFileNameWithoutExtension(request.File.FileName),
                Extension = Path.GetExtension(request.File.FileName),
                    ImageType = ImageType.Management,
                Category = Enum.TryParse<ImageCategory>(request.Category, true, out var cat) ? cat : ImageCategory.Gallery,
                PropertyId = string.IsNullOrEmpty(request.PropertyId) ? (Guid?)null : Guid.Parse(request.PropertyId),
                UnitId = string.IsNullOrEmpty(request.UnitId) ? (Guid?)null : Guid.Parse(request.UnitId),
                SectionId = string.IsNullOrEmpty(request.SectionId) ? (Guid?)null : Guid.Parse(request.SectionId),
                PropertyInSectionId = string.IsNullOrEmpty(request.PropertyInSectionId) ? (Guid?)null : Guid.Parse(request.PropertyInSectionId),
                UnitInSectionId = string.IsNullOrEmpty(request.UnitInSectionId) ? (Guid?)null : Guid.Parse(request.UnitInSectionId),
                    CityName = !string.IsNullOrWhiteSpace(request.CityName) ? request.CityName : (!string.IsNullOrWhiteSpace(request.CityId) ? request.CityId : null),
                Alt = request.Alt,
                IsPrimary = request.IsPrimary,
                Order = request.Order,
                Tags = string.IsNullOrEmpty(request.Tags)
                    ? null
                    : (request.Tags.TrimStart().StartsWith("[")
                        ? System.Text.Json.JsonSerializer.Deserialize<List<string>>(request.Tags)
                        : new List<string>(request.Tags.Split(new[] { ',', ' ' }, StringSplitOptions.RemoveEmptyEntries)))
                ,
                Is360 = request.Is360
            };

            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(new { success = false, error = result.Message });

            // Build absolute URLs for the frontend. / إعداد روابط مطلقة للواجهة الأمامية.
            var image = result.Data!;
            var baseUrl = $"{Request.Scheme}://{Request.Host}";
            if (!image.Url.StartsWith("http", StringComparison.OrdinalIgnoreCase))
            {
                image.Url = baseUrl + (image.Url.StartsWith("/") ? image.Url : "/" + image.Url);
            }
            // Normalize thumbnail URLs when present. / تطبيع روابط الصور المصغرة عند توفرها.
            if (image.Thumbnails != null)
            {
                image.Thumbnails.Small = string.IsNullOrWhiteSpace(image.Thumbnails.Small) ? image.Thumbnails.Small : (image.Thumbnails.Small.StartsWith("http", StringComparison.OrdinalIgnoreCase) ? image.Thumbnails.Small : baseUrl + (image.Thumbnails.Small.StartsWith("/") ? image.Thumbnails.Small : "/" + image.Thumbnails.Small));
                image.Thumbnails.Medium = string.IsNullOrWhiteSpace(image.Thumbnails.Medium) ? image.Thumbnails.Medium : (image.Thumbnails.Medium.StartsWith("http", StringComparison.OrdinalIgnoreCase) ? image.Thumbnails.Medium : baseUrl + (image.Thumbnails.Medium.StartsWith("/") ? image.Thumbnails.Medium : "/" + image.Thumbnails.Medium));
                image.Thumbnails.Large = string.IsNullOrWhiteSpace(image.Thumbnails.Large) ? image.Thumbnails.Large : (image.Thumbnails.Large.StartsWith("http", StringComparison.OrdinalIgnoreCase) ? image.Thumbnails.Large : baseUrl + (image.Thumbnails.Large.StartsWith("/") ? image.Thumbnails.Large : "/" + image.Thumbnails.Large));
                image.Thumbnails.Hd = string.IsNullOrWhiteSpace(image.Thumbnails.Hd) ? image.Thumbnails.Hd : (image.Thumbnails.Hd.StartsWith("http", StringComparison.OrdinalIgnoreCase) ? image.Thumbnails.Hd : baseUrl + (image.Thumbnails.Hd.StartsWith("/") ? image.Thumbnails.Hd : "/" + image.Thumbnails.Hd));
            }
            if (!string.IsNullOrWhiteSpace(image.VideoThumbnail))
            {
                image.VideoThumbnail = image.VideoThumbnail!.StartsWith("http", StringComparison.OrdinalIgnoreCase)
                    ? image.VideoThumbnail
                    : baseUrl + (image.VideoThumbnail!.StartsWith("/") ? image.VideoThumbnail : "/" + image.VideoThumbnail);
            }
            
            return Ok(new { success = true, taskId = image.Id, image });
        }


        /// <summary>
        /// يعيد قائمة الصور.
        /// Returns the image list.
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetImages([FromQuery] GetImagesQuery query)
        {
            var result = await _mediator.Send(query);
            if (!result.Success)
                return BadRequest(result.Message);

            var data = result.Data!;
            var baseUrl = $"{Request.Scheme}://{Request.Host}";
            foreach (var img in data.Items)
            {
                // Normalize the main image URL. / تطبيع رابط الصورة الرئيسية.
                if (!img.Url.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                    img.Url = baseUrl + (img.Url.StartsWith("/") ? img.Url : "/" + img.Url);
                // Normalize the video thumbnail URL when present. / تطبيع رابط الصورة المصغرة للفيديو عند توفره.
                if (!string.IsNullOrWhiteSpace(img.VideoThumbnail) && !img.VideoThumbnail!.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                {
                    img.VideoThumbnail = baseUrl + (img.VideoThumbnail!.StartsWith("/") ? img.VideoThumbnail : "/" + img.VideoThumbnail);
                }
                // Only normalize thumbnails when the DTO contains them. / تطبيع الصور المصغرة فقط عند توفرها في الـ DTO.
                if (img.Thumbnails != null)
                {
                    // Normalize absolute URLs only; do not derive thumbnails from the video URL. / تطبيع الروابط المطلقة فقط، وعدم اشتقاق الصور المصغرة من رابط الفيديو.
                    img.Thumbnails.Small = string.IsNullOrWhiteSpace(img.Thumbnails.Small) ? img.Thumbnails.Small : (img.Thumbnails.Small.StartsWith("http", StringComparison.OrdinalIgnoreCase) ? img.Thumbnails.Small : baseUrl + (img.Thumbnails.Small.StartsWith("/") ? img.Thumbnails.Small : "/" + img.Thumbnails.Small));
                    img.Thumbnails.Medium = string.IsNullOrWhiteSpace(img.Thumbnails.Medium) ? img.Thumbnails.Medium : (img.Thumbnails.Medium.StartsWith("http", StringComparison.OrdinalIgnoreCase) ? img.Thumbnails.Medium : baseUrl + (img.Thumbnails.Medium.StartsWith("/") ? img.Thumbnails.Medium : "/" + img.Thumbnails.Medium));
                    img.Thumbnails.Large = string.IsNullOrWhiteSpace(img.Thumbnails.Large) ? img.Thumbnails.Large : (img.Thumbnails.Large.StartsWith("http", StringComparison.OrdinalIgnoreCase) ? img.Thumbnails.Large : baseUrl + (img.Thumbnails.Large.StartsWith("/") ? img.Thumbnails.Large : "/" + img.Thumbnails.Large));
                    img.Thumbnails.Hd = string.IsNullOrWhiteSpace(img.Thumbnails.Hd) ? img.Thumbnails.Hd : (img.Thumbnails.Hd.StartsWith("http", StringComparison.OrdinalIgnoreCase) ? img.Thumbnails.Hd : baseUrl + (img.Thumbnails.Hd.StartsWith("/") ? img.Thumbnails.Hd : "/" + img.Thumbnails.Hd));
                }
            }
            return Ok(new
            {
                images = data.Items,
                total = data.Total,
                page = data.Page,
                limit = data.Limit,
                totalPages = data.TotalPages
            });
        }

        /// <summary>
        /// يحذف جميع الصور المرتبطة بمفتاح مؤقت.
        /// Purges all images associated with a temporary key.
        /// </summary>
        [HttpDelete("purge-temp")]
        public async Task<IActionResult> PurgeTempImages([FromQuery] string tempKey)
        {
            if (string.IsNullOrWhiteSpace(tempKey))
                return BadRequest("tempKey is required");

            var result = await _mediator.Send(new DeleteImagesByTempKeyCommand { TempKey = tempKey });
            if (!result.Success)
                return BadRequest(result.Message);

            return NoContent();
        }

        // /// <summary>
        // /// Temporary image-list stub kept for reference.
        // /// </summary>
        // [HttpGet]
        // public async Task<IActionResult> GetImages([FromQuery] GetImagesQuery query)
        // {
        //     // Temporary stub: return images from Uploads/Review folder
        //     var reviewFolder = System.IO.Path.Combine(System.IO.Directory.GetCurrentDirectory(), "Uploads", "Review");
        //     var files = System.IO.Directory.Exists(reviewFolder) ? System.IO.Directory.GetFiles(reviewFolder, "*.png") : new string[0];
        //     var images = files.Select(filePath =>
        //     {
        //         var fileName = System.IO.Path.GetFileName(filePath);
        //         var url = $"{Request.Scheme}://{Request.Host}/uploads/Review/{fileName}";
        //         var fileInfo = new System.IO.FileInfo(filePath);
        //         return new ImageDto
        //         {
        //             Id = Guid.NewGuid(),
        //             Url = url,
        //             Filename = fileName,
        //             Size = fileInfo.Length
        //         };
        //     }).ToList();
        //     return Ok(new
        //     {
        //         images = images,
        //         total = images.Count,
        //         page = 1,
        //         limit = images.Count,
        //         totalPages = 1
        //     });
        // }

        /// <summary>
        /// يعيد صورة بواسطة المعرف.
        /// Returns an image by identifier.
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetImageById([FromRoute] Guid id)
        {
            var result = await _mediator.Send(new GetImageByIdQuery { ImageId = id });
            if (!result.Success)
                return NotFound(result.Message);

            return Ok(result.Data);
        }

        /// <summary>
        /// يحدّث بيانات الصورة.
        /// Updates image data.
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateImage([FromRoute] Guid id, [FromBody] UpdateImageCommand command)
        {
            command.ImageId = id;
            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result.Message);

            return Ok(result.Data);
        }

        /// <summary>
        /// يحذف صورة واحدة.
        /// Deletes a single image.
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteImage([FromRoute] Guid id, [FromQuery] bool permanent = false)
        {
            var command = new DeleteImageCommand { ImageId = id, Permanent = permanent };
            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result.Message);

            return NoContent();
        }

        /// <summary>
        /// يحذف صورًا متعددة.
        /// Deletes multiple images.
        /// </summary>
        [HttpPost("bulk-delete")]
        public async Task<IActionResult> DeleteImages([FromBody] DeleteImagesCommand command)
        {
            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result.Message);

            return NoContent();
        }

        /// <summary>
        /// نموذج طلب لإعادة ترتيب الصور.
        /// Request model for reordering images.
        /// </summary>
        public class ReorderImagesRequest
        {
            /// <summary>
            /// معرّفات الصور بالترتيب المطلوب.
            /// Image identifiers in the desired order.
            /// </summary>
            public List<string> ImageIds { get; set; } = new List<string>();

            /// <summary>
            /// معرف العقار عند الحاجة.
            /// Optional listing identifier.
            /// </summary>
            public string? PropertyId { get; set; }

            /// <summary>
            /// معرف الوحدة عند الحاجة.
            /// Optional unit identifier.
            /// </summary>
            public string? UnitId { get; set; }
            /// <summary>
            /// المفتاح المؤقت المستخدم لتجميع الصور قبل الربط.
            /// Temporary key used to group images before binding.
            /// </summary>
            public string? TempKey { get; set; }
            /// <summary>
            /// اسم المدينة عند الحاجة.
            /// Optional city name.
            /// </summary>
            public string? CityName { get; set; }

        }

        /// <summary>
        /// يعيد ترتيب الصور.
        /// Reorders images.
        /// </summary>
        [HttpPost("reorder")]
        public async Task<IActionResult> ReorderImages([FromBody] ReorderImagesRequest request)
        {
            var assignments = request.ImageIds
                .Select((id, idx) => new ImageOrderAssignment
                {
                    ImageId = Guid.Parse(id),
                    DisplayOrder = idx + 1
                })
                .ToList();

            var command = new ReorderImagesCommand { Assignments = assignments };
            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result.Message);

            return NoContent();
        }

        /// <summary>
        /// يعيّن صورة كرئيسية.
        /// Sets an image as primary.
        /// </summary>
        [HttpPost("{id}/set-primary")]
        public async Task<IActionResult> SetPrimaryImage([FromRoute] Guid id, [FromBody] SetPrimaryImageCommand command)
        {
            command.ImageId = id;
            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result.Message);

            return NoContent();
        }

        /// <summary>
        /// يعيد إحصائيات الصور.
        /// Returns image statistics.
        /// </summary>
        [HttpGet("statistics")]
        public async Task<IActionResult> GetImageStatistics([FromQuery] GetImageStatisticsQuery query)
        {
            var result = await _mediator.Send(query);
            if (!result.Success)
                return BadRequest(result.Message);

            return Ok(result.Data);
        }

        /// <summary>
        /// يبحث في الصور.
        /// Searches images.
        /// </summary>
        [HttpPost("search")]
        public async Task<IActionResult> SearchImages([FromBody] SearchImagesQuery query)
        {
            var result = await _mediator.Send(query);
            if (!result.Success)
                return BadRequest(result.Message);

            var data = result.Data!;
            return Ok(new
            {
                images = data.Items,
                total = data.Total,
                page = data.Page,
                limit = data.Limit,
                totalPages = data.TotalPages
            });
        }

        /// <summary>
        /// يعيد تقدم رفع الصورة.
        /// Returns image upload progress.
        /// </summary>
        [HttpGet("upload-progress/{taskId}")]
        public async Task<IActionResult> GetUploadProgress([FromRoute] string taskId)
        {
            var result = await _mediator.Send(new GetUploadProgressQuery { TaskId = taskId });
            if (!result.Success)
                return BadRequest(result.Message);

            return Ok(result.Data);
        }

        /// <summary>
        /// يعيد رابط تنزيل مؤقتًا.
        /// Returns a temporary download URL.
        /// </summary>
        [HttpGet("{id}/download")]
        public async Task<IActionResult> GetDownloadUrl([FromRoute] Guid id, [FromQuery] string size = null)
        {
            var result = await _mediator.Send(new GetDownloadUrlQuery { ImageId = id, Size = size });
            if (!result.Success)
                return BadRequest(result.Message);

            return Ok(new { url = result.Data });
        }

        /// <summary>
        /// يحسّن الصورة.
        /// Optimizes an image.
        /// </summary>
        [HttpPost("{id}/optimize")]
        public async Task<IActionResult> OptimizeImage([FromRoute] Guid id, [FromBody] OptimizeImageCommand command)
        {
            command.ImageId = id;
            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result.Message);

            return Ok(result.Data);
        }

        /// <summary>
        /// ينشئ مصغرات إضافية.
        /// Generates additional thumbnails.
        /// </summary>
        [HttpPost("{id}/thumbnails")]
        public async Task<IActionResult> GenerateThumbnails([FromRoute] Guid id, [FromBody] GenerateThumbnailsCommand command)
        {
            command.ImageId = id;
            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result.Message);

            return Ok(result.Data);
        }

        /// <summary>
        /// ينسخ الصورة إلى كيان أو وحدة أخرى.
        /// Copies an image to another entity or unit.
        /// </summary>
        [HttpPost("{id}/copy")]
        public async Task<IActionResult> CopyImage([FromRoute] Guid id, [FromBody] CopyImageCommand command)
        {
            command.ImageId = id;
            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result.Message);

            return Ok(result.Data);
        }
    }
} 
