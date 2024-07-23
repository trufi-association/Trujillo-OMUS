using Microsoft.AspNetCore.Mvc;
using OMUS.Data;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

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
            return await _context.Categories.Include(e => e.Colloquial).Include(e => e.Questions).ToListAsync();
        }

        // POST: api/Categories
        [HttpPost]
        public async Task<IActionResult> SaveCategory(Category category)
        {

            if (category.ParentId != null)
            {
                var categoryFind = await _context.Categories.FindAsync(category.ParentId);
                if (categoryFind == null) return NotFound("ParentId");
            }
            if (category.Id == Guid.Empty)
            {
                category.Id = Guid.NewGuid();
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
        public async Task<IActionResult> DeleteCategory(Guid id)
        {
            var category = await _context.Categories.FindAsync(id);
            if (category == null) return NotFound();

            _context.Categories.Remove(category);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
