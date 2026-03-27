using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Infrastructure.Data.Context;

namespace YemenBooking.Infrastructure.Repositories.Admin;

/// <summary>
/// يمثل مستودعًا للوصول إلى البلاغات.
/// Represents a repository for accessing reports.
/// </summary>
public class ReportRepository : BaseRepository<Report>, IReportRepository
{
/// <summary>
/// ينشئ المستودع مع سياق قاعدة البيانات المشترك.
/// Creates the repository with the shared database context.
/// </summary>
    public ReportRepository(YemenBookingDbContext context) : base(context)
    {
    }

/// <summary>
/// ينشئ سجلًا جديدًا في المستودع.
/// Creates a new record in the repository.
/// </summary>
    public async Task<Report> CreateReportAsync(Report report, CancellationToken cancellationToken = default)
    {
        _context.Reports.Add(report);
        return report;
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<Report?> GetReportByIdAsync(Guid reportId, CancellationToken cancellationToken = default)
    {
        return await _context.Reports
            .Include(r => r.ReporterUser)
            .Include(r => r.ReportedUser)
            .Include(r => r.ReportedProperty)
            .FirstOrDefaultAsync(r => r.Id == reportId, cancellationToken);
    }

/// <summary>
/// يسترجع البيانات المطلوبة من المستودع.
/// Retrieves the requested data from the repository.
/// </summary>
    public async Task<IEnumerable<Report>> GetReportsAsync(Guid? reporterUserId = null, Guid? reportedUserId = null, Guid? reportedPropertyId = null, CancellationToken cancellationToken = default)
    {
        var query = _context.Reports.AsQueryable();
        if (reporterUserId.HasValue)
            query = query.Where(r => r.ReporterUserId == reporterUserId.Value);
        if (reportedUserId.HasValue)
            query = query.Where(r => r.ReportedUserId == reportedUserId.Value);
        if (reportedPropertyId.HasValue)
            query = query.Where(r => r.ReportedPropertyId == reportedPropertyId.Value);
        return await query
            .Include(r => r.ReporterUser)
            .Include(r => r.ReportedUser)
            .Include(r => r.ReportedProperty)
            .ToListAsync(cancellationToken);
    }

/// <summary>
/// يحدّث السجل المطلوب في المستودع.
/// Updates the requested record in the repository.
/// </summary>
    public async Task<Report> UpdateReportAsync(Report report, CancellationToken cancellationToken = default)
    {
        return TrackForUpdate(_context.Reports, report);
    }

/// <summary>
/// يحذف السجل المطلوب من المستودع.
/// Deletes the requested record from the repository.
/// </summary>
    public async Task<bool> DeleteReportAsync(Guid reportId, CancellationToken cancellationToken = default)
    {
        var report = await _context.Reports.FindAsync(new object[]{reportId}, cancellationToken);
        if (report == null) return false;
        _context.Reports.Remove(report);
        return true;
    }
} 
