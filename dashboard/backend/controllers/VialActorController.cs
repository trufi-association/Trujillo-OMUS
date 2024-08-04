using Microsoft.AspNetCore.Mvc;
using OMUS.Data;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using System.Net.Http.Headers;
using System.Text;
using Microsoft.AspNetCore.Authorization;

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


        [HttpGet]
        public async Task<ActionResult<IEnumerable<VialActor>>> GetVialActors()
        {
            return await _context.VialActors.ToListAsync();
        }


        [Authorize]
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
            var actorsJson = JsonConvert.SerializeObject(actors);

            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Token", "0c8454f10c5917709f462d89342742a81d195d07");

                var content = new StringContent(JsonConvert.SerializeObject(new
                {
                    value = actorsJson
                }), Encoding.UTF8, "application/json");

                var response = await client.PostAsync("https://textit.com/api/v2/globals.json?key=vialactors", content);

                if (response.IsSuccessStatusCode)
                {
                    return NoContent();
                }
                else
                {
                    var responseBody = await response.Content.ReadAsStringAsync();
                    return StatusCode((int)response.StatusCode, responseBody);
                }
            }
        }

    }
}
