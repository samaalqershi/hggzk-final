using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Users.Queries.GetUserById;

    /// <summary>
    /// استعلام جلب بيانات مستخدم حسب المعرف.
    /// user by id query.
    /// </summary>
public class GetUserByIdQuery : IRequest<ResultDto<object>>
{
    /// <summary>
    /// معرّف المستخدم
    /// user ID
    /// </summary>
    public Guid UserId { get; set; }
} 