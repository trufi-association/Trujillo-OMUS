using Microsoft.AspNetCore.Mvc;
using OMUS.Data;
using Microsoft.EntityFrameworkCore;
using System.Net.Http.Headers;
using System.Text;
using Newtonsoft.Json;
using Microsoft.AspNetCore.Authorization;

namespace OMUS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CategoriesController : ControllerBase
    {
        private readonly OMUSContext _context;
        private readonly IHttpClientFactory _httpClientFactory;

        public CategoriesController(OMUSContext context, IHttpClientFactory httpClientFactory)
        {
            _context = context;
            _httpClientFactory = httpClientFactory;
        }


        [HttpGet]
        public async Task<ActionResult<IEnumerable<Category>>> GetCategories()
        {
            return await _context.Categories.ToListAsync();
        }

        [Authorize]
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


        [Authorize]
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCategory(int id)
        {
            var category = await _context.Categories.FindAsync(id);
            if (category == null) return NotFound();

            _context.Categories.Remove(category);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        [Authorize]
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
        [HttpGet("proxy")]
        public async Task<IActionResult> Proxy([FromQuery] string url)
        {
            if (string.IsNullOrEmpty(url))
            {
                return BadRequest("Missing 'url' query parameter.");
            }

            var client = _httpClientFactory.CreateClient();
            var responseMessage = await client.GetAsync(url);

            if (responseMessage.IsSuccessStatusCode)
            {
                var contentType = responseMessage.Content.Headers.ContentType?.ToString() ?? "application/octet-stream";
                var contentStream = await responseMessage.Content.ReadAsStreamAsync();
                return File(contentStream, contentType);
            }
            else
            {
                var responseBody = await responseMessage.Content.ReadAsStringAsync();
                return StatusCode((int)responseMessage.StatusCode, responseBody);
            }
        }

    }
    public class SyncCategoriesRequest
    {
        public required string Url { get; set; }
        public required string ApiKey { get; set; }
    }
}
