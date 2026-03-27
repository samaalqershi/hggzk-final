using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Users.Commands.ManageUserStatus;

    /// <summary>
    /// طلب تفعيل مستخدم.
    /// user activation request.
    /// </summary>
public class ActivateUserCommand : IRequest<ResultDto<bool>>
{
    /// <summary>
    /// معرّف المستخدم
    /// user ID
    /// </summary>
    public Guid UserId { get; set; }
}
