using System.Threading;
using System.Threading.Tasks;
using MediatR;
using YemenBooking.Application.Features.Chat;
using YemenBooking.Application.Common.Models;
using System.Text.Json;
using System;
using YemenBooking.Application.Common.Interfaces;
 
 namespace YemenBooking.Application.Features.Chat.Commands.Presence
 {
     /// <summary>
     /// يعالج الطلب ويطبق منطق التنفيذ.
     /// Processes the request and applies the execution logic.
     /// </summary>
     public class UpdateUserStatusCommandHandler : IRequestHandler<UpdateUserStatusCommand, ResultDto>
     {
        private readonly IFirebaseService _firebaseService;
        private readonly ICurrentUserService _currentUserService;

        /// <summary>
        /// يهيئ مثيلاً جديدًا من المعالج.
        /// Initializes a new handler instance.
        /// </summary>
        public UpdateUserStatusCommandHandler(IFirebaseService firebaseService, ICurrentUserService currentUserService)
        {
            _firebaseService = firebaseService;
            _currentUserService = currentUserService;
        }

    /// <summary>
    /// يعالج هذا المكوّن المرتبط بـ النطاق الحالي ويعيد النتيجة المطلوبة.
    /// Handles the corresponding current feature area command or query and returns the requested result.
    /// </summary>
        public async Task<ResultDto> Handle(UpdateUserStatusCommand request, CancellationToken cancellationToken)
        {
            var userId = _currentUserService.UserId;
            // إشعار تغيّر الحالة عبر FCM (اختياري: يمكن الاستغناء عنه)
            await _firebaseService.SendNotificationAsync($"user_{userId}", "تحديث حالة المستخدم", request.Status, new System.Collections.Generic.Dictionary<string, string>
            {
                { "type", "user_status_changed" },
                { "user_id", userId.ToString() },
                { "status", request.Status }
            }, cancellationToken);
            return ResultDto.Ok(null, "تم تحديث حالة المستخدم");
        }
    }
} 
