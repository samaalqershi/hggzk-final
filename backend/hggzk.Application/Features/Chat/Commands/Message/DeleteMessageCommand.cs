using System;
using System.Text.Json.Serialization;
using MediatR;
using YemenBooking.Application.Common.Models;
 
 namespace YemenBooking.Application.Features.Chat.Commands.Message
 {
    /// <summary>
    /// يمثل أمر حذف رسالة ضمن نطاق الدردشة.
    /// Represents a command to delete a chat message.
    /// </summary>
     public class DeleteMessageCommand : IRequest<ResultDto>
     {
         /// <summary>
         /// معرّف الرسالة المطلوب حذفها.
         /// Message identifier to delete.
         /// </summary>
         [JsonPropertyName("message_id")]
         public Guid MessageId { get; set; }
     }
 } 
