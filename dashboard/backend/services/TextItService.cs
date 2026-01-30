using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

namespace OMUS.Services
{
    public interface ITextItService
    {
        Task<bool> SyncGlobalAsync(string key, object data);
    }

    public class TextItService : ITextItService
    {
        private readonly HttpClient _httpClient;
        private readonly string _token;
        private readonly ILogger<TextItService> _logger;
        private const string TextItApiUrl = "https://textit.com/api/v2/globals.json";

        public TextItService(IConfiguration config, IHttpClientFactory httpClientFactory, ILogger<TextItService> logger)
        {
            _httpClient = httpClientFactory.CreateClient();
            _token = config["TextIt:Token"] ?? string.Empty;
            _logger = logger;

            if (string.IsNullOrEmpty(_token))
            {
                _logger.LogWarning("TextIt token not configured. TextIt sync will be disabled.");
            }
        }

        public async Task<bool> SyncGlobalAsync(string key, object data)
        {
            if (string.IsNullOrEmpty(_token))
            {
                _logger.LogWarning("TextIt sync skipped: token not configured");
                return false;
            }

            try
            {
                _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Token", _token);
                _httpClient.DefaultRequestHeaders.UserAgent.ParseAdd("OMUS-Dashboard/1.0");

                var payload = new
                {
                    value = JsonSerializer.Serialize(data)
                };

                var content = new StringContent(
                    JsonSerializer.Serialize(payload),
                    Encoding.UTF8,
                    "application/json"
                );

                var response = await _httpClient.PostAsync($"{TextItApiUrl}?key={key}", content);

                if (response.IsSuccessStatusCode)
                {
                    _logger.LogInformation("TextIt sync successful for key: {Key}", key);
                    return true;
                }

                var responseBody = await response.Content.ReadAsStringAsync();
                _logger.LogError("TextIt sync failed for key {Key}: {StatusCode} - {Response}",
                    key, response.StatusCode, responseBody);
                return false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "TextIt sync error for key: {Key}", key);
                return false;
            }
        }
    }
}
