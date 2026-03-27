using System;
using System.Text.Json.Serialization;
using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Chat.DTOs;
 
 namespace YemenBooking.Application.Features.Chat.Commands.Message
 {
    /// <summary>
    /// يمثل أمر تعديل رسالة ضمن نطاق الدردشة.
    /// Represents a command to edit a chat message.
    /// </summary>
     public class EditMessageCommand : IRequest<ResultDto<ChatMessageDto>>
     {
         /// <summary>
         /// معرّف الرسالة المطلوب تعديلها.
         /// Message identifier to edit.
         /// </summary>
        [JsonIgnore]
         public Guid MessageId { get; set; }
 
         /// <summary>
         /// المحتوى الجديد للرسالة.
         /// New message content.
         /// </summary>
        [JsonPropertyName("content")]
         public string Content { get; set; } = string.Empty;
     }
 } 
