import 'package:equatable/equatable.dart';

class ReviewSummary extends Equatable {
  final String authorName;
  final String text;
  final int rating;
  final String? source;

  const ReviewSummary({
    required this.authorName,
    required this.text,
    required this.rating,
    this.source,
  });

  @override
  List<Object?> get props => [authorName, text, rating, source];
}

class Place extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final double rating;

  // Extended fields from API
  final String? type;
  final String? address;
  final String? governorateName;
  final String? mainImageUrl;
  final int? priceLevel;
  final String? website;
  final String? googleMapsUrl;
  final List<String> additionalPhotoUrls;
  final dynamic openingHours; // Can be a List or parsed JSON
  final List<ReviewSummary> reviews;
  final List<String> photos;
  final int reviewCount;

  const Place({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.rating,
    this.type,
    this.address,
    this.governorateName,
    this.mainImageUrl,
    this.priceLevel,
    this.website,
    this.googleMapsUrl,
    this.additionalPhotoUrls = const [],
    this.openingHours,
    this.reviews = const [],
    this.photos = const [],
    this.reviewCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        imageUrl,
        latitude,
        longitude,
        rating,
        type,
        address,
        governorateName,
        mainImageUrl,
        priceLevel,
        website,
        googleMapsUrl,
        additionalPhotoUrls,
        openingHours,
        reviews,
        photos,
        reviewCount,
      ];
}

class Governorate extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final String? region;
  final double latitude;
  final double longitude;

  const Governorate({
    required this.id,
    required this.name,
    this.imageUrl,
    this.region,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, region, latitude, longitude];
}
