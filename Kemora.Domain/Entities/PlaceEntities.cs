using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Kemora.Domain.Entities
{
    public class Governorate
    {
        [Key]
        public int GovernorateID { get; set; }
        public string Name { get; set; }
        public string Region { get; set; }
        public string? ImageURL { get; set; }
        
        [Column(TypeName = "decimal(10, 8)")]
        public decimal Latitude { get; set; }

        [Column(TypeName = "decimal(11, 8)")]
        public decimal Longitude { get; set; }

        public ICollection<Place> Places { get; set; }
    }

    public class Category
    {
        [Key]
        public int CategoryID { get; set; }
        public string Name { get; set; } // e.g., "Natural", "Historical"
        public ICollection<PlaceType> PlaceTypes { get; set; }
    }

    public class PlaceType
    {
        [Key]
        public int TypeID { get; set; }
        public string GoogleType { get; set; }
        public string DisplayName { get; set; }

        public int CategoryID { get; set; }
        public Category Category { get; set; }
        public ICollection<Place> Places { get; set; }
    }

    public class Place
    {
        [Key]
        public int PlaceID { get; set; }
        public string? GooglePlaceId { get; set; }
        public string Name { get; set; }
        public string? Description { get; set; }
        public string? Address { get; set; }

        [Column(TypeName = "decimal(10, 8)")]
        public decimal Latitude { get; set; }

        [Column(TypeName = "decimal(11, 8)")]
        public decimal Longitude { get; set; }

        public string? Phone { get; set; }
        public string? Website { get; set; }

        [Column(TypeName = "decimal(3, 2)")]
        public decimal Rating { get; set; }

        public int PriceLevel { get; set; } // 0=Free, 4=Luxury
        public string? OpeningHoursJSON { get; set; }
        public string? MainImageURL { get; set; }

        // Foreign Keys — nullable to support AI-generated places that may not have full metadata
        public int? GovernorateID { get; set; }
        public Governorate? Governorate { get; set; }

        public int? PlaceTypeID { get; set; }
        public PlaceType? PlaceType { get; set; }

        public DateTime? LastEnrichedAt { get; set; }
        public string? Source { get; set; } // "seed", "google", "manual"
        
        [StringLength(100)]
        public string? GoogleDataId { get; set; } // SerpApi Maps data_id

        public string? GoogleMapsUrl { get; set; }
        public string? AdditionalPhotoUrlsJSON { get; set; }

        // Relationships
        public ICollection<Photo> Photos { get; set; }
        public ICollection<Review> Reviews { get; set; }
        public ICollection<Event> Events { get; set; }
    }

    public class Photo
    {
        [Key] public int PhotoID { get; set; }
        public string ImageURL { get; set; }
        public bool IsMain { get; set; }
        public int PlaceID { get; set; }
        public Place Place { get; set; }
    }

    public class Review
    {
        [Key] public int ReviewID { get; set; }
        public string AuthorName { get; set; }
        public int Rating { get; set; }
        public string Text { get; set; }
        public string? Source { get; set; } // "Google", "Kemora"
        public int PlaceID { get; set; }
        public Place Place { get; set; }
    }

    public class Event
    {
        [Key] public int EventID { get; set; }
        public string Name { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int PlaceID { get; set; }
        public Place Place { get; set; }
    }
}