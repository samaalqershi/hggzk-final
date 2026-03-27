using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Users;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Users.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Users.Queries.GetUsersByRole
{
    /// <summary>
    /// معالج المستخدمون حسب الدور.
    /// users by role handler.
    /// </summary>
    public class GetUsersByRoleQueryHandler : IRequestHandler<GetUsersByRoleQuery, PaginatedResult<UserDto>>
    {
        private readonly IUserRepository _userRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly IMapper _mapper;
        private readonly ILogger<GetUsersByRoleQueryHandler> _logger;

        /// <summary>
        /// يهيئ هذا المكوّن بالاعتماديات المطلوبة.
        /// Initializes this component with the required dependencies.
        /// </summary>
        public GetUsersByRoleQueryHandler(
            IUserRepository userRepository,
            ICurrentUserService currentUserService,
            IMapper mapper,
            ILogger<GetUsersByRoleQueryHandler> logger)
        {
            _userRepository = userRepository;
            _currentUserService = currentUserService;
            _mapper = mapper;
            _logger = logger;
        }

    /// <summary>
    /// ينفذ منطق المعالجة لهذا الطلب.
    /// executes the handling logic for this request.
    /// </summary>
        public async Task<PaginatedResult<UserDto>> Handle(GetUsersByRoleQuery request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("جاري معالجة استعلام المستخدمين حسب الدور: {RoleName}, الصفحة: {PageNumber}, الحجم: {PageSize}",
                request.RoleName, request.PageNumber, request.PageSize);

            // صلاحيات المسؤول فقط
            if (!_currentUserService.UserRoles.Contains("Admin"))
            {
                throw new UnauthorizedAccessException("ليس لديك صلاحية لعرض المستخدمين حسب الدور");
            }

            var pageNumber = request.PageNumber < 1 ? 1 : request.PageNumber;
            var pageSize = request.PageSize < 1 ? 10 : request.PageSize;

            var query = _userRepository.GetQueryable()
                .AsNoTracking()
                .Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
                .Where(u => u.UserRoles.Any(ur => ur.Role.Name == request.RoleName));

            var totalCount = await query.CountAsync(cancellationToken);
            var users = await query
                .OrderBy(u => u.Name)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync(cancellationToken);

            var dtos = users.Select(u => _mapper.Map<UserDto>(u)).ToList();

            _logger.LogInformation("تم جلب {Count} مستخدم من إجمالي {TotalCount} حسب الدور: {RoleName}",
                dtos.Count, totalCount, request.RoleName);
            return new PaginatedResult<UserDto>(dtos, pageNumber, pageSize, totalCount);
        }
    }
} 
