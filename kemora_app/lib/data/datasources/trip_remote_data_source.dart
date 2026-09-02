import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../models/trip_model.dart';
import '../../domain/entities/trip_plan_request.dart';
import '../models/ai_itinerary_model.dart';
import '../../domain/entities/ai_itinerary.dart';

abstract class TripRemoteDataSource {
  Future<TripModel> createTripPlan(String title, DateTime startDate, DateTime endDate, List<String> placeIds);
  Future<List<TripModel>> getUserTrips();
  Future<TripModel> getTripDetails(String id);
  Future<bool> deleteTrip(String id);
  Future<bool> renameTrip(String id, String newName);
  Future<AIItinerary> generateItinerary(TripPlanRequest request);
  Future<ItineraryItem> swapPlace(String currentPlaceName, String preferences);
  Future<TripModel> saveAIPlan(AIItinerary itinerary, DateTime startDate, DateTime endDate);
  Future<bool> updatePlaceVisitedStatus(int tripId, int tripPlaceId, bool isVisited);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final Dio dio;

  TripRemoteDataSourceImpl({required this.dio});

  @override
  Future<TripModel> saveAIPlan(AIItinerary itinerary, DateTime startDate, DateTime endDate) async {
    try {
      final List<Map<String, dynamic>> activities = [];
      
      for (var day in itinerary.days) {
        final DateTime visitDate = startDate.add(Duration(days: day.dayNumber - 1));
        for (var act in day.activities) {
          activities.add({
            'name': act.name,
            'description': act.description,
            'latitude': act.latitude,
            'longitude': act.longitude,
            'category': act.category,
            'imageUrl': act.imageUrl,
            'visitDate': visitDate.toIso8601String(),
            'notes': act.itineraryReview,
            // Persist the DB PlaceID so a saved trip can still deep-link to
            // /places/{id} after a reload.
            'placeId': act.dbPlaceId,
          });
        }
      }

      final requestData = {
          'title': itinerary.title,
          'description': 'AI generated trip for ${itinerary.duration}',
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'activities': activities,
        };
      print('DATA: $requestData');

      final response = await dio.post(
        '/api/v1/trips/save-plan',
        data: requestData,
      );

      print('=== SAVE AI PLAN RES ===');
      print('STATUS: ${response.statusCode}');
      print('DATA TYPE: ${response.data.runtimeType}');
      print('DATA: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is! Map<String, dynamic>) {
          print('SAVE AI PLAN ERROR: Expected Map but got ${response.data.runtimeType}: ${response.data}');
          throw const ServerFailure('Unexpected response format from server');
        }
        return TripModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw const ServerFailure('Failed to save AI plan');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      print('=== SAVE AI PLAN DIO ERROR ===');
      print('STATUS: ${e.response?.statusCode}');
      print('DATA TYPE: ${data?.runtimeType}');
      print('DATA: $data');
      // data can be a Map or a plain String (e.g. HTML error page from middleware)
      final message = data is Map ? (data['message'] ?? data['Message'] ?? 'Server Error') : 'Server Error (${e.response?.statusCode})';
      throw ServerFailure(message.toString());
    }
  }

  @override
  Future<ItineraryItem> swapPlace(String currentPlaceName, String preferences) async {
    try {
      final response = await dio.get(
        '/api/v1/places/swap',
        queryParameters: {
          'currentPlaceName': currentPlaceName,
          'preferences': preferences,
        },
      );
      
      if (response.statusCode == 200) {
        // Normalise the response into a Map. The controller usually unwraps the
        // AI's { "newActivity": { ... } } envelope and returns the inner object,
        // but be defensive in case it comes back wrapped or as a JSON string.
        Map<String, dynamic> parsed;
        if (response.data is String) {
          parsed = json.decode(response.data) as Map<String, dynamic>;
        } else if (response.data is Map) {
          parsed = response.data as Map<String, dynamic>;
        } else {
          throw const ServerFailure('Unexpected swap response format');
        }
        // Unwrap if the controller returned the full envelope.
        if (parsed.containsKey('newActivity') && parsed['newActivity'] is Map) {
          parsed = (parsed['newActivity'] as Map).cast<String, dynamic>();
        }
        return ItineraryItemModel.fromJson(parsed);
      } else {
        throw const ServerFailure('Failed to swap place');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final errorMessage = data is String ? data : (data?['message'] ?? 'Server Error');
      throw ServerFailure(errorMessage);
    }
  }

  @override
  Future<AIItinerary> generateItinerary(TripPlanRequest request) async {
    try {
      final response = await dio.post(
        '/api/v1/places/trip-plan',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        final String? tripPlanJson = response.data['tripPlan'] ?? response.data['TripPlan'];
        final List<dynamic>? placesJson = response.data['places'] ?? response.data['Places'];

        if (tripPlanJson != null && tripPlanJson.isNotEmpty) {
          try {
            var itinerary = AIItineraryModel.fromString(tripPlanJson);

            // Hydrate with places data from the same response
            if (placesJson != null) {
              final Map<String, dynamic> placesMap = {
                for (var p in placesJson)
                  p['name']?.toString() ?? p['Name']?.toString() ?? '': p
              };

              final hydratedDays = itinerary.days.map((day) {
                final hydratedActivities = day.activities.map((act) {
                  final placeData = placesMap[act.name] ?? placesMap[act.name.replaceAll('the ', 'The ')];
                  if (placeData != null) {
                    final imgUrl = placeData['imageUrl']?.toString() ?? placeData['ImageUrl']?.toString() ?? placeData['mainImageURL']?.toString() ?? placeData['MainImageURL']?.toString();
                    return act.copyWith(
                      imageUrl: (act.imageUrl == null || act.imageUrl!.isEmpty) ? imgUrl : act.imageUrl,
                      category: act.category ?? placeData['category']?.toString() ?? placeData['Category']?.toString(),
                      dbPlaceId: act.dbPlaceId ?? (placeData['dbPlaceId'] as num?)?.toInt() ?? (placeData['DbPlaceId'] as num?)?.toInt(),
                      latitude: act.latitude ?? (placeData['latitude'] as num?)?.toDouble() ?? (placeData['Latitude'] as num?)?.toDouble(),
                      longitude: act.longitude ?? (placeData['longitude'] as num?)?.toDouble() ?? (placeData['Longitude'] as num?)?.toDouble(),
                      rating: act.rating ?? (placeData['rating'] as num?)?.toDouble() ?? (placeData['Rating'] as num?)?.toDouble(),
                    );
                  }
                  return act;
                }).toList();
                
                return TripDay(
                  dayNumber: day.dayNumber,
                  activities: List<ItineraryItem>.from(hydratedActivities),
                  dailySummary: day.dailySummary,
                  transportTips: day.transportTips,
                );
              }).toList();

              itinerary = AIItineraryModel(
                title: itinerary.title,
                duration: itinerary.duration,
                days: List<TripDay>.from(hydratedDays),
              );
            }

            return itinerary;
          } catch (e) {
            throw const ServerFailure('AI generated an incomplete plan. Please try again.');
          }
        }
        return const AIItinerary(title: 'Empty Plan', duration: '0 days', days: []);
      } else {
        throw const ServerFailure('Failed to generate AI itinerary');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final errorMessage = data is String ? data : (data?['message'] ?? 'Server Error');
      throw ServerFailure(errorMessage);
    }
  }

  @override
  Future<TripModel> createTripPlan(String title, DateTime startDate, DateTime endDate, List<String> placeIds) async {
    try {
      final response = await dio.post(
        '/api/v1/trips',
        data: {
          'name': title,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'placeIds': placeIds,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TripModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to create trip');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? (data['message'] ?? 'Server Error') : 'Server Error';
      throw ServerFailure(message.toString());
    }
  }

  @override
  // [KEMORA-MIGRATION] Backend GET /api/v1/trips returns PagedResult<TripListDto> { items: [...], totalCount, page, pageSize }
  // Fixed to unwrap the 'items' array. Falls back to direct list if server returns flat array.
  Future<List<TripModel>> getUserTrips() async {
    try {
      print('=== GET USER TRIPS REQ ===');
      final response = await dio.get('/api/v1/trips');
      print('=== GET USER TRIPS RES ===');
      print('STATUS: ${response.statusCode}');
      print('DATA: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = (data is Map && data.containsKey('items'))
            ? data['items'] as List<dynamic>
            : data as List<dynamic>;
        return items.map((json) => TripModel.fromJson(json)).toList();
      } else {
        throw const ServerFailure('Failed to fetch trips');
      }
    } on DioException catch (e) {
      print('=== GET USER TRIPS ERROR ===');
      print('ERROR: ${e.response?.data}');
      throw ServerFailure(e.response?.data?['message'] ?? 'Server Error');
    } catch (e, stack) {
      print('=== GET USER TRIPS UNHANDLED ERROR ===');
      print(e);
      print(stack);
      throw ServerFailure('Data parsing error');
    }
  }

  @override
  Future<bool> updatePlaceVisitedStatus(int tripId, int tripPlaceId, bool isVisited) async {
    try {
      final response = await dio.put(
        '/api/v1/trips/$tripId/places/$tripPlaceId',
        data: {
          'isVisited': isVisited,
        },
      );
      return response.statusCode == 204;
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? (data['message'] ?? 'Server Error') : 'Server Error updating visited status';
      throw ServerFailure(message.toString());
    }
  }

  @override
  Future<TripModel> getTripDetails(String id) async {
    try {
      print('=== GET_TRIP_DETAILS: id="$id" ===');
      final response = await dio.get('/api/v1/trips/$id');
      print('=== GET_TRIP_DETAILS RES: status=${response.statusCode} ===');
      if (response.statusCode == 200) {
        return TripModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to fetch trip details');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      print('=== GET_TRIP_DETAILS ERROR: status=${e.response?.statusCode} data=$data ===');
      final message = data is Map ? (data['message'] ?? 'Server Error') : 'Server Error';
      throw ServerFailure(message.toString());
    }
  }

  @override
  Future<bool> deleteTrip(String id) async {
    try {
      print('=== DELETE_TRIP: id="$id" url=/api/v1/trips/$id ===');
      if (id.isEmpty) {
        print('DELETE_TRIP ERROR: id is empty! Cannot delete.');
        throw const ServerFailure('Trip ID is empty — cannot delete.');
      }
      final response = await dio.delete('/api/v1/trips/$id');
      print('=== DELETE_TRIP RES: status=${response.statusCode} ===');
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      print('=== DELETE_TRIP ERROR: status=${e.response?.statusCode} data=${e.response?.data} ===');
      throw ServerFailure(e.response?.data?['message'] ?? 'Server Error');
    }
  }

  @override
  Future<bool> renameTrip(String id, String newName) async {
    try {
      print('=== RENAME_TRIP: id="$id" newName="$newName" url=/api/v1/trips/$id ===');
      if (id.isEmpty) {
        print('RENAME_TRIP ERROR: id is empty! Cannot rename.');
        throw const ServerFailure('Trip ID is empty — cannot rename.');
      }
      final response = await dio.put(
        '/api/v1/trips/$id',
        data: {'name': newName},
      );
      print('=== RENAME_TRIP RES: status=${response.statusCode} ===');
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      print('=== RENAME_TRIP ERROR: status=${e.response?.statusCode} data=${e.response?.data} ===');
      throw ServerFailure(e.response?.data?['message'] ?? 'Server Error');
    }
  }
}
