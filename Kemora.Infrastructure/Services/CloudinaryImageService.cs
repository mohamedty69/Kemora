using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Kemora.Application.Interfaces;
using Microsoft.Extensions.Configuration;
using System.IO;
using System.Threading.Tasks;

namespace Kemora.Infrastructure.Services
{
    public class CloudinaryImageService : IImageService
    {
        private readonly Cloudinary _cloudinary;

        public CloudinaryImageService(IConfiguration config)
        {
            var cloudName = config["Cloudinary:CloudName"] ?? throw new ArgumentNullException("Cloudinary:CloudName is missing from configuration");
            var apiKey = config["Cloudinary:ApiKey"] ?? throw new ArgumentNullException("Cloudinary:ApiKey is missing from configuration");
            var apiSecret = config["Cloudinary:ApiSecret"] ?? throw new ArgumentNullException("Cloudinary:ApiSecret is missing from configuration");

            var acc = new Account(cloudName, apiKey, apiSecret);
            _cloudinary = new Cloudinary(acc);
        }

        public async Task<string?> UploadImageAsync(Stream fileStream, string fileName)
        {
            if (fileStream.Length > 0)
            {
                var uploadParams = new ImageUploadParams
                {
                    File = new FileDescription(fileName, fileStream),
                    Transformation = new Transformation().Height(1000).Width(1000).Crop("limit")
                };
                
                var uploadResult = await _cloudinary.UploadAsync(uploadParams);
                return uploadResult.SecureUrl?.ToString();
            }

            return null;
        }

        public async Task<string?> UploadImageFromUrlAsync(string url)
        {
            if (string.IsNullOrWhiteSpace(url)) return null;

            var uploadParams = new ImageUploadParams
            {
                File = new FileDescription(url),
                Transformation = new Transformation().Height(1000).Width(1000).Crop("limit")
            };
            
            var uploadResult = await _cloudinary.UploadAsync(uploadParams);
            return uploadResult.SecureUrl?.ToString();
        }
    }
}
