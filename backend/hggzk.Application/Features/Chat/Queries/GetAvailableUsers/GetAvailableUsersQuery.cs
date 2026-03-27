using YemenBooking.Application.Features.Users.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Chat.Queries.GetAvailableUsers
{
    using System;
    using System.Collections.Generic;
    using MediatR;
    using YemenBooking.Application.Common.Models;
    using YemenBooking.Application.Features.Users;

    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
    public class GetAvailableUsersQuery : IRequest<ResultDto<IEnumerable<ChatUserDto>>>
    {
        /// <summary>
        /// نوع المستخدم المطلوب تضمينه في النتائج.
        /// User type to include in the results.
        /// </summary>
        public string? UserType { get; set; }

        /// <summary>
        /// معرّف العقار عند تصفية مستخدمي مالكي العقارات.
        /// Property identifier when filtering property owners.
        /// </summary>
        public Guid? PropertyId { get; set; }
    }
} 
