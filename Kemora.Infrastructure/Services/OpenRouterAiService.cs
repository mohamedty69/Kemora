using System.Collections.Concurrent;
using System.Net.Http.Json;
using System.Text.Json.Serialization;
using Kemora.Domain.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace Kemora.Infrastructure.Services
{
    public class OpenRouterAiService : IAiService
    {
        private readonly IHttpClientFactory _httpFactory;
        private readonly IConfiguration _config;
        private readonly ILogger<OpenRouterAiService> _logger;

        private class ModelInfo
        {
            public string Id { get; set; } = string.Empty;
            public long ContextLength { get; set; }
            public int RequestCount { get; set; }
            public DateTime WindowStart { get; set; }
            public bool IsExhausted { get; set; }
            public DateTime? ResetTime { get; set; }
        }

        private readonly ConcurrentDictionary<string, ModelInfo> _models = new();
        private readonly SemaphoreSlim _initSemaphore = new(1, 1);
        private bool _isInitialized = false;

        public OpenRouterAiService(
            IHttpClientFactory httpFactory,
            IConfiguration config,
            ILogger<OpenRouterAiService> logger)
        {
            _httpFactory = httpFactory;
            _config = config;
            _logger = logger;
        }

        private string GetApiKey() => _config["OpenRouter:ApiKey"] ?? string.Empty;
        private int MaxRequestsPerModel() => _config.GetValue<int>("OpenRouter:MaxRequestsPerModelPerDay", 40);

        private async Task EnsureInitializedAsync()
        {
            if (_isInitialized) return;

            await _initSemaphore.WaitAsync();
            try
            {
                if (_isInitialized) return;

                var client = _httpFactory.CreateClient("OpenRouter");
                var response = await client.GetAsync("https://openrouter.ai/api/v1/models");
                
                if (response.IsSuccessStatusCode)
                {
                    var result = await response.Content.ReadFromJsonAsync<OpenRouterModelsResponse>();
                    if (result?.Data != null)
                    {
                        var now = DateTime.UtcNow;
                        foreach (var model in result.Data)
                        {
                            // Filter free models with 0 prompt and 0 completion pricing
                            if (model.Pricing != null && 
                                double.TryParse(model.Pricing.Prompt, out var promptPrice) && promptPrice == 0 &&
                                double.TryParse(model.Pricing.Completion, out var compPrice) && compPrice == 0)
                            {
                                // Exclude known paid/broken models that falsely report $0 pricing
                                var blocklist = new[] { "lyria", "imagen", "owl-alpha", "ocr-fast", "music" };
                                if (model.ContextLength >= 8192 && 
                                    !blocklist.Any(b => model.Id.Contains(b, StringComparison.OrdinalIgnoreCase)))
                                {
                                    _models[model.Id] = new ModelInfo 
                                    { 
                                        Id = model.Id, 
                                        ContextLength = model.ContextLength,
                                        RequestCount = 0,
                                        WindowStart = now,
                                        IsExhausted = false
                                    };
                                }
                            }
                        }
                        _logger.LogInformation("Loaded {Count} free models from OpenRouter", _models.Count);
                    }
                }
                else
                {
                    _logger.LogWarning("Failed to fetch OpenRouter models. Code: {StatusCode}", response.StatusCode);
                }

                _isInitialized = true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Exception while initializing OpenRouter models.");
            }
            finally
            {
                _initSemaphore.Release();
            }
        }

        private string SelectBestModel(int estimatedTokens, IEnumerable<string>? excludeModels = null)
        {
            var now = DateTime.UtcNow;
            var maxReqs = MaxRequestsPerModel();
            var excludeSet = excludeModels?.ToHashSet() ?? new HashSet<string>();

            foreach (var prop in _models.Values)
            {
                // Reset exhausted status if ResetTime has passed
                if (prop.IsExhausted && prop.ResetTime.HasValue && now >= prop.ResetTime.Value)
                {
                    prop.IsExhausted = false;
                    prop.ResetTime = null;
                    prop.RequestCount = 0;
                    prop.WindowStart = now;
                }
                else if (!prop.IsExhausted && now.Subtract(prop.WindowStart).TotalHours >= 24)
                {
                    prop.RequestCount = 0;
                    prop.WindowStart = now;
                }
            }

            var availableModels = _models.Values
                .Where(m => !m.IsExhausted && m.RequestCount < maxReqs && !excludeSet.Contains(m.Id))
                .Where(m => m.ContextLength >= estimatedTokens * 1.5) // Buffer for output and system prompts
                .OrderBy(m => m.RequestCount)
                .ThenByDescending(m => m.ContextLength)
                .ToList();

            if (availableModels.Any())
            {
                var selected = availableModels.First();
                selected.RequestCount++;
                return selected.Id;
            }

            return "openrouter/free";
        }

        private void HandleRateLimitHeaders(System.Net.Http.HttpResponseMessage response, string modelId)
        {
            if (!_models.TryGetValue(modelId, out var modelInfo)) return;

            var headers = response.Headers;
            DateTime? resetTime = null;

            // Try standard rate limit headers
            if (headers.TryGetValues("x-ratelimit-reset", out var resetValues) || headers.TryGetValues("x-ratelimit-reset-requests", out resetValues))
            {
                var resetStr = resetValues.FirstOrDefault();
                if (!string.IsNullOrEmpty(resetStr))
                {
                    // OpenRouter might send a string like "10s", "1m", "24h" or a unix timestamp
                    if (resetStr.EndsWith("s") && double.TryParse(resetStr.TrimEnd('s'), out var secs))
                    {
                        resetTime = DateTime.UtcNow.AddSeconds(secs);
                    }
                    else if (resetStr.EndsWith("m") && double.TryParse(resetStr.TrimEnd('m'), out var mins))
                    {
                        resetTime = DateTime.UtcNow.AddMinutes(mins);
                    }
                    else if (resetStr.EndsWith("h") && double.TryParse(resetStr.TrimEnd('h'), out var hrs))
                    {
                        resetTime = DateTime.UtcNow.AddHours(hrs);
                    }
                    else if (long.TryParse(resetStr, out var timestamp))
                    {
                        // Could be seconds or milliseconds
                        if (timestamp > 2000000000000) // Milliseconds
                        {
                            resetTime = DateTimeOffset.FromUnixTimeMilliseconds(timestamp).UtcDateTime;
                        }
                        else
                        {
                            resetTime = DateTimeOffset.FromUnixTimeSeconds(timestamp).UtcDateTime;
                        }
                    }
                }
            }
            
            if (resetTime.HasValue)
            {
                modelInfo.ResetTime = resetTime;
                modelInfo.IsExhausted = true;
                _logger.LogWarning("Model {Model} rate limited. Reset time set to {ResetTime} UTC.", modelId, resetTime);
            }
            else
            {
                // Fallback to 1 hour if no header
                modelInfo.ResetTime = DateTime.UtcNow.AddHours(1);
                modelInfo.IsExhausted = true;
            }
        }

        public async Task<string> GenerateCompletionAsync(string systemPrompt, string userPrompt, double temperature = 0.3, bool jsonMode = true)
        {
            var apiKey = GetApiKey();
            if (string.IsNullOrEmpty(apiKey))
            {
                _logger.LogError("OpenRouter:ApiKey is missing.");
                return "AI Error: Missing API Key.";
            }

            await EnsureInitializedAsync();
            
            // Very rough token estimation (1 token approx 4 chars)
            int estimatedTokens = (systemPrompt.Length + userPrompt.Length) / 4;

            int attempts = 0;
            int maxAttempts = Math.Max(3, _models.Count > 0 ? _models.Count : 3);
            var triedModels = new HashSet<string>();

            while (attempts < maxAttempts)
            {
                attempts++;
                var selectedModel = SelectBestModel(estimatedTokens, triedModels);
                triedModels.Add(selectedModel);

                var fallbackModels = _models.Values.Where(m => m.Id != selectedModel && !triedModels.Contains(m.Id)).Select(m => m.Id).Take(2).ToList();

                var requestBody = new
                {
                    model = selectedModel,
                    messages = new[]
                    {
                        new { role = "system", content = systemPrompt },
                        new { role = "user", content = userPrompt }
                    },
                    temperature = temperature,
                    response_format = jsonMode ? new { type = "json_object" } : null,
                    models = fallbackModels,
                    route = "fallback"
                };

                var client = _httpFactory.CreateClient("OpenRouter");
                client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", apiKey);
                client.DefaultRequestHeaders.Add("HTTP-Referer", "https://kemora.app"); // Good practice for OpenRouter
                client.DefaultRequestHeaders.Add("X-Title", "Kemora AI Planner");

                try
                {
                    var response = await client.PostAsJsonAsync("https://openrouter.ai/api/v1/chat/completions", requestBody);
                    
                    if (!response.IsSuccessStatusCode)
                    {
                        var statusCode = response.StatusCode;
                        var errorContent = await response.Content.ReadAsStringAsync();
                        _logger.LogWarning("OpenRouter API error for model {Model} ({Code}): {Error}", selectedModel, statusCode, errorContent);

                        // If rate limited or not found
                        if (statusCode == System.Net.HttpStatusCode.TooManyRequests)
                        {
                            HandleRateLimitHeaders(response, selectedModel);
                            continue;
                        }
                        
                        if (statusCode == System.Net.HttpStatusCode.NotFound)
                        {
                            if (_models.TryGetValue(selectedModel, out var info))
                            {
                                info.IsExhausted = true;
                                info.ResetTime = DateTime.UtcNow.AddDays(1); // 404 means model is likely gone
                            }
                            continue;
                        }

                        // 402 Payment Required — model is NOT actually free, remove permanently
                        if (statusCode == System.Net.HttpStatusCode.PaymentRequired)
                        {
                            _logger.LogWarning("Model {Model} requires payment — removing from free pool permanently.", selectedModel);
                            _models.TryRemove(selectedModel, out _);
                            continue;
                        }

                        if ((int)statusCode >= 500)
                        {
                            // Transient server error, try next
                            continue;
                        }

                        // For 400 Bad Request (e.g. context too big), we can also try next if there are models with larger context
                        if (statusCode == System.Net.HttpStatusCode.BadRequest)
                        {
                             continue;
                        }
                        
                        return $"AI Error: {statusCode}";
                    }

                    var result = await response.Content.ReadFromJsonAsync<OpenRouterResponse>();
                    var content = result?.Choices?.FirstOrDefault()?.Message?.Content;

                    if (string.IsNullOrEmpty(content))
                    {
                        _logger.LogWarning("AI returned empty response for model {Model}. Marking as exhausted and retrying...", selectedModel);
                        if (_models.TryGetValue(selectedModel, out var info))
                        {
                            info.IsExhausted = true;
                            info.ResetTime = DateTime.UtcNow.AddMinutes(5);
                        }
                        continue;
                    }

                    if (jsonMode)
                    {
                        var trimmed = content.Trim();
                        if (!(trimmed.StartsWith("{") || trimmed.StartsWith("[")))
                        {
                            _logger.LogWarning("AI returned non-JSON content in JSON mode for model {Model}. Attempt {Attempt}", selectedModel, attempts);
                            continue;
                        }
                    }

                    return content;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to call OpenRouter API for model {Model}", selectedModel);
                    if (attempts >= maxAttempts) return $"AI Error: {ex.Message}";
                }
            }

            return "AI Error: All free models are currently rate-limited or unavailable. Please try again later.";
        }

        private class OpenRouterModelsResponse { [JsonPropertyName("data")] public List<OpenRouterModel>? Data { get; set; } }
        private class OpenRouterModel { 
            [JsonPropertyName("id")] public string Id { get; set; } = string.Empty; 
            [JsonPropertyName("context_length")] public long ContextLength { get; set; } 
            [JsonPropertyName("pricing")] public OpenRouterPricing? Pricing { get; set; } 
        }
        private class OpenRouterPricing { 
            [JsonPropertyName("prompt")] public string Prompt { get; set; } = string.Empty; 
            [JsonPropertyName("completion")] public string Completion { get; set; } = string.Empty; 
        }
        private class OpenRouterResponse { [JsonPropertyName("choices")] public List<OpenRouterChoice>? Choices { get; set; } }
        private class OpenRouterChoice { [JsonPropertyName("message")] public OpenRouterMessage? Message { get; set; } }
        private class OpenRouterMessage { [JsonPropertyName("content")] public string? Content { get; set; } }
    }
}
