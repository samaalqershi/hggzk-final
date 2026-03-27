using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the UserRole entity mapping.
/// يهيئ ربط كيان دور المستخدم بقاعدة البيانات.
/// </summary>
public class UserRoleConfiguration : IEntityTypeConfiguration<UserRole>
{
    /// <summary>
    /// Applies UserRole entity mapping rules.
    /// يطبق قواعد ربط كيان دور المستخدم.
    /// </summary>
    public void Configure(EntityTypeBuilder<UserRole> builder)
    {
        // Set the table name.
        // تعيين اسم الجدول.
        builder.ToTable("UserRoles");

        // Re-apply BaseEntity fields explicitly for the schema.
        // إعادة تطبيق حقول BaseEntity بشكل صريح في المخطط.
        builder.Property(b => b.Id).HasColumnName("UserRoleId").IsRequired();
        builder.Property(b => b.IsDeleted).HasDefaultValue(false);
        builder.Property(b => b.DeletedAt).HasColumnType("timestamp with time zone");
        
        // Configure the remaining scalar properties.
        // تهيئة الخصائص البسيطة المتبقية.
        builder.Property(ur => ur.UserId).IsRequired();
        builder.Property(ur => ur.RoleId).IsRequired();
        builder.Property(ur => ur.AssignedAt).HasColumnType("timestamp with time zone").IsRequired();
        
        // Configure the composite primary key.
        // تهيئة المفتاح الأساسي المركب.
        builder.HasKey(ur => new { ur.UserId, ur.RoleId });
        
        // Configure relationships.
        // تهيئة العلاقات.
        builder.HasOne(ur => ur.User)
               .WithMany(u => u.UserRoles)
               .HasForeignKey(ur => ur.UserId);
        
        builder.HasOne(ur => ur.Role)
               .WithMany(r => r.UserRoles)
               .HasForeignKey(ur => ur.RoleId);

        // Configure indexes.
        // تهيئة الفهارس.
        builder.HasIndex(ur => ur.UserId)
            .HasDatabaseName("IX_UserRoles_UserId");

        builder.HasIndex(ur => ur.RoleId)
            .HasDatabaseName("IX_UserRoles_RoleId");

        builder.HasIndex(ur => ur.IsDeleted)
            .HasDatabaseName("IX_UserRoles_IsDeleted");

        // Apply the soft-delete filter.
        // تطبيق مرشح الحذف الناعم.
        builder.HasQueryFilter(ur => !ur.IsDeleted);
    }
}
