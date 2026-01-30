using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

[Route("api/[controller]")]
[ApiController]
public class AuthController : ControllerBase
{
    private readonly IConfiguration _config;
    private readonly ILogger<AuthController> _logger;

    public AuthController(IConfiguration config, ILogger<AuthController> logger)
    {
        _config = config;
        _logger = logger;
    }

    [HttpPost("login")]
    public IActionResult Login([FromBody] LoginModel login)
    {
        if (login == null)
        {
            return BadRequest("Invalid client request");
        }

        var adminUsername = _config["Admin:Username"];
        var adminPasswordHash = _config["Admin:PasswordHash"];

        if (string.IsNullOrEmpty(adminUsername) || string.IsNullOrEmpty(adminPasswordHash))
        {
            _logger.LogError("Admin credentials not configured. Set Admin:Username and Admin:PasswordHash in environment.");
            return StatusCode(500, "Server configuration error");
        }

        // Verify username and password using BCrypt
        if (login.Username == adminUsername && BCrypt.Net.BCrypt.Verify(login.Password, adminPasswordHash))
        {
            var jwtKey = _config["Jwt:Key"];
            if (string.IsNullOrEmpty(jwtKey) || jwtKey.Length < 32)
            {
                _logger.LogError("JWT Key not configured or too short. Must be at least 32 characters.");
                return StatusCode(500, "Server configuration error");
            }

            var secretKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
            var signinCredentials = new SigningCredentials(secretKey, SecurityAlgorithms.HmacSha256);

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, login.Username),
                new Claim(ClaimTypes.Role, "Admin")
            };

            var tokenOptions = new JwtSecurityToken(
                issuer: _config["Jwt:Issuer"],
                audience: _config["Jwt:Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddHours(24),
                signingCredentials: signinCredentials
            );

            var tokenString = new JwtSecurityTokenHandler().WriteToken(tokenOptions);
            _logger.LogInformation("User {Username} logged in successfully", login.Username);
            return Ok(new { Token = tokenString });
        }

        _logger.LogWarning("Failed login attempt for user: {Username}", login.Username);
        return Unauthorized(new { message = "Invalid username or password" });
    }

    /// <summary>
    /// Utility endpoint to generate a BCrypt hash for a password.
    /// Only available in Development environment.
    /// </summary>
    [HttpPost("generate-hash")]
    public IActionResult GenerateHash([FromBody] GenerateHashRequest request)
    {
        var env = _config["ASPNETCORE_ENVIRONMENT"] ?? Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
        if (env != "Development")
        {
            return NotFound();
        }

        if (string.IsNullOrEmpty(request?.Password))
        {
            return BadRequest("Password is required");
        }

        var hash = BCrypt.Net.BCrypt.HashPassword(request.Password, workFactor: 12);
        return Ok(new { hash });
    }
}

public class LoginModel
{
    public required string Username { get; set; }
    public required string Password { get; set; }
}

public class GenerateHashRequest
{
    public string? Password { get; set; }
}
