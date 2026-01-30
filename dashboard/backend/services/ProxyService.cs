using System.Net;
using System.Net.Sockets;

namespace OMUS.Services
{
    public interface IProxyService
    {
        Task<ProxyResult> FetchUrlAsync(string url);
        bool IsUrlAllowed(string url);
    }

    public class ProxyResult
    {
        public bool Success { get; set; }
        public string? ContentType { get; set; }
        public Stream? Content { get; set; }
        public int StatusCode { get; set; }
        public string? ErrorMessage { get; set; }
    }

    public class ProxyService : IProxyService
    {
        private readonly HttpClient _httpClient;
        private readonly HashSet<string> _allowedDomains;
        private readonly ILogger<ProxyService> _logger;
        private readonly TimeSpan _timeout = TimeSpan.FromSeconds(30);
        private const long MaxResponseSize = 10 * 1024 * 1024; // 10MB

        public ProxyService(IConfiguration config, IHttpClientFactory httpClientFactory, ILogger<ProxyService> logger)
        {
            _httpClient = httpClientFactory.CreateClient();
            _httpClient.Timeout = _timeout;
            _logger = logger;

            // Load allowed domains from configuration
            var allowedDomainsConfig = config["Proxy:AllowedDomains"] ?? "";
            _allowedDomains = allowedDomainsConfig
                .Split(',', StringSplitOptions.RemoveEmptyEntries)
                .Select(d => d.Trim().ToLowerInvariant())
                .ToHashSet();

            if (_allowedDomains.Count == 0)
            {
                _logger.LogWarning("No proxy allowed domains configured. Proxy will reject all requests.");
            }
        }

        public bool IsUrlAllowed(string url)
        {
            if (!Uri.TryCreate(url, UriKind.Absolute, out var uri))
            {
                return false;
            }

            // Only allow HTTPS
            if (uri.Scheme != "https")
            {
                _logger.LogWarning("Proxy rejected non-HTTPS URL: {Url}", url);
                return false;
            }

            // Check if host is in whitelist
            var host = uri.Host.ToLowerInvariant();
            if (!_allowedDomains.Contains(host))
            {
                _logger.LogWarning("Proxy rejected URL with non-whitelisted domain: {Host}", host);
                return false;
            }

            // Block private IP addresses
            if (IsPrivateOrLocalhost(uri.Host))
            {
                _logger.LogWarning("Proxy rejected private/localhost URL: {Url}", url);
                return false;
            }

            return true;
        }

        public async Task<ProxyResult> FetchUrlAsync(string url)
        {
            if (!IsUrlAllowed(url))
            {
                return new ProxyResult
                {
                    Success = false,
                    StatusCode = 400,
                    ErrorMessage = "URL not allowed. Only HTTPS URLs from whitelisted domains are permitted."
                };
            }

            try
            {
                var response = await _httpClient.GetAsync(url, HttpCompletionOption.ResponseHeadersRead);

                // Check content length
                if (response.Content.Headers.ContentLength > MaxResponseSize)
                {
                    return new ProxyResult
                    {
                        Success = false,
                        StatusCode = 413,
                        ErrorMessage = "Response too large"
                    };
                }

                if (response.IsSuccessStatusCode)
                {
                    return new ProxyResult
                    {
                        Success = true,
                        ContentType = response.Content.Headers.ContentType?.ToString() ?? "application/octet-stream",
                        Content = await response.Content.ReadAsStreamAsync(),
                        StatusCode = (int)response.StatusCode
                    };
                }

                return new ProxyResult
                {
                    Success = false,
                    StatusCode = (int)response.StatusCode,
                    ErrorMessage = await response.Content.ReadAsStringAsync()
                };
            }
            catch (TaskCanceledException)
            {
                return new ProxyResult
                {
                    Success = false,
                    StatusCode = 504,
                    ErrorMessage = "Request timeout"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Proxy error fetching URL: {Url}", url);
                return new ProxyResult
                {
                    Success = false,
                    StatusCode = 502,
                    ErrorMessage = "Failed to fetch URL"
                };
            }
        }

        private static bool IsPrivateOrLocalhost(string host)
        {
            // Check for localhost
            if (host == "localhost" || host == "127.0.0.1" || host == "::1")
            {
                return true;
            }

            // Try to parse as IP address
            if (IPAddress.TryParse(host, out var ipAddress))
            {
                // Check for private IP ranges
                var bytes = ipAddress.GetAddressBytes();

                if (ipAddress.AddressFamily == AddressFamily.InterNetwork)
                {
                    // IPv4 private ranges
                    // 10.0.0.0/8
                    if (bytes[0] == 10)
                        return true;

                    // 172.16.0.0/12
                    if (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31)
                        return true;

                    // 192.168.0.0/16
                    if (bytes[0] == 192 && bytes[1] == 168)
                        return true;

                    // 169.254.0.0/16 (link-local)
                    if (bytes[0] == 169 && bytes[1] == 254)
                        return true;

                    // 127.0.0.0/8 (loopback)
                    if (bytes[0] == 127)
                        return true;
                }
                else if (ipAddress.AddressFamily == AddressFamily.InterNetworkV6)
                {
                    // IPv6 loopback
                    if (ipAddress.Equals(IPAddress.IPv6Loopback))
                        return true;

                    // IPv6 link-local (fe80::/10)
                    if (bytes[0] == 0xfe && (bytes[1] & 0xc0) == 0x80)
                        return true;

                    // IPv6 unique local (fc00::/7)
                    if ((bytes[0] & 0xfe) == 0xfc)
                        return true;
                }
            }

            return false;
        }
    }
}
