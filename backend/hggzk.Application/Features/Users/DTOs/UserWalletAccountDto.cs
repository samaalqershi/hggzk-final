using System;
using YemenBooking.Core.Enums;

namespace YemenBooking.Application.Features.Users.DTOs;

/// <summary>
/// فئة UserWalletAccountDto.
/// UserWalletAccountDto class.
/// </summary>
public class UserWalletAccountDto
{
    /// <summary>
    /// خاصية Id.
    /// Id property.
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// خاصية WalletType.
    /// WalletType property.
    /// </summary>
    public PaymentMethodEnum WalletType { get; set; }

    /// <summary>
    /// خاصية AccountNumber.
    /// AccountNumber property.
    /// </summary>
    public string AccountNumber { get; set; } = string.Empty;

    /// <summary>
    /// خاصية AccountName.
    /// AccountName property.
    /// </summary>
    public string? AccountName { get; set; }

    /// <summary>
    /// خاصية IsDefault.
    /// IsDefault property.
    /// </summary>
    public bool IsDefault { get; set; }
}

/// <summary>
/// فئة UserWalletAccountRequestDto.
/// UserWalletAccountRequestDto class.
/// </summary>
public class UserWalletAccountRequestDto
{
    /// <summary>
    /// خاصية WalletType.
    /// WalletType property.
    /// </summary>
    public PaymentMethodEnum WalletType { get; set; }

    /// <summary>
    /// خاصية AccountNumber.
    /// AccountNumber property.
    /// </summary>
    public string AccountNumber { get; set; } = string.Empty;

    /// <summary>
    /// خاصية AccountName.
    /// AccountName property.
    /// </summary>
    public string? AccountName { get; set; }

    /// <summary>
    /// خاصية IsDefault.
    /// IsDefault property.
    /// </summary>
    public bool IsDefault { get; set; }
}
