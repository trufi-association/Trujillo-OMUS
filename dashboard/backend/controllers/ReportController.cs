using Microsoft.AspNetCore.Mvc;
using OMUS.Data;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace OMUS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReportsController : ControllerBase
    {
        private readonly OMUSContext _context;

        public ReportsController(OMUSContext context)
        {
            _context = context;
        }

        // GET: api/Reports
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Report>>> GetReports()
        {
            return await _context.Reports.ToListAsync();
        }

        // POST: api/Reports
        [HttpPost]
        public async Task<IActionResult> SaveReport(Report report)
        {
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


        // DELETE: api/Reports/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteReport(Guid id)
        {
            var report = await _context.Reports.FindAsync(id);
            if (report == null) return NotFound();

            _context.Reports.Remove(report);
            await _context.SaveChangesAsync();

            return NoContent();
        }

    }
}
