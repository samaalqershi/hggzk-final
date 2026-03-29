using System.Collections;
using System.Dynamic;
using System.Reflection;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace YemenBooking.Api.Infrastructure.Localization;

/// <summary>
/// Localizes user-facing message fields before sending object results.
/// يعرّب حقول الرسائل الموجهة للمستخدم قبل إرسال نتائج الكائنات.
/// </summary>
public sealed class LocalizedResponseFilter : IAsyncResultFilter
{
    private static readonly HashSet<string> LocalizablePropertyNames =
        new(StringComparer.OrdinalIgnoreCase)
        {
            "message",
            "messages",
            "title",
            "error",
            "errors",
            "errormessage",
            "statusmessage",
            "successmessage",
            "usermessage",
            "warningmessage",
            "responsemessage",
            "fixmessage",
            "name",
            "description",
            "displayname",
            "shortdescription",
            "caption",
            "alttext",
            "action",
            "searchstrategy",
            "suggestedactions",
            "relaxedfilters",
            "besttimetovisit",
            "climate"
        };

    private readonly IBackendTextLocalizer _localizer;

    public LocalizedResponseFilter(IBackendTextLocalizer localizer)
    {
        _localizer = localizer;
    }

    public async Task OnResultExecutionAsync(ResultExecutingContext context, ResultExecutionDelegate next)
    {
        if (context.Result is ObjectResult objectResult && objectResult.Value != null)
        {
            var visited = new HashSet<object>(ReferenceEqualityComparer.Instance);
            objectResult.Value = LocalizeNode(objectResult.Value, propertyName: null, visited);
        }
        else if (context.Result is JsonResult jsonResult && jsonResult.Value != null)
        {
            var visited = new HashSet<object>(ReferenceEqualityComparer.Instance);
            jsonResult.Value = LocalizeNode(jsonResult.Value, propertyName: null, visited);
        }

        await next();
    }

    private object? LocalizeNode(object? value, string? propertyName, HashSet<object> visited)
    {
        if (value == null)
        {
            return null;
        }

        if (value is string text)
        {
            return propertyName == null || ShouldTranslate(propertyName)
                ? _localizer.Translate(text)
                : text;
        }

        var type = value.GetType();
        if (IsSimpleValue(type))
        {
            return value;
        }

        if (!type.IsValueType && !visited.Add(value))
        {
            return value;
        }

        if (value is IDictionary dictionary)
        {
            return LocalizeDictionary(dictionary, visited);
        }

        if (value is IEnumerable enumerable)
        {
            return LocalizeEnumerable(enumerable, propertyName, visited);
        }

        if (IsAnonymousType(type))
        {
            return LocalizeAnonymousObject(value, visited);
        }

        LocalizeMutableObject(value, visited);
        return value;
    }

    private IDictionary<string, object?> LocalizeAnonymousObject(object value, HashSet<object> visited)
    {
        var output = new ExpandoObject() as IDictionary<string, object?>;
        foreach (var property in value.GetType().GetProperties(BindingFlags.Public | BindingFlags.Instance))
        {
            if (!property.CanRead)
            {
                continue;
            }

            output[property.Name] = LocalizeNode(property.GetValue(value), property.Name, visited);
        }

        return output;
    }

    private void LocalizeMutableObject(object value, HashSet<object> visited)
    {
        foreach (var property in value.GetType().GetProperties(BindingFlags.Public | BindingFlags.Instance))
        {
            if (!property.CanRead)
            {
                continue;
            }

            var localizedValue = LocalizeNode(property.GetValue(value), property.Name, visited);

            if (property.CanWrite && property.SetMethod is { IsPublic: true })
            {
                property.SetValue(value, ConvertValueForProperty(localizedValue, property.PropertyType));
            }
        }
    }

    private object LocalizeDictionary(IDictionary dictionary, HashSet<object> visited)
    {
        var output = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
        var changed = false;
        foreach (var (key, rawValue) in EnumerateDictionary(dictionary))
        {
            var localizedValue = LocalizeNode(rawValue, key, visited);
            if (!Equals(localizedValue, rawValue))
            {
                changed = true;
            }

            output[key] = localizedValue;
        }

        return changed ? output : dictionary;
    }

    private object LocalizeEnumerable(IEnumerable enumerable, string? propertyName, HashSet<object> visited)
    {
        var stringItems = new List<string>();
        var allStrings = true;
        var itemCount = 0;

        foreach (var item in enumerable)
        {
            itemCount++;
            var localizedItem = LocalizeNode(item, propertyName, visited);
            if (localizedItem is string stringValue)
            {
                stringItems.Add(stringValue);
            }
            else
            {
                allStrings = false;
            }
        }

        return allStrings && itemCount > 0 ? stringItems.ToArray() : enumerable;
    }

    private static object? ConvertValueForProperty(object? value, Type propertyType)
    {
        if (value == null)
        {
            return null;
        }

        if (propertyType.IsInstanceOfType(value))
        {
            return value;
        }

        if (value is string[] stringArray)
        {
            if (propertyType == typeof(string[]))
            {
                return stringArray;
            }

            if (propertyType == typeof(List<string>))
            {
                return stringArray.ToList();
            }

            if (propertyType == typeof(IReadOnlyList<string>)
                || propertyType == typeof(IList<string>)
                || propertyType == typeof(ICollection<string>)
                || propertyType == typeof(IEnumerable<string>))
            {
                return stringArray.ToList();
            }

            if (propertyType.IsGenericType && propertyType.GetGenericArguments() is [var itemType] && itemType == typeof(string))
            {
                var candidate = TryCreateStringCollection(propertyType, stringArray);
                if (candidate != null)
                {
                    return candidate;
                }
            }
        }

        if (value is IDictionary dictionary && propertyType.IsGenericType)
        {
            var genericArgs = propertyType.GetGenericArguments();
            if (genericArgs.Length == 2 && genericArgs[0] == typeof(string))
            {
                var candidate = TryCreateTypedDictionary(propertyType, genericArgs[1], dictionary);
                if (candidate != null)
                {
                    return candidate;
                }
            }
        }

        return value;
    }

    private static object? TryCreateStringCollection(Type propertyType, IEnumerable<string> values)
    {
        var valueList = values.ToList();

        var enumerableCtor = propertyType.GetConstructor(new[] { typeof(IEnumerable<string>) });
        if (enumerableCtor != null)
        {
            return enumerableCtor.Invoke(new object[] { valueList });
        }

        var defaultCtor = propertyType.GetConstructor(Type.EmptyTypes);
        if (defaultCtor == null)
        {
            return null;
        }

        var collection = defaultCtor.Invoke(null);
        var addMethod = propertyType.GetMethod("Add", new[] { typeof(string) });
        if (addMethod == null)
        {
            return null;
        }

        foreach (var item in valueList)
        {
            addMethod.Invoke(collection, new object[] { item });
        }

        return collection;
    }

    private static object? TryCreateTypedDictionary(Type propertyType, Type valueType, IDictionary dictionary)
    {
        var concreteType = propertyType.IsInterface
            ? typeof(Dictionary<,>).MakeGenericType(typeof(string), valueType)
            : propertyType;

        var collection = Activator.CreateInstance(concreteType);
        if (collection == null)
        {
            return null;
        }

        var addMethod = concreteType.GetMethod("Add", new[] { typeof(string), valueType });
        if (addMethod == null)
        {
            return null;
        }

        foreach (var (key, rawValue) in EnumerateDictionary(dictionary))
        {
            var convertedValue = ConvertDictionaryValue(rawValue, valueType);
            if (convertedValue == null && Nullable.GetUnderlyingType(valueType) == null && valueType.IsValueType)
            {
                return null;
            }

            addMethod.Invoke(collection, new[] { key, convertedValue });
        }

        return collection;
    }

    private static IEnumerable<(string Key, object? Value)> EnumerateDictionary(IDictionary dictionary)
    {
        foreach (var item in dictionary)
        {
            if (item is DictionaryEntry entry)
            {
                yield return (entry.Key?.ToString() ?? string.Empty, entry.Value);
                continue;
            }

            var itemType = item?.GetType();
            var keyProperty = itemType?.GetProperty("Key");
            var valueProperty = itemType?.GetProperty("Value");
            if (keyProperty != null && valueProperty != null)
            {
                yield return (
                    keyProperty.GetValue(item)?.ToString() ?? string.Empty,
                    valueProperty.GetValue(item));
            }
        }
    }

    private static object? ConvertDictionaryValue(object? value, Type targetType)
    {
        if (value == null)
        {
            return null;
        }

        if (targetType.IsInstanceOfType(value))
        {
            return value;
        }

        var underlyingType = Nullable.GetUnderlyingType(targetType) ?? targetType;

        try
        {
            if (underlyingType.IsEnum)
            {
                return value is string enumName
                    ? Enum.Parse(underlyingType, enumName, ignoreCase: true)
                    : Enum.ToObject(underlyingType, value);
            }

            return Convert.ChangeType(value, underlyingType);
        }
        catch
        {
            return null;
        }
    }

    private static bool IsAnonymousType(Type type) =>
        Attribute.IsDefined(type, typeof(System.Runtime.CompilerServices.CompilerGeneratedAttribute), inherit: false)
        && type.IsGenericType
        && type.Name.Contains("AnonymousType", StringComparison.Ordinal)
        && (type.Name.StartsWith("<>", StringComparison.Ordinal) || type.Name.StartsWith("VB$", StringComparison.Ordinal));

    private static bool ShouldTranslate(string? propertyName) =>
        !string.IsNullOrWhiteSpace(propertyName)
        && LocalizablePropertyNames.Contains(propertyName);

    private static bool IsSimpleValue(Type type)
    {
        var underlyingType = Nullable.GetUnderlyingType(type) ?? type;
        return underlyingType.IsPrimitive
               || underlyingType.IsEnum
               || underlyingType == typeof(decimal)
               || underlyingType == typeof(Guid)
               || underlyingType == typeof(DateTime)
               || underlyingType == typeof(DateTimeOffset)
               || underlyingType == typeof(TimeSpan);
    }
}
