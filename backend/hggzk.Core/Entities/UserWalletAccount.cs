using System;
using System.ComponentModel.DataAnnotations;
using YemenBooking.Core.Enums;

namespace YemenBooking.Core.Entities;

/// <summary>
/// يمثل حساب محفظة مالية مرتبطًا بالمستخدم.
/// Represents a financial wallet account linked to a user.
/// </summary>
[Display(Name = "حساب محفظة المستخدم")]
public class UserWalletAccount : BaseEntity<Guid>
{
    /// <summary>
    /// معرّف المستخدم مالك الحساب.
    /// The user identifier that owns this account.
    /// </summary>
    public Guid UserId { get; set; }

    /// <summary>
    /// نوع المحفظة أو وسيلة الدفع المرتبطة بالحساب.
    /// The wallet type or payment method associated with the account.
    /// </summary>
    public PaymentMethodEnum WalletType { get; set; }

    /// <summary>
    /// رقم الحساب أو المرجع المستخدم للتعريف به.
    /// The account number or reference used to identify it.
    /// </summary>
    public string AccountNumber { get; set; } = string.Empty;

    /// <summary>
    /// اسم الحساب كما يظهر للمستخدم أو في السجلات.
    /// The account name as shown to users or in records.
    /// </summary>
    public string? AccountName { get; set; }

    /// <summary>
    /// يشير إلى ما إذا كان هذا الحساب هو الافتراضي.
    /// Indicates whether this is the default account.
    /// </summary>
    public bool IsDefault { get; set; } = false;

    /// <summary>
    /// مرجع التنقّل إلى المستخدم المرتبط بالحساب.
    /// Navigation reference to the related user.
    /// </summary>
    public virtual User User { get; set; } = null!;
}
