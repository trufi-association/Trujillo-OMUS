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


        [HttpPost]
        public async Task<IActionResult> SaveReport([FromQuery] string apiKey, Report report)
        {
            var configuredApiKey = _configuration.GetValue<string>("ApiKey");

            if (apiKey != configuredApiKey)
            {
                return Unauthorized("Invalid API Key");
            }
            if (report.Id == 0) // Assuming 0 is the default value for uninitialized int
            {
                _context.Reports.Add(report);
                await _context.SaveChangesAsync();
                return NoContent();
            }
            else
            {
                var reportFind = await _context.Reports.FindAsync(report.Id);
                if (reportFind == null) return NotFound();

                _context.Entry(reportFind).CurrentValues.SetValues(report);
                await _context.SaveChangesAsync();
                return NoContent();
            }
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
