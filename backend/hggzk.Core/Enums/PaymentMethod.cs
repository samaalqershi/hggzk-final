namespace YemenBooking.Core.Enums;

/// <summary>
/// تعداد طرق الدفع
/// Payment Methods enumeration
/// </summary>
public enum PaymentMethodEnum
{
    /// <summary>
    /// قيمة تعداد JwaliWallet.
    /// JwaliWallet enum value.
    /// </summary>
    JwaliWallet = 1,
    /// <summary>
    /// قيمة تعداد CashWallet.
    /// CashWallet enum value.
    /// </summary>
    CashWallet = 2,
    /// <summary>
    /// قيمة تعداد OneCashWallet.
    /// OneCashWallet enum value.
    /// </summary>
    OneCashWallet = 3,
    /// <summary>
    /// قيمة تعداد FloskWallet.
    /// FloskWallet enum value.
    /// </summary>
    FloskWallet = 4,
    /// <summary>
    /// قيمة تعداد JaibWallet.
    /// JaibWallet enum value.
    /// </summary>
    JaibWallet = 5,
    /// <summary>
    /// قيمة تعداد Cash.
    /// Cash enum value.
    /// </summary>
    Cash = 6,
    /// <summary>
    /// قيمة تعداد Paypal.
    /// Paypal enum value.
    /// </summary>
    Paypal = 7,
    /// <summary>
    /// قيمة تعداد CreditCard.
    /// CreditCard enum value.
    /// </summary>
    CreditCard = 8,
    /// <summary>
    /// قيمة تعداد EWallet.
    /// EWallet enum value.
    /// </summary>
    EWallet = 9,

    /// <summary>
    /// محفظة سبأ كاش (محفظة إلكترونية عبر YottaPay)
    /// SabaCash wallet payment method (via YottaPay)
    /// </summary>
    SabaCashWallet = 10
} 