using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;

[ApiController]
[Route("api/[controller]")]
public class ChartConfigController : ControllerBase
{
    private static readonly string FilePath = "config.json";

    [Authorize]
    [HttpPost("update")]
    public async Task<IActionResult> UpdateConfig([FromBody] Dictionary<string, object> data)
    {
        if (data == null || data.Count == 0)
        {
            return BadRequest("Data cannot be empty.");
        }

        var jsonData = JsonSerializer.Serialize(data, new JsonSerializerOptions { WriteIndented = true });

        try
        {
            await System.IO.File.WriteAllTextAsync(FilePath, jsonData);
            return Ok(new { message = "Configuration updated successfully." });
        }
        catch
        {
            return StatusCode(500, new { message = "Error saving configuration." });
        }
    }

    [HttpGet("config")]
    public async Task<IActionResult> GetConfig()
    {
        if (!System.IO.File.Exists(FilePath))
        {
            return NotFound(new { message = "No configuration available." });
        }

        try
        {
            var jsonData = await System.IO.File.ReadAllTextAsync(FilePath);
            var configData = JsonSerializer.Deserialize<Dictionary<string, object>>(jsonData);
            return Ok(configData);
        }
        catch
        {
            return StatusCode(500, new { message = "Error reading configuration." });
        }
    }
}
