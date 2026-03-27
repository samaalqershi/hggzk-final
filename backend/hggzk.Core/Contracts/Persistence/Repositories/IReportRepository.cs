using YemenBooking.Core.Entities;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace YemenBooking.Core.Interfaces.Repositories;

/// <summary>
/// واجهة مستودع التقرير repository.
/// Report repository repository interface.
/// </summary>
public interface IReportRepository : IRepository<Report>
{
    /// <summary>
    /// ينشئ التقرير.
    /// Creates report.
    /// </summary>
    Task<Report> CreateReportAsync(Report report, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب التقرير حسب المعرّف.
    /// Gets report by id.
    /// </summary>
    Task<Report?> GetReportByIdAsync(Guid reportId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحدّث التقرير.
    /// Updates report.
    /// </summary>
    Task<Report> UpdateReportAsync(Report report, CancellationToken cancellationToken = default);

    /// <summary>
    /// يحذف التقرير.
    /// Deletes report.
    /// </summary>
    Task<bool> DeleteReportAsync(Guid reportId, CancellationToken cancellationToken = default);

    /// <summary>
    /// يجلب التقارير.
    /// Gets reports.
    /// </summary>
    Task<IEnumerable<Report>> GetReportsAsync(
        Guid? reporterUserId = null,
        Guid? reportedUserId = null,
        Guid? reportedPropertyId = null,
        CancellationToken cancellationToken = default);
} 
