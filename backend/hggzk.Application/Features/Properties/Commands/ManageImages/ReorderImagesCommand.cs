using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Properties.Commands.ManageImages
{
    /// <summary>
    /// طلب إعادة ترتيب الصور.
    /// Request to reorder images.
    /// </summary>
    public class ReorderImagesCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// تعيينات الترتيب الجديدة للصور.
        /// New image order assignments.
        /// </summary>
        public List<ImageOrderAssignment> Assignments { get; set; } = new List<ImageOrderAssignment>();
    }

    /// <summary>
    /// يمثل تعيينًا واحدًا لترتيب صورة.
    /// Represents a single image ordering assignment.
    /// </summary>
    public class ImageOrderAssignment
    {
        /// <summary>
        /// معرّف الصورة.
        /// Image identifier.
        /// </summary>
        public Guid ImageId { get; set; }
        /// <summary>
        /// ترتيب العرض المطلوب للصورة.
        /// Desired display order for the image.
        /// </summary>
        public int DisplayOrder { get; set; }
    }
} 
