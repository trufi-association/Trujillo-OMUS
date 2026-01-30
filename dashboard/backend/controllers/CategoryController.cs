using Microsoft.AspNetCore.Mvc;
using OMUS.Data;
using OMUS.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;

namespace OMUS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CategoriesController : ControllerBase
    {
        private readonly OMUSContext _context;
        private readonly ITextItService _textItService;
        private readonly IProxyService _proxyService;

        public CategoriesController(OMUSContext context, ITextItService textItService, IProxyService proxyService)
        {
            _context = context;
            _textItService = textItService;
            _proxyService = proxyService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Category>>> GetCategories()
        {
            return await _context.Categories.ToListAsync();
        }

        [Authorize]
        [HttpPost("AddCategory")]
        public async Task<IActionResult> AddCategory(Category category)
        {
            if (category.ParentId.HasValue)
            {
                var parentCategory = await _context.Categories.FindAsync(category.ParentId.Value);
                if (parentCategory == null)
                {
                    return NotFound("ParentId");
                }
            }

            _context.Categories.Add(category);
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [Authorize]
        [HttpPut("UpdateCategory")]
        public async Task<IActionResult> UpdateCategory(Category category)
        {
            var categoryFind = await _context.Categories.FindAsync(category.Id);
            if (categoryFind == null)
            {
                return NotFound();
            }

            if (category.ParentId.HasValue)
            {
                var parentCategory = await _context.Categories.FindAsync(category.ParentId.Value);
                if (parentCategory == null)
                {
                    return NotFound("ParentId");
                }
            }

            _context.Entry(categoryFind).CurrentValues.SetValues(category);
            await _context.SaveChangesAsync();
            return NoContent();
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

            // Convert to compact DTO format for TextIt (10000 char limit)
            var compactCategories = categories.Select(c => new
            {
                id = c.Id,
                parentId = c.ParentId,
                categoryName = c.CategoryName,
                hasVictim = c.hasVictim,
                hInv = c.hasInvolvedActor,  // Abbreviated to save space
                hasDateTime = c.hasDateTime
            });

            var success = await _textItService.SyncGlobalAsync("categories", compactCategories);

            if (success)
            {
                return NoContent();
            }

            return StatusCode(502, new { message = "Failed to sync with TextIt" });
        }

        /// <summary>
        /// Proxy endpoint for fetching external resources.
        /// Only allows HTTPS URLs from whitelisted domains.
        /// </summary>
        [Authorize]
        [HttpGet("proxy")]
        public async Task<IActionResult> Proxy([FromQuery] string url)
        {
            if (string.IsNullOrEmpty(url))
            {
                return BadRequest(new { message = "Missing 'url' query parameter." });
            }

            var result = await _proxyService.FetchUrlAsync(url);

            if (result.Success && result.Content != null)
            {
                return File(result.Content, result.ContentType ?? "application/octet-stream");
            }

            return StatusCode(result.StatusCode, new { message = result.ErrorMessage });
        }
    }
}
