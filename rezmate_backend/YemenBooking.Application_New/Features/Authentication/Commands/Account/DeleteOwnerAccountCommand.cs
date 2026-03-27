using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Authentication.DTOs;

namespace YemenBooking.Application.Features.Authentication.Commands.Account
{
    public class DeleteOwnerAccountCommand : IRequest<ResultDto<DeleteAccountResponse>>
    {
        public string? Password { get; set; }

        public string? SocialProvider { get; set; }

        public string? SocialToken { get; set; }

        public string? SocialNonce { get; set; }

        public string? Reason { get; set; }
    }
}
