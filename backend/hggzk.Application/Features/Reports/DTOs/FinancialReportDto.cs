using System;
using System.Collections.Generic;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Reports.DTOs {
    /// <summary>
    /// DTO للتقرير المالي
    /// Financial Report DTO
    /// </summary>
    public class FinancialReportDto
    {
        /// <summary>
        /// خاصية StartDate.
        /// StartDate property.
        /// </summary>
        public DateTime StartDate { get; set; }
        /// <summary>
        /// خاصية EndDate.
        /// EndDate property.
        /// </summary>
        public DateTime EndDate { get; set; }
        /// <summary>
        /// خاصية TotalRevenue.
        /// TotalRevenue property.
        /// </summary>
        public decimal TotalRevenue { get; set; }
        /// <summary>
        /// خاصية TotalExpenses.
        /// TotalExpenses property.
        /// </summary>
        public decimal TotalExpenses { get; set; }
        /// <summary>
        /// خاصية TotalCommissions.
        /// TotalCommissions property.
        /// </summary>
        public decimal TotalCommissions { get; set; }
        /// <summary>
        /// خاصية TotalRefunds.
        /// TotalRefunds property.
        /// </summary>
        public decimal TotalRefunds { get; set; }
        /// <summary>
        /// خاصية NetProfit.
        /// NetProfit property.
        /// </summary>
        public decimal NetProfit { get; set; }
        /// <summary>
        /// خاصية TransactionCount.
        /// TransactionCount property.
        /// </summary>
        public int TransactionCount { get; set; }
        /// <summary>
        /// خاصية TransactionsByType.
        /// TransactionsByType property.
        /// </summary>
        public Dictionary<TransactionType, decimal> TransactionsByType { get; set; }
    }
}
