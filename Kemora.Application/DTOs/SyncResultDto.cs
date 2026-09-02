using System;
using System.Collections.Generic;

namespace Kemora.Application.DTOs
{
    public class SyncResultDto
    {
        public int GovernorateId { get; set; }
        public string GovernorateName { get; set; } = string.Empty;
        public int PlacesAdded { get; set; }
        public int PlacesUpdated { get; set; }
        public int PlacesSkipped { get; set; }
        public List<string> Errors { get; set; } = [];
        public DateTime SyncedAt { get; set; } = DateTime.UtcNow;
    }
}
