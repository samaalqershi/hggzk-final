using System.Text.Json;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Reviews;

internal static class ReviewImageMetadataHelper
{
    private const string ThumbnailUrlKey = "thumbnailUrl";

    public static string BuildTags(string? thumbnailUrl)
    {
        if (string.IsNullOrWhiteSpace(thumbnailUrl))
        {
            return string.Empty;
        }

        return JsonSerializer.Serialize(new Dictionary<string, string>
        {
            [ThumbnailUrlKey] = thumbnailUrl
        });
    }

    public static string GetThumbnailUrl(ReviewImage image)
    {
        if (!string.IsNullOrWhiteSpace(image.Tags))
        {
            try
            {
                var values = JsonSerializer.Deserialize<Dictionary<string, string>>(image.Tags);
                if (values != null &&
                    values.TryGetValue(ThumbnailUrlKey, out var thumbnailUrl) &&
                    !string.IsNullOrWhiteSpace(thumbnailUrl))
                {
                    return thumbnailUrl;
                }
            }
            catch
            {
                // Ignore malformed legacy metadata and fall back to the original URL.
            }
        }

        return image.Url ?? string.Empty;
    }
}
