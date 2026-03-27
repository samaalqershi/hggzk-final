using System;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Policies.Commands.ManagePolicies
{
    /// <summary>
    /// يبدّل حالة السياسة بين التفعيل والإيقاف.
    /// Toggles a policy between active and inactive states.
    /// </summary>
    public class TogglePolicyStatusCommand : IRequest<ResultDto<bool>>
    {
        /// <summary>
        /// معرّف السياسة.
        /// Policy identifier.
        /// </summary>
        public Guid PolicyId { get; set; }
    }
}
