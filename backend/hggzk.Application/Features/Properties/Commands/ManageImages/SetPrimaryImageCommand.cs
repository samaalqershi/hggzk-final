using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Properties.Commands.ManageImages
{
    /// <summary>
    /// طلب تعيين Primary Image.
    /// Request to set primaryimage.
    /// </summary>
    public class SetPrimaryImageCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// معرّف الصورة.
        /// image identifier.
        /// </summary>
        public Guid ImageId { get; set; }

        /// <summary>
        /// معرّف العقار.
        /// property identifier.
        /// </summary>
        public Guid? PropertyId { get; set; }

        /// <summary>
        /// معرّف الوحدة.
        /// unit identifier.
        /// </summary>
        public Guid? UnitId { get; set; }
        
        /// <summary>
        /// المفتاح المؤقت.
        /// temporary key.
        /// </summary>
        public string? TempKey { get; set; }

        /// <summary>
        /// اسم المدينة.
        /// city name.
        /// </summary>
        public string? CityName { get; set; }
    }
} 
