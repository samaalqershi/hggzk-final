using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Properties.Commands.ManageImages
{
    /// <summary>
    /// طلب حذف الصور.
    /// Request to delete images.
    /// </summary>
    public class DeleteImagesCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// معرّفات الصور المطلوب حذفها.
        /// Identifiers of the images to delete.
        /// </summary>
        public List<Guid> ImageIds { get; set; } = new List<Guid>();
        /// <summary>
        /// يحدد ما إذا كان الحذف نهائيًا.
        /// Indicates whether deletion is permanent.
        /// </summary>
        public bool Permanent { get; set; } = false;
    }

    /// <summary>
    /// طلب حذف الصور باستخدام المفتاح المؤقت.
    /// Request to delete images using a temporary key.
    /// </summary>
    public class DeleteImagesByTempKeyCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// المفتاح المؤقت المرتبط بعملية الحذف.
        /// Temporary key associated with the delete operation.
        /// </summary>
        public string TempKey { get; set; } = string.Empty;
        /// <summary>
        /// يحدد ما إذا كان الحذف نهائيًا.
        /// Indicates whether deletion is permanent.
        /// </summary>
        public bool Permanent { get; set; } = true;
    }
} 
