using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace YemenBooking.Core.Wallets.Flosk
{
    public class FloskRequestKeyRequest
    {
        [JsonPropertyName("phone")]
        public string Phone { get; set; } = string.Empty;

        [JsonPropertyName("short_code")]
        public string ShortCode { get; set; } = string.Empty;
    }

    public class FloskRequestKeyResponse
    {
        [JsonPropertyName("message")]
        public string Message { get; set; } = string.Empty;

        [JsonPropertyName("request_id")]
        public long RequestId { get; set; }

        [JsonPropertyName("name")]
        public string? Name { get; set; }
    }

    public class FloskVerifyKeyRequest
    {
        [JsonPropertyName("otp")]
        public string Otp { get; set; } = string.Empty;

        [JsonPropertyName("request_id")]
        public long RequestId { get; set; }
    }

    public class FloskVerifyKeyResponse
    {
        [JsonPropertyName("message")]
        public string Message { get; set; } = string.Empty;

        [JsonPropertyName("key")]
        public string Key { get; set; } = string.Empty;

        [JsonPropertyName("account_detail")]
        public FloskAccountDetail? AccountDetail { get; set; }
    }

    public class FloskAccountDetail
    {
        [JsonPropertyName("account")]
        public FloskAccount? Account { get; set; }
    }

    public class FloskAccount
    {
        [JsonPropertyName("wallets")]
        public List<FloskWallet> Wallets { get; set; } = new();
    }

    public class FloskWallet
    {
        [JsonPropertyName("id")]
        public long Id { get; set; }

        [JsonPropertyName("currency")]
        public FloskCurrency? Currency { get; set; }

        [JsonPropertyName("balance")]
        public decimal Balance { get; set; }
    }

    public class FloskCurrency
    {
        [JsonPropertyName("id")]
        public int Id { get; set; }

        [JsonPropertyName("symbol")]
        public FloskLocalizedValue? Symbol { get; set; }

        [JsonPropertyName("name")]
        public FloskLocalizedValue? Name { get; set; }
    }

    public class FloskLocalizedValue
    {
        [JsonPropertyName("en")]
        public string? En { get; set; }

        [JsonPropertyName("ar")]
        public string? Ar { get; set; }
    }

    public class FloskPurchaseRequest
    {
        [JsonPropertyName("source_wallet_id")]
        public long SourceWalletId { get; set; }

        [JsonPropertyName("request_id")]
        public string RequestId { get; set; } = string.Empty;

        [JsonPropertyName("target_phone")]
        public long TargetPhone { get; set; }

        [JsonPropertyName("amount")]
        public decimal Amount { get; set; }

        [JsonPropertyName("purpose")]
        public string Purpose { get; set; } = string.Empty;
    }

    public class FloskConfirmRequest
    {
        [JsonPropertyName("otp")]
        public int Otp { get; set; }

        [JsonPropertyName("purchase_id")]
        public long PurchaseId { get; set; }
    }

    public class FloskRefundRequest
    {
        [JsonPropertyName("transaction_id")]
        public long TransactionId { get; set; }

        [JsonPropertyName("request_id")]
        public string RequestId { get; set; } = string.Empty;

        [JsonPropertyName("amount")]
        public decimal Amount { get; set; }
    }

    public class FloskApiResponse<T>
    {
        [JsonPropertyName("data")]
        public T? Data { get; set; }

        [JsonPropertyName("message")]
        public string Message { get; set; } = string.Empty;

        [JsonPropertyName("is_success")]
        public bool IsSuccess { get; set; }
    }

    public class FloskPurchaseData
    {
        [JsonPropertyName("name")]
        public string? Name { get; set; }

        [JsonPropertyName("balance")]
        public decimal Balance { get; set; }

        [JsonPropertyName("phone")]
        public string? Phone { get; set; }

        [JsonPropertyName("status")]
        public FloskLocalizedValue? Status { get; set; }

        [JsonPropertyName("net")]
        public decimal Net { get; set; }

        [JsonPropertyName("fee")]
        public decimal Fee { get; set; }

        [JsonPropertyName("rate")]
        public decimal Rate { get; set; }

        [JsonPropertyName("gross")]
        public decimal Gross { get; set; }

        [JsonPropertyName("reference_id")]
        public string? ReferenceId { get; set; }

        [JsonPropertyName("id")]
        public long Id { get; set; }

        [JsonPropertyName("created_at")]
        public string? CreatedAt { get; set; }
    }
}
