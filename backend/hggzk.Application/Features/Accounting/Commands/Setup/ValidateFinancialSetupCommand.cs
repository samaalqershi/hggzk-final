using System;
using System.Collections.Generic;
using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Accounting.Commands.Setup
{
    /// <summary>
    /// يمثل أمرًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area command.
    /// </summary>
    public class ValidateFinancialSetupCommand : IRequest<ResultDto<FinancialSetupValidationResult>>
    {
        /// <summary>
        /// Gets or sets whether customer accounts should be validated.
        /// يحصل أو يعيّن ما إذا كان يجب التحقق من حسابات العملاء.
        /// </summary>
        public bool CheckCustomerAccounts { get; set; } = true;

        /// <summary>
        /// Gets or sets whether owner accounts should be validated.
        /// يحصل أو يعيّن ما إذا كان يجب التحقق من حسابات الملاك.
        /// </summary>
        public bool CheckOwnerAccounts { get; set; } = true;

        /// <summary>
        /// Gets or sets whether system accounts should be validated.
        /// يحصل أو يعيّن ما إذا كان يجب التحقق من حسابات النظام.
        /// </summary>
        public bool CheckSystemAccounts { get; set; } = true;

        /// <summary>
        /// Gets or sets whether detected issues should be fixed automatically.
        /// يحصل أو يعيّن ما إذا كانت المشاكل المكتشفة تُصلح تلقائيًا.
        /// </summary>
        public bool AutoFix { get; set; } = false;
    }

    /// <summary>
    /// Represents the result of validating the accounting setup.
    /// يمثل نتيجة التحقق من الإعدادات المحاسبية.
    /// </summary>
    public class FinancialSetupValidationResult
    {
        /// <summary>
        /// Gets or sets whether the setup is valid.
        /// يحصل أو يعيّن ما إذا كان الإعداد صحيحًا.
        /// </summary>
        public bool IsValid { get; set; }

        /// <summary>
        /// Gets or sets the number of detected issues.
        /// يحصل أو يعيّن عدد المشاكل المكتشفة.
        /// </summary>
        public int IssuesFound { get; set; }

        /// <summary>
        /// Gets or sets the number of fixed issues.
        /// يحصل أو يعيّن عدد المشاكل المصححة.
        /// </summary>
        public int IssuesFixed { get; set; }

        /// <summary>
        /// Gets or sets the issue details.
        /// يحصل أو يعيّن تفاصيل المشاكل.
        /// </summary>
        public List<ValidationIssue> Issues { get; set; } = new List<ValidationIssue>();

    /// <summary>
    /// ينشئ مثيلًا جديدًا مع الاعتمادات المطلوبة.
    /// Creates a new instance with its required dependencies.
    /// </summary>
        public AccountsSummary Summary { get; set; } = new AccountsSummary();
    }

    /// <summary>
    /// يمثل عنصرًا ضمن نطاق النطاق الحالي.
    /// Represents an item in the current feature area feature area.
    /// </summary>
    public class ValidationIssue
    {
        /// <summary>
        /// Gets or sets the issue type.
        /// يحصل أو يعيّن نوع المشكلة.
        /// </summary>
        public string Type { get; set; }

        /// <summary>
        /// Gets or sets the issue description.
        /// يحصل أو يعيّن وصف المشكلة.
        /// </summary>
        public string Description { get; set; }

        /// <summary>
        /// Gets or sets the affected entity name.
        /// يحصل أو يعيّن اسم الكيان المتأثر.
        /// </summary>
        public string AffectedEntity { get; set; }

        /// <summary>
        /// Gets or sets the affected entity identifier.
        /// يحصل أو يعيّن معرف الكيان المتأثر.
        /// </summary>
        public Guid? EntityId { get; set; }

        /// <summary>
        /// Gets or sets whether the issue was fixed.
        /// يحصل أو يعيّن ما إذا كانت المشكلة قد أُصلحت.
        /// </summary>
        public bool IsFixed { get; set; }

        /// <summary>
        /// Gets or sets the fix message.
        /// يحصل أو يعيّن رسالة الإصلاح.
        /// </summary>
        public string FixMessage { get; set; }
    }

    /// <summary>
    /// Represents summary metrics for financial accounts.
    /// يمثل مؤشرات ملخص الحسابات المالية.
    /// </summary>
    public class AccountsSummary
    {
        /// <summary>
        /// Gets or sets the customer accounts count.
        /// يحصل أو يعيّن عدد حسابات العملاء.
        /// </summary>
        public int CustomerAccountsCount { get; set; }

        /// <summary>
        /// Gets or sets the owner accounts count.
        /// يحصل أو يعيّن عدد حسابات الملاك.
        /// </summary>
        public int OwnerAccountsCount { get; set; }

        /// <summary>
        /// Gets or sets the system accounts count.
        /// يحصل أو يعيّن عدد حسابات النظام.
        /// </summary>
        public int SystemAccountsCount { get; set; }

        /// <summary>
        /// Gets or sets the number of customers without accounts.
        /// يحصل أو يعيّن عدد العملاء بدون حسابات.
        /// </summary>
        public int CustomersWithoutAccounts { get; set; }

        /// <summary>
        /// Gets or sets the number of owners without accounts.
        /// يحصل أو يعيّن عدد الملاك بدون حسابات.
        /// </summary>
        public int OwnersWithoutAccounts { get; set; }

        /// <summary>
        /// Gets or sets the number of owners with a single account.
        /// يحصل أو يعيّن عدد الملاك بحساب واحد فقط.
        /// </summary>
        public int OwnersWithSingleAccount { get; set; }
    }
}
