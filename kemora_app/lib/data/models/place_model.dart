import '../../domain/entities/place.dart';
import '../../core/di/injection_container.dart';

class PlaceModel extends Place {
  const PlaceModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.imageUrl,
    required super.latitude,
    required super.longitude,
    required super.rating,
    super.type,
    super.address,
    super.governorateName,
    super.mainImageUrl,
    super.priceLevel,
    super.website,
    super.googleMapsUrl,
    super.additionalPhotoUrls,
    super.openingHours,
    super.reviews,
    super.photos,
    super.reviewCount,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    // Parse reviews if present — handles both camelCase variants from
    // ReviewResponseDto (reviewID, authorName, rating, text, placeID)
    final rawReviews = json['reviews'] as List<dynamic>? ?? [];
    final reviews = rawReviews
        .map((r) => ReviewSummary(
              authorName: r['authorName'] as String? ??
                  r['author_name'] as String? ??
                  'Anonymous',
              text: r['text'] as String? ?? '',
              rating: (r['rating'] as num?)?.toInt() ?? 5,
              source: r['source'] as String?,
            ))
        .toList();

    final mainImageRaw =
        json['mainImageURL'] as String? ?? json['mainImageUrl'] as String? ?? json['MainImageURL'] as String?;
    String? resolvedMainImage;
    if (mainImageRaw != null && mainImageRaw.isNotEmpty) {
      resolvedMainImage = mainImageRaw.startsWith('http')
          ? mainImageRaw
          : (mainImageRaw.startsWith('/') ? '${resolveApiBaseUrl()}$mainImageRaw' : '${resolveApiBaseUrl()}/$mainImageRaw');
    }
    final mainImageUrl = resolvedMainImage;

    // Parse photos array from PlaceDetailPublicDto
    // Each element: {photoID, imageURL, isMain, placeID}
    final rawPhotos = json['photos'] as List<dynamic>? ?? [];
    final photos = rawPhotos
        .map((p) => (p['imageURL'] as String? ?? p['imageUrl'] as String? ?? p['ImageURL'] as String? ?? ''))
        .where((url) => url.isNotEmpty)
        .map((url) => url.startsWith('http') ? url : (url.startsWith('/') ? '${resolveApiBaseUrl()}$url' : '${resolveApiBaseUrl()}/$url'))
        .toList();

    return PlaceModel(
      id: json['placeID']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unknown Place',
      description: json['description'] as String? ?? 'No description available.',
      category: json['placeTypeName'] as String? ?? json['type'] as String? ?? 'Uncategorized',
      imageUrl: mainImageUrl ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      type: json['placeTypeName'] as String? ?? json['type'] as String?,
      address: json['address'] as String?,
      governorateName: json['governorateName'] as String?,
      mainImageUrl: mainImageUrl,
      priceLevel: (json['priceLevel'] as num?)?.toInt(),
      website: json['website'] as String?,
      googleMapsUrl: json['googleMapsUrl'] as String?,
      additionalPhotoUrls: photos,
      openingHours: json['openingHoursJSON'] ?? json['openingHours'],
      reviews: reviews,
      photos: photos,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? reviews.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
    };
  }
}

class GovernorateModel extends Governorate {
  const GovernorateModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.region,
    super.latitude,
    super.longitude,
  });

  factory GovernorateModel.fromJson(Map<String, dynamic> json) {
    final imageUrlRaw = json['imageURL'] as String? ?? json['imageUrl'] as String? ?? json['ImageURL'] as String?;
    String? resolvedImage;
    if (imageUrlRaw != null && imageUrlRaw.isNotEmpty) {
      resolvedImage = imageUrlRaw.startsWith('http')
          ? imageUrlRaw
          : (imageUrlRaw.startsWith('/') ? '${resolveApiBaseUrl()}$imageUrlRaw' : '${resolveApiBaseUrl()}/$imageUrlRaw');
    }
    return GovernorateModel(
      id: json['governorateID']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unknown Governorate',
      imageUrl: resolvedImage,
      region: json['region'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'region': region,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
