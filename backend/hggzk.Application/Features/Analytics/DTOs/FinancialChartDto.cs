using System;
using System.Collections.Generic;

namespace YemenBooking.Application.Features.Analytics.DTOs {
    /// <summary>
    /// بيانات المخططات البيانية المالية
    /// Financial Chart Data DTO
    /// </summary>
    public class FinancialChartDto
    {
        /// <summary>
        /// خاصية Label.
        /// Label property.
        /// </summary>
        public string Label { get; set; }
        /// <summary>
        /// خاصية Value.
        /// Value property.
        /// </summary>
        public decimal Value { get; set; }
        /// <summary>
        /// خاصية Color.
        /// Color property.
        /// </summary>
        public string Color { get; set; }
        /// <summary>
        /// خاصية Category.
        /// Category property.
        /// </summary>
        public string Category { get; set; }
        /// <summary>
        /// خاصية Date.
        /// Date property.
        /// </summary>
        public DateTime? Date { get; set; }
    }

    /// <summary>
    /// الملخص المالي الشامل
    /// Comprehensive Financial Summary DTO
    /// </summary>
    public class FinancialSummaryDto
    {
        // الأصول والخصوم
        /// <summary>
        /// خاصية TotalAssets.
        /// TotalAssets property.
        /// </summary>
        public decimal TotalAssets { get; set; }
        /// <summary>
        /// خاصية TotalLiabilities.
        /// TotalLiabilities property.
        /// </summary>
        public decimal TotalLiabilities { get; set; }
        /// <summary>
        /// خاصية TotalEquity.
        /// TotalEquity property.
        /// </summary>
        public decimal TotalEquity { get; set; }
        /// <summary>
        /// خاصية CurrentAssets.
        /// CurrentAssets property.
        /// </summary>
        public decimal CurrentAssets { get; set; }
        /// <summary>
        /// خاصية CurrentLiabilities.
        /// CurrentLiabilities property.
        /// </summary>
        public decimal CurrentLiabilities { get; set; }
        /// <summary>
        /// خاصية WorkingCapital.
        /// WorkingCapital property.
        /// </summary>
        public decimal WorkingCapital { get; set; }
        
        // نسب السيولة
        /// <summary>
        /// خاصية CurrentRatio.
        /// CurrentRatio property.
        /// </summary>
        public decimal CurrentRatio { get; set; }
        /// <summary>
        /// خاصية QuickRatio.
        /// QuickRatio property.
        /// </summary>
        public decimal QuickRatio { get; set; }
        /// <summary>
        /// خاصية CashRatio.
        /// CashRatio property.
        /// </summary>
        public decimal CashRatio { get; set; }
        
        // نسب الديون
        /// <summary>
        /// خاصية DebtToEquityRatio.
        /// DebtToEquityRatio property.
        /// </summary>
        public decimal DebtToEquityRatio { get; set; }
        /// <summary>
        /// خاصية DebtToAssetsRatio.
        /// DebtToAssetsRatio property.
        /// </summary>
        public decimal DebtToAssetsRatio { get; set; }
        
        // نسب الربحية
        /// <summary>
        /// خاصية ReturnOnAssets.
        /// ReturnOnAssets property.
        /// </summary>
        public decimal ReturnOnAssets { get; set; }
        /// <summary>
        /// خاصية ReturnOnEquity.
        /// ReturnOnEquity property.
        /// </summary>
        public decimal ReturnOnEquity { get; set; }
        /// <summary>
        /// خاصية GrossProfitMargin.
        /// GrossProfitMargin property.
        /// </summary>
        public decimal GrossProfitMargin { get; set; }
        /// <summary>
        /// خاصية NetProfitMargin.
        /// NetProfitMargin property.
        /// </summary>
        public decimal NetProfitMargin { get; set; }
        /// <summary>
        /// خاصية OperatingProfitMargin.
        /// OperatingProfitMargin property.
        /// </summary>
        public decimal OperatingProfitMargin { get; set; }
        
        // التدفق النقدي
        /// <summary>
        /// خاصية CashFromOperations.
        /// CashFromOperations property.
        /// </summary>
        public decimal CashFromOperations { get; set; }
        /// <summary>
        /// خاصية CashFromInvesting.
        /// CashFromInvesting property.
        /// </summary>
        public decimal CashFromInvesting { get; set; }
        /// <summary>
        /// خاصية CashFromFinancing.
        /// CashFromFinancing property.
        /// </summary>
        public decimal CashFromFinancing { get; set; }
        /// <summary>
        /// خاصية NetCashFlow.
        /// NetCashFlow property.
        /// </summary>
        public decimal NetCashFlow { get; set; }
        
        // مؤشرات إضافية
        /// <summary>
        /// خاصية ActiveBookings.
        /// ActiveBookings property.
        /// </summary>
        public int ActiveBookings { get; set; }
        /// <summary>
        /// خاصية TotalProperties.
        /// TotalProperties property.
        /// </summary>
        public int TotalProperties { get; set; }
        /// <summary>
        /// خاصية TotalUnits.
        /// TotalUnits property.
        /// </summary>
        public int TotalUnits { get; set; }
        /// <summary>
        /// خاصية OccupancyRate.
        /// OccupancyRate property.
        /// </summary>
        public decimal OccupancyRate { get; set; }
        /// <summary>
        /// خاصية AverageBookingValue.
        /// AverageBookingValue property.
        /// </summary>
        public decimal AverageBookingValue { get; set; }
        /// <summary>
        /// خاصية CustomerAcquisitionCost.
        /// CustomerAcquisitionCost property.
        /// </summary>
        public decimal CustomerAcquisitionCost { get; set; }
        /// <summary>
        /// خاصية CustomerLifetimeValue.
        /// CustomerLifetimeValue property.
        /// </summary>
        public decimal CustomerLifetimeValue { get; set; }
        
        // التاريخ
        /// <summary>
        /// خاصية CalculatedAt.
        /// CalculatedAt property.
        /// </summary>
        public DateTime CalculatedAt { get; set; }
        /// <summary>
        /// خاصية PeriodStart.
        /// PeriodStart property.
        /// </summary>
        public DateTime PeriodStart { get; set; }
        /// <summary>
        /// خاصية PeriodEnd.
        /// PeriodEnd property.
        /// </summary>
        public DateTime PeriodEnd { get; set; }
    }

    /// <summary>
    /// البيانات التحليلية للإيرادات والمصروفات
    /// Revenue and Expense Analytics DTO
    /// </summary>
    public class FinancialAnalyticsDto
    {
        /// <summary>
        /// خاصية RevenueByCategory.
        /// RevenueByCategory property.
        /// </summary>
        public List<FinancialChartDto> RevenueByCategory { get; set; }
        /// <summary>
        /// خاصية ExpensesByCategory.
        /// ExpensesByCategory property.
        /// </summary>
        public List<FinancialChartDto> ExpensesByCategory { get; set; }
        /// <summary>
        /// خاصية CashFlowOverTime.
        /// CashFlowOverTime property.
        /// </summary>
        public List<FinancialChartDto> CashFlowOverTime { get; set; }
        /// <summary>
        /// خاصية RevenueOverTime.
        /// RevenueOverTime property.
        /// </summary>
        public List<FinancialChartDto> RevenueOverTime { get; set; }
        /// <summary>
        /// خاصية ExpensesOverTime.
        /// ExpensesOverTime property.
        /// </summary>
        public List<FinancialChartDto> ExpensesOverTime { get; set; }
        /// <summary>
        /// خاصية ProfitOverTime.
        /// ProfitOverTime property.
        /// </summary>
        public List<FinancialChartDto> ProfitOverTime { get; set; }
        
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
        /// خاصية NetProfit.
        /// NetProfit property.
        /// </summary>
        public decimal NetProfit { get; set; }
        /// <summary>
        /// خاصية ProfitMargin.
        /// ProfitMargin property.
        /// </summary>
        public decimal ProfitMargin { get; set; }
        
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
    }
}
