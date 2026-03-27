using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Staffs;
using YemenBooking.Application.Common.Exceptions;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.Staffs.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Staffs.Queries.GetStaffByUser
{
    /// <summary>
    /// يعالج جلب الموظف by المستخدم ويعيد النتيجة المطلوبة.
    /// Processes the Get Staff By User request and returns the requested result.
    /// </summary>
    public class GetStaffByUserQueryHandler : IRequestHandler<GetStaffByUserQuery, ResultDto<StaffDto>>
    {
        private readonly IStaffRepository _staffRepository;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<GetStaffByUserQueryHandler> _logger;

        /// <summary>
        /// ينشئ مثيلاً جديداً من GetStaffByUserQueryHandler.
        /// Initializes a new instance of GetStaffByUserQueryHandler.
        /// </summary>
        /// <param name="staffRepository">مستودع الموظف / staff repository.</param>
        /// <param name="currentUserService">خدمة المستخدم الحالي / Current user service.</param>
        /// <param name="logger">مسجل الأحداث / Logger.</param>
        public GetStaffByUserQueryHandler(
            IStaffRepository staffRepository,
            ICurrentUserService currentUserService,
            ILogger<GetStaffByUserQueryHandler> logger)
        {
            _staffRepository = staffRepository;
            _currentUserService = currentUserService;
            _logger = logger;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
        public async Task<ResultDto<StaffDto>> Handle(GetStaffByUserQuery request, CancellationToken cancellationToken)
        {
            _logger.LogInformation("بدء جلب بيانات الموظف للمستخدم: {UserId}", request.UserId);

            if (request.UserId == Guid.Empty)
            {
                _logger.LogWarning("معرف المستخدم غير صالح");
                return ResultDto<StaffDto>.Failure("معرف المستخدم غير صالح");
            }

            if (_currentUserService.Role != "Admin" && _currentUserService.UserId != request.UserId)
            {
                _logger.LogWarning("ليس لدى المستخدم صلاحية الوصول إلى بيانات الموظف");
                return ResultDto<StaffDto>.Failure("ليس لديك صلاحية الوصول إلى بيانات الموظف");
            }

            var staff = await _staffRepository.GetStaffByUserAsync(request.UserId, cancellationToken);
            if (staff == null)
            {
                _logger.LogWarning("الموظف غير موجود للمستخدم: {UserId}", request.UserId);
                return ResultDto<StaffDto>.Failure("الموظف غير موجود");
            }

            var dto = new StaffDto
            {
                Id = staff.Id,
                UserId = staff.UserId,
                UserName = string.Empty,
                PropertyId = staff.PropertyId,
                PropertyName = string.Empty,
                Position = staff.Position,
                Permissions = staff.Permissions
            };

            return ResultDto<StaffDto>.Ok(dto);
        }
    }
} 