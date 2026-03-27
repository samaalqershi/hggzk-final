namespace YemenBooking.Application.Common.Exceptions;

/// <summary>
/// Represents a business rule violation exception.
/// يمثل استثناء انتهاك قاعدة عمل.
/// </summary>
public class BusinessRuleException : Exception
{
    /// <summary>
    /// Gets the name of the violated rule.
    /// يحصل على اسم القاعدة المنتهكة.
    /// </summary>
    public string RuleName { get; }

    /// <summary>
    /// Gets the rule code.
    /// يحصل على رمز القاعدة.
    /// </summary>
    public string? RuleCode { get; }

    /// <summary>
    /// Gets the contextual object associated with the violated rule, if any.
    /// يحصل على الكائن السياقي المرتبط بالقاعدة المنتهكة، إن وجد.
    /// </summary>
    public object? RelatedObject { get; }

    /// <summary>
    /// Creates a business rule exception with the specified rule name and error message.
    /// ينشئ استثناء انتهاك قاعدة عمل باسم القاعدة ورسالة الخطأ.
    /// </summary>
    /// <param name="ruleName">The violated rule name. اسم القاعدة المنتهكة.</param>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    public BusinessRuleException(string ruleName, string message) : base(message)
    {
        RuleName = ruleName;
    }

    /// <summary>
    /// Creates a business rule exception with the specified rule code.
    /// ينشئ استثناء انتهاك قاعدة عمل مع رمز القاعدة المحدد.
    /// </summary>
    /// <param name="ruleName">The violated rule name. اسم القاعدة المنتهكة.</param>
    /// <param name="ruleCode">The rule code. رمز القاعدة.</param>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    public BusinessRuleException(string ruleName, string ruleCode, string message) : base(message)
    {
        RuleName = ruleName;
        RuleCode = ruleCode;
    }

    /// <summary>
    /// Creates a business rule exception with a related context object.
    /// ينشئ استثناء انتهاك قاعدة عمل مع كائن سياقي مرتبط.
    /// </summary>
    /// <param name="ruleName">The violated rule name. اسم القاعدة المنتهكة.</param>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    /// <param name="relatedObject">The related context or object. الكائن أو السياق المرتبط.</param>
    public BusinessRuleException(string ruleName, string message, object? relatedObject) : base(message)
    {
        RuleName = ruleName;
        RelatedObject = relatedObject;
    }

    /// <summary>
    /// Creates a business rule exception with both the rule code and related context.
    /// ينشئ استثناء انتهاك قاعدة عمل مع رمز القاعدة والسياق المرتبط.
    /// </summary>
    /// <param name="ruleName">The violated rule name. اسم القاعدة المنتهكة.</param>
    /// <param name="ruleCode">The rule code. رمز القاعدة.</param>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    /// <param name="relatedObject">The related context or object. الكائن أو السياق المرتبط.</param>
    public BusinessRuleException(string ruleName, string ruleCode, string message, object? relatedObject) : base(message)
    {
        RuleName = ruleName;
        RuleCode = ruleCode;
        RelatedObject = relatedObject;
    }

    /// <summary>
    /// Creates a business rule exception with an inner exception to preserve the original error chain.
    /// ينشئ استثناء انتهاك قاعدة عمل مع استثناء داخلي للحفاظ على سلسلة الخطأ الأصلية.
    /// </summary>
    /// <param name="ruleName">The violated rule name. اسم القاعدة المنتهكة.</param>
    /// <param name="message">The error message. رسالة الخطأ.</param>
    /// <param name="innerException">The inner exception. الاستثناء الداخلي.</param>
    public BusinessRuleException(string ruleName, string message, Exception innerException) : base(message, innerException)
    {
        RuleName = ruleName;
    }
}
