using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the role entity mapping.
/// يهيئ ربط كيان الدور بقاعدة البيانات.
/// </summary>
public class RoleConfiguration : IEntityTypeConfiguration<Role>
{
    /// <summary>
    /// Applies the role mapping rules.
    /// يطبق قواعد ربط كيان الدور.
    /// </summary>
    public void Configure(EntityTypeBuilder<Role> builder)
    {
        // Set the table name. تعيين اسم الجدول.
        builder.ToTable("Roles");

        // Set the primary key. تعيين المفتاح الأساسي.
        builder.HasKey(r => r.Id);

        // Re-apply BaseEntity fields explicitly. إعادة تطبيق حقول BaseEntity بشكل صريح.
        builder.Property(b => b.Id).HasColumnName("RoleId").IsRequired();
        builder.Property(b => b.IsDeleted).HasDefaultValue(false);
        builder.Property(b => b.DeletedAt).HasColumnType("timestamp with time zone");
        
        // Configure the remaining scalar properties. تهيئة الخصائص البسيطة المتبقية.
        builder.Property(r => r.Name).IsRequired().HasMaxLength(50);
        
        // Configure the unique index. تهيئة الفهرس الفريد.
        builder.HasIndex(r => r.Name).IsUnique();

        // Configure relationships. تهيئة العلاقات.
        builder.HasMany(r => r.UserRoles)
            .WithOne(ur => ur.Role)
            .HasForeignKey(ur => ur.RoleId)
            .OnDelete(DeleteBehavior.Cascade);

        // Seed data is handled by DataSeedingService. تتم معالجة البيانات الأولية عبر DataSeedingService.

        // Apply the soft-delete filter. تطبيق مرشح الحذف الناعم.
        builder.HasQueryFilter(r => !r.IsDeleted);
    }
}
