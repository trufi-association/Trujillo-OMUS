using Microsoft.AspNetCore.Mvc;
using OMUS.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using System.ComponentModel.DataAnnotations;

namespace OMUS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReportsController : ControllerBase
    {
        private readonly OMUSContext _context;
        private readonly IConfiguration _configuration;
        private readonly ILogger<ReportsController> _logger;

        public ReportsController(OMUSContext context, IConfiguration configuration, ILogger<ReportsController> logger)
        {
            _context = context;
            _configuration = configuration;
            _logger = logger;
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<ActionResult<IEnumerable<Report>>> GetReports()
        {
            return await _context.Reports.ToListAsync();
        }

        [HttpGet("complete-reports")]
        [AllowAnonymous]
        public async Task<ActionResult<IEnumerable<Report>>> GetCompleteReports()
        {
            var reports = await _context.Reports
                .Include(r => r.Category)
                .Include(r => r.InvolvedActor)
                .Include(r => r.VictimActor)
                .ToListAsync();

            return Ok(reports);
        }

        /// <summary>
        /// Create or update a report. Requires API Key in X-API-Key header.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> SaveReport(
            [FromHeader(Name = "X-API-Key")] string? apiKey,
            [FromBody] ReportRequestDto reportDto)
        {
            var configuredApiKey = _configuration.GetValue<string>("ApiKey");

            if (string.IsNullOrEmpty(apiKey) || apiKey != configuredApiKey)
            {
                _logger.LogWarning("Invalid API key attempt for report submission");
                return Unauthorized(new { message = "Invalid or missing API Key" });
            }

            // Validate coordinates if provided
            if (reportDto.Latitude.HasValue && (reportDto.Latitude < -90 || reportDto.Latitude > 90))
            {
                return BadRequest(new { message = "Latitude must be between -90 and 90" });
            }

            if (reportDto.Longitude.HasValue && (reportDto.Longitude < -180 || reportDto.Longitude > 180))
            {
                return BadRequest(new { message = "Longitude must be between -180 and 180" });
            }

            var report = new Report
            {
                Id = reportDto.Id,
                UserId = reportDto.UserId,
                CategoryId = reportDto.CategoryId,
                CreateDate = reportDto.CreateDate,
                ReportDate = reportDto.ReportDate,
                Latitude = reportDto.Latitude,
                Longitude = reportDto.Longitude,
                Images = reportDto.Images,
                Description = reportDto.Description,
                InvolvedActorId = reportDto.InvolvedActorId,
                VictimActorId = reportDto.VictimActorId
            };

            if (report.Id == 0)
            {
                _context.Reports.Add(report);
                _logger.LogInformation("New report created by user {UserId}", reportDto.UserId);
            }
            else
            {
                var reportFind = await _context.Reports.FindAsync(report.Id);
                if (reportFind == null) return NotFound();

                _context.Entry(reportFind).CurrentValues.SetValues(report);
                _logger.LogInformation("Report {ReportId} updated", report.Id);
            }

            await _context.SaveChangesAsync();
            return NoContent();
        }

        [Authorize]
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteReport(int id)
        {
            var report = await _context.Reports.FindAsync(id);
            if (report == null) return NotFound();

            _context.Reports.Remove(report);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Report {ReportId} deleted", id);
            return NoContent();
        }

        [Authorize]
        [HttpDelete("{reportId}/images")]
        public async Task<IActionResult> DeleteAllReportImages(int reportId)
        {
            var report = await _context.Reports.FindAsync(reportId);
            if (report == null)
                return NotFound();

            report.Images.Clear();
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
