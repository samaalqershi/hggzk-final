using System;
using System.Linq.Expressions;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Specifications
{
    /// <summary>
    /// معاملات البحث في المدفوعات
    /// Payment search parameters
    /// </summary>
    public class PaymentSearchParameters
    {
        /// <summary>
        /// خاصية PaymentMethod.
        /// PaymentMethod property.
        /// </summary>
        public string? PaymentMethod { get; set; }
        /// <summary>
        /// خاصية Status.
        /// Status property.
        /// </summary>
        public string? Status { get; set; }
        /// <summary>
        /// خاصية UserId.
        /// UserId property.
        /// </summary>
        public Guid? UserId { get; set; }
        /// <summary>
        /// خاصية BookingId.
        /// BookingId property.
        /// </summary>
        public Guid? BookingId { get; set; }
        /// <summary>
        /// خاصية StartDate.
        /// StartDate property.
        /// </summary>
        public DateTime? StartDate { get; set; }
        /// <summary>
        /// خاصية EndDate.
        /// EndDate property.
        /// </summary>
        public DateTime? EndDate { get; set; }
        /// <summary>
        /// خاصية PageNumber.
        /// PageNumber property.
        /// </summary>
        public int PageNumber { get; set; } = 1;
        /// <summary>
        /// خاصية PageSize.
        /// PageSize property.
        /// </summary>
        public int PageSize { get; set; } = 10;
    }

    /// <summary>
    /// مواصفة البحث في المدفوعات
    /// Specification for searching payments
    /// </summary>
    public class PaymentSearchSpecification : BaseSpecification<Payment>
    {
        /// <summary>
        /// منشئ PaymentSearchSpecification.
        /// PaymentSearchSpecification constructor.
        /// </summary>
        public PaymentSearchSpecification(PaymentSearchParameters parameters)
            : base()
        {
            AddCriteria(p => true);

            if (!string.IsNullOrWhiteSpace(parameters.PaymentMethod))
            {
                var m = parameters.PaymentMethod.Trim().ToLower();
                AddCriteria(p => p.PaymentMethod.ToString().ToLower() == m);
            }

            if (!string.IsNullOrWhiteSpace(parameters.Status))
            {
                var s = parameters.Status.Trim().ToLower();
                AddCriteria(p => p.Status.ToString().ToLower() == s);
            }

            if (parameters.UserId.HasValue)
                AddCriteria(p => p.Booking.UserId == parameters.UserId.Value);

            if (parameters.BookingId.HasValue)
                AddCriteria(p => p.BookingId == parameters.BookingId.Value);

            if (parameters.StartDate.HasValue)
                AddCriteria(p => p.PaymentDate >= parameters.StartDate.Value);

            if (parameters.EndDate.HasValue)
                AddCriteria(p => p.PaymentDate <= parameters.EndDate.Value);

            if (parameters.PageNumber > 0 && parameters.PageSize > 0)
                ApplyPaging(parameters.PageNumber, parameters.PageSize);

            ApplyOrderBy(p => p.PaymentDate);
            ApplyNoTracking();
            ApplySplitQuery();
        }
    }
} 