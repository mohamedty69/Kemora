import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/trip.dart';
import '../entities/trip_plan_request.dart';
import '../entities/ai_itinerary.dart';

abstract class ITripRepository {
  Future<Either<Failure, Trip>> createTripPlan(String title, DateTime startDate, DateTime endDate, List<String> placeIds);
  Future<Either<Failure, List<Trip>>> getUserTrips();
  Future<Either<Failure, Trip>> getTripDetails(String id);
  Future<Either<Failure, bool>> deleteTrip(String id);
  Future<Either<Failure, bool>> renameTrip(String id, String newName);
  Future<Either<Failure, AIItinerary>> generateItinerary(TripPlanRequest request);
  Future<Either<Failure, ItineraryItem>> swapPlace(String currentPlaceName, String preferences);
  Future<Either<Failure, Trip>> saveAIPlan(AIItinerary itinerary, DateTime startDate, DateTime endDate);
  Future<Either<Failure, bool>> updatePlaceVisitedStatus(int tripId, int tripPlaceId, bool isVisited);
}
