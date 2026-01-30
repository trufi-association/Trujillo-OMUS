using System.Text;
using AspNetCoreRateLimit;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using OMUS.Data;
using OMUS.Middleware;
using OMUS.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddDbContext<OMUSContext>(options =>
    options.UseMySql(builder.Configuration.GetConnectionString("DefaultConnection"),
                    new MySqlServerVersion(new Version(8, 0, 21)),
                    mySqlOptions => mySqlOptions.EnableRetryOnFailure()
        ));

// Register custom services
builder.Services.AddScoped<ITextItService, TextItService>();
builder.Services.AddScoped<IProxyService, ProxyService>();

// Auto-hash admin password if provided as plain text
var adminPassword = builder.Configuration["Admin:Password"];
if (!string.IsNullOrEmpty(adminPassword))
{
    var hash = BCrypt.Net.BCrypt.HashPassword(adminPassword, workFactor: 12);
    builder.Configuration["Admin:PasswordHash"] = hash;
}

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Configure CORS
var corsOrigins = builder.Configuration["Cors:Origins"]?.Split(',', StringSplitOptions.RemoveEmptyEntries)
    ?? Array.Empty<string>();
var allowLocalhost = builder.Configuration.GetValue<bool>("Cors:AllowLocalhost", true);

builder.Services.AddCors(options =>
{
    options.AddPolicy("CorsPolicy", policy =>
    {
        policy.SetIsOriginAllowed(origin =>
              {
                  // Allow any localhost port in development
                  if (allowLocalhost)
                  {
                      var uri = new Uri(origin);
                      if (uri.Host == "localhost" || uri.Host == "127.0.0.1")
                          return true;
                  }
                  // Allow configured origins
                  return corsOrigins.Contains(origin);
              })
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

// Configure Rate Limiting
builder.Services.AddMemoryCache();
builder.Services.Configure<IpRateLimitOptions>(options =>
{
    options.EnableEndpointRateLimiting = true;
    options.StackBlockedRequests = false;
    options.HttpStatusCode = 429;
    options.RealIpHeader = "X-Real-IP";
    options.ClientIdHeader = "X-ClientId";
    options.GeneralRules = new List<RateLimitRule>
    {
        new RateLimitRule
        {
            Endpoint = "POST:/api/Auth/login",
            Period = "1m",
            Limit = 5
        },
        new RateLimitRule
        {
            Endpoint = "POST:/api/Reports",
            Period = "1m",
            Limit = 100
        },
        new RateLimitRule
        {
            Endpoint = "GET:/api/Categories/proxy",
            Period = "1m",
            Limit = 10
        },
        new RateLimitRule
        {
            Endpoint = "*",
            Period = "1s",
            Limit = 50
        }
    };
});
builder.Services.AddSingleton<IIpPolicyStore, MemoryCacheIpPolicyStore>();
builder.Services.AddSingleton<IRateLimitCounterStore, MemoryCacheRateLimitCounterStore>();
builder.Services.AddSingleton<IRateLimitConfiguration, RateLimitConfiguration>();
builder.Services.AddSingleton<IProcessingStrategy, AsyncKeyLockProcessingStrategy>();
builder.Services.AddInMemoryRateLimiting();

// JWT Authentication Configuration
var jwtKey = builder.Configuration["Jwt:Key"];
if (string.IsNullOrEmpty(jwtKey) || jwtKey.Length < 32)
{
    throw new InvalidOperationException("JWT Key must be configured and at least 32 characters long. Set Jwt:Key in configuration.");
}

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
        };
    });

// Configure Swagger to use JWT
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "OMUS API",
        Version = "v1",
        Description = "API for OMUS Dashboard - Urban Mobility Observatory"
    });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\""
    });

    c.AddSecurityDefinition("ApiKey", new OpenApiSecurityScheme
    {
        Name = "X-API-Key",
        Type = SecuritySchemeType.ApiKey,
        In = ParameterLocation.Header,
        Description = "API Key for report submissions"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

builder.Services.AddHttpClient();

var app = builder.Build();

// Global exception handler
app.UseGlobalExceptionHandler();

// Rate limiting
app.UseIpRateLimiting();

// Configure the HTTP request pipeline.
app.UseSwagger(c =>
{
    c.RouteTemplate = "api/swagger/{documentName}/swagger.json";
});
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/api/swagger/v1/swagger.json", "OMUS API V1");
    c.RoutePrefix = "api/swagger";
});

app.UseHttpsRedirection();

// CORS must be before Authentication/Authorization
app.UseCors("CorsPolicy");

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<OMUSContext>();
        context.Database.Migrate();
        DbInitializer.Initialize(services);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while seeding the database.");
    }
}

app.Run();
