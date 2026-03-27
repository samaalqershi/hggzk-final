using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the report entity mapping.
/// يهيئ ربط كيان البلاغ بقاعدة البيانات.
/// </summary>
public class ReportConfiguration : IEntityTypeConfiguration<Report>
{
    /// <summary>
    /// Applies the report mapping rules.
    /// يطبق قواعد ربط كيان البلاغ.
    /// </summary>
    public void Configure(EntityTypeBuilder<Report> builder)
    {
        builder.ToTable("Reports");
        builder.HasKey(r => r.Id);

        builder.Property(r => r.Reason)
            .IsRequired()
            .HasMaxLength(250);

        builder.Property(r => r.Description)
            .IsRequired()
            .HasMaxLength(1000);

        // Configure the report status field. تهيئة حقل حالة البلاغ.
        builder.Property(r => r.Status)
            .IsRequired()
            .HasMaxLength(50);

        // Configure the admin action note field. تهيئة حقل ملاحظات الإجراء من الإدارة.
        builder.Property(r => r.ActionNote)
            .HasMaxLength(1000);

        // Configure the admin identifier who handled the report.
        // تهيئة معرف المسؤول الذي اتخذ الإجراء.
        builder.Property(r => r.AdminId)
            .IsRequired(false);

        builder.Property(r => r.CreatedAt)
            .IsRequired();

        // Apply the global query filter. تطبيق مرشح الاستعلام العام.
        builder.HasQueryFilter(r => !r.IsDeleted);

        builder.HasOne(r => r.ReporterUser)
            .WithMany(u => u.ReportsMade)
            .HasForeignKey(r => r.ReporterUserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(r => r.ReportedUser)
            .WithMany(u => u.ReportsAgainstUser)
            .HasForeignKey(r => r.ReportedUserId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(r => r.ReportedProperty)
            .WithMany(p => p.Reports)
            .HasForeignKey(r => r.ReportedPropertyId)
            .OnDelete(DeleteBehavior.SetNull);
    }
} 
