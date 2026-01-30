using System.Net;
using System.Text.Json;

namespace OMUS.Middleware
{
    public class ExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionMiddleware> _logger;
        private readonly IHostEnvironment _env;

        public ExceptionMiddleware(RequestDelegate next, ILogger<ExceptionMiddleware> logger, IHostEnvironment env)
        {
            _next = next;
            _logger = logger;
            _env = env;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unhandled exception for request {Method} {Path}",
                    context.Request.Method, context.Request.Path);

                context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                context.Response.ContentType = "application/json";

                var response = new ErrorResponse
                {
                    Message = "An internal server error occurred",
                    TraceId = context.TraceIdentifier
                };

                // Include details only in development
                if (_env.IsDevelopment())
                {
                    response.Details = ex.Message;
                    response.StackTrace = ex.StackTrace;
                }

                var options = new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };
                await context.Response.WriteAsJsonAsync(response, options);
            }
        }
    }

    public class ErrorResponse
    {
        public string Message { get; set; } = string.Empty;
        public string TraceId { get; set; } = string.Empty;
        public string? Details { get; set; }
        public string? StackTrace { get; set; }
    }

    public static class ExceptionMiddlewareExtensions
    {
        public static IApplicationBuilder UseGlobalExceptionHandler(this IApplicationBuilder app)
        {
            return app.UseMiddleware<ExceptionMiddleware>();
        }
    }
}
