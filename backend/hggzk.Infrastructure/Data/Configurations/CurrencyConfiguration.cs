using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the Currency entity mapping.
/// يهيئ ربط كيان العملة بقاعدة البيانات. / Configures the Currency entity mapping.
/// </summary>
public class CurrencyConfiguration : IEntityTypeConfiguration<Currency>
{
    /// <summary>
    /// Applies the Currency mapping rules.
    /// يطبق قواعد ربط كيان العملة. / Applies the Currency mapping rules.
    /// </summary>
    public void Configure(EntityTypeBuilder<Currency> builder)
    {
        builder.ToTable("Currencies");

        builder.HasKey(c => c.Code);
        builder.Property(c => c.Code)
               .HasMaxLength(10)
               .IsRequired();
        builder.Property(c => c.ArabicCode)
               .HasMaxLength(10);
        builder.Property(c => c.Name)
               .HasMaxLength(100)
               .IsRequired();
        builder.Property(c => c.ArabicName)
               .HasMaxLength(100);
        builder.Property(c => c.IsDefault)
               .HasDefaultValue(false);
        builder.Property(c => c.ExchangeRate)
               .HasColumnType("decimal(18,6)");
        builder.Property(c => c.LastUpdated)
               .HasColumnType("timestamp with time zone");

        builder.HasIndex(c => c.IsDefault).HasDatabaseName("IX_Currencies_IsDefault");
    }
}
