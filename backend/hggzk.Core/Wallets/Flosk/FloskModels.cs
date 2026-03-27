using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace YemenBooking.Core.Wallets.Flosk
{
    /// <summary>
    /// فئة FloskRequestKeyRequest.
    /// FloskRequestKeyRequest class.
    /// </summary>
    public class FloskRequestKeyRequest
    {
        /// <summary>
        /// خاصية Phone.
        /// Phone property.
        /// </summary>
        [JsonPropertyName("phone")]
        public string Phone { get; set; } = string.Empty;

        /// <summary>
        /// خاصية ShortCode.
        /// ShortCode property.
        /// </summary>
        [JsonPropertyName("short_code")]
        public string ShortCode { get; set; } = string.Empty;
    }

    /// <summary>
    /// فئة FloskRequestKeyResponse.
    /// FloskRequestKeyResponse class.
    /// </summary>
    public class FloskRequestKeyResponse
    {
        /// <summary>
        /// خاصية Message.
        /// Message property.
        /// </summary>
        [JsonPropertyName("message")]
        public string Message { get; set; } = string.Empty;

        /// <summary>
        /// خاصية RequestId.
        /// RequestId property.
        /// </summary>
        [JsonPropertyName("request_id")]
        public long RequestId { get; set; }

        /// <summary>
        /// خاصية Name.
        /// Name property.
        /// </summary>
        [JsonPropertyName("name")]
        public string? Name { get; set; }
    }

    /// <summary>
    /// فئة FloskVerifyKeyRequest.
    /// FloskVerifyKeyRequest class.
    /// </summary>
    public class FloskVerifyKeyRequest
    {
        /// <summary>
        /// خاصية Otp.
        /// Otp property.
        /// </summary>
        [JsonPropertyName("otp")]
        public string Otp { get; set; } = string.Empty;

        /// <summary>
        /// خاصية RequestId.
        /// RequestId property.
        /// </summary>
        [JsonPropertyName("request_id")]
        public long RequestId { get; set; }
    }

    /// <summary>
    /// فئة FloskVerifyKeyResponse.
    /// FloskVerifyKeyResponse class.
    /// </summary>
    public class FloskVerifyKeyResponse
    {
        /// <summary>
        /// خاصية Message.
        /// Message property.
        /// </summary>
        [JsonPropertyName("message")]
        public string Message { get; set; } = string.Empty;

        /// <summary>
        /// خاصية Key.
        /// Key property.
        /// </summary>
        [JsonPropertyName("key")]
        public string Key { get; set; } = string.Empty;

        /// <summary>
        /// خاصية AccountDetail.
        /// AccountDetail property.
        /// </summary>
        [JsonPropertyName("account_detail")]
        public FloskAccountDetail? AccountDetail { get; set; }
    }

    /// <summary>
    /// فئة FloskAccountDetail.
    /// FloskAccountDetail class.
    /// </summary>
    public class FloskAccountDetail
    {
        /// <summary>
        /// خاصية Account.
        /// Account property.
        /// </summary>
        [JsonPropertyName("account")]
        public FloskAccount? Account { get; set; }
    }

    /// <summary>
    /// فئة FloskAccount.
    /// FloskAccount class.
    /// </summary>
    public class FloskAccount
    {
        /// <summary>
        /// خاصية Wallets.
        /// Wallets property.
        /// </summary>
        [JsonPropertyName("wallets")]
        public List<FloskWallet> Wallets { get; set; } = new();
    }

    /// <summary>
    /// فئة FloskWallet.
    /// FloskWallet class.
    /// </summary>
    public class FloskWallet
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        [JsonPropertyName("id")]
        public long Id { get; set; }

        /// <summary>
        /// خاصية Currency.
        /// Currency property.
        /// </summary>
        [JsonPropertyName("currency")]
        public FloskCurrency? Currency { get; set; }

        /// <summary>
        /// خاصية Balance.
        /// Balance property.
        /// </summary>
        [JsonPropertyName("balance")]
        public decimal Balance { get; set; }
    }

    /// <summary>
    /// فئة FloskCurrency.
    /// FloskCurrency class.
    /// </summary>
    public class FloskCurrency
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        [JsonPropertyName("id")]
        public int Id { get; set; }

        /// <summary>
        /// خاصية Symbol.
        /// Symbol property.
        /// </summary>
        [JsonPropertyName("symbol")]
        public FloskLocalizedValue? Symbol { get; set; }

        /// <summary>
        /// خاصية Name.
        /// Name property.
        /// </summary>
        [JsonPropertyName("name")]
        public FloskLocalizedValue? Name { get; set; }
    }

    /// <summary>
    /// فئة FloskLocalizedValue.
    /// FloskLocalizedValue class.
    /// </summary>
    public class FloskLocalizedValue
    {
        /// <summary>
        /// خاصية En.
        /// En property.
        /// </summary>
        [JsonPropertyName("en")]
        public string? En { get; set; }

        /// <summary>
        /// خاصية Ar.
        /// Ar property.
        /// </summary>
        [JsonPropertyName("ar")]
        public string? Ar { get; set; }
    }

    /// <summary>
    /// فئة FloskPurchaseRequest.
    /// FloskPurchaseRequest class.
    /// </summary>
    public class FloskPurchaseRequest
    {
        /// <summary>
        /// خاصية SourceWalletId.
        /// SourceWalletId property.
        /// </summary>
        [JsonPropertyName("source_wallet_id")]
        public long SourceWalletId { get; set; }

        /// <summary>
        /// خاصية RequestId.
        /// RequestId property.
        /// </summary>
        [JsonPropertyName("request_id")]
        public string RequestId { get; set; } = string.Empty;

        /// <summary>
        /// خاصية TargetPhone.
        /// TargetPhone property.
        /// </summary>
        [JsonPropertyName("target_phone")]
        public long TargetPhone { get; set; }

        /// <summary>
        /// خاصية Amount.
        /// Amount property.
        /// </summary>
        [JsonPropertyName("amount")]
        public decimal Amount { get; set; }

        /// <summary>
        /// خاصية Purpose.
        /// Purpose property.
        /// </summary>
        [JsonPropertyName("purpose")]
        public string Purpose { get; set; } = string.Empty;
    }

    /// <summary>
    /// فئة FloskConfirmRequest.
    /// FloskConfirmRequest class.
    /// </summary>
    public class FloskConfirmRequest
    {
        /// <summary>
        /// خاصية Otp.
        /// Otp property.
        /// </summary>
        [JsonPropertyName("otp")]
        public int Otp { get; set; }

        /// <summary>
        /// خاصية PurchaseId.
        /// PurchaseId property.
        /// </summary>
        [JsonPropertyName("purchase_id")]
        public long PurchaseId { get; set; }
    }

    /// <summary>
    /// فئة FloskRefundRequest.
    /// FloskRefundRequest class.
    /// </summary>
    public class FloskRefundRequest
    {
        /// <summary>
        /// خاصية TransactionId.
        /// TransactionId property.
        /// </summary>
        [JsonPropertyName("transaction_id")]
        public long TransactionId { get; set; }

        /// <summary>
        /// خاصية RequestId.
        /// RequestId property.
        /// </summary>
        [JsonPropertyName("request_id")]
        public string RequestId { get; set; } = string.Empty;

        /// <summary>
        /// خاصية Amount.
        /// Amount property.
        /// </summary>
        [JsonPropertyName("amount")]
        public decimal Amount { get; set; }
    }

    /// <summary>
    /// فئة FloskApiResponse.
    /// FloskApiResponse class.
    /// </summary>
    public class FloskApiResponse<T>
    {
        /// <summary>
        /// خاصية Data.
        /// Data property.
        /// </summary>
        [JsonPropertyName("data")]
        public T? Data { get; set; }

        /// <summary>
        /// خاصية Message.
        /// Message property.
        /// </summary>
        [JsonPropertyName("message")]
        public string Message { get; set; } = string.Empty;

        /// <summary>
        /// خاصية IsSuccess.
        /// IsSuccess property.
        /// </summary>
        [JsonPropertyName("is_success")]
        public bool IsSuccess { get; set; }
    }

    /// <summary>
    /// فئة FloskPurchaseData.
    /// FloskPurchaseData class.
    /// </summary>
    public class FloskPurchaseData
    {
        /// <summary>
        /// خاصية Name.
        /// Name property.
        /// </summary>
        [JsonPropertyName("name")]
        public string? Name { get; set; }

        /// <summary>
        /// خاصية Balance.
        /// Balance property.
        /// </summary>
        [JsonPropertyName("balance")]
        public decimal Balance { get; set; }

        /// <summary>
        /// خاصية Phone.
        /// Phone property.
        /// </summary>
        [JsonPropertyName("phone")]
        public string? Phone { get; set; }

        /// <summary>
        /// خاصية Status.
        /// Status property.
        /// </summary>
        [JsonPropertyName("status")]
        public FloskLocalizedValue? Status { get; set; }

        /// <summary>
        /// خاصية Net.
        /// Net property.
        /// </summary>
        [JsonPropertyName("net")]
        public decimal Net { get; set; }

        /// <summary>
        /// خاصية Fee.
        /// Fee property.
        /// </summary>
        [JsonPropertyName("fee")]
        public decimal Fee { get; set; }

        /// <summary>
        /// خاصية Rate.
        /// Rate property.
        /// </summary>
        [JsonPropertyName("rate")]
        public decimal Rate { get; set; }

        /// <summary>
        /// خاصية Gross.
        /// Gross property.
        /// </summary>
        [JsonPropertyName("gross")]
        public decimal Gross { get; set; }

        /// <summary>
        /// خاصية ReferenceId.
        /// ReferenceId property.
        /// </summary>
        [JsonPropertyName("reference_id")]
        public string? ReferenceId { get; set; }

        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        [JsonPropertyName("id")]
        public long Id { get; set; }

        /// <summary>
        /// خاصية CreatedAt.
        /// CreatedAt property.
        /// </summary>
        [JsonPropertyName("created_at")]
        public string? CreatedAt { get; set; }
    }
}
