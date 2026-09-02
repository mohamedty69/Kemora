import '../../core/di/injection_container.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/ai_itinerary.dart' as ai;

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.title,
    required super.startDate,
    required super.endDate,
    super.plannedPlaces,
    super.savedItinerary,
    super.location,
  });

  // [KEMORA-MIGRATION] Fixed field names to match backend TripDetailDto / TripListDto:
  // Backend uses tripID (not id), name (not title), places[] (not placeIds).
  factory TripModel.fromJson(Map<String, dynamic> json) {
    // Log the raw JSON keys to diagnose ID field name issues
    final rawId = json['tripId'] ?? json['tripID'] ?? json['id'];
    print('=== TripModel.fromJson: keys=${json.keys.toList()} tripId/tripID/id="$rawId" name="${json['name']}" ===');
    return TripModel(
      // Backend serializes as camelCase: TripID -> tripId
      id: rawId?.toString() ?? '',
      title: json['name'] as String? ?? json['title'] as String? ?? 'Unnamed Trip',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'].toString()) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'].toString()) : DateTime.now().add(const Duration(days: 1)),
      location: json['location']?.toString() ?? 'Egypt',
      savedItinerary: _parseItinerary(json),
    );
  }

  static ai.AIItinerary? _parseItinerary(Map<String, dynamic> json) {
    if (json['places'] == null || (json['places'] as List).isEmpty) return null;

    final placesList = json['places'] as List;
    final Map<int, List<ai.ItineraryItem>> groupedByDay = {};

    final startDate = json['startDate'] != null ? DateTime.parse(json['startDate'].toString()) : DateTime.now();
    final endDate = json['endDate'] != null ? DateTime.parse(json['endDate'].toString()) : DateTime.now().add(const Duration(days: 1));
    final durationDays = endDate.difference(startDate).inDays;

    for (var p in placesList) {
      final visitDate = p['visitDate'] != null ? DateTime.parse(p['visitDate'].toString()) : startDate;
      final dayNumber = visitDate.difference(startDate).inDays + 1;

      String? rawImgUrl = p['imageUrl'] as String?;
      if (rawImgUrl != null && rawImgUrl.isNotEmpty && !rawImgUrl.startsWith('http') && !rawImgUrl.startsWith('//')) {
        rawImgUrl = rawImgUrl.startsWith('/') ? '${resolveApiBaseUrl()}$rawImgUrl' : '${resolveApiBaseUrl()}/$rawImgUrl';
      }

      final item = ai.ItineraryItem(
        name: p['placeName']?.toString() ?? 'Unknown Place',
        description: (p['notes']?.toString().isNotEmpty ?? false)
            ? p['notes'].toString()
            : (p['description']?.toString() ?? ''),
        timeOfDay: 'Anytime',
        isVisited: p['isVisited'] ?? false,
        tripPlaceId: (p['tripPlaceId'] ?? p['tripPlaceID']) as int?,
        // Carry the underlying PlaceID so a reloaded trip can still deep-link to
        // /places/{id}, plus image/category/rating for consistent rendering.
        dbPlaceId: (p['placeId'] ?? p['placeID']) as int?,
        imageUrl: rawImgUrl,
        category: p['category'] as String?,
        rating: p['rating'] != null ? (p['rating'] as num).toDouble() : null,
      );

      if (!groupedByDay.containsKey(dayNumber)) {
        groupedByDay[dayNumber] = [];
      }
      groupedByDay[dayNumber]!.add(item);
    }

    final List<ai.TripDay> days = [];
    final sortedDays = groupedByDay.keys.toList()..sort();
    
    for (var dayNum in sortedDays) {
      days.add(ai.TripDay(
        dayNumber: dayNum,
        activities: groupedByDay[dayNum]!,
      ));
    }

    return ai.AIItinerary(
      title: json['name'] as String? ?? json['title'] as String? ?? 'Unnamed Trip',
      duration: '$durationDays Days',
      days: days,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'placeIds': plannedPlaces.map((p) => p.id).toList(),
    };
  }
}
