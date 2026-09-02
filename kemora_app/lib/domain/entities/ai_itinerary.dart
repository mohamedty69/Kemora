import 'package:equatable/equatable.dart';

class ItineraryItem extends Equatable {
  final String name;
  final String description;
  final String timeOfDay;
  final String? time;
  final String? suggestedHours;
  final String? imageUrl;
  final double? rating;
  final String? price;
  final String? itineraryReview;
  final double? latitude;
  final double? longitude;
  final String? category;
  /// Database PlaceID so the Flutter app can deep-link to /places/{dbPlaceId}.
  final int? dbPlaceId;
  final bool isVisited;
  final int? tripPlaceId;

  const ItineraryItem({
    required this.name,
    required this.description,
    required this.timeOfDay,
    this.time,
    this.suggestedHours,
    this.imageUrl,
    this.rating,
    this.price,
    this.itineraryReview,
    this.latitude,
    this.longitude,
    this.category,
    this.dbPlaceId,
    this.isVisited = false,
    this.tripPlaceId,
  });

  ItineraryItem copyWith({
    String? name,
    String? description,
    String? timeOfDay,
    String? time,
    String? suggestedHours,
    String? imageUrl,
    double? rating,
    String? price,
    String? itineraryReview,
    double? latitude,
    double? longitude,
    String? category,
    int? dbPlaceId,
    bool? isVisited,
    int? tripPlaceId,
  }) {
    return ItineraryItem(
      name: name ?? this.name,
      description: description ?? this.description,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      time: time ?? this.time,
      suggestedHours: suggestedHours ?? this.suggestedHours,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      itineraryReview: itineraryReview ?? this.itineraryReview,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      dbPlaceId: dbPlaceId ?? this.dbPlaceId,
      isVisited: isVisited ?? this.isVisited,
      tripPlaceId: tripPlaceId ?? this.tripPlaceId,
    );
  }

  @override
  List<Object?> get props => [
        name,
        description,
        timeOfDay,
        time,
        suggestedHours,
        imageUrl,
        rating,
        price,
        itineraryReview,
        latitude,
        longitude,
        category,
        dbPlaceId,
        isVisited,
        tripPlaceId,
      ];
}

class TripDay extends Equatable {
  final int dayNumber;
  final List<ItineraryItem> activities;
  final String? dailySummary;
  final String? transportTips;

  const TripDay({
    required this.dayNumber,
    required this.activities,
    this.dailySummary,
    this.transportTips,
  });

  @override
  List<Object?> get props => [dayNumber, activities, dailySummary, transportTips];
}

class AIItinerary extends Equatable {
  final String title;
  final String duration;
  final List<TripDay> days;

  const AIItinerary({
    required this.title,
    required this.duration,
    required this.days,
  });

  @override
  List<Object?> get props => [title, duration, days];
}
