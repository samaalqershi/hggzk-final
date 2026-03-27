using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.PropertyServices.Commands.DeleteProperty
{
    /// <summary>
    /// يمثل طلب حذف خدمة مرتبطة بعقار.
    /// Deletes a property service entry.
    /// </summary>
    public class DeletePropertyServiceCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// معرّف الخدمة.
        /// service identifier.
        /// </summary>
        public Guid ServiceId { get; set; }
    }
} 
