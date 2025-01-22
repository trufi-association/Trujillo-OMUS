using Microsoft.AspNetCore.Mvc;
using OMUS.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;

namespace OMUS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReportsController : ControllerBase
    {
        private readonly OMUSContext _context;
        private readonly IConfiguration _configuration;

        public ReportsController(OMUSContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Report>>> GetReports()
        {
            return await _context.Reports.ToListAsync();
        }

        [HttpGet("complete-reports")]
        public async Task<ActionResult<IEnumerable<Report>>> GetCompleteReports()
        {
            var reports = await _context.Reports
           .Include(r => r.Category)
           .Include(r => r.InvolvedActor)
           .Include(r => r.VictimActor)
           .ToListAsync();

            return Ok(reports);
        }


        [HttpPost]
        public async Task<IActionResult> SaveReport([FromQuery] string apiKey, ReportRequestDto reportDto)
        {
            var configuredApiKey = _configuration.GetValue<string>("ApiKey");

            if (apiKey != configuredApiKey)
            {
                return Unauthorized("Invalid API Key");
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
            }
            else
            {
                var reportFind = await _context.Reports.FindAsync(report.Id);
                if (reportFind == null) return NotFound();

                _context.Entry(reportFind).CurrentValues.SetValues(report);
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

            return NoContent();
        }

    }
}
