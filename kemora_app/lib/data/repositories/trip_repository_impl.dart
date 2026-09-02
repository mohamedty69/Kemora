import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_plan_request.dart';
import '../../domain/entities/ai_itinerary.dart';
import '../../domain/repositories/i_trip_repository.dart';
import '../datasources/trip_remote_data_source.dart';

class TripRepositoryImpl implements ITripRepository {
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Trip>> createTripPlan(
      String title, DateTime startDate, DateTime endDate, List<String> placeIds) async {
    try {
      final trip = await remoteDataSource.createTripPlan(title, startDate, endDate, placeIds);
      return Right(trip);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Trip>>> getUserTrips() async {
    try {
      final trips = await remoteDataSource.getUserTrips();
      return Right(trips);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Trip>> getTripDetails(String id) async {
    try {
      final trip = await remoteDataSource.getTripDetails(id);
      return Right(trip);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTrip(String id) async {
    try {
      final success = await remoteDataSource.deleteTrip(id);
      return Right(success);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> renameTrip(String id, String newName) async {
    try {
      final success = await remoteDataSource.renameTrip(id, newName);
      return Right(success);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AIItinerary>> generateItinerary(TripPlanRequest request) async {
    try {
      final itinerary = await remoteDataSource.generateItinerary(request);
      return Right(itinerary);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ItineraryItem>> swapPlace(String currentPlaceName, String preferences) async {
    try {
      final newItem = await remoteDataSource.swapPlace(currentPlaceName, preferences);
      return Right(newItem);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Trip>> saveAIPlan(AIItinerary itinerary, DateTime startDate, DateTime endDate) async {
    try {
      final trip = await remoteDataSource.saveAIPlan(itinerary, startDate, endDate);
      return Right(trip);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> updatePlaceVisitedStatus(int tripId, int tripPlaceId, bool isVisited) async {
    try {
      final success = await remoteDataSource.updatePlaceVisitedStatus(tripId, tripPlaceId, isVisited);
      return Right(success);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Connection Error: ${e.toString()}'));
    }
  }
}
