using Microsoft.AspNetCore.Mvc;
using OMUS.Data;
using OMUS.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;

namespace OMUS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class VialActorsController : ControllerBase
    {
        private readonly OMUSContext _context;
        private readonly ITextItService _textItService;

        public VialActorsController(OMUSContext context, ITextItService textItService)
        {
            _context = context;
            _textItService = textItService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<VialActor>>> GetVialActors()
        {
            return await _context.VialActors.ToListAsync();
        }

        [Authorize]
        [HttpPost]
        public async Task<IActionResult> SaveVialActor(VialActor vialActor)
        {
            if (vialActor.Id == 0)
            {
                _context.VialActors.Add(vialActor);
                await _context.SaveChangesAsync();
                return NoContent();
            }
            else
            {
                var vialActorFind = await _context.VialActors.FindAsync(vialActor.Id);
                if (vialActorFind == null) return NotFound();

                _context.Entry(vialActorFind).CurrentValues.SetValues(vialActor);
                await _context.SaveChangesAsync();
                return NoContent();
            }
        }

        [Authorize]
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteVialActor(int id)
        {
            var vialActor = await _context.VialActors.FindAsync(id);
            if (vialActor == null) return NotFound();

            _context.VialActors.Remove(vialActor);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        [Authorize]
        [HttpGet("SyncTextIt")]
        public async Task<IActionResult> SyncTextIt()
        {
            var actors = await _context.VialActors.ToListAsync();
            var success = await _textItService.SyncGlobalAsync("vialactors", actors);

            if (success)
            {
                return NoContent();
            }

            return StatusCode(502, new { message = "Failed to sync with TextIt" });
        }
    }
}
