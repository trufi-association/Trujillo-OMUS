using Microsoft.AspNetCore.Mvc;
using OMUS.Data;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace OMUS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class VialActorsController : ControllerBase
    {
        private readonly OMUSContext _context;

        public VialActorsController(OMUSContext context)
        {
            _context = context;
        }

        // GET: api/VialActors
        [HttpGet]
        public async Task<ActionResult<IEnumerable<VialActor>>> GetVialActors()
        {
            return await _context.VialActors.ToListAsync();
        }

        // POST: api/VialActors
        [HttpPost]
        public async Task<IActionResult> SaveVialActor(VialActor vialActor)
        {
            if (vialActor.Id == 0) // Assuming 0 is the default value for uninitialized int
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


        // DELETE: api/VialActors/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteVialActor(int id)
        {
            var vialActor = await _context.VialActors.FindAsync(id);
            if (vialActor == null) return NotFound();

            _context.VialActors.Remove(vialActor);
            await _context.SaveChangesAsync();

            return NoContent();
        }

    }
}
