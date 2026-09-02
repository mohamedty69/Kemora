import 'dart:convert';
import '../../core/di/injection_container.dart';
import '../../domain/entities/ai_itinerary.dart';

class AIItineraryModel extends AIItinerary {
  const AIItineraryModel({
    required super.title,
    required super.duration,
    required super.days,
  });

  factory AIItineraryModel.fromJson(Map<String, dynamic> json) {
    return AIItineraryModel(
      title: json['trip_title'] as String? ?? 'AI Trip Plan',
      duration: json['trip_duration'] as String? ?? '',
      days: (json['itinerary'] as List<dynamic>?)
              ?.map((d) => TripDayModel.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory AIItineraryModel.fromString(String jsonString) {
    final Map<String, dynamic> decoded = json.decode(jsonString);
    return AIItineraryModel.fromJson(decoded);
  }
}

class TripDayModel extends TripDay {
  const TripDayModel({
    required super.dayNumber,
    required super.activities,
    super.dailySummary,
    super.transportTips,
  });

  factory TripDayModel.fromJson(Map<String, dynamic> json) {
    return TripDayModel(
      dayNumber: json['day'] as int? ?? 1,
      // The backend AI prompt emits "theme"; older schemas used "daily_summary".
      dailySummary: json['daily_summary'] as String? ?? json['theme'] as String?,
      transportTips: json['transport_tips'] as String?,
      activities: (json['activities'] as List<dynamic>?)
              ?.map((a) => ItineraryItemModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ItineraryItemModel extends ItineraryItem {
  const ItineraryItemModel({
    required super.name,
    required super.description,
    required super.timeOfDay,
    super.time,
    super.suggestedHours,
    super.imageUrl,
    super.rating,
    super.price,
    super.itineraryReview,
    super.latitude,
    super.longitude,
    super.category,
    super.dbPlaceId,
  });

  factory ItineraryItemModel.fromJson(Map<String, dynamic> json) {
    String? rawImageUrl = json['image_url'] as String? ?? json['imageUrl'] as String? ?? json['MainImageURL'] as String?;
    
    if (rawImageUrl != null && rawImageUrl.isNotEmpty && !rawImageUrl.startsWith('http') && !rawImageUrl.startsWith('//')) {
      rawImageUrl = rawImageUrl.startsWith('/') ? '${resolveApiBaseUrl()}$rawImageUrl' : '${resolveApiBaseUrl()}/$rawImageUrl';
    }

    return ItineraryItemModel(
      name: json['place'] as String? ?? (json['name'] as String? ?? 'Unknown Place'),
      description: json['description'] as String? ?? '',
      timeOfDay: json['time_slot'] as String? ?? (json['time_of_day'] as String? ?? 'Morning'),
      time: json['time'] as String?,
      suggestedHours: json['suggested_hours'] as String?,
      imageUrl: rawImageUrl,
      rating: (json['rating'] as num?)?.toDouble(),
      price: json['price'] as String?,
      itineraryReview: json['itinerary_review'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      category: json['category'] as String?,
      dbPlaceId: (json['place_id'] as num?)?.toInt(),
    );
  }
}
