using System.IO;
using System.Threading.Tasks;

namespace Kemora.Application.Interfaces
{
    public interface IImageService
    {
        Task<string?> UploadImageAsync(Stream fileStream, string fileName);
        Task<string?> UploadImageFromUrlAsync(string url);
    }
}
