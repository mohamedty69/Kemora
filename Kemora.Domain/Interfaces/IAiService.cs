namespace Kemora.Domain.Interfaces
{
    public interface IAiService
    {
        /// <summary>
        /// Send a prompt to an AI model and get a text response.
        /// Automatically rotates between available free models.
        /// </summary>
        Task<string> GenerateCompletionAsync(
            string systemPrompt,
            string userPrompt,
            double temperature = 0.3,
            bool jsonMode = true);
    }
}
