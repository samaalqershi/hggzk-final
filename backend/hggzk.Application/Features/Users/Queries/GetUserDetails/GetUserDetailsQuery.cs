using System;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Users.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Users.Queries.GetUserDetails
{
    /// <summary>
    /// استعلام تفاصيل المستخدم.
    /// user details query.
    /// </summary>
    public class GetUserDetailsQuery : IRequest<ResultDto<UserDetailsDto>>
    {
        /// <summary>
        /// معرّف المستخدم
        /// user ID
        /// </summary>
        public Guid UserId { get; set; }
    }
}
