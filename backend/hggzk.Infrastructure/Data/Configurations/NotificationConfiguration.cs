using System;
using System.Collections.Generic;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the Notification entity mapping.
/// يهيئ ربط كيان الإشعار بقاعدة البيانات.
/// </summary>
public class NotificationConfiguration : IEntityTypeConfiguration<Notification>
{
    /// <summary>
    /// حقل _jsonOptions.
    /// _jsonOptions field.
    /// </summary>
    private static readonly JsonSerializerOptions _jsonOptions = new JsonSerializerOptions();

    /// <summary>
    /// Applies Notification entity mapping rules.
    /// يطبق قواعد ربط كيان الإشعار.
    /// </summary>
    public void Configure(EntityTypeBuilder<Notification> builder)
    {
        // Set the table name.
        // تعيين اسم الجدول.
        builder.ToTable("Notifications");

        // Set the primary key.
        // تعيين المفتاح الأساسي.
        builder.HasKey(n => n.Id);
        builder.Property(n => n.Id).HasColumnName("NotificationId").IsRequired();

        // Configure BaseEntity properties.
        // تهيئة خصائص BaseEntity.
        builder.Property(n => n.CreatedAt).HasColumnType("timestamp with time zone").IsRequired();
        builder.Property(n => n.UpdatedAt).HasColumnType("timestamp with time zone").IsRequired();
        builder.Property(n => n.IsActive).HasDefaultValue(true);
        builder.Property(n => n.IsDeleted).HasDefaultValue(false);
        builder.Property(n => n.DeletedAt).HasColumnType("timestamp with time zone");

        // Configure scalar properties.
        // تهيئة الخصائص البسيطة.
        builder.Property(n => n.Type).IsRequired().HasMaxLength(50);
        builder.Property(n => n.Title).IsRequired().HasMaxLength(200);
        builder.Property(n => n.Message).IsRequired().HasMaxLength(1000);
        builder.Property(n => n.TitleAr).HasMaxLength(200);
        builder.Property(n => n.MessageAr).HasMaxLength(1000);
        builder.Property(n => n.Priority).IsRequired().HasMaxLength(20);
        builder.Property(n => n.Status).IsRequired().HasMaxLength(20);
        builder.Property(n => n.Data).HasColumnType("text");

        // Configure Channels and SentChannels JSON conversion.
        // تهيئة تحويل Channels و SentChannels إلى JSON.
        var listConverter = new ValueConverter<List<string>, string>(
            v => JsonSerializer.Serialize(v, _jsonOptions),
            v => JsonSerializer.Deserialize<List<string>>(v, _jsonOptions) ?? new List<string>());
        builder.Property(n => n.Channels)
            .HasConversion(listConverter)
            .HasColumnType("text");
        builder.Property(n => n.SentChannels)
            .HasConversion(listConverter)
            .HasColumnType("text");

        builder.Property(n => n.IsRead).HasDefaultValue(false);
        builder.Property(n => n.IsDismissed).HasDefaultValue(false);
        builder.Property(n => n.RequiresAction).HasDefaultValue(false);
        builder.Property(n => n.CanDismiss).HasDefaultValue(true);

        builder.Property(n => n.ReadAt).HasColumnType("timestamp with time zone");
        builder.Property(n => n.DismissedAt).HasColumnType("timestamp with time zone");
        builder.Property(n => n.ScheduledFor).HasColumnType("timestamp with time zone");
        builder.Property(n => n.ExpiresAt).HasColumnType("timestamp with time zone");
        builder.Property(n => n.DeliveredAt).HasColumnType("timestamp with time zone");

        builder.Property(n => n.GroupId).HasMaxLength(100);
        builder.Property(n => n.BatchId).HasMaxLength(100);
        builder.Property(n => n.Icon).HasMaxLength(100);
        builder.Property(n => n.Color).HasMaxLength(20);
        builder.Property(n => n.ActionUrl).HasMaxLength(500);
        builder.Property(n => n.ActionText).HasMaxLength(200);

        // Configure relationships.
        // تهيئة العلاقات.
        builder.HasOne(n => n.Recipient)
            .WithMany()
            .HasForeignKey(n => n.RecipientId)
            .OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(n => n.Sender)
            .WithMany()
            .HasForeignKey(n => n.SenderId)
            .OnDelete(DeleteBehavior.SetNull);

        // Apply the global query filter.
        // تطبيق مرشح الاستعلام العام.
        builder.HasQueryFilter(n => !n.IsDeleted);
    }
} 
