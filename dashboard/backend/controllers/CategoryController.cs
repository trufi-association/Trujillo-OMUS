using Microsoft.AspNetCore.Mvc;
using OMUS.Data;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;

namespace OMUS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CategoriesController : ControllerBase
    {
        private readonly OMUSContext _context;

        public CategoriesController(OMUSContext context)
        {
            _context = context;
        }

        // GET: api/Categories
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Category>>> GetCategories()
        {
            return await _context.Categories.ToListAsync();
        }

        [HttpPost]
        public async Task<IActionResult> SaveCategory(Category category)
        {
            if (category.ParentId.HasValue)
            {
                var categoryFind = await _context.Categories.FindAsync(category.ParentId.Value);
                if (categoryFind == null) return NotFound("ParentId");
            }

            if (category.Id == 0) // Assuming 0 is the default value for uninitialized int
            {
                _context.Categories.Add(category);
                await _context.SaveChangesAsync();
                return NoContent();
            }
            else
            {
                var categoryFind = await _context.Categories.FindAsync(category.Id);
                if (categoryFind == null) return NotFound();

                _context.Entry(categoryFind).CurrentValues.SetValues(category);
                await _context.SaveChangesAsync();
                return NoContent();
            }
        }


        // DELETE: api/Categories/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCategory(int id)
        {
            var category = await _context.Categories.FindAsync(id);
            if (category == null) return NotFound();

            _context.Categories.Remove(category);
            await _context.SaveChangesAsync();

            return NoContent();
        }
        // GET: api/Categories/SyncTextIt
        [HttpGet("SyncTextIt")]
        public async Task<IActionResult> SyncTextIt()
        {
            var categories = await _context.Categories.ToListAsync();
            var categoriesJson = JsonConvert.SerializeObject(categories);

            using (var client = new HttpClient())
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Token", "0c8454f10c5917709f462d89342742a81d195d07");

                var content = new StringContent(JsonConvert.SerializeObject(new
                {
                    name = "Categories",
                    value = categoriesJson
                }), Encoding.UTF8, "application/json");

                var response = await client.PostAsync("https://textit.com/api/v2/globals.json?key=categories", content);

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
    public class SyncCategoriesRequest
    {
        public required string Url { get; set; }
        public required string ApiKey { get; set; }
    }
}
